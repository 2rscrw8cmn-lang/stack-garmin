using Toybox.Graphics as Gfx;
using Toybox.Lang;

//! STACK display numerals.
//!
//! The reference OFFSET artwork uses a chamfered, poster-weight numeral that no
//! stock Garmin face or device font provides. Rather than ship a bitmap font
//! resource (expensive inside the 128 KiB watch-face budget) each digit is
//! assembled here from convex polygons, so the silhouette is exact at any cap
//! height and costs only bytecode.
//!
//! Every shape emitted is convex; Garmin's fillPolygon does not reliably fill
//! concave outlines, so counters are cut with mitred frame pieces instead.
//!
//! Geometry is expressed as fractions of the cap height, inside a tabular
//! advance. Tabular figures matter: every hour and minute pair is then exactly
//! the same width, so the composition never resizes as the clock ticks.
module StackDigits {
    const ADV = 0.620;      // tabular advance per digit
    const TRACK = 0.060;    // space between digits
    const STEM = 0.205;     // vertical stroke
    const BAR = 0.200;      // horizontal stroke
    const MIDBAR = 0.165;   // shared middle stroke of 6, 8, 9
    const CHAM = 0.110;     // outer chamfer
    const ICHAM = 0.050;    // counter chamfer

    //! Width of a digit string in cap-height units.
    function unitWidth(text) {
        var n = text.length();
        return ADV * n + TRACK * (n - 1);
    }

    //! Draw a digit string with its top-left at (x, y) and the given cap height.
    function drawNumber(dc, text, x, y, cap) {
        var chars = text.toCharArray() as Lang.Array<Lang.Char>;
        var step = (ADV + TRACK) * cap;
        var cx = x;

        for (var i = 0; i < chars.size(); i++) {
            var d = chars[i].toNumber() - 48;
            if (d >= 0 && d <= 9) {
                drawDigit(dc, d, cx, y, cap);
            }
            cx += step;
        }
    }

    function px(v) {
        return (v + 0.5).toNumber();
    }

    //! Axis-aligned bar with independent corner chamfers.
    function bar(dc, x0, y0, x1, y1, tl, tr, br, bl) {
        dc.fillPolygon([
            [px(x0 + tl), px(y0)],
            [px(x1 - tr), px(y0)],
            [px(x1), px(y0 + tr)],
            [px(x1), px(y1 - br)],
            [px(x1 - br), px(y1)],
            [px(x0 + bl), px(y1)],
            [px(x0), px(y1 - bl)],
            [px(x0), px(y0 + tl)]
        ]);
    }

    //! Closed counter, cut into four convex mitred pieces.
    function ring(dc, x0, y0, x1, y1, ht, hb, st, ctl, ctr, cbl, cbr, ic) {
        var ix0 = x0 + st + ic;
        var ix1 = x1 - st - ic;
        var iy0 = y0 + ht;
        var iy1 = y1 - hb;

        dc.fillPolygon([
            [px(x0 + ctl), px(y0)], [px(x1 - ctr), px(y0)],
            [px(ix1), px(iy0)], [px(ix0), px(iy0)]
        ]);
        dc.fillPolygon([
            [px(ix0), px(iy1)], [px(ix1), px(iy1)],
            [px(x1 - cbr), px(y1)], [px(x0 + cbl), px(y1)]
        ]);
        dc.fillPolygon([
            [px(x0 + ctl), px(y0)], [px(ix0), px(iy0)], [px(ix0), px(iy1)],
            [px(x0 + cbl), px(y1)], [px(x0), px(y1 - cbl)], [px(x0), px(y0 + ctl)]
        ]);
        dc.fillPolygon([
            [px(x1 - ctr), px(y0)], [px(x1), px(y0 + ctr)], [px(x1), px(y1 - cbr)],
            [px(x1 - cbr), px(y1)], [px(ix1), px(iy1)], [px(ix1), px(iy0)]
        ]);
    }

