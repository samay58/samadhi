#!/bin/sh
set -eu

project_root="${SRCROOT:?}"
output_file="${DERIVED_FILE_DIR:?}/SamadhiSourceFingerprint.txt"

mkdir -p "$(dirname "$output_file")"
"$project_root/Scripts/source-fingerprint.sh" "$project_root" > "$output_file"
