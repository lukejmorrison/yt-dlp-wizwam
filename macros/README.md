# yt-dlp-wizwam Macro Scripts

This directory contains example macro scripts that can be executed on downloaded files.

## Quick Start

1. **Copy example script:**
   ```bash
   mkdir -p ~/.config/yt-dlp-wizwam/macros
   cp macros/synology.sh ~/.config/yt-dlp-wizwam/macros/
   chmod +x ~/.config/yt-dlp-wizwam/macros/synology.sh
   ```

2. **Configure environment variables** (add to `~/.bashrc` or `~/.zshrc`):
   ```bash
   export YT_DLP_WIZWAM_NAS_HOST="192.168.1.100"  # Your NAS IP/hostname
   export YT_DLP_WIZWAM_NAS_USER="your-username"
   export YT_DLP_WIZWAM_NAS_PASSWORD="your-password"
   export YT_DLP_WIZWAM_NAS_SHARE_PATH="/volume1/video/youtube"
   export YT_DLP_WIZWAM_NAS_API_URL="https://192.168.1.100:5001"
   export YT_DLP_WIZWAM_MACRO_SCRIPT="$HOME/.config/yt-dlp-wizwam/macros/synology.sh"
   ```

3. **Reload shell:**
   ```bash
   source ~/.bashrc  # or source ~/.zshrc
   ```

4. **Test macro:**
   ```bash
   ~/.config/yt-dlp-wizwam/macros/synology.sh /path/to/video.mp4
   ```

## Available Scripts

### `default.sh`
Basic script that copies files to NAS via rsync/scp. Good starting point for customization.

**Features:**
- Copies file to NAS via mounted share, rsync, or scp
- Generates placeholder share link
- Minimal dependencies

### `synology.sh`
Full Synology NAS integration with FileStation API.

**Features:**
- Uploads file via rsync
- Authenticates with Synology API
- Creates share link programmatically
- Returns clickable share URL

**Requirements:**
- Synology NAS with FileStation enabled
- SSH access to NAS
- API credentials

## Creating Custom Macros

### Script Requirements

1. **Input:** Script receives file path as first argument (`$1`)
2. **Output:** Print status messages to stdout
3. **Share Link:** Output `SHARE_LINK:https://...` to return shareable URL
4. **Exit Code:** Return 0 on success, non-zero on error

### Example Custom Macro

```bash
#!/bin/bash
# custom-macro.sh

INPUT_FILE="$1"
FILENAME=$(basename "$INPUT_FILE")

echo "Processing $FILENAME..."

# Your custom logic here
# - Upload to cloud storage
# - Transcode video
# - Generate thumbnails
# - Send notification
# - etc.

# Return share link (optional)
echo "SHARE_LINK:https://example.com/share/$FILENAME"

echo "✅ Complete!"
exit 0
```

### Make it executable:
```bash
chmod +x custom-macro.sh
```

### Use in app:
```bash
export YT_DLP_WIZWAM_MACRO_SCRIPT="/path/to/custom-macro.sh"
```

## Synology NAS Setup

### Enable SSH
1. Control Panel → Terminal & SNMP
2. Enable SSH service
3. Apply

### Setup API Access
1. Control Panel → Application
2. Enable WebStation and FileStation
3. Note your NAS IP and port (default: 5001 for HTTPS)

### Test SSH Connection
```bash
ssh your-username@your-nas.local
```

### Create Upload Directory
```bash
ssh your-username@your-nas.local
mkdir -p /volume1/video/youtube
chmod 755 /volume1/video/youtube
exit
```

### Test rsync Upload
```bash
rsync -avz test-file.mp4 your-username@your-nas.local:/volume1/video/youtube/
```

## Troubleshooting

### "Macro script not configured"
- Set `YT_DLP_WIZWAM_MACRO_SCRIPT` environment variable
- Check script exists and is executable: `ls -la $YT_DLP_WIZWAM_MACRO_SCRIPT`

### "Permission denied"
```bash
chmod +x ~/.config/yt-dlp-wizwam/macros/synology.sh
```

### "Authentication failed" (Synology)
- Verify username and password
- Check NAS API is enabled (Control Panel → Application)
- Test API manually:
  ```bash
  curl -k "https://your-nas:5001/webapi/auth.cgi?api=SYNO.API.Auth&version=3&method=login&account=USER&passwd=PASS&session=FileStation&format=sid"
  ```

### "Connection refused" (rsync/ssh)
- Verify SSH is enabled on NAS
- Check firewall rules
- Test connection: `ssh your-username@your-nas.local`

### Script timeout
- Default timeout: 5 minutes
- For large files, increase timeout in `web.py`:
  ```python
  timeout=600  # 10 minutes
  ```

## Advanced: Multiple Macro Scripts

To support multiple macro scripts with a dropdown selector:

1. **Create multiple scripts:**
   ```bash
   ~/.config/yt-dlp-wizwam/macros/
   ├── synology.sh
   ├── google-drive.sh
   ├── s3-upload.sh
   └── transcode.sh
   ```

2. **Set default:**
   ```bash
   export YT_DLP_WIZWAM_MACRO_SCRIPT="$HOME/.config/yt-dlp-wizwam/macros/synology.sh"
   ```

3. **App will scan macro directory** and allow selection in Settings (future feature)

## Share Link Integration

Your macro script can output a share link that will be:
1. Displayed in success dialog
2. Automatically copied to clipboard
3. Saved in file metadata (future feature)

**Format:**
```bash
echo "SHARE_LINK:https://your-nas.local/sharing/AbCdEf123"
```

## Examples

### Upload to Google Drive
```bash
#!/bin/bash
# google-drive.sh
rclone copy "$1" gdrive:youtube-downloads/
SHARE_LINK=$(rclone link "gdrive:youtube-downloads/$(basename "$1")")
echo "SHARE_LINK:$SHARE_LINK"
```

### Upload to AWS S3
```bash
#!/bin/bash
# s3-upload.sh
BUCKET="my-videos"
FILENAME=$(basename "$1")
aws s3 cp "$1" "s3://$BUCKET/youtube/$FILENAME"
SHARE_LINK=$(aws s3 presign "s3://$BUCKET/youtube/$FILENAME" --expires-in 604800)
echo "SHARE_LINK:$SHARE_LINK"
```

### Transcode and Upload
```bash
#!/bin/bash
# transcode-and-upload.sh
INPUT="$1"
OUTPUT="${INPUT%.mp4}_compressed.mp4"

# Transcode
ffmpeg -i "$INPUT" -c:v libx264 -crf 23 -c:a aac -b:a 128k "$OUTPUT"

# Upload
rsync "$OUTPUT" user@nas:/volume1/video/

# Clean up
rm "$OUTPUT"

echo "✅ Transcoded and uploaded"
```

## Contributing

Have a useful macro script? Submit a pull request to share it with the community!

## License

Macro scripts are provided as examples. Modify freely for your needs.
