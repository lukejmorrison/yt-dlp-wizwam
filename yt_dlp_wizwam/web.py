"""
Web server module for yt-dlp-wizwam.

Flask application with Socket.IO for real-time progress updates.
Designed to work in both embedded mode (single-user) and Docker mode (multi-user).

TODO: Refactor from /home/luke/dev/yt-dlp.wizwam.com/dv.py
"""

from flask import Flask, render_template, request, jsonify, send_file
from flask_socketio import SocketIO, emit
from flask_cors import CORS
from pathlib import Path
import threading
import queue
import os
import socket
import logging

from yt_dlp_wizwam.config import Config, get_config
from yt_dlp_wizwam.downloader import download_video
from yt_dlp_wizwam.user_config import UserConfig

# Set up logging
logger = logging.getLogger(__name__)


# Set up logging
logger = logging.getLogger(__name__)

# Global SocketIO instance
socketio = SocketIO()


def is_port_in_use(port, host='127.0.0.1'):
    """
    Check if a port is already in use.
    
    Args:
        port: Port number to check
        host: Host address to check (default: 127.0.0.1)
    
    Returns:
        bool: True if port is in use, False if available
    """
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
        try:
            s.bind((host, port))
            return False
        except socket.error:
            return True


def find_available_port(start_port=8080, max_attempts=10, host='127.0.0.1'):
    """
    Find an available port starting from start_port.
    
    Args:
        start_port: Port to start checking from
        max_attempts: Maximum number of ports to try
        host: Host address to check
    
    Returns:
        int: Available port number, or None if none found
    """
    for port in range(start_port, start_port + max_attempts):
        if not is_port_in_use(port, host):
            return port
    return None


