# Transport and Finish rebuild, 2026-08-18

Simulator evidence for the run screen controls. Device: iPhone 17 Pro, iOS 27.0, Debug build,
serial interface tests. Every frame in this folder was opened and read at its original size before
anything below was written. No song titles, playlist names, or account details appear in any frame.
The demo collection is the bundled fixture. Four frames stay as lossless PNG for edge inspection
(`before-hold-detail.png`, `after-transport-normal.png`, `after-finish-armed-normal.png`,
`after-hold-midway-frame.png`); the rest are high-quality JPEG to keep the repository small.

## What changed

The three floating transport pills became one glass capsule bar with three regions: Previous,
Pause or Resume, and Next. The bar is a single `GlassEffectContainer` holding one
`glassEffect(.regular, in: .capsule)` surface. Pause or Resume is the primary region: it is about
1.65 times as wide as either secondary region, its symbol is one type step larger and heavier, and
it sits on a raised ivory disc. Previous and Next carry symbols only. No region has a text label at
any size.

Pressing a region darkens that region with an ink wash at about 8 percent and compresses its symbol
to 0.97 over 100 ms, ease out. Under Reduce Motion the wash appears with no scale and no animation.
The visible symbols are small; the touch region for each is the full region of a 60 point bar, well
past 44 points.

Finish moved below the bar and became quiet: a text button with a hairline ivory capsule stroke, no
glass at rest, a visible pill 34 points tall inside a 44 point touch height. Tapping it arms the
hold control. Finish and the hold control are now one view. The word and the width change in place
in a single frame; the material and tint animate. The hold progress is drawn behind the label and
clipped by the same capsule the button uses, so it moves and clips with the pressed shape.

The status line "Keep holding to finish" now appears only while the hold is actually pressing. The
status row keeps its height while Finish is merely armed, and the dark well behind the line only
appears when there is a line. The tempo aperture still grows by 42 points when the transport
controls hide, so arming does shift the whole lower block down once, before any press begins; that
is the pre-existing aperture rule, not the control moving under a finger.

`RunViewState` gained one field, `finishHoldPressing`, defaulting to false. The app shell maps
`FinishConfirmation.hold == .pressing` onto it. These frames were captured before that mapping
landed, so the armed frames show no status line.

## The two overflow causes and the fix

Both causes were reproduced by the integrator on video before this work started. `before-hold-detail.png`
is that contact sheet.

Cause one, crossfade overlap. The resting Finish pill and the hold pill were two different views
swapped in the same slot with an opacity transition, at two different sizes, under the screen level
smooth animation. For roughly eight frames both capsule borders and both labels were visible on top
of each other, and the transport pills faded behind them.

Cause two, the pressed fill escaping. `HoldToFinishControl` drew progress as a `Capsule` in the
Button's `background`, outside the button style. The `glassProminent` style scales its own glass
capsule on press. The background capsule did not follow and was not clipped by the glass shape, so a
second capsule edge appeared offset below and left of the pill during the hold.

The fix. Finish and hold are one `Button` whose label and metrics change with an `armed` flag, so
there is never a second view to cross into. The progress fill lives inside the label, behind the
text, and the whole label plus fill is clipped by one capsule before any glass or stroke is applied,
so the fill cannot leave the border. The `glassProminent` style is gone; the armed pill uses
`glassEffect(.regular.tint(clay), in: .capsule)` inside a custom `ButtonStyle`, which keeps the same
raised clay meaning while giving the fill a shape to live in.

One more defect showed up on video during this work and was fixed here. With the two states in one
view, SwiftUI still crossfaded the two words, so "Finish" and "Hold to finish" were both legible for
a few frames at slightly different widths. The label now swaps with `contentTransition(.identity)`
inside a transaction that clears the animation, so the word and the width change in one frame.

## Which variant won and why

Two restrained bar treatments were built and rendered. Variant one put hairline ivory dividers
between the three regions. Variant two dropped the dividers and gave the primary region a raised
ivory disc behind its symbol.

Variant two won. The disc names the primary action without adding two lines that do no other work,
so the bar stays one object instead of reading as a segmented control, and its circle echoes the
tempo aperture directly above it. The disc also gives the paused state somewhere to live: it
brightens from 12 to 20 percent ivory and holds `play.fill`, which variant one has no place for.
`variant-1-transport-normal.jpg` and `variant-1-transport-paused.jpg` are the loser at running and
paused; the divided bar is legible but the three cells read as equal weight and the paused play
symbol sits alone in a wide empty cell.

## What each frame shows

Before frames were captured from the unchanged code before any edit, in the same five environments
as the after frames.

