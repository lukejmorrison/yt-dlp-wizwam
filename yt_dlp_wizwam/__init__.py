"""
yt-dlp-wizwam: Advanced YouTube downloader with CLI and web interface.

This package provides both command-line and web interfaces for downloading
videos from 1800+ websites using yt-dlp as the backend.
"""

__version__ = '0.0.2-alpha'
__author__ = 'Luke J Morrison'
__license__ = 'MIT'

# Expose main components
from yt_dlp_wizwam.cli import main
from yt_dlp_wizwam.config import Config

__all__ = ['main', 'Config', '__version__']
