#!/bin/bash

# GitHub Sync Script for yt-dlp-wizwam
# This script helps synchronize local changes with GitHub repository
# Supports regular updates, not just major releases

set -e  # Exit on error

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Parse command line arguments
DRY_RUN=false
AUTO_MODE=false
TEST_AUTH=false

show_help() {
    echo "🚀 GitHub Sync Script for yt-dlp-wizwam"
    echo "========================================"
    echo ""
    echo "Usage: ./sync-to-github.sh [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -h, --help       Show this help message and exit"
    echo "  --testgitauth    Test GitHub authentication by creating and pushing a test file"
    echo "                   (Run this FIRST to validate GitHub is accessible)"
    echo "  --dry-run        Show what would be committed without actually committing or pushing"
    echo "  --auto           Skip all prompts, use auto-generated commit messages, and push automatically"
    echo ""
    echo "Description:"
    echo "  Interactive script to safely sync local changes to GitHub with security checks."
    echo ""
    echo "Features:"
    echo "  • Creates automatic backup branch before committing"
    echo "  • Scans for hardcoded secrets (passwords, API keys, tokens)"
    echo "  • Auto-generates commit messages based on file types"
    echo "  • Suggests version tags based on current version"
    echo "  • Dynamic branch detection"
    echo ""
    echo "Examples:"
    echo "  ./sync-to-github.sh --testgitauth   # Test GitHub auth (run first!)"
    echo "  ./sync-to-github.sh              # Interactive mode (default)"
    echo "  ./sync-to-github.sh --dry-run    # Preview changes without committing"
    echo "  ./sync-to-github.sh --auto       # Fully automated sync"
    echo ""
    echo "Recommended Workflow:"
    echo "  1. Run with --testgitauth to verify GitHub access works"
    echo "  2. Run with --dry-run to preview what will be committed"
    echo "  3. Run normally for interactive sync or with --auto for automated sync"
    echo ""
    echo "Repository: https://github.com/lukejmorrison/yt-dlp-wizwam"
    echo ""
    exit 0
}

# Parse arguments
for arg in "$@"; do
    case $arg in
        -h|--help)
            show_help
            ;;
        --testgitauth)
            TEST_AUTH=true
            shift
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --auto)
            AUTO_MODE=true
            shift
            ;;
        *)
            echo -e "${RED}❌ Unknown option: $arg${NC}"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

if [ "$DRY_RUN" = true ]; then
    echo "🔍 DRY RUN MODE - No changes will be committed or pushed"
    echo "========================================================"
    echo ""
fi

if [ "$AUTO_MODE" = true ]; then
    echo "🤖 AUTO MODE - Skipping all prompts"
    echo "===================================="
    echo ""
fi

# Test GitHub authentication if requested
if [ "$TEST_AUTH" = true ]; then
    echo "🔐 Testing GitHub Authentication"
    echo "================================="
    echo ""
    
    # Get current branch
    CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "main")
    echo -e "${BLUE}Current branch: ${CURRENT_BRANCH}${NC}"
    echo ""
    
    # Create test file
    TEST_FILE="testauth.md"
    TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S %Z')
    
    echo "Creating test file: ${TEST_FILE}"
    cat > "$TEST_FILE" << EOF
# GitHub Authentication Test

This is a test file to verify GitHub authentication and push access.

**Test Details:**
- Timestamp: ${TIMESTAMP}
- Branch: ${CURRENT_BRANCH}
- User: $(whoami)
- Hostname: $(hostname)
- Repository: https://github.com/lukejmorrison/yt-dlp-wizwam

**Purpose:**
This file was created by the sync-to-github.sh script using the --testgitauth flag
to verify that:
1. Git configuration is correct
2. SSH keys or credentials are properly set up
3. Push access to the repository is working

If you can see this file on GitHub, authentication is working correctly!

