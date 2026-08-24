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
        // Keep the first simulator-safe pass deliberately primitive: no date,
        // ActivityMonitor, arrays, string parsing, or optional sensor values.
        // Once this renders reliably we can add those secondary elements back.
        var h1 = (hour / 10).toNumber();
        var h2 = hour % 10;
        var m1 = (minute / 10).toNumber();
        var m2 = minute % 10;

        // Small STACK identity pill placeholder.
        dc.setColor(StackTheme.BLUE, StackTheme.BG);
        dc.fillRoundedRectangle(142, 34, 132, 42, 11);
        dc.setColor(StackTheme.TEXT, StackTheme.BLUE);
        dc.drawText(208, 43, Gfx.FONT_XTINY, "STACK", Gfx.TEXT_JUSTIFY_CENTER);

        // OFFSET time composition.
        drawDigit(dc, h1, 44, 88, 15, 3, StackTheme.TEXT, false);
        drawDigit(dc, h2, 131, 88, 15, 3, StackTheme.TEXT, false);
        drawDigit(dc, m1, 198, 226, 15, 3, StackTheme.LIME, false);
        drawDigit(dc, m2, 285, 226, 15, 3, StackTheme.LIME, false);

        dc.setColor(StackTheme.LIME, StackTheme.BG);
        dc.fillCircle(205, 182, 8);
        dc.fillCircle(205, 210, 8);

        // Decorative STACK punctuation only; no sensor dependency.
        dc.setColor(StackTheme.PURPLE, StackTheme.BG);
        dc.fillRoundedRectangle(325, 145, 28, 28, 5);
        dc.fillRoundedRectangle(345, 165, 28, 28, 5);

        dc.setColor(StackTheme.YELLOW, StackTheme.BG);
        dc.fillCircle(78, 314, 17);

        dc.setColor(StackTheme.CYAN, StackTheme.BG);
        dc.fillRoundedRectangle(105, 354, 78, 20, 5);
        dc.fillRoundedRectangle(151, 339, 32, 20, 5);
    }

    function drawAlwaysOn(dc, hour, minute) {
        var h1 = (hour / 10).toNumber();
        var h2 = hour % 10;
        var m1 = (minute / 10).toNumber();
        var m2 = minute % 10;

        drawDigit(dc, h1, 111, 108, 10, 3, StackTheme.AOD, true);
        drawDigit(dc, h2, 172, 108, 10, 3, StackTheme.AOD, true);
        drawDigit(dc, m1, 111, 220, 10, 3, StackTheme.AOD, true);
        drawDigit(dc, m2, 172, 220, 10, 3, StackTheme.AOD, true);

        dc.setColor(StackTheme.AOD, StackTheme.BG);
        dc.drawCircle(207, 202, 3);
        dc.drawCircle(207, 214, 3);

        dc.setColor(StackTheme.LIME, StackTheme.BG);
        dc.fillRoundedRectangle(195, 362, 26, 3, 1);
    }

    function drawDigit(dc, digit, x, y, cell, gap, color, outline) {
        dc.setColor(color, StackTheme.BG);

        for (var r = 0; r < 7; r += 1) {
            var row = digitRow(digit, r);
            for (var c = 0; c < 5; c += 1) {
                var mask = 1 << (4 - c);
                if ((row & mask) != 0) {
                    var px = x + c * (cell + gap);
                    var py = y + r * (cell + gap);
                    if (outline) {
                        dc.drawRoundedRectangle(px, py, cell, cell, 2);
                    } else {
                        dc.fillRoundedRectangle(px, py, cell, cell, 3);
                    }
                }
            }
        }
    }

    function digitRow(digit, row) {
        // Primitive switch table avoids runtime array/container access entirely.
        if (digit == 0) {
            if (row == 0 || row == 6) { return 31; }
            if (row == 1 || row == 5) { return 17; }
            if (row == 2) { return 19; }
            if (row == 3) { return 21; }
            return 25;
        }
        if (digit == 1) {
            if (row == 0) { return 4; }
            if (row == 1) { return 12; }
            if (row == 6) { return 14; }
            return 4;
        }
        if (digit == 2) {
            if (row == 0 || row == 3) { return 30; }
            if (row == 1 || row == 2) { return 1; }
            if (row == 4 || row == 5) { return 16; }
            return 31;
        }
        if (digit == 3) {
            if (row == 0 || row == 6) { return 30; }
            if (row == 3) { return 14; }
            return 1;
        }
        if (digit == 4) {
            if (row <= 2) { return 18; }
            if (row == 3) { return 31; }
            return 2;
        }
        if (digit == 5) {
            if (row == 0) { return 31; }
            if (row == 1 || row == 2) { return 16; }
            if (row == 3 || row == 6) { return 30; }
            return 1;
        }
        if (digit == 6) {
            if (row == 0) { return 15; }
            if (row == 1 || row == 2) { return 16; }
            if (row == 3) { return 30; }
            if (row == 4 || row == 5) { return 17; }
            return 14;
        }
        if (digit == 7) {
            if (row == 0) { return 31; }
            if (row == 1) { return 1; }
            if (row == 2) { return 2; }
            if (row == 3) { return 4; }
            return 8;
        }
        if (digit == 8) {
            if (row == 0 || row == 3 || row == 6) { return 14; }
            return 17;
        }
        if (digit == 9) {
            if (row == 0) { return 14; }
            if (row == 1 || row == 2) { return 17; }
            if (row == 3) { return 15; }
            if (row == 4 || row == 5) { return 1; }
            return 30;
        }
        return 0;
    }
}
