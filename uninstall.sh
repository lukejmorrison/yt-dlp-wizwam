#!/bin/bash
# Uninstall script for yt-dlp-wizwam

set -e

echo "🗑️  yt-dlp-wizwam Uninstaller"
echo "============================"
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

INSTALL_DIR="$HOME/.local/share/yt-dlp-wizwam"
DESKTOP_FILE="$HOME/.local/share/applications/yt-dlp-wizwam.desktop"
ICON_FILE="$HOME/.local/share/icons/hicolor/512x512/apps/yt-dlp-wizwam.png"
BIN_FILE="$HOME/.local/bin/yt-dlp-wizwam"
CONFIG_DIR="$HOME/.yt-dlp-wizwam"

echo -e "${YELLOW}This will remove:${NC}"
echo -e "  • Application files: $INSTALL_DIR"
echo -e "  • Desktop entry: $DESKTOP_FILE"
echo -e "  • Icon: $ICON_FILE"
echo -e "  • Launcher: $BIN_FILE"
echo ""
echo -e "${BLUE}Configuration and downloads will be preserved:${NC}"
echo -e "  • Config: $CONFIG_DIR"
echo -e "  • Downloads: ~/Downloads/yt-dlp-wizwam"
echo ""
read -p "Continue? (y/N) " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Uninstall cancelled."
    exit 0
fi

echo ""
echo -e "${BLUE}Removing application files...${NC}"

if [ -d "$INSTALL_DIR" ]; then
    rm -rf "$INSTALL_DIR"
    echo -e "${GREEN}✓${NC} Removed $INSTALL_DIR"
fi

if [ -f "$DESKTOP_FILE" ]; then
    rm -f "$DESKTOP_FILE"
    echo -e "${GREEN}✓${NC} Removed desktop entry"
fi

if [ -f "$ICON_FILE" ]; then
    rm -f "$ICON_FILE"
    echo -e "${GREEN}✓${NC} Removed icon"
fi

if [ -f "$BIN_FILE" ]; then
    rm -f "$BIN_FILE"
    echo -e "${GREEN}✓${NC} Removed launcher"
fi

echo ""
echo -e "${BLUE}Updating desktop database...${NC}"
if command -v update-desktop-database &> /dev/null; then
    update-desktop-database "$HOME/.local/share/applications" 2>/dev/null
    echo -e "${GREEN}✓${NC} Desktop database updated"
fi

if command -v gtk-update-icon-cache &> /dev/null; then
    gtk-update-icon-cache -f -t "$HOME/.local/share/icons/hicolor" 2>/dev/null
    echo -e "${GREEN}✓${NC} Icon cache updated"
fi

echo ""
echo -e "${GREEN}Uninstall complete!${NC}"
echo ""
echo -e "${YELLOW}To remove configuration and downloads:${NC}"
echo -e "  rm -rf $CONFIG_DIR"
echo -e "  rm -rf ~/Downloads/yt-dlp-wizwam"
echo ""
