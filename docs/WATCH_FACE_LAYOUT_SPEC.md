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

### Secondary data slots

Secondary data is not hand-placed. OFFSET has three slots, and any supported
metric can be rendered into any of them without touching the layout.

```text
slot   position           x    centre y   mark height   type
A      upper-right        288      84        16 px      26 px
B      lower-left upper    52     250        30 px      28 px
C      lower-left lower    52     300        28 px      34 px
```

A slot draws a graphic mark at `x`, then the value at `x + markWidth + 8`,
both vertically centred on the slot's centre y. The mark reports its own
advance, so marks of different widths line their values up correctly.

Default assignment - see `docs/WATCH_FACE.md` for why B is steps, not weather:

```text
A -> Battery      lime battery outline + 50%
B -> Steps        blue runner + 6.2K
C -> Temperature  yellow disc + 62°
```

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
center x:    hour right edge + 19  (= 253 with the current hour box)
upper dot y: 152
lower dot y: 190
radius:      11  (6 in always-on)
```

Rules:

- lime
- anchored to the **measured** right edge of the hour group, not a fixed x, so it
  bridges the two masses whatever the digits are
- must stay clear of the minute box top (`y = 214`)
- the gap is 19 px, not 14: at 14 the colon crowded a `11` hour

## Lower-left utility system

The lower-left is functional, not decorative filler.

### Marks

Every mark is drawn into a box `h` tall and returns its advance. Marks are
built from primitives, not resources, so they cost no memory and scale with
the slot.

| Metric | Mark | Accent |
|---|---|---|
| Battery | outline, proportional fill, terminal nub | lime `#A6FF1A` |
| Temperature | solid disc | yellow `#FFD21A` |
| Steps | running figure | blue `#287DFF` |
| Heart rate | two discs + triangle | pink `#FF5AC8` |
| Body battery | two-quad bolt | cyan `#2BC6D6` |
| Notifications | rounded bubble + tail | purple `#A14CFF` |
| Sunrise / sunset | disc over a horizon bar | yellow `#FFD21A` |

#### Running mark

Four shapes: a head circle, one arm-and-torso stroke, two legs. That is the
whole glyph. An anatomically detailed runner was tried and rejected - at 30 px
the limbs merge into a tangle, so the silhouette has to carry the idea on its
own. Do not add feet, hands, elbows or joints.

#### Weather mark

A solid disc. Do not build a detailed meteorological icon. Weather is
deliberately the smaller of the two lower-left slots: it must read as
secondary to the time, which an oversized disc and 48 px type did not.
- use Garmin cached weather; no STACK connection
- respect the user's temperature unit setting
- if no weather is available, render `--°` rather than hiding the unit or crashing

### Steps

Steps are a default OFFSET metric again, in slot B, as runner + `6.2K`. The
value stays small and subordinate; it must never compete with the time.

Cyan remains decoration and carries no meaning.

## Decorative punctuation

### Cyan block

```text
104, 330  50 x 24
104, 350  68 x 24
```

A chunky horizontal stepped form with the taller part on the left, balancing the
lime minute mass across the lower half. Pure decoration.

Its right edge stays at `x = 172`. The minute group starts at `x = 182` and its
knockouts bleed `BLEED * cap` (about 4 px) to the left of that, so anything in
the lower-left must keep at least 6 px clear of the minute box or the numerals
will paint background over it.

### Purple block

