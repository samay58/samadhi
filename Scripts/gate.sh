#!/bin/sh
# The whole software gate. A pass means the code is ready for a phone. It says nothing about feel.
set -eu
. "$(dirname "$0")/lib.sh"

project_hash() {
  find Samadhi.xcodeproj -type f -not -path '*/xcuserdata/*' -not -path '*/project.xcworkspace/*' \
    -exec shasum -a 256 {} + | LC_ALL=C sort -k2 | shasum -a 256
}

before=$(project_hash)
./Scripts/bootstrap.sh >/dev/null
if [ "$before" != "$(project_hash)" ]; then
  echo "project.yml and Samadhi.xcodeproj disagreed. Review and commit the regenerated project." >&2
  exit 1
fi

if ! lint_output=$(xcrun swift-format lint --configuration .swift-format --recursive \
  App Packages/SamadhiKit/Sources Packages/SamadhiKit/Tests Tests 2>&1) || [ -n "$lint_output" ]; then
  echo "$lint_output" >&2
  exit 1
fi
echo "Formatter lint passed."

./Scripts/test.sh

for configuration in Debug Release; do
  xcodebuild_serial build -scheme Samadhi -configuration "$configuration" \
    -destination "$simulator_destination" -quiet
done
echo "Debug and Release builds passed."

# A Debug app keeps its code in the dylib, and its main binary is a stub that matches nothing, so
# each side needs a string known to be present before an absence means anything.
debug_binary="$derived_data/Build/Products/Debug-iphonesimulator/Samadhi.app/Samadhi.debug.dylib"
release_binary="$derived_data/Build/Products/Release-iphonesimulator/Samadhi.app/Samadhi"
for hidden in CoreLoopDiagnosticsView FeedbackAuditionView MusicKitFeasibilityView; do
  strings -a "$debug_binary" | grep -q "$hidden" || {
    echo "Control failed: $hidden is missing from Debug, so this check proves nothing." >&2
    exit 1
  }
  if strings -a "$release_binary" | grep -q "$hidden"; then
    echo "$hidden shipped in Release." >&2
    exit 1
  fi
done
strings -a "$release_binary" | grep -q RunPresentationModel || {
  echo "Control failed: Release is missing RunPresentationModel." >&2
  exit 1
}
echo "Debug-only screens are absent from Release."

echo "Software gate passed at $(git rev-parse --short HEAD), fingerprint $(./Scripts/source-fingerprint.sh)."
