# Watch Face Platform Constraints — Forerunner 265

This document defines the hardware and Connect IQ constraints that the STACK watch face must be designed inside.

It is intentionally implementation-oriented. `WATCH_FACE.md` defines the product intent; this file defines the box we are actually designing in.

## Target hardware

Primary and v1-only target:

- Device: Garmin Forerunner 265 (`fr265`)
- Screen: round AMOLED
- Raster: 416 × 416 px
- Center: `(208, 208)`
- Physical screen radius: `208 px`
- Display colors: 65,536
- Touch: supported by hardware, but a watch face is not an interactive screen
- Connect IQ watch-face memory limit: **131,072 bytes / 128 KiB**

The 128 KiB watch-face memory limit is a first-order design constraint. Full-screen decoded bitmaps, large bitmap-font atlases, large buffered layers, and duplicate font resources can consume the budget quickly.

## Round-screen geometry

A 416 × 416 canvas is not a 416 × 416 usable rectangle. The display is circular.

For a circle centered at `(208,208)` with radius `r`, the usable horizontal range at a given `y` is:

```text
x = 208 ± sqrt(r² - (y - 208)²)
```

This matters most near the top and bottom. A battery group that fits numerically inside `x < 416` can still be visibly clipped by the circular display.

### STACK internal safe zones

These are project rules, not Garmin API rules.

#### Critical-content circle — radius 188

Critical information must fit inside a circle of radius **188 px**.

This gives a 20 px optical inset from the physical display edge and protects text/numbers from bezel compression and clipping.

Use this zone for:

- time glyphs that must remain readable
- day/date
- battery value
- steps / temperature values
- functional icons

#### Accent circle — radius 196

Decorative geometry may extend to radius **196 px**.

Use this zone for:

- purple/cyan/yellow punctuation blocks
- nonessential edges of oversized numerals
- intentional near-edge crops

#### Outer ring — radius 196–208

Keep this black by default. Do not put critical information here.

### Critical-content width by vertical position

For the project safe radius of 188 px:

| Y | Safe X range |
| ---: | ---: |
| 30 | 148–268 |
| 40 | 124–292 |
| 50 | 106–310 |
| 60 | 92–324 |
| 70 | 80–336 |
| 80 | 70–346 |
| 100 | 54–362 |
| 120 | 42–374 |
| 140 | 33–383 |
| 160 | 26–390 |
| 180 | 22–394 |
| 200 | 20–396 |
| 240 | 23–393 |
| 280 | 34–382 |
| 320 | 57–359 |
| 360 | 97–319 |
| 380 | 132–284 |

This table is the reason top-right and bottom-right elements must move inward as they approach the top/bottom arcs.

## Typography constraints

### Built-in Garmin font sizes are large on the 265

On the Forerunner 265, Garmin publishes these standard font sizes:

| Constant | Face | Approx. size |
| --- | --- | ---: |
| `FONT_XTINY` | Roboto | 34 px |
| `FONT_TINY` | Roboto | 43 px |
| `FONT_SMALL` | Roboto | 50 px |
| `FONT_MEDIUM` | Roboto | 58 px |
| `FONT_LARGE` | Roboto | 67 px |
| `FONT_NUMBER_MILD` | Roboto | 95 px |
| `FONT_NUMBER_MEDIUM` | Roboto | 117 px |
| `FONT_NUMBER_HOT` | Roboto | 140 px |

Do **not** treat `FONT_XTINY` as small metadata type. At 34 px it is already a prominent display size on a 416 px screen.

### Scalable system fonts are supported

The Forerunner 265 supports scalable/vector system fonts through `Graphics.getVectorFont()`.

Published scalable faces include:

- `BionicBold`
- `RobotoCondensedBold`
- `RobotoCondensedRegular`
- `RobotoRegular`
- additional language-specific faces

This is important: we can request a system font at a specific pixel height instead of accepting Garmin's fixed bitmap sizes.

### STACK font strategy

Preferred order:

1. **Use a system vector font first.**
   - Test `BionicBold` for display numerals.
   - Test `RobotoCondensedBold` as the fallback display face.
   - Use `RobotoCondensedBold` / `RobotoRegular` for 18–26 px metadata.
2. If neither display font feels sufficiently STACK, introduce **one custom numeric bitmap font** filtered to only `0123456789` and required punctuation.
3. Do not ship multiple large custom display fonts on v1 unless memory profiling proves there is room.

