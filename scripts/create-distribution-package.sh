#!/bin/bash

# Create Distribution Package Script for yt-dlp-wizwam
# This script creates OS-specific distribution packages with single-file installers
# Supports: Ubuntu/Debian, Arch/Manjaro, macOS, Windows, and generic source

set -e  # Exit on error

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo "📦 Creating OS-Specific Distribution Packages for yt-dlp-wizwam"
echo "================================================================"
echo ""

# Check if we're in the right directory
if [ ! -f "setup.py" ] || [ ! -f "README.md" ] || [ ! -d "yt_dlp_wizwam" ]; then
    echo -e "${RED}❌ Error: Not in the yt-dlp-wizwam directory${NC}"
    echo "Please run this script from /home/luke/dev/yt-dlp-wizwam"
    exit 1
fi

# Get version from __init__.py using Python's ast module (most reliable)
if [ -f "yt_dlp_wizwam/__init__.py" ]; then
    VERSION=$(python3 << 'PYEOF'
import re
with open('yt_dlp_wizwam/__init__.py', 'r') as f:
    content = f.read()
    match = re.search(r"^__version__\s*=\s*['\"]([^'\"]+)['\"]", content, re.MULTILINE)
    if match:
        print(match.group(1))
PYEOF
)
    if [ -z "$VERSION" ]; then
        echo -e "${RED}❌ Error: Could not extract version from __init__.py${NC}"
        echo "Please ensure __version__ is defined in yt_dlp_wizwam/__init__.py"
        exit 1
    fi
else
    echo -e "${RED}❌ Error: Cannot find yt_dlp_wizwam/__init__.py${NC}"
    exit 1
fi

# Get repository name
REPO_NAME="yt-dlp-wizwam"
PACKAGE_NAME="${REPO_NAME}-v${VERSION}"
DIST_DIR="dist-packages"
TEMP_DIR=".packaging-temp"

echo -e "${BLUE}📋 Package Information:${NC}"
echo "  Repository: ${REPO_NAME}"
echo "  Version: ${VERSION}"
echo "  Package base name: ${PACKAGE_NAME}"
echo ""

# Create distribution directory
if [ -d "$DIST_DIR" ]; then
    echo -e "${YELLOW}⚠️  Cleaning existing distribution directory${NC}"
    rm -rf "$DIST_DIR"
fi
mkdir -p "$DIST_DIR"

# Clean up any previous temp directory
if [ -d "$TEMP_DIR" ]; then
    rm -rf "$TEMP_DIR"
fi

# Create temp directory
echo -e "${YELLOW}Step 1: Creating temporary package directory${NC}"
echo "--------------------------------------------"
mkdir -p "$TEMP_DIR/$PACKAGE_NAME"
echo -e "${GREEN}✅ Created temp directory${NC}"
echo ""

# Copy essential files
echo -e "${YELLOW}Step 2: Copying package files${NC}"
echo "-------------------------------"

# Function to copy file and report
copy_file() {
    local src="$1"
    local dest="$2"
    if [ -f "$src" ]; then
        cp "$src" "$dest"
        echo "  ✓ $src"
    elif [ -d "$src" ]; then
        cp -r "$src" "$dest"
        echo "  ✓ $src/ (directory)"
    else
        echo -e "  ${YELLOW}⚠️  $src (not found, skipping)${NC}"
    fi
}

# Core package files
echo "Copying core files:"
copy_file "setup.py" "$TEMP_DIR/$PACKAGE_NAME/"
copy_file "pyproject.toml" "$TEMP_DIR/$PACKAGE_NAME/"
copy_file "requirements.txt" "$TEMP_DIR/$PACKAGE_NAME/"
copy_file "MANIFEST.in" "$TEMP_DIR/$PACKAGE_NAME/"
copy_file "README.md" "$TEMP_DIR/$PACKAGE_NAME/"
copy_file "LICENSE" "$TEMP_DIR/$PACKAGE_NAME/"
copy_file "CHANGELOG.md" "$TEMP_DIR/$PACKAGE_NAME/"
echo ""

# Documentation files
echo "Copying documentation:"
copy_file "TODO.md" "$TEMP_DIR/$PACKAGE_NAME/"
copy_file "STATUS.md" "$TEMP_DIR/$PACKAGE_NAME/"
copy_file "CONTRIBUTING.md" "$TEMP_DIR/$PACKAGE_NAME/"
copy_file "CODE_OF_CONDUCT.md" "$TEMP_DIR/$PACKAGE_NAME/"
echo ""

