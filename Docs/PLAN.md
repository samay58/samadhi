# Product plan

## Completed gates

### Repository foundation

Project generates, builds, tests, and stores evidence without production dependencies.

### Interaction prototype

Every meaningful state renders deterministically. Golden flow and recovery paths pass. Visual hierarchy, accessibility, progress, controls, finish safety, and summary are resolved at prototype level.

## Next planning task

Specify Milestone 2 before writing production motion or audio code.

Spec must settle:

- What prepared local track proves tempo adaptation
- Where iPhone sits on runner during test
- Which cadence samples count as reliable
- How quickly lock may appear
- How much cadence drift changes tempo
- Safe tempo range and smoothing
- What happens when motion, route, or audio engine fails
- Which physical routes must pass
- What listening artifacts fail build
- What exact outdoor run completes milestone

## Proposed Milestone 2 boundary

One prepared local track. One physical iPhone. One supported headphone route. Real cadence acquisition. Pitch-preserving tempo response. Existing interaction reused unchanged unless physical evidence proves it misleading.

Exclude music import, catalog expansion, session history, Lock Screen controls, App Intent, and broad device compatibility until vertical slice feels good.

## Proposed done definition

Milestone 2 ends when:

- Cold start reaches trustworthy cadence lock during real running
- Lock remains stable through normal gait noise
- Tempo changes sound acceptable within declared safe range
- Pause, resume, route loss, and finish leave no orphaned work
- UI never claims confidence sensor or audio engine does not have
- One documented outdoor run passes with device, OS, route, track, logs, and listening notes

## Stop rule

Do not build surrounding product until body-to-music loop works. If audio quality or cadence stability fails, fix core loop before adding imports, persistence, media controls, or more tracks.
