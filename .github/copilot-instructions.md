# Copilot Instructions for yt-dlp-wizwam

## Project Overview

**Python package** providing YouTube/video downloader with dual interfaces: CLI + embedded web server. Being refactored from Docker-only web app (`yt-dlp.wizwam.com`) into pip-installable package (`yt-dlp-wizwam`).

**Status:** Early development (v0.0.2-alpha)  
**Architecture:** Single-process embedded mode (default) + optional Docker mode  
**Target:** PyPI distribution following yt-dlp model (CLI + web in one package)

## Critical Context

### This is NOT the Docker Project
The old project (`yt-dlp.wizwam.com`) used Flask + Celery + Redis in Docker containers. This NEW project is a standalone Python package with simplified embedded mode.

**IMPORTANT:** The old Docker project runs on port 42070. The NEW package uses port 8080 by default to avoid conflicts when both are running.

**Key differences:**
- **Old:** Multi-container Docker with Redis pub/sub between Flask and Celery (port 42070)
- **New:** Single-process embedded server with threading (no Docker required, port 8080)
- **Old:** Main file `dv.py` (1038 lines)
- **New:** Modular package in `yt_dlp_wizwam/` directory
- **Old:** Production deployment to NAS
- **New:** Desktop/laptop pip install for end users

### Package vs Docker Modes

**Embedded Mode (default):**
```python
# yt_dlp_wizwam/config.py
DEPLOYMENT_MODE = 'embedded'
CELERY_BROKER_URL = 'memory://'  # In-memory queue
USE_REDIS = False
SOCKETIO_MESSAGE_QUEUE = None    # Direct emit, no pub/sub
```

**Docker Mode (optional for production):**
```python
DEPLOYMENT_MODE = 'docker'
CELERY_BROKER_URL = 'redis://redis:6379/0'
USE_REDIS = True
SOCKETIO_MESSAGE_QUEUE = 'redis://...'  # Cross-process messaging
```

### Refactoring in Progress

**Status (see `TODO.md`):**
- ✅ Phase 1: Package structure, CLI, downloader logic
- 🚧 Phase 2: Web interface refactoring (CURRENT)
  - Need to port templates from old project
  - Need to port static assets (CSS, JS)
  - Need to adapt Socket.IO for embedded mode
- ⏳ Phase 3: Testing and PyPI publication

**DO NOT** copy Docker-specific patterns from old project. Adapt for embedded mode.

## Essential Files

### Package Structure
```
yt_dlp_wizwam/
├── __init__.py          # Package exports (main, Config, __version__)
├── __main__.py          # `python -m yt_dlp_wizwam` entry point
├── cli.py               # Click-based CLI commands (197 lines)
├── config.py            # Configuration with embedded/docker modes (159 lines)
├── downloader.py        # yt-dlp wrapper with progress tracking (335 lines)
├── web.py               # Flask app (stub, needs refactoring from old dv.py)
├── templates/           # HTML templates (TO BE ADDED from old project)
└── static/              # CSS/JS assets (TO BE ADDED from old project)
```

### Packaging Files
- `setup.py` - setuptools metadata, entry points (`downloader`, `yt-dlp-web`, `yt-dlp-cli`)
- `pyproject.toml` - Modern packaging (PEP 517/518)
- `MANIFEST.in` - Include templates/static in distribution
- `requirements.txt` - Core dependencies for pip install

### Key References
- **Old Docker project:** `/home/luke/dev/yt-dlp.wizwam.com/` (source for templates/static)
- **TODO tracker:** `TODO.md` - refactoring status and checklist
- **Version tracking:** `CHANGELOG.md` - Keep a Changelog format

## Critical Patterns

### Entry Points Pattern
Three CLI entry points defined in `setup.py`:

```python
entry_points={
    'console_scripts': [
        'downloader=yt_dlp_wizwam.cli:main',           # Main: defaults to web UI
        'yt-dlp-web=yt_dlp_wizwam.cli:start_web',      # Web server only
        'yt-dlp-cli=yt_dlp_wizwam.cli:cli_download',   # CLI download only
    ],
}
```

**User workflows:**
```bash
downloader                           # No args → start web UI (invoke_without_command)
downloader download {URL}            # CLI download
downloader web --port 8080           # Web with custom port
yt-dlp-web                           # Alias for web mode
yt-dlp-cli {URL}                     # Alias for CLI download
```

**Implementation (see `cli.py` lines 173-195):**
```python
def start_web():
    """Entry point for 'yt-dlp-web' command."""
    sys.argv = [sys.argv[0], 'web'] + sys.argv[1:]
    main()

def cli_download():
    """Entry point for 'yt-dlp-cli' command."""
    if len(sys.argv) < 2:
        click.echo('Usage: yt-dlp-cli {URL} [OPTIONS]')
        sys.exit(1)
    sys.argv = [sys.argv[0], 'download'] + sys.argv[1:]
    main()
```

