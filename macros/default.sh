#!/bin/bash
#
# Default Macro Script for yt-dlp-wizwam
# Copies file to NAS and generates share link
#
# Usage: ./default.sh /path/to/video.mp4
#
# Environment variables (set in ~/.bashrc or ~/.zshrc):
#   YT_DLP_WIZWAM_NAS_HOST - NAS hostname or IP
#   YT_DLP_WIZWAM_NAS_USER - NAS username
#   YT_DLP_WIZWAM_NAS_PASSWORD - NAS password
#   YT_DLP_WIZWAM_NAS_SHARE_PATH - Path on NAS (e.g., /volume1/video)
#   YT_DLP_WIZWAM_NAS_MOUNT - Local mount point (optional, for local copy)
#

set -e  # Exit on error

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Input file
INPUT_FILE="$1"

if [ -z "$INPUT_FILE" ]; then
    echo -e "${RED}Error: No file specified${NC}" >&2
    exit 1
fi

if [ ! -f "$INPUT_FILE" ]; then
    echo -e "${RED}Error: File not found: $INPUT_FILE${NC}" >&2
    exit 1
fi

FILENAME=$(basename "$INPUT_FILE")

echo -e "${GREEN}📦 Starting macro for: $FILENAME${NC}"

# Check if NAS is configured
if [ -z "$YT_DLP_WIZWAM_NAS_HOST" ]; then
    echo -e "${YELLOW}⚠️  NAS not configured. Performing local operation only.${NC}"
    echo -e "${GREEN}✅ File already exists locally${NC}"
    exit 0
fi

# Method 1: Copy via mounted share (fastest)
if [ -n "$YT_DLP_WIZWAM_NAS_MOUNT" ] && [ -d "$YT_DLP_WIZWAM_NAS_MOUNT" ]; then
    echo -e "${GREEN}📁 Copying to mounted NAS share...${NC}"
    cp "$INPUT_FILE" "$YT_DLP_WIZWAM_NAS_MOUNT/$FILENAME"
    echo -e "${GREEN}✅ File copied to NAS${NC}"
    
# Method 2: Copy via rsync over SSH
elif command -v rsync &> /dev/null; then
    echo -e "${GREEN}🔄 Syncing to NAS via rsync...${NC}"
    rsync -avz --progress "$INPUT_FILE" \
        "${YT_DLP_WIZWAM_NAS_USER}@${YT_DLP_WIZWAM_NAS_HOST}:${YT_DLP_WIZWAM_NAS_SHARE_PATH}/"
    echo -e "${GREEN}✅ File synced to NAS${NC}"
    
# Method 3: Copy via scp
else
    echo -e "${GREEN}📤 Uploading to NAS via SCP...${NC}"
    scp "$INPUT_FILE" \
        "${YT_DLP_WIZWAM_NAS_USER}@${YT_DLP_WIZWAM_NAS_HOST}:${YT_DLP_WIZWAM_NAS_SHARE_PATH}/"
    echo -e "${GREEN}✅ File uploaded to NAS${NC}"
fi

# Generate share link (Synology-specific)
if [ -n "$YT_DLP_WIZWAM_NAS_API_URL" ]; then
    echo -e "${GREEN}🔗 Generating share link...${NC}"
    
    # This is a placeholder - you'll need to implement Synology API calls
    # See: https://global.download.synology.com/download/Document/Software/DeveloperGuide/Package/FileStation/All/enu/Synology_File_Station_API_Guide.pdf
    
    # For now, output a manual share link format
    SHARE_LINK="https://${YT_DLP_WIZWAM_NAS_HOST}/sharing/${FILENAME}"
    echo -e "${GREEN}✅ Share link generated${NC}"
    echo "SHARE_LINK:${SHARE_LINK}"
fi

echo -e "${GREEN}🎉 Macro completed successfully!${NC}"
echo ""
echo "Summary:"
echo "  📄 File: $FILENAME"
echo "  📦 Location: ${YT_DLP_WIZWAM_NAS_HOST}:${YT_DLP_WIZWAM_NAS_SHARE_PATH}/$FILENAME"
if [ -n "$SHARE_LINK" ]; then
    echo "  🔗 Share: $SHARE_LINK"
fi
