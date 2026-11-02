#!/bin/sh
# The physical loop. Installs in place and never uninstalls, because the phone holds the only copy
# of the selected collection and analysis cache.
set -eu
. "$(dirname "$0")/lib.sh"

usage() {
  cat >&2 <<'TEXT'
Usage: ./Scripts/phone.sh <command>

  status            Show whether the phone is reachable and whether signing is ready
  install           Build with the exact profile, verify it, and install in place
  launch [args]     Launch the installed app, for example --core-diagnostics
  screenshot <name> Capture the phone's screen
  pull              Save every run record from the phone and summarize the latest
TEXT
  exit 2
}

bundle_id=com.samaydhawan.Samadhi
application_id=ZL5U59XBJ6.com.samaydhawan.Samadhi
collection_path="Library/Application Support/Samadhi/selected-music.json"
record_directory="Library/Application Support/Samadhi"
output_dir="$scratch/phone"
# Outside the repository, because these are personal and must survive a fresh clone.
run_archive=${SAMADHI_RUN_ARCHIVE:-$HOME/Documents/Samadhi Run Records}
app_path="$derived_data/Build/Products/Debug-iphoneos/Samadhi.app"

device_list=$(mktemp "${TMPDIR:-/tmp}/samadhi-devices.XXXXXX")
trap 'rm -f "$device_list"' EXIT

device_field() {
  xcrun devicectl list devices --quiet --json-output "$device_list" >/dev/null 2>&1
  python3 - "$device_list" "$1" <<'PY'
import json, sys
devices = json.load(open(sys.argv[1]))["result"]["devices"]
phones = [d for d in devices
          if d["hardwareProperties"].get("reality") == "physical"
          and d["hardwareProperties"].get("deviceType") == "iPhone"]
if not phones:
    sys.exit("No paired iPhone. Connect it by cable once, or set SAMADHI_DEVICE.")
print({"id": phones[0]["identifier"],
       "udid": phones[0]["hardwareProperties"].get("udid", ""),
       "state": phones[0]["connectionProperties"].get("tunnelState", "unknown"),
       "name": phones[0]["deviceProperties"].get("name", "iPhone")}[sys.argv[2]])
PY
}

device_id() {
  if [ -n "${SAMADHI_DEVICE:-}" ]; then
    echo "$SAMADHI_DEVICE"
  else
    device_field id
  fi
}

# Prints the newest unexpired development profile for the exact App ID, as "name<TAB>expiry".
exact_profile() {
  python3 - "$application_id" <<'PY'
import datetime, glob, os, plistlib, subprocess, sys
wanted = sys.argv[1]
home = os.path.expanduser("~/Library")
paths = (glob.glob(home + "/Developer/Xcode/UserData/Provisioning Profiles/*.mobileprovision")
         + glob.glob(home + "/MobileDevice/Provisioning Profiles/*.mobileprovision"))
best = None
for path in paths:
    raw = subprocess.run(["security", "cms", "-D", "-i", path], capture_output=True).stdout
    if not raw:
        continue
    profile = plistlib.loads(raw)
    expires = profile["ExpirationDate"].replace(tzinfo=datetime.timezone.utc)
    if profile["Entitlements"].get("application-identifier") != wanted:
        continue
    if expires <= datetime.datetime.now(datetime.timezone.utc):
        continue
    if best is None or expires > best[1]:
        best = (profile["Name"], expires)
if best:
    print(f"{best[0]}\t{best[1].date()}")
PY
}

collection_checksum() {
  copy=$(mktemp -d "${TMPDIR:-/tmp}/samadhi-collection.XXXXXX")
  if xcrun devicectl device copy from --device "$1" --domain-type appDataContainer \
    --domain-identifier "$bundle_id" --source "$collection_path" \
    --destination "$copy/selected-music.json" >/dev/null 2>&1; then
    shasum -a 256 "$copy/selected-music.json" | awk '{print $1}'
  else
    echo unreadable
  fi
  rm -rf "$copy"
}

# Copies everything the phone holds into a new dated folder and prints that folder.
save_run_records() {
  stamp=$(date +%Y-%m-%d-%H%M%S)
  destination="$run_archive/$stamp"
  mkdir -p "$run_archive"
  xcrun devicectl device copy from --device "$1" --domain-type appDataContainer \
    --domain-identifier "$bundle_id" --source "$record_directory" \
    --destination "$destination" >/dev/null
  echo "$destination"
}

