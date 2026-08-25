using Toybox.Graphics as Gfx;
using Toybox.Lang;
using Toybox.Math;

//! STACK display numerals.
//!
//! Each digit is a small set of convex polygons: SOLIDS filled in the glyph
//! colour, then KNOCKOUTS filled in the background colour. A knockout edge is
//! a glyph edge, drawn exactly once, so it anti-aliases cleanly. Seams only
//! appear where two polygons of the same colour meet exactly edge to edge, so
//! solids overlap solids and knockouts overlap knockouts and the construction
//! is invisible. Most digits are one chamfered silhouette plus a carved hole.
//!
//! Because counters are carved in the background colour, digits must be drawn
//! onto a flat background - which is what the OFFSET canvas is.
//!
//! Geometry is expressed as fractions of the cap height inside a tabular
//! advance, so every hour and minute pair is exactly the same width and the
//! composition never resizes as the clock ticks.
//!
//! `weight` scales every stroke, including the diagonals of 2/4/7:
//! 1.0 is the poster weight, AOD_WEIGHT the always-on hairline.
module StackDigits {
    const ADV = 0.620;       // tabular advance per digit
    const TRACK = 0.060;     // space between digits
    const BLEED = 0.030;     // how far knockouts run past the silhouette

    const AOD_WEIGHT = 0.24;

    const _STEM = 0.215;
    const _BAR = 0.200;
    const _WAIST = 0.145;    // shared middle stroke of 6, 8, 9
    const _CHAM = 0.110;
    const _ICH = 0.045;
    const _S8 = 0.185;       // side stroke of 6, 8, 9: keeps counters open

    //! Width of a digit string in cap-height units.
    function unitWidth(text) {
        var n = text.length();
        return ADV * n + TRACK * (n - 1);
    }

    //! Draw a digit string with its top-left at (x, y).
    function drawNumber(dc, text, x, y, cap, weight, fg, bg) {
        var chars = text.toCharArray() as Lang.Array<Lang.Char>;
        var step = (ADV + TRACK) * cap;
        var cx = x;

        for (var i = 0; i < chars.size(); i++) {
            var d = chars[i].toNumber() - 48;
            if (d >= 0 && d <= 9) {
                drawDigit(dc, d, cx, y, cap, weight, fg, bg);
            }
            cx += step;
        }
    }

    // ------------------------------------------------------------------
    // primitives, all in unit coordinates against an origin and cap height
    // ------------------------------------------------------------------

    function px(v) {
        return (v + 0.5).toNumber();
    }

    function uOcta(dc, ox, oy, s, x0, y0, x1, y1, ctl, ctr, cbr, cbl) {
        dc.fillPolygon([
            [px(ox + (x0 + ctl) * s), px(oy + y0 * s)],
            [px(ox + (x1 - ctr) * s), px(oy + y0 * s)],
            [px(ox + x1 * s), px(oy + (y0 + ctr) * s)],
            [px(ox + x1 * s), px(oy + (y1 - cbr) * s)],
            [px(ox + (x1 - cbr) * s), px(oy + y1 * s)],
            [px(ox + (x0 + cbl) * s), px(oy + y1 * s)],
            [px(ox + x0 * s), px(oy + (y1 - cbl) * s)],
            [px(ox + x0 * s), px(oy + (y0 + ctl) * s)]
        ]);
    }

    function uBox(dc, ox, oy, s, x0, y0, x1, y1) {
        dc.fillPolygon([
            [px(ox + x0 * s), px(oy + y0 * s)],
            [px(ox + x1 * s), px(oy + y0 * s)],
            [px(ox + x1 * s), px(oy + y1 * s)],
            [px(ox + x0 * s), px(oy + y1 * s)]
        ]);
    }

    function uQuad(dc, ox, oy, s, ax, ay, bx, by, cx, cy, dx, dy) {
        dc.fillPolygon([
            [px(ox + ax * s), px(oy + ay * s)],
            [px(ox + bx * s), px(oy + by * s)],
            [px(ox + cx * s), px(oy + cy * s)],
            [px(ox + dx * s), px(oy + dy * s)]
        ]);
    }

    function uTri(dc, ox, oy, s, ax, ay, bx, by, cx, cy) {
        dc.fillPolygon([
            [px(ox + ax * s), px(oy + ay * s)],
            [px(ox + bx * s), px(oy + by * s)],
            [px(ox + cx * s), px(oy + cy * s)]
        ]);
    }

    //! Segment (x1,y1)-(x2,y2) translated perpendicular by d, as [x1,y1,x2,y2].
    //! Used to derive the far edge of a diagonal so it thins with the weight.
    function shift(x1, y1, x2, y2, d) as Lang.Array<Lang.Float> {
        var dx = x2 - x1;
        var dy = y2 - y1;
        var len = Math.sqrt(dx * dx + dy * dy);
        if (len == 0) { len = 1.0; }
        var nx = dy / len * d;
        var ny = -dx / len * d;
        return [x1 + nx, y1 + ny, x2 + nx, y2 + ny];
    }

    function atY(l as Lang.Array<Lang.Float>, y) {
        return l[0] + (l[2] - l[0]) * (y - l[1]) / (l[3] - l[1]);
    }

