# TODO: yt-dlp-wizwam Implementation Checklist

**Project Goal:** Transform yt-dlp.wizwam.com Docker web app into pip-installable Python package with CLI and embedded web interface.

**Target:** PyPI-installable package following yt-dlp distribution model (CLI + web interface in one package).

**Current Version:** 0.0.2-alpha (Operational - 2025-10-28)  
**Status:** Core functionality complete and tested. Application is fully operational for personal use.

---

## Phase 1: Core Package Structure ✅

**Status:** COMPLETED (2025-01-26)

- [x] Create project directory: `/home/luke/dev/yt-dlp-wizwam`
- [x] Set up packaging files:
  - [x] `setup.py` - Package metadata and entry points
  - [x] `pyproject.toml` - Modern Python packaging config
  - [x] `MANIFEST.in` - Include templates/static in distribution
  - [x] `requirements.txt` - Dependency list
  - [x] `LICENSE` - MIT license
  - [x] `README.md` - Installation and usage documentation
  - [x] `CHANGELOG.md` - Version history
  - [x] `.gitignore` - Exclude build artifacts
- [x] Create package structure:
  - [x] `yt_dlp_wizwam/__init__.py` - Package initialization (17 lines)
  - [x] `yt_dlp_wizwam/__main__.py` - Module entry point (11 lines)
  - [x] `yt_dlp_wizwam/config.py` - Configuration management (180 lines)
  - [x] `yt_dlp_wizwam/cli.py` - Click-based CLI commands (245 lines)
  - [x] `yt_dlp_wizwam/downloader.py` - yt-dlp wrapper with progress tracking (351 lines)
  - [x] `yt_dlp_wizwam/web.py` - Flask web server (479 lines)
  - [x] `yt_dlp_wizwam/user_config.py` - Persistent configuration (85 lines)

---

## Phase 2: Web Interface Refactoring ✅

**Status:** COMPLETED (2025-10-28)

**Goal:** Refactor Flask app from `/home/luke/dev/yt-dlp.wizwam.com/dv.py` into embeddable `web.py` module.

### Tasks:

#### 2.1 Copy and Adapt Templates ✅
- [x] Create `yt_dlp_wizwam/templates/` directory
- [x] Create templates with embedded mode Socket.IO:
  - [x] `templates/index.html` → Matrix theme, Socket.IO client, download form
  - [x] `templates/about.html` → Version info, features, credits
  - [x] `templates/settings.html` → Configuration display, localStorage settings

---

## Phase 2.5: Distribution Packaging ✅

**Status:** COMPLETED (2025-10-28)

**Goal:** Create OS-specific single-file installers for easy distribution.

### Tasks:

#### 2.5.1 Distribution Package Script ✅
- [x] Create `scripts/create-distribution-package.sh` (232 lines)
- [x] Python regex-based version extraction from `__init__.py`
- [x] Output directory: `dist-packages/`
- [x] Generate SHA256 checksums for all packages
- [x] Create comprehensive installation guide

#### 2.5.2 OS-Specific Installers ✅
- [x] **Ubuntu/Debian Installer** (`install-ubuntu-{version}.sh`)
  - [x] apt-based dependency installation (python3, pip, ffmpeg)
  - [x] Virtual environment in `~/.local/share/yt-dlp-wizwam`
  - [x] Launcher scripts in `~/.local/bin`
  - [x] Automatic PATH configuration in `.bashrc`
  - [x] Backup of previous installations
- [x] **Arch Linux Installer** (`install-arch-{version}.sh`)
  - [x] pacman-based dependency installation
  - [x] Same venv and launcher structure as Ubuntu
  - [x] Compatible with Manjaro, EndeavourOS
- [x] **macOS Installer** (`install-macos-{version}.sh`)
  - [x] Homebrew installation if needed
  - [x] Python 3.11 installation via brew
  - [x] ffmpeg installation via brew
  - [x] Installation in `~/Library/Application Support/yt-dlp-wizwam`
  - [x] zsh PATH configuration
  - [x] Intel and Apple Silicon support
- [x] **Windows Installer** (`install-windows-{version}.ps1`)
  - [x] PowerShell script for Windows 10/11
  - [x] Python version checking (3.10+)
  - [x] Installation in `%LOCALAPPDATA%\yt-dlp-wizwam`
  - [x] Batch launcher scripts in WindowsApps
  - [x] FFmpeg installation instructions
- [x] **Source Package** (`yt-dlp-wizwam-v{version}-source.zip`)
  - [x] Complete source code
  - [x] Setup files and documentation
  - [x] Auto-generated INSTALL.txt
  - [x] For manual installation on any platform

#### 2.5.3 GitHub Sync Enhancement ✅
- [x] Remove basic `scripts/sync-to-github.sh` (368 lines) to avoid confusion
- [x] Keep enhanced `github/sync-to-github.sh` (671 lines) as primary tool
- [x] Features: `--help`, `--testgitauth`, `--dry-run`, `--auto`
- [x] Smart security scanning (excludes scripts, markdown, backups)
- [x] Automatic detection and staging of `dist-packages/` directory

