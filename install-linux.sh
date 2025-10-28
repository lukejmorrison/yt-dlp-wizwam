#!/bin/bash
#
# yt-dlp-wizwam Installation Script for Linux
# 
# This script installs yt-dlp-wizwam and its dependencies on Linux systems.
#

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Script version
VERSION="1.0.0"

# Functions
print_header() {
    echo -e "${CYAN}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                                                              ║"
    echo "║                    yt-dlp-wizwam Installer                   ║"
    echo "║                                                              ║"
    echo "║              Advanced YouTube Downloader v${VERSION}              ║"
    echo "║                                                              ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

print_help() {
    cat << EOF
${CYAN}Usage:${NC}
  ./install-linux.sh [OPTIONS]

${CYAN}Options:${NC}
  -h, --help              Show this help message
  -v, --version           Show version information
  --system                Install system-wide (requires sudo)
  --user                  Install for current user only (default)
  --venv PATH             Install in virtual environment at PATH
  --dev                   Install with development dependencies
  --skip-deps             Skip dependency installation
  --uninstall             Uninstall yt-dlp-wizwam

${CYAN}Installation Modes:${NC}

  ${GREEN}1. User Installation (Recommended):${NC}
     ./install-linux.sh
     - Installs to ~/.local/bin
     - No sudo required
     - Automatically added to PATH on most systems

  ${GREEN}2. Virtual Environment:${NC}
     ./install-linux.sh --venv ~/venvs/yt-dlp-wizwam
     - Isolated Python environment
     - Recommended for development

  ${GREEN}3. System-Wide Installation:${NC}
     ./install-linux.sh --system
     - Requires sudo
     - Available to all users
     - Installs to /usr/local/bin

${CYAN}After Installation:${NC}

  ${GREEN}Run the web interface:${NC}
    downloader
    # OR
    yt-dlp-web

  ${GREEN}Download a video via CLI:${NC}
    downloader download https://youtube.com/watch?v=dQw4w9WgXcQ
    # OR
    yt-dlp-cli https://youtube.com/watch?v=dQw4w9WgXcQ

  ${GREEN}Start web interface with custom options:${NC}
    downloader web --port 8080 --open-browser

  ${GREEN}Show help:${NC}
    downloader --help
    downloader download --help
    downloader web --help

${CYAN}Requirements:${NC}
  - Python 3.10 or higher
  - pip (Python package installer)
  - ffmpeg (automatically bundled via imageio-ffmpeg)

${CYAN}Examples:${NC}

  # Install for current user (recommended)
  ./install-linux.sh

  # Install for development
  ./install-linux.sh --dev

  # Install in custom virtual environment
  ./install-linux.sh --venv ~/.venvs/ytdlp

  # Install system-wide
  sudo ./install-linux.sh --system

  # Uninstall
  ./install-linux.sh --uninstall

${CYAN}Supported Distributions:${NC}
  - Ubuntu / Debian
  - Fedora / RHEL / CentOS
  - Arch Linux
  - Linux Mint
  - Pop!_OS
  - Most other Linux distributions with Python 3.10+

${CYAN}For more information:${NC}
  GitHub: https://github.com/lukejmorrison/yt-dlp-wizwam
  Issues: https://github.com/lukejmorrison/yt-dlp-wizwam/issues

EOF
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

check_python() {
    print_info "Checking Python version..."
    
    if ! command -v python3 &> /dev/null; then
        print_error "Python 3 is not installed"
        echo ""
        echo "Please install Python 3.10 or higher:"
        echo "  Ubuntu/Debian: sudo apt install python3 python3-pip python3-venv"
        echo "  Fedora/RHEL:   sudo dnf install python3 python3-pip"
        echo "  Arch Linux:    sudo pacman -S python python-pip"
        exit 1
    fi
    
    PYTHON_VERSION=$(python3 --version | cut -d' ' -f2)
    PYTHON_MAJOR=$(echo $PYTHON_VERSION | cut -d'.' -f1)
    PYTHON_MINOR=$(echo $PYTHON_VERSION | cut -d'.' -f2)
    
    if [ "$PYTHON_MAJOR" -lt 3 ] || ([ "$PYTHON_MAJOR" -eq 3 ] && [ "$PYTHON_MINOR" -lt 10 ]); then
        print_error "Python 3.10+ required (found $PYTHON_VERSION)"
        echo ""
        echo "Please upgrade Python:"
        echo "  Ubuntu 22.04+: sudo apt install python3.10"
        echo "  Fedora 35+:    sudo dnf install python3.10"
        exit 1
    fi
    
    print_success "Python $PYTHON_VERSION found"
}

check_pip() {
    print_info "Checking pip..."
    
    if ! python3 -m pip --version &> /dev/null; then
        print_error "pip is not installed"
        echo ""
        echo "Please install pip:"
        echo "  Ubuntu/Debian: sudo apt install python3-pip"
        echo "  Fedora/RHEL:   sudo dnf install python3-pip"
        echo "  Arch Linux:    sudo pacman -S python-pip"
        exit 1
    fi
    
    print_success "pip found"
}

install_user() {
    print_info "Installing yt-dlp-wizwam for current user..."
    
    if [ "$INSTALL_DEV" = true ]; then
        python3 -m pip install --user -e ".[dev]"
    else
        python3 -m pip install --user .
    fi
    
    print_success "Installation complete!"
    
    # Check if ~/.local/bin is in PATH
    if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
        print_warning "~/.local/bin is not in your PATH"
        echo ""
        echo "Add this to your ~/.bashrc or ~/.zshrc:"
        echo "  export PATH=\"\$HOME/.local/bin:\$PATH\""
        echo ""
        echo "Then run: source ~/.bashrc  # or source ~/.zshrc"
    fi
    
    echo ""
    print_info "Installation location: ~/.local/bin/downloader"
}

install_venv() {
    VENV_PATH="$1"
    
    print_info "Creating virtual environment at $VENV_PATH..."
    python3 -m venv "$VENV_PATH"
    
    print_info "Installing yt-dlp-wizwam in virtual environment..."
    
    if [ "$INSTALL_DEV" = true ]; then
        "$VENV_PATH/bin/pip" install -e ".[dev]"
    else
        "$VENV_PATH/bin/pip" install .
    fi
    
    print_success "Installation complete!"
    
    echo ""
    print_info "To use yt-dlp-wizwam, activate the virtual environment:"
    echo "  source $VENV_PATH/bin/activate"
    echo ""
    print_info "Then run:"
    echo "  downloader"
    echo ""
    print_info "To deactivate when done:"
    echo "  deactivate"
}

install_system() {
    if [ "$EUID" -ne 0 ]; then
        print_error "System installation requires sudo/root privileges"
        echo "Run: sudo ./install-linux.sh --system"
        exit 1
    fi
    
    print_info "Installing yt-dlp-wizwam system-wide..."
    
    if [ "$INSTALL_DEV" = true ]; then
        python3 -m pip install -e ".[dev]"
    else
        python3 -m pip install .
    fi
    
    print_success "Installation complete!"
    
    echo ""
    print_info "Installation location: /usr/local/bin/downloader"
}

uninstall() {
    print_info "Uninstalling yt-dlp-wizwam..."
    
    if [ "$INSTALL_MODE" = "system" ]; then
        if [ "$EUID" -ne 0 ]; then
            print_error "System uninstallation requires sudo"
            echo "Run: sudo ./install-linux.sh --uninstall --system"
            exit 1
        fi
        python3 -m pip uninstall -y yt-dlp-wizwam
    elif [ -n "$VENV_PATH" ]; then
        if [ -f "$VENV_PATH/bin/pip" ]; then
            "$VENV_PATH/bin/pip" uninstall -y yt-dlp-wizwam
            print_success "Uninstalled from virtual environment"
        else
            print_error "Virtual environment not found at $VENV_PATH"
            exit 1
        fi
    else
        python3 -m pip uninstall -y yt-dlp-wizwam
    fi
    
    print_success "yt-dlp-wizwam has been uninstalled"
}

show_usage_info() {
    echo ""
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}  Installation successful! 🎉${NC}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${CYAN}Quick Start:${NC}"
    echo ""
    echo -e "  ${GREEN}1. Start web interface:${NC}"
    echo "     downloader"
    echo "     # Opens browser at http://localhost:42070"
    echo ""
    echo -e "  ${GREEN}2. Download a video:${NC}"
    echo "     downloader download https://youtube.com/watch?v=dQw4w9WgXcQ"
    echo ""
    echo -e "  ${GREEN}3. Get help:${NC}"
    echo "     downloader --help"
    echo ""
    echo -e "${CYAN}Available Commands:${NC}"
    echo "  downloader              - Start web interface (default)"
    echo "  downloader download     - Download via CLI"
    echo "  downloader web          - Start web interface"
    echo "  yt-dlp-web              - Alias for web interface"
    echo "  yt-dlp-cli              - Alias for CLI downloads"
    echo ""
    echo -e "${CYAN}Downloads saved to:${NC} ~/Downloads/yt-dlp-wizwam/"
    echo ""
    echo -e "${CYAN}Need help?${NC} https://github.com/lukejmorrison/yt-dlp-wizwam/wiki"
    echo ""
}

# Main script
main() {
    # Default options
    INSTALL_MODE="user"
    INSTALL_DEV=false
    SKIP_DEPS=false
    DO_UNINSTALL=false
    VENV_PATH=""
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                print_help
                exit 0
                ;;
            -v|--version)
                echo "yt-dlp-wizwam installer v$VERSION"
                exit 0
                ;;
            --system)
                INSTALL_MODE="system"
                shift
                ;;
            --user)
                INSTALL_MODE="user"
                shift
                ;;
            --venv)
                INSTALL_MODE="venv"
                VENV_PATH="$2"
                shift 2
                ;;
            --dev)
                INSTALL_DEV=true
                shift
                ;;
            --skip-deps)
                SKIP_DEPS=true
                shift
                ;;
            --uninstall)
                DO_UNINSTALL=true
                shift
                ;;
            *)
                print_error "Unknown option: $1"
                echo "Run './install-linux.sh --help' for usage"
                exit 1
                ;;
        esac
    done
    
    # Show header
    print_header
    
    # Handle uninstall
    if [ "$DO_UNINSTALL" = true ]; then
        uninstall
        exit 0
    fi
    
    # Check requirements
    if [ "$SKIP_DEPS" = false ]; then
        check_python
        check_pip
    fi
    
    # Perform installation
    echo ""
    case $INSTALL_MODE in
        user)
            install_user
            ;;
        venv)
            if [ -z "$VENV_PATH" ]; then
                print_error "Virtual environment path required with --venv"
                echo "Example: ./install-linux.sh --venv ~/venvs/yt-dlp-wizwam"
                exit 1
            fi
            install_venv "$VENV_PATH"
            ;;
        system)
            install_system
            ;;
    esac
    
    # Show usage information
    if [ "$INSTALL_MODE" != "venv" ]; then
        show_usage_info
    fi
}

# Run main function
main "$@"
