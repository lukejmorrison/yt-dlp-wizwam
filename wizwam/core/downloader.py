"""
Core downloader implementation using yt-dlp
"""
from typing import Dict, Any, Optional, Callable
from pathlib import Path
import yt_dlp


class Downloader:
    """
    Core downloader class wrapping yt-dlp functionality
    """
    
    def __init__(self, output_dir: Optional[str] = None):
        """
        Initialize downloader
        
        Args:
            output_dir: Directory to save downloads (default: ./downloads)
        """
        self.output_dir = Path(output_dir or "./downloads")
        self.output_dir.mkdir(parents=True, exist_ok=True)
    
    def download(
        self, 
        url: str, 
        options: Optional[Dict[str, Any]] = None,
        progress_callback: Optional[Callable] = None
    ) -> Dict[str, Any]:
        """
        Download video/audio from URL
        
        Args:
            url: URL to download from
            options: yt-dlp options override
            progress_callback: Optional callback for progress updates
            
        Returns:
            Dictionary with download results
        """
        default_options = {
            'outtmpl': str(self.output_dir / '%(title)s.%(ext)s'),
            'format': 'best',
            'quiet': False,
            'no_warnings': False,
        }
        
        if options:
            default_options.update(options)
        
        if progress_callback:
            default_options['progress_hooks'] = [progress_callback]
        
        try:
            with yt_dlp.YoutubeDL(default_options) as ydl:
                info = ydl.extract_info(url, download=True)
                
                return {
                    'success': True,
                    'title': info.get('title', 'Unknown'),
                    'url': url,
                    'filename': ydl.prepare_filename(info),
                    'duration': info.get('duration'),
                    'format': info.get('format'),
                    'filesize': info.get('filesize'),
                }
        except Exception as e:
            # Sanitize error message to avoid exposing internal details
            error_msg = "Failed to download video"
            # Only include safe error information
            if "unavailable" in str(e).lower():
                error_msg = "Video is unavailable"
            elif "private" in str(e).lower():
                error_msg = "Video is private"
            elif "not found" in str(e).lower():
                error_msg = "Video not found"
            
            return {
                'success': False,
                'error': error_msg,
                'url': url
            }
    
    def get_info(self, url: str) -> Dict[str, Any]:
        """
        Get video information without downloading
        
        Args:
            url: URL to get info from
            
        Returns:
            Dictionary with video information
        """
        options = {
            'quiet': True,
            'no_warnings': True,
        }
        
        try:
            with yt_dlp.YoutubeDL(options) as ydl:
                info = ydl.extract_info(url, download=False)
                
                return {
                    'success': True,
                    'title': info.get('title', 'Unknown'),
                    'url': url,
                    'duration': info.get('duration'),
                    'formats': [
                        {
                            'format_id': f.get('format_id'),
                            'format': f.get('format'),
                            'ext': f.get('ext'),
                            'filesize': f.get('filesize'),
                        }
                        for f in info.get('formats', [])
                    ],
                    'thumbnail': info.get('thumbnail'),
                    'description': info.get('description'),
                    'uploader': info.get('uploader'),
                    'upload_date': info.get('upload_date'),
                }
        except Exception as e:
            # Sanitize error message to avoid exposing internal details
            error_msg = "Failed to retrieve video information"
            # Only include safe error information
            if "unavailable" in str(e).lower():
                error_msg = "Video is unavailable"
            elif "private" in str(e).lower():
                error_msg = "Video is private"
            elif "not found" in str(e).lower():
                error_msg = "Video not found"
            
            return {
                'success': False,
                'error': error_msg,
                'url': url
            }
