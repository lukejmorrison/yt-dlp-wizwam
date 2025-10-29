# yt-dlp-wizwam Windows Installer
# Single-file installer for Windows 10/11

$VERSION = "0.0.2-alpha"
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
