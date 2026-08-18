# Expanded playback candidate

The 0.85 through 1.15 candidate passed the complete software gate: 153 package tests, 27 app-model tests, 28 serial interface tests, formatter lint, source-fingerprint tests, Debug and Release Simulator builds, and Release exclusion of the hidden Debug screen.

The physical Debug build records source fingerprint `fd8120ad2ac14e1090a687438e6564beb65bde0a61d58fab04d4ec7295535684`. It uses exact profile `Samadhi Development 2026-08-15`, UUID `1b613344-c5cd-4802-a31f-9ff5088c1802`. The embedded profile and app signature both use `ZL5U59XBJ6.com.samaydhawan.Samadhi`. Strict signature verification passed.

The build was installed over Samadhi 1.0 build 1 without uninstalling. The selected collection stayed byte-for-byte unchanged at SHA-256 `81a9b31fbc115d607bc766dd25374ecff6874b079276b68c3719cb122cea3f52`.

The phone was locked when launch was attempted. The installed build has not yet produced an in-app fingerprint read-back, an Apple Music reply at 0.85 or 1.15, or a listening result. Those remain physical gates.
