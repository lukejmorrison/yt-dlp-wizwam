#!/usr/bin/env bash
set -euo pipefail

# Quick helper: verify SSH auth to github, run github-upload.sh (stages/commits), then push
# Usage: ./scripts/push-with-ssh-check.sh [branch]

branch=${1:-$(git rev-parse --abbrev-ref HEAD)}
remote_ssh="git@github.com:lukejmorrison/yt-dlp-wizwam.git"

echo "▶️  Checking current branch: ${branch}"

# Check for .git
if [[ ! -d .git ]]; then
  echo "❌ Not a git repository. Run this from the repo root." >&2
  exit 1
fi

# Test SSH agent/auth
echo "▶️  Testing SSH authentication to GitHub (git@github.com)..."
if ssh -T git@github.com 2>&1 | tee /dev/stderr | grep -q "successfully authenticated"; then
  echo "✅ SSH authentication OK"
else
  echo "⚠️  SSH test did not show successful authentication. Please ensure your SSH key is added to GitHub and loaded into ssh-agent." >&2
  echo "Run: ssh-add ~/.ssh/id_ed25519 (or the path to your key)" >&2
  exit 2
fi

# Run upload script to stage & commit
if [[ -x scripts/github-upload.sh ]]; then
  echo "▶️  Running scripts/github-upload.sh to stage & commit changes"
  ./scripts/github-upload.sh
else
  echo "⚠️  scripts/github-upload.sh not found or not executable. Run: chmod +x scripts/github-upload.sh" >&2
  exit 3
fi

# Push
echo "▶️  Pushing ${branch} to ${remote_ssh}"
git push ${remote_ssh} ${branch}

echo "✅ Push complete. Verify repository on GitHub."