# Evidence

This directory holds the proof behind claims in `Docs/STATUS.md` and `Docs/TESTING.md`.

| Folder | What it proves |
| --- | --- |
| `Device/` | What a signed build did on the physical iPhone: install receipts, pulled-record analyses, and listening notes |
| `Simulator/` | Interface behavior in Simulator, with frames for the current run controls and setup flow |
| `Audio/` | Tempo analyzer corpus results and the Auto feedback prototype record |
| `Brand/` | Small-scale app icon reviews |

## What is kept in Git

Every written record stays. Images stay only when they show the current interface.

On 2026-11-02, 112 superseded images, logs, and export manifests left the repository to keep it light, and Git history was rewritten so they no longer download with every clone. Older records still name those files. They are all in the [evidence archive](https://github.com/samay58/samadhi/releases/tag/evidence-archive-2026-08-19).

Commit hashes written in records before 2026-11-02 belong to the original history. [COMMIT-MAP.txt](../Docs/Archive/COMMIT-MAP.txt) gives each one's current hash, and the same release holds a complete backup of the original history. A build's source fingerprint did not change.

## Adding evidence

1. Capture raw frames, recordings, and exports in `Evidence/Temp/`. Git ignores it.
2. Inspect them. A frame nobody looked at proves nothing.
3. Commit one dated folder with a `README.md` that says what ran, on which commit or source fingerprint, what passed, and what stays unproved.
4. Add one contact sheet or at most five frames. Replace older frames of the same surface rather than adding to them.

Raw phone records stay local because they can contain personal music and device data. `.gitignore` covers `*diagnostics.json`. Commit a parsed analysis instead, with song titles only where the finding needs them.

A Simulator frame never proves cadence quality, audio quality, haptic feel, or locked-screen behavior.
