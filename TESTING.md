# Testing Guide for yt-dlp-wizwam

## Phase 2 & 3 Testing - Web Interface and CLI

### Prerequisites

**Option 1: Use Installation Script (Recommended)**

```bash
cd /home/luke/dev/yt-dlp-wizwam

# Install for current user
./install-linux.sh

# OR install in virtual environment
./install-linux.sh --venv .venv

# OR install with development dependencies
./install-linux.sh --dev

# Show all options
./install-linux.sh --help
```

**Option 2: Manual Setup**

1. **Set up virtual environment:**
   ```bash
   cd /home/luke/dev/yt-dlp-wizwam
   python3 -m venv .venv
   source .venv/bin/activate  # On Linux/Mac
   ```

2. **Install package in editable mode:**
   ```bash
   pip install -e .
   ```

3. **Verify installation:**
   ```bash
   which downloader  # Should show .venv/bin/downloader or ~/.local/bin/downloader
   downloader --version  # Should show: yt-dlp-wizwam version 1.0.0
   ```

---

## CLI Testing (Phase 3)

### Test 1: Version and Help
```bash
# Test version flag
downloader --version

# Test help
downloader --help
downloader download --help
downloader web --help
```

**Expected:** Should display version and help text without errors.

### Test 2: Entry Point Aliases
```bash
# Test yt-dlp-web alias
yt-dlp-web --help

# Test yt-dlp-cli alias
yt-dlp-cli --help
```

**Expected:** Both commands should work and show appropriate help text.

### Test 3: CLI Download (Short Test Video)
```bash
# Download a short test video (Rick Astley - Never Gonna Give You Up, ~3.5 min)
downloader download https://www.youtube.com/watch?v=dQw4w9WgXcQ

# With custom options
downloader download https://www.youtube.com/watch?v=dQw4w9WgXcQ \
  --quality 480p \
  --video-codec avc1 \
  --audio-codec m4a \
  --verbose
```

**Expected:**
- Should display progress updates in terminal
- Should download to `~/Downloads/yt-dlp-wizwam/`
- Filename format: `YYYYMMDD_Never_Gonna_Give_You_Up_480p_avc1_m4a__youtube_dQw4w9WgXcQ.mp4`

### Test 4: Audio-Only Download
```bash
downloader download https://www.youtube.com/watch?v=dQw4w9WgXcQ \
  --audio-only \
  --audio-codec opus
```

**Expected:**
- Should download audio only
- File extension should be `.opus` or `.m4a`

### Test 5: Custom Output Directory
```bash
downloader download https://www.youtube.com/watch?v=dQw4w9WgXcQ \
  --output-dir ~/Videos/test
```

**Expected:**
- Should create `~/Videos/test/` directory
- Should download file to that directory

---

## Web Interface Testing (Phase 2)

### Test 6: Start Web Server
```bash
# Default settings (localhost:42070)
downloader web

# OR with auto-open browser
downloader web --open-browser

# OR custom port
downloader web --port 8080
```

**Expected:**
- Server should start without errors
- Should display: `Server: http://127.0.0.1:42070`
- Should be accessible in browser

### Test 7: Web UI - Main Page
1. Open browser to `http://localhost:42070`
2. Verify Matrix theme (green text on black background)
3. Verify navigation (Download, About, Settings)
4. Verify download form with all options

**Expected:**
- Page loads with Matrix theme
- All form elements visible and functional
- No JavaScript errors in console

### Test 8: Web UI - About Page
1. Navigate to `http://localhost:42070/about`
2. Verify version number displays correctly
3. Verify download directory shows correct path

**Expected:**
- About page loads with features list
- Version matches `1.0.0`
- Download directory fetched from `/api/config`

### Test 9: Web UI - Settings Page
1. Navigate to `http://localhost:42070/settings`
2. Verify configuration displays correctly
3. Change default settings and save
4. Reload page and verify settings persisted

**Expected:**
- Settings page loads
- LocalStorage saves settings
- Settings persist across page reloads

### Test 10: API Endpoints
```bash
# Test config endpoint
curl http://localhost:42070/api/config

# Expected JSON:
# {
#   "version": "1.0.0",
#   "download_dir": "/home/luke/Downloads/yt-dlp-wizwam",
#   "deployment_mode": "embedded",
#   ...
# }

# Test files endpoint (should be empty initially)
curl http://localhost:42070/api/files

# Expected: {"files": []}
```

### Test 11: Web UI - Download Video
1. Open `http://localhost:42070` in browser
2. Open browser console (F12) to see Socket.IO events
3. Paste URL: `https://www.youtube.com/watch?v=dQw4w9WgXcQ`
4. Select quality: `480p` (for faster testing)
5. Click "Download"

**Expected:**
- Progress bar appears
- Progress updates in real-time
- Console shows Socket.IO events: `progress`, `success`
- On completion, success message appears
- File appears in "Downloaded Files" section

### Test 12: Socket.IO Real-Time Updates
1. Start download from web UI
2. Watch browser console for Socket.IO events

