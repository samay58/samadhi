#!/bin/sh
set -eu
. "$(dirname "$0")/lib.sh"
ensure_simulator
./Scripts/test-source-fingerprint.sh
swift test --package-path Packages/SamadhiKit
xcodebuild_serial test -scheme Samadhi -destination "$simulator_destination" -only-testing:SamadhiTests
xcodebuild_interface_tests -scheme Samadhi -destination "$simulator_destination" -only-testing:SamadhiUITests
