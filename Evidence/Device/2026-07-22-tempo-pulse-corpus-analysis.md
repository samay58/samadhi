# Running-pulse tempo corpus

## Result

Tempo estimator version 3 passed 11 of 12 provider-hosted Apple previews against the exact tempo printed in each catalog title. Every accepted result is within 2 percent of the declared 130 through 180 BPM running pulse. The remaining preview was rejected instead of receiving a confident wrong tempo.

| Evidence | SHA-256 |
| --- | --- |
| `2026-07-22-tempo-pulse-corpus-validation.json` | `223151f10ee74ffcad20439d25278b3f52314b3079b948f2c604651053fd7ddd` |

## Why version 3 exists

Version 2 accepted half-time and double-time estimates as equivalent. That let one declared 180 BPM track pass at 89.5 BPM. The arithmetic is related, but the perceived musical pulse can still feel like 90 BPM. Samadhi cannot show 180 and claim the music is playing at 180 when its analyzer selected the slower pulse.

Version 3 searches the 120 through 210 BPM running-pulse range directly. Track selection, rate derivation, displayed applied BPM, and tempo-matched measurement now use that one analyzed pulse without silently multiplying or dividing it. Persisted version-2 selections are reimported before use.

## Boundary

This is network-backed analyzer evidence, not a physical listening pass. It proves that the narrow reference corpus no longer passes through half-time equivalence. It does not prove that every arbitrary song has one unambiguous step pulse, nor does it prove beat phase. Ambiguous previews should continue to be rejected.