---
*This file can be safely deleted after verification.*
EOF
    
    echo -e "${GREEN}✅ Test file created${NC}"
    echo ""
    
    # Stage the file
    echo "Staging ${TEST_FILE}..."
    git add "$TEST_FILE"
    echo -e "${GREEN}✅ File staged${NC}"
    echo ""
    
    # Commit the file
    echo "Creating test commit..."
    git commit -m "test: Verify GitHub authentication and push access

This is an automated test commit created by sync-to-github.sh --testgitauth
to verify repository access. The testauth.md file can be deleted after verification."
    
    COMMIT_HASH=$(git rev-parse --short HEAD)
    echo -e "${GREEN}✅ Test commit created: ${COMMIT_HASH}${NC}"
    echo ""
    
    # Test SSH connection first
    echo "Testing SSH connection to GitHub..."
    if ssh -T git@github.com 2>&1 | grep -q "successfully authenticated"; then
        echo -e "${GREEN}✅ SSH authentication successful${NC}"
        echo ""
    else
        echo -e "${YELLOW}⚠️  SSH authentication may have issues, but attempting push anyway...${NC}"
        echo ""
    fi
    
    # Push to GitHub
    echo "Pushing to GitHub..."
    echo -e "${YELLOW}Running: git push origin ${CURRENT_BRANCH}${NC}"
    echo ""
    
    if git push origin "${CURRENT_BRANCH}"; then
        echo ""
        echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${GREEN}🎉 SUCCESS! GitHub authentication is working correctly!${NC}"
        echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo ""
        echo -e "${BLUE}📋 Test Results:${NC}"
        echo "  ✅ Test file created successfully"
        echo "  ✅ File committed to local repository"
        echo "  ✅ Changes pushed to GitHub"
        echo ""
        COMMIT_URL="https://github.com/lukejmorrison/yt-dlp-wizwam/commit/${COMMIT_HASH}"
        echo -e "${BLUE}🔗 View test commit on GitHub:${NC}"
        echo -e "  ${GREEN}${COMMIT_URL}${NC}"
        echo ""
        echo -e "${BLUE}🔗 View test file on GitHub:${NC}"
        echo -e "  ${GREEN}https://github.com/lukejmorrison/yt-dlp-wizwam/blob/${CURRENT_BRANCH}/${TEST_FILE}${NC}"
        echo ""
        echo -e "${YELLOW}📝 Next Steps:${NC}"
        echo "  1. Verify the test file appears on GitHub (check the link above)"
        echo "  2. You can now safely delete ${TEST_FILE} or keep it for reference"
        echo "  3. Run this script normally to sync your actual changes"
        echo ""
        echo "To delete the test file and commit the deletion:"
        echo -e "  ${BLUE}rm ${TEST_FILE} && git add ${TEST_FILE} && git commit -m 'chore: Remove auth test file' && git push${NC}"
        echo ""
    else
        echo ""
        echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${RED}❌ FAILED! GitHub push unsuccessful${NC}"
        echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo ""
        echo -e "${YELLOW}⚠️  Troubleshooting Steps:${NC}"
        echo ""
        echo "1. Check SSH key setup:"
        echo -e "   ${BLUE}ssh -T git@github.com${NC}"
        echo "   You should see: 'Hi lukejmorrison! You've successfully authenticated...'"
        echo ""
        echo "2. Verify SSH key is loaded:"
        echo -e "   ${BLUE}ssh-add -l${NC}"
        echo ""
        echo "3. Add your SSH key if needed:"
        echo -e "   ${BLUE}ssh-add ~/.ssh/id_ed25519${NC}"
        echo "   (or ~/.ssh/id_rsa depending on your key type)"
        echo ""
        echo "4. Check git remote URL:"
        echo -e "   ${BLUE}git remote -v${NC}"
        echo "   Should show: git@github.com:lukejmorrison/yt-dlp-wizwam.git"
        echo ""
        echo "5. If using HTTPS, you may need a personal access token:"
        echo "   https://github.com/settings/tokens"
        echo ""
        echo "To undo the test commit (it wasn't pushed):"
        echo -e "  ${BLUE}git reset --soft HEAD~1 && git restore --staged ${TEST_FILE} && rm ${TEST_FILE}${NC}"
        echo ""
        exit 1
    fi
    
    exit 0