**Expected Socket.IO events:**
```javascript
// Connection
{ event: 'connect' }
{ event: 'connected', data: { version: '1.0.0' } }

// During download
{ event: 'progress', data: { 
  job_id: '...', 
  phase: 'downloading', 
  percent: 45.3, 
  message: 'Speed: 2.5MB/s, ETA: 00:15' 
}}

// On completion
{ event: 'success', data: { 
  job_id: '...', 
  filename: '...', 
  filesize: '...' 
}}
```

### Test 13: File Management
1. Download a video via web UI
2. Verify file appears in "Downloaded Files"
3. Click "Refresh" to reload file list
4. Click "Download" to download file to browser
5. Click "Delete" to remove file

**Expected:**
- Files list updates automatically on download completion
- Refresh button reloads list
- Download button triggers file download
- Delete button removes file with confirmation

### Test 14: Error Handling
```bash
# Test invalid URL
curl -X POST http://localhost:42070/api/download \
  -H "Content-Type: application/json" \
  -d '{"url": "not-a-url"}'

# Test missing URL
curl -X POST http://localhost:42070/api/download \
  -H "Content-Type: application/json" \
  -d '{}'
```

**Expected:**
- Invalid URL should show error in Socket.IO event
- Missing URL should return 400 error

---

## Test Results Checklist

### CLI (Phase 3)
- [ ] `downloader --version` works
- [ ] `downloader --help` works
- [ ] `yt-dlp-web` alias works
- [ ] `yt-dlp-cli` alias works
- [ ] CLI download works with default options
- [ ] CLI download works with custom quality/codec
- [ ] Audio-only download works
- [ ] Custom output directory works
- [ ] Progress updates display in terminal
- [ ] Error handling works (invalid URL, network error)

### Web Interface (Phase 2)
- [ ] Web server starts without errors
- [ ] Main page loads with Matrix theme
- [ ] About page loads with correct version
- [ ] Settings page loads and persists settings
- [ ] `/api/config` returns correct configuration
- [ ] `/api/files` returns file list
- [ ] Download form submits successfully
- [ ] Socket.IO connection established
- [ ] Real-time progress updates work
- [ ] Success notification appears on completion
- [ ] Downloaded files appear in list
- [ ] File download from browser works
- [ ] File delete works
- [ ] Error handling shows appropriate messages
- [ ] Responsive design works on mobile

---

## Known Issues / TODO

### Phase 2 Remaining:
- [ ] File verification (FileIntegrityManager) - not critical for desktop use, can be deferred
- [ ] Multiple concurrent downloads - works but not optimized
- [ ] Tailwind CSS integration - using custom CSS instead, can add later

### Next Steps After Testing:
1. Fix any bugs found during testing
2. Add unit tests (Phase 7)
3. Update TODO.md with test results
4. Prepare for PyPI publishing (Phase 9)

---

## Troubleshooting

### Port Already in Use (Error: [Errno 98] Address already in use)

**Problem:** The default port 8080 (or custom port) is already in use.

**Common Cause:** The old Docker project at `https://yt-dlp.wizwam.com/` is running on port 42070.

**Solutions:**

**Option 1: Use the new default port (recommended)**
```bash
# The package now uses port 8080 by default
downloader web --open-browser
# Opens http://localhost:8080
```

**Option 2: Stop the Docker deployment**
```bash
cd /home/luke/dev/yt-dlp.wizwam.com
docker-compose down
```

**Option 3: Use a different port**
```bash
downloader web --port 5000 --open-browser
```

**Option 4: Find and kill the process**
```bash
# Check which process is using the port
lsof -i :8080

# Kill the process
kill -9 <PID>
```

### Server Won't Start
```bash
# Check if virtual environment is activated
which python  # Should show .venv/bin/python

# Reinstall package
pip install -e . --force-reinstall
```

### Import Errors
```bash
# Reinstall in editable mode
pip install -e . --force-reinstall

# Or reinstall dependencies
pip install -r requirements.txt
```

### Download Fails
```bash
# Check yt-dlp is installed
python -c "import yt_dlp; print(yt_dlp.version.__version__)"

# Check download directory is writable
ls -la ~/Downloads/yt-dlp-wizwam/

# Run with verbose flag
downloader download {URL} --verbose
```

### Socket.IO Not Connecting
1. Check browser console for connection errors
2. Verify server is running on correct port
3. Check CORS settings in `config.py`
4. Try different browser

---

## Test Videos

**Short Videos (for quick testing):**
- Rick Astley - Never Gonna Give You Up: `https://www.youtube.com/watch?v=dQw4w9WgXcQ` (3:33)
- Big Buck Bunny (Open Source): `https://www.youtube.com/watch?v=aqz-KE-bpKQ` (10:34)

**Various Platforms:**
- Vimeo: `https://vimeo.com/148751763`
- Twitter/X: Find any video tweet
- Instagram: Find any video post

**Different Qualities:**
- 4K video: Search YouTube for "4K test video"
- Low quality: Use `--quality 360p` flag