#### 2.5.4 Documentation Updates ✅
- [x] Update `README.md` with OS-specific installation commands
- [x] Update `CHANGELOG.md` with distribution packaging features
- [x] Update `TODO.md` with Phase 2.5 completion status
- [x] Create `dist-packages/README.md` with quick start guide
  - [x] `templates/viewer.html` → In-browser video player
- [x] Update template paths in `web.py` (already correct)
- [x] Test template rendering ✅ **VERIFIED**

#### 2.2 Copy and Adapt Static Assets ✅
- [x] Create `yt_dlp_wizwam/static/` directory structure:
  - [x] `static/css/` - Stylesheets
  - [x] `static/js/` - JavaScript files
- [x] Create static files:
  - [x] `static/css/styles.css` - Matrix theme CSS (green on black, Courier New)
  - [x] `static/js/app.js` - Socket.IO client, download form handling, file management
- [x] Implement responsive design for mobile
- [x] Test static file serving ✅ **VERIFIED**

**Note:** Created new templates/static from scratch with Matrix theme instead of copying from old project. This ensures embedded mode compatibility from the start.

#### 2.3 Refactor Flask Routes ✅
- [x] Port routes from `dv.py` to `web.py`:
  - [x] `/` - Main page with download form
  - [x] `/about` - About page with version info
  - [x] `/settings` - Settings page with configuration
  - [x] `/api/config` - Configuration endpoint (GET/POST)
  - [x] `/api/download` - Download endpoint with threading (not Celery)
  - [x] `/api/files` - List files with metadata
  - [x] `/api/files/<filename>` - Download/delete file
  - [x] `/view/<filename>` - In-browser video player
  - [x] `/api/macro/run` - Run post-download macros
- [x] Adapted for embedded mode (threading instead of Celery)
- [x] Test all routes ✅ **VERIFIED** (15+ routes operational)

#### 2.4 Socket.IO Integration ✅
- [x] Port Socket.IO events:
  - [x] `connect` - Client connection with version info
  - [x] `disconnect` - Client disconnection
  - [x] `ping/pong` - Health check
  - [x] `progress` - Download progress updates (phase, percent, message)
  - [x] `success` - Download completion with file info
  - [x] `error` - Download errors
- [x] Implemented direct Socket.IO emit (no Redis pub/sub needed)
- [x] Test real-time progress updates ✅ **VERIFIED** (showing actual percentages)
- [x] **FIXED (2025-10-28):** Progress tracking stuck at 0%
  - [x] Implemented percentage extraction using `downloaded_bytes / total_bytes`
  - [x] Fixed multi-stream progress bouncing (changed from average to minimum)
  - [x] Verified progress updates: 14.4%, 28.8%, 43.1%, 57.2%, 71.4%, 85.2%, 98.9%, 100%

#### 2.5 Button Functionality ✅
- [x] **FIXED (2025-10-28):** VIEW, MACRO, DOWNLOAD, DELETE buttons not working
  - [x] Identified root cause: HTML entity escaping breaking JavaScript onclick
  - [x] Implemented `escapeJs()` function in app.js (~line 300)
  - [x] Updated button rendering to use JavaScript escaping
  - [x] Verified all buttons functional with special characters in filenames

