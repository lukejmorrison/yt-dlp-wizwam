"""
Example custom processor plugin
This demonstrates how to create a custom plugin for yt-dlp-wizwam
"""
from typing import Dict, Any
from wizwam.core.plugin import ProcessorPlugin


class TitleCapitalizerPlugin(ProcessorPlugin):
    """
    Example processor plugin that capitalizes video titles
    """
    
    @property
    def name(self) -> str:
        return "title-capitalizer"
    
    @property
    def version(self) -> str:
        return "1.0.0"
    
    @property
    def description(self) -> str:
        return "Capitalizes video titles in download results"
    
    def process(self, data: Dict[str, Any]) -> Dict[str, Any]:
        """
        Process download data by capitalizing the title
        
        Args:
            data: Download result data
            
        Returns:
            Processed data with capitalized title
        """
        if 'title' in data:
            data['title'] = data['title'].upper()
        
        return data