def create_app():
    """
    Application factory for Flask app.
    
    Returns:
        Flask app instance
    """
    # Create Flask app
    app = Flask(__name__)
    
    # Load configuration
    config = get_config()
    app.config.from_object(config)
    
    # Ensure directories exist
    Config.ensure_directories()
    
    # Initialize extensions
    CORS(app, resources={r"/*": {"origins": Config.CORS_ORIGINS}})
    socketio.init_app(
        app,
        async_mode=Config.SOCKETIO_ASYNC_MODE,
        cors_allowed_origins=Config.CORS_ORIGINS,
        message_queue=Config.SOCKETIO_MESSAGE_QUEUE,
        logger=True,  # Enable Socket.IO logging
        engineio_logger=True,  # Enable Engine.IO logging
        ping_timeout=60,
        ping_interval=25
    )
    
    # Task queue for embedded mode
    download_queue = queue.Queue()
    
    # Routes
    @app.route('/')
    def index():
        """Main page."""
        return render_template('index.html', version=Config.VERSION)
    
    @app.route('/favicon.ico')
    def favicon():
        """Serve favicon."""
        return send_file(Path(app.root_path) / 'static' / 'favicon.ico', mimetype='image/x-icon')
    
    @app.route('/about')
    def about():
        """About page."""
        return render_template('about.html', version=Config.VERSION)
    
    @app.route('/settings')
    def settings():
        """Settings page."""
        return render_template('settings.html', version=Config.VERSION)
    
    @app.route('/api/config', methods=['GET'])
    def get_config_api():
        """Get current configuration."""
        return jsonify({
            'version': Config.VERSION,
            'download_dir': Config.DOWNLOAD_DIR,
            'deployment_mode': Config.DEPLOYMENT_MODE,
            'qualities': list(Config.QUALITY_MAP.keys()),
            'video_codecs': Config.VIDEO_CODECS,
            'audio_codecs': Config.AUDIO_CODECS,
        })
    
    @app.route('/api/test-socketio', methods=['POST'])
    def test_socketio():
        """Test Socket.IO connection."""
        logger.info("Testing Socket.IO emit...")
        socketio.emit('progress', {
            'job_id': 'test',
            'phase': 'test',
            'percent': 50.0,
            'message': 'Test message from server'
        })
        return jsonify({'status': 'sent', 'message': 'Test emit sent'})
    
    @app.route('/api/config/download-dir', methods=['POST'])
    def update_download_dir():
        """
        Update download directory.
        
        Request body:
        {
            "download_dir": "/path/to/directory"
        }
        """
        data = request.get_json()
        new_dir = data.get('download_dir')
        
        if not new_dir:
            return jsonify({'status': 'error', 'error': 'download_dir is required'}), 400
        
        # Validate the path
        path = Path(new_dir)
        
        # Check if path is absolute
        if not path.is_absolute():
            return jsonify({'status': 'error', 'error': 'Path must be absolute'}), 400
        
        # Try to create the directory if it doesn't exist
        try:
            path.mkdir(parents=True, exist_ok=True)
        except Exception as e:
            return jsonify({'status': 'error', 'error': f'Cannot create directory: {str(e)}'}), 400
        
        # Check if directory is writable
        if not os.access(path, os.W_OK):
            return jsonify({'status': 'error', 'error': 'Directory is not writable'}), 400
        
        # Save to user config
        if UserConfig.set('download_dir', str(path)):
            # Update the Config class (for current session)
            Config.DOWNLOAD_DIR = str(path)
            
            logger.info(f"Download directory updated to: {path}")
            return jsonify({
                'status': 'success',
                'download_dir': str(path),
                'message': 'Download directory updated successfully'
            })
        else:
            return jsonify({'status': 'error', 'error': 'Failed to save configuration'}), 500
    
    @app.route('/api/config/validate-dir', methods=['POST'])
    def validate_dir():
        """
        Validate a directory path.
        
        Request body:
        {
            "path": "/path/to/directory"
        }
        """
        data = request.get_json()
        dir_path = data.get('path')
        
        if not dir_path:
            return jsonify({'valid': False, 'error': 'Path is required'}), 400
        
        path = Path(dir_path)
        
        # Check if path is absolute
        if not path.is_absolute():
            return jsonify({'valid': False, 'error': 'Path must be absolute'})
        
        # Check if path exists
        if path.exists():
            if not path.is_dir():
                return jsonify({'valid': False, 'error': 'Path is not a directory'})
            if not os.access(path, os.W_OK):
                return jsonify({'valid': False, 'error': 'Directory is not writable'})
            return jsonify({'valid': True, 'exists': True})
        else:
            # Check if parent exists and is writable
            parent = path.parent
            if parent.exists() and os.access(parent, os.W_OK):
                return jsonify({'valid': True, 'exists': False, 'message': 'Directory will be created'})
            else:
                return jsonify({'valid': False, 'error': 'Cannot create directory (parent not writable)'})
    
    @app.route('/api/download', methods=['POST'])
    def download():
        """
        Download endpoint.
        
        Request body:
        {
            "url": "https://youtube.com/watch?v=...",
            "quality": "720p",
            "video_codec": "avc1",
            "audio_codec": "m4a",
            "audio_only": false
        }
        """
        data = request.get_json()
        
        url = data.get('url')
        if not url:
            return jsonify({'error': 'URL is required'}), 400
        
        quality = data.get('quality', Config.DEFAULT_QUALITY)
        video_codec = data.get('video_codec', Config.DEFAULT_VIDEO_CODEC)
        audio_codec = data.get('audio_codec', Config.DEFAULT_AUDIO_CODEC)
        audio_only = data.get('audio_only', False)
        
        logger.info(f"Download request: {url} (quality={quality}, video={video_codec}, audio={audio_codec}, audio_only={audio_only})")
        audio_only = data.get('audio_only', False)
        
        # Generate job ID
        import uuid
        job_id = str(uuid.uuid4())
        
        logger.info(f"Starting download job {job_id}")
        logger.info(f"Current download directory: {Config.DOWNLOAD_DIR}")
        
        # Progress callback to emit via Socket.IO
        def progress_callback(phase, percent, message):
            logger.info(f"Progress callback - Job: {job_id}, Phase: {phase}, Percent: {percent:.1f}%, Message: {message}")
            socketio.emit('progress', {
                'job_id': job_id,
                'phase': phase,
                'percent': percent,
                'message': message
            })
        
        # Start download in background thread (embedded mode)
        def download_worker():
            logger.info(f"Download worker started for job {job_id}")
            try:
                logger.info(f"Calling download_video with url={url}, quality={quality}")
                result = download_video(
                    url=url,
                    quality=quality,
                    video_codec=video_codec,
                    audio_codec=audio_codec,
                    audio_only=audio_only,
                    progress_callback=progress_callback
                )
                
                logger.info(f"Download result: {result}")
                
                if result['status'] == 'success':
                    socketio.emit('success', {
                        'job_id': job_id,
                        'filename': os.path.basename(result['filename']),
                        'filepath': result['filename'],
                        'filesize': result.get('filesize', 'Unknown'),
                        'title': result.get('title', 'Unknown')
                    })
                else:
                    socketio.emit('error', {
                        'job_id': job_id,
                        'error': result.get('error', 'Unknown error')
                    })
            except Exception as e:
                logger.exception(f"Download worker error for job {job_id}: {e}")
                socketio.emit('error', {
                    'job_id': job_id,
                    'error': str(e)
                })
        
        # Start download in background using socketio.start_background_task (better for eventlet)
        socketio.start_background_task(download_worker)
        
        return jsonify({
            'job_id': job_id,
            'status': 'started',
            'url': url
        })
    
    @app.route('/api/files', methods=['GET'])
    def list_files():
        """List downloaded files."""
        download_dir = Path(Config.DOWNLOAD_DIR)
        
        if not download_dir.exists():
            return jsonify({'files': []})
        
        files = []
        for filepath in sorted(download_dir.iterdir(), key=lambda p: p.stat().st_mtime, reverse=True):
            if filepath.is_file() and not filepath.name.startswith('.'):
                stat = filepath.stat()
                files.append({
                    'name': filepath.name,  # Changed from 'filename' to 'name' for JS compatibility
                    'filename': filepath.name,  # Keep for backwards compatibility
                    'size': stat.st_size,
                    'size_mb': f'{stat.st_size / (1024 * 1024):.1f} MB',
                    'modified': stat.st_mtime
                })
        
        return jsonify({'files': files})
    
    @app.route('/api/files/<filename>', methods=['GET'])
    def download_file(filename):
        """Download a file."""
        filepath = Path(Config.DOWNLOAD_DIR) / filename
        
        if not filepath.exists() or not filepath.is_file():
            return jsonify({'error': 'File not found'}), 404
        
        return send_file(filepath, as_attachment=True)
    
    @app.route('/api/files/<filename>', methods=['DELETE'])
    def delete_file(filename):
        """Delete a file."""
        filepath = Path(Config.DOWNLOAD_DIR) / filename
        
        if not filepath.exists():
            return jsonify({'status': 'error', 'error': 'File not found'}), 404
        
        try:
            filepath.unlink()
            return jsonify({'status': 'success', 'message': f'Deleted {filename}', 'filename': filename})
        except Exception as e:
            return jsonify({'status': 'error', 'error': str(e)}), 500
    
    @app.route('/view/<filename>')
    def view_file(filename):
        """View file in browser video player."""
        filepath = Path(Config.DOWNLOAD_DIR) / filename
        
        if not filepath.exists() or not filepath.is_file():
            return jsonify({'error': 'File not found'}), 404
        
        return render_template('viewer.html', filename=filename)
    
    @app.route('/serve/<filename>')
    def serve_file(filename):
        """Serve file for video player (with range support for seeking)."""
        filepath = Path(Config.DOWNLOAD_DIR) / filename
        
        if not filepath.exists() or not filepath.is_file():
            return jsonify({'error': 'File not found'}), 404
        
        # Determine MIME type
        if filename.lower().endswith(('.mp4', '.m4v')):
            mimetype = 'video/mp4'
        elif filename.lower().endswith('.webm'):
            mimetype = 'video/webm'
        elif filename.lower().endswith(('.mp3', '.m4a')):
            mimetype = 'audio/mpeg'
        elif filename.lower().endswith('.opus'):
            mimetype = 'audio/opus'
        else:
            mimetype = 'application/octet-stream'
        
        return send_file(filepath, mimetype=mimetype)
    
    @app.route('/api/macro/run', methods=['POST'])
    def run_macro():
        """Run macro script on a file."""
        data = request.get_json()
        filename = data.get('filename')
        
        if not filename:
            return jsonify({'error': 'Filename is required'}), 400
        
        filepath = Path(Config.DOWNLOAD_DIR) / filename
        
        if not filepath.exists():
            return jsonify({'error': 'File not found'}), 404
        
        try:
            # Get macro script path from config
            macro_script = Config.MACRO_SCRIPT
            
            if not macro_script or not Path(macro_script).exists():
                return jsonify({
                    'error': 'Macro script not configured. Please set MACRO_SCRIPT in settings.'
                }), 400
            
            # Run macro script
            import subprocess
            result = subprocess.run(
                [macro_script, str(filepath)],
                capture_output=True,
                text=True,
                timeout=300  # 5 minute timeout
            )
            
            if result.returncode == 0:
                # Parse output for share link (if any)
                share_link = None
                for line in result.stdout.split('\n'):
                    if line.startswith('SHARE_LINK:'):
                        share_link = line.split('SHARE_LINK:')[1].strip()
                
                return jsonify({
                    'status': 'success',
                    'message': result.stdout or 'Macro completed successfully',
                    'share_link': share_link
                })
            else:
                return jsonify({
                    'error': f'Macro failed: {result.stderr or "Unknown error"}'
                }), 500
                
        except subprocess.TimeoutExpired:
            return jsonify({'error': 'Macro script timed out'}), 500
        except Exception as e:
            logger.exception(f"Macro error: {e}")
            return jsonify({'error': str(e)}), 500
    
    # Socket.IO events
    @socketio.on('connect')
    def handle_connect():
        """Handle client connection."""
        emit('connected', {'version': Config.VERSION})
    
    @socketio.on('disconnect')
    def handle_disconnect():
        """Handle client disconnection."""
        pass
    
    @socketio.on('ping')
    def handle_ping():
        """Handle ping from client."""
        emit('pong', {'timestamp': 'now'})
    
    return app


if __name__ == '__main__':
    """Run development server."""
    app = create_app()
    socketio.run(
        app,
        host=Config.HOST,
        port=Config.PORT,
        debug=Config.DEBUG
    )
