# Shared by every script here. Sourced, not run.

project_root=$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)
cd "$project_root"

# An explicit DEVELOPER_DIR wins, then the selected Xcode. Command Line Tools cannot build for iOS,
# so a machine selecting them falls back to whichever Xcode is installed.
if [ -z "${DEVELOPER_DIR:-}" ]; then
  selected=$(xcode-select -p 2>/dev/null || true)
  case "$selected" in
    *.app/Contents/Developer)
      export DEVELOPER_DIR="$selected"
      ;;
    *)
      for candidate in /Applications/Xcode.app /Applications/Xcode-beta.app; do
        if [ -d "$candidate/Contents/Developer" ]; then
          export DEVELOPER_DIR="$candidate/Contents/Developer"
          break
        fi
      done
      ;;
  esac
fi

simulator_name=${SAMADHI_SIMULATOR:-iPhone 17 Pro}
simulator_destination="platform=iOS Simulator,name=$simulator_name,OS=latest"
derived_data=.build/xcode
scratch=Evidence/Temp

# Serial on purpose: the iOS 27 Simulator can terminate concurrent UI test runners.
xcodebuild_serial() {
  xcodebuild "$@" \
    -project Samadhi.xcodeproj \
    -derivedDataPath "$derived_data" \
    -parallel-testing-enabled NO \
    CODE_SIGNING_ALLOWED=NO
}

ensure_simulator() {
  if ! xcrun simctl list devices available | grep -q "^ *$simulator_name ("; then
    type_id=$(xcrun simctl list devicetypes | sed -n "s/^$simulator_name (\(.*\))$/\1/p")
    runtime_id=$(xcrun simctl list runtimes available | sed -n 's/.* - \(com\.apple\.CoreSimulator\.SimRuntime\.iOS-.*\)$/\1/p' | tail -1)
    xcrun simctl create "$simulator_name" "$type_id" "$runtime_id" >/dev/null
  fi
}