#### 2.6 Network Configuration ✅
- [x] **CONFIGURED (2025-10-28):** LAN accessibility
  - [x] Changed default HOST from `'127.0.0.1'` to `'0.0.0.0'` in config.py
  - [x] Server accessible via LAN IP (e.g., http://192.168.8.232:8081)
  - [x] Maintains localhost access (http://localhost:8081)
  - [x] Verified cross-device access ✅

#### 2.7 File Verification
- [ ] Port `FileIntegrityManager` from `dv.py`:
  - [ ] Delayed file verification for NAS stability
  - [ ] Two-reading or 10-second timeout logic
  - [ ] Background thread for verification worker
- [ ] Add configuration options:
  - [ ] `FILE_VERIFICATION_ENABLED` (default: True)
  - [ ] `FILE_VERIFICATION_DELAY` (default: 2s)
  - [ ] `FILE_VERIFICATION_TIMEOUT` (default: 10s)
- [ ] Test with large file downloads

**NOTE:** File verification deferred to future version. Current downloads complete successfully without it.

---

## Phase 3: CLI Implementation ✅

**Status:** COMPLETED (2025-10-28)

**Goal:** Fully functional CLI using Click framework.

### Tasks:

#### 3.1 Main CLI Command (`downloader`) ✅
- [x] Entry point setup in `cli.py`
- [x] Version flag: `downloader --version`
- [x] Help text: `downloader --help`
- [x] Default behavior: start web interface when no subcommand
- [x] Test CLI invocation ✅ **VERIFIED**

#### 3.2 Download Subcommand ✅
- [x] Command: `downloader download {URL} [OPTIONS]`
- [x] Options:
  - [x] `--quality` (4k, 1080p, 720p, 480p, 360p)
  - [x] `--video-codec` (avc1, av1, vp9)
  - [x] `--audio-codec` (m4a, opus, mp3)
  - [x] `--audio-only` flag
  - [x] `--output-dir` path
  - [x] `--verbose` flag
- [x] Test downloads with different codecs/qualities ✅ **VERIFIED** (H.264 default working)
- [ ] Test audio-only mode (pending verification)
- [x] Test custom output directory ✅ **VERIFIED** (user_config.py persistence working)

#### 3.3 Web Subcommand ✅
- [x] Command: `downloader web [OPTIONS]`
- [x] Options:
  - [x] `--host` (default: 0.0.0.0)
  - [x] `--port` (default: 8080, actually running on 8081 in current session)
  - [x] `--debug` flag
  - [x] `--open-browser` flag
- [x] Test web server startup ✅ **VERIFIED**
- [x] Test custom port/host ✅ **VERIFIED** (running on 0.0.0.0:8081)
- [ ] Test browser auto-open (pending verification)

#### 3.4 CLI Aliases ✅
- [x] `yt-dlp-web` → `downloader web`
- [x] `yt-dlp-cli` → `downloader download`
- [x] Implement `start_web()` function (done - line 173 in cli.py)
- [x] Implement `cli_download()` function (done - line 180 in cli.py)
- [x] Test entry point aliases ✅ **VERIFIED** (all 3 entry points in setup.py)
- [ ] Verify commands work after `pip install` (pending package installation test)

**Note:** The alias functions use `sys.argv` manipulation to simulate subcommands. This follows a simple pattern:
- `yt-dlp-web` → calls `main()` with `sys.argv = [sys.argv[0], 'web'] + sys.argv[1:]`
- `yt-dlp-cli` → calls `main()` with `sys.argv = [sys.argv[0], 'download'] + sys.argv[1:]`

This is simpler than yt-dlp's approach (which uses a single binary) and more aligned with our package-based distribution.

---

## Phase 4: Download Logic ✅

**Status:** COMPLETED

**Goal:** Robust download functionality with progress tracking.

### Tasks:

- [x] yt-dlp wrapper in `downloader.py`
- [x] Format selection logic:
  - [x] Prioritize H.264 (avc1) for compatibility
  - [x] Support AV1 and VP9 codecs
  - [x] Fallback chain for unavailable formats
- [x] Progress tracking:
  - [x] `DownloadProgress` class with callback support
  - [x] Multi-stream tracking (video + audio)
  - [x] Progress phases: initializing, downloading, processing, completed, error
- [x] Filename generation:
  - [x] Deterministic naming: `{date}_{title}_{height}p_{vcodec}_{acodec}__{platform}_{videoID}.{ext}`
  - [x] Title sanitization (remove special chars, replace spaces)
  - [x] Prevent overwrites
- [x] Error handling and logging

---

## Phase 5: Configuration Management ✅

**Status:** COMPLETED

**Goal:** Flexible configuration for embedded and Docker modes.

### Tasks:

- [x] `Config` class in `config.py`
- [x] Embedded mode defaults:
  - [x] In-memory task queue (no Redis)
  - [x] Bundled FFmpeg via imageio-ffmpeg
  - [x] Single-user optimizations
- [x] Docker mode support:
  - [x] Redis integration
  - [x] Celery task queue
  - [x] Multi-user environment
- [x] Environment variable support:
  - [x] `DEPLOYMENT_MODE` (embedded/docker)
  - [x] `YT_DLP_WIZWAM_DOWNLOAD_DIR`
  - [x] `PORT`, `HOST`, `DEBUG`
  - [x] `SECRET_KEY` for production
- [x] Configuration validation:
  - [x] Directory writability checks
  - [x] Production secret key requirement
- [x] `ProductionConfig` and `DevelopmentConfig` subclasses

---

## Phase 6: Desktop Integration 📋

**Status:** NOT STARTED

**Goal:** Desktop launcher files for Linux/macOS/Windows.

### Tasks:

#### 6.1 Linux (.desktop file)
- [ ] Create `desktop/yt-dlp-wizwam.desktop`:
  ```desktop
  [Desktop Entry]
  Name=yt-dlp Wizwam
  Comment=Advanced YouTube Downloader
  Exec=yt-dlp-web --open-browser
  Icon=/path/to/icon.png
  Terminal=false
  Type=Application
  Categories=AudioVideo;Network;
  ```
- [ ] Create app icon: `desktop/icon.png` (256x256)
- [ ] Installation script for Linux:
  - [ ] Copy .desktop to `~/.local/share/applications/`
  - [ ] Copy icon to `~/.local/share/icons/`
  - [ ] Update desktop database: `update-desktop-database`
- [ ] Test on Ubuntu/Debian/Fedora

#### 6.2 macOS (.app bundle)
- [ ] Research macOS app bundle structure
- [ ] Create launcher script that calls `yt-dlp-web --open-browser`
- [ ] Package as .app with icon
- [ ] Test on macOS

#### 6.3 Windows (.lnk shortcut)
- [ ] Research Windows shortcut creation
- [ ] Create PowerShell script to generate .lnk
- [ ] Point to `pythonw.exe -m yt_dlp_wizwam web --open-browser`
- [ ] Create icon: `desktop/icon.ico`
- [ ] Test on Windows 10/11

#### 6.4 Post-Install Hook
- [ ] Add setup.py post-install script:
  - [ ] Detect OS
  - [ ] Offer to install desktop launcher
  - [ ] Copy files to appropriate locations
- [ ] Test automated installation

---

## Phase 7: Testing & Quality Assurance 📋

**Status:** DEFERRED (waiting for web interface completion)

**Goal:** Comprehensive test coverage and quality checks.

**Note:** Testing will begin after Phase 2 (Web Interface Refactoring) is complete, as we need a working web interface to test end-to-end workflows.

### Tasks:

#### 7.1 Unit Tests
- [ ] Create `tests/` directory structure:
  ```
  tests/
  ├── __init__.py
  ├── conftest.py           # Pytest fixtures
  ├── test_config.py        # Configuration tests
  ├── test_downloader.py    # Download logic tests
  ├── test_cli.py           # CLI command tests
  └── test_web.py           # Web interface tests
  ```
- [ ] Test `config.py`:
  - [ ] Configuration loading
  - [ ] Environment variable parsing
  - [ ] Validation logic (directory writability, production checks)
  - [ ] Mode switching (embedded vs docker)
- [ ] Test `downloader.py`:
  - [ ] Format string generation for different codecs/qualities
  - [ ] Filename sanitization (special chars, length limits)
  - [ ] Filename building (date, title, platform, video ID)
  - [ ] Progress tracking (multi-stream downloads)
  - [ ] Mock yt-dlp downloads using `unittest.mock`
- [ ] Test `cli.py`:
  - [ ] Command parsing and argument validation
  - [ ] Option defaults and overrides
  - [ ] Help text generation
  - [ ] Entry point aliases (`start_web`, `cli_download`)
  - [ ] Error handling and exit codes
- [ ] Test `web.py` (after Phase 2 completion):
  - [ ] Route responses (/, /about, /settings)
  - [ ] API endpoints (/api/config, /api/download, /api/files)
  - [ ] File operations (list, download, delete)
  - [ ] Socket.IO events (connect, disconnect, progress, success, error)
  - [ ] File verification (FileIntegrityManager)
- [ ] Run tests: `pytest tests/ -v`

#### 7.2 Integration Tests
**Prerequisites:** Web interface must be functional (Phase 2 complete)

- [ ] Test full download workflow:
  - [ ] CLI download with various options
  - [ ] Web interface download via API
  - [ ] Progress callbacks and real-time updates
  - [ ] File verification workflow
- [ ] Test Socket.IO real-time updates:
  - [ ] Connect/disconnect events
  - [ ] Progress updates during download
  - [ ] Success notification on completion
  - [ ] Error handling and recovery
- [ ] Test file management:
  - [ ] List downloaded files
  - [ ] Download file from server
  - [ ] Delete file
  - [ ] Handle missing files gracefully
- [ ] Test error scenarios:
  - [ ] Invalid URL
  - [ ] Network failure
  - [ ] Disk full
  - [ ] Permission denied

#### 7.3 Code Quality
- [ ] Set up pre-commit hooks (optional)
- [ ] Run linter: `flake8 yt_dlp_wizwam/ --max-line-length=100`
- [ ] Run formatter: `black yt_dlp_wizwam/ tests/`
- [ ] Run type checker: `mypy yt_dlp_wizwam/ --ignore-missing-imports`
- [ ] Fix all errors and warnings
- [ ] Add docstrings to public functions (Google-style)

#### 7.4 Manual Testing
**Prerequisites:** Web interface must be functional (Phase 2 complete)

- [ ] Test on clean virtual environment:
  ```bash
  python -m venv test_env
  source test_env/bin/activate
  pip install -e .
  downloader --version
  downloader download https://www.youtube.com/watch?v=dQw4w9WgXcQ
  downloader web --open-browser
  ```
- [ ] Test all CLI commands and options:
  - [ ] `downloader` (default to web)
  - [ ] `downloader download {URL}` with various options
  - [ ] `downloader web` with custom port/host
  - [ ] `yt-dlp-web` and `yt-dlp-cli` aliases
- [ ] Test web interface features:
  - [ ] Download with different qualities (720p, 1080p, 4K)
  - [ ] Download with different codecs (H.264, AV1, VP9)
  - [ ] Audio-only downloads
  - [ ] Real-time progress updates
  - [ ] File management (list, download, delete)
  - [ ] Multiple concurrent downloads
- [ ] Test on different platforms:
  - [ ] Linux (Ubuntu, Fedora)
  - [ ] macOS (if available)
  - [ ] Windows (if available)
- [ ] Test with various video sources:
  - [ ] YouTube (public videos, age-restricted)
  - [ ] Twitter/X
  - [ ] Vimeo
  - [ ] Other supported sites

---

## Phase 8: Documentation 📋

**Status:** PARTIAL (README.md created)

**Goal:** Comprehensive documentation for users and developers.

### Tasks:

#### 8.1 User Documentation
- [x] `README.md` - Installation, quick start, usage examples
- [ ] Update README with:
  - [ ] Screenshots of web interface
  - [ ] GIF demo of CLI usage
  - [ ] Troubleshooting section
- [ ] `docs/INSTALLATION.md` - Detailed installation guide
- [ ] `docs/USAGE.md` - Comprehensive usage guide
- [ ] `docs/FAQ.md` - Frequently asked questions
- [ ] `docs/TROUBLESHOOTING.md` - Common issues and solutions

#### 8.2 Developer Documentation
- [ ] `CONTRIBUTING.md` - Contribution guidelines
- [ ] `docs/ARCHITECTURE.md` - System architecture overview
- [ ] `docs/DEVELOPMENT.md` - Development environment setup
- [ ] Code comments and docstrings:
  - [ ] Review all modules
  - [ ] Add missing docstrings
  - [ ] Add type hints where missing
- [ ] API reference (auto-generated from docstrings)

#### 8.3 GitHub Wiki
- [ ] Create wiki pages:
  - [ ] Home - Project overview
  - [ ] Installation - Step-by-step guide
  - [ ] CLI Usage - Command reference
  - [ ] Web Interface - Feature guide
  - [ ] Configuration - Advanced settings
  - [ ] Docker Deployment - Production setup
  - [ ] Troubleshooting - Common issues

---

## Phase 9: PyPI Publishing 📋

**Status:** NOT STARTED

**Goal:** Publish package to PyPI for easy installation.

### Tasks:

#### 9.1 Pre-Publishing Checklist
- [ ] Verify version number in all files:
  - [ ] `setup.py`
  - [ ] `pyproject.toml`
  - [ ] `yt_dlp_wizwam/__init__.py`
  - [ ] `CHANGELOG.md`
  - [ ] `README.md`
- [ ] Verify all dependencies are correct
- [ ] Verify package metadata (author, email, URL)
- [ ] Verify LICENSE is included
- [ ] Run full test suite: `pytest`
- [ ] Build package: `python -m build`
- [ ] Check package contents: `tar -tzf dist/yt-dlp-wizwam-1.0.0.tar.gz`

#### 9.2 Test PyPI (Optional)
- [ ] Create account on test.pypi.org
- [ ] Upload to test PyPI: `twine upload --repository testpypi dist/*`
- [ ] Install from test PyPI:
  ```bash
  pip install --index-url https://test.pypi.org/simple/ yt-dlp-wizwam
  ```
- [ ] Test installation and functionality
- [ ] Fix any issues

#### 9.3 Production PyPI
- [ ] Create account on pypi.org
- [ ] Upload to PyPI: `twine upload dist/*`
- [ ] Verify package page: https://pypi.org/project/yt-dlp-wizwam/
- [ ] Install from PyPI: `pip install yt-dlp-wizwam`
- [ ] Test installation and functionality
- [ ] Update GitHub repository with PyPI badge

#### 9.4 Release Management
- [ ] Tag release in Git: `git tag -a v1.0.0 -m "Release v1.0.0"`
- [ ] Push tags: `git push --tags`
- [ ] Create GitHub release:
  - [ ] Release notes from CHANGELOG.md
  - [ ] Attach source archive
  - [ ] Link to PyPI package
- [ ] Announce release:
  - [ ] GitHub Discussions
  - [ ] Reddit (r/opensource, r/python)
  - [ ] Twitter/X

---

## Phase 9.5: File Registry Search & Sort ✅

**Status:** COMPLETED (2025-01-26)

**Goal:** Add client-side search and sort functionality to file registry for better UX.

### Tasks:

#### 9.5.1 UI Components ✅
- [x] Add search bar to file registry
  - [x] Text input with placeholder "Search files..."
  - [x] Real-time filtering as user types
  - [x] Case-insensitive search
- [x] Add sort dropdown with 6 options:
  - [x] Newest First (default)
  - [x] Oldest First
  - [x] Name (A-Z)
  - [x] Name (Z-A)
  - [x] Size (Largest First)
  - [x] Size (Smallest First)
- [x] Add file count display
  - [x] Shows "X files" normally
  - [x] Shows "Showing X of Y files" when filtering

#### 9.5.2 Client-Side Logic ✅
- [x] Implement `filterAndSortFiles()` function
  - [x] Filter by search term (matches filename)
  - [x] Sort by selected criteria
  - [x] Update count display
  - [x] Render filtered/sorted results
- [x] Add event listeners
  - [x] Search input: real-time filtering on keyup
  - [x] Sort select: re-sort on change
- [x] Refactor `loadFiles()` function
  - [x] Store all files in `allFiles` array
  - [x] Call `filterAndSortFiles()` after fetch
  - [x] Preserve state during auto-refresh

#### 9.5.3 Styling ✅
- [x] Matrix-themed search/sort controls
  - [x] Green borders and text
  - [x] Dark backgrounds
  - [x] Focus states with glow effect
  - [x] Responsive flex layout
- [x] File count styling (dimmed green)
- [x] Search placeholder styling

#### 9.5.4 Future Enhancements 📋
- [ ] Server-side search for large libraries (>500 files)
- [ ] Advanced filters (date range, codec, duration)
- [ ] Saved search queries
- [ ] Search history
- [ ] Full-text search across transcriptions (see Phase 10)

**Implementation Notes:**
- Uses client-side filtering for speed with small libraries
- All files stored in `allFiles` array, filtered on demand
- No database required for initial release
- Ready to scale to server-side when needed (Phase 10)

**Testing:**
- See `test_search_sort.md` for comprehensive testing guide
- Test search with various terms
- Test all sort options
- Verify count updates correctly
- Check mobile responsive layout

---

## Phase 10: Local Search & Media Library 📋

**Status:** PLANNING

**Goal:** Build a searchable media library with metadata and extensible plugin system for post-processing.

### Overview

Create a local search system that indexes downloaded videos and provides extensible hooks for AI-powered enhancements like transcription, clip generation, and social media sharing.

### Tasks:

#### 10.1 Media Library Database
- [ ] Choose database backend:
  - [ ] SQLite (embedded, no external dependencies) - **RECOMMENDED**
  - [ ] JSON files (simple, portable)
  - [ ] PostgreSQL (for production/multi-user)
- [ ] Design schema:
  ```sql
  CREATE TABLE videos (
    id INTEGER PRIMARY KEY,
    filename TEXT UNIQUE NOT NULL,
    original_url TEXT,
    title TEXT,
    platform TEXT,  -- youtube, twitter, vimeo, etc.
    video_id TEXT,  -- platform-specific ID
    upload_date TEXT,
    download_date TEXT,
    quality TEXT,   -- 720p, 1080p, etc.
    video_codec TEXT,  -- avc1, av1, vp9
    audio_codec TEXT,  -- m4a, opus, mp3
    duration INTEGER,  -- seconds
    filesize INTEGER,  -- bytes
    thumbnail_path TEXT,
    metadata JSON,  -- flexible storage for platform-specific data
    tags TEXT,      -- comma-separated tags
    transcript TEXT,  -- full transcript (if generated)
    created_at TIMESTAMP,
    updated_at TIMESTAMP
  );
  
  CREATE TABLE clips (
    id INTEGER PRIMARY KEY,
    video_id INTEGER REFERENCES videos(id),
    start_time REAL,  -- seconds
    end_time REAL,    -- seconds
    title TEXT,
    description TEXT,
    filename TEXT,    -- generated clip file
    created_at TIMESTAMP,
    FOREIGN KEY(video_id) REFERENCES videos(id) ON DELETE CASCADE
  );
  
  CREATE INDEX idx_videos_title ON videos(title);
  CREATE INDEX idx_videos_platform ON videos(platform);
  CREATE INDEX idx_videos_download_date ON videos(download_date);
  ```
- [ ] Create ORM models (SQLAlchemy or Peewee)
- [ ] Implement CRUD operations

#### 10.2 Automatic Metadata Extraction
- [ ] Extract metadata during download:
  - [ ] Video title, description, upload date
  - [ ] Platform and video ID
  - [ ] Duration, resolution, codecs
  - [ ] Thumbnail image
  - [ ] Creator/channel information
- [ ] Store metadata in database
- [ ] Update existing files retroactively (scan downloads folder)

#### 10.3 Local Search Interface
- [ ] Backend search API:
  - [ ] Full-text search on title, description, tags
  - [ ] Filter by platform, date range, quality
  - [ ] Sort by date, duration, filesize
  - [ ] Pagination for large libraries
- [ ] Web UI search component:
  - [ ] Search bar with autocomplete
  - [ ] Advanced filters (platform, quality, date)
  - [ ] Grid/list view toggle
  - [ ] Thumbnail previews
  - [ ] Quick actions (play, download, delete, generate clip)
- [ ] CLI search command:
  ```bash
  downloader search "keyword"
  downloader search --platform youtube --quality 1080p
  downloader search --after 2025-01-01 --before 2025-12-31
  ```

#### 10.4 Plugin System Architecture
- [ ] Design plugin interface:
  ```python
  # yt_dlp_wizwam/plugins/base.py
  class PluginBase:
      """Base class for yt-dlp-wizwam plugins."""
      
      name: str  # Plugin identifier
      version: str
      description: str
      
      def on_download_complete(self, video_info: Dict) -> None:
          """Called when a video download completes."""
          pass
      
      def on_search(self, query: str, results: List[Dict]) -> List[Dict]:
          """Called during search, can modify results."""
          return results
      
      def get_actions(self, video_info: Dict) -> List[Action]:
          """Return available actions for this video."""
          return []
  ```
- [ ] Plugin discovery and loading:
  - [ ] Scan `~/.yt-dlp-wizwam/plugins/` directory
  - [ ] Load plugins via entry points (setuptools plugins)
  - [ ] Validate plugin compatibility
- [ ] Plugin configuration:
  - [ ] Per-plugin settings in config
  - [ ] Enable/disable plugins via UI/CLI
- [ ] Plugin lifecycle hooks:
  - [ ] `on_download_start`
  - [ ] `on_download_complete`
  - [ ] `on_search`
  - [ ] `on_file_delete`

#### 10.5 LLM Integration Plugin (Example)
- [ ] Create example plugin: `yt_dlp_wizwam_llm`
- [ ] Features:
  - [ ] **Transcription:**
    - [ ] Extract audio from video
    - [ ] Send to local LLM (Whisper via llamafile, Ollama, etc.)
    - [ ] Store transcript in database
    - [ ] Make transcript searchable
  - [ ] **Clip Generation:**
    - [ ] Analyze transcript to find key moments
    - [ ] Use LLM to identify quotable segments
    - [ ] Generate video clips with start/end timestamps
    - [ ] Add captions/subtitles to clips
  - [ ] **Social Media Export:**
    - [ ] Generate optimized clips for platforms:
      - [ ] Twitter/X: 2:20 max, square format
      - [ ] Instagram: 60s max, vertical format
      - [ ] YouTube Shorts: 60s max, vertical
    - [ ] Auto-generate captions with LLM
    - [ ] Create preview images/thumbnails
- [ ] Configuration:
  ```python
  # config.py or plugin config
  LLM_BACKEND = 'ollama'  # ollama, llamafile, openai, etc.
  LLM_MODEL = 'mistral'
  WHISPER_MODEL = 'base'  # tiny, base, small, medium, large
  ```
- [ ] Web UI integration:
  - [ ] "Generate Transcript" button on video detail page
  - [ ] "Create Clip" with timestamp selection
  - [ ] "Export for Social" with platform selection
  - [ ] Progress indicators for long-running tasks

#### 10.6 Video Clip Generator
- [ ] UI for clip creation:
  - [ ] Video player with timeline
  - [ ] Drag to select start/end points
  - [ ] Preview selected segment
  - [ ] Add title and description
- [ ] Backend clip generation:
  - [ ] Use FFmpeg to extract segment
  - [ ] Apply filters (resize, crop, add captions)
  - [ ] Save clip to clips directory
  - [ ] Store clip metadata in database
- [ ] Clip management:
  - [ ] List all clips for a video
  - [ ] Delete clips
  - [ ] Export clips
  - [ ] Share clips via URL

#### 10.7 Social Media Integration
- [ ] Platform-specific export presets:
  ```python
  SOCIAL_PRESETS = {
      'twitter': {
          'max_duration': 140,  # seconds
          'aspect_ratio': '1:1',
          'max_size': 512 * 1024 * 1024,  # 512 MB
          'formats': ['mp4'],
      },
      'instagram': {
          'max_duration': 60,
          'aspect_ratio': '9:16',  # vertical
          'formats': ['mp4'],
      },
      'youtube_shorts': {
          'max_duration': 60,
          'aspect_ratio': '9:16',
          'formats': ['mp4'],
      },
  }
  ```
- [ ] Export workflow:
  - [ ] Select video or clip
  - [ ] Choose platform
  - [ ] Auto-resize and optimize
  - [ ] Add captions (from transcript or LLM-generated)
  - [ ] Download optimized file
  - [ ] Copy share URL to clipboard
- [ ] Optional: Direct upload API integration (future)

#### 10.8 Transcript Search & Semantic Search
- [ ] Full-text search on transcripts
- [ ] Timestamp-aware search (jump to specific moment)
- [ ] Semantic search using embeddings:
  - [ ] Generate embeddings for transcript segments
  - [ ] Use vector database (ChromaDB, FAISS)
  - [ ] Search by meaning, not just keywords
  - [ ] "Find videos where someone explains quantum computing"

### Implementation Notes

**Database Choice:** SQLite is recommended for embedded mode (single-user, desktop), with optional PostgreSQL support for Docker/multi-user deployments.

**LLM Backend Options:**
- **Ollama:** Easy local LLM hosting, good for Mistral/Llama models
- **llamafile:** Single-file LLM distribution (Whisper, Mistral, etc.)
- **Whisper.cpp:** Fast local transcription
- **OpenAI API:** Cloud-based (requires API key)

**FFmpeg for Clips:** Already included via imageio-ffmpeg, can be used for clip extraction and format conversion.

**Plugin Distribution:** Plugins can be:
- Built-in (shipped with main package)
- Installable via pip (`pip install yt-dlp-wizwam-llm`)
- User-created (dropped into `~/.yt-dlp-wizwam/plugins/`)

### Dependencies (New)

```python
# For Phase 10
'sqlalchemy>=2.0.0',      # ORM for database
'chromadb>=0.4.0',        # Vector database for semantic search (optional)
'sentence-transformers',  # Embeddings for semantic search (optional)
```

---

## Phase 11: Future Enhancements 💡

**Status:** PLANNING

**Goal:** Additional features and improvements for future versions.

### Potential Features:

#### 11.1 Standalone Binary (PyInstaller)
- [ ] Research PyInstaller for bundling Python app
- [ ] Create `.spec` file for build configuration
- [ ] Build standalone executables:
  - [ ] Linux binary
  - [ ] macOS binary
  - [ ] Windows .exe
- [ ] Test binaries on fresh systems (no Python installed)
- [ ] Add to GitHub releases

#### 11.2 Advanced Download Features
- [ ] Playlist support:
  - [ ] Download entire playlist
  - [ ] Select specific videos
  - [ ] Playlist progress tracking
- [ ] Download queue:
  - [ ] Add multiple URLs
  - [ ] Manage queue (pause, resume, cancel)
  - [ ] Concurrent downloads
- [ ] Download scheduling:
  - [ ] Schedule downloads for later
  - [ ] Bandwidth throttling
  - [ ] Auto-retry failed downloads

#### 11.3 Enhanced Web Interface
- [ ] Dark mode toggle
- [ ] Customizable themes (Matrix, Cyberpunk, Minimalist, etc.)
- [ ] Advanced settings panel:
  - [ ] Custom yt-dlp arguments
  - [ ] Proxy settings
  - [ ] Authentication for protected videos
- [ ] Download history dashboard:
  - [ ] Track all downloads
  - [ ] Search and filter history
  - [ ] Export history to CSV/JSON
  - [ ] Download statistics and charts
- [ ] Preview thumbnails before download
- [ ] Batch operations (delete, export, re-encode)

#### 11.4 Mobile App
- [ ] Research React Native or Flutter
- [ ] Design mobile UI/UX
- [ ] Implement mobile client
- [ ] Connect to local or remote yt-dlp-wizwam server
- [ ] Publish to app stores (optional)

#### 11.5 Browser Extension
- [ ] Chrome/Firefox extension
- [ ] Detect videos on current page
- [ ] Send to yt-dlp-wizwam server with one click
- [ ] Show download progress in extension popup
- [ ] Context menu integration (right-click video → download)

#### 11.6 Cloud/Multi-User Features
- [ ] User authentication and accounts
- [ ] Personal download libraries
- [ ] Shared download queues
- [ ] Remote access via HTTPS
- [ ] Admin dashboard for server management
- [ ] Rate limiting and quotas
- [ ] Webhook notifications (Discord, Slack, etc.)

---

## Implementation Notes

### Current Priorities (2025-01-26)

1. **Phase 2: Web Interface Refactoring** - Copy templates and static assets from original project
2. **Phase 3: CLI Testing** - Test all CLI commands and options
3. **Phase 7: Testing** - Write unit tests and integration tests

### Development Workflow

```bash
# Set up development environment
cd /home/luke/dev/yt-dlp-wizwam
python -m venv venv
source venv/bin/activate
pip install -e ".[dev]"

# Run tests
pytest

# Format code
black yt_dlp_wizwam/

# Lint code
flake8 yt_dlp_wizwam/

# Build package
python -m build

# Install locally
pip install -e .

# Test CLI
downloader --version
downloader download {TEST_URL}
downloader web --open-browser
```

### Testing URLs

**YouTube (Public):**
- Short video: https://www.youtube.com/watch?v=dQw4w9WgXcQ (Never Gonna Give You Up)
- 4K video: https://www.youtube.com/watch?v=LXb3EKWsInQ (Costa Rica 4K)

**Other Platforms:**
- Vimeo: https://vimeo.com/148751763 (Test video)
- Twitter/X: https://twitter.com/[username]/status/[id]

### Version Numbering

Follow Semantic Versioning (semver.org):
- **Major (1.x.x):** Breaking changes
- **Minor (x.1.x):** New features, backward compatible
- **Patch (x.x.1):** Bug fixes, backward compatible

**Current:** v1.0.0 (initial release)

---

## Questions / Decisions Needed

1. **Email address for PyPI:** Update in `setup.py` and `pyproject.toml`
2. **GitHub repository:** Create before PyPI publishing
3. **Desktop launcher auto-install:** Should it be opt-in or opt-out?
4. **PyInstaller binaries:** Include in v1.0.0 or defer to v1.1.0?
5. **Docker deployment:** Keep original Docker setup in separate repo or merge?

---

## Completed Sessions

### Session 1: Initial Setup (2025-01-26)

**Duration:** ~1 hour

**Completed:**
- Created project directory
- Set up all packaging files (setup.py, pyproject.toml, MANIFEST.in, etc.)
- Created core package structure
- Implemented CLI framework with Click
- Implemented download logic with yt-dlp wrapper
- Implemented configuration management
- Created stub for web server (needs refactoring from original)
- Created comprehensive documentation (README.md, CHANGELOG.md)
- Created this TODO.md file

**Next Session Goals:**
1. Copy templates and static assets from original project
2. Refactor Flask routes and Socket.IO from dv.py
3. Test CLI commands with real downloads
4. Write initial unit tests

---

## References

- **Original Docker Project:** `/home/luke/dev/yt-dlp.wizwam.com`
- **yt-dlp Documentation:** https://github.com/yt-dlp/yt-dlp
- **Flask Documentation:** https://flask.palletsprojects.com/
- **Click Documentation:** https://click.palletsprojects.com/
- **PyPI Packaging Guide:** https://packaging.python.org/
- **Semantic Versioning:** https://semver.org/
