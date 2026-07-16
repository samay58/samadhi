# Apple Music gate device start

Date: 2026-07-15

Status: Physical gate blocked by automatic MusicKit developer-token acquisition. No source decision has been made.

## Configuration

| Item | Result |
| --- | --- |
| App ID | `com.samaydhawan.Samadhi` registered |
| Apple team | `ZL5U59XBJ6` |
| MusicKit App Service | Enabled, user-confirmed in the Apple developer portal |
| Signing | Passed with Apple Development: Samay Dhawan |
| Device | Samay's iPhone, iPhone 17 Pro, iPhone18,1 |
| OS | iOS 27.0, build 24A5380h |
| Developer Mode | Enabled |
| Physical build | Passed |
| Installation | Passed |
| Gate launch | Passed with `--music-feasibility` |

## Passed checks

- Contextual Music authorization
- Loading 40 library playlists and multiple playlists with at least ten tracks
- Real `ApplicationMusicPlayer` playback
- Mechanical live rate writes at 0.94, 1.00, and 1.06
- Pause and resume observation

## Open or failing checks

- Decoded PCM preview coverage is 0 of 10 across every direct-library sample.
- Catalog resolution is blocked because every equivalent-ID request returns `.developerTokenRequestFailed`.
- Pitch stability without clicks, gaps, or obvious warble
- Five minutes of screen-locked playback
- Track change, controlled interruption, and route loss

The device gate is not passed until automatic catalog access works and every remaining check has physical evidence.
