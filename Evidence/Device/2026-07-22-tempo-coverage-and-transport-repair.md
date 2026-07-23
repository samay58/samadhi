# Tempo coverage and transport repair

## Environment

- Date: 2026-07-22 America/New_York
- Device source: Samay's iPhone 17 Pro on iOS 27.0
- Selected collection: private Apple Music playlist metadata pulled from the app container
- Privacy boundary: song titles, artists, catalog identifiers, and the selected collection file remain outside git
- Selected collection SHA-256: `0042a57548e8bc182602115ab1a80d2f97c0675590ab1194363875ba2efd2594`

## Coverage result

The current selection contains 18 tracks. Two fail strict catalog resolution and have no preview to analyze. Sixteen preview-available tracks were replayed locally through the production estimator.

| Analysis state | Ready | Rhythm unclear | Catalog unavailable |
| --- | ---: | ---: | ---: |
| Prior persisted analysis | 11 | 5 | 2 |
| Version 3 | 10 | 6 | 2 |
| Version 4 replay | 14 | 2 | 2 |

Version 3 lost one track that the prior estimator accepted because it searched only the 120 through 210 BPM running range. Version 4 recovered four version-3 rejections without losing any version-3 ready track. The repaired analyzer separates the measured musical pulse from an independently supported alternate stride pulse. It does not invent a doubled pulse or change the displayed musical BPM through silent multiplication.

The public version-4 corpus passed 12 of 12 exact musical-pulse references within 2 percent. Its committed JSON checksum is `ba8fff26bd88199fbaab6e400f3ca0c449927f8d6e88db91e2838556557bb9fc`. The two 180 BPM references measured 180.75 and 181.25 BPM, so the earlier 89.5-versus-180 false-pulse failure did not return.

## Former song-switch trigger

A direct wheel change set `immediateTrackSelectionID`. When asynchronous preparation later produced `nextTrackPrepared`, the reducer emitted `skipTrack`. One large change or several rapid changes could therefore replace the song at an invisible, timing-dependent moment. Stable Auto incompatibility also had a separate five-second preparation path, leaving two conflicting transport rules.

## Repaired contract

- Manual and Auto change only the current song's bounded playback rate.
- An unreachable request remains visible while the current song uses the nearest rate inside 0.90 through 1.10.
- Candidate preparation coalesces to the latest target and selection identity.
- Preparation never commits transport.
- Explicit Skip or a player-confirmed natural boundary may commit the latest prepared candidate.
- Song identity, progress, and applied rate remain player-confirmed truth.

## Automated evidence

The final serial gate covers a large Manual target, rapid Manual targets, a sustained Auto mismatch, stale selection work, explicit Skip, player-confirmed track change, requested and achievable BPM, commanded and applied rates, song identity, UI continuity, lower musical pulses, exact 180 BPM, silence, irregular rhythm, and triple-meter ambiguity.

## Physical boundary

This replay proves coverage against the current private previews and proves transition behavior deterministically. The repair passed an exact-profile signed device build, but the paired iPhone was unavailable at 2026-07-22 21:40 EDT, so installation was not claimed. The app still needs one reimport to confirm the projected 14 ready tracks on device. During one short playback, several large wheel changes must keep the same song until explicit Skip or its natural boundary.
