# Skomelr Quantum — STACK Garmin Font Plan

## Selected font

Display/numeric font: **Skomelr Quantum** by Storytype Studio.

Use it for:

- hero time
- primary metric numerals

Do not replace it with hand-built polygon digits unless a future platform limitation requires it.

## Licensing status

The project owner reviewed the Skomelr Quantum license and cleared it for STACK/Garmin use.

Project policy remains:

- keep the raw OTF/TTF source file local and gitignored
- commit only the generated Garmin bitmap font resources used by the watch face
- do not redistribute the raw source font from this public repository

Place the licensed source file locally at:

`watch-face/fonts-src/Skomelr Quantum.otf`

## Garmin conversion

Garmin custom font resources use bitmap font atlases. The repository includes:

`watch-face/tools/gen_fonts.py`

The generator is adapted from the MIT-licensed WinterTime-Watchface font pipeline and creates tintable AngelCode BMFont `.fnt` + PNG atlases.

Generated resources include:

- `StackTime` — `0123456789:`
- `StackMetric` — `0123456789.%-`

The Forerunner 265 uses the 416×416 resource set.

Because the generated glyphs are white alpha masks, Monkey C can call `dc.setColor()` before drawing the font. That supports:

- hour color
- minute color
- colon color
- metric number colors

## Color settings

Draw the hero time as three separately measured strings:

- hour
- colon
- minute

Do not draw `HH:MM` as one string when user-selectable per-group colors are enabled.