    function drawDigit(dc, d, x, y, s) {
        var x1 = x + ADV * s;
        var y1 = y + s;
        var st = STEM * s;
        var hb = BAR * s;
        var mb = MIDBAR * s;
        var c = CHAM * s;
        var ic = ICHAM * s;

        if (d == 0) {
            ring(dc, x, y, x1, y1, hb, hb, st, c, c, c, c, ic);
        } else if (d == 1) {
            var o = x + 0.260 * s;
            var fw = 0.165 * s;
            var sc = 0.085 * s;
            bar(dc, o, y, o + 0.265 * s, y1, 0.0, sc, sc, sc);
            dc.fillPolygon([
                [px(o), px(y)], [px(o), px(y + 0.470 * s)],
                [px(o - fw), px(y + 0.325 * s)], [px(o - fw), px(y + 0.130 * s)]
            ]);
        } else if (d == 2) {
            bar(dc, x, y, x1, y + hb, c, c, 0.0, 0.0);
            bar(dc, x, y + hb, x + st, y + 0.34 * s, 0.0, 0.0, 0.0, 0.0);
            bar(dc, x1 - st, y + hb, x1, y + 0.40 * s, 0.0, 0.0, 0.0, 0.0);
            dc.fillPolygon([
                [px(x1 - st), px(y + 0.30 * s)], [px(x1), px(y + 0.30 * s)],
                [px(x + 0.27 * s), px(y + 0.80 * s)], [px(x), px(y + 0.80 * s)]
            ]);
            bar(dc, x, y + 0.80 * s, x1, y1, 0.0, 0.0, c, c);
        } else if (d == 3) {
            bar(dc, x, y, x1, y + hb, c, c, 0.0, 0.0);
            bar(dc, x1 - st, y, x1, y1, 0.0, c, c, 0.0);
            bar(dc, x + 0.13 * s, y + 0.415 * s, x1 - st, y + 0.585 * s, 0.0, 0.0, 0.0, 0.0);
            bar(dc, x, y1 - hb, x1, y1, 0.0, 0.0, c, c);
        } else if (d == 4) {
            dc.fillPolygon([
                [px(x1 - st), px(y)], [px(x1 - st), px(y + 0.26 * s)],
                [px(x + 0.235 * s), px(y + 0.60 * s)], [px(x), px(y + 0.60 * s)],
                [px(x), px(y + 0.44 * s)]
            ]);
            bar(dc, x, y + 0.60 * s, x1, y + 0.79 * s, 0.0, 0.0, 0.0, c);
            bar(dc, x1 - st, y, x1, y1, 0.0, c, c, 0.0);
        } else if (d == 5) {
            bar(dc, x, y, x1, y + hb, c, c, 0.0, 0.0);
            bar(dc, x, y + hb, x + st, y + 0.52 * s, 0.0, 0.0, 0.0, 0.0);
            bar(dc, x, y + 0.38 * s, x1, y + 0.575 * s, 0.0, 0.0, 0.0, 0.0);
            bar(dc, x1 - st, y + 0.38 * s, x1, y1 - hb, 0.0, 0.0, 0.0, 0.0);
            bar(dc, x, y1 - hb, x1, y1, 0.0, 0.0, c, c);
        } else if (d == 6) {
            bar(dc, x, y, x1, y + hb, c, c, 0.0, 0.0);
            bar(dc, x, y, x + st, y1, c, 0.0, 0.0, 0.0);
            ring(dc, x, y + 0.415 * s, x1, y1, mb, hb, st, 0.0, 0.0, c, c, ic);
        } else if (d == 7) {
            bar(dc, x, y, x1, y + hb, c, c, 0.0, 0.0);
            dc.fillPolygon([
                [px(x1 - 0.275 * s), px(y + hb)], [px(x1), px(y + hb)],
                [px(x + 0.275 * s), px(y1)], [px(x), px(y1)]
            ]);
        } else if (d == 8) {
            ring(dc, x, y, x1, y + 0.575 * s, hb, mb, st, c, c, 0.0, 0.0, ic);
            ring(dc, x, y + 0.425 * s, x1, y1, mb, hb, st, 0.0, 0.0, c, c, ic);
        } else if (d == 9) {
            bar(dc, x, y1 - hb, x1, y1, 0.0, 0.0, c, c);
            bar(dc, x1 - st, y, x1, y1, 0.0, 0.0, c, 0.0);
            ring(dc, x, y, x1, y + 0.585 * s, hb, mb, st, c, c, 0.0, 0.0, ic);
        }
    }
}
