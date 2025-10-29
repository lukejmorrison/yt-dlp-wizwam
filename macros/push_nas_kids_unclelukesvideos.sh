#!/bin/bash
#
# Synology NAS Macro Script for yt-dlp-wizwam
# Uploads file to Synology NAS and generates share link via FileStation API
#
# Setup Instructions:
# 1. Enable SSH on your Synology NAS (Control Panel > Terminal & SNMP)
# 2. Create API credentials (Control Panel > Application > Create)
# 3. Set environment variables in ~/.bashrc or ~/.zshrc:
#
#    export YT_DLP_WIZWAM_NAS_HOST="your-nas.local"
#    export YT_DLP_WIZWAM_NAS_USER="your-username"
#    export YT_DLP_WIZWAM_NAS_PASSWORD="your-password"
#    export YT_DLP_WIZWAM_NAS_SHARE_PATH="/volume1/video/youtube"
#    export YT_DLP_WIZWAM_NAS_API_URL="https://your-nas.local:5001"
#
# 4. Make script executable: chmod +x synology.sh
# 5. Set in settings: ~/.config/yt-dlp-wizwam/macros/synology.sh
#

set -e

# Input file
INPUT_FILE="$1"
FILENAME=$(basename "$INPUT_FILE")

echo "🔧 Synology NAS Integration"
echo "================================"

# Validate configuration
if [ -z "$YT_DLP_WIZWAM_NAS_HOST" ] || [ -z "$YT_DLP_WIZWAM_NAS_USER" ] || [ -z "$YT_DLP_WIZWAM_NAS_PASSWORD" ]; then
    echo "❌ Error: NAS credentials not configured"
    echo "Please set YT_DLP_WIZWAM_NAS_HOST, NAS_USER, and NAS_PASSWORD"
    exit 1
fi

# Step 1: Upload file to NAS
echo "📤 Uploading to NAS..."
rsync -avz --progress "$INPUT_FILE" \
    "${YT_DLP_WIZWAM_NAS_USER}@${YT_DLP_WIZWAM_NAS_HOST}:${YT_DLP_WIZWAM_NAS_SHARE_PATH}/"

echo "✅ File uploaded"

# Step 2: Authenticate with Synology API
echo "🔐 Authenticating with Synology API..."
AUTH_RESPONSE=$(curl -sk "${YT_DLP_WIZWAM_NAS_API_URL}/webapi/auth.cgi" \
    --data-urlencode "api=SYNO.API.Auth" \
    --data-urlencode "version=3" \
    --data-urlencode "method=login" \
    --data-urlencode "account=${YT_DLP_WIZWAM_NAS_USER}" \
    --data-urlencode "passwd=${YT_DLP_WIZWAM_NAS_PASSWORD}" \
    --data-urlencode "session=FileStation" \
    --data-urlencode "format=sid")

# Extract SID (session ID)
SID=$(echo "$AUTH_RESPONSE" | grep -o '"sid":"[^"]*"' | cut -d'"' -f4)

if [ -z "$SID" ]; then
    echo "❌ Authentication failed"
    echo "Response: $AUTH_RESPONSE"
    exit 1
fi

echo "✅ Authenticated"

# Step 3: Create share link
echo "🔗 Creating share link..."
SHARE_RESPONSE=$(curl -sk "${YT_DLP_WIZWAM_NAS_API_URL}/webapi/entry.cgi" \
    --data-urlencode "api=SYNO.FileStation.Sharing" \
    --data-urlencode "version=3" \
    --data-urlencode "method=create" \
    --data-urlencode "_sid=${SID}" \
    --data-urlencode "path=${YT_DLP_WIZWAM_NAS_SHARE_PATH}/${FILENAME}")

# Extract share link
SHARE_ID=$(echo "$SHARE_RESPONSE" | grep -o '"id":"[^"]*"' | cut -d'"' -f4)

if [ -n "$SHARE_ID" ]; then
    SHARE_LINK="https://${YT_DLP_WIZWAM_NAS_HOST}/sharing/${SHARE_ID}"
    echo "✅ Share link created"
    echo ""
    echo "SHARE_LINK:${SHARE_LINK}"
else
    echo "⚠️  Could not create share link automatically"
    echo "Response: $SHARE_RESPONSE"
fi

# Step 4: Logout
curl -sk "${YT_DLP_WIZWAM_NAS_API_URL}/webapi/auth.cgi" \
    --data-urlencode "api=SYNO.API.Auth" \
    --data-urlencode "version=1" \
    --data-urlencode "method=logout" \
    --data-urlencode "session=FileStation" \
    --data-urlencode "_sid=${SID}" > /dev/null

echo ""
echo "🎉 Macro completed!"
echo ""
echo "📄 File: $FILENAME"
echo "📦 NAS: ${YT_DLP_WIZWAM_NAS_HOST}:${YT_DLP_WIZWAM_NAS_SHARE_PATH}/$FILENAME"
if [ -n "$SHARE_LINK" ]; then
    echo "🔗 Share: $SHARE_LINK"
fi
