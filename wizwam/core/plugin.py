"""
Base plugin interface for extensibility
"""
from abc import ABC, abstractmethod
from typing import Dict, Any, Optional


class BasePlugin(ABC):
    """
    Base class for all plugins.
    Plugins can extend functionality like custom downloaders, processors, or hooks.
    """
    
    def __init__(self, config: Optional[Dict[str, Any]] = None):
        self.config = config or {}
    
    @property
    @abstractmethod
    def name(self) -> str:
        """Return the plugin name"""
        pass
    
    @property
    def version(self) -> str:
        """Return the plugin version"""
        return "1.0.0"
    
    @property
    def description(self) -> str:
        """Return a description of the plugin"""
        return ""
    
    @abstractmethod
    def execute(self, context: Dict[str, Any]) -> Dict[str, Any]:
        """
        Execute the plugin functionality
        
        Args:
            context: Dictionary containing execution context
            
        Returns:
            Dictionary with results
        """
        pass


class DownloaderPlugin(BasePlugin):
    """
    Base class for downloader plugins
    """
    
    @abstractmethod
    def download(self, url: str, options: Optional[Dict[str, Any]] = None) -> Dict[str, Any]:
        """
        Download content from URL
        
        Args:
            url: The URL to download from
            options: Additional download options
            
        Returns:
            Dictionary with download results
        """
        pass
    
    def execute(self, context: Dict[str, Any]) -> Dict[str, Any]:
        """Execute download based on context"""
        url = context.get('url')
        options = context.get('options', {})
        if not url:
            raise ValueError("URL is required in context")
        return self.download(url, options)


class ProcessorPlugin(BasePlugin):
    """
    Base class for processor plugins that transform downloaded content
    """
    
    @abstractmethod
    def process(self, data: Dict[str, Any]) -> Dict[str, Any]:
        """
        Process downloaded content
        
        Args:
            data: Downloaded content data
            
        Returns:
            Processed data
        """
        pass
    
    def execute(self, context: Dict[str, Any]) -> Dict[str, Any]:
        """Execute processing based on context"""
        data = context.get('data')
        if not data:
            raise ValueError("Data is required in context")
        return self.process(data)
