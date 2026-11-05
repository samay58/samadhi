#!/bin/sh
# The fast visual loop. Everything it captures lands in Evidence/Temp, which Git ignores.
set -eu
. "$(dirname "$0")/lib.sh"

usage() {
  cat >&2 <<'TEXT'
Usage: ./Scripts/sim.sh <command>

  run [launch args]        Build, install, and launch the app fresh
  shot <name>              Save the current screen
  record <name> <seconds>  Record video, then split it into frames at 30 per second
  matrix <name> [args]     Launch in all six environments and build one contact sheet
  frames <test name>       Run one UI test and export every frame it attached
  flags                    List the launch arguments the Debug app understands

Examples:
  ./Scripts/sim.sh run -SAMADHI_FAST_MODE -SAMADHI_MUSIC_PARTIAL
  ./Scripts/sim.sh matrix setup-partial -SAMADHI_FAST_MODE -SAMADHI_MUSIC_PARTIAL
  ./Scripts/sim.sh frames testTransportAndFinishAfterStateEvidence
TEXT
  exit 2
}

bundle_id=com.samaydhawan.Samadhi
app_path="$derived_data/Build/Products/Debug-iphonesimulator/Samadhi.app"
output_dir="$scratch/sim"

boot() {
  ensure_simulator
  xcrun simctl bootstatus "$simulator_name" -b >/dev/null
}

build_and_install() {
  boot
  xcodebuild_serial build -scheme Samadhi -destination "$simulator_destination" -quiet
  xcrun simctl install "$simulator_name" "$app_path"
}

launch() {
  xcrun simctl terminate "$simulator_name" "$bundle_id" >/dev/null 2>&1 || true
  xcrun simctl launch "$simulator_name" "$bundle_id" "$@" >/dev/null
}

shot() {
  mkdir -p "$output_dir"
  xcrun simctl io "$simulator_name" screenshot --type=png "$output_dir/$1.png" >/dev/null 2>&1
  echo "$output_dir/$1.png"
}

[ $# -ge 1 ] || usage
command=$1
shift

case "$command" in
  run)
    build_and_install
    launch "$@"
    ;;
  shot)
    [ $# -eq 1 ] || usage
    boot
    shot "$1"
    ;;
  record)
    [ $# -eq 2 ] || usage
    boot
    mkdir -p "$output_dir/$1"
    xcrun simctl io "$simulator_name" recordVideo --codec=h264 --force "$output_dir/$1.mp4" &
    recorder=$!
    sleep "$2"
    kill -INT "$recorder"
    wait "$recorder" || true
    ffmpeg -loglevel error -y -i "$output_dir/$1.mp4" -vf fps=30 "$output_dir/$1/%04d.png"
    echo "$output_dir/$1/ holds $(find "$output_dir/$1" -name '*.png' | wc -l | tr -d ' ') frames"
    ;;
  matrix)
    [ $# -ge 1 ] || usage
    name=$1
    shift
    build_and_install
    mkdir -p "$output_dir/$name"
    while IFS='|' read -r environment arguments; do
      # Appearance is a Simulator setting rather than a launch argument, and it stays set until changed.
      if [ "$environment" = dark ]; then
        xcrun simctl ui "$simulator_name" appearance dark
      else
        xcrun simctl ui "$simulator_name" appearance light
      fi
      # shellcheck disable=SC2086
      launch "$@" $arguments
      sleep "${SAMADHI_SETTLE_SECONDS:-3}"
      xcrun simctl io "$simulator_name" screenshot --type=png \
        "$output_dir/$name/$environment.png" >/dev/null 2>&1
    done <<'MATRIX'
default|
dark|
accessibility-xxxl|-UIPreferredContentSizeCategoryName UICTContentSizeCategoryAccessibilityXXXL
reduce-motion|-UIAccessibilityReduceMotionEnabled YES
increased-contrast|-UIAccessibilityDarkerSystemColorsEnabled YES
reduced-transparency|-UIAccessibilityReduceTransparencyEnabled YES
MATRIX
    xcrun simctl ui "$simulator_name" appearance light
    magick montage "$output_dir/$name"/default.png "$output_dir/$name"/dark.png \
      "$output_dir/$name"/accessibility-xxxl.png \
      "$output_dir/$name"/reduce-motion.png "$output_dir/$name"/increased-contrast.png \
      "$output_dir/$name"/reduced-transparency.png \
      -tile 6x1 -geometry 402x874+8+8 -background '#f4efe6' "$output_dir/$name-sheet.png"
    echo "$output_dir/$name-sheet.png"
    ;;
  frames)
    [ $# -eq 1 ] || usage
    boot
    # A bare name is a tap-through test. Anything with a slash is a full test path.
    case "$1" in
      */*) target=$1 ;;
      *)
        class=$(awk -v name="$1" '/^final class /{c=$3; sub(":", "", c)} index($0, "func " name "(") {print c}' \
          Tests/SamadhiUITests/SamadhiUITests.swift)
        target="SamadhiUITests/$class/$1"
        ;;
    esac
    result_bundle="$output_dir/$(echo "$1" | tr '/()' '---').xcresult"
    mkdir -p "$output_dir"
    frames_dir="$output_dir/$(echo "$1" | tr '/()' '---')"
    rm -rf "$result_bundle" "$frames_dir"
    xcodebuild_serial test -scheme Samadhi -destination "$simulator_destination" \
      -only-testing:"$target" \
      -resultBundlePath "$result_bundle" -quiet
    xcrun xcresulttool export attachments --path "$result_bundle" --output-path "$frames_dir"
    echo "$frames_dir/"
    ;;
  flags)
    grep -hoE '"-{1,2}[A-Za-z_-]+=?"' App/SimulationConfiguration.swift App/RootView.swift \
      | tr -d '"' | sort -u
    ;;
  *)
    usage
    ;;
esac
