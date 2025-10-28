# Download Progress Fix

## Problem
Downloads were hanging at "Initializing download... 0%" and the progress bar wasn't updating.

## Root Cause
Using `threading.Thread()` for background downloads is incompatible with Flask-SocketIO's eventlet async mode. The Socket.IO events were being emitted but not delivered to the browser because the thread wasn't running in an eventlet greenlet.

## Solution
Changed from:
```python
thread = threading.Thread(target=download_worker)
thread.daemon = True
thread.start()
```

To:
```python
socketio.start_background_task(download_worker)
```

## Additional Improvements

1. **Enhanced Logging**: Added detailed logging throughout the download process:
   - Job ID tracking
   - Current download directory logging
   - Progress callback details (phase, percent, message)
   - Download worker lifecycle events
   - Error details with full stack traces

2. **Test Endpoint**: Added `/api/test-socketio` endpoint to verify Socket.IO is working:
   ```bash
   curl -X POST http://localhost:8080/api/test-socketio
   ```

## How It Works Now

1. **Download Request**:
   - Client submits form → `/api/download` endpoint
   - Server generates job ID
   - Server starts background task using `socketio.start_background_task()`
   - Returns immediately with job ID and status

2. **Background Download**:
   - `download_worker()` runs in eventlet greenlet
   - Calls `download_video()` with progress callback
   - Progress callback emits Socket.IO events
   - Events are properly delivered to browser

3. **Progress Updates**:
   - "initializing" → Fetching video information
   - "downloading" → Downloading video/audio streams
   - "processing" → Merging streams
   - "success" → Download complete

4. **Browser Updates**:
   - Socket.IO client receives 'progress' events
   - Updates progress bar and percentage
   - Shows current phase and message
   - Auto-refreshes file list on completion

## Testing

### Start the Server
```bash
cd /home/luke/dev/yt-dlp-wizwam
python3 -m yt_dlp_wizwam web --open-browser
```

### Test Socket.IO Connection
Open browser console (F12) and check for:
- "Connected to server" message
- Socket.IO connection status

Or test with curl:
```bash
curl -X POST http://localhost:8080/api/test-socketio
```

### Download a Video
1. Paste URL: https://youtu.be/oQvK95SXfms
2. Click DOWNLOAD
3. Watch server terminal for log messages:
   ```
   [INFO] Starting download job <uuid>
   [INFO] Current download directory: /path/to/downloads
   [INFO] Download worker started for job <uuid>
   [INFO] Calling download_video with url=...
   [INFO] Progress callback - Job: <uuid>, Phase: initializing, Percent: 0.0%, Message: Fetching video information...
   [INFO] Progress callback - Job: <uuid>, Phase: downloading, Percent: 15.3%, Message: Speed: 2.5MB/s, ETA: 00:05
   ...
   ```

4. Watch browser for progress updates:
   - Progress bar should fill from 0% → 100%
   - Status messages should update
   - File should appear in Downloaded Files list

## Why This Fix Works

**Eventlet Greenlets vs OS Threads**:
- Flask-SocketIO with eventlet uses cooperative multitasking (greenlets)
- Regular Python threads (threading.Thread) don't play well with eventlet
- Socket.IO events emitted from OS threads may not be delivered properly
- `socketio.start_background_task()` creates an eventlet greenlet
- Greenlets cooperate with the Socket.IO event loop

**From Flask-SocketIO Docs**:
> When using the eventlet or gevent async modes, the server uses greenlets for concurrency. To ensure compatibility with the event loop, background tasks should be started using socketio.start_background_task().

## Verification Checklist

- [x] Changed Thread to socketio.start_background_task()
- [x] Added comprehensive logging
- [x] Added test Socket.IO endpoint
- [x] Progress callback logging shows phase/percent/message
- [ ] Test with actual download (manual)
- [ ] Verify progress bar updates in browser
- [ ] Verify file appears in list after download
- [ ] Check server logs for progress messages

## Known Limitations

1. **Browser Security**: Can't show native folder picker for download directory
2. **Progress Granularity**: yt-dlp controls update frequency
3. **Multiple Downloads**: Currently no queue, one at a time

## Future Improvements

1. Download queue system
2. Pause/resume downloads
3. Download history with statistics
4. Bandwidth limiting
5. Concurrent downloads (with proper eventlet handling)
