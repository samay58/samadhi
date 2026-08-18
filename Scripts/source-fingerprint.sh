#!/bin/sh
set -eu

project_root="${1:-${SRCROOT:-$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)}}"

collect_inputs() {
  for path in \
    App \
    Resources \
    Packages/SamadhiKit/Sources \
    Config \
    project.yml \
    Samadhi.xcodeproj/project.pbxproj \
    Packages/SamadhiKit/Package.swift \
    Packages/SamadhiKit/Package.resolved \
    Scripts/capture-source-fingerprint.sh \
    Scripts/embed-build-identity.sh \
    Scripts/source-fingerprint.sh
  do
    if [ -f "$project_root/$path" ]; then
      printf '%s\n' "$project_root/$path"
    elif [ -d "$project_root/$path" ]; then
      find "$project_root/$path" -type f
    fi
  done
}

collect_inputs \
  | LC_ALL=C sort \
  | while IFS= read -r file; do
      relative_path=${file#"$project_root"/}
      content_hash=$(shasum -a 256 "$file" | awk '{print $1}')
      printf '%s\t%s\n' "$relative_path" "$content_hash"
    done \
  | shasum -a 256 \
  | awk '{print $1}'
