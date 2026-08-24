# STACK Watch Face Layout Spec — OFFSET

This is the design blueprint for the canonical STACK watch face on the Garmin Forerunner 265.

Read together with:

- `WATCH_FACE.md` — product intent
- `WATCH_FACE_PLATFORM_CONSTRAINTS.md` — hardware/API constraints

The goal is to stop eyeballing every simulator pass and instead design against a repeatable coordinate system.

## Design target

OFFSET should feel like a small STACK poster on the wrist:

- oversized graphic time
- strong asymmetry
- bright STACK color
- sparse utility data
- chunky punctuation shapes
- black AMOLED canvas

It should **not** look like:

- a centered digital clock
- a Garmin complication grid
- a seven-segment display
- a miniature STACK app dashboard
- a Build tower

## Canvas

```text
416 × 416
center = 208,208
physical radius = 208
critical radius = 188
accent radius = 196
```

Use an 8 px base spacing rhythm for intentional alignment, but optical alignment wins over mechanical grid alignment.

## Composition model

OFFSET is made from six visual objects:

1. **Hour** — white, upper-left, dominant
2. **Minute** — lime, lower-right, dominant
3. **Colon** — lime punctuation between the two time masses
4. **Date badge** — blue, compact, top-center
5. **Utility system** — battery upper-right; weather + steps lower-left
6. **Decorative punctuation** — one purple block in leftover negative space

The time must occupy the majority of the optical weight.

## No STACK wordmark on-face

The face does not need the word `STACK` displayed as a logo.

The visual system itself is the branding.

Removing the wordmark:

- frees scarce top-center space
- avoids competing with date/battery
- makes the face feel like a product rather than branded merch

## Primary layout zones

Coordinates below are design targets, not immutable API constants. Final values should be based on actual vector-font bounds.

### Date badge

Target zone:

```text
center x: 208
center y: 42–50
width: measured text + 24 px
height: ~32 px
```

Visual:

```text
┌──────────┐
│  MON 24  │
└──────────┘
```

Rules:

- blue fill `#287DFF`
- white text
- 22–24 px condensed bold type
- modest radius, not a giant pill
- keep entire badge inside the critical-content circle

### Battery

Target zone:

```text
x: 286–350
baseline y: 78–96
```

Do **not** place battery text at the same vertical level as the date badge near the top arc; the available width there collapses rapidly.

Preferred treatment:

```text
▭ 82%
```

Rules:

- lime battery outline/fill
- white value
- 20–22 px type
- compact total width
- right edge ideally ≤ 360 px at this Y

### Hour group

Target optical bounds:

```text
x: 34–194
y: 64–220
```

Rules:

- white
- **BionicBold system vector font**
- current implementation target: **238 px font size**
- always render two digits, including a leading zero in 12-hour mode
- two digits form one visual mass
- allow 1–4 px intentional crop into the accent zone if it increases energy
- hour should feel heavier than all utility information combined

The leading zero is intentional graphic structure, not a formatting accident. `03` is preferred to `3` because the two-digit mass keeps OFFSET balanced across every hour.

### Minute group

Target optical bounds:

```text
x: 208–372
y: 194–350
```

Rules:

- STACK lime
- **BionicBold system vector font**
- same size/family as hour
- approximately equal or slightly greater visual weight than hour
- keep the diagonal relationship tight enough that hour + colon + minute read as one composition
- bottom-right is visually dangerous: at `y=360`, the critical safe range ends around `x=319`

### Colon

Target:

```text
center x: 208–216
upper dot y: 164–174
lower dot y: 190–202
radius: 6–7
```

Rules:

- lime
- should read as punctuation between groups, not attach visually to the hour
- can shift 2–4 px based on active glyphs if optical balance requires it

## Lower-left utility system

The lower-left is functional, not decorative filler.

### Weather

Target zone:

```text
x: 48–150
y: 260–300
```