**Why this approach:** Simpler than yt-dlp's single-binary approach. Uses `sys.argv` manipulation to simulate Click subcommands, which works well for package-based distribution.

### Progress Tracking (Multi-Stream Downloads)
yt-dlp downloads video+audio separately. Track each stream to prevent "bouncing" progress:

```python
# yt_dlp_wizwam/downloader.py
class DownloadProgress:
    def __init__(self, callback):
        self.stream_progress = {}  # {filename: percent}
    
    def __call__(self, d):
        if d.get('status') == 'downloading':
            filename = os.path.basename(d.get('filename', 'unknown'))
            self.stream_progress[filename] = d.get('_percent', 0.0)
            overall = sum(self.stream_progress.values()) / len(self.stream_progress)
            self.callback('downloading', overall, ...)
```

**Why:** Video and audio streams download concurrently; averaging prevents UI jitter.

### Filename Convention (from old project)
Deterministic naming prevents overwrites:

```python
# Format: {date}_{sanitized_title}_{height}p_{vcodec}_{acodec}__{platform}_{videoID}.{ext}
# Example: 20251007_Some_Video_720p_avc1_m4a__youtube_dQw4w9WgXcQ.mp4

def build_filename(info, quality, url):
    date = info.get('upload_date') or datetime.now().strftime('%Y%m%d')
    title = sanitize_title(info['title'])  # Remove special chars, _ for spaces
    height = Config.get_quality_height(quality)
    vcodec = info.get('vcodec', 'unknown')[:20]
    acodec = info.get('acodec', 'unknown')[:20]
    platform = info.get('extractor_key', 'site').lower()
    vid_id = info.get('id') or hashlib.sha256(url.encode()).hexdigest()[:10]
    return f"{date}_{title}_{height}p_{vcodec}_{acodec}__{platform}_{vid_id}"
```

**Why this format:**
- **Date prefix:** Chronological sorting by default
- **Sanitized title:** Filesystem-safe, underscore-separated words
- **Codecs in filename:** Easy to identify format without inspecting file
- **Platform & ID suffix:** Prevents duplicates, enables re-download detection
- **Deterministic:** Same video always generates same filename

**Title sanitization rules (see `downloader.py` line 77-97):**
- Remove special chars: `[<>:"/\\|?*]`
- Replace spaces with underscores
- Collapse multiple underscores
- Trim leading/trailing underscores
- Limit to 100 characters

### Future: Local Search & LLM Integration (Phase 10 in TODO.md)

**Planned features:**
- SQLite database for downloaded video metadata
- Full-text search on titles, descriptions, tags
- Plugin system for extensible post-processing
- LLM integration for transcription and clip generation
- Social media export presets (Twitter, Instagram, YouTube Shorts)

**Filename design supports this:**
- Structured format enables regex parsing for retroactive database population
- Platform and video ID allow fetching additional metadata from source
- Codec information helps with re-encoding decisions

**Plugin architecture (planned):**
```python
# Example: LLM plugin for transcription
class TranscriptPlugin(PluginBase):
    def on_download_complete(self, video_info):
        # Extract audio, send to Whisper
        transcript = whisper.transcribe(video_info['filename'])
        # Store in database
        db.update_video(video_info['id'], transcript=transcript)
```

See `TODO.md` Phase 10 for full specification.

### Package Data Inclusion
Templates and static files MUST be included in distribution:

```python
# setup.py
include_package_data=True,
package_data={
    'yt_dlp_wizwam': [
        'templates/*.html',
        'static/**/*',
        'static/css/*',
        'static/js/*',
    ],
}
```

```
# MANIFEST.in
include README.md LICENSE CHANGELOG.md
recursive-include yt_dlp_wizwam/templates *.html
recursive-include yt_dlp_wizwam/static *.css *.js *.png
```

### FFmpeg Auto-Download
Use `imageio-ffmpeg` to bundle FFmpeg (no system dependency):

```python
# yt_dlp_wizwam/config.py
FFMPEG_AUTO_DOWNLOAD = True

# yt_dlp_wizwam/downloader.py
import imageio_ffmpeg
ffmpeg_path = imageio_ffmpeg.get_ffmpeg_exe()  # Auto-downloads if missing
```

## Common Tasks

### Development Setup
```bash
cd /home/luke/dev/yt-dlp-wizwam

# Create virtual environment
python -m venv venv
source venv/bin/activate  # Linux/Mac

# Install in editable mode with dev dependencies
pip install -e ".[dev]"

# Verify installation
downloader --version
which downloader  # Should show venv path
```

### Running Locally
```bash
# Web interface (default)
python -m yt_dlp_wizwam
# OR
downloader

# CLI download
downloader download https://youtube.com/watch?v=dQw4w9WgXcQ

# Custom options
downloader download {URL} --quality 1080p --video-codec av1 --output-dir ~/Videos
```

