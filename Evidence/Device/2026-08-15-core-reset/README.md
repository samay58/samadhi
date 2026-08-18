# Exact phone baseline

This folder records one short run on the paired iPhone 17 Pro. The app was built from commit `4f5394f3158dde9ad891b8b772b197c4c26090b2` on `main` with tracked changes present. The screen records that base commit, dirty state, and build time. It does not record a hash of the dirty source changes, so the exact source tree cannot be reconstructed from the screen alone.

The build used `Samadhi Development 2026-08-15`, UUID `1b613344-c5cd-4802-a31f-9ff5088c1802`. Its embedded application identifier and app signature both used `ZL5U59XBJ6.com.samaydhawan.Samadhi`. It was installed over Samadhi 1.0 build 1 without uninstalling. The selected collection stayed byte-for-byte unchanged. Its SHA-256 before and after installation was `5bc4aacab776db92bb0dc15311ed011e2ee1c329da9e14231635a3a0c2afa529`.

The phone produced 17 cadence events. Sixteen had a numeric reading from 151.56 to 158.10 steps per minute. The filter accepted only two numeric readings because 14 arrived about 2.57 seconds after their Core Motion end time, while the current freshness limit is 2.0 seconds. Three accepted readings are required to lock. This trace therefore exposes a mismatch between real Core Motion delivery timing and the filter. It does not show that Samay's pace was unstable, and it does not prove that Auto feels stable.

Manual and Return to Auto both sent real Apple Music speed changes. Apple Music reported the changes in about 0.04 to 0.07 seconds. Examples include 1.0952 for a 164 SPM Manual target, 0.9015 for 135 SPM, and 0.9215 for 138 SPM. The final Auto command sent 0.9683 and Apple Music reported 0.9762, leaving about 1.19 SPM of difference.

The run used one ready song. It did not physically prove a confirmed song change. No separate listening, haptic, or running-feel judgment was recorded.

After the Manual and tempo-close fixes passed the full software gate, the final candidate was rebuilt with the same exact profile and installed in place. Its embedded profile, signature, base commit, branch, dirty flag, version, and build number were inspected before installation. The selected collection checksum remained unchanged. Two remote launch attempts were rejected because the phone had locked, so the final behavior build has installation proof but no in-app read-back or new phone screen capture.

Files:

- `exact-build-hidden-screen.png`: base commit, dirty state, build time, and phone environment shown inside the baseline app.
- `baseline-ready.png`: phone ready before the short check.
- `baseline-after-run.png`: hidden screen after the check.
- `baseline-latest-run-diagnostics.json`: local diagnostic file pulled immediately after the check. Git ignores it because it contains music metadata.
