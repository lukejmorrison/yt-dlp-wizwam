#!/bin/bash
# Install script for yt-dlp-wizwam
# Installs as a desktop application in PopOS COSMIC with Wizwam hat icon

set -e  # Exit on error

echo "🎩 yt-dlp-wizwam Installer"
echo "=========================="
echo ""

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_DIR="$SCRIPT_DIR"

# Installation paths
INSTALL_DIR="$HOME/.local/share/yt-dlp-wizwam"
DESKTOP_FILE="$HOME/.local/share/applications/yt-dlp-wizwam.desktop"
ICON_DIR="$HOME/.local/share/icons/hicolor/512x512/apps"
ICON_FILE="$ICON_DIR/yt-dlp-wizwam.png"
BIN_DIR="$HOME/.local/bin"
BIN_FILE="$BIN_DIR/yt-dlp-wizwam"

# Source icon path
SOURCE_ICON="/home/luke/Pictures/wizwam/wizwam-hat-logo1-495x400.png"

echo -e "${BLUE}Step 1:${NC} Checking Python installation..."
if ! command -v python3 &> /dev/null; then
    echo -e "${RED}Error: Python 3 is not installed${NC}"
    exit 1
fi
PYTHON_VERSION=$(python3 --version | cut -d' ' -f2)
echo -e "${GREEN}✓${NC} Python $PYTHON_VERSION found"

echo ""
echo -e "${BLUE}Step 2:${NC} Creating installation directory..."
mkdir -p "$INSTALL_DIR"
mkdir -p "$BIN_DIR"
echo -e "${GREEN}✓${NC} Directory created: $INSTALL_DIR"

echo ""
echo -e "${BLUE}Step 3:${NC} Creating virtual environment..."
if [ -d "$INSTALL_DIR/venv" ]; then
    echo -e "${YELLOW}!${NC} Removing existing virtual environment..."
    rm -rf "$INSTALL_DIR/venv"
fi
python3 -m venv "$INSTALL_DIR/venv"
echo -e "${GREEN}✓${NC} Virtual environment created"

echo ""
echo -e "${BLUE}Step 4:${NC} Installing package..."
source "$INSTALL_DIR/venv/bin/activate"
pip install --upgrade pip > /dev/null 2>&1

# Copy project files to install directory
echo -e "${YELLOW}→${NC} Copying project files..."
cp -r "$PROJECT_DIR/yt_dlp_wizwam" "$INSTALL_DIR/"
cp "$PROJECT_DIR/setup.py" "$INSTALL_DIR/"
cp "$PROJECT_DIR/requirements.txt" "$INSTALL_DIR/"
cp "$PROJECT_DIR/README.md" "$INSTALL_DIR/"
cp "$PROJECT_DIR/LICENSE" "$INSTALL_DIR/"

# Install dependencies
cd "$INSTALL_DIR"
pip install -e . > /dev/null 2>&1
echo -e "${GREEN}✓${NC} Package installed"

echo ""
echo -e "${BLUE}Step 5:${NC} Installing icon..."
mkdir -p "$ICON_DIR"

if [ -f "$SOURCE_ICON" ]; then
    cp "$SOURCE_ICON" "$ICON_FILE"
    echo -e "${GREEN}✓${NC} Icon installed from $SOURCE_ICON"
else
    echo -e "${YELLOW}!${NC} Warning: Icon not found at $SOURCE_ICON"
    echo -e "${YELLOW}→${NC} Creating placeholder icon..."
    # Create a simple placeholder icon if source not found
    convert -size 512x512 xc:blue -pointsize 200 -fill orange -gravity center -annotate +0+0 "🎩" "$ICON_FILE" 2>/dev/null || {
        echo -e "${YELLOW}!${NC} ImageMagick not installed, skipping icon creation"
    }
fi

echo ""
echo -e "${BLUE}Step 6:${NC} Creating desktop entry..."

cat > "$DESKTOP_FILE" << 'EOF'
[Desktop Entry]
Version=1.0
Type=Application
Name=yt-dlp Wizwam
GenericName=Video Downloader
Comment=Download videos from 1800+ websites with yt-dlp
Icon=yt-dlp-wizwam
Exec=/home/luke/.local/bin/yt-dlp-wizwam
Terminal=false
Categories=Utility;AudioVideo;Video;Network;
Keywords=download;youtube;video;yt-dlp;
StartupNotify=true
EOF

