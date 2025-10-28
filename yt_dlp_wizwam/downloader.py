"""
Download logic for yt-dlp-wizwam.

This module wraps yt-dlp functionality with smart format selection,
progress tracking, and error handling.
"""

import os
import sys
from pathlib import Path
from datetime import datetime
import hashlib
import re
import yt_dlp
from typing import Dict, Optional, Callable

from yt_dlp_wizwam.config import Config


class DownloadProgress:
    """Track download progress."""
    
    def __init__(self, callback: Optional[Callable] = None):
        """
        Initialize progress tracker.
        
        Args:
            callback: Optional callback function for progress updates
                     Called with (phase, percent, message) tuple
        """
        self.callback = callback
        self.stream_progress = {}  # Track multi-stream downloads
    
    def __call__(self, d: Dict):
        """
        Progress hook called by yt-dlp.
        
        Args:
            d: Progress dictionary from yt-dlp
        """
        status = d.get('status')
        
        if status == 'downloading':
            # Track individual stream progress (video + audio download separately)
            filename = os.path.basename(d.get('filename', 'unknown'))
            
            # Try multiple methods to get percentage
            percent_float = 0.0
            
            # Method 1: Use downloaded_bytes / total_bytes
            downloaded = d.get('downloaded_bytes', 0)
            total = d.get('total_bytes') or d.get('total_bytes_estimate', 0)
            
            if total > 0:
                percent_float = (downloaded / total) * 100.0
            else:
                # Method 2: Parse _percent_str
                percent_str = d.get('_percent_str', '0%').strip().rstrip('%')
                try:
                    percent_float = float(percent_str)
                except (ValueError, TypeError):
                    # Method 3: Check for fragment info
                    frag_index = d.get('fragment_index')
                    frag_count = d.get('fragment_count')
                    if frag_index and frag_count:
                        percent_float = (frag_index / frag_count) * 100.0
            
            self.stream_progress[filename] = percent_float
            
            # Calculate overall progress - use MINIMUM to avoid bouncing
            # (download isn't complete until ALL streams finish)
            if self.stream_progress:
                overall = min(self.stream_progress.values())
            else:
                overall = 0.0
            
            # Format message
            speed = d.get('_speed_str', 'Unknown')
            eta = d.get('_eta_str', 'Unknown')
            message = f'Speed: {speed}, ETA: {eta}'
            
            if self.callback:
                self.callback('downloading', overall, message)
        
        elif status == 'finished':
            if self.callback:
                self.callback('processing', 100.0, 'Merging video and audio...')
        
        elif status == 'error':
            if self.callback:
                self.callback('error', 0.0, d.get('error', 'Unknown error'))


def sanitize_title(title: str) -> str:
    """
    Sanitize video title for use in filename.
    
    Args:
        title: Original video title
    
    Returns:
        Sanitized title safe for filesystem
    """
    # Remove special characters
    title = re.sub(r'[<>:"/\\|?*]', '', title)
    # Replace spaces with underscores
    title = title.replace(' ', '_')
    # Remove consecutive underscores
    title = re.sub(r'_{2,}', '_', title)
    # Trim underscores
    title = title.strip('_')
    # Limit length
    return title[:100]


def build_filename(info: Dict, quality: str, url: str) -> str:
    """
    Build deterministic filename to prevent overwrites.
    
    Format: {date}_{sanitized_title}_{height}p_{vcodec}_{acodec}__{platform}_{videoID}.{ext}
    
    Args:
        info: Video info dictionary from yt-dlp
        quality: Requested quality
        url: Original URL
    
    Returns:
        Base filename (without extension)
    """
    # Date
    upload_date = info.get('upload_date')
    if upload_date:
        date_str = upload_date
    else:
        date_str = datetime.now().strftime('%Y%m%d')
    
    # Title
    title = sanitize_title(info.get('title', 'video'))
    
    # Quality/height
    height = info.get('height') or Config.get_quality_height(quality)
    
    # Codecs
    vcodec = info.get('vcodec', 'unknown')[:20]
    acodec = info.get('acodec', 'unknown')[:20]
    
    # Platform
    extractor = info.get('extractor_key', 'site').lower()
    
    # Video ID
    vid_id = info.get('id') or hashlib.sha256(url.encode()).hexdigest()[:10]
    
    return f"{date_str}_{title}_{height}p_{vcodec}_{acodec}__{extractor}_{vid_id}"


