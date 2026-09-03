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
- lower metric values
- functional icons

#### Accent circle — radius 196

Decorative geometry may extend to radius **196 px**.

Use this zone for:

- nonessential punctuation blocks
- intentional near-edge accents
- decorative geometry that can tolerate bezel compression

#### Functional step ring — radius 188

Hero Time's segmented daily-step ring currently uses a radius of **188 px** with a deliberate bottom opening above the metric shelf.

The implementation retains a 16-slot angular system but renders 14 visible segments, omitting the two lowest slots so the metric area remains clear.

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

System vector fonts remain appropriate for utility text such as the top row and compact labels.

### STACK font strategy — resolved for v1

Hero Time uses **Skomelr Quantum** as a custom Garmin bitmap font, generated locally from the licensed source font with:

`watch-face/tools/gen_fonts.py`

The generator creates tintable AngelCode BMFont `.fnt` + PNG atlases for the supported round resource sizes.

For the Forerunner 265 resource set:

- `StackTime` uses Skomelr Quantum at approximately 94 px and contains `0123456789:` for AOD compatibility
- `StackTimeHero` uses approximately 104 px filled glyphs for active minutes
- `StackTimeOutline` uses approximately 104 px transparent-interior outline glyphs for active hours
- `StackMetric` uses Skomelr Quantum at approximately 32 px and contains `0123456789.%-`
- utility text uses Garmin system vector fonts where available

The raw OTF/TTF source remains gitignored. Generated Garmin bitmap resources are committed.

The active hero time is measured and rendered as two independent strings:

- outlined hour
- filled minute

Both are fixed to off-white and omit the colon. The separate outline atlas allows
the active masonry background to remain visible inside the hour glyphs.

Custom font text is drawn with a transparent background so glyph bounds do not punch black rectangles through the step ring or other underlying geometry.

Fallback behavior remains in the renderer for missing resources, but the committed Forerunner 265 build uses the generated Skomelr resources.

### Current implemented sizes

For the 416 × 416 Forerunner 265 resource set:

- Hero time bitmap source sizes: approximately 104 px active / 94 px AOD
- Metric bitmap source size: approximately 32 px
- Utility vector font: approximately 15 px requested size
- Metric fallback vector font: approximately 26 px requested size

Always measure rendered text before placement; custom glyph advance widths vary substantially, especially for `1`.

## Memory budget

Hard runtime ceiling: **128 KiB**.

Project working budget:

- Target steady-state usage: **≤ 90 KiB**
- Reserve / headroom: **≥ 38 KiB**

The implemented Hero Time build has been measured in the simulator at approximately **18.5 KB / 123.9 KB**, leaving substantial headroom.

Reasons for preserving headroom:

- font objects
- Garmin data access
- strings and temporary objects during update
- runtime overhead
- future settings or complication work

### Memory rules

- Never decode a full-screen bitmap for the primary face.
- Avoid full-screen `BufferedBitmap` or `Layer` objects.
- Load resources once during layout/initialization, not inside every `onUpdate()`.
- Keep custom font glyph sets filtered to required characters.
- Do not duplicate large font resources merely to change color; tint the same alpha-mask resource at draw time.
- Measure memory in the simulator before accepting new visual resources.

## AMOLED / power model

### High-power state

The full expressive STACK face belongs in high-power mode after the wrist gesture.

Current Hero Time high-power composition includes:

- outlined/filled white Skomelr hero time
- full-color Trainer Boi
- segmented daily step-goal ring
- day/date and battery row
- three configurable lower metrics
- a deterministic near-black masonry background
- black AMOLED background

Do not design anything that requires continuous animation.

### Low-power / always-on state

AMOLED always-on is not a dim copy of high-power mode.

Garmin limits always-on rendering and recommends mostly black backgrounds plus conservative lit-pixel usage and burn-in mitigation.

STACK rule:

- AOD uses a separate reduced composition.
- Black dominates.
- Hero time is subdued and monochrome.
- The step ring, lower metrics, and Trainer Boi are omitted.
- Static content shifts slightly over time for burn-in mitigation.
- Test with Simulator → **View Screen Heat Map** / burn-in simulation before release.

## Update cadence

Watch faces are intentionally restricted for battery life.

- Sleep / low-power: normally once per minute.
- High-power after gesture: updates can occur more frequently for a short period.
- Do not design anything that requires continuous animation.
- If wake animation is added later, keep it brief and limited to the high-power window.

## Data/API boundaries

Hero Time v1 uses Garmin-local APIs only and has no STACK backend dependency.

Implemented/selectable data includes:

- current time
- day/date
- battery
- daily steps and step goal progress
- daily distance
- heart rate when available
- Body Battery when available
- temperature/weather when available
- notification count
- sunrise / sunset

Data access should fail gracefully and display a neutral fallback when the device/API cannot provide a value.

### Complications remain a useful future abstraction

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

Long term, some secondary watch-face data may be simplified through the Complications API. Time remains a direct system-clock concern.

## Rendering rules

- Use `dc.getWidth()` / `dc.getHeight()` rather than assuming dimensions inside reusable helpers, even though v1 targets one device.
- Scale reusable geometry from the 416 px reference layout.
- Use measured text dimensions for placement.
- Avoid load/parse work inside every `onUpdate()`.
- Use transparent text backgrounds when text overlays functional or decorative geometry.
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
