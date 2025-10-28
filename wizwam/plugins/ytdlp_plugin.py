"""
Default yt-dlp downloader plugin
"""
from typing import Dict, Any, Optional
from wizwam.core.plugin import DownloaderPlugin
from wizwam.core.downloader import Downloader


class YtDlpPlugin(DownloaderPlugin):
    """
    Default yt-dlp downloader plugin
    """
    
    def __init__(self, config: Optional[Dict[str, Any]] = None):
        super().__init__(config)
        self._downloader = None
    
    @property
    def downloader(self) -> Downloader:
        """Lazy-load the downloader instance"""
        if self._downloader is None:
            output_dir = self.config.get('output_dir', './downloads')
            self._downloader = Downloader(output_dir)
        return self._downloader
    
    @property
    def name(self) -> str:
        return "yt-dlp"
    
    @property
    def version(self) -> str:
        return "1.0.0"
    
    @property
    def description(self) -> str:
        return "Default yt-dlp downloader for videos and audio"
    
    def download(self, url: str, options: Optional[Dict[str, Any]] = None) -> Dict[str, Any]:
        """
        Download using yt-dlp
        
        Args:
            url: URL to download
            options: Download options
            
        Returns:
            Download results
        """
        return self.downloader.download(url, options)
    
    def get_info(self, url: str) -> Dict[str, Any]:
        """
        Get video info without downloading
        
        Args:
            url: URL to get info from
            
        Returns:
            Video information
        """
        return self.downloader.get_info(url)
