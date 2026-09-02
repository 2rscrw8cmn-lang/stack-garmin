# STACK Watch Face — Canonical v2 Direction

## Product intent

The STACK watch face is a **brand object first and a utility second**.

It should feel unmistakably STACK without printing the word STACK on the face. Identity comes from the numeric type, Trainer Boi, color behavior, chunky geometry, and playful composition.

The face must still behave like a real Garmin watch face: glanceable time, power-safe AMOLED behavior, limited data density, and practical Forerunner 265 performance.

## Canonical direction — STACK Hero Time

The previous OFFSET layout is superseded.

### Hierarchy

1. Hero time
2. Trainer Boi
3. Step-progress ring
4. Three compact lower metrics
5. Day/date and battery utility row

No additional information should be added merely because Garmin exposes it.

## Hero time

Use **Skomelr Quantum** for the main time.

Required behavior:

- hour, colon, and minute are separate draw objects
- each can be assigned a different user-selectable color
- default active palette:
  - hour: STACK cyan/teal
  - colon: STACK yellow
  - minute: STACK red-orange
- monochrome and single-color modes are also supported
- respect the device 12/24-hour preference
- keep the time centered optically even though each color group is drawn separately

The font must come from generated Garmin bitmap-font resources, not hand-built polygon digits.

## Trainer Boi

Use the actual canonical full-color STACK runner artwork, not a generic runner icon and not an AI approximation.

Source:

`watch-face/artwork/trainer-boi-full-color.svg`

Default active treatment:

- full color
- centered beneath the hero time
- approximately 72–90 px high on the 416×416 target, tuned in simulator
- no label and no surrounding card

Trainer Boi is a brand anchor, not a data icon.

User setting:

- Full Color
- Mono
- Off

See `TRAINER_BOI_INTEGRATION.md`.

## Outer segmented ring

The outer ring is **not decoration**.

Canonical meaning: **daily steps as a percentage of the Garmin step goal**.

Behavior:

- segmented rather than a continuous gauge
- empty segments remain dark charcoal
- filled segments progress around the upper/side perimeter
- multicolor STACK mode is the default
- optional single-color mode uses the user's ring color setting
- keep a visual break at the bottom so the ring does not box in the metrics

Do not use the ring for heart-rate zones on the everyday watch face.

## Lower metrics

Three compact slots sit beneath Trainer Boi.

Default slots:

1. distance / steps summary
2. heart rate
3. Body Battery

The exact Garmin-local value can be configurable, but v1 should expose a curated list rather than every possible complication.

Recommended available metrics:

- steps
- distance
- heart rate
- Body Battery
- battery
- temperature
- notification count
- sunrise / sunset

Keep metric labels abbreviated (`MI`, `HR`, `BB`) or use simple graphic marks. Avoid Garmin-style dense dashboard labels.

## Top utility row

Small and quiet:

- left: day + date
- right: battery percentage / battery mark

This row stays subordinate to the time.

## Color system

Use colors derived from the canonical Trainer Boi artwork in `stack-run`.

Primary usable watch colors:

- Cyan — `#02BCC0`
- Bright blue — `#0CB9FC`
- Blue — `#0A66DA`
- Yellow — `#FCBC12`
- Orange — `#FC9809`
- Red-orange — `#FD4E2E`
- Lime — `#65FC04`
- Purple — `#8537DF`
- Deep purple — `#4C229E`
- Background — near-black / black
- Utility text — off-white

Do not substitute an unrelated generic neon palette.

### User color settings

Expose a curated STACK palette for:

- hour color
- minute color
- colon color
- ring mode: multicolor / single color
- ring single color
- metric color mode: automatic / match time / individual

Unlimited RGB input is not required for v1.

## Active / high-power state

The active state may use:

- full-color hero time
- full-color Trainer Boi
- multicolor step-progress ring
- all three lower metrics
- top utility row

Keep animations optional and brief. No continuous running animation.

## Always-on / low-power state

AOD is a separate reduced composition, not a dim copy of the active face.

Required direction:

- black background
- single dim time color
- day/date and battery only if pixel budget allows
- no step-progress ring
- no lower metrics
- Trainer Boi hidden by default
- minimal lit pixels and no continuous motion

Reference: `docs/screenshots/watch-face-v2-aod-reference.png`.

## Platform rules

Primary target: **Forerunner 265, 416×416 AMOLED**.

Implementation should still be structured so additional round AMOLED sizes can be added through resource overrides rather than a rewrite.

Do not hard-code the product around one pixel layout if a relative/normalized anchor can solve it cleanly.

## Explicit non-goals for v1

- STACK backend connectivity
- Build/tower visualization
- training-plan status
- race countdown
- HR-zone ring on the everyday watch face
- six-plus complication dashboard
- continuous character animation
- gradients/effects that require expensive per-frame rendering

## Acceptance criteria

The v2 face succeeds when:

- Skomelr Quantum is visibly the actual chosen font
- Trainer Boi is the actual STACK artwork
- the ring visibly communicates step-goal progress
- hour/minute/colon colors are configurable
- time remains readable at a glance
- the face feels fun and STACK-specific without a STACK wordmark
- the active state is colorful without becoming random
- AOD is intentional and power-safe
- Forerunner 265 simulator validation passes without clipping