fi

echo "🚀 GitHub Sync Script for yt-dlp-wizwam"
echo "========================================"
echo ""

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
if [ "$AUTO_MODE" = false ]; then
    read -p "Do you want to continue with the sync? (y/n) " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${RED}Sync cancelled${NC}"
        exit 1
    fi
fi

# Step 2: Create backup branch
echo -e "${YELLOW}Step 2: Creating backup branch${NC}"
echo "-------------------------------"
BACKUP_BRANCH="backup-before-sync-$(date +%Y%m%d-%H%M%S)"
if [ "$DRY_RUN" = false ]; then
    git branch "$BACKUP_BRANCH"
    echo -e "${GREEN}✅ Created backup branch: $BACKUP_BRANCH${NC}"
else
    echo -e "${BLUE}[DRY RUN] Would create backup branch: $BACKUP_BRANCH${NC}"
fi
echo ""

# Step 3: Ensure .gitignore is up to date
echo -e "${YELLOW}Step 3: Checking .gitignore${NC}"
echo "----------------------------"
GITIGNORE_NEEDS_UPDATE=false

# Check for essential entries
if ! grep -q "cookies.txt" .gitignore 2>/dev/null; then
    if [ "$DRY_RUN" = false ]; then
        echo "Adding cookies.txt to .gitignore..."
        echo "cookies.txt" >> .gitignore
        GITIGNORE_NEEDS_UPDATE=true
    else
        echo -e "${BLUE}[DRY RUN] Would add cookies.txt to .gitignore${NC}"
    fi
fi

if ! grep -q ".yt-dlp-wizwam/" .gitignore 2>/dev/null; then
    if [ "$DRY_RUN" = false ]; then
        echo "Adding .yt-dlp-wizwam/ to .gitignore..."
        echo ".yt-dlp-wizwam/" >> .gitignore
        GITIGNORE_NEEDS_UPDATE=true
    else
        echo -e "${BLUE}[DRY RUN] Would add .yt-dlp-wizwam/ to .gitignore${NC}"
    fi
fi

if ! grep -q "config_local.py" .gitignore 2>/dev/null; then
    if [ "$DRY_RUN" = false ]; then
        echo "Adding config_local.py to .gitignore..."
        echo "config_local.py" >> .gitignore
        GITIGNORE_NEEDS_UPDATE=true
    else
        echo -e "${BLUE}[DRY RUN] Would add config_local.py to .gitignore${NC}"
    fi
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
    if [ "$AUTO_MODE" = false ]; then
        read -p "No changes detected. Stage all files anyway? (y/n) " -n 1 -r
        echo ""
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            echo "Staging all files..."
            if [ "$DRY_RUN" = false ]; then
                git add .
            else
                echo -e "${BLUE}[DRY RUN] Would stage all files${NC}"
            fi
        else
            echo -e "${YELLOW}Please make your changes first, then run this script.${NC}"
            exit 1
        fi
    else
        echo "Auto mode: Staging all files..."
        if [ "$DRY_RUN" = false ]; then
            git add .
        else
            echo -e "${BLUE}[DRY RUN] Would stage all files${NC}"
        fi
    fi
else
    echo "Staging all modified and new files..."
    # Stage all modified, added, and untracked files
    if [ "$DRY_RUN" = false ]; then
        git add -A
    else
        echo -e "${BLUE}[DRY RUN] Would stage all modified and new files${NC}"
    fi
fi

# Remove any staged files that are now ignored (e.g., logs/)
echo "Removing staged files that should be ignored..."
if [ "$DRY_RUN" = false ]; then
    git diff --cached --name-only | while read -r file; do
        if git check-ignore "$file" >/dev/null 2>&1; then
            echo "Unstaging ignored file: $file"
            git reset HEAD "$file" >/dev/null 2>&1
            git rm --cached "$file" >/dev/null 2>&1 || true
        fi
    done
