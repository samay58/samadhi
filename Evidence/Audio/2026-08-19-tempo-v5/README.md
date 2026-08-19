# Tempo analyzer version 5

Record of the repair that stopped swung and dotted grooves from being rejected or mislabeled. No preview audio and no private song or playlist names are kept here; the per-song probe output stayed local.

- `corpus-validation.json`: the 12 tempo-declared public previews, all within 2 percent of the declared pulse under version 5.
- Synthetic tests: 20 of 20, including the new swing and dotted-eighth cases; the dotted-eighth case fails under version 4.
- One real 48-song playlist: 38 ready under version 4, 41 under version 5, none lost. The three recovered songs are live-drummed or swung and now report a beat with its half.
- The 138 version 4 results cached on the phone: 132 unchanged, 5 changed, 1 newly rejected. Four of the five changes were checked against public BPM listings and matched; the fifth is a broken-beat track with no listing. The newly rejected song had been reported at 210 under version 4 for a song listed near 115.

What this does not prove: analysis of songs outside these sets, and how the matching feels on a run. The remaining rejections in the 48 have no tempo peak above the bar in their 30-second preview, which is the analyzer being honest about the excerpt it was given.
