# Apple Music trace analysis

Date: 2026-07-15

Device: Samay's iPhone, iPhone 17 Pro, iPhone18,1

OS: iOS 27.0, build 24A5380h

Route: Built-in speaker

Source: Apple Music library through MusicKit

Status: Historical blocked snapshot. Superseded by [2026-07-16-apple-music-token-preview-analysis.md](2026-07-16-apple-music-token-preview-analysis.md), where exact-profile signing fixed automatic token generation and ten of ten previews decoded locally. No production source decision has been made.

## Saved traces

| Trace | SHA-256 | Notes |
| --- | --- | --- |
| `2026-07-15-apple-music-trace-1.json` | `9609a2058ad6f133c7f81e1c70be21c0bd2ca5df51c4d8eda288a8a70fa1af4a` | Authorization, library loading, and initial preview checks |
| `2026-07-15-apple-music-trace-2.json` | `7b061b977998e7cf701febdf4612920ad88d4123ee479e5d65571512b776c823` | Playback, live rate writes, pause, resume, and more preview checks |
| `2026-07-15-apple-music-trace-3.json` | `a5a460aca8273c1f58b1310c3455b5881302f4e6303d56075d44f2f2b562b93a` | Independent playback and preview repetition from the original harness |
| `2026-07-15-apple-music-trace-4.json` | `d30196e7775276f07a85416d35590117e9056b0cdff687e06128edd1c0d64e7a` | Catalog retry showing that library tracks provide neither previews nor ISRCs |
| `2026-07-15-apple-music-trace-5.json` | `c4e23572db7a2e9b9c694181576a9f75f6f46cac0c285853e042bb7a0ec833e9` | Equivalent-ID requests blocked by automatic developer-token failure |

Trace 2 contains the Trace 1 session plus later events. Counts below use Trace 2 and Trace 3 so the first session is not counted twice.

## Gate evidence

| Capability | Result | Evidence |
| --- | --- | --- |
| Contextual Music authorization | Pass | Authorization returned `authorized` |
| Library playlist loading | Pass | MusicKit loaded 40 playlists |
| Library track loading | Pass | Multiple playlists loaded 13 to 226 tracks |
| Direct library preview decoding | Fail | 100 attempts across ten 10-track samples produced 0 decoded previews |
| Catalog preview resolution | Blocked | All 40 equivalent-ID requests returned `.developerTokenRequestFailed` before a catalog response |
| Real `ApplicationMusicPlayer` playback | Pass | Queues of 25 and 34 tracks entered the playing state |
| Live rate writes | Mechanical pass | 0.94, 1.00, and 1.06 were accepted and reported while playing |
| Pause and resume | Pass | Requested actions and state changes are present in the traces |
| Track change | Not proven | No successful next-track event appears in the supplied traces |
| Pitch-stable listening | Not proven | No listening notes or headphone evidence were supplied |
| Five-minute screen-lock playback | Not proven | Sessions were shorter and no lock interval was recorded |
| Deliberate interruption recovery | Not proven | Interruption notifications appeared during session activation, but no controlled interruption was recorded |
| Route loss and recovery | Not proven | Every saved event used the built-in speaker route |

## Focused retry

Trace 4 showed that MusicKit returned no ISRC for all 40 sampled library tracks. Those tracks did provide library IDs. The iOS 27 SDK supports `findEquivalents` on catalog requests, so the harness used each library ID as a catalog-resolution fallback.

Trace 5 contains 40 equivalent-ID attempts. Every attempt returned `.developerTokenRequestFailed`. This error means MusicKit failed to fetch the automatic developer token for the current app. It does not prove that the corresponding catalog songs lack previews.

The portal App Service, bundle identifier, and team were user-confirmed. The signed app uses `com.samaydhawan.Samadhi`. Its embedded development profile is the Xcode-managed wildcard profile `ZL5U59XBJ6.*`. Whether profile selection or Apple service propagation caused the token failure is not proven.

Do not pass or fail the Apple Music source gate from this trace. The shortest next action is to retry one equivalent-ID sample after Apple recognizes the enabled MusicKit App Service for this bundle identifier. If automatic token acquisition still fails, inspect or regenerate signing for the explicit App ID before considering manual token infrastructure.
