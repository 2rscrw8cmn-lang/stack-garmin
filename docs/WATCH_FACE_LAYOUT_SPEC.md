# STACK Watch Face Layout Spec — OFFSET

This is the design blueprint for the canonical STACK watch face on the Garmin Forerunner 265.

Read together with:

- `WATCH_FACE.md` — product intent
- `WATCH_FACE_PLATFORM_CONSTRAINTS.md` — hardware/API constraints

The goal is to stop eyeballing every simulator pass and instead design against a repeatable coordinate system.

Coordinates below are the values actually implemented in
`source/StackWatchFaceView.mc`, verified against the reference artwork in the
Forerunner 265 simulator.

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
5. **Utility system** — battery upper-right; runner + weather lower-left
6. **Decorative punctuation** — a cyan block lower-left and a purple block upper-right

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
top y:    26
width:    measured text + 24 px
height:   33 px
radius:   6
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
- 24 px condensed bold type
- modest radius, not a giant pill
- keep entire badge inside the critical-content circle

### Battery

Target zone:

```text
icon:  x 288, y 76, 28 x 15, pen 3, terminal nub 3 x 7
value: x 326, vertically centred on y 83
```

Do **not** place battery text at the same vertical level as the date badge near the top arc; the available width there collapses rapidly.

Preferred treatment:

```text
▭ 82%
```

Rules:

- lime battery outline, internal fill proportional to charge, terminal nub
- white value
- 26 px type
- compact total width
- right edge ideally <= 360 px at this Y

### Hour group

Optical box (left, top, right, bottom):

```text
46, 66 -> 240, 206
```

Fitted result for every hour: cap height **140**, group width **182**,
drawn at `x = 52, y = 66`, right edge **234**.

Rules:

- white
- **StackDigits polygon numerals** (see `source/StackDigits.mc`)
- always render two digits, including a leading zero in 12-hour mode
- two digits form one visual mass
- hour should feel heavier than all utility information combined
- the group is scaled to the box, centred horizontally and **bottom aligned**,
  so the baseline never moves between times

The leading zero is intentional graphic structure, not a formatting accident. `03` is preferred to `3` because the two-digit mass keeps OFFSET balanced across every hour.

### Minute group

Optical box (left, top, right, bottom):

```text
178, 214 -> 366, 352
```

Fitted result for every minute: cap height **138**, group width **179**,
drawn at `x = 182, y = 214`, right edge **362**, bottom **352**.

Rules:

- STACK lime
- **StackDigits polygon numerals**, same family as the hour
- approximately equal visual weight to the hour; the minute is two full-width
  digits where the reference hour is `1` plus `0`, so it reads at least as heavy
- keep the diagonal relationship tight enough that hour + colon + minute read as one composition
- bottom-right is the dangerous corner; the fitted box was chosen so the worst
  digit pair peaks at radius **200.5**

### Colon

```text
center x:    hour right edge + 14  (= 248 with the current hour box)
upper dot y: 152
lower dot y: 190
radius:      11
```

Rules:

- lime
- anchored to the **measured** right edge of the hour group, not a fixed x, so it
  bridges the two masses whatever the digits are
- must stay clear of the minute box top (`y = 214`)

## Lower-left utility system

The lower-left is functional, not decorative filler.

### Running mark

```text
bounding box: x 52-110, y 214-274
```

Rules:

- electric blue `#287DFF`
- chunky STACK pictogram assembled from tapered convex quads plus a head circle
- **no numeric value in v1** - it is a mark, not a metric

### Weather

```text
disc:  centre 76, 298  radius 20
value: x 110, vertically centred on y 298
```

Preferred treatment:

```text
● 84°
```

Rules:

- solid yellow disc `#FFD21A`; do not build a detailed meteorological icon
- white temperature value
- 48 px condensed bold type
- use Garmin cached weather; no STACK connection
- respect the user's temperature unit setting
- if no weather is available, render `--°` rather than hiding the unit or crashing

### Steps - NOT IN OFFSET v1

No step count and no shoe mark appear in OFFSET. Cyan is decoration here, not a
metric. Steps may return later as a different layout or a configurable option.

## Decorative punctuation

### Cyan block

```text
98, 324  54 x 26
98, 346  82 x 26
```

A chunky horizontal stepped form with the taller part on the left, balancing the
lime minute mass across the lower half. Pure decoration.

Its right edge stays at `x = 180` so it clears the minute group's left edge at
`x = 182` for every minute, including full-width pairs such as `00` and `88`.