fi

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
        # Skip script files, documentation, and backup files to avoid false positives
        if [[ "$file" == *.sh ]] || \
           [[ "$file" == *.md ]] || \
           [[ "$file" == *.backup ]] || \
           [[ "$file" == *.backup-* ]] || \
           [[ "$file" == *backup* ]]; then
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
find_secrets "password.*=" "password="
find_secrets "SECRET_KEY.*=" "SECRET_KEY"
find_secrets "api_key.*=" "api_key"
find_secrets "token.*=" "token="

if [ $SECRETS_FOUND -eq 0 ]; then
    echo -e "${GREEN}✅ No hardcoded secrets detected${NC}"
    echo -e "${BLUE}ℹ️  Note: The script only scans Python, JS, HTML, CSS, and config files${NC}"
    echo -e "${BLUE}   Bash scripts, markdown docs, and backup files are skipped to avoid false positives${NC}"
    echo -e "${BLUE}   Environment variables like password=os.getenv('PASSWORD') are safe and allowed${NC}"
else
    echo -e "${RED}❌ Hardcoded secrets detected! These must be fixed before committing.${NC}"
    echo ""
    echo -e "${YELLOW}Problematic lines found:${NC}"
    echo -e "$SECRET_FILES"
    echo ""
    if [ "$AUTO_MODE" = false ]; then
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
            echo "3. Then run: git add <fixed-files> && ./sync-to-github.sh again"
            echo ""
            exit 1
        fi
    else
        echo -e "${RED}AUTO MODE: Cannot continue with hardcoded secrets!${NC}"
        echo ""
        echo -e "${YELLOW}To fix the secrets:${NC}"
        echo "1. Replace hardcoded values with environment variables:"
        echo "   BAD:  password = \"secret123\""
        echo "   GOOD: password = os.getenv('PASSWORD')"
        echo ""
        echo "2. Or use .env files for local development"
        echo "3. Then run this script again"
        echo ""
        exit 1
    fi
fi
echo ""

# Step 6: Create commit
echo -e "${YELLOW}Step 6: Creating commit${NC}"
echo "-----------------------"

# Get commit message from user or generate a default
if [ "$AUTO_MODE" = false ]; then
    echo "Enter a commit message (or press Enter for auto-generated message):"
    read -r USER_COMMIT_MESSAGE
else
    USER_COMMIT_MESSAGE=""
    echo "Auto mode: Using auto-generated commit message"
fi

if [ -z "$USER_COMMIT_MESSAGE" ]; then
    # Auto-generate commit message based on changed files
    CHANGED_FILES=$(git diff --cached --name-only)
    FILE_COUNT=$(echo "$CHANGED_FILES" | wc -l)

    # Categorize changes
    DOC_CHANGES=$(echo "$CHANGED_FILES" | grep -E "\.(md|txt)$" | wc -l)
    CODE_CHANGES=$(echo "$CHANGED_FILES" | grep -E "\.(py|js|html|css|sh)$" | wc -l)
    CONFIG_CHANGES=$(echo "$CHANGED_FILES" | grep -E "(docker-compose|\.yml|\.yaml|\.conf|\.service)$" | wc -l)

    # Generate appropriate commit message
    if [ "$DOC_CHANGES" -gt "$CODE_CHANGES" ] && [ "$DOC_CHANGES" -gt "$CONFIG_CHANGES" ]; then
        COMMIT_MESSAGE="docs: Update documentation and guides"
    elif [ "$CONFIG_CHANGES" -gt "$CODE_CHANGES" ] && [ "$CONFIG_CHANGES" -gt "$DOC_CHANGES" ]; then
        COMMIT_MESSAGE="config: Update configuration and deployment files"
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

if [ "$DRY_RUN" = false ]; then
    git commit -m "$COMMIT_MESSAGE"
    echo -e "${GREEN}✅ Commit created${NC}"
