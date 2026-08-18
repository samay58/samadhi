# Walking Auto analysis

The saved workout showed a clear product gap without proving which exact seconds were walking. Of 61 retained numeric cadence readings, 49 were from 90 through 119 steps per minute. Samay described the session as brisk walking, a short light jog, and substantial lifting.

The candidate supports steady movement from 90 through 210 steps per minute. Running still begins at 120. Walking needs five seconds of steady evidence before it can control the music. Running can settle after the motion filter locks. Missing, broken, repeated, backward, stale, or out-of-order readings still fail.

The 90-step floor is intentionally conservative. Published adult walking observations include values below 100 steps per minute, while 100 steps per minute is commonly used as a practical moderate-intensity marker. The local workout had long steady groups near 95, 99 through 101, 102, 107, and 116. Values from 80 through 89 remain outside Auto for this candidate. Sources: [adult walking cadence ranges](https://pubmed.ncbi.nlm.nih.gov/22462794/) and [100 steps per minute as a practical moderate-intensity marker](https://pmc.ncbi.nlm.nih.gov/articles/PMC6337834/).

At this checkpoint, approximate matching accepted a remaining difference of five steps per minute instead of three, while playback still used 0.90 through 1.10. On the saved 15-track ready collection, this made four tracks usable around 90 and 100 steps per minute and seven around 110. Those counts are historical evidence for the earlier range. The later 0.85 through 1.15 candidate needs its own collection measurement.

One bug surfaced while testing the new walking rule. Raw cadence could reach the playback policy before the separate Auto target had settled. The reducer now passes an explicit empty target during acquisition, so the song stays at its current speed until Auto has enough steady evidence.

This folder contains aggregate evidence only. The raw phone file and private music metadata remain outside the repository. A clean walking-only phone check is still required before calling the floor or five-second delay physically tuned.

The final candidate passed 152 package tests, 27 app-model tests, and 28 serial interface tests. It was built with exact profile `Samadhi Development 2026-08-15`. The embedded profile and app signature both requested `ZL5U59XBJ6.com.samaydhawan.Samadhi`. The built app recorded source fingerprint `9137f9db705f06e69d358178d56c090c9ff05f54cd9aa7109c37d3d32e03748b`.

The candidate was installed over the existing app without uninstalling it. The selected collection stayed byte-for-byte unchanged at SHA-256 `81a9b31fbc115d607bc766dd25374ecff6874b079276b68c3719cb122cea3f52`. The device launch command succeeded, but the in-app fingerprint screen was not read back. No walking, listening, or Apple Music claim comes from this installation alone.
