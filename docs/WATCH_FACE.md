# STACK Watch Face

## Product intent

The STACK watch face is a **brand object first and a utility second**.

It should look like a watch face STACK designed, not like a Garmin dashboard wearing STACK colors.

The face does **not** need to connect to the STACK app, represent the Build tower, or expose training-plan data. It should be useful on its own and rely only on Garmin-local data for v1.

## Design documents

This file defines product intent and direction.

Implementation and layout work must also follow:

- `WATCH_FACE_PLATFORM_CONSTRAINTS.md` — Forerunner 265 hardware, memory, AMOLED, font, API, and round-screen constraints.
- `WATCH_FACE_LAYOUT_SPEC.md` — the canonical OFFSET coordinate system, typography plan, safe areas, test times, and visual acceptance criteria.

Do not make visual implementation passes by eyeballing a single simulator screenshot. The platform and layout docs are the source of truth.

## Design principle

> **Big time. Bright STACK color. Chunky graphic personality. Minimal data.**

The STACK app itself keeps a relatively quiet shell around stronger running data. The watch face can invert that balance because it has no forms, lists, navigation, or long-form reading to protect.

For the watch face, visual identity should be approximately:

- 80% expressive STACK / Performance Arcade
- 20% quiet utility

Avoid a generic fitness-dashboard composition of centered time plus rows of tiny metrics.

## v1 direction — OFFSET

OFFSET is the first and canonical layout.

### Composition

- Oversized split time: `HH` and `MM` are separate graphic objects.
- Asymmetric placement rather than a centered digital-clock row.
- The colon is a small STACK accent object.
- Time is the dominant visual element and may approach the circular safe-area edges.
- Day/date lives in one compact bright badge.
- Battery sits in the upper-right utility zone.
- Weather and steps form a purposeful lower-left utility stack.
- One purple STACK block occupies negative space as pure graphic punctuation.
- No on-face STACK wordmark is required; the visual system itself is the branding.

### Required v1 information

1. Time
2. Day + date
3. Battery
4. Current temperature/weather when available
5. Steps

Do not add additional data simply because Garmin exposes it.

## Visual language

### Color

Use the current STACK palette from the main `stack-run` design system as the source of truth.

Core watch colors:

- Background — `#03070A`
- White — `#F6F7F8`
- STACK lime — `#A6FF1A`
- Electric blue — `#287DFF`
- Purple — `#A14CFF`
- Yellow — `#FFD21A`
- Cyan — `#2BC6D6`
- Orange — `#FF9F43`
- Pink — `#FF5AC8`

A single face should normally use black + white + lime + a limited set of secondary accents with defined jobs.

Current OFFSET roles:

- blue — date badge
- yellow — weather
- cyan — steps/run mark
- purple — decorative punctuation

The old Garmin-specific orange / blue / muted-lime palette is deprecated.

### Typography — LOCKED FOR v1

The Forerunner 265 supports scalable system fonts at explicit pixel sizes. Its fixed `FONT_XTINY` is already about 34 px tall, so Garmin's named bitmap sizes are not appropriate for small metadata by name alone.

#### Display numerals

**BionicBold is the v1 display face.**

Simulator testing established that it provides the right combination of weight, width, readability, and personality without consuming memory on a custom bitmap font.

Current target size: **238 px**.

The main time must:

- look like real display typography
- feel heavy and condensed
- avoid seven-segment / LED-clock character
- remain readable at glance speed
- render as two-digit hour + two-digit minute masses

The leading zero is intentional in both 12-hour and 24-hour mode because it stabilizes the upper-left visual mass.

The hand-built geometric digit renderer is retired.

#### Utility type

Use scalable `RobotoCondensedBold` at explicit sizes:

- day/date: ~24 px
- battery: ~20 px
- weather: ~24 px
- steps: ~24 px

Measure variable-width strings before final positioning where useful.

## Graphic pieces

The face uses a small graphic kit rather than a Build tower.

Current v1 pieces:

- compact battery outline/bar
- yellow STACK-style sun
- cyan chunky shoe/run mark
- one purple stepped block

Functional pieces should have a clear job. Decorative pieces should be sparse and semantically inert.

## Data presentation

Avoid conventional labels such as:

- `STEPS 6247`
- `BATTERY 82%`
- dense grids of complications

Prefer direct graphic treatment:

- cyan shoe + `6.2K`
- yellow sun + `84°`
- lime battery symbol + `82%`

Color and geometry should help recognition, but the numeric value remains readable.

Current v1 data comes only from Garmin-local APIs:

- clock — `System`
- date — `Gregorian`
- battery — `System`
- steps — `ActivityMonitor`
- weather — cached `Weather` data

No STACK connection is required.

## High-power / wake state

When the user raises the wrist, the full face uses the complete color treatment.

A short wake animation is allowed later if it remains subtle and power-safe. Preferred behavior:

- main numerals snap or settle into place
- one small STACK block slides/lands
- total visual motion roughly 250–400 ms

Do not build a continuous arcade animation.

Typography and static composition must be complete before animation work starts.

## Always-on / low-power state

Always-on mode is a deliberately different composition, not a dim copy of the full face.

Keep it mostly black with:

- simplified thin gray time
- day/date if luminance testing permits
- at most one tiny lime accent detail
- no weather, steps, battery, or decorative block field in v1 AOD

The face must remain readable while respecting Garmin AMOLED low-power constraints and burn-in guidance.

Test AOD with the Connect IQ Simulator screen heat-map / burn-in simulation before release.

## Future layouts

After OFFSET is stable, two additional layouts may reuse the same font and graphic kit.

### BLOCK

Time is integrated into large STACK-shaped containers. More structured and geometric than OFFSET.

### POSTER

Time becomes nearly full-face editorial typography with tiny utility data pushed into leftover negative space.

These are later variants, not parallel v1 implementation work.

## Explicit non-goals

For v1, do **not** add:

- STACK backend connectivity
- Build/tower visualization
- race countdown
- training-plan status
- readiness/recovery dashboard
- weekly mileage dashboard
- heart-rate-zone visualization
- dense configurable complication grids

Those features may be useful elsewhere in the Garmin project, particularly the run field, but they do not improve the core watch-face concept.

## v1 acceptance criteria

The v1 face is successful when:

- it is immediately recognizable as a designed STACK object
- time is readable at a glance
- it does not resemble a stock Garmin data dashboard
- the OFFSET composition works on the Forerunner 265 416×416 round AMOLED display
- all critical content respects the project round-screen safe area
- current STACK colors replace the legacy Garmin palette
- the tower is removed
- BionicBold owns the main time
- two-digit hours remain visually balanced across the full day
- weather and steps feel like intentional utility objects, not filler
- high-power and low-power states both feel intentional
- steady-state memory leaves meaningful headroom under the 128 KiB watch-face limit
- no STACK account or network connection is required

## Immediate next milestone

1. validate the 238 px BionicBold composition across the standard time grid
2. confirm cached weather behavior in simulator and on-device
3. tune only optical placement/scale from those results
4. profile steady-state memory
5. validate AOD with Garmin's heat map
6. then consider accent-color settings or alternate layouts
