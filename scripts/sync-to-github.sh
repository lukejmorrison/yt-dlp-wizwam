#!/bin/bash

# GitHub Sync Script for yt-dlp-wizwam
# This script helps synchronize local changes with GitHub repository
# Supports regular updates, not just major releases

set -e  # Exit on error

echo "🚀 GitHub Sync Script for yt-dlp-wizwam"
echo "========================================"
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if we're in the right directory
if [ ! -f "setup.py" ] || [ ! -f "README.md" ] || [ ! -d "yt_dlp_wizwam" ]; then
    echo -e "${RED}❌ Error: Not in the yt-dlp-wizwam directory${NC}"
    echo "Please run this script from /home/luke/dev/yt-dlp-wizwam"
    exit 1
fi

echo -e "${BLUE}📍 Current directory: $(pwd)${NC}"
echo ""

# Step 1: Verify git status
echo -e "${YELLOW}Step 1: Checking git status${NC}"
echo "----------------------------"
git status
echo ""

# Ask for confirmation
read -p "Do you want to continue with the sync? (y/n) " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${RED}Sync cancelled${NC}"
    exit 1
fi

# Step 2: Create backup branch
echo -e "${YELLOW}Step 2: Creating backup branch${NC}"
echo "-------------------------------"
BACKUP_BRANCH="backup-before-sync-$(date +%Y%m%d-%H%M%S)"
git branch "$BACKUP_BRANCH"
echo -e "${GREEN}✅ Created backup branch: $BACKUP_BRANCH${NC}"
echo ""

# Step 3: Ensure .gitignore is up to date
echo -e "${YELLOW}Step 3: Checking .gitignore${NC}"
echo "----------------------------"
GITIGNORE_NEEDS_UPDATE=false

# Check for essential entries specific to this project
if ! grep -q "cookies.txt" .gitignore 2>/dev/null; then
    echo "Adding cookies.txt to .gitignore..."
    echo "cookies.txt" >> .gitignore
    GITIGNORE_NEEDS_UPDATE=true
fi

if ! grep -q "config_local.py" .gitignore 2>/dev/null; then
    echo "Adding config_local.py to .gitignore..."
    echo "config_local.py" >> .gitignore
    GITIGNORE_NEEDS_UPDATE=true
fi

if ! grep -q ".yt-dlp-wizwam/" .gitignore 2>/dev/null; then
    echo "Adding .yt-dlp-wizwam/ to .gitignore..."
    echo ".yt-dlp-wizwam/" >> .gitignore
    GITIGNORE_NEEDS_UPDATE=true
fi

if [ "$GITIGNORE_NEEDS_UPDATE" = true ]; then
    echo -e "${GREEN}✅ Updated .gitignore${NC}"
else
    echo -e "${GREEN}✅ .gitignore is up to date${NC}"
fi
echo ""

# Step 4: Stage modified files intelligently
echo -e "${YELLOW}Step 4: Staging modified files${NC}"
echo "--------------------------------"

# Check what files have been modified/added
MODIFIED_FILES=$(git status --porcelain | grep -E "^(M|A|\?\?)" | wc -l)
UNTRACKED_FILES=$(git status --porcelain | grep "^??" | wc -l)

if [ "$MODIFIED_FILES" -eq 0 ]; then
    echo -e "${YELLOW}⚠️  No modified files detected. Checking if you want to stage all changes...${NC}"
    echo ""
    echo "Current git status:"
    git status --short
    echo ""
    read -p "No changes detected. Stage all files anyway? (y/n) " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "Staging all files..."
        git add .
    else
        echo -e "${YELLOW}Please make your changes first, then run this script.${NC}"
        exit 1
    fi
else
    echo "Staging all modified and new files..."
    # Stage all modified, added, and untracked files
    git add -A
fi

# Remove any staged files that are now ignored (e.g., logs/)
echo "Removing staged files that should be ignored..."
git diff --cached --name-only | while read -r file; do
    if git check-ignore "$file" >/dev/null 2>&1; then
        echo "Unstaging ignored file: $file"
        git reset HEAD "$file" >/dev/null 2>&1
        git rm --cached "$file" >/dev/null 2>&1 || true
    fi
done

echo -e "${GREEN}✅ Files staged${NC}"
echo ""

# Show what will be committed
echo -e "${YELLOW}Files to be committed:${NC}"
git diff --cached --name-status
echo ""

# Check if there are any staged changes
STAGED_CHANGES=$(git diff --cached --name-only | wc -l)
if [ "$STAGED_CHANGES" -eq 0 ]; then
    echo -e "${YELLOW}⚠️  No files staged for commit. Nothing to sync.${NC}"
    exit 1
fi

# Step 5: Check for sensitive data
echo -e "${YELLOW}Step 5: Security check${NC}"
echo "----------------------"
echo "Checking for potential secrets..."

# Check for common secret patterns and capture details
SECRETS_FOUND=0
SECRET_FILES=""

