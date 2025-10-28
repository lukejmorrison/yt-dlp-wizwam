"""
Plugin manager for discovering and managing plugins
"""
import importlib
import inspect
from typing import Dict, List, Type, Optional
from pathlib import Path

from wizwam.core.plugin import BasePlugin, DownloaderPlugin, ProcessorPlugin


class PluginManager:
    """
    Manages plugin discovery, registration, and execution
    """
    
    def __init__(self):
        self._plugins: Dict[str, BasePlugin] = {}
        self._plugin_classes: Dict[str, Type[BasePlugin]] = {}
    
    def register_plugin(self, plugin_class: Type[BasePlugin], config: Optional[Dict] = None):
        """
        Register a plugin class
        
        Args:
            plugin_class: The plugin class to register
            config: Optional configuration for the plugin
        """
        if not issubclass(plugin_class, BasePlugin):
            raise ValueError(f"{plugin_class} must inherit from BasePlugin")
        
        plugin_instance = plugin_class(config)
        plugin_name = plugin_instance.name
        
        self._plugin_classes[plugin_name] = plugin_class
        self._plugins[plugin_name] = plugin_instance
    
    def get_plugin(self, name: str) -> Optional[BasePlugin]:
        """
        Get a registered plugin by name
        
        Args:
            name: Plugin name
            
        Returns:
            Plugin instance or None
        """
        return self._plugins.get(name)
    
    def list_plugins(self) -> List[Dict[str, str]]:
        """
        List all registered plugins
        
        Returns:
            List of plugin information dictionaries
        """
        return [
            {
                'name': plugin.name,
                'version': plugin.version,
                'description': plugin.description,
                'type': type(plugin).__name__
            }
            for plugin in self._plugins.values()
        ]
    
    def execute_plugin(self, name: str, context: Dict) -> Dict:
        """
        Execute a plugin by name
        
        Args:
            name: Plugin name
            context: Execution context
            
        Returns:
            Execution results
        """
        plugin = self.get_plugin(name)
        if not plugin:
            raise ValueError(f"Plugin '{name}' not found")
        
        return plugin.execute(context)
    
    def discover_plugins(self, plugin_dir: Path):
        """
        Discover and register plugins from a directory
        
        Args:
            plugin_dir: Directory to search for plugins
        """
        if not plugin_dir.exists():
            return
        
        for py_file in plugin_dir.glob("*.py"):
            if py_file.name.startswith("_"):
                continue
            
            module_name = f"wizwam.plugins.{py_file.stem}"
            try:
                module = importlib.import_module(module_name)
                
                for name, obj in inspect.getmembers(module):
                    if (inspect.isclass(obj) and 
                        issubclass(obj, BasePlugin) and 
                        obj not in [BasePlugin, DownloaderPlugin, ProcessorPlugin]):
                        self.register_plugin(obj)
            except Exception as e:
                print(f"Error loading plugin from {py_file}: {e}")


# Global plugin manager instance
plugin_manager = PluginManager()
