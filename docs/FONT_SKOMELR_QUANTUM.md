# Skomelr Quantum — STACK Garmin Font Plan

## Selected font

Display/numeric font: **Skomelr Quantum** by Storytype Studio.

Use it for:

- hero time
- primary metric numerals

Do not replace it with hand-built polygon digits unless the font becomes impossible to license.

## Licensing gate

The supplied OTF in the current design handoff is the **personal-use demo**. Public sources for the font explicitly state that the demo is personal-use only and that commercial/corporate use requires a paid license.

Therefore:

- do **not** commit the supplied demo OTF to this public repository
- do **not** bundle it in a Connect IQ release
- do **not** ship it in the STACK app/watch face until the correct license has been purchased

The repository ignores `watch-face/fonts-src/*.otf` for this reason.

Once licensed, place the licensed file locally at:

`watch-face/fonts-src/Skomelr Quantum.otf`

## Garmin conversion

Garmin custom font resources use bitmap font atlases. The repository includes:

`watch-face/tools/gen_fonts.py`

The generator is adapted from the MIT-licensed WinterTime-Watchface font pipeline and creates tintable AngelCode BMFont `.fnt` + PNG atlases.

Initial output should include:

- `StackTime` — `0123456789:`
- `StackMetric` — `0123456789.%-`

The Forerunner 265 uses the 416×416 resource set.

Because the generated glyphs are white alpha masks, Monkey C can call `dc.setColor()` before drawing the font. That makes the following feasible without separate font files:

- hour color
- minute color
- colon color
- metric number colors

## Color settings

Draw the hero time as three separately measured strings:

- hour
- colon
- minute

Do not draw `HH:MM` as one string if user-selectable per-group colors are enabled.
