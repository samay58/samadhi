#!/bin/sh
set -eu
. "$(dirname "$0")/lib.sh"
xcodegen generate
