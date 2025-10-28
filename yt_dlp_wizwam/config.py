"""
Configuration module for yt-dlp-wizwam.

Handles both embedded mode (default) and Docker/production modes.
"""

import os
from pathlib import Path
from .user_config import UserConfig


class Config:
    """Base configuration class."""
    
    # Application metadata
    APP_NAME = 'yt-dlp-wizwam'
    VERSION = '0.0.2-alpha'
    
    # Deployment mode
    DEPLOYMENT_MODE = os.getenv('DEPLOYMENT_MODE', 'embedded')  # 'embedded' or 'docker'
    
    # Web server settings
    HOST = os.getenv('HOST', '0.0.0.0')
    PORT = int(os.getenv('PORT', '8080'))  # Changed from 42070 to avoid conflict with Docker deployment
    DEBUG = os.getenv('DEBUG', 'False').lower() == 'true'
    SECRET_KEY = os.getenv('SECRET_KEY', 'dev-secret-key-change-in-production')
    
    # Download settings
    # Priority: 1) Environment variable, 2) User config file, 3) Default
    _user_config = UserConfig.load()
    DOWNLOAD_DIR = os.getenv(
        'YT_DLP_WIZWAM_DOWNLOAD_DIR',
        _user_config.get('download_dir', str(Path.home() / 'Downloads' / 'yt-dlp-wizwam'))
    )
    
    # Macro script settings
    MACRO_SCRIPT = os.getenv(
        'YT_DLP_WIZWAM_MACRO_SCRIPT',
        str(Path.home() / '.config' / 'yt-dlp-wizwam' / 'macros' / 'default.sh')
    )
    MACRO_DIR = os.getenv(
        'YT_DLP_WIZWAM_MACRO_DIR',
        str(Path.home() / '.config' / 'yt-dlp-wizwam' / 'macros')
    )
    
    # NAS settings (for Synology integration)
    NAS_ENABLED = os.getenv('YT_DLP_WIZWAM_NAS_ENABLED', 'False').lower() == 'true'
    NAS_HOST = os.getenv('YT_DLP_WIZWAM_NAS_HOST', '')
    NAS_USER = os.getenv('YT_DLP_WIZWAM_NAS_USER', '')
    NAS_PASSWORD = os.getenv('YT_DLP_WIZWAM_NAS_PASSWORD', '')
    NAS_SHARE_PATH = os.getenv('YT_DLP_WIZWAM_NAS_SHARE_PATH', '')
    NAS_API_URL = os.getenv('YT_DLP_WIZWAM_NAS_API_URL', '')  # Synology FileStation API
    
    # yt-dlp default settings
    DEFAULT_QUALITY = '720p'
    DEFAULT_VIDEO_CODEC = 'avc1'  # H.264 for compatibility
    DEFAULT_AUDIO_CODEC = 'm4a'   # AAC for compatibility
    
    # Quality mapping
    QUALITY_MAP = {
        '4k': 2160,
        '1080p': 1080,
        '720p': 720,
        '480p': 480,
        '360p': 360,
    }
    
    # Codec preferences
    VIDEO_CODECS = {
        'avc1': 'H.264 (best compatibility)',
        'av1': 'AV1 (best compression)',
        'vp9': 'VP9 (good compression)',
    }
    
    AUDIO_CODECS = {
        'm4a': 'AAC (best compatibility)',
        'opus': 'Opus (best quality)',
        'mp3': 'MP3 (universal)',
    }
    
    # Task queue settings
    if DEPLOYMENT_MODE == 'embedded':
        # Embedded mode: use in-memory queue
        CELERY_BROKER_URL = 'memory://'
        CELERY_RESULT_BACKEND = 'cache+memory://'
        USE_REDIS = False
    else:
        # Docker mode: use Redis
        CELERY_BROKER_URL = os.getenv('CELERY_BROKER_URL', 'redis://redis:6379/0')
        CELERY_RESULT_BACKEND = os.getenv('CELERY_RESULT_BACKEND', 'redis://redis:6379/1')
        USE_REDIS = True
    
    # Socket.IO settings
    SOCKETIO_MESSAGE_QUEUE = None if DEPLOYMENT_MODE == 'embedded' else CELERY_BROKER_URL
    SOCKETIO_ASYNC_MODE = 'eventlet'
    
    # CORS settings
    CORS_ORIGINS = os.getenv('CORS_ORIGINS', '*').split(',')
    
    # Logging
    LOG_LEVEL = os.getenv('LOG_LEVEL', 'INFO')
    LOG_DIR = os.getenv('LOG_DIR', str(Path.home() / '.yt-dlp-wizwam' / 'logs'))
    
    # File verification settings (for NAS stability)
    FILE_VERIFICATION_ENABLED = os.getenv('FILE_VERIFICATION_ENABLED', 'True').lower() == 'true'
    FILE_VERIFICATION_DELAY = int(os.getenv('FILE_VERIFICATION_DELAY', '2'))  # seconds
    FILE_VERIFICATION_TIMEOUT = int(os.getenv('FILE_VERIFICATION_TIMEOUT', '10'))  # seconds
    
    # FFmpeg settings
    FFMPEG_AUTO_DOWNLOAD = True  # Use imageio-ffmpeg for automatic FFmpeg
    
    @classmethod
    def ensure_directories(cls):
        """Create necessary directories if they don't exist."""
        Path(cls.DOWNLOAD_DIR).mkdir(parents=True, exist_ok=True)
        Path(cls.LOG_DIR).mkdir(parents=True, exist_ok=True)
    
    @classmethod
    def get_quality_height(cls, quality: str) -> int:
        """Get height in pixels for a quality string."""
        return cls.QUALITY_MAP.get(quality, 720)
    
    @classmethod
    def validate(cls):
        """Validate configuration."""
        errors = []
        
        # Check download directory is writable
        try:
            Path(cls.DOWNLOAD_DIR).mkdir(parents=True, exist_ok=True)
            test_file = Path(cls.DOWNLOAD_DIR) / '.write_test'
            test_file.write_text('test')
            test_file.unlink()
        except Exception as e:
            errors.append(f"Download directory not writable: {e}")
        
        # Check log directory is writable
        try:
            Path(cls.LOG_DIR).mkdir(parents=True, exist_ok=True)
        except Exception as e:
            errors.append(f"Log directory not writable: {e}")
        
        if errors:
            raise RuntimeError(f"Configuration validation failed: {', '.join(errors)}")
        
        return True


class ProductionConfig(Config):
    """Production configuration."""
    DEBUG = False
    SECRET_KEY = os.getenv('SECRET_KEY')  # Must be set in production
    
    @classmethod
    def validate(cls):
        """Additional production validation."""
        super().validate()
        
        if cls.SECRET_KEY == 'dev-secret-key-change-in-production':
            raise RuntimeError("SECRET_KEY must be set in production!")
        
        return True


class DevelopmentConfig(Config):
    """Development configuration."""
    DEBUG = True
    LOG_LEVEL = 'DEBUG'


# Configuration factory
def get_config():
    """Get appropriate configuration based on environment."""
    env = os.getenv('FLASK_ENV', 'production')
    
    if env == 'development':
        return DevelopmentConfig
    else:
        return ProductionConfig if Config.DEPLOYMENT_MODE == 'docker' else Config
