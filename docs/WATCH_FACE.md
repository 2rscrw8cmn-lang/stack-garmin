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

Do not make another visual implementation pass by eyeballing a single simulator screenshot. The platform and layout docs are the source of truth.

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
- Secondary data stays sparse and visually subordinate.
- Decorative STACK blocks/shapes occupy negative space and do not need to represent data.
- No on-face STACK wordmark is required; the visual system itself is the branding.

### Required v1 information

1. Time
2. Day + date
3. Battery
4. One optional activity metric, initially steps

Temperature/weather is a planned secondary complication once the composition is stable. Do not delay the core visual system to add it.

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

A single face should normally use black + white + lime + one or two secondary accents. Do not turn the face into an undifferentiated rainbow.

The old Garmin-specific orange / blue / muted-lime palette is deprecated.

### Typography

Typography is the main unresolved design problem and now has a defined technical strategy.

The Forerunner 265 supports scalable system fonts at explicit pixel sizes. Its fixed `FONT_XTINY` is already about 34 px tall, so Garmin's named bitmap sizes are not appropriate for small metadata by name alone.

#### Display numerals

Prototype in this order:

1. `BionicBold` system vector font
2. `RobotoCondensedBold` system vector font
3. one custom bitmap numeric font filtered to required glyphs if the system faces do not have enough STACK personality

Target display size is approximately 142–160 px, subject to actual measured glyph bounds.

The final main time must:

- look like real display typography
- feel heavy and condensed
- avoid seven-segment / LED-clock character
- avoid obvious hand-assembled rectangle joints
- remain readable at glance speed

The hand-built prototype digit renderer is **not** the target final typography system.

#### Utility type

Use scalable system type at explicit sizes, approximately:

- day/date: 22–24 px
- battery: 20–22 px
- steps / temperature: 22–24 px

Measure every string with `getTextDimensions()` before final positioning.

## Graphic pieces

Develop a small reusable set of chunky STACK shapes rather than drawing a tower.

Candidate pieces:

- 2×1 block
- stepped / L block
- hollow square
- slot block inspired by Runner Icon geometry
- bolt
- simple shoe/run mark
- weather mark
- battery block/bar

Some pieces are functional icons. Others are pure graphic punctuation.

Decorative pieces should feel intentional and may change position or accent over time without implying training progress.

## Data presentation

Avoid conventional labels such as:

- `STEPS 6247`
- `BATTERY 82%`
- dense grids of complications

Prefer direct graphic treatment:

- run icon + `6.2K`
- temperature icon + `84°`
- battery symbol/bar + `82%`

Color and geometry should help recognition, but the numeric value remains readable.

For secondary data, the Garmin Complications API is the preferred long-term abstraction because the Forerunner 265 can expose battery, steps, weekday/date, current weather, and current temperature without any STACK connection.

## High-power / wake state

When the user raises the wrist, the full face may use the complete color treatment.

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
- day/date
- at most one tiny accent detail
- no decorative field of bright blocks

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
- real display typography replaces prototype geometric digits
- high-power and low-power states both feel intentional
- steady-state memory leaves meaningful headroom under the 128 KiB watch-face limit
- no STACK account or network connection is required

## Immediate next milestone

Do **not** keep tuning the current geometric digits.

Next implementation pass:

1. prototype `BionicBold` vector numerals
2. prototype `RobotoCondensedBold` vector numerals
3. render a standard grid of test times from `WATCH_FACE_LAYOUT_SPEC.md`
4. choose the display face
5. measure actual glyph bounds
6. lock OFFSET coordinates from those measurements
7. then restore/finalize secondary data and decorative pieces
