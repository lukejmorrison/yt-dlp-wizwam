#!/bin/bash
# yt-dlp-wizwam Ubuntu/Debian Installer
# Single-file installer for Ubuntu, Debian, Linux Mint, Pop!_OS, etc.

set -e

VERSION="0.0.2-alpha"
PACKAGE_URL="https://github.com/lukejmorrison/yt-dlp-wizwam/archive/refs/heads/main.zip"

echo "🚀 Installing yt-dlp-wizwam v${VERSION} for Ubuntu/Debian"
echo "=========================================================="
echo ""

# Check for Python 3.10+
if ! command -v python3 &> /dev/null; then
    echo "❌ Python 3 not found. Installing..."
    sudo apt update
    sudo apt install -y python3 python3-pip python3-venv
fi

PYTHON_VERSION=$(python3 -c 'import sys; print(f"{sys.version_info.major}.{sys.version_info.minor}")')
if (( $(echo "$PYTHON_VERSION < 3.10" | bc -l) )); then
    echo "❌ Python 3.10+ required. Current version: $PYTHON_VERSION"
    echo "Install Python 3.10+: sudo apt install python3.10 python3.10-venv"
    exit 1
fi

# Install system dependencies
echo "📦 Installing system dependencies..."
sudo apt update
sudo apt install -y python3-pip python3-venv ffmpeg unzip wget curl

# Create installation directory
INSTALL_DIR="$HOME/.local/share/yt-dlp-wizwam"
echo "📁 Installing to: $INSTALL_DIR"

if [ -d "$INSTALL_DIR" ]; then
    echo "⚠️  Previous installation found. Backing up..."
    mv "$INSTALL_DIR" "$INSTALL_DIR.backup-$(date +%Y%m%d-%H%M%S)"
fi

mkdir -p "$INSTALL_DIR"
cd "$INSTALL_DIR"

# Download source
echo "⬇️  Downloading source..."
wget -O yt-dlp-wizwam.zip "$PACKAGE_URL"
unzip -q yt-dlp-wizwam.zip
mv yt-dlp-wizwam-main/* .
rm -rf yt-dlp-wizwam-main yt-dlp-wizwam.zip

# Create virtual environment
echo "🔧 Creating virtual environment..."
python3 -m venv venv
source venv/bin/activate

# Install package
echo "📥 Installing yt-dlp-wizwam..."
pip install --upgrade pip
pip install -e .

# Create system-wide launchers
echo "🔗 Creating launchers..."
mkdir -p "$HOME/.local/bin"

cat > "$HOME/.local/bin/downloader" << 'LAUNCHER_EOF'
#!/bin/bash
source "$HOME/.local/share/yt-dlp-wizwam/venv/bin/activate"
exec python -m yt_dlp_wizwam "$@"
LAUNCHER_EOF

chmod +x "$HOME/.local/bin/downloader"
ln -sf "$HOME/.local/bin/downloader" "$HOME/.local/bin/yt-dlp-web"
ln -sf "$HOME/.local/bin/downloader" "$HOME/.local/bin/yt-dlp-cli"

# Add to PATH if needed
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    echo "" >> "$HOME/.bashrc"
    echo "# yt-dlp-wizwam" >> "$HOME/.bashrc"
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"
    export PATH="$HOME/.local/bin:$PATH"
fi

echo ""
echo "✅ Installation complete!"
echo ""
echo "Usage:"
echo "  downloader              # Start web interface"
echo "  yt-dlp-cli <URL>        # Download from CLI"
echo "  downloader --help       # Show help"
echo ""
echo "⚠️  Note: You may need to restart your terminal or run:"
echo '  source ~/.bashrc'
echo ""
