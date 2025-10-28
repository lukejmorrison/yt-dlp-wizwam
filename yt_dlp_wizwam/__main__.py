"""
Main entry point for running yt-dlp-wizwam as a module.

Usage:
    python -m yt_dlp_wizwam          # Start web interface (default)
    python -m yt_dlp_wizwam web      # Start web interface
    python -m yt_dlp_wizwam download {URL}  # CLI download
"""

from yt_dlp_wizwam.cli import main

if __name__ == '__main__':
    main()
