# STACK Watch Face

## Product intent

The STACK watch face is a **brand object first and a utility second**.

It should look like a watch face STACK designed, not like a Garmin dashboard wearing STACK colors.

The face does **not** need to connect to the STACK app, represent the Build tower, or expose training-plan data. It should be useful on its own and rely only on Garmin-local data for v1.

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

### Required v1 information

1. Time
2. Day + date
3. Battery
4. Temperature/weather when available
5. One optional activity metric, initially steps

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

The current STACK app uses Space Mono as its data voice. The watch face should preserve that attitude but is not required to use the exact web font.

v1 should introduce two watch-specific font roles:

- **STACK Display** — oversized, heavy, squared/condensed numeric glyphs for the main time.
- **STACK Mono** — compact mono/tabular text for date, temperature, battery, and secondary figures.

The main time must not look like a stock Garmin numeric font in the final design.

Use custom font resources trimmed to the glyphs actually required by the watch face where practical.

### Graphic pieces

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

- shoe/run icon + `6.2K`
- temperature icon + `84°`
- battery symbol/bar + `82`

Color and geometry should help recognition, but the numeric value remains readable.

## High-power / wake state

When the user raises the wrist, the full face may use the complete color treatment.

A short wake animation is allowed if it remains subtle and power-safe. Preferred behavior:

- main numerals snap or settle into place
- one small STACK block slides/lands
- total visual motion roughly 250–400 ms

Do not build a continuous arcade animation.

## Always-on / low-power state

Always-on mode is a deliberately different composition, not a dim copy of the full face.

Keep it mostly black with:

- simplified or outline/dim time
- day/date
- at most one tiny accent detail
- no decorative field of bright blocks

The face must remain readable while respecting Garmin AMOLED low-power constraints and burn-in guidance.

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
- current STACK colors replace the legacy Garmin palette
- the tower is removed
- custom numeric typography is in place
- high-power and low-power states both feel intentional
- no STACK account or network connection is required
