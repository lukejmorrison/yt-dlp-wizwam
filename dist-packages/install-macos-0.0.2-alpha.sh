#!/bin/bash
# yt-dlp-wizwam macOS Installer
# Single-file installer for macOS (Intel & Apple Silicon)

set -e

VERSION="0.0.2-alpha"
PACKAGE_URL="https://github.com/lukejmorrison/yt-dlp-wizwam/archive/refs/heads/main.zip"

echo "🚀 Installing yt-dlp-wizwam v${VERSION} for macOS"
echo "=================================================="
echo ""

# Check for Homebrew
if ! command -v brew &> /dev/null; then
    echo "❌ Homebrew not found. Installing..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Install Python 3.10+ if needed
if ! command -v python3 &> /dev/null; then
    echo "📦 Installing Python..."
    brew install python@3.11
fi

PYTHON_VERSION=$(python3 -c 'import sys; print(f"{sys.version_info.major}.{sys.version_info.minor}")')
if (( $(echo "$PYTHON_VERSION < 3.10" | bc -l) )); then
    echo "❌ Python 3.10+ required. Installing..."
    brew install python@3.11
    export PATH="/opt/homebrew/opt/python@3.11/bin:$PATH"
fi

# Install dependencies
echo "📦 Installing dependencies..."
brew install ffmpeg

# Create installation directory
INSTALL_DIR="$HOME/Library/Application Support/yt-dlp-wizwam"
echo "📁 Installing to: $INSTALL_DIR"

if [ -d "$INSTALL_DIR" ]; then
    echo "⚠️  Previous installation found. Backing up..."
    mv "$INSTALL_DIR" "$INSTALL_DIR.backup-$(date +%Y%m%d-%H%M%S)"
fi

mkdir -p "$INSTALL_DIR"
cd "$INSTALL_DIR"

# Download source
echo "⬇️  Downloading source..."
curl -L -o yt-dlp-wizwam.zip "$PACKAGE_URL"
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
source "$HOME/Library/Application Support/yt-dlp-wizwam/venv/bin/activate"
exec python -m yt_dlp_wizwam "$@"
LAUNCHER_EOF

chmod +x "$HOME/.local/bin/downloader"
ln -sf "$HOME/.local/bin/downloader" "$HOME/.local/bin/yt-dlp-web"
ln -sf "$HOME/.local/bin/downloader" "$HOME/.local/bin/yt-dlp-cli"

# Add to PATH if needed
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    echo "" >> "$HOME/.zshrc"
    echo "# yt-dlp-wizwam" >> "$HOME/.zshrc"
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.zshrc"
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
echo '  source ~/.zshrc'
echo ""
