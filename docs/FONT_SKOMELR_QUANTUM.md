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
- `StackTimeHero` — larger filled `0123456789` active-time glyphs
- `StackTimeOutline` — transparent-interior outline glyphs generated from the same source
- `StackMetric` — `0123456789.%-`

The Forerunner 265 uses the 416×416 resource set.

Because the generated glyphs are white alpha masks, Monkey C can call `dc.setColor()`
before drawing the font. Active hero glyphs are fixed to off-white; metric glyphs
remain tintable for the three-slot palette.

## Hero treatment

The active face measures and centers two two-digit groups without a colon:

- outlined white hour
- filled white minute

The outline atlas keeps its glyph interiors transparent so the masonry background
remains visible through the hour. AOD continues to use the smaller filled atlas.