### Refactoring from Old Project
When porting code from `/home/luke/dev/yt-dlp.wizwam.com/dv.py`:

**1. Remove Celery/Redis patterns:**
```python
# ❌ OLD (Docker mode with Celery)
@celery.task
def download_task(job_id, url, quality):
    redis_client.publish('progress_updates', ...)

# ✅ NEW (Embedded mode with threading)
def download_task(job_id, url, quality, socketio_instance):
    socketio_instance.emit('progress', ...)  # Direct emit
```

**2. Simplify Socket.IO:**
```python
# ❌ OLD (cross-process via Redis)
def redis_progress_listener():
    for message in pubsub.listen():
        socketio.emit(...)

# ✅ NEW (same process)
@socketio.on('connect')
def handle_connect():
    emit('connected', {'status': 'ok'})
```

**3. File paths:**
```python
# ❌ OLD (hardcoded /data mount)
DOWNLOAD_DIR = '/data/downloads'

# ✅ NEW (user home directory)
DOWNLOAD_DIR = Path.home() / 'Downloads' / 'yt-dlp-wizwam'
```

### Testing Package Installation
```bash
# Build distribution
python -m build

# Install locally
pip install dist/yt_dlp_wizwam-1.0.0-py3-none-any.whl

# Test entry points
downloader --version
yt-dlp-web --help
yt-dlp-cli --help

# Verify package data
python -c "from yt_dlp_wizwam import Config; print(Config.VERSION)"
```

### Publishing to PyPI (when ready)
```bash
# Build distribution
python -m build

# Check distribution
twine check dist/*

# Upload to TestPyPI first
twine upload --repository testpypi dist/*

# Test install from TestPyPI
pip install --index-url https://test.pypi.org/simple/ yt-dlp-wizwam

# Upload to PyPI (production)
twine upload dist/*
```

## Version Management

**Single Source of Truth:** `yt_dlp_wizwam/__init__.py`

The version is defined in ONE place only: `yt_dlp_wizwam/__init__.py` as `__version__ = '0.0.2-alpha'`

All other files read from this source:
- `setup.py` - Uses `get_version()` function to dynamically extract from `__init__.py`
- `scripts/sync-to-github.sh` - Reads `__version__` to create git tags
- Runtime imports - `from yt_dlp_wizwam import __version__`

**To update version:**
1. Edit `yt_dlp_wizwam/__init__.py` - Change `__version__ = '0.0.X-alpha'`
2. Update `CHANGELOG.md` - Add new `## [0.0.X-alpha] - YYYY-MM-DD` section with changes
3. Everything else updates automatically

**Version format:** Follow [Semantic Versioning](https://semver.org/)
- Development: `0.0.X-alpha`, `0.0.X-beta`
- Pre-release: `0.1.0-rc1`
- Stable: `1.0.0`, `1.1.0`, `2.0.0`

**Changelog format:** Follow [Keep a Changelog](https://keepachangelog.com/)

**DO NOT** manually edit version in `setup.py` or `pyproject.toml` - they are not used as version sources.

## Gotchas

1. **Package data must be in MANIFEST.in** - Templates/static won't be included without it
2. **Use Path.home(), not /data/** - This is desktop package, not Docker container
3. **Don't copy Redis/Celery patterns** - Use direct Socket.IO emit in embedded mode
4. **Entry point names matter** - `downloader` is main CLI, others are aliases
5. **FFmpeg via imageio-ffmpeg** - Avoid system FFmpeg dependency for pip install
6. **Python 3.10+ required** - For modern type hints and match statements (if used)
7. **Test in clean venv** - Avoid host system pollution during development

## Reference: Old Docker Project

**Location:** `/home/luke/dev/yt-dlp.wizwam.com/`

**DO copy from old project:**
- Templates (`templates/*.html`) - adapt for embedded mode
- Static assets (`static/css/`, `static/js/`)
- Filename sanitization logic
- Format selection strings (H.264 compatibility)
- Matrix theme styling

**DO NOT copy from old project:**
- Celery task definitions (`@celery.task`)
- Redis pub/sub patterns
- Docker-specific paths (`/data/`, `/app/`)
- Deployment scripts (`deploy-and-test.sh`, `sync-to-github.sh`)
- Multi-container architecture

## Style Guide

- **CLI:** Use Click decorators, group commands logically
- **Logging:** Use standard `logging` module (not print statements)
- **Type hints:** Add for public APIs (optional for internal)
- **Docstrings:** Google-style for functions/classes
- **Error messages:** User-friendly for CLI, technical for logs
- **Configuration:** Use `Config` class, respect environment variables

## Testing Strategy

```bash
# Unit tests
pytest tests/

# Coverage
pytest --cov=yt_dlp_wizwam --cov-report=html

# Test CLI commands
downloader --version
downloader download --help

# Test web interface
downloader web --port 42070
# Open http://localhost:42070 in browser

# Test package installation
pip install dist/*.whl
downloader  # Should work outside project directory
```