Preferred treatment:

```text
☀ 84°
```

Rules:

- yellow STACK-style sun mark
- white temperature value
- 22–24 px condensed bold type
- use Garmin cached weather; no STACK connection
- respect the user's temperature unit setting
- if no weather is available, render `--°` rather than hiding the unit or crashing

### Steps

Target zone:

```text
x: 52–160
y: 312–350
```

Preferred treatment:

```text
[shoe] 6.2K
```

Rules:

- chunky cyan shoe/run mark
- white value
- no `STEPS` label
- 22–24 px value type
- zero in simulator must still look intentional

The previous separate cyan decorative block is removed. Cyan now has a job as the steps/run mark.

## Decorative punctuation

### Purple block

Target zone:

```text
x: 330–380
y: 130–185
```

Use one compact stepped/L form.

It is pure visual punctuation. It does not indicate progress, training, or status.

### Yellow accent

Yellow is reserved for weather in the current OFFSET composition. Do not add extra arbitrary yellow dots.

## Type system

### Display numerals — LOCKED

**BionicBold is the v1 display family.**

Simulator testing showed it has the right combination of:

- heavy weight
- compact width
- rounded/squared personality
- clear counters
- strong glance readability
- enough character to feel non-Garmin without a custom font asset

Current implementation size: **238 px**.

Do not return to hand-built geometric digits or seven-segment construction.

### Utility type

Use scalable system type at explicit sizes:

- Date: 24 px `RobotoCondensedBold`
- Battery: 20 px `RobotoCondensedBold`
- Weather: 24 px `RobotoCondensedBold`
- Steps: 24 px `RobotoCondensedBold`

Do not use `FONT_XTINY` for these roles on Forerunner 265; it is 34 px tall.

## Dynamic layout rules

The layout must survive every possible time, not just one screenshot.

Test at least these times:

- `00:00`
- `01:11`
- `03:20`
- `08:58`
- `10:42` — concept reference
- `11:11`
- `12:59`
- `20:08`
- `23:59`

### Leading zero — LOCKED

- **24-hour mode:** always two-digit hour
- **12-hour mode:** always two-digit hour

The leading zero is retained for visual balance.

## Measurement, not guesswork

Every font-based element should be placed from measured or simulator-verified bounds.

Implementation should:

1. obtain vector fonts once during initialization
2. use text-width measurement for variable-width utility content
3. position the main time from tested optical anchors
4. use optical offsets rather than assuming a generic centered grid

## Secondary data strategy

Current v1 paths:

- time — system clock
- date — Gregorian weekday/date
- battery — System stats
- steps — ActivityMonitor
- weather / temperature — Garmin cached `Toybox.Weather` data

No STACK network connection is required.

## AOD layout

Always-on is its own design.

Target concept:

```text
        10
         :
        42

       MON 24
```

Rules:

- gray, thin vector font
- centered or near-centered rather than copying OFFSET exactly
- only one tiny lime accent line/dot if luminance budget permits
- no purple/cyan/yellow decorative blocks
- no steps, weather, or battery in v1 AOD
- shift static content slightly over time if required for burn-in mitigation

## Visual acceptance tests

A screenshot does not pass because all elements are technically visible.

High-power OFFSET passes only when:

- the time reads first from arm's length
- BionicBold feels oversized and intentional
- there is no obvious invisible centered grid
- date and battery fit without arc clipping
- weather and steps read as deliberate compact utility units
- the purple block fills negative space without competing with the time
- the face uses the circular canvas intentionally
- nothing looks like it came from Garmin's stock watch-face UI

## Next implementation milestone

1. validate the 238 px BionicBold composition across the standard test-time grid
2. adjust only optical anchors/scale from those screenshots
3. validate cached weather behavior in simulator and on-device
4. profile steady-state memory
5. validate AOD with Garmin's screen heat map
6. then consider accent-color settings or alternate layouts
