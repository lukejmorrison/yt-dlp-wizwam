# Download Directory Configuration Feature

## Overview

Added the ability for users to select and save a custom download directory through the web interface Settings page. The directory preference is stored persistently in a user configuration file.

## What Was Implemented

### 1. Backend Components

#### New File: `yt_dlp_wizwam/user_config.py`
- **UserConfig class**: Manages persistent user preferences
- **Storage**: `~/.yt-dlp-wizwam/config.json`
- **Features**:
  - Automatic config directory creation
  - JSON-based storage
  - Default values for all settings
  - Thread-safe read/write operations
  
**Stored Settings**:
```json
{
  "download_dir": "/path/to/downloads",
  "default_quality": "720p",
  "default_video_codec": "avc1",
  "default_audio_codec": "m4a"
}
```

#### Updated: `yt_dlp_wizwam/config.py`
- Integrated UserConfig for download directory
- **Priority Order**:
  1. Environment variable `YT_DLP_WIZWAM_DOWNLOAD_DIR`
  2. User config file setting
  3. Default: `~/Downloads/yt-dlp-wizwam`

#### Updated: `yt_dlp_wizwam/web.py`
Added three new API endpoints:

**1. POST /api/config/download-dir**
- Updates the download directory
- Validates path (absolute, writable, can create)
- Creates directory if it doesn't exist
- Saves to user config file
- Updates Config class for current session

Request:
```json
{
  "download_dir": "/path/to/directory"
}
```

Response (success):
```json
{
  "status": "success",
  "download_dir": "/path/to/directory",
  "message": "Download directory updated successfully"
}
```

Response (error):
```json
{
  "status": "error",
  "error": "Directory is not writable"
}
```

**2. POST /api/config/validate-dir**
- Validates a directory path without saving
- Real-time validation for UI feedback
- Checks: absolute path, exists, is directory, writable

Request:
```json
{
  "path": "/path/to/directory"
}
```

Response:
```json
{
  "valid": true,
  "exists": true
}
```

Or:
```json
{
  "valid": true,
  "exists": false,
  "message": "Directory will be created"
}
```

Or:
```json
{
  "valid": false,
  "error": "Path is not a directory"
}
```

### 2. Frontend Components

#### Updated: `templates/settings.html`

**New Section: Download Directory**
- Current directory display
- Text input for new directory path
- Browse button (with educational message about browser security)
- Real-time path validation
- Save button

**Features**:
- Shows current download directory
- Placeholder shows current path as hint
- Real-time validation as user types (debounced 500ms)
- Visual feedback (green checkmark for valid, red X for invalid)
- Informative error messages
- Disabled save button while saving

**UI Flow**:
1. User sees current directory
2. User types new path in input field
3. Validation runs automatically (green ✓ or red ✗)
4. User clicks "Save Directory"
5. Success message confirms change
6. Input clears, ready for next change

#### Updated: `static/css/styles.css`

**New CSS Classes**:
- `.path-input-group` - Flex layout for input + browse button
- `.path-input` - Flexible width path input
- `.form-help` - Help text styling
- `.validation-message` - Base validation message
- `.validation-message.success` - Green border/background for valid paths
- `.validation-message.error` - Red border/background for invalid paths

**Styling Features**:
- Matrix theme integration (green text on dark background)
- Responsive flex layout
- Visual feedback with colored borders
- Smooth transitions

## How to Use

### As a User

1. **Navigate to Settings**: Click "Settings" in the navigation bar
2. **Find Download Directory Section**: Top section of the settings page
3. **Enter New Path**: Type the full path to your desired download folder
   - Linux/Mac example: `/home/username/Videos/downloads`
   - Windows example: `C:\Users\username\Videos\downloads`
4. **Validation**: Watch for the green checkmark (✓) or red error (✗)
5. **Save**: Click "💾 Save Directory" button
6. **Confirmation**: You'll see a success message with the new path

### Path Requirements

- **Must be absolute** (start with `/` on Linux/Mac or drive letter on Windows)
- **Must be writable** (you have permission to create/write files)
- **Will be created** if it doesn't exist (as long as parent is writable)

### Browser Limitation

The "📁 Browse" button shows an informational message because web browsers cannot browse your local file system for security reasons. You must manually type the path.

## Configuration Priority

The download directory is determined by this priority:

1. **Environment Variable** (highest priority)
   ```bash
   export YT_DLP_WIZWAM_DOWNLOAD_DIR="/custom/path"
   ```