def get_format_string(quality: str, video_codec: str, audio_codec: str, audio_only: bool = False) -> str:
    """
    Build yt-dlp format selection string.
    
    Prioritizes H.264 (avc1) for compatibility with Signal/WhatsApp/etc.
    
    Args:
        quality: Quality string (720p, 1080p, etc.)
        video_codec: Preferred video codec
        audio_codec: Preferred audio codec
        audio_only: Download audio only
    
    Returns:
        Format selection string for yt-dlp
    """
    if audio_only:
        # Audio-only format string
        if audio_codec == 'opus':
            return 'bestaudio[acodec=opus]/bestaudio[ext=webm]/bestaudio'
        elif audio_codec == 'mp3':
            return 'bestaudio[acodec=mp3]/bestaudio'
        else:  # m4a/aac
            return 'bestaudio[acodec=aac]/bestaudio[ext=m4a]/bestaudio'
    
    # Get height from quality
    height = Config.get_quality_height(quality)
    
    # Build video+audio format string with fallbacks
    # Priority: requested codec → H.264 MP4 → any MP4 → WebM → best
    formats = []
    
    # Requested codec
    if video_codec == 'avc1':
        formats.append(f'bestvideo[vcodec=avc1][ext=mp4][height<={height}]+bestaudio[ext=m4a]')
    elif video_codec == 'av1':
        formats.append(f'bestvideo[vcodec^=av01][ext=mp4][height<={height}]+bestaudio[ext=m4a]')
    elif video_codec == 'vp9':
        formats.append(f'bestvideo[vcodec=vp9][ext=webm][height<={height}]+bestaudio')
    
    # Fallback to H.264 MP4 (best compatibility)
    formats.append(f'bestvideo[vcodec=avc1][ext=mp4][height<={height}]+bestaudio[ext=m4a]')
    
    # Fallback to any MP4
    formats.append(f'bestvideo[ext=mp4][height<={height}]+bestaudio[ext=m4a]')
    
    # Fallback to WebM
    formats.append(f'bestvideo[ext=webm][height<={height}]+bestaudio')
    
    # Last resort: best available
    formats.append(f'bestvideo[height<={height}]+bestaudio')
    formats.append('best')
    
    return '/'.join(formats)


def download_video(
    url: str,
    quality: str = '720p',
    video_codec: str = 'avc1',
    audio_codec: str = 'm4a',
    audio_only: bool = False,
    verbose: bool = False,
    progress_callback: Optional[Callable] = None
) -> Dict:
    """
    Download a video using yt-dlp.
    
    Args:
        url: Video URL
        quality: Quality string (720p, 1080p, etc.)
        video_codec: Preferred video codec
        audio_codec: Preferred audio codec
        audio_only: Download audio only
        verbose: Enable verbose logging
        progress_callback: Optional callback for progress updates
    
    Returns:
        Dictionary with download result:
        {
            'status': 'success' or 'error',
            'filename': 'path/to/file.mp4',
            'filesize': 'Size in human-readable format',
            'error': 'Error message if failed'
        }
    """
    try:
        # Ensure download directory exists
        Config.ensure_directories()
        download_dir = Path(Config.DOWNLOAD_DIR)
        
        # Set up progress tracking
        progress = DownloadProgress(progress_callback)
        
        # Build format string
        format_str = get_format_string(quality, video_codec, audio_codec, audio_only)
        
        # yt-dlp options
        ydl_opts = {
            'format': format_str,
            'outtmpl': str(download_dir / '%(title)s.%(ext)s'),  # Temporary, will rename
            'progress_hooks': [progress],
            'quiet': not verbose,
            'no_warnings': not verbose,
            'extract_flat': False,
            'nocheckcertificate': True,
            'ignoreerrors': False,
            'age_limit': None,
            'user_agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
            # FFmpeg options (use bundled via imageio-ffmpeg)
            'prefer_ffmpeg': True,
            'merge_output_format': 'mp4' if not audio_only else None,
        }
        
        # Download video
        with yt_dlp.YoutubeDL(ydl_opts) as ydl:
            # Get video info first
            if progress_callback:
                progress_callback('initializing', 0.0, 'Fetching video information...')
            
            info = ydl.extract_info(url, download=False)
            
            if not info:
                raise RuntimeError('Failed to extract video information')
            
            # Build proper filename
            base_filename = build_filename(info, quality, url)
            ext = 'mp3' if audio_only and audio_codec == 'mp3' else \
                  'opus' if audio_only and audio_codec == 'opus' else \
                  'm4a' if audio_only else \
                  'mp4'
            
            final_filename = f"{base_filename}.{ext}"
            final_path = download_dir / final_filename
            
            # Update output template
            ydl_opts['outtmpl'] = str(download_dir / f'{base_filename}.%(ext)s')
            
            # Perform download
            if progress_callback:
                progress_callback('downloading', 0.0, 'Starting download...')
            
            with yt_dlp.YoutubeDL(ydl_opts) as ydl_download:
                ydl_download.download([url])
            
            # Verify file exists
            if not final_path.exists():
                # Look for file with different extension
                found_files = list(download_dir.glob(f"{base_filename}.*"))
                if found_files:
                    final_path = found_files[0]
                else:
                    raise RuntimeError(f'Downloaded file not found: {final_path}')
            
            # Get file size
            filesize = final_path.stat().st_size
            filesize_mb = filesize / (1024 * 1024)
            
            if progress_callback:
                progress_callback('completed', 100.0, f'Download complete: {filesize_mb:.1f} MB')
            
            return {
                'status': 'success',
                'filename': str(final_path),
                'filesize': f'{filesize_mb:.1f} MB',
                'url': url,
                'title': info.get('title', 'Unknown'),
            }
    
    except Exception as e:
        error_msg = str(e)
        if progress_callback:
            progress_callback('error', 0.0, error_msg)
        
        return {
            'status': 'error',
            'error': error_msg,
            'url': url,
        }


if __name__ == '__main__':
    # Simple CLI test
    if len(sys.argv) < 2:
        print('Usage: python -m yt_dlp_wizwam.downloader {URL}')
        sys.exit(1)
    
    def progress_callback(phase, percent, message):
        print(f'[{phase.upper()}] {percent:.1f}% - {message}')
    
    result = download_video(sys.argv[1], verbose=True, progress_callback=progress_callback)
    
    if result['status'] == 'success':
        print(f'\n✅ Success: {result["filename"]}')
    else:
        print(f'\n❌ Error: {result["error"]}')