### Purple block

```text
320, 120  34 x 32
344, 148  40 x 34
```

Use one compact stepped/L form.

It is pure visual punctuation. It does not indicate progress, training, or status.

### Yellow accent

Yellow is reserved for weather in the current OFFSET composition. Do not add extra arbitrary yellow dots.

## Type system

### Display numerals — StackDigits

**`StackDigits` is the v1 display family**: `0`-`9` drawn as convex polygons,
sized as fractions of the cap height.

BionicBold was measured as the baseline candidate and rejected. It is a rounded
grotesque - too light, too soft at the corners, and its `1` is a thin
flag-and-stem - so its silhouette differs materially from the reference.

Proportions, as fractions of cap height:

| Token | Value | Meaning |
|---|---|---|
| `ADV` | 0.620 | tabular advance per digit |
| `TRACK` | 0.060 | space between digits |
| `STEM` | 0.205 | vertical stroke |
| `BAR` | 0.200 | horizontal stroke |
| `MIDBAR` | 0.165 | shared middle stroke of 6, 8, 9 |
| `CHAM` | 0.110 | outer chamfer |
| `ICHAM` | 0.050 | counter chamfer |

A two-digit group is therefore always `2 * 0.620 + 0.060 = 1.300` cap heights
wide. Figures are **tabular**: `1` is drawn narrow and centred inside the shared
advance, so the composition never resizes between times.

Constraints that shaped the construction:

- every polygon must be **convex** - Garmin's `fillPolygon` does not reliably
  fill concave outlines, and a ring cannot be one polygon at all
- counters are therefore cut into four mitred frame pieces
- outer corners are chamfered rather than rounded, which is both closer to the
  reference and cheaper than arc approximation

Do not return to seven-segment construction, and do not add a bitmap font
resource for the time without profiling memory first.

### Utility type

Use scalable system type at explicit sizes:

- Date: 24 px `RobotoCondensedBold`
- Battery: 26 px `RobotoCondensedBold`
- Weather: 48 px `RobotoCondensedBold`

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

All 24 x 60 combinations are checked geometrically against the display circle.
Worst-case ink radius: hour **200.9**, minute **200.5**, against a physical
radius of 208.

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

Implemented geometry:

```text
hour box:   144, 82  -> 272, 162     cap 80
colon dots: 208, 182 and 208, 200    radius 5
minute box: 144, 216 -> 272, 296     cap 80
date:       centred on 208, 340      24 px
underline:  194, 358  28 x 4         lime
```

Rules:

- same StackDigits numerals, drawn in AOD gray `#343C43`
- vertically stacked and centred rather than copying OFFSET
- exactly one tiny lime accent line beneath the date
- no purple/cyan/yellow decorative blocks
- no steps, weather, battery, or runner in v1 AOD
- **lit-pixel budget: 9.0% of the display circle**, under Garmin's 10% always-on
  guidance. Re-measure after any AOD change; cap height 88 pushed it to 10.6%.

## Visual acceptance tests

A screenshot does not pass because all elements are technically visible.

High-power OFFSET passes only when:

- the time reads first from arm's length
- the numerals feel oversized, chamfered and intentional
- there is no obvious invisible centered grid
- date and battery fit without arc clipping
- the runner and weather read as deliberate compact utility units
- no step count appears
- the cyan and purple blocks fill negative space without competing with the time
- the face uses the circular canvas intentionally
- nothing looks like it came from Garmin's stock watch-face UI

## Next implementation milestone

1. validate cached weather behaviour on-device, not only in the simulator
2. re-check the AOD lit-pixel budget with Garmin's screen heat map on hardware
3. then consider accent-color settings or alternate layouts

## Verified simulator captures

Cropped from the Forerunner 265 simulator at 416 x 416.

| Capture | File |
|---|---|
| `10:42` reference time | `screenshots/offset-1042.png` |
| `08:58` | `screenshots/offset-0858.png` |
| `11:11` | `screenshots/offset-1111.png` |
| `23:59` (12-hour mode shows `11:59`) | `screenshots/offset-2359.png` |
| Always-on | `screenshots/always-on.png` |
| No weather, no battery | `screenshots/offset-no-data.png` |

`StackWatchFaceView` carries a screenshot harness for reproducing these:
`PIN_TIME` pins the clock (e.g. `1042`) and `PIN_SLEEP` forces the always-on
state. Both must be `-1` / `false` in anything shipped.
