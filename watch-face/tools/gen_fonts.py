#!/usr/bin/env python
"""Generate tintable Connect IQ bitmap fonts for STACK.

Adapted from the MIT-licensed WinterTime-Watchface font generator by
Christopher Fennell (2026). See /THIRD_PARTY_NOTICES.md.

The source Skomelr font is intentionally not committed. Put a properly licensed
copy at watch-face/fonts-src/Skomelr Quantum.otf before running this script.
"""
from pathlib import Path
from PIL import Image, ImageChops, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / "fonts-src" / "Skomelr Quantum.otf"
PAD = 2
BASE_RES = 416
DIGITS = "0123456789"

# The outline stroke is measured on a render this many times larger. See
# outline_cell() for why the 1x lattice is not good enough.
SUPERSAMPLE = 4

FONTS = [
    {"name": "stack_time", "size": 94, "chars": DIGITS + ":"},
    {"name": "stack_time_hero", "size": 104, "chars": DIGITS},
    {"name": "stack_time_outline", "size": 104, "chars": DIGITS, "outline": 2},
    {"name": "stack_metric", "size": 32, "chars": DIGITS + ".%-:K"},
]

# Start with the primary fr265 panel and prepare the common round AMOLED sizes we
# are most likely to add next. Bitmap fonts do not scale at runtime.
TARGETS = [
    (416, 416, ROOT / "resources-round-416x416" / "fonts"),
    (454, 454, ROOT / "resources-round-454x454" / "fonts"),
    (390, 390, ROOT / "resources-round-390x390" / "fonts"),
    (360, 360, ROOT / "resources-round-360x360" / "fonts"),
]

FONTS_XML = """<resources>
    <fonts>
        <font id="StackTime" filename="stack_time.fnt" antialias="true" />
        <font id="StackTimeHero" filename="stack_time_hero.fnt" antialias="true" />
        <font id="StackTimeOutline" filename="stack_time_outline.fnt" antialias="true" />
        <font id="StackMetric" filename="stack_metric.fnt" antialias="true" />
    </fonts>
</resources>
"""


def next_pow2(n):
    p = 1
    while p < n:
        p <<= 1
    return p


def disc_erode(img, radius):
    """Erode by a Euclidean disc: the pointwise minimum over the disc's offsets.

    Pillow only ships MinFilter, whose kernel is a square, and a square insets
    an edge by radius * (|nx| + |ny|). That is radius on horizontal and
    vertical edges but radius * sqrt(2) on 45-degree ones, so a square-eroded
    outline comes out 41% heavier on the diagonals. Skomelr's digits are built
    from exactly those two edge families, which is what made the stroke weight
    visibly uneven on glyphs like the 9.
    """
    width, height = img.size
    padded = Image.new("L", (width + radius * 2, height + radius * 2), 0)
    padded.paste(img, (radius, radius))
    eroded = None
    limit = radius * radius
    for dy in range(-radius, radius + 1):
        for dx in range(-radius, radius + 1):
            if dx * dx + dy * dy > limit:
                continue
            shifted = padded.crop(
                (radius + dx, radius + dy, radius + dx + width, radius + dy + height))
            eroded = shifted if eroded is None else ImageChops.darker(eroded, shifted)
    return eroded


def outline_cell(glyph, size, outline):
    """A uniform-width inner stroke for one glyph.

    A disc drawn on the 1x lattice is still lopsided at these radii, so the
    band is built on a SUPERSAMPLE-times render and boxed back down, which also
    supplies the antialiasing. The stroke never leaves the glyph's own bounding
    box, so every metric in the .fnt is unchanged.
    """
    hi_font = ImageFont.truetype(str(SRC), size * SUPERSAMPLE)
    hi_left, hi_top, _, _ = hi_font.getbbox(glyph["ch"])
    margin = outline + 1
    hi_margin = margin * SUPERSAMPLE
    cell = Image.new("L", (
        glyph["w"] * SUPERSAMPLE + hi_margin * 2,
        glyph["h"] * SUPERSAMPLE + hi_margin * 2), 0)
    ImageDraw.Draw(cell).text(
        (-hi_left + hi_margin, -hi_top + hi_margin), glyph["ch"], font=hi_font, fill=255)
    band = ImageChops.subtract(cell, disc_erode(cell, outline * SUPERSAMPLE))
    small = band.resize(
        (glyph["w"] + margin * 2, glyph["h"] + margin * 2), Image.BOX)
    return small.crop((margin, margin, margin + glyph["w"], margin + glyph["h"]))


