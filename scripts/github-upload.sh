#!/usr/bin/env bash
set -euo pipefail

if [[ ! -d .git ]]; then
    echo "❌ This script must be run from the root of a Git repository." >&2
    exit 1
fi

if ! git remote >/dev/null 2>&1; then
    echo "⚠️  No git remotes configured. Add one with 'git remote add origin <URL>'." >&2
fi

echo "▶️  Running safety checks..."

if git status --short | grep -q "."; then
    echo "ℹ️  Uncommitted changes detected."
else
    echo "✅ Working tree clean."
fi

if git status --short --untracked-files=all | grep -E "(^\?\?\s+.*\.env|^\?\?\s+.*config_local\.py)" >/dev/null; then
    echo "❌ Potential sensitive files detected (.env or config_local.py)." >&2
    exit 1
fi

if [[ -f .git/config ]] && ! git remote | grep -q origin; then
    echo "⚠️  Remote 'origin' is not set."
fi

default_branch="$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@' || true)"
if [[ -z "$default_branch" ]]; then
    default_branch="main"
fi

echo "Current branch: $(git rev-parse --abbrev-ref HEAD)"
echo "Default remote branch (if configured): ${default_branch}"

echo "▶️  Staging all tracked changes..."
git add -A

echo "Current status:"
git status -sb

default_message="chore: initial project upload"
read -rp "Commit message [${default_message}]: " message
message=${message:-$default_message}

git commit --allow-empty -m "$message"

echo "▶️  Ready to push. Run the following command manually once credentials are configured:"
remote="$(git remote get-url origin 2>/dev/null || echo 'origin')"
branch="$(git rev-parse --abbrev-ref HEAD)"
echo "    git push ${remote} ${branch}"
