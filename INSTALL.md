# yt-dlp-wizwam Installation Guide

## Quick Install (PopOS/Ubuntu/Linux)

### Prerequisites
- Python 3.10 or higher
- Your Wizwam hat icon at: `/home/luke/Pictures/wizwam/wizwam-hat-logo1-495x400.png`

### Installation Steps

1. **Clone or navigate to the project directory:**
   ```bash
   cd /home/luke/dev/yt-dlp-wizwam
   ```

2. **Run the installer:**
   ```bash
   ./install.sh
   ```

3. **Launch the app:**
   - **From Applications Menu**: Search for "yt-dlp Wizwam" in COSMIC (Utilities category)
   - **From Terminal**: Run `yt-dlp-wizwam`
   - **Direct**: Run `~/.local/bin/yt-dlp-wizwam`

4. **First Launch:**
   - Browser will open automatically to `http://localhost:8080`
   - Start downloading videos!

## What Gets Installed

| Item | Location |
|------|----------|
| Application files | `~/.local/share/yt-dlp-wizwam/` |
| Virtual environment | `~/.local/share/yt-dlp-wizwam/venv/` |
| Desktop entry | `~/.local/share/applications/yt-dlp-wizwam.desktop` |
| Icon | `~/.local/share/icons/hicolor/512x512/apps/yt-dlp-wizwam.png` |
| Launcher script | `~/.local/bin/yt-dlp-wizwam` |
| Configuration | `~/.yt-dlp-wizwam/config.json` |
| Downloads | `~/Downloads/yt-dlp-wizwam/` (default) |

## Desktop Entry Details

The app will appear in:
- **Application Menu**: Utilities → yt-dlp Wizwam
- **Search**: Type "wizwam" or "download"
- **Categories**: Utility, AudioVideo, Video, Network

## Uninstalling

To remove the application:

```bash
cd /home/luke/dev/yt-dlp-wizwam
./uninstall.sh
```

This removes the app but preserves your:
- Configuration file (`~/.yt-dlp-wizwam/config.json`)
- Downloaded videos (`~/Downloads/yt-dlp-wizwam/`)

To remove everything including config and downloads:
```bash
./uninstall.sh
rm -rf ~/.yt-dlp-wizwam
rm -rf ~/Downloads/yt-dlp-wizwam
```

## Troubleshooting

### Icon Not Showing
If the Wizwam hat icon doesn't appear:

1. **Check icon exists:**
   ```bash
   ls -lh /home/luke/Pictures/wizwam/wizwam-hat-logo1-495x400.png
   ```

2. **Update icon cache manually:**
   ```bash
   gtk-update-icon-cache -f -t ~/.local/share/icons/hicolor
   ```

3. **Log out and back in** to refresh COSMIC

### App Not in Menu
If the app doesn't appear in your application menu:

1. **Update desktop database:**
   ```bash
   update-desktop-database ~/.local/share/applications
   ```

2. **Check desktop file exists:**
   ```bash
   cat ~/.local/share/applications/yt-dlp-wizwam.desktop
   ```

3. **Log out and back in** or restart COSMIC

### Command Not Found: yt-dlp-wizwam
If the terminal command doesn't work:

1. **Check PATH includes ~/.local/bin:**
   ```bash
   echo $PATH | grep -o "$HOME/.local/bin"
   ```

2. **Add to PATH if missing** (add to `~/.bashrc` or `~/.zshrc`):
   ```bash
   export PATH="$HOME/.local/bin:$PATH"
   ```

3. **Reload shell:**
   ```bash
   source ~/.zshrc  # or ~/.bashrc
   ```

### Python Version Error
If you get a Python version error:

```bash
python3 --version  # Should be 3.10 or higher
```

Install newer Python if needed:
```bash
sudo apt update
sudo apt install python3.12 python3.12-venv
```

### Port Already in Use
If port 8080 is in use, the app will automatically find an available port (8081, 8082, etc.)

You can also specify a custom port:
```bash
python3 -m yt_dlp_wizwam web --port 9000
```

## Manual Installation

If you prefer to install manually:

```bash
# Create virtual environment
python3 -m venv ~/.local/share/yt-dlp-wizwam/venv

# Activate it
source ~/.local/share/yt-dlp-wizwam/venv/bin/activate

# Install package
cd /home/luke/dev/yt-dlp-wizwam
pip install -e .

# Run the app
python3 -m yt_dlp_wizwam web --open-browser
```

## Development Mode

To run without installing (for development):

```bash
cd /home/luke/dev/yt-dlp-wizwam
python3 -m yt_dlp_wizwam web --open-browser
```

## Updating

To update to the latest version:

```bash
cd /home/luke/dev/yt-dlp-wizwam
git pull  # If using git
./install.sh  # Reinstall
```

The installer will:
- Remove old virtual environment
- Create fresh virtual environment
- Install latest version
- Preserve your configuration and downloads

## Support

For issues, check:
- **Logs**: `~/.yt-dlp-wizwam/logs/`
- **Config**: `~/.yt-dlp-wizwam/config.json`
- **GitHub Issues**: [Report a bug](https://github.com/lukejmorrison/yt-dlp-wizwam/issues)