# Source code
echo "Copying source code:"
copy_file "yt_dlp_wizwam" "$TEMP_DIR/$PACKAGE_NAME/"
echo ""

# GitHub templates and workflows (optional but useful)
echo "Copying GitHub metadata:"
if [ -d ".github" ]; then
    mkdir -p "$TEMP_DIR/$PACKAGE_NAME/.github"
    copy_file ".github/workflows" "$TEMP_DIR/$PACKAGE_NAME/.github/"
    copy_file ".github/ISSUE_TEMPLATE" "$TEMP_DIR/$PACKAGE_NAME/.github/"
    copy_file ".github/PULL_REQUEST_TEMPLATE.md" "$TEMP_DIR/$PACKAGE_NAME/.github/"
    copy_file ".github/CODEOWNERS" "$TEMP_DIR/$PACKAGE_NAME/.github/"
fi
echo ""

# Scripts (if they're useful for users)
echo "Copying utility scripts:"
if [ -d "scripts" ]; then
    mkdir -p "$TEMP_DIR/$PACKAGE_NAME/scripts"
    # Only copy user-facing scripts, not internal development scripts
    for script in scripts/*.sh; do
        if [[ ! "$script" =~ (sync-to-github|push-with-ssh-check|github-upload) ]]; then
            copy_file "$script" "$TEMP_DIR/$PACKAGE_NAME/scripts/"
        fi
    done
fi
echo ""

echo -e "${GREEN}✅ All files copied${NC}"
echo ""

#==============================================================================
# Create OS-Specific Single-File Installers
#==============================================================================

echo -e "${YELLOW}Step 3: Creating OS-specific installers${NC}"
echo "----------------------------------------"
echo ""

# 1. Ubuntu/Debian Installer
echo -e "${BLUE}Creating Ubuntu/Debian installer...${NC}"
cat > "$DIST_DIR/install-ubuntu-${VERSION}.sh" << 'UBUNTU_EOF'
#!/bin/bash
# yt-dlp-wizwam Ubuntu/Debian Installer
# Single-file installer for Ubuntu, Debian, Linux Mint, Pop!_OS, etc.

set -e

VERSION="__VERSION__"
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
UBUNTU_EOF

sed -i "s/__VERSION__/$VERSION/g" "$DIST_DIR/install-ubuntu-${VERSION}.sh"
chmod +x "$DIST_DIR/install-ubuntu-${VERSION}.sh"
echo "  ✅ install-ubuntu-${VERSION}.sh"

# 2. Arch/Manjaro Installer
echo -e "${BLUE}Creating Arch/Manjaro installer...${NC}"
cat > "$DIST_DIR/install-arch-${VERSION}.sh" << 'ARCH_EOF'
#!/bin/bash
# yt-dlp-wizwam Arch Linux Installer
# Single-file installer for Arch, Manjaro, EndeavourOS, etc.

set -e

VERSION="__VERSION__"
PACKAGE_URL="https://github.com/lukejmorrison/yt-dlp-wizwam/archive/refs/heads/main.zip"

echo "🚀 Installing yt-dlp-wizwam v${VERSION} for Arch Linux"
echo "======================================================"
echo ""

# Check for Python 3.10+
if ! command -v python &> /dev/null; then
    echo "❌ Python not found. Installing..."
    sudo pacman -S --noconfirm python python-pip
fi

PYTHON_VERSION=$(python -c 'import sys; print(f"{sys.version_info.major}.{sys.version_info.minor}")')
if (( $(echo "$PYTHON_VERSION < 3.10" | bc -l) )); then
    echo "❌ Python 3.10+ required. Current version: $PYTHON_VERSION"
    exit 1
fi

# Install system dependencies
echo "📦 Installing system dependencies..."
sudo pacman -S --noconfirm python-pip ffmpeg unzip wget curl

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
python -m venv venv
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
ARCH_EOF

sed -i "s/__VERSION__/$VERSION/g" "$DIST_DIR/install-arch-${VERSION}.sh"
chmod +x "$DIST_DIR/install-arch-${VERSION}.sh"
echo "  ✅ install-arch-${VERSION}.sh"

# 3. macOS Installer
echo -e "${BLUE}Creating macOS installer...${NC}"
cat > "$DIST_DIR/install-macos-${VERSION}.sh" << 'MACOS_EOF'
#!/bin/bash
# yt-dlp-wizwam macOS Installer
# Single-file installer for macOS (Intel & Apple Silicon)

set -e

VERSION="__VERSION__"
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
MACOS_EOF

sed -i "s/__VERSION__/$VERSION/g" "$DIST_DIR/install-macos-${VERSION}.sh"
chmod +x "$DIST_DIR/install-macos-${VERSION}.sh"
echo "  ✅ install-macos-${VERSION}.sh"

# 4. Windows PowerShell Installer
echo -e "${BLUE}Creating Windows installer...${NC}"
cat > "$DIST_DIR/install-windows-${VERSION}.ps1" << 'WINDOWS_EOF'
# yt-dlp-wizwam Windows Installer
# Single-file installer for Windows 10/11

$VERSION = "__VERSION__"
$PACKAGE_URL = "https://github.com/lukejmorrison/yt-dlp-wizwam/archive/refs/heads/main.zip"

Write-Host "🚀 Installing yt-dlp-wizwam v$VERSION for Windows" -ForegroundColor Cyan
Write-Host "===================================================" -ForegroundColor Cyan
Write-Host ""

# Check for Python
$pythonCmd = Get-Command python -ErrorAction SilentlyContinue
if (-not $pythonCmd) {
    Write-Host "❌ Python not found. Please install Python 3.10+ from:" -ForegroundColor Red
    Write-Host "   https://www.python.org/downloads/" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Make sure to check 'Add Python to PATH' during installation!" -ForegroundColor Yellow
    exit 1
}

$pythonVersion = & python -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')"
if ([version]$pythonVersion -lt [version]"3.10") {
    Write-Host "❌ Python 3.10+ required. Current version: $pythonVersion" -ForegroundColor Red
    Write-Host "   Download from: https://www.python.org/downloads/" -ForegroundColor Yellow
    exit 1
}

# Create installation directory
$INSTALL_DIR = "$env:LOCALAPPDATA\yt-dlp-wizwam"
Write-Host "📁 Installing to: $INSTALL_DIR" -ForegroundColor Green

if (Test-Path $INSTALL_DIR) {
    Write-Host "⚠️  Previous installation found. Backing up..." -ForegroundColor Yellow
    $backupName = "yt-dlp-wizwam.backup-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
    Rename-Item $INSTALL_DIR "$env:LOCALAPPDATA\$backupName"
}

New-Item -ItemType Directory -Force -Path $INSTALL_DIR | Out-Null
Set-Location $INSTALL_DIR

# Download source
Write-Host "⬇️  Downloading source..." -ForegroundColor Cyan
Invoke-WebRequest -Uri $PACKAGE_URL -OutFile "yt-dlp-wizwam.zip"
Expand-Archive -Path "yt-dlp-wizwam.zip" -DestinationPath "." -Force
Move-Item -Path "yt-dlp-wizwam-main\*" -Destination "." -Force
Remove-Item -Recurse -Force "yt-dlp-wizwam-main", "yt-dlp-wizwam.zip"

# Create virtual environment
Write-Host "🔧 Creating virtual environment..." -ForegroundColor Cyan
python -m venv venv
& ".\venv\Scripts\Activate.ps1"

# Install package
Write-Host "📥 Installing yt-dlp-wizwam..." -ForegroundColor Cyan
python -m pip install --upgrade pip
pip install -e .

# Create launcher scripts
Write-Host "🔗 Creating launchers..." -ForegroundColor Cyan
$launcherDir = "$env:LOCALAPPDATA\Microsoft\WindowsApps"

@"
@echo off
call "$INSTALL_DIR\venv\Scripts\activate.bat"
python -m yt_dlp_wizwam %*
"@ | Out-File -FilePath "$launcherDir\downloader.bat" -Encoding ASCII

@"
@echo off
call "$INSTALL_DIR\venv\Scripts\activate.bat"
python -m yt_dlp_wizwam %*
"@ | Out-File -FilePath "$launcherDir\yt-dlp-web.bat" -Encoding ASCII

@"
@echo off
call "$INSTALL_DIR\venv\Scripts\activate.bat"
python -m yt_dlp_wizwam download %*
"@ | Out-File -FilePath "$launcherDir\yt-dlp-cli.bat" -Encoding ASCII

Write-Host ""
Write-Host "✅ Installation complete!" -ForegroundColor Green
Write-Host ""
Write-Host "Usage:" -ForegroundColor Cyan
Write-Host "  downloader              # Start web interface"
Write-Host "  yt-dlp-cli <URL>        # Download from CLI"
Write-Host "  downloader --help       # Show help"
Write-Host ""
Write-Host "⚠️  Note: FFmpeg is recommended for video processing." -ForegroundColor Yellow
Write-Host "   Install via: winget install FFmpeg" -ForegroundColor Yellow
Write-Host ""
WINDOWS_EOF

sed -i "s/__VERSION__/$VERSION/g" "$DIST_DIR/install-windows-${VERSION}.ps1"
echo "  ✅ install-windows-${VERSION}.ps1"

echo ""
echo -e "${GREEN}✅ OS-specific installers created${NC}"
echo ""

#==============================================================================
# Create Source Distribution Package
#==============================================================================

echo -e "${YELLOW}Step 4: Creating source distribution package${NC}"
echo "----------------------------------------------"

ZIP_FILE="$DIST_DIR/${PACKAGE_NAME}-source.zip"
mkdir -p "$TEMP_DIR/$PACKAGE_NAME"
cat > "$TEMP_DIR/$PACKAGE_NAME/INSTALL.txt" << 'EOF'
# Installation Instructions for yt-dlp-wizwam

## Quick Install

```bash
pip install .
```

Or for development:

```bash
pip install -e .
```

## Requirements

- Python 3.10 or higher
- pip (Python package installer)

## Installation Steps

1. Extract this archive:
   ```bash
   unzip yt-dlp-wizwam-v*.zip
   cd yt-dlp-wizwam-v*/
   ```

2. (Optional) Create a virtual environment:
   ```bash
   python -m venv venv
   source venv/bin/activate  # On Linux/Mac
   # OR
   venv\Scripts\activate  # On Windows
   ```

3. Install the package:
   ```bash
   pip install .
   ```

4. Verify installation:
   ```bash
   downloader --version
   ```

## Usage

- Start web interface: `downloader` or `yt-dlp-web`
- CLI download: `yt-dlp-cli {URL}`
- View help: `downloader --help`

## Documentation

See README.md for full documentation and usage examples.

## Troubleshooting

If you encounter issues:
1. Ensure Python 3.10+ is installed: `python --version`
2. Update pip: `pip install --upgrade pip`
3. Check GitHub issues: https://github.com/lukejmorrison/yt-dlp-wizwam/issues

EOF
echo -e "${GREEN}✅ Created INSTALL.txt${NC}"
echo ""

# Create the zip file
echo -e "Creating source archive..."
cd "$TEMP_DIR"
zip -r "../$ZIP_FILE" "$PACKAGE_NAME" -q
cd ..
echo -e "${GREEN}✅ Created ${PACKAGE_NAME}-source.zip${NC}"
echo ""

# Clean up temp directory
rm -rf "$TEMP_DIR"

#==============================================================================
# Generate Checksums
#==============================================================================

echo -e "${YELLOW}Step 5: Generating checksums${NC}"
echo "-----------------------------"

cd "$DIST_DIR"
sha256sum * > SHA256SUMS.txt
cd ..

echo -e "${GREEN}✅ Created SHA256SUMS.txt${NC}"
echo ""

# Get file sizes
SOURCE_SIZE=$(du -h "$ZIP_FILE" | cut -f1)

#==============================================================================
# Create Download Guide
#==============================================================================

echo -e "${YELLOW}Step 6: Creating download guide${NC}"
echo "--------------------------------"

cat > "$DIST_DIR/README.md" << 'README_EOF'
# yt-dlp-wizwam Distribution Packages

## Quick Installation

### Ubuntu / Debian / Linux Mint / Pop!_OS
```bash
wget https://raw.githubusercontent.com/lukejmorrison/yt-dlp-wizwam/main/dist-packages/install-ubuntu-__VERSION__.sh
chmod +x install-ubuntu-__VERSION__.sh
./install-ubuntu-__VERSION__.sh
```

### Arch Linux / Manjaro / EndeavourOS
```bash
wget https://raw.githubusercontent.com/lukejmorrison/yt-dlp-wizwam/main/dist-packages/install-arch-__VERSION__.sh
chmod +x install-arch-__VERSION__.sh
./install-arch-__VERSION__.sh
```

### macOS (Intel & Apple Silicon)
```bash
curl -O https://raw.githubusercontent.com/lukejmorrison/yt-dlp-wizwam/main/dist-packages/install-macos-__VERSION__.sh
chmod +x install-macos-__VERSION__.sh
./install-macos-__VERSION__.sh
```

### Windows 10/11
Download and run in PowerShell (as Administrator):
```powershell
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/lukejmorrison/yt-dlp-wizwam/main/dist-packages/install-windows-__VERSION__.ps1" -OutFile "install.ps1"
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
.\install.ps1
```

### Generic Source Installation
For other Linux distributions or manual installation:
```bash
# Download source package
wget https://github.com/lukejmorrison/yt-dlp-wizwam/releases/download/v__VERSION__/yt-dlp-wizwam-v__VERSION__-source.zip
unzip yt-dlp-wizwam-v__VERSION__-source.zip
cd yt-dlp-wizwam-v__VERSION__

