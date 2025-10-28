# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### To Be Determined
- Authentication system for multi-user deployments
- Download queue management UI
- Retry logic for failed downloads
- Local search database (SQLite) for downloaded videos
- LLM integration for transcription and clip generation

## [0.0.2-alpha] - 2025-10-28

### Fixed
- **Progress bar stuck at 0%** - Implemented proper percentage extraction
  - Added `downloaded_bytes / total_bytes` calculation in downloader.py
  - Three fallback methods for percentage extraction
  - Real-time updates now show actual progress (14.4%, 28.8%, etc.)
- **Multi-stream progress bouncing** - Changed from average to minimum calculation
  - Video and audio streams download separately
  - Using minimum prevents "bouncing" when one stream finishes early
  - Code: `overall = min(self.stream_progress.values())` (downloader.py:72)
- **Button functionality broken** - Fixed JavaScript onclick handlers
  - HTML entity escaping (`&apos;`) was breaking JavaScript strings
  - Implemented `escapeJs()` function in app.js
  - VIEW, MACRO, DOWNLOAD, DELETE buttons now functional with special characters
- **Network access limited to localhost** - Configured LAN accessibility
  - Changed default HOST from `'127.0.0.1'` to `'0.0.0.0'` in config.py
  - Server now accessible via LAN IP (e.g., http://192.168.8.232:8081)
  - Maintains localhost access as well

### Added
- **Custom download directory** - Web UI for selecting and saving download folder
  - Real-time path validation
  - Persistent storage in `~/.yt-dlp-wizwam/config.json`
  - Environment variable override support (`DOWNLOAD_DIR`)
  - Automatic directory creation with error handling
- **Search and sort** - Client-side file filtering and sorting
  - Real-time search as you type
  - 6 sorting options (newest, oldest, name A-Z, name Z-A, size largest, size smallest)
  - File count display with filter status
  - Case-insensitive matching
- **Video player** - In-browser video viewing with keyboard shortcuts
  - HTML5 player with custom controls
  - YouTube-style keyboard shortcuts (Space, J/L, arrows, K, F, M)
  - Fullscreen support (F key or button)
  - Seek forward/back (J/L keys, arrow keys)
- **Macro system** - Customizable post-download scripts
  - NAS upload integration tested and working
  - Synology FileStation API support
  - Programmatic share link generation
  - Environment variable support for credentials

### Changed
- Version updated to 0.0.2-alpha (early development phase)
- Default port remains 8080 (previously documented auto-detection was not actually implemented)
- Network binding now defaults to all interfaces (0.0.0.0) instead of localhost only

### Technical Details
- **Progress tracking algorithm:** Multi-stream aware using minimum calculation
- **Socket.IO:** Direct emit in embedded mode (no Redis pub/sub)
- **JavaScript security:** Proper escaping for onclick attributes
- **Network configuration:** HOST environment variable supported
- **File storage:** Configurable via UserConfig with JSON persistence

## [0.0.1-alpha] - 2025-01-26

### Added
- Initial release as PyPI-installable package
- CLI interface with `downloader`, `yt-dlp-cli`, and `yt-dlp-web` commands
- Web interface with Matrix theme
- Real-time download progress via WebSocket
- Support for 1800+ websites via yt-dlp
- Smart format selection optimized for compatibility
- URL-based sharing for mobile devices
- Automatic FFmpeg bundling via imageio-ffmpeg
- Embedded mode (no Docker required)
- Desktop launcher integration (.desktop files)
- **Automatic port detection** - Finds available port if default is in use
- **Smart conflict resolution** - Avoids port conflicts with Docker deployment
- **Custom download directory** - Web UI for selecting and saving download folder (2025-10-27)
  - Real-time path validation
  - Persistent storage in `~/.yt-dlp-wizwam/config.json`
  - Environment variable override support
  - Automatic directory creation
- **Search and sort** - Client-side file filtering and sorting (2025-10-27)
  - Real-time search as you type
  - 6 sorting options (newest, oldest, name, size)
  - File count display with filter status
- **Video player** - In-browser video viewing with keyboard shortcuts (2025-10-27)
  - HTML5 player with custom controls
  - YouTube-style keyboard shortcuts (Space, J/L, arrows)
  - Fullscreen support
- **Macro system** - Customizable post-download scripts (2025-10-27)
  - NAS upload integration
  - Synology FileStation API support
  - Programmatic share link generation

### Changed
- Refactored from Docker-only deployment to pip-installable package
- Migrated from external Redis to embedded task queue
- Simplified architecture for single-user desktop use
- **Default port changed from 42070 to 8080** - Prevents conflicts with Docker deployment
- Port detection with automatic fallback (8080 → 8081 → 8082, etc.)

### Technical Details
- Python 3.10+ required
- Built with Flask, Click, yt-dlp
- Entry points: `downloader` (main), `yt-dlp-web`, `yt-dlp-cli`
- Default port: 8080 (auto-detects if in use)
- Download directory: ~/Downloads/yt-dlp-wizwam

---

## Legacy Versions (Docker-based)

### [47.15] - 2025-10-09
- Share feature pivot to URL-based sharing
- Fixed Signal/X/AirDrop compatibility
- Added analytics tracking for share attempts
- Improved file verification on NAS

### [47.14] - 2025-10-08
- Enhanced deployment validation
- Improved error handling for WebSocket connections
- Updated sync-to-github.sh with security checks

### Earlier versions
See [UpdateHistory.md](../yt-dlp.wizwam.com/UpdateHistory.md) in the original Docker project.

---

[1.0.0]: https://github.com/lukejmorrison/yt-dlp-wizwam/releases/tag/v1.0.0