    function atX(l as Lang.Array<Lang.Float>, x) {
        return l[1] + (l[3] - l[1]) * (x - l[0]) / (l[2] - l[0]);
    }

    // ------------------------------------------------------------------

    function drawDigit(dc, d, x, y, s, k, fg, bg) {
        var ck = 0.35 + 0.65 * k;
        var st = _STEM * k;
        var bar = _BAR * k;
        var waist = _WAIST * k;
        var s8 = _S8 * k;
        var c = _CHAM * ck;
        var ic = _ICH * ck;
        var b = BLEED;

        // --- solids ---------------------------------------------------
        dc.setColor(fg, bg);

        if (d == 1) {
            var sw = st * 1.24;
            var fw = 0.170 * (0.5 + 0.5 * k);
            var o = (ADV - sw + fw) / 2.0;
            var c1 = c * 0.8;
            if (c1 > sw * 0.30) { c1 = sw * 0.30; }   // never eat the stem
            var ff = st * 0.30;
            var fh = bar * 1.00;
            var ftip = 0.340;
            uOcta(dc, x, y, s, o, 0.0, o + sw, 1.0, 0.0, c1, c1, c1);
            uOcta(dc, x, y, s, o - ff, 1.0 - fh, o + sw + ff, 1.0, 0.0, 0.0, c1, c1);
            uQuad(dc, x, y, s, o + 0.02, 0.0, o + 0.02, ftip + sw * 0.72,
                  o - fw, ftip, o - fw, ftip - sw * 0.85);
            return;
        }

        uOcta(dc, x, y, s, 0.0, 0.0, ADV, 1.0, c, c, c, c);

        // --- knockouts ------------------------------------------------
        dc.setColor(bg, bg);

        if (d == 0) {
            uOcta(dc, x, y, s, st, bar, ADV - st, 1.0 - bar, ic, ic, ic, ic);

        } else if (d == 2) {
            var q2 = shift(ADV - st, 0.44, -b, 1.0 - bar, st * 1.16);
            uQuad(dc, x, y, s, -b, bar, ADV - st, bar,
                  ADV - st, 0.44, -b, 1.0 - bar);
            uTri(dc, x, y, s, ADV + b, atX(q2, ADV + b), ADV + b, 1.0 - bar,
                 atY(q2, 1.0 - bar), 1.0 - bar);

        } else if (d == 3) {
            var mid = 0.500;
            uBox(dc, x, y, s, -b, bar, ADV - st, mid - waist / 2.0);
            uBox(dc, x, y, s, -b, mid + waist / 2.0, ADV - st, 1.0 - bar);
            uBox(dc, x, y, s, -b, mid - waist / 2.0 - 0.02, 0.145,
                 mid + waist / 2.0 + 0.02);

        } else if (d == 4) {
            var cross = 0.680;
            var q4 = shift(ADV - st, 0.0, -b, cross - 0.02, st * 0.78);
            uQuad(dc, x, y, s, -b, -b, ADV - st, -b,
                  ADV - st, 0.0, -b, cross - 0.02);
            uTri(dc, x, y, s, ADV - st, atX(q4, ADV - st), ADV - st, cross,
                 atY(q4, cross), cross);
            uBox(dc, x, y, s, -b, cross + bar, ADV - st, 1.0 + b);

        } else if (d == 5) {
            var top5 = 0.425;
            uBox(dc, x, y, s, st, bar, ADV + b, top5);
            uQuad(dc, x, y, s, -b, top5 + waist + 0.020, ADV - st, top5 + waist,
                  ADV - st, 1.0 - bar, -b, 1.0 - bar);

        } else if (d == 6) {
            var split6 = 0.570;
            uBox(dc, x, y, s, st, bar, ADV + b, split6 - waist);
            uOcta(dc, x, y, s, s8, split6, ADV - s8, 1.0 - bar * 0.9,
                  ic, ic, ic, ic);

        } else if (d == 7) {
            var q7 = shift(0.345, bar, 0.010, 1.0 + b, st * 1.28);
            uQuad(dc, x, y, s, -b, bar, 0.345, bar, 0.010, 1.0 + b, -b, 1.0 + b);
            uTri(dc, x, y, s, ADV + b, bar, ADV + b, 1.0 + b,
                 atY(q7, 1.0 + b), 1.0 + b);

        } else if (d == 8) {
            var top8 = 0.175 * (0.45 + 0.55 * k);
            var bot8 = 1.0 - top8;
            var half = (bot8 - top8 - waist) / 2.0;
            uOcta(dc, x, y, s, s8, top8, ADV - s8, top8 + half, ic, ic, ic, ic);
            uOcta(dc, x, y, s, s8, top8 + half + waist, ADV - s8, bot8,
                  ic, ic, ic, ic);

        } else if (d == 9) {
            var split9 = 0.585;
            uOcta(dc, x, y, s, s8, bar * 0.9, ADV - s8, split9 - waist,
                  ic, ic, ic, ic);
            uBox(dc, x, y, s, -b, split9, ADV - st, 1.0 - bar);
        }
    }
}