# Install
pip install .
```

## Files in This Distribution

| File | Description | Platform |
|------|-------------|----------|
| `install-ubuntu-__VERSION__.sh` | Single-file installer | Ubuntu, Debian, Mint, Pop!_OS |
| `install-arch-__VERSION__.sh` | Single-file installer | Arch, Manjaro, EndeavourOS |
| `install-macos-__VERSION__.sh` | Single-file installer | macOS (Intel & M1/M2/M3) |
| `install-windows-__VERSION__.ps1` | PowerShell installer | Windows 10/11 |
| `yt-dlp-wizwam-v__VERSION__-source.zip` | Source code package | All platforms |
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

**Version**: __VERSION__  
**Repository**: https://github.com/lukejmorrison/yt-dlp-wizwam
README_EOF

sed -i "s/__VERSION__/$VERSION/g" "$DIST_DIR/README.md"
echo -e "${GREEN}✅ Created README.md${NC}"
echo ""

# Success summary
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}🎉 All Distribution Packages Created Successfully!${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${BLUE}📦 Package Details:${NC}"
echo "  Version: ${VERSION}"
echo "  Output directory: ${DIST_DIR}/"
echo "  Source package size: ${SOURCE_SIZE}"
echo ""
echo -e "${BLUE}📋 Created Files:${NC}"
echo "  ✅ install-ubuntu-${VERSION}.sh      (Ubuntu/Debian/Mint/Pop!_OS)"
echo "  ✅ install-arch-${VERSION}.sh        (Arch/Manjaro/EndeavourOS)"
echo "  ✅ install-macos-${VERSION}.sh       (macOS Intel & Apple Silicon)"
echo "  ✅ install-windows-${VERSION}.ps1    (Windows 10/11)"
echo "  ✅ ${PACKAGE_NAME}-source.zip        (Source code)"
echo "  ✅ SHA256SUMS.txt                    (Checksums)"
echo "  ✅ README.md                         (Installation guide)"
echo ""
echo -e "${YELLOW}📝 Next Steps:${NC}"
echo ""
echo "1. Test installers:"
echo -e "   ${BLUE}# Ubuntu/Debian${NC}"
echo -e "   ${BLUE}./${DIST_DIR}/install-ubuntu-${VERSION}.sh${NC}"
echo ""
echo "2. Upload to GitHub:"
echo -e "   ${BLUE}# Commit distribution files${NC}"
echo -e "   ${BLUE}git add ${DIST_DIR}${NC}"
echo -e "   ${BLUE}git commit -m 'feat: Add v${VERSION} distribution packages'${NC}"
echo -e "   ${BLUE}git push${NC}"
echo ""
echo "3. Create GitHub Release:"
echo -e "   ${BLUE}https://github.com/lukejmorrison/yt-dlp-wizwam/releases/new${NC}"
echo "   - Tag: v${VERSION}"
echo "   - Title: Release v${VERSION}"
echo "   - Upload: ${PACKAGE_NAME}-source.zip"
echo "   - Copy install commands from ${DIST_DIR}/README.md"
echo ""
echo "4. Users can now install with single command:"
echo -e "   ${GREEN}# Ubuntu/Debian${NC}"
echo -e "   ${BLUE}wget https://raw.githubusercontent.com/lukejmorrison/yt-dlp-wizwam/main/${DIST_DIR}/install-ubuntu-${VERSION}.sh && chmod +x install-ubuntu-${VERSION}.sh && ./install-ubuntu-${VERSION}.sh${NC}"
echo ""
echo -e "   ${GREEN}# Arch Linux${NC}"
echo -e "   ${BLUE}wget https://raw.githubusercontent.com/lukejmorrison/yt-dlp-wizwam/main/${DIST_DIR}/install-arch-${VERSION}.sh && chmod +x install-arch-${VERSION}.sh && ./install-arch-${VERSION}.sh${NC}"
echo ""
echo -e "   ${GREEN}# macOS${NC}"
echo -e "   ${BLUE}curl -O https://raw.githubusercontent.com/lukejmorrison/yt-dlp-wizwam/main/${DIST_DIR}/install-macos-${VERSION}.sh && chmod +x install-macos-${VERSION}.sh && ./install-macos-${VERSION}.sh${NC}"
echo ""
echo "5. Verify checksums:"
echo -e "   ${BLUE}cd ${DIST_DIR} && sha256sum -c SHA256SUMS.txt${NC}"
echo ""