# Function to find secrets with line numbers
find_secrets() {
    local pattern="$1"
    local label="$2"

    # Get list of staged files
    staged_files=$(git diff --cached --name-only)

    for file in $staged_files; do
        # Skip script and documentation files to avoid false positives
        if [[ "$file" == *.sh ]] || [[ "$file" == *.md ]]; then
            continue
        fi
        if [ -f "$file" ]; then
            # Look for actual hardcoded secrets (quoted strings after =)
            # This will match: password = "secret" or password="secret" or secret_key = 'value'
            # But NOT: password = os.getenv('PASSWORD') or password = get_env_var()
            hardcoded_matches=$(grep -n "$pattern[[:space:]]*['\"][^'\"]*['\"]" "$file" 2>/dev/null | grep -v "example" | grep -v "#" | head -3)

            if [ -n "$hardcoded_matches" ]; then
                echo -e "${RED}⚠️  WARNING: Hardcoded $label found in $file!${NC}"
                SECRETS_FOUND=1
                while IFS=: read -r line_num content; do
                    # Clean up the line content for display
                    clean_content=$(echo "$content" | sed 's/^[[:space:]]*//')
                    SECRET_FILES="$SECRET_FILES- $file: line $line_num: $clean_content\n"
                done <<< "$hardcoded_matches"
            fi
        fi
    done
}

# Check each pattern
find_secrets "password.*=" "password"
find_secrets "secret_key.*=" "secret_key"
find_secrets "SECRET_KEY.*=" "SECRET_KEY"
find_secrets "token.*=" "token"
find_secrets "api_key.*=" "api_key"

if [ $SECRETS_FOUND -eq 0 ]; then
    echo -e "${GREEN}✅ No hardcoded secrets detected${NC}"
    echo -e "${BLUE}ℹ️  Note: The script only flags actual hardcoded values like password=\"secret\"${NC}"
    echo -e "${BLUE}   Environment variables like password=os.getenv('PASSWORD') are safe and allowed.${NC}"
else
    echo -e "${RED}❌ Hardcoded secrets detected! These must be fixed before committing.${NC}"
    echo ""
    echo -e "${YELLOW}Problematic lines found:${NC}"
    echo -e "$SECRET_FILES"
    echo ""
    read -p "Continue anyway? (y/n) " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${RED}Sync cancelled${NC}"
        echo ""
        echo -e "${YELLOW}To fix the secrets:${NC}"
        echo "1. Replace hardcoded values with environment variables:"
        echo "   BAD:  password = \"secret123\""
        echo "   GOOD: password = os.getenv('PASSWORD')"
        echo ""
        echo "2. Or use .env files for local development"
        echo "3. Then run: git add <fixed-files> && ./scripts/sync-to-github.sh again"
        echo ""
        exit 1
    fi
fi
echo ""

# Step 6: Create commit
echo -e "${YELLOW}Step 6: Creating commit${NC}"
echo "-----------------------"

# Get commit message from user or generate a default
echo "Enter a commit message (or press Enter for auto-generated message):"
read -r USER_COMMIT_MESSAGE

if [ -z "$USER_COMMIT_MESSAGE" ]; then
    # Auto-generate commit message based on changed files
    CHANGED_FILES=$(git diff --cached --name-only)
    FILE_COUNT=$(echo "$CHANGED_FILES" | wc -l)

    # Categorize changes
    DOC_CHANGES=$(echo "$CHANGED_FILES" | grep -E "\.(md|txt|rst)$" | wc -l)
    CODE_CHANGES=$(echo "$CHANGED_FILES" | grep -E "\.(py|js|html|css|sh)$" | wc -l)
    CONFIG_CHANGES=$(echo "$CHANGED_FILES" | grep -E "(setup\.py|pyproject\.toml|requirements\.txt|MANIFEST\.in|\.yml|\.yaml|\.conf)$" | wc -l)

    # Generate appropriate commit message
    if [ "$DOC_CHANGES" -gt "$CODE_CHANGES" ] && [ "$DOC_CHANGES" -gt "$CONFIG_CHANGES" ]; then
        COMMIT_MESSAGE="docs: Update documentation and guides"
    elif [ "$CONFIG_CHANGES" -gt "$CODE_CHANGES" ] && [ "$CONFIG_CHANGES" -gt "$DOC_CHANGES" ]; then
        COMMIT_MESSAGE="chore: Update configuration and packaging files"
    elif [ "$FILE_COUNT" -eq 1 ]; then
        COMMIT_MESSAGE="feat: Update $(basename "$CHANGED_FILES")"
    else
        COMMIT_MESSAGE="feat: Update application files and improvements"
    fi

    echo -e "${BLUE}Using auto-generated commit message${NC}"
else
    COMMIT_MESSAGE="$USER_COMMIT_MESSAGE"
    echo -e "${BLUE}Using custom commit message${NC}"
fi

echo -e "${GREEN}Commit message: \"$COMMIT_MESSAGE\"${NC}"
echo ""
git commit -m "$COMMIT_MESSAGE"
echo -e "${GREEN}✅ Commit created${NC}"
echo ""