2. **User Config File**
   - Location: `~/.yt-dlp-wizwam/config.json`
   - Set via Settings page

3. **Default**
   - `~/Downloads/yt-dlp-wizwam`

## Technical Details

### File Locations

- **User Config**: `~/.yt-dlp-wizwam/config.json`
- **Log Directory**: `~/.yt-dlp-wizwam/logs/`
- **Macro Scripts**: `~/.config/yt-dlp-wizwam/macros/`

### Validation Logic

The backend performs these checks:

1. **Path is not empty**
2. **Path is absolute** (not relative like `./downloads`)
3. **If path exists**:
   - Must be a directory (not a file)
   - Must be writable
4. **If path doesn't exist**:
   - Parent directory must exist
   - Parent directory must be writable

### Session vs Persistent

- **Current Session**: Updated immediately in `Config.DOWNLOAD_DIR`
  - All new downloads use the new path right away
  - No server restart required

- **Persistent**: Saved to `~/.yt-dlp-wizwam/config.json`
  - Survives server restarts
  - Survives system reboots
  - User preference across sessions

## API Examples

### Test with curl

**Check current config**:
```bash
curl http://localhost:8080/api/config | jq
```

**Validate a path**:
```bash
curl -X POST http://localhost:8080/api/config/validate-dir \
  -H "Content-Type: application/json" \
  -d '{"path": "/home/luke/Videos"}' | jq
```

**Update download directory**:
```bash
curl -X POST http://localhost:8080/api/config/download-dir \
  -H "Content-Type: application/json" \
  -d '{"download_dir": "/home/luke/Videos/youtube"}' | jq
```

## Error Handling

### Common Errors

1. **"Path must be absolute"**
   - User entered relative path like `./downloads`
   - Solution: Use full path `/home/user/downloads`

2. **"Directory is not writable"**
   - No write permission on existing directory
   - Solution: Change permissions with `chmod` or choose different directory

3. **"Cannot create directory"**
   - Parent directory doesn't exist or not writable
   - Solution: Create parent directory first or choose different path

4. **"Path is not a directory"**
   - User entered path to a file, not a folder
   - Solution: Remove the filename, use only the folder path

### Logging

The backend logs all configuration changes:
```
[INFO] Download directory updated to: /home/luke/Videos/youtube
```

## Future Enhancements

Potential improvements for future versions:

1. **Directory Picker Dialog** (if Electron wrapper is added)
   - Native file browser dialog
   - No manual typing required

2. **Recent Directories**
   - Dropdown of recently used paths
   - Quick selection from history

3. **Suggested Paths**
   - Common download locations
   - Platform-specific suggestions (Videos folder, Documents, etc.)

4. **Space Check**
   - Show available disk space
   - Warn if directory is nearly full

5. **Directory Templates**
   - Organize by date: `/downloads/{year}/{month}/`
   - Organize by platform: `/downloads/{platform}/`
   - Organize by quality: `/downloads/{quality}/`

## Testing Checklist

- [x] Backend API endpoints created
- [x] Frontend UI implemented
- [x] Real-time validation working
- [x] Config file persistence working
- [x] Environment variable override working
- [x] Error handling for invalid paths
- [x] Success messages displayed
- [x] Matrix theme styling applied
- [ ] Test with actual downloads (manual testing)
- [ ] Test on Windows paths
- [ ] Test with network paths/NFS mounts

## Files Modified

1. **yt_dlp_wizwam/user_config.py** (NEW)
   - UserConfig class for persistent storage

2. **yt_dlp_wizwam/config.py**
   - Import UserConfig
   - Load download_dir from user config

3. **yt_dlp_wizwam/web.py**
   - Import UserConfig
   - Add /api/config/download-dir endpoint
   - Add /api/config/validate-dir endpoint

4. **yt_dlp_wizwam/templates/settings.html**
   - Add Download Directory section
   - Add form with input and browse button
   - Add JavaScript for validation and save

5. **yt_dlp_wizwam/static/css/styles.css**
   - Add .path-input-group styling
   - Add .validation-message styling
   - Add .form-help styling

## Migration Notes

**Existing Users**: 
- First visit to Settings page will create `~/.yt-dlp-wizwam/config.json`
- Default download directory remains unchanged
- No action required unless user wants to change location

**Docker Users**:
- Environment variable `YT_DLP_WIZWAM_DOWNLOAD_DIR` still takes precedence
- User config file can be mounted as volume if persistence desired
- Typical Docker setup remains unchanged
