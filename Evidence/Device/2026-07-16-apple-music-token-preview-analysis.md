# Apple Music token and preview analysis

Date: 2026-07-16

Device: Samay's iPhone, iPhone 17 Pro, iPhone18,1

OS: iOS 27.0, build 24A5380h

Route: Built-in speaker

Source: Apple Music library through MusicKit

Profile: `Samadhi Development`, UUID `f7dc2163-4562-4849-90ba-1f49d14ce03a`

Application identifier: `ZL5U59XBJ6.com.samaydhawan.Samadhi`

Status: Automatic token and tempo-source gates passed. Built-in-speaker listening passed provisionally. Headphone listening, background, track change, controlled interruption, and route recovery remain open. No production source decision has been made.

## Saved trace

| Trace | SHA-256 | Notes |
| --- | --- | --- |
| `2026-07-16-apple-music-token-preview-trace.json` | `44a8bbcaf8b1742131da3d30e64d5515fa6b6d116fe2d0b8b93e3ea0eca35cc3` | Exact-profile token probe, 40 playlists, strict catalog resolution, 10 of 10 locally decoded previews, playback, repeated 0.94 and 1.06 rate writes, pause, and resume |

The user export and the file pulled directly from the app data container matched byte-for-byte.

## Gate evidence

| Capability | Result | Evidence |
| --- | --- | --- |
| Exact-App-ID signing | Pass | Signed app embedded `Samadhi Development` and the exact application identifier |
| Automatic developer token | Pass | Four direct catalog probes each returned one song |
| Library authorization | Pass | Authorization returned `authorized` |
| Library loading | Pass | MusicKit loaded 40 playlists |
| Strict catalog identity | Pass for sample | All ten City Pocket tracks matched title, artist, album, and duration; every duration delta was 0.0 seconds |
| Local preview download | Pass | All ten resolved preview assets downloaded into temporary app storage |
| Decoded PCM coverage | Pass | Ten of ten previews yielded decoded PCM, above the required eight of ten |
| Real playback | Pass | The 25-track queue entered the playing state |
| Live rate writes | Pass | 0.94, 1.00, and 1.06 were accepted and reported while playing |
| Pitch-stable listening | Preliminary pass | On the built-in speaker, Samay reported no major pitch change or unpleasant artifacts, only a genuine speedup or slowdown |
| Five-minute screen-lock playback | Not proven | No five-minute locked interval was recorded |
| Track change | Not proven | No successful next-track event was recorded |
| Controlled interruption | Not proven | Session activation emitted an interruption notification, but it was not a controlled test |
| Route loss and recovery | Not proven | Every event used the built-in speaker route |

## What changed

The original wildcard-profile build could authorize, load the library, and play music, but catalog calls failed before a response with `developerTokenRequestFailed`. The exact profile fixed automatic token generation.

Library tracks still expose opaque `i.*` identifiers, no ISRC, and no direct preview. MusicKit's equivalent-ID request rejects those nonnumeric identifiers. The harness therefore uses a strict catalog search and accepts a result only when title, artist, album, and duration agree. Ambiguous results fail closed. The returned numeric catalog identifier is the stable identifier to persist after resolution.

Catalog preview URLs are remote HTTPS assets. `AVAssetReader` cannot initialize directly from those URLs. The harness downloads each preview into temporary app storage, decodes the local file, and deletes it immediately. This produced ten of ten decoded previews for City Pocket.

This result proves technical feasibility for local tempo analysis. It does not prove analyzer accuracy, preview-analysis terms for public distribution, or headphone listening quality at changed playback rates.

## Listening note

Samay listened while switching between the safe-rate endpoints. He reported no major pitch change, clicks, gaps, warble, or unpleasant sound. The change sounded like a genuine speedup or slowdown. The trace confirms repeated accepted writes at 0.94 and 1.06, but every event used the iPhone speaker. Repeat the same check on a Bluetooth headphone route before passing the final listening gate.
