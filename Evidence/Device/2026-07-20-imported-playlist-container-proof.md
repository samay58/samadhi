# Imported playlist container proof

Capture date: 2026-07-20

Persisted selection date: 2026-07-16 17:01:03 EDT

Device: Samay's iPhone 17 Pro (`iPhone18,1`)

OS: iOS 27.0 (`24A5380h`)

Source: Apple Music

Collection: `Strut Frequency -- July 2026`

Route: Not applicable. This check covers import and local analysis, not listening.

## Result

Samadhi's Xcode-installed app container was available through `devicectl`. The persisted `selected-music.json` file contained one real 25-track Apple Music collection:

- 13 adaptive-ready tracks
- 8 tracks rejected as `couldNotReadTempo`
- 4 unavailable tracks
- 20 cached tempo analyses

The three-ready-track threshold passed. Failures remained explicit instead of entering the playback queue.

Persisted file SHA-256: `dd4a68603d20c8fd1fa1edb0efb439470bbeaaaf2bf964aa7d786a3f2b89e96a`

Raw library metadata was inspected locally and was not copied into the repository.

## Method

~~~sh
xcrun devicectl device copy from \
  --device 74BE85BB-5455-56FE-BFA3-0150F3A28C43 \
  --domain-type appDataContainer \
  --domain-identifier com.samaydhawan.Samadhi \
  --source Library \
  --destination /tmp/samadhi-device-library
~~~

## Open proof

A terminate-and-relaunch attempt was denied because the iPhone was locked. This capture proves real selection, local analysis, the ready-track threshold, and durable storage. It does not yet prove UI restoration after relaunch, playback progress, a natural track transition, or cadence-driven adaptation in the imported run.
