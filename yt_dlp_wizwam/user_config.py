"""
User configuration storage for yt-dlp-wizwam.

Handles persistent storage of user preferences in a JSON config file.
"""

import json
from pathlib import Path
from typing import Any, Dict


class UserConfig:
    """Manages user configuration stored in ~/.yt-dlp-wizwam/config.json"""
    
    CONFIG_DIR = Path.home() / '.yt-dlp-wizwam'
    CONFIG_FILE = CONFIG_DIR / 'config.json'
    
    DEFAULT_CONFIG = {
        'download_dir': str(Path.home() / 'Downloads' / 'yt-dlp-wizwam'),
        'default_quality': '720p',
        'default_video_codec': 'avc1',
        'default_audio_codec': 'm4a',
    }
    
    @classmethod
    def ensure_config_dir(cls):
        """Ensure config directory exists."""
        cls.CONFIG_DIR.mkdir(parents=True, exist_ok=True)
    
    @classmethod
    def load(cls) -> Dict[str, Any]:
        """Load user configuration from file."""
        cls.ensure_config_dir()
        
        if not cls.CONFIG_FILE.exists():
            # Create default config if it doesn't exist
            cls.save(cls.DEFAULT_CONFIG)
            return cls.DEFAULT_CONFIG.copy()
        
        try:
            with open(cls.CONFIG_FILE, 'r') as f:
                config = json.load(f)
                # Merge with defaults to ensure all keys exist
                return {**cls.DEFAULT_CONFIG, **config}
        except (json.JSONDecodeError, IOError) as e:
            print(f"Warning: Error loading config file: {e}")
            return cls.DEFAULT_CONFIG.copy()
    
    @classmethod
    def save(cls, config: Dict[str, Any]) -> bool:
        """Save user configuration to file."""
        cls.ensure_config_dir()
        
        try:
            with open(cls.CONFIG_FILE, 'w') as f:
                json.dump(config, f, indent=2)
            return True
        except IOError as e:
            print(f"Error saving config file: {e}")
            return False
    
    @classmethod
    def get(cls, key: str, default: Any = None) -> Any:
        """Get a single config value."""
        config = cls.load()
        return config.get(key, default)
    
    @classmethod
    def set(cls, key: str, value: Any) -> bool:
        """Set a single config value."""
        config = cls.load()
        config[key] = value
        return cls.save(config)
    
    @classmethod
    def update(cls, updates: Dict[str, Any]) -> bool:
        """Update multiple config values."""
        config = cls.load()
        config.update(updates)
        return cls.save(config)
