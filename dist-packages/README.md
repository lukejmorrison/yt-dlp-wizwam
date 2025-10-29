# yt-dlp-wizwam Distribution Packages

## Quick Installation

### Ubuntu / Debian / Linux Mint / Pop!_OS
```bash
wget https://raw.githubusercontent.com/lukejmorrison/yt-dlp-wizwam/main/dist-packages/install-ubuntu-0.0.2-alpha.sh
chmod +x install-ubuntu-0.0.2-alpha.sh
./install-ubuntu-0.0.2-alpha.sh
```

### Arch Linux / Manjaro / EndeavourOS
```bash
wget https://raw.githubusercontent.com/lukejmorrison/yt-dlp-wizwam/main/dist-packages/install-arch-0.0.2-alpha.sh
chmod +x install-arch-0.0.2-alpha.sh
./install-arch-0.0.2-alpha.sh
```

### macOS (Intel & Apple Silicon)
```bash
curl -O https://raw.githubusercontent.com/lukejmorrison/yt-dlp-wizwam/main/dist-packages/install-macos-0.0.2-alpha.sh
chmod +x install-macos-0.0.2-alpha.sh
./install-macos-0.0.2-alpha.sh
```

### Windows 10/11
Download and run in PowerShell (as Administrator):
```powershell
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/lukejmorrison/yt-dlp-wizwam/main/dist-packages/install-windows-0.0.2-alpha.ps1" -OutFile "install.ps1"
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
.\install.ps1
```

### Generic Source Installation
For other Linux distributions or manual installation:
```bash
# Download source package
wget https://github.com/lukejmorrison/yt-dlp-wizwam/releases/download/v0.0.2-alpha/yt-dlp-wizwam-v0.0.2-alpha-source.zip
unzip yt-dlp-wizwam-v0.0.2-alpha-source.zip
cd yt-dlp-wizwam-v0.0.2-alpha

# Install
pip install .
```

## Files in This Distribution

| File | Description | Platform |
|------|-------------|----------|
| `install-ubuntu-0.0.2-alpha.sh` | Single-file installer | Ubuntu, Debian, Mint, Pop!_OS |
| `install-arch-0.0.2-alpha.sh` | Single-file installer | Arch, Manjaro, EndeavourOS |
| `install-macos-0.0.2-alpha.sh` | Single-file installer | macOS (Intel & M1/M2/M3) |
| `install-windows-0.0.2-alpha.ps1` | PowerShell installer | Windows 10/11 |
| `yt-dlp-wizwam-v0.0.2-alpha-source.zip` | Source code package | All platforms |
| `SHA256SUMS.txt` | Checksums for verification | - |

## Verify Downloads

```bash
sha256sum -c SHA256SUMS.txt
```

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
chmod +x install-*.sh
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