[ $# -ge 1 ] || usage
command=$1
shift

case "$command" in
  status)
    if name=$(device_field name 2>/dev/null); then
      echo "Phone: $name, $(device_field state)"
    else
      echo "Phone: not paired with this Mac"
    fi
    profile=$(exact_profile)
    if [ -n "$profile" ]; then
      echo "Exact profile: $(printf '%s' "$profile" | tr '\t' ' '), expires as shown"
    else
      echo "Exact profile: missing or expired. MusicKit needs it. See Docs/DEVICE_RUNBOOK.md"
    fi
    ;;
  install)
    device=$(device_id)
    # CoreDevice names the phone by identifier, and xcodebuild names it by hardware UDID.
    udid=$(device_field udid)
    profile=$(exact_profile | cut -f1)
    if [ -z "$profile" ]; then
      echo "No unexpired profile for $application_id on this Mac. See Docs/DEVICE_RUNBOOK.md." >&2
      exit 1
    fi
    if [ -n "$(git status --porcelain -- App Packages Resources Config project.yml)" ]; then
      echo "Note: building uncommitted source. The fingerprint records it."
    fi
    xcodebuild build -project Samadhi.xcodeproj -scheme Samadhi -configuration Debug \
      -derivedDataPath "$derived_data" -destination "id=$udid" -quiet \
      CODE_SIGN_STYLE=Manual CODE_SIGN_IDENTITY="Apple Development" \
      PROVISIONING_PROFILE_SPECIFIER="$profile"

    embedded=$(security cms -D -i "$app_path/embedded.mobileprovision" \
      | plutil -extract Entitlements.application-identifier raw -o - -)
    signed=$(codesign -d --entitlements :- "$app_path" 2>/dev/null \
      | plutil -extract application-identifier raw -o - -)
    if [ "$embedded" != "$application_id" ] || [ "$signed" != "$application_id" ]; then
      echo "Signing is wrong: profile $embedded, signature $signed, need $application_id." >&2
      exit 1
    fi
    codesign --verify --strict "$app_path"

    # The phone may hold the only copy of a real outing. Never go further without saving it.
    saved=$(save_run_records "$device") || {
      echo "Could not save the run records from the phone, so nothing was installed." >&2
      exit 1
    }
    echo "Saved run records: $saved"

    before=$(collection_checksum "$device")
    xcrun devicectl device install app --device "$device" "$app_path" >/dev/null
    after=$(collection_checksum "$device")
    if [ "$before" = unreadable ] || [ "$after" = unreadable ]; then
      collection_result="could not be read, so it is unverified. Check the phone before running"
    elif [ "$before" != "$after" ]; then
      echo "The selected collection changed during install: $before to $after." >&2
      exit 1
    else
      collection_result="unchanged: $after"
    fi
    built=$(/usr/libexec/PlistBuddy -c 'Print :SamadhiSourceFingerprint' "$app_path/Info.plist")
    echo "Installed $(git rev-parse --short HEAD) with profile $profile."
    echo "Fingerprint $built. Read it back with: ./Scripts/phone.sh launch --core-diagnostics"
    echo "Selected collection $collection_result"
    ;;
  launch)
    device=$(device_id)
    xcrun devicectl device process launch --device "$device" "$bundle_id" "$@"
    ;;
  screenshot)
    [ $# -eq 1 ] || usage
    mkdir -p "$output_dir"
    device=$(device_id)
    xcrun devicectl device capture screenshot --device "$device" \
      --destination "$output_dir/$1.png" >/dev/null
    echo "$output_dir/$1.png"
    ;;
  pull)
    device=$(device_id)
    saved=$(save_run_records "$device")
    latest=$(find "$saved" -name latest-run-diagnostics.json | head -1)
    if [ -n "$latest" ]; then
      python3 Scripts/read-run.py "$latest"
    else
      echo "The phone holds no run record yet."
    fi
    echo
    echo "Raw records stay out of Git: $saved"
    ;;
  *)
    usage
    ;;
esac
