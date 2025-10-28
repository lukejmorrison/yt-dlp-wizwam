# Search and Sort Feature Testing Guide

## What Was Implemented

### 1. UI Components (templates/index.html)
- **Search Bar**: Text input with placeholder "Search files..."
- **Sort Dropdown**: Select with 6 sorting options:
  - Newest First (default)
  - Oldest First
  - Name (A-Z)
  - Name (Z-A)
  - Size (Largest First)
  - Size (Smallest First)
- **File Count Display**: Shows "X files" or "Showing X of Y files" when filtering

### 2. Client-Side Logic (static/js/app.js)

#### State Variables
```javascript
let allFiles = [];           // Stores all files from API
let currentSort = 'newest';  // Tracks current sort option
```

#### Core Functions

**loadFiles()**: 
- Fetches files from `/api/files`
- Stores all files in `allFiles` array
- Calls `filterAndSortFiles()` to display

**filterAndSortFiles()**:
- Filters files by search term (case-insensitive, matches filename)
- Sorts files by selected criteria
- Updates file count display
- Renders filtered/sorted file list
- Shows "No files match your search" when filter returns empty

**Event Listeners**:
- `searchFilesInput.addEventListener('input', filterAndSortFiles)` - Real-time search
- `sortFilesSelect.addEventListener('change', filterAndSortFiles)` - Sort on change

### 3. Styling (static/css/styles.css)

**New CSS Classes**:
- `.files-header` - Container for title, count, and controls
- `.files-controls` - Flex container for search and sort
- `.search-container` / `.sort-container` - Individual control wrappers
- `#search-files` - Styled input with Matrix theme
- `#sort-files` - Styled dropdown with Matrix theme
- `#file-count` - Dimmed text for count display

**Matrix Theme Integration**:
- Green borders (`var(--matrix-green)`)
- Dark backgrounds (`var(--matrix-dark)`)
- Focus states with glow effect
- Placeholder text in dim green

## Testing Checklist

### Basic Functionality
- [ ] **Load Page**: Files list appears with count
- [ ] **Search**: Type in search box, files filter in real-time
- [ ] **Sort**: Change dropdown, files reorder immediately
- [ ] **Combine**: Search + sort work together
- [ ] **Clear Search**: Delete search text, all files return
- [ ] **No Results**: Search for non-existent file, see "No files match your search"

### Progress Bar (Existing Issue)
- [ ] **Download Video**: Start a download
- [ ] **Check Terminal**: Look for `Progress: downloading X.X%` logs
- [ ] **Check UI**: Progress bar should update (0% → 100%)
- [ ] **Auto-Refresh**: File list should update automatically after download

### VIEW Button
- [ ] **Click View**: Opens video player in new page
- [ ] **Video Plays**: HTML5 player loads and plays
- [ ] **Keyboard Shortcuts**: Test Space (pause), arrows (seek), J/L (10s jumps)

### MACRO Button
- [ ] **Configure NAS** (if testing Synology):
  ```bash
  export YT_DLP_NAS_HOST=your.synology.local
  export YT_DLP_NAS_USER=your_username
  export YT_DLP_NAS_PASSWORD=your_password
  export YT_DLP_NAS_SHARE_PATH=/video
  export YT_DLP_NAS_API_URL=http://your.synology.local:5000
  ```
- [ ] **Click Macro**: Should show progress
- [ ] **Check Logs**: rsync upload, API authentication, share link
- [ ] **Get Link**: Share link appears in UI

## Manual Test Commands

### 1. Start Server
```bash
cd /home/luke/dev/yt-dlp-wizwam
source venv/bin/activate
python -m yt_dlp_wizwam
# OR
downloader
```

### 2. Download Test Video (short video for fast testing)
```bash
# In browser: http://localhost:8080
# Paste URL: https://www.youtube.com/watch?v=jNQXAC9IVRw
# (Me at the zoo - 19 seconds)
```

### 3. Test Search
```
- Type "zoo" → should show the file
- Type "xxxx" → should show "No files match"
- Clear search → file returns
```

### 4. Test Sort
```
- Download multiple videos with different names/sizes
- Switch between sort options
- Verify order changes
```

### 5. Check Server Logs
```bash
# Look for these log messages:
[INFO] Progress: initializing 0.0% - Starting download...
[INFO] Progress: downloading 5.2% - Downloading video stream...
[INFO] Progress: downloading 100.0% - Download complete
[INFO] Progress: merging 0.0% - Merging video and audio...
[INFO] Progress: complete 100.0% - Video downloaded successfully
```

## Expected Behavior

### Search Feature
- **Real-time filtering**: Results update as you type
- **Case-insensitive**: "VIDEO" matches "video.mp4"
- **Partial matches**: "cat" matches "category_video.mp4"
- **Count updates**: Shows "Showing 3 of 10 files" when filtering

### Sort Feature
- **Newest First**: Uses file.modified timestamp (descending)
- **Oldest First**: Uses file.modified timestamp (ascending)
- **Name (A-Z)**: Alphabetical, case-insensitive
- **Name (Z-A)**: Reverse alphabetical
- **Size (Largest)**: Uses file.size in bytes (descending)
- **Size (Smallest)**: Uses file.size in bytes (ascending)

### Auto-Refresh
- File list automatically updates after download completes
- Search/sort state is preserved during refresh
- New file appears according to current sort order

## Known Issues

### Progress Bar Not Updating (DEBUGGING)
**Symptoms**: Progress stays at "Initializing... 0%" during download

**Debug Steps**:
1. Check server logs for `Progress:` messages
2. If logs show progress but UI doesn't update:
   - Check browser console for Socket.IO errors
   - Verify Socket.IO connection: `socket.connected` should be `true`
3. If no logs appear:
   - Problem is in `downloader.py` - progress callback not being called
   - Check yt-dlp version: `yt-dlp --version`

**Potential Fixes**:
- Ensure Socket.IO is connected before emitting
- Add retry logic for emit failures
- Check if progress_callback is actually being passed to yt-dlp

### Future Enhancements (See TODO.md Phase 11)
- Server-side search with pagination for large file counts
- Full-text search across video transcriptions
- Subtitle/SRT file integration
- Timestamp-based search results (jump to specific moment in video)
- Advanced filters (date range, file type, duration, codec)
- Saved search queries
- Search history

## Architecture Notes

### Client-Side vs Server-Side Search

**Current: Client-Side (Phase 1)**
- All files loaded into `allFiles` array
- Filtering happens in JavaScript
- Fast for <1000 files
- No server round-trips

**Future: Server-Side (Phase 2)**
- API endpoint: `/api/files/search?q=term&sort=newest&limit=50&offset=0`
- SQLite FTS5 full-text search
- Pagination for large libraries
- Search across metadata (title, description, tags)
- Search across transcriptions (Whisper output)

### Why This Approach?

1. **Progressive Enhancement**: Client-side works immediately, server-side added later
2. **Performance**: Most users have <100 files, client-side is faster
3. **Simplicity**: No database required for initial release
4. **Future-Proof**: Easy to swap in server-side when needed

### When to Switch to Server-Side?

- File count exceeds 500-1000 files
- Users request transcript search
- Mobile users report slow performance
- Advanced filtering needed (date ranges, complex queries)
