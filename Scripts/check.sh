#!/bin/sh
# The fast loop. Runs only the tests that the changes since a base commit can affect, usually in
# seconds. It does not replace the gate, which still runs before a phone install or a push to main.
# Usage: ./Scripts/check.sh [base], where base defaults to the current commit, so uncommitted work.
set -eu
. "$(dirname "$0")/lib.sh"

base=${1:-HEAD}
changed=$( { git diff --name-only "$base"; git ls-files --others --exclude-standard; } | sort -u)

if [ -z "$changed" ]; then
  echo "Nothing has changed since $base."
  exit 0
fi

matches() {
  echo "$changed" | grep -Eq "$1"
}

package=false
screens=false
interface=false
matches '^Packages/SamadhiKit/(Sources|Tests|Tools|Package)' && package=true
matches '^(Packages/SamadhiKit/Sources/SamadhiDesign|App|Resources|Config|project.yml|Tests/SamadhiTests)' && screens=true
matches '^Tests/SamadhiUITests' && interface=true

if ! $package && ! $screens && ! $interface; then
  echo "Only docs or other files changed, so there is nothing to test."
  exit 0
fi

if matches '\.swift$'; then
  lint_output=$(xcrun swift-format lint --configuration .swift-format --recursive \
    App Packages/SamadhiKit/Sources Packages/SamadhiKit/Tests Tests 2>&1) || true
  if [ -n "$lint_output" ]; then
    echo "$lint_output" >&2
    exit 1
  fi
  echo "Formatter lint passed."
fi

if $package; then
  # GitHub's older compiler gives up on expressions that this one accepts, so catch them here.
  slow=$(swift build --package-path Packages/SamadhiKit --scratch-path .build/typecheck \
    -Xswiftc -Xfrontend -Xswiftc -warn-long-expression-type-checking=500 2>&1 |
    grep "expression took" || true)
  if [ -n "$slow" ]; then
    echo "$slow" >&2
    echo "Split these expressions. GitHub's older compiler can fail on them." >&2
    exit 1
  fi
  swift test --package-path Packages/SamadhiKit
fi

if $screens; then
  ensure_simulator
  xcodebuild_serial test -scheme Samadhi -destination "$simulator_destination" \
    -only-testing:SamadhiTests -quiet
fi

if $interface; then
  ensure_simulator
  xcodebuild_interface_tests -scheme Samadhi -destination "$simulator_destination" \
    -only-testing:SamadhiUITests -quiet
fi

echo "Check passed: package $package, screens $screens, interface $interface."
