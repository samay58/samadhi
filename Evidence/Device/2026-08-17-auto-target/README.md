# Fingerprinted Auto workout

Captured on August 17, 2026 with Samay's paired iPhone 17 Pro on iOS 27.0.

The Debug candidate was built with exact profile `Samadhi Development 2026-08-15`, UUID `1b613344-c5cd-4802-a31f-9ff5088c1802`. The embedded profile and app signature both use `ZL5U59XBJ6.com.samaydhawan.Samadhi`.

The built app contains source fingerprint `4e454d2859a521367bf83f26ba1287b14d617d0700c630f90ff13ce8f3b5b498`. Its signature passed strict verification. It was installed over Samadhi 1.0 build 1 without uninstalling.

The selected collection stayed byte-for-byte unchanged. Its SHA-256 before and after installation was `ad06b66b5f9eb90641e903c734c8ddce362df22347b2ddd25cc84cd5dde2bdd4`.

The first launch attempt ended at the lock screen. Samay later opened the installed build and used it during his workout. The local diagnostic file was pulled from the phone after that run. Its source fingerprint matches the inspected build.

The bounded trace contains 61 numeric cadence readings. Fifty-seven were below the current 120 steps-per-minute running range. Samay reports a mix of brisk walking, a short light jog, and substantial lifting. The trace cannot label which activity produced each reading. Four readings entered the supported range, the repaired delivery rule accepted them, the sensor estimate reached 133.27 SPM, and Auto settled at 133 SPM. This physically confirms the cadence timing repair for the observed phone delivery pattern.

Apple Music received 1.0390625 and reported 1.0390625 after 0.066 seconds for the settled target. Samay felt Auto changing the music. He also reported that the changes felt jarring and unexplained. That listening judgment is direct product evidence. The trace cannot measure the quality of the sound or haptics.

The app summary counted 328 seconds, including 313 seconds in Auto and 15 seconds in Manual, across six songs. It reported 96 percent measurement coverage but only 6 percent tempo matched. The larger 30-minute period included substantial lifting. It is therefore not a valid comparison for judging how much rhythmic walking or jogging time the summary omitted. The trace proves what the app counted, not that the duration is wrong by a specific amount.

The retained timeline begins at 1,300.94 seconds because diagnostics keep only the newest 512 events. It contains one confirmed song change but cannot tell whether that boundary was natural or followed Skip or Previous. Current code does not let Auto interrupt a song. Do not infer an automatic mid-song cut from this trace.

The route was lost at 1,612.14 seconds and restored at 8,765.21 seconds. The workout included lifting and other activity outside rhythmic walking or jogging. The long gap is not evidence of a continuous two-hour Samadhi run.

`workout-readback-summary.json` preserves the privacy-safe numerical evidence. The raw pulled diagnostic stays outside the repository because it contains private collection and song metadata. The earlier lock-screen capture stays local and is ignored by Git because it is not in-app proof.
