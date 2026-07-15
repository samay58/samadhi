#!/bin/sh
set -eu
cd "$(dirname "$0")/.."
if [ -z "${DEVELOPER_DIR:-}" ] && [ -d /Applications/Xcode-beta.app/Contents/Developer ]; then
  export DEVELOPER_DIR=/Applications/Xcode-beta.app/Contents/Developer
fi
swift test --package-path Packages/SamadhiKit
xcodebuild test \
  -project Samadhi.xcodeproj \
  -scheme Samadhi \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=latest' \
  -parallel-testing-enabled NO \
  CODE_SIGNING_ALLOWED=NO
