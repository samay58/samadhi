# Latest-run diagnostics test build

Date: 2026-07-20

Base commit: `ecc79d44a550812fc7a89096f73f29b6e47b5e2d`

Device: Samay's iPhone 17 Pro (`iPhone18,1`)

OS: iOS 27.0 (`24A5380h`)

Bundle: `com.samaydhawan.Samadhi`

Signing profile: `Samadhi Development`

Profile UUID: `f7dc2163-4562-4849-90ba-1f49d14ce03a`

Profile expiry: 2026-07-23 03:54:43 UTC

## Result

The debug build containing automatic latest-run diagnostics compiled and signed for the physical iPhone with the exact App ID profile. `devicectl` installed it successfully while the phone was locked.

The existing selected playlist survived the app update byte-for-byte:

- Before install SHA-256: `dd4a68603d20c8fd1fa1edb0efb439470bbeaaaf2bf964aa7d786a3f2b89e96a`
- After install SHA-256: `dd4a68603d20c8fd1fa1edb0efb439470bbeaaaf2bf964aa7d786a3f2b89e96a`

The refreshed build was not launched because iOS denied foreground launch while the device was locked. `latest-run-diagnostics.json` will appear only after a completed run on this build.

## Automated gate

- Formatter lint: passed
- Swift package tests: 48 passed
- App-model tests: 9 passed
- UI tests: 8 passed
- Exact-profile physical build: passed
- Physical installation: passed
- Foreground launch: blocked by device lock
