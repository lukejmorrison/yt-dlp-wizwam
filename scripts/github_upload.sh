#!/usr/bin/env bash
# Upload the current repository state to GitHub with a single command.
# Usage:
#   ./scripts/github_upload.sh "commit message here"
# If no commit message is supplied, a descriptive default is used.

set -euo pipefail

if ! command -v git >/dev/null 2>&1; then
  echo "❌ git is not installed or not in PATH" >&2
  exit 1
fi

if ! git rev-parse --git-dir >/dev/null 2>&1; then
  echo "❌ This script must be run inside a Git repository" >&2
  exit 1
fi

REPO_ROOT="$(git rev-parse --show-toplevel)"
cd "${REPO_ROOT}" || exit 1

# Basic sanity checks before uploading
echo "🔍 Running pre-push checks..."
if [ -f "pyproject.toml" ]; then
  if command -v python >/dev/null 2>&1; then
    python -m compileall yt_dlp_wizwam >/dev/null 2>&1 || {
      echo "❌ Python bytecode compilation failed" >&2
      exit 1
    }
  fi
fi

if command -v python >/dev/null 2>&1 && [ -f "test_config.py" ]; then
  python -m compileall test_config.py >/dev/null 2>&1 || true
fi

if ! git status --short >/dev/null; then
  echo "❌ git status failed" >&2
  exit 1
fi

if [ -z "$(git status --porcelain)" ]; then
  echo "ℹ️  Nothing to commit. Working tree clean."
  exit 0
fi

COMMIT_MSG=${1:-"chore: sync repository"}

echo "➕ Staging all changes..."
git add -A

if [ -z "$(git diff --cached --name-only)" ]; then
  echo "ℹ️  No staged changes after git add. Exiting without commit."
  exit 0
fi

echo "📝 Creating commit: ${COMMIT_MSG}"
git commit -m "${COMMIT_MSG}"

if ! git remote get-url origin >/dev/null 2>&1; then
  echo "❌ No 'origin' remote is configured. Please run:"
  echo "    git remote add origin git@github.com:lukejmorrison/yt-dlp-wizwam.git"
  echo "    # or use https://github.com/lukejmorrison/yt-dlp-wizwam.git"
  exit 1
fi

echo "🚀 Pushing to origin/main..."
git push origin main

echo "✅ Push complete."
