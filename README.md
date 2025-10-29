# yt-dlp-wizwam

**Advanced YouTube Downloader - CLI + Web Interface**

A powerful, user-friendly wrapper around yt-dlp that provides both command-line and web interfaces for downloading videos from 1800+ websites.

## Features

- 🚀 **Dual Interface**: CLI for power users, beautiful web UI for everyone
- 🎯 **Smart Downloads**: Automatic format selection optimized for compatibility (H.264+AAC by default)
- 🌐 **1800+ Sites**: YouTube, Twitter/X, Instagram, TikTok, Vimeo, and [more](https://github.com/yt-dlp/yt-dlp/blob/master/supportedsites.md)
- 📱 **Mobile-Friendly**: Responsive design, file viewer, macro support for post-processing
- ⚡ **Real-time Progress**: WebSocket-based live updates with multi-stream tracking
- 🎨 **Matrix Theme**: Retro-futuristic green-on-black interface
- 📁 **Flexible Storage**: Configurable download directory with persistence
- 🔧 **Network Ready**: Bind to 0.0.0.0 for LAN access or 127.0.0.1 for localhost only

## Installation

### Quick Install - OS-Specific Single-File Installers

#### Ubuntu / Debian / Linux Mint / Pop!_OS
```bash
wget https://raw.githubusercontent.com/lukejmorrison/yt-dlp-wizwam/main/dist-packages/install-ubuntu-0.0.2-alpha.sh
chmod +x install-ubuntu-0.0.2-alpha.sh
./install-ubuntu-0.0.2-alpha.sh
```

#### Arch Linux / Manjaro / EndeavourOS
```bash
wget https://raw.githubusercontent.com/lukejmorrison/yt-dlp-wizwam/main/dist-packages/install-arch-0.0.2-alpha.sh
chmod +x install-arch-0.0.2-alpha.sh
./install-arch-0.0.2-alpha.sh
```

#### macOS (Intel & Apple Silicon)
```bash
curl -O https://raw.githubusercontent.com/lukejmorrison/yt-dlp-wizwam/main/dist-packages/install-macos-0.0.2-alpha.sh
chmod +x install-macos-0.0.2-alpha.sh
./install-macos-0.0.2-alpha.sh
```

#### Windows 10/11
Download and run in PowerShell (as Administrator):
```powershell
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/lukejmorrison/yt-dlp-wizwam/main/dist-packages/install-windows-0.0.2-alpha.ps1" -OutFile "install.ps1"
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
.\install.ps1
```

### Alternative Installation Methods

#### From PyPI (When Published)

```bash
pip install yt-dlp-wizwam
```

#### Manual Installation from Source

```bash
git clone https://github.com/lukejmorrison/yt-dlp-wizwam.git
cd yt-dlp-wizwam

# For user installation (recommended)
pip install --user .

# For development
pip install -e ".[dev]"
```

#### Linux Generic Installer

```bash
# Clone and install
git clone https://github.com/lukejmorrison/yt-dlp-wizwam.git
cd yt-dlp-wizwam
./install-linux.sh

# Or with options:
./install-linux.sh --help              # Show all installation options
./install-linux.sh --venv ~/.venvs/ytdlp  # Install in virtual environment
./install-linux.sh --dev               # Install with development dependencies
```

## Quick Start

### Web Interface (Default)

```bash
# Start web server (binds to 0.0.0.0:8080 by default)
downloader

# Or explicitly:
yt-dlp-web

# Custom port (will error if port is in use):
downloader web --port 8081

# Localhost only (not accessible from network):
HOST=127.0.0.1 downloader web --port 8080

# With browser auto-open:
downloader web --open-browser
```

**Network Access:**
- Default binding: `0.0.0.0:8080` (accessible from LAN)
- Access locally: `http://localhost:8080`
- Access from network: `http://<your-ip>:8080` (e.g., `http://192.168.1.100:8080`)
- Change via environment: `HOST=127.0.0.1` for localhost only

**Port Detection:**
- App does NOT auto-detect ports when using `--port` flag
- If specified port is in use, you'll see an error
- Default port 8080 is used unless overridden

### CLI Mode

```bash
# Download with defaults (720p, H.264+AAC)
downloader download https://youtube.com/watch?v=...

# Custom quality and codecs
downloader download {URL} --quality 1080p --video-codec av1 --audio-codec opus

# Specify output directory
downloader download {URL} --output-dir ~/Videos
```

## Usage Examples

### Web Interface

1. Start the server: `downloader` or `yt-dlp-web`
2. Open `http://localhost:42070` in your browser
3. Paste a URL and click download
4. Watch real-time progress
5. Share or download completed files

### CLI Commands

```bash
# Basic download
downloader download https://youtube.com/watch?v=dQw4w9WgXcQ

# High quality with AV1 codec
downloader download {URL} --quality 1080p --video-codec av1

# Audio-only download
downloader download {URL} --audio-only --audio-codec opus

# Custom output directory
downloader download {URL} --output-dir ~/Downloads/Videos

# Web interface with custom port
yt-dlp-web --port 8080 --host 0.0.0.0
```

## Command Reference

### `downloader` (Main CLI)

The main entry point with subcommands:

```bash
downloader download {URL} [OPTIONS]  # Download via CLI
downloader web [OPTIONS]             # Start web interface
downloader --help                    # Show help
```

### `yt-dlp-web` (Web Server)

Alias for `downloader web`:

```bash
yt-dlp-web                           # Start on 0.0.0.0:8080
yt-dlp-web --port 5000               # Force specific port
yt-dlp-web --host 127.0.0.1          # Localhost only
yt-dlp-web --open-browser            # Auto-open browser
```

**Important:** Port must be available. No automatic port detection when using `--port` flag.

### Download Options

| Option | Default | Description |
|--------|---------|-------------|
| `--quality` | `720p` | Video quality (720p, 1080p, 4k) |
| `--video-codec` | `avc1` | Video codec (avc1, av1, vp9) |
| `--audio-codec` | `m4a` | Audio codec (m4a, opus, mp3) |
| `--output-dir` | `~/Downloads` | Download directory |
| `--audio-only` | `False` | Download audio only |

## Architecture

### Embedded Mode (Default)

When installed via pip, yt-dlp-wizwam runs in embedded mode:

- **No Docker required**: Runs as standalone Python application
- **Embedded task queue**: Uses in-memory queue instead of Redis
- **Bundled FFmpeg**: Automatic download of platform-specific binary
- **Single process**: Web server handles downloads directly

### Docker Mode (Optional)

For production deployments, use the Docker setup from the original repository:

```bash
git clone https://github.com/lukejmorrison/yt-dlp.wizwam.com.git
cd yt-dlp.wizwam.com
docker-compose up -d
```

## Development

### Setup Development Environment

```bash
git clone https://github.com/lukejmorrison/yt-dlp-wizwam.git
cd yt-dlp-wizwam

# Create virtual environment
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install in editable mode with dev dependencies
pip install -e ".[dev]"

# Run tests
pytest

# Run web interface
python -m yt_dlp_wizwam web
```

### Project Structure

```
yt-dlp-wizwam/
├── yt_dlp_wizwam/           # Main package
│   ├── __init__.py
│   ├── __main__.py          # Entry point for `python -m yt_dlp_wizwam`
│   ├── cli.py               # CLI commands (Click framework)
│   ├── web.py               # Web server (Flask)
│   ├── downloader.py        # Download logic (yt-dlp wrapper)
│   ├── config.py            # Configuration
│   ├── templates/           # HTML templates
│   └── static/              # CSS, JS, images
├── tests/                   # Test suite
├── setup.py                 # Package metadata
├── pyproject.toml           # Modern Python packaging
└── README.md                # This file
```

## Requirements

- Python 3.10+
- FFmpeg (automatically downloaded)
- 500MB+ free disk space for downloads

## Supported Sites

yt-dlp supports 1800+ websites. Check the full list:

```bash
yt-dlp --list-extractors
```

Popular sites include:
- YouTube, YouTube Music
- Twitter/X, Instagram, TikTok
- Vimeo, Dailymotion, Twitch
- Reddit, Facebook, LinkedIn
- And many more...

## Configuration

Configuration is automatic for embedded mode. For advanced users:

```bash
# Set download directory
export YT_DLP_WIZWAM_DOWNLOAD_DIR=~/Videos

# Set web server port
export YT_DLP_WIZWAM_PORT=8080
```

## Troubleshooting

### "Command not found: downloader"

Make sure pip's bin directory is in your PATH:

```bash
# Add to ~/.bashrc or ~/.zshrc
export PATH="$HOME/.local/bin:$PATH"
```

### FFmpeg not found

FFmpeg is automatically downloaded. If issues persist:

```bash
pip install --upgrade imageio-ffmpeg
```

### Port already in use

Change the port:

```bash
yt-dlp-web --port 8080
```

## Contributing

Contributions welcome! Please:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests
5. Submit a pull request

## License

MIT License - see LICENSE file for details

## Credits

- Built on top of [yt-dlp](https://github.com/yt-dlp/yt-dlp)
- Inspired by the command-line simplicity of yt-dlp
- Matrix theme and Douglas Adams references throughout
- Created by [lukejmorrison](https://github.com/lukejmorrison)

## Version

Current version: 1.0.0

See [CHANGELOG.md](CHANGELOG.md) for version history.

## Support

- 🐛 **Issues**: https://github.com/lukejmorrison/yt-dlp-wizwam/issues
- 💬 **Discussions**: https://github.com/lukejmorrison/yt-dlp-wizwam/discussions
- 📖 **Wiki**: https://github.com/lukejmorrison/yt-dlp-wizwam/wiki

---

*"The major difference between a thing that might go wrong and a thing that cannot possibly go wrong is that when a thing that cannot possibly go wrong goes wrong, it usually turns out to be impossible to get at or repair." - Douglas Adams*
