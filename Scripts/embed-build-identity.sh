#!/bin/sh
set -eu

project_root="${SRCROOT:?}"
built_plist="${TARGET_BUILD_DIR:?}/${INFOPLIST_PATH:?}"

git_commit="$(git -C "$project_root" rev-parse HEAD)"
git_branch="$(git -C "$project_root" branch --show-current)"
if [ -z "$git_branch" ]; then
  git_branch="detached"
fi

if git -C "$project_root" status --porcelain --untracked-files=no | grep -q .; then
  tracked_files_dirty=true
else
  tracked_files_dirty=false
fi

build_date="$(date -u '+%Y-%m-%dT%H:%M:%SZ')"
fingerprint_file="${DERIVED_FILE_DIR:?}/SamadhiSourceFingerprint.txt"
if [ ! -s "$fingerprint_file" ]; then
  printf 'Missing source fingerprint captured before compilation: %s\n' "$fingerprint_file" >&2
  exit 1
fi
source_fingerprint="$(cat "$fingerprint_file")"
plist_buddy=/usr/libexec/PlistBuddy

set_string() {
  key="$1"
  value="$2"
  "$plist_buddy" -c "Delete :$key" "$built_plist" 2>/dev/null || true
  "$plist_buddy" -c "Add :$key string $value" "$built_plist"
}

set_bool() {
  key="$1"
  value="$2"
  "$plist_buddy" -c "Delete :$key" "$built_plist" 2>/dev/null || true
  "$plist_buddy" -c "Add :$key bool $value" "$built_plist"
}

set_string SamadhiGitCommit "$git_commit"
set_string SamadhiGitBranch "$git_branch"
set_bool SamadhiTrackedFilesDirty "$tracked_files_dirty"
set_string SamadhiBuildDate "$build_date"
set_string SamadhiSourceFingerprint "$source_fingerprint"
