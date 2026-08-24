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
5. **Utility pair** — battery upper-right + one secondary metric lower-left
6. **Decorative punctuation** — purple and cyan blocks in leftover negative space

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
center y: 48–56
width: 104–116
height: 30–34
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
x: 286–348
baseline y: 90–104
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
x: 48–198
y: 82–220
```

Rules:

- white
- display font 142–160 px
- two digits form one visual mass
- allow 1–4 px intentional crop into the accent zone if it increases energy
- no visible seven-segment joints
- no large gaps between digits
- hour should feel heavier than all utility information combined

### Minute group

Target optical bounds:

```text
x: 210–365
y: 220–344
```

Rules:

- STACK lime
- display font same family as hour
- approximately equal or slightly greater visual weight than hour
- avoid descending so low that right-hand digits collide with the circle arc
- bottom-right is visually dangerous: at `y=360`, the critical safe range ends around `x=319`

### Colon

Target:

```text
center x: 208–218
upper dot y: 178–188
lower dot y: 205–215
radius: 6–8
```

Rules:

- lime
- should read as punctuation between groups, not attach visually to the hour
- smaller than previous prototype passes
- can shift 2–4 px based on the active hour glyphs if optical balance requires it

## Secondary metric — lower-left

Default v1 metric: steps.

Target zone:

```text
x: 50–150
y: 255–315
```

Preferred treatment:

```text
[run mark] 6.2K
```

Rules:

- one compact horizontal unit
- electric-blue icon
- white value
- no `STEPS` label
- optional yellow dot may sit adjacent as decorative punctuation, not beneath as a disconnected second row
- 22–24 px value type

If the metric is zero in simulator, the treatment must still look intentional.

## Decorative punctuation

### Purple block

Target zone:

```text
x: 325–370
y: 135–190
```

Use a compact stepped/L form.

It is pure visual punctuation. It does not indicate progress, training, or status.

### Cyan block

Target zone:

```text
x: 95–190
y: 330–365
```

Use a horizontal stepped shape.

Keep it visually subordinate to the lime minute group.

### Yellow accent

Use at most one small yellow object in the high-power face.

Preferred location: adjacent to the lower-left utility group.

Do not scatter multiple arbitrary dots.

## Type system

### Display numerals

Prototype priority:

1. `BionicBold` system vector font at 148–160 px
2. `RobotoCondensedBold` system vector font at 150–164 px
3. one custom filtered numeric font if neither has the right personality

We should test the real glyphs before drawing another custom geometric number system.

Required characteristics:

- heavy
- condensed enough to fit two digits in ~150 px
- squared / assertive
- large counters
- readable at glance speed
- no digital-clock / seven-segment character

### Utility type

Use system vector type at explicit sizes:

- Date: 22–24 px bold condensed
- Battery: 20–22 px bold condensed
- Steps / temperature: 22–24 px bold condensed

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

Why:

- `1` is narrow
- `0` / `8` are wide and dense
- `4` / `7` can create unusual optical gaps
- 12-hour mode can remove a leading zero depending on final product decision

### Leading zero

Decision for v1:

- **24-hour mode:** always two-digit hour
- **12-hour mode:** test both, but default preference is **no leading zero** if the typography/layout remains balanced

If no-leading-zero creates a weak upper-left mass, a leading zero is acceptable as a deliberate graphic choice.

## Measurement, not guesswork

Every font-based element must be placed from measured dimensions.

Implementation should:

1. obtain vector font once
2. call `dc.getTextDimensions()` for actual strings
3. position the group from measured width/height
4. use optical offsets from that measured anchor

Do not hard-code an assumed glyph width as if all digits are monospaced unless the selected font actually is.

## Secondary data strategy

Preferred data source hierarchy:

- time — system clock
- date — Garmin native weekday/date complication or Gregorian fallback
- battery — Garmin battery complication or System fallback
- steps — Garmin steps complication or ActivityMonitor fallback
- current weather / temperature — Garmin native complications

Weather is not required for the next visual pass. First stabilize typography and composition.

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
- no steps or battery unless later testing proves it worthwhile
- shift static content slightly over time if required for burn-in mitigation

## Visual acceptance tests

A screenshot does not pass because all elements are technically visible.

High-power OFFSET passes only when:

- the time reads first from arm's length
- the numerals feel like type, not assembled rectangles
- there is no obvious invisible centered grid
- date and battery fit without arc clipping
- lower-left metric reads as one designed unit
- decorative blocks fill negative space without competing with the time
- the face uses the circular canvas intentionally
- nothing looks like it came from Garmin's stock watch-face UI

## Next implementation step

Before another layout tweak:

1. remove the hand-built display digit renderer from the visual path
2. prototype `BionicBold` vector numerals at several explicit sizes
3. prototype `RobotoCondensedBold` as comparison
4. capture a simulator grid of the required test times
5. choose the display font
6. only then lock final OFFSET coordinates

That is the next design milestone.
