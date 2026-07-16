# Tempo corpus analysis

Date: 2026-07-16

Source: Apple catalog lookup and provider-hosted preview assets

Reference: The exact Apple catalog title declares the tempo

Analyzer: LocalTempoAnalyzer version 2

Status: Passed at 12 of 12 within 2 percent of the published tempo or its half or double

## Saved result

| File | SHA-256 |
| --- | --- |
| `2026-07-16-tempo-corpus-validation.json` | `1f3ccc669fa86fd444d84f626b3f7308ee0fbd53bda26826e7ceef8ee2eb16b7` |

## Method

The opt-in `TempoCorpusValidator` resolves each fixed catalog identifier through Apple's lookup endpoint, verifies title and artist, downloads the provider-hosted preview into temporary storage, analyzes it through the public `TempoAnalyzing` interface, and deletes the file. No preview audio is stored in the repository.

The corpus contains two workout mixes at each declared tempo from 130 through 180 BPM. These tracks are useful references because the catalog titles publish the intended tempo and the audio contains full mixed music rather than generated clicks.

Normal automated tests remain offline. This network validation runs only when invoked directly and fails if metadata changes, a preview disappears, or fewer than ten tracks land within the accepted tempo family.

## Results

| Catalog ID | Reference | Estimate | Confidence | Family error |
| --- | ---: | ---: | ---: | ---: |
| `1598194487` | 130 | 130.25 | 1.00 | 0.19% |
| `1383986831` | 130 | 65.00 | 0.84 | 0.00% |
| `1434921088` | 140 | 139.50 | 1.00 | 0.36% |
| `1434921085` | 140 | 139.50 | 1.00 | 0.36% |
| `1558215042` | 150 | 149.75 | 1.00 | 0.17% |
| `1585442488` | 150 | 74.75 | 1.00 | 0.33% |
| `1323303912` | 160 | 79.75 | 1.00 | 0.31% |
| `1323303916` | 160 | 160.75 | 1.00 | 0.47% |
| `1066177773` | 170 | 170.25 | 1.00 | 0.15% |
| `1066177779` | 170 | 170.25 | 1.00 | 0.15% |
| `1441808823` | 180 | 89.50 | 1.00 | 0.56% |
| `1307211987` | 180 | 181.25 | 1.00 | 0.69% |

Version 1 passed 11 of the same 12 previews but confidently labelled one 180 BPM mix as 60 BPM. Version 2 replaces frame-energy onset detection with Accelerate spectral flux and fractional-lag autocorrelation. It also rejects a low-tempo triple-meter alias when the corresponding double-tempo family has no support. The generated regression fixture captures that failure mode at the public file seam.

## Decision

The real-preview accuracy gate passes for this deliberately narrow corpus. Catalog track `1066177773`, “Shake It Off (Workout Remix 170 Bpm)” by Hanna, becomes the known-tempo core-loop fixture with a 170.25 BPM local estimate.

This result does not prove accuracy across arbitrary music, public-distribution permission for preview analysis, physical cadence, adaptive playback, or listening quality. Expansion beyond this corpus should prefer rejection over a confident wrong tempo.
