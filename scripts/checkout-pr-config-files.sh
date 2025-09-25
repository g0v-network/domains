#!/bin/bash
set -euo pipefail

# Extract PR config files for planning
# Usage: checkout-pr-config-files.sh <pr_head_sha> <pr_number>

PR_HEAD_SHA="$1"
PR_NUMBER="$2"

# Set $_sha to the first 7 char of PR head SHA
_sha="$(echo "$PR_HEAD_SHA" | cut -c 1-7)"
echo "Processing PR head commit: $_sha"

# Fetch PR head commit
git fetch origin refs/pull/$PR_NUMBER/head

# List changed config files in PR head (handle case where no YAML files exist)
_files="$(git diff --name-only HEAD $_sha | grep "\.yaml$" || true)"

if [ -z "$_files" ]; then
  echo "No YAML files changed in this PR"
  echo "::set-output name=sha::${_sha}"
  exit 0
fi

echo "Changed YAML files: $_files"

# Separate added/modified files from deleted files
_existing_files=""
_deleted_files=""
for file in $_files; do
  # Security: Only allow files matching expected patterns
  if [[ ! "$file" =~ ^[a-zA-Z0-9._-]+\.domain/[a-zA-Z0-9._-]+\.yaml$ ]] && [[ "$file" != ".github/config-plan-amendment.yml" ]]; then
    echo "Warning: Skipping file with unexpected pattern: $file"
    continue
  fi
  
  if git cat-file -e "$_sha:$file" 2>/dev/null; then
    _existing_files="$_existing_files $file"
  else
    _deleted_files="$_deleted_files $file"
  fi
done

# Checkout only existing config files from PR head commit
if [ -n "$_existing_files" ]; then
  echo "Checking out files: $_existing_files"
  git checkout "$_sha" -- $_existing_files
fi

# Remove deleted files from working directory if they exist
if [ -n "$_deleted_files" ]; then
  for file in $_deleted_files; do
    if [ -f "$file" ]; then
      echo "Removing deleted file: $file"
      rm "$file"
    fi
  done
fi

# Set output 'sha' to $_sha
echo "::set-output name=sha::${_sha}"