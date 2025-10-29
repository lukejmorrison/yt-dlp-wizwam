# yt-dlp-wizwam Distribution Packages

## Quick Installation

These installers always point to the latest stable version. They will automatically:
- Install Python 3.10+ and dependencies
- Set up a virtual environment
- Install yt-dlp-wizwam
- Create launcher scripts in your PATH

### Ubuntu / Debian / Linux Mint / Pop!_OS
```bash
wget https://raw.githubusercontent.com/lukejmorrison/yt-dlp-wizwam/main/dist-packages/install-ubuntu-latest.sh
chmod +x install-ubuntu-latest.sh
./install-ubuntu-latest.sh
```

### Arch Linux / Manjaro / EndeavourOS
```bash
wget https://raw.githubusercontent.com/lukejmorrison/yt-dlp-wizwam/main/dist-packages/install-arch-latest.sh
chmod +x install-arch-latest.sh
./install-arch-latest.sh
```

### macOS (Intel & Apple Silicon)
```bash
curl -O https://raw.githubusercontent.com/lukejmorrison/yt-dlp-wizwam/main/dist-packages/install-macos-latest.sh
chmod +x install-macos-latest.sh
./install-macos-latest.sh
```

### Windows 10/11
Download and run in PowerShell (as Administrator):
```powershell
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/lukejmorrison/yt-dlp-wizwam/main/dist-packages/install-windows-latest.ps1" -OutFile "install.ps1"
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
.\install.ps1
```

### Manual Installation from Source
For other systems or custom installations:
```bash
# Clone repository
git clone https://github.com/lukejmorrison/yt-dlp-wizwam.git
cd yt-dlp-wizwam

# Install
pip install .

# Or for development
pip install -e ".[dev]"
```

## Available Files

| File | Description | Platform |
|------|-------------|----------|
| `install-ubuntu-latest.sh` | Single-file installer | Ubuntu, Debian, Mint, Pop!_OS |
| `install-arch-latest.sh` | Single-file installer | Arch, Manjaro, EndeavourOS |
| `install-macos-latest.sh` | Single-file installer | macOS (Intel & M1/M2/M3) |
| `install-windows-latest.ps1` | PowerShell installer | Windows 10/11 |

> **Note:** For version-specific installers and source packages, see the [Releases](https://github.com/lukejmorrison/yt-dlp-wizwam/releases) page.

## Requirements

- **Python**: 3.10 or higher
- **FFmpeg**: For video processing (auto-installed on Linux/macOS)
- **Storage**: ~100MB for installation

## After Installation

Run the application:
```bash
downloader                # Start web interface
yt-dlp-cli <URL>          # CLI download
downloader --help         # Show help
```

Web interface will be available at: http://localhost:8080

## Troubleshooting

### Permission Denied
```bash
chmod +x install-*-latest.sh
```

### Python Version Issues
Ensure Python 3.10+ is installed:
```bash
python3 --version
```

### PATH Issues
Add to your shell config (~/.bashrc, ~/.zshrc):
```bash
export PATH="$HOME/.local/bin:$PATH"
```

## Support

- **Issues**: https://github.com/lukejmorrison/yt-dlp-wizwam/issues
- **Documentation**: https://github.com/lukejmorrison/yt-dlp-wizwam
- **License**: MIT

---

**Version**: 0.0.2-alpha  
**Repository**: https://github.com/lukejmorrison/yt-dlp-wizwam
