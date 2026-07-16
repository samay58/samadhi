# Apple Music gate device start

Date: 2026-07-15

Status: Physical gate in progress. No source decision has been made.

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

## Remaining checks

- Contextual Music authorization
- One library playlist with at least ten tracks
- Decoded PCM preview coverage of at least eight of ten tracks
- Real `ApplicationMusicPlayer` playback
- Live rate writes at 0.94, 1.00, and 1.06
- Pitch stability without clicks, gaps, or obvious warble
- Five minutes of screen-locked playback
- Pause, resume, track change, interruption, and route loss

The device gate is not passed until every remaining check has physical evidence.
