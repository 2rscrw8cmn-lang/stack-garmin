using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
using Toybox.WatchUi as WatchUi;

class StackWatchFaceView extends WatchUi.WatchFace {
    var _sleeping = false;

    function initialize() {
        WatchFace.initialize();
    }

    function onEnterSleep() {
        _sleeping = true;
    }

    function onExitSleep() {
        _sleeping = false;
    }

    function onUpdate(dc) {
        dc.setColor(StackTheme.BG, StackTheme.BG);
        dc.clear();

        var clock = Sys.getClockTime();
        if (clock == null) {
            return;
        }

        if (_sleeping) {
            drawAlwaysOn(dc, clock.hour, clock.min);
        } else {
            drawOffset(dc, clock.hour, clock.min);
        }
    }

    function drawOffset(dc, hour, minute) {
        var h1 = (hour / 10).toNumber();
        var h2 = hour % 10;
        var m1 = (minute / 10).toNumber();
        var m2 = minute % 10;

        // Quiet identity. The time remains the graphic, not a STACK logo card.
        dc.setColor(StackTheme.LIME, StackTheme.BG);
        dc.drawText(208, 35, Gfx.FONT_XTINY, "STACK", Gfx.TEXT_JUSTIFY_CENTER);

        // Solid modular numerals: large, chunky and intentionally offset.
        drawSegmentDigit(dc, h1, 34, 78, 70, 132, 20, StackTheme.TEXT, false);
        drawSegmentDigit(dc, h2, 116, 78, 70, 132, 20, StackTheme.TEXT, false);

        drawSegmentDigit(dc, m1, 204, 218, 70, 132, 20, StackTheme.LIME, false);
        drawSegmentDigit(dc, m2, 286, 218, 70, 132, 20, StackTheme.LIME, false);

        // Colon is oversized punctuation between the two number groups.
        dc.setColor(StackTheme.LIME, StackTheme.BG);
        dc.fillCircle(201, 177, 8);
        dc.fillCircle(201, 207, 8);

        drawDecorativeBlocks(dc);
    }

    function drawAlwaysOn(dc, hour, minute) {
        var h1 = (hour / 10).toNumber();
        var h2 = hour % 10;
        var m1 = (minute / 10).toNumber();
        var m2 = minute % 10;

        // Sparse outline treatment for AMOLED low-power mode.
        drawSegmentDigit(dc, h1, 92, 92, 48, 92, 12, StackTheme.AOD, true);
        drawSegmentDigit(dc, h2, 148, 92, 48, 92, 12, StackTheme.AOD, true);
        drawSegmentDigit(dc, m1, 220, 216, 48, 92, 12, StackTheme.AOD, true);
        drawSegmentDigit(dc, m2, 276, 216, 48, 92, 12, StackTheme.AOD, true);

        dc.setColor(StackTheme.AOD, StackTheme.BG);
        dc.drawCircle(208, 191, 3);
        dc.drawCircle(208, 205, 3);

        dc.setColor(StackTheme.LIME, StackTheme.BG);
        dc.fillRoundedRectangle(194, 359, 28, 3, 1);
    }

    function drawDecorativeBlocks(dc) {
        // Graphic punctuation only. Keep these sparse so the time owns the face.
        dc.setColor(StackTheme.PURPLE, StackTheme.BG);
        dc.fillRoundedRectangle(329, 118, 24, 34, 5);
        dc.fillRoundedRectangle(346, 135, 24, 34, 5);

        dc.setColor(StackTheme.CYAN, StackTheme.BG);
        dc.fillRoundedRectangle(55, 327, 68, 18, 5);
        dc.fillRoundedRectangle(103, 311, 20, 34, 5);

        dc.setColor(StackTheme.YELLOW, StackTheme.BG);
        dc.fillCircle(73, 255, 9);
    }

    function drawSegmentDigit(dc, digit, x, y, w, h, t, color, outline) {
        dc.setColor(color, StackTheme.BG);

        var half = (h / 2).toNumber();
        var horizontalW = w - t;
        var verticalH = half - (t / 2).toNumber();
        var radius = (t / 3).toNumber();

        // A — top
        if (segmentOn(digit, 0)) {
            drawSegment(dc, x + (t / 2).toNumber(), y, horizontalW, t, radius, outline);
        }
        // B — upper right
        if (segmentOn(digit, 1)) {
            drawSegment(dc, x + w - t, y + (t / 2).toNumber(), t, verticalH, radius, outline);
        }
        // C — lower right
        if (segmentOn(digit, 2)) {
            drawSegment(dc, x + w - t, y + half, t, verticalH, radius, outline);
        }
        // D — bottom
        if (segmentOn(digit, 3)) {
            drawSegment(dc, x + (t / 2).toNumber(), y + h - t, horizontalW, t, radius, outline);
        }
        // E — lower left
        if (segmentOn(digit, 4)) {
            drawSegment(dc, x, y + half, t, verticalH, radius, outline);
        }
        // F — upper left
        if (segmentOn(digit, 5)) {
            drawSegment(dc, x, y + (t / 2).toNumber(), t, verticalH, radius, outline);
        }
        // G — middle
        if (segmentOn(digit, 6)) {
            drawSegment(dc, x + (t / 2).toNumber(), y + half - (t / 2).toNumber(), horizontalW, t, radius, outline);
        }
    }

    function drawSegment(dc, x, y, w, h, radius, outline) {
        if (outline) {
            dc.drawRoundedRectangle(x, y, w, h, radius);
        } else {
            dc.fillRoundedRectangle(x, y, w, h, radius);
        }
    }

    function segmentOn(digit, segment) {
        // Seven-segment map expressed without arrays so the known-safe runtime path
        // stays free of container access.
        if (digit == 0) { return segment != 6; }
        if (digit == 1) { return segment == 1 || segment == 2; }
        if (digit == 2) { return segment == 0 || segment == 1 || segment == 6 || segment == 4 || segment == 3; }
        if (digit == 3) { return segment == 0 || segment == 1 || segment == 6 || segment == 2 || segment == 3; }
        if (digit == 4) { return segment == 5 || segment == 6 || segment == 1 || segment == 2; }
        if (digit == 5) { return segment == 0 || segment == 5 || segment == 6 || segment == 2 || segment == 3; }
        if (digit == 6) { return segment == 0 || segment == 5 || segment == 6 || segment == 4 || segment == 2 || segment == 3; }
        if (digit == 7) { return segment == 0 || segment == 1 || segment == 2; }
        if (digit == 8) { return true; }
        if (digit == 9) { return segment == 0 || segment == 5 || segment == 6 || segment == 1 || segment == 2 || segment == 3; }
        return false;
    }
}