```text
322, 124  32 x 30
346, 150  36 x 32
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

#### Construction: solids, then knockouts

Each digit is a set of SOLIDS filled in the glyph colour, then KNOCKOUTS filled
in the **background** colour. Most digits are one chamfered silhouette plus a
carved hole or two.

This exists to kill seams. The first implementation mitred a ring into four
trapezoids that met exactly edge to edge; anti-aliasing gave each edge partial
coverage, the two halves composited to less than solid, and a hairline showed
through. The glyphs read as folded, low-poly assemblies rather than type.

The rule that fixes it:

- a **knockout edge is a glyph edge**, drawn exactly once, so it always
  anti-aliases cleanly
- seams only occur where two polygons of the **same colour** meet edge to edge
- therefore solids overlap solids, and knockouts overlap knockouts, and no
  construction line is ever visible

The consequence to remember: because counters are carved in the background
colour, digits must be drawn onto a flat background. That is what the OFFSET
canvas is, but it rules out drawing numerals over artwork.

#### Proportions, as fractions of cap height:

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

Every polygon must be **convex**: Garmin's `fillPolygon` does not reliably fill
concave outlines, and a ring cannot be one polygon at all.

#### Weight

`drawNumber` takes a weight multiplier that scales every stroke - including the
diagonals of `2`, `4` and `7`, whose far edges are derived by perpendicular
offset rather than hard-coded, so they thin with everything else.

```text
1.00  OFFSET poster weight
0.24  always-on hairline (StackDigits.AOD_WEIGHT)
```

Chamfers scale more slowly than strokes (`0.35 + 0.65 * weight`) so thin
numerals do not turn into octagons. The `1` additionally clamps its chamfer to
30% of its stem: without that clamp the hairline `1` collapsed into an arrow.

Do not return to seven-segment construction, and do not add a bitmap font
resource for the time without profiling memory first.

### Utility type

Use scalable system type at explicit sizes:

- Date: 24 px `RobotoCondensedBold`
- Slot A: 26 px `RobotoCondensedBold`
- Slot B: 28 px `RobotoCondensedBold`
- Slot C: 34 px `RobotoCondensedBold`

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

Always-on is **not** its own design. It is OFFSET in low power.

It reuses the same hour box, the same minute box, the same colon anchoring, the
same date position and the same slot A - it just drops colour, drops the
decoration, and draws the numerals at hairline weight. Waking should read as
colour and detail turning on, never as the face rearranging itself.

There is deliberately no second geometry system to keep in sync.

Rules:

- same StackDigits numerals at `AOD_WEIGHT`, drawn in AOD gray `#343C43`
- same hour and minute boxes as OFFSET
- colon in the same place, radius 6 instead of 11
- date in the same place, gray text with **no blue badge fill**
- slot A (battery) kept, gray
- removed: runner, steps, weather, cyan block, purple block, all bright colour

#### Burn-in drift

The whole composition shifts on an eight-step cycle, one step per five minutes,
driven by `((hour * 60 + minute) / 5) % 8`. The offsets walk a 1 px ring around
the origin. It is deterministic, costs nothing, and is imperceptible in use.

#### Lit-pixel budget

Measured inside the display circle, from real simulator captures:

```text
9.0%   worst case (12:00 - four heavy glyphs)
8.5%   10:42
```

Under Garmin's 10% always-on guidance. **Re-measure after any AOD change.**
This is a tight budget and it moved a lot during tuning:

```text
weight 0.45   13.9%   over
weight 0.28   10.2%   over on heavy times
weight 0.24    9.0%   shipped
```

Battery is the first thing to drop if the budget is ever exceeded again.

## Visual acceptance tests

A screenshot does not pass because all elements are technically visible.

High-power OFFSET passes only when:

- the time reads first from arm's length
- the numerals feel oversized, chamfered and intentional
- there is no obvious invisible centered grid
- date and battery fit without arc clipping
- the runner, steps and weather read as deliberate compact utility units
- no numeral shows a visible internal seam or facet
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
| `00:58` (12-hour mode shows `12:58`) | `screenshots/offset-0058.png` |
| `11:59` | `screenshots/offset-1159.png` |
| `23:59` (12-hour mode shows `11:59`) | `screenshots/offset-2359.png` |
| Always-on `10:42` | `screenshots/always-on-1042.png` |
| Always-on `11:59` | `screenshots/always-on-1159.png` |
| Always-on worst-case lit pixels | `screenshots/always-on-worst-case.png` |
| Steps value formatting | `screenshots/offset-steps-formatting.png` |

The simulator reports no activity data, so the shipped captures show steps as
`0` - the correct empty state. `offset-steps-formatting.png` was taken with the
step count stubbed, to confirm `12.3K` formats and fits.

`StackWatchFaceView` carries a screenshot harness for reproducing these:
`PIN_TIME` pins the clock (e.g. `1042`) and `PIN_SLEEP` forces the always-on
state. Both must be `-1` / `false` in anything shipped.