# Capture the commit hash just created
COMMIT_HASH=$(git rev-parse --short HEAD 2>/dev/null || true)
if [ -n "$COMMIT_HASH" ]; then
    COMMIT_URL="https://github.com/lukejmorrison/yt-dlp-wizwam/commit/$COMMIT_HASH"
    echo -e "${BLUE}🔖 Commit created: ${GREEN}$COMMIT_HASH${NC}"
    echo -e "${BLUE}🔗 View commit: ${GREEN}$COMMIT_URL${NC}"
    echo ""
fi

# Step 7: Show commit info
echo -e "${YELLOW}Step 7: Commit summary${NC}"
echo "----------------------"
git show --stat HEAD
echo ""

# Step 8: Ask before pushing
echo -e "${YELLOW}Step 8: Ready to push to GitHub${NC}"
echo "--------------------------------"
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
echo -e "${BLUE}Remote: origin${NC}"
echo -e "${BLUE}Branch: $CURRENT_BRANCH${NC}"
echo ""

read -p "Push to GitHub now? (y/n) " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Commit created but not pushed.${NC}"
    echo "To push later, run: git push origin $CURRENT_BRANCH"
    exit 0
fi

# Step 9: Push to GitHub
echo -e "${YELLOW}Step 9: Pushing to GitHub${NC}"
echo "-------------------------"
git push origin "$CURRENT_BRANCH"

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Successfully pushed to GitHub!${NC}"
    echo ""
    echo -e "${GREEN}🎉 Sync complete!${NC}"
    echo ""
    
    # Check current version from __init__.py
    CURRENT_VERSION=""
    if [ -f "yt_dlp_wizwam/__init__.py" ]; then
        CURRENT_VERSION=$(grep -m 1 "__version__" yt_dlp_wizwam/__init__.py | sed "s/.*['\"]//;s/['\"].*//" | sed 's/^/v/')
    fi
    
    # Detect what needs to be done next
    NEEDS_STEPS=false
    NEXT_STEPS=""
    
    # Check if version tag already exists
    if [ -n "$CURRENT_VERSION" ]; then
        if git rev-parse "$CURRENT_VERSION" >/dev/null 2>&1; then
            echo -e "${BLUE}ℹ️  Version tag $CURRENT_VERSION already exists${NC}"
        else
            NEEDS_STEPS=true
            NEXT_STEPS="${NEXT_STEPS}• Create release tag:\n  ${GREEN}git tag -a $CURRENT_VERSION -m 'Release $CURRENT_VERSION' && git push origin $CURRENT_VERSION${NC}\n\n"
        fi
    fi
    
    # Always show link to GitHub
    echo -e "${YELLOW}📋 What's Next:${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    # Recompute the short commit hash (in case)
    PUSHED_COMMIT_HASH=$(git rev-parse --short HEAD 2>/dev/null || true)
    if [ -n "$PUSHED_COMMIT_HASH" ]; then
        PUSHED_COMMIT_URL="https://github.com/lukejmorrison/yt-dlp-wizwam/commit/$PUSHED_COMMIT_HASH"
    fi

    echo -e "${GREEN}✅ COMPLETED:${NC}"
    echo "  1) Code pushed to GitHub successfully"
    if [ -n "$PUSHED_COMMIT_HASH" ]; then
        echo "     • Commit: $PUSHED_COMMIT_HASH"
        echo "     • View commit: $PUSHED_COMMIT_URL"
    fi

    if [ -n "$CURRENT_VERSION" ] && git rev-parse "$CURRENT_VERSION" >/dev/null 2>&1; then
        echo "  2) Version tag $CURRENT_VERSION exists"
        echo ""
        echo "No further actions required unless you want to create a GitHub Release page. To view releases:" 
        echo "   https://github.com/lukejmorrison/yt-dlp-wizwam/releases"
    else
        echo ""
        echo -e "${YELLOW}📝 ACTION REQUIRED (optional):${NC}"
        echo "  You can create a release tag for version $CURRENT_VERSION to mark this release:"
        echo ""
        echo -e "  ${GREEN}git tag -a $CURRENT_VERSION -m 'Release $CURRENT_VERSION' && git push origin $CURRENT_VERSION${NC}"
        echo ""
        echo "  After tagging, you can create a GitHub Release using the web UI:" 
        echo "   https://github.com/lukejmorrison/yt-dlp-wizwam/releases/new?tag=$CURRENT_VERSION"
    fi
    echo ""
    echo -e "${BLUE}🔗 GitHub Repository:${NC}"
    echo -e "  ${GREEN}https://github.com/lukejmorrison/yt-dlp-wizwam${NC}"
    echo ""
    echo ""
else
    echo -e "${RED}❌ Push failed!${NC}"
    echo "You may need to:"
    echo "1. Check your network connection"
    echo "2. Verify GitHub credentials (SSH key or PAT)"
    echo "3. Pull latest changes first: git pull origin $CURRENT_BRANCH"
    echo "4. Check that your SSH key is loaded: ssh-add ~/.ssh/id_ed25519"
    exit 1
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${BLUE}💾 Backup Info:${NC}"
echo -e "  Branch: ${GREEN}$BACKUP_BRANCH${NC}"
echo -e "  Rollback: ${YELLOW}git checkout $BACKUP_BRANCH${NC}"
echo ""
