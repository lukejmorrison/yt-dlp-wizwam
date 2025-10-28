"""
Tests for the plugin system
"""
import pytest
from wizwam.core.plugin import BasePlugin, DownloaderPlugin, ProcessorPlugin
from wizwam.core.manager import PluginManager


class MockDownloaderPlugin(DownloaderPlugin):
    """Mock downloader plugin for testing"""
    
    @property
    def name(self):
        return "test-downloader"
    
    def download(self, url, options=None):
        return {'success': True, 'url': url}


class MockProcessorPlugin(ProcessorPlugin):
    """Mock processor plugin for testing"""
    
    @property
    def name(self):
        return "test-processor"
    
    def process(self, data):
        data['processed'] = True
        return data


def test_plugin_registration():
    """Test plugin registration"""
    manager = PluginManager()
    manager.register_plugin(MockDownloaderPlugin)
    
    plugin = manager.get_plugin("test-downloader")
    assert plugin is not None
    assert plugin.name == "test-downloader"


def test_plugin_execution():
    """Test plugin execution"""
    manager = PluginManager()
    manager.register_plugin(MockDownloaderPlugin)
    
    result = manager.execute_plugin("test-downloader", {'url': 'http://test.com'})
    assert result['success'] is True
    assert result['url'] == 'http://test.com'


def test_list_plugins():
    """Test listing plugins"""
    manager = PluginManager()
    manager.register_plugin(MockDownloaderPlugin)
    manager.register_plugin(MockProcessorPlugin)
    
    plugins = manager.list_plugins()
    assert len(plugins) == 2
    
    names = [p['name'] for p in plugins]
    assert 'test-downloader' in names
    assert 'test-processor' in names


def test_processor_plugin():
    """Test processor plugin"""
    manager = PluginManager()
    manager.register_plugin(MockProcessorPlugin)
    
    result = manager.execute_plugin("test-processor", {'data': {'title': 'Test'}})
    assert result['processed'] is True
    assert result['title'] == 'Test'
