#!/bin/sh
set -eu
cd "$(dirname "$0")/.."
swift test --package-path Packages/InStepKit
xcodebuild test \
  -project InStep.xcodeproj \
  -scheme InStep \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=latest' \
  CODE_SIGNING_ALLOWED=NO