- `before-transport-normal.jpg`: three separate glass pills, each with a symbol above a caption, and
  a Finish pill below of almost the same visual weight. Nothing marks Pause as primary.
- `before-transport-accessibility-xxxl.jpg`: the same three pills with captions dropped. Finish still
  matches the transport pills in weight.
- `before-transport-increased-contrast.jpg`, `before-transport-reduce-motion.jpg`,
  `before-transport-reduced-transparency.jpg`: no visible difference from the normal frame apart from
  the clock, which is the honest before state.
- `before-finish-armed-*.png`: the saturated clay `glassProminent` pill with the transport pills gone.
- `before-hold-detail.png`: the integrator's 30 fps contact sheet. Frames one to four show both
  labels and both borders at once. Frames five to eight show the offset second edge around the
  pressed pill.

After frames.

- `after-transport-normal.png`: one capsule bar, three regions, pause on a raised disc, symbols
  optically centered. Finish is a hairline outline pill below with clear separation.
- `after-transport-paused-normal.jpg`: the primary disc is brighter and holds `play.fill`. The
  aperture is dimmed and the status line reads Paused.
- `after-transport-accessibility-xxxl.jpg`: the bar grows from 60 to 84 points and the symbols scale.
  The primary is still about 1.65 times as wide as each secondary, so the hierarchy survives. Finish
  grows but stays an outline against a filled bar.
- `after-transport-reduce-motion.jpg`: identical at rest, as expected. Reduce Motion changes press
  and transition behavior, not the resting frame.
- `after-transport-increased-contrast.jpg`: captured with Increase Contrast switched on at the device
  level with `simctl ui increase_contrast enabled`, because the launch argument alone did not reach
  `colorSchemeContrast` on this runtime. The bar carries a visible capsule edge, the disc ring is
  stronger, the Finish stroke and label are brighter, and the aperture ring is much brighter.
- `after-transport-reduced-transparency.jpg`: the glass falls back to a solid warm tint. The bar
  still reads as one raised object and the raised disc is still visible.
- `after-finish-armed-normal.png`: one clay tinted glass pill, one border, no second capsule and no
  ghost label. The bar's place is held empty above it.
- `after-finish-armed-accessibility-xxxl.jpg`: one line, fully on screen, no truncation. Text growth
  inside this control is bounded at accessibility 2; without that bound the pill wrapped to two lines
  and ran off the bottom of the screen.
- `after-finish-armed-increased-contrast.jpg`, `after-finish-armed-reduce-motion.jpg`,
  `after-finish-armed-reduced-transparency.jpg`: the same single pill, with the stronger stroke under
  Increase Contrast and the solid fallback under Reduced Transparency.
- `after-finish-cancelled-normal.jpg`: after a 0.4 second press and release, the hold control is
  still present, unfilled, and the run continues.

Key frames pulled from 30 fps recordings made with `simctl io recordVideo` while the evidence tests
drove the app.

- `after-transport-rest-frame.jpg`: the bar at rest, for comparison with the pressed frames.
- `after-pressed-previous-frame.jpg`: the Previous region darkened with a clean edge at the region
  boundary and its symbol slightly smaller. The wash is clipped to the capsule's left end.
- `after-pressed-next-frame.jpg`: the same on the Next region.
- `after-pressed-pause-frame.jpg`: the primary region darkened. The wash follows the disc's region,
  and measured against the resting frame the darkening is about 3 percent of luminance, which reads
  as pressure rather than as an animation.
- `after-hold-armed-frame.jpg`: armed, unfilled.
- `after-hold-press-begins-frame.jpg`: the fill just entering from the left, rounded by the capsule.
- `after-hold-early-release-frame.jpg`: the fill at roughly 18 percent, the last frame before release.
- `after-hold-cancel-reset-frame.jpg`: the next frame. The fill is gone with no animation.
- `after-hold-midway-frame.png`: the fill at roughly 62 percent. The left end is rounded by the
  capsule, the right edge is a straight sweeping line, and nothing crosses the border.
- `after-hold-complete-frame.jpg`: the fill at full width, still inside the border.
- `after-hold-handoff-frame.jpg`: the pill fading out as the summary takes over.
- `hold-contact-sheet.jpg`: 54 frames at 30 fps covering arm, first press, instant reset, second
  press, fill to full, and fade out. Every fill edge stays inside the capsule.

## What is not proven here

These are Simulator frames. Press feel, haptics, and how the hold reads on glass in daylight are
physical checks. No frame here shows the "Keep holding to finish" line, because the frames predate
the shell mapping of `finishHoldPressing`; the interface test that presses the hold covers it.