The hand-built seven-segment / rectangle-digit approach is now considered a prototype technique, not the final typography system.

### Proposed sizes for design exploration

These are starting values, not final values:

- Hour display: 142–160 px
- Minute display: 142–160 px
- Day/date: 22–26 px
- Battery value: 20–24 px
- Steps / temperature: 22–26 px
- Micro labels: avoid where possible; if needed, 16–20 px

Always measure with `getTextDimensions()` before placement.

## Memory budget

Hard runtime ceiling: **128 KiB**.

Project working budget:

- Target steady-state usage: **≤ 90 KiB**
- Reserve / headroom: **≥ 38 KiB**

Reasons for headroom:

- font objects
- complication callbacks/data
- strings and temporary objects during update
- Garmin runtime overhead
- future accent settings

### Memory rules

- Never decode a full-screen bitmap for the primary face.
- Avoid full-screen `BufferedBitmap` or `Layer` objects.
- Prefer primitives and system vector fonts.
- Load any resource once during initialization, not inside `onUpdate()`.
- If a custom font is used, filter it to required glyphs.
- Do not duplicate large font resources merely to change color; colorize the same mask at draw time where possible.
- Measure memory in simulator before accepting new visual resources.

## AMOLED / power model

### High-power state

The full expressive STACK face belongs in high-power mode after the wrist gesture.

Use:

- full white/lime time
- blue/purple/cyan/yellow accents
- date, battery, one secondary metric
- optional short wake motion later

Garmin typically keeps the watch face in high-power mode for roughly 10 seconds after a wrist gesture.

### Low-power / always-on state

AMOLED always-on is not a dim copy of high-power mode.

Garmin limits always-on rendering to approximately 10% of the display's available pixels/luminance depending on screen-protection generation, and recommends thin type, mostly black backgrounds, and moving static elements slightly to reduce burn-in risk.

STACK rule:

- AOD uses a separate composition.
- Black dominates.
- Use thin gray time, not full white/lime poster glyphs.
- No bright decorative block field.
- Shift static content by 1–4 px over time if needed for burn-in mitigation.
- Test with Simulator → **View Screen Heat Map** / burn-in simulation before release.

## Update cadence

Watch faces are intentionally restricted for battery life.

- Sleep / low-power: normally once per minute.
- High-power after gesture: updates can occur once per second for a short period.
- Do not design anything that requires continuous animation.
- If wake animation is added later, keep it brief and limited to the high-power window.

## Data/API boundaries

Garmin watch faces have less API access than full device apps.

Appropriate v1 data:

- current time
- day/date
- battery
- steps
- current temperature/weather through Garmin complications when available

Do not design around direct GPS, compass, or live sensor access from the watch face.

### Complications are the preferred secondary-data abstraction

Forerunner 265 supports the Connect IQ Complications API.

Useful native complication types include:

- battery
- steps
- weekday + month day
- current weather condition
- current temperature
- high / low temperature
- notification count
- sunrise / sunset

Long term, secondary watch-face data should come through the Complications API rather than several separate ad hoc data paths. Time remains a direct system-clock concern.

This also gives us a clean route to the temperature/weather treatment shown in the concept mockup without connecting to STACK.

## Rendering rules

- Use `dc.getWidth()` / `dc.getHeight()` rather than assuming dimensions inside reusable helpers, even though v1 targets one device.
- Use measured text dimensions for placement.
- Avoid load/parse work inside every `onUpdate()`.
- No runtime `format()` patterns that have not been simulator-tested; simple string composition is safer for tiny watch-face strings.
- Keep decorative shapes semantically inert. They are punctuation, not implied metrics.

## Sources

Garmin references used for this constraint set:

- Device Reference — Forerunner 265: https://developer.garmin.com/connect-iq/device-reference/fr265/
- Watch Face UX Guidelines: https://developer.garmin.com/connect-iq/user-experience-guidelines/watch-faces/
- AMOLED Watch Face FAQ: https://developer.garmin.com/connect-iq/connect-iq-faq/how-do-i-make-a-watch-face-for-amoled-products/
- Graphics / scalable fonts: https://developer.garmin.com/connect-iq/core-topics/graphics/
- Resources / custom fonts: https://developer.garmin.com/connect-iq/core-topics/resources/
- App Types / watch-face restrictions: https://developer.garmin.com/connect-iq/connect-iq-basics/app-types/
- Complications: https://developer.garmin.com/connect-iq/core-topics/complications/