def generate_font(spec, size, outdir):
    font = ImageFont.truetype(str(SRC), size)
    ascent, descent = font.getmetrics()
    line_height = ascent + descent
    outline = spec.get("outline", 0)

    glyphs = []
    for ch in spec["chars"]:
        left, top, right, bottom = font.getbbox(ch)
        glyphs.append({
            "ch": ch,
            "l": left,
            "t": top,
            "w": max(right - left, 0),
            "h": max(bottom - top, 0),
            "adv": int(round(font.getlength(ch))),
        })

    max_w = max((g["w"] for g in glyphs), default=1)
    atlas_w = next_pow2(max(128, max_w + PAD * 2))
    x, y, row_h = PAD, PAD, 0

    for g in glyphs:
        if x + g["w"] + PAD > atlas_w:
            x = PAD
            y += row_h + PAD
            row_h = 0
        g["x"], g["y"] = x, y
        x += g["w"] + PAD
        row_h = max(row_h, g["h"])

    atlas_h = next_pow2(y + row_h + PAD)
    atlas = Image.new("RGBA", (atlas_w, atlas_h), (255, 255, 255, 0))

    for g in glyphs:
        if not g["w"] or not g["h"]:
            continue
        if outline > 0:
            cell = outline_cell(g, size, outline)
        else:
            cell = Image.new("L", (g["w"], g["h"]), 0)
            ImageDraw.Draw(cell).text((-g["l"], -g["t"]), g["ch"], font=font, fill=255)
        white = Image.new("RGBA", (g["w"], g["h"]), (255, 255, 255, 0))
        white.putalpha(cell)
        atlas.alpha_composite(white, (g["x"], g["y"]))

    png_name = spec["name"] + ".png"
    atlas.save(outdir / png_name)

    lines = [
        f'info face="{spec["name"]}" size={size} bold=0 italic=0 charset="" unicode=1 stretchH=100 smooth=1 aa=1 padding=0,0,0,0 spacing=1,1 outline=0',
        f"common lineHeight={line_height} base={ascent} scaleW={atlas_w} scaleH={atlas_h} pages=1 packed=0 alphaChnl=1 redChnl=4 greenChnl=4 blueChnl=4",
        f'page id=0 file="{png_name}"',
        f"chars count={len(glyphs)}",
    ]

    for g in glyphs:
        lines.append(
            "char id=%d x=%d y=%d width=%d height=%d xoffset=%d yoffset=%d xadvance=%d page=0 chnl=15"
            % (ord(g["ch"]), g["x"], g["y"], g["w"], g["h"], g["l"], g["t"], g["adv"])
        )
    lines.append("kernings count=0")
    (outdir / f'{spec["name"]}.fnt').write_text("\n".join(lines) + "\n", encoding="utf-8")


def main():
    if not SRC.exists():
        raise SystemExit(
            "Missing licensed font source: watch-face/fonts-src/Skomelr Quantum.otf\n"
            "See docs/FONT_SKOMELR_QUANTUM.md before adding the file."
        )

    for w, h, outdir in TARGETS:
        outdir.mkdir(parents=True, exist_ok=True)
        scale = min(w, h) / float(BASE_RES)
        print(f"== {w}x{h} -> {outdir.relative_to(ROOT)} ==")
        for spec in FONTS:
            size = max(8, int(round(spec["size"] * scale)))
            generate_font(spec, size, outdir)
            print(f"   {spec['name']}: {size}px")
        (outdir / "fonts.xml").write_text(FONTS_XML, encoding="utf-8")

    print("Done.")


if __name__ == "__main__":
    main()
