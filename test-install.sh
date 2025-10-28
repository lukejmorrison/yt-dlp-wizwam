#!/bin/bash

# Test script for verifying yt-dlp-wizwam installation
# Run after installing with ./install-linux.sh or manual setup

set -e  # Exit on error

VENV_PATH=".venv"
BIN_PATH="$VENV_PATH/bin"

echo "=================================="
echo "yt-dlp-wizwam Installation Test"
echo "=================================="
echo ""

# Check if venv exists
if [ ! -d "$VENV_PATH" ]; then
    echo "❌ Virtual environment not found at $VENV_PATH"
    echo "   Please run: ./install-linux.sh --venv .venv"
    exit 1
fi

echo "✅ Virtual environment found"
echo ""

# Test 1: Version check
echo "Test 1: Version Check"
echo "---------------------"
if [ -f "$BIN_PATH/downloader" ]; then
    echo "$ downloader --version"
    $BIN_PATH/downloader --version
    echo "✅ Main entry point working"
else
    echo "❌ downloader binary not found"
    exit 1
fi
echo ""

# Test 2: Help command
echo "Test 2: Help Command"
echo "--------------------"
echo "$ downloader --help"
$BIN_PATH/downloader --help | head -20
echo "..."
echo "✅ Help output working"
echo ""

# Test 3: Entry point aliases
echo "Test 3: Entry Point Aliases"
echo "---------------------------"
if [ -f "$BIN_PATH/yt-dlp-web" ]; then
    echo "$ yt-dlp-web --help"
    $BIN_PATH/yt-dlp-web --help | head -5
    echo "..."
    echo "✅ yt-dlp-web alias working"
else
    echo "❌ yt-dlp-web binary not found"
    exit 1
fi
echo ""

if [ -f "$BIN_PATH/yt-dlp-cli" ]; then
    echo "$ yt-dlp-cli --help"
    $BIN_PATH/yt-dlp-cli --help 2>&1 | head -5
    echo "✅ yt-dlp-cli alias working"
else
    echo "❌ yt-dlp-cli binary not found"
    exit 1
fi
echo ""

# Test 4: Import test
echo "Test 4: Python Import Test"
echo "--------------------------"
echo "$ python -c 'from yt_dlp_wizwam import __version__; print(__version__)'"
VERSION=$($BIN_PATH/python -c 'from yt_dlp_wizwam import __version__; print(__version__)')
echo "$VERSION"
echo "✅ Package imports successfully"
echo ""

# Test 5: Config test
echo "Test 5: Configuration Test"
echo "--------------------------"
echo "$ python -c 'from yt_dlp_wizwam.config import Config; print(Config.VERSION)'"
CONFIG_VERSION=$($BIN_PATH/python -c 'from yt_dlp_wizwam.config import Config; print(Config.VERSION)')
echo "$CONFIG_VERSION"
echo "✅ Configuration loaded"
echo ""

# Test 6: Web module test
echo "Test 6: Web Module Test"
echo "------------------------"
echo "$ python -c 'from yt_dlp_wizwam.web import create_app'"
$BIN_PATH/python -c 'from yt_dlp_wizwam.web import create_app; app = create_app(); print(f"Flask app created: {app.name}")'
echo "✅ Web module imports"
echo ""

# Summary
echo "=================================="
echo "✅ All installation tests passed!"
echo "=================================="
echo ""
echo "Next steps:"
echo "  1. Test CLI download:"
echo "     $BIN_PATH/downloader download https://www.youtube.com/watch?v=BaW_jenozKc"
echo ""
echo "  2. Test web interface:"
echo "     $BIN_PATH/downloader web --open-browser"
echo ""
echo "  3. Run full test suite:"
echo "     See TESTING.md for comprehensive test scenarios"
echo ""
