"""
Flask web application
"""
from flask import Flask, request, jsonify, render_template
from flask_cors import CORS
from pathlib import Path

from wizwam.core.downloader import Downloader
from wizwam.core.manager import plugin_manager
from wizwam.plugins.ytdlp_plugin import YtDlpPlugin


def create_app():
    """
    Create and configure Flask application
    """
    app = Flask(__name__)
    CORS(app)
    
    # Register default plugin
    plugin_manager.register_plugin(YtDlpPlugin)
    
    # Discover plugins
    plugin_dir = Path(__file__).parent.parent / 'plugins'
    plugin_manager.discover_plugins(plugin_dir)
    
    downloader = Downloader()
    
    @app.route('/')
    def index():
        """Serve the main page"""
        return render_template('index.html')
    
    @app.route('/api/info', methods=['POST'])
    def get_info():
        """Get video information"""
        data = request.get_json()
        url = data.get('url')
        
        if not url:
            return jsonify({'success': False, 'error': 'URL is required'}), 400
        
        result = downloader.get_info(url)
        return jsonify(result)
    
    @app.route('/api/download', methods=['POST'])
    def download():
        """Download video/audio"""
        data = request.get_json()
        url = data.get('url')
        options = data.get('options', {})
        
        if not url:
            return jsonify({'success': False, 'error': 'URL is required'}), 400
        
        result = downloader.download(url, options)
        return jsonify(result)
    
    @app.route('/api/plugins', methods=['GET'])
    def list_plugins():
        """List available plugins"""
        plugins = plugin_manager.list_plugins()
        return jsonify({'plugins': plugins})
    
    @app.route('/api/health', methods=['GET'])
    def health():
        """Health check endpoint"""
        return jsonify({'status': 'ok', 'version': '0.1.0'})
    
    return app


def main():
    """Entry point for web server"""
    app = create_app()
    app.run(host='127.0.0.1', port=5000, debug=True)


if __name__ == '__main__':
    main()