else
    echo -e "${BLUE}[DRY RUN] Would create commit with message: \"$COMMIT_MESSAGE\"${NC}"
fi
echo ""

# Capture the commit hash just created
if [ "$DRY_RUN" = false ]; then
    COMMIT_HASH=$(git rev-parse --short HEAD 2>/dev/null || true)
    if [ -n "$COMMIT_HASH" ]; then
        COMMIT_URL="https://github.com/lukejmorrison/yt-dlp-wizwam/commit/$COMMIT_HASH"
        echo -e "${BLUE}🔖 Commit created: ${GREEN}$COMMIT_HASH${NC}"
        echo -e "${BLUE}🔗 View commit: ${GREEN}$COMMIT_URL${NC}"
        echo ""
    fi
fi

# Step 7: Show commit info
echo -e "${YELLOW}Step 7: Commit summary${NC}"
echo "----------------------"
if [ "$DRY_RUN" = false ]; then
    git show --stat HEAD
else
    echo -e "${BLUE}[DRY RUN] Changes that would be committed:${NC}"
    git diff --cached --stat
fi
echo ""

# Step 8: Ask before pushing
echo -e "${YELLOW}Step 8: Ready to push to GitHub${NC}"
echo "--------------------------------"

# Detect current branch
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
echo -e "${BLUE}Remote: origin${NC}"
echo -e "${BLUE}Branch: ${CURRENT_BRANCH}${NC}"
echo ""

if [ "$DRY_RUN" = true ]; then
    echo -e "${BLUE}[DRY RUN] Would push to origin/${CURRENT_BRANCH}${NC}"
    echo ""
    echo -e "${GREEN}✅ DRY RUN COMPLETE - No changes were made${NC}"
    exit 0
fi

if [ "$AUTO_MODE" = false ]; then
    read -p "Push to GitHub now? (y/n) " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}Commit created but not pushed.${NC}"
        echo "To push later, run: git push origin ${CURRENT_BRANCH}"
        exit 0
    fi
else
    echo "Auto mode: Pushing to GitHub automatically..."
fi

# Step 9: Push to GitHub
echo -e "${YELLOW}Step 9: Pushing to GitHub${NC}"
echo "-------------------------"
git push origin ${CURRENT_BRANCH}

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
        PUSHED_COMMIT_URL="https://github.com/lukejmorrison/yt-dlp.wizwam.com/commit/$PUSHED_COMMIT_HASH"
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
        echo "No further actions required unless you want to create a GitHub Release page. To view the release page:" 
        echo "   https://github.com/lukejmorrison/yt-dlp.wizwam.com/releases"
    else
        echo ""
        echo -e "${YELLOW}📝 ACTION REQUIRED:${NC}"
        echo "  You should create a release tag for the current version to keep tags in sync. Exact command:"
        echo ""
        echo -e "  ${GREEN}git tag -a $CURRENT_VERSION -m 'Release $CURRENT_VERSION' && git push origin $CURRENT_VERSION${NC}"
        echo ""
        echo "  After tagging, you can create a GitHub Release using the web UI:" 
        echo "   https://github.com/lukejmorrison/yt-dlp.wizwam.com/releases/new?tag=$CURRENT_VERSION"
    fi
    echo ""
    echo -e "${BLUE}� GitHub Repository:${NC}"
    echo -e "  ${GREEN}https://github.com/lukejmorrison/yt-dlp.wizwam.com${NC}"
    echo ""
    echo ""
else
    echo -e "${RED}❌ Push failed!${NC}"
    echo "You may need to:"
    echo "1. Check your network connection"
    echo "2. Verify GitHub credentials"
    echo "3. Pull latest changes first: git pull origin main"
    exit 1
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${BLUE}💾 Backup Info:${NC}"
echo -e "  Branch: ${GREEN}$BACKUP_BRANCH${NC}"
echo -e "  Rollback: ${YELLOW}git checkout $BACKUP_BRANCH${NC}"
echo ""