# Make desktop file executable
chmod +x "$DESKTOP_FILE"
echo -e "${GREEN}✓${NC} Desktop entry created"

echo ""
echo -e "${BLUE}Step 7:${NC} Creating launcher script..."

cat > "$BIN_FILE" << 'EOF'
#!/bin/bash
# yt-dlp-wizwam launcher script with single-instance check

LOCKFILE="$HOME/.yt-dlp-wizwam/app.lock"
LOGFILE="$HOME/.yt-dlp-wizwam/launcher.log"

# Create config directory if needed
mkdir -p "$HOME/.yt-dlp-wizwam"

# Function to check if process is still running
is_running() {
    if [ -f "$LOCKFILE" ]; then
        PID=$(cat "$LOCKFILE" 2>/dev/null)
        if [ -n "$PID" ] && kill -0 "$PID" 2>/dev/null; then
            return 0  # Process is running
        else
            # Stale lockfile, remove it
            rm -f "$LOCKFILE"
            return 1  # Process not running
        fi
    fi
    return 1  # No lockfile
}

# Check if already running
if is_running; then
    PID=$(cat "$LOCKFILE")
    echo "yt-dlp-wizwam is already running (PID: $PID)"
    echo "Opening existing instance in browser..."
    
    # Find which port it's running on by checking the process
    PORT=$(lsof -Pan -p "$PID" -i TCP -sTCP:LISTEN 2>/dev/null | grep -oP ':\K\d+' | head -1)
    
    if [ -n "$PORT" ]; then
        xdg-open "http://localhost:$PORT" 2>/dev/null &
    else
        # Default to 8080/8081
        xdg-open "http://localhost:8080" 2>/dev/null || xdg-open "http://localhost:8081" 2>/dev/null &
    fi
    exit 0
fi

# Log startup
echo "$(date): Starting yt-dlp-wizwam..." >> "$LOGFILE"

# Activate virtual environment
source "INSTALL_DIR_PLACEHOLDER/venv/bin/activate"

# Change to install directory
cd "INSTALL_DIR_PLACEHOLDER"

# Write PID to lockfile
echo $$ > "$LOCKFILE"

# Cleanup function
cleanup() {
    echo "$(date): Shutting down..." >> "$LOGFILE"
    rm -f "$LOCKFILE"
    exit 0
}

# Trap signals for cleanup
trap cleanup EXIT INT TERM

# Run the application
python3 -m yt_dlp_wizwam web --open-browser 2>&1 | tee -a "$LOGFILE"

# Keep terminal open on error
if [ ${PIPESTATUS[0]} -ne 0 ]; then
    echo ""
    echo "Error occurred. Check log: $LOGFILE"
    echo "Press Enter to close..."
    read
fi
EOF

# Replace placeholder with actual install directory
sed -i "s|INSTALL_DIR_PLACEHOLDER|$INSTALL_DIR|g" "$BIN_FILE"

chmod +x "$BIN_FILE"
echo -e "${GREEN}✓${NC} Launcher script created with single-instance check"

echo ""
echo -e "${BLUE}Step 8:${NC} Updating desktop database..."
if command -v update-desktop-database &> /dev/null; then
    update-desktop-database "$HOME/.local/share/applications" 2>/dev/null
    echo -e "${GREEN}✓${NC} Desktop database updated"
fi

if command -v gtk-update-icon-cache &> /dev/null; then
    gtk-update-icon-cache -f -t "$HOME/.local/share/icons/hicolor" 2>/dev/null
    echo -e "${GREEN}✓${NC} Icon cache updated"
fi

echo ""
echo -e "${GREEN}╔════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║   Installation Complete! 🎉                ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BLUE}Application installed to:${NC}"
echo -e "  📁 $INSTALL_DIR"
echo ""
echo -e "${BLUE}You can now:${NC}"
echo -e "  1. Find 'yt-dlp Wizwam' in your application menu (Utilities)"
echo -e "  2. Run from terminal: ${YELLOW}yt-dlp-wizwam${NC}"
echo -e "  3. Run directly: ${YELLOW}$BIN_FILE${NC}"
echo ""
echo -e "${BLUE}Configuration:${NC}"
echo -e "  📝 Config file: ~/.yt-dlp-wizwam/config.json"
echo -e "  📁 Default downloads: ~/Downloads/yt-dlp-wizwam"
echo ""
echo -e "${YELLOW}Note:${NC} You may need to log out and back in for the app to appear in COSMIC"
echo ""
