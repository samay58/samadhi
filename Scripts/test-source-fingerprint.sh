#!/bin/sh
set -eu

project_root=$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)
fixture_root=$(mktemp -d "${TMPDIR:-/tmp}/samadhi-source-fingerprint.XXXXXX")
trap 'rm -rf "$fixture_root"' EXIT

mkdir -p \
  "$fixture_root/App" \
  "$fixture_root/Resources" \
  "$fixture_root/Packages/SamadhiKit/Sources" \
  "$fixture_root/Packages/SamadhiKit" \
  "$fixture_root/Config" \
  "$fixture_root/Samadhi.xcodeproj" \
  "$fixture_root/Scripts" \
  "$fixture_root/Docs" \
  "$fixture_root/Evidence"

printf 'app source\n' > "$fixture_root/App/Main.swift"
printf 'resource\n' > "$fixture_root/Resources/asset.txt"
printf 'package source\n' > "$fixture_root/Packages/SamadhiKit/Sources/Domain.swift"
printf 'package manifest\n' > "$fixture_root/Packages/SamadhiKit/Package.swift"
printf 'plist\n' > "$fixture_root/Config/App.plist"
printf 'project yaml\n' > "$fixture_root/project.yml"
printf 'generated project\n' > "$fixture_root/Samadhi.xcodeproj/project.pbxproj"
printf 'capture script\n' > "$fixture_root/Scripts/capture-source-fingerprint.sh"
printf 'embed script\n' > "$fixture_root/Scripts/embed-build-identity.sh"
printf 'fingerprint script\n' > "$fixture_root/Scripts/source-fingerprint.sh"

fingerprint() {
  "$project_root/Scripts/source-fingerprint.sh" "$fixture_root"
}

initial=$(fingerprint)
[ "$initial" = "$(fingerprint)" ]

printf 'changed app source\n' > "$fixture_root/App/Main.swift"
changed=$(fingerprint)
[ "$changed" != "$initial" ]

printf 'app source\n' > "$fixture_root/App/Main.swift"
[ "$(fingerprint)" = "$initial" ]

printf 'untracked resource\n' > "$fixture_root/Resources/new.txt"
with_untracked_input=$(fingerprint)
[ "$with_untracked_input" != "$initial" ]
rm "$fixture_root/Resources/new.txt"
[ "$(fingerprint)" = "$initial" ]

printf 'private diagnostics\n' > "$fixture_root/Evidence/run.json"
printf 'unrelated documentation\n' > "$fixture_root/Docs/note.md"
[ "$(fingerprint)" = "$initial" ]

printf 'changed project\n' > "$fixture_root/project.yml"
[ "$(fingerprint)" != "$initial" ]

printf 'source fingerprint tests passed\n'
