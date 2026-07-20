# Current main install and playlist restoration

Date: 2026-07-20

- Device: Samay's iPhone 17 Pro
- OS: iOS 27.0, build 24A5380h
- CoreDevice: `74BE85BB-5455-56FE-BFA3-0150F3A28C43`
- Source commit: `7de5bd42ee5fc830f8e1261655cee7e5e9cfc98d`
- Profile: `Samadhi Development`
- Profile UUID: `f7dc2163-4562-4849-90ba-1f49d14ce03a`
- Profile expiry: 2026-07-23 03:54:43 UTC
- Application identifier: `ZL5U59XBJ6.com.samaydhawan.Samadhi`

## Result

A clean detached worktree at current `main` built successfully for a generic iPhone with manual exact-profile signing. `devicectl` installed the app over the existing `com.samaydhawan.Samadhi` installation, launched it, and confirmed the process was running.

The selected collection survived the update byte-for-byte. Its persisted record still contains 25 tracks: 13 ready, 8 unreadable, and 4 unavailable.

- Selected collection before install SHA-256: `dd4a68603d20c8fd1fa1edb0efb439470bbeaaaf2bf964aa7d786a3f2b89e96a`
- Selected collection after install SHA-256: `dd4a68603d20c8fd1fa1edb0efb439470bbeaaaf2bf964aa7d786a3f2b89e96a`
- Physical ready-screen capture SHA-256: `66e305eefee66a036ea7aa61f64e6add7f5ecab1970a17cad6ec81944abe38a5`

The normal ready screen rendered the restored collection and the correct 13-of-25 ready count without reimport. This closes the relaunch-restoration check.

The existing schema-version-2 latest-run trace was also pulled directly from the app container. It records the same 13-ready-track collection and real production-player progress from 0 through 6 seconds on one stable catalog identity. The run ended before cadence lock, so active duration remained zero and no tempo-match claim was made.

- Latest-run trace SHA-256: `b3158be977803c937c080603922a62ae62eda436681d587472bb4bb48f51f92c`

The raw screenshot and trace contain personal library metadata and are not committed. Their checksums and privacy-safe results are retained here.

## Open physical proof

This evidence does not prove cadence-driven BPM control, a natural track transition, listening quality, locked-screen continuity, interruption, or route-loss recovery. Those remain physical gates.
