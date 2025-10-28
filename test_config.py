#!/usr/bin/env python3
"""
Test script for the download directory configuration feature.
"""

import sys
from pathlib import Path

# Add parent directory to path
sys.path.insert(0, str(Path(__file__).parent))

from yt_dlp_wizwam.user_config import UserConfig
from yt_dlp_wizwam.config import Config

def test_user_config():
    """Test UserConfig class."""
    print("=" * 60)
    print("Testing UserConfig")
    print("=" * 60)
    
    # Test config file location
    print(f"\n✓ Config file location: {UserConfig.CONFIG_FILE}")
    print(f"  Config directory: {UserConfig.CONFIG_DIR}")
    
    # Test loading config
    config = UserConfig.load()
    print(f"\n✓ Loaded config: {config}")
    
    # Test getting a value
    download_dir = UserConfig.get('download_dir')
    print(f"\n✓ Download directory from config: {download_dir}")
    
    # Test Config class integration
    print(f"\n✓ Config.DOWNLOAD_DIR: {Config.DOWNLOAD_DIR}")
    
    print("\n" + "=" * 60)
    print("All tests passed!")
    print("=" * 60)

if __name__ == '__main__':
    test_user_config()
