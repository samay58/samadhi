# Restored iPhone install

Date: 2026-07-22

## Configuration

- Commit: `c8e195e1432834fef90b96bb41c90a8354ffcfe8`
- Device: Samay's iPhone 17 Pro (`iPhone18,1`)
- CoreDevice identifier: `74BE85BB-5455-56FE-BFA3-0150F3A28C43`
- iOS: 27.0 (`24A5390f`)
- Connection: paired over the local network
- Developer Mode: enabled
- Bundle identifier: `com.samaydhawan.Samadhi`
- Profile: `Samadhi Development`
- Profile UUID: `f7dc2163-4562-4849-90ba-1f49d14ce03a`
- Application identifier: `ZL5U59XBJ6.com.samaydhawan.Samadhi`
- Profile expiration: 2026-07-23 03:54:43 UTC
- Executable SHA-256: `20c659f3d67bc0c6cc1514689104e184cd9767d52ccc20be37f51366bf10b994`

## Result

The clean `main` build compiled with manual exact-profile signing, installed over the local network, and launched successfully. CoreDevice reported the Samadhi process running. A direct 1206 by 2622 device capture showed the normal `Choose music` setup screen with no launch or layout failure.

The device restore cleared Samadhi's prior local playlist selection, so the screen correctly asks for a new selection. This proves installation and first-screen rendering only. It does not prove playlist import, click-wheel feel, adaptive playback, or a natural track transition on the restored device.

The direct device capture was kept outside the repository. SHA-256: `07dd5dfb41ebee418465ba264150df0320566c2e354e4f2b9b9ee5d2d00a578c`.
