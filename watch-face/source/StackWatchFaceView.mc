using Toybox.ActivityMonitor as ActivityMonitor;
using Toybox.Graphics as Gfx;
using Toybox.Lang as Lang;
using Toybox.System as Sys;
using Toybox.Time as Time;
using Toybox.Time.Gregorian as Gregorian;
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

        if (_sleeping) {
            drawAlwaysOn(dc, clock.hour, clock.min);
        } else {
            drawOffset(dc, clock.hour, clock.min);
        }
    }

    function drawOffset(dc, hour, minute) {
        var displayHour = getDisplayHour(hour);
        var h1 = (displayHour / 10).toNumber();
        var h2 = displayHour % 10;
        var m1 = (minute / 10).toNumber();
        var m2 = minute % 10;

        // Top information row: date badge left/center, battery to the right.
        drawDateBadge(dc);
        drawBattery(dc, 300, 58);

        // The time is the poster. Two independent number groups own most of the face.
        // White hour sits high and left; lime minutes sit low and right.
        drawDisplayDigit(dc, h1, 30, 82, 82, 142, 25, StackTheme.TEXT);
        drawDisplayDigit(dc, h2, 115, 82, 82, 142, 25, StackTheme.TEXT);

        drawDisplayDigit(dc, m1, 205, 220, 82, 142, 25, StackTheme.LIME);
        drawDisplayDigit(dc, m2, 290, 220, 82, 142, 25, StackTheme.LIME);

        // Colon behaves like a graphic object, not tiny punctuation.
        dc.setColor(StackTheme.LIME, StackTheme.BG);
        dc.fillCircle(205, 165, 9);
        dc.fillCircle(205, 196, 9);

        drawSteps(dc, 42, 255);
        drawDecorativeBlocks(dc);
    }

    function getDisplayHour(hour) {
        var settings = Sys.getDeviceSettings();
        if (settings != null && !settings.is24Hour) {
            var twelve = hour % 12;
            if (twelve == 0) {
                twelve = 12;
            }
            return twelve;
        }
        return hour;
    }

    function drawDateBadge(dc) {
        var label = "TODAY";
        var info = Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);
        if (info != null) {
            label = Lang.format("$1$ $2$", [weekdayLabel(info.day_of_week), info.day]);
        }

        dc.setColor(StackTheme.BLUE, StackTheme.BG);
        dc.fillRoundedRectangle(130, 30, 126, 42, 10);
        dc.setColor(StackTheme.TEXT, StackTheme.BLUE);
        dc.drawText(193, 39, Gfx.FONT_XTINY, label, Gfx.TEXT_JUSTIFY_CENTER);
    }

    function weekdayLabel(day) {
        if (day == 1) { return "SUN"; }
        if (day == 2) { return "MON"; }
        if (day == 3) { return "TUE"; }
        if (day == 4) { return "WED"; }
        if (day == 5) { return "THU"; }
        if (day == 6) { return "FRI"; }
        if (day == 7) { return "SAT"; }
        return "DAY";
    }

    function drawBattery(dc, x, y) {
        var battery = 0;
        var stats = Sys.getSystemStats();
        if (stats != null && stats.battery != null) {
            battery = stats.battery.toNumber();
        }

        dc.setColor(StackTheme.LIME, StackTheme.BG);
        dc.drawRoundedRectangle(x, y, 30, 14, 3);
        dc.fillRectangle(x + 30, y + 4, 4, 6);

        var fill = ((battery * 22) / 100).toNumber();
        if (fill > 0) {
            dc.fillRoundedRectangle(x + 4, y + 4, fill, 6, 1);
        }

        // Avoid Number.format("%d%%"): Connect IQ rejects that format string at runtime.
        var batteryLabel = battery.toString() + "%";
        dc.setColor(StackTheme.TEXT, StackTheme.BG);
        dc.drawText(x + 42, y - 6, Gfx.FONT_XTINY,
            batteryLabel, Gfx.TEXT_JUSTIFY_LEFT);
    }

    function drawSteps(dc, x, y) {
        var steps = 0;
        var activity = ActivityMonitor.getInfo();
        if (activity != null && activity.steps != null) {
            steps = activity.steps;
        }

        var thousands = (steps / 1000).toNumber();
        var hundreds = ((steps % 1000) / 100).toNumber();
        var label;
        if (steps >= 1000) {
            label = Lang.format("$1$.$2$K", [thousands, hundreds]);
        } else {
            label = steps.toString();
        }

        // Small electric-blue runner glyph built from primitives.
        dc.setColor(StackTheme.BLUE, StackTheme.BG);
        dc.fillCircle(x + 12, y + 6, 5);
        dc.fillRoundedRectangle(x + 9, y + 13, 7, 20, 3);
        dc.fillRoundedRectangle(x + 14, y + 17, 18, 6, 3);
        dc.fillRoundedRectangle(x + 3, y + 29, 17, 6, 3);
        dc.fillRoundedRectangle(x + 20, y + 29, 17, 6, 3);

        dc.setColor(StackTheme.YELLOW, StackTheme.BG);
        dc.fillCircle(x + 4, y + 58, 12);

        dc.setColor(StackTheme.TEXT, StackTheme.BG);
        dc.drawText(x + 25, y + 47, Gfx.FONT_XTINY, label, Gfx.TEXT_JUSTIFY_LEFT);
    }

    function drawDecorativeBlocks(dc) {
        // Purple offset piece at right — intentionally decorative, like the mockup.
        dc.setColor(StackTheme.PURPLE, StackTheme.BG);
        dc.fillRoundedRectangle(333, 132, 30, 34, 5);
        dc.fillRoundedRectangle(351, 151, 30, 34, 5);

        // Cyan stepped punctuation at the bottom-left.
        dc.setColor(StackTheme.CYAN, StackTheme.BG);
        dc.fillRoundedRectangle(112, 353, 86, 22, 5);
        dc.fillRoundedRectangle(166, 335, 32, 40, 5);
    }

    function drawAlwaysOn(dc, hour, minute) {
        var displayHour = getDisplayHour(hour);
        var h1 = (displayHour / 10).toNumber();
        var h2 = displayHour % 10;
        var m1 = (minute / 10).toNumber();
        var m2 = minute % 10;

        // AOD is intentionally its own composition: sparse, centered and quiet.
        drawDisplayDigit(dc, h1, 105, 100, 52, 88, 12, StackTheme.AOD);
        drawDisplayDigit(dc, h2, 161, 100, 52, 88, 12, StackTheme.AOD);
        drawDisplayDigit(dc, m1, 205, 220, 52, 88, 12, StackTheme.AOD);
        drawDisplayDigit(dc, m2, 261, 220, 52, 88, 12, StackTheme.AOD);

        dc.setColor(StackTheme.AOD, StackTheme.BG);
        dc.fillCircle(207, 194, 3);
        dc.fillCircle(207, 208, 3);

        dc.setColor(StackTheme.LIME, StackTheme.BG);
        dc.fillRoundedRectangle(195, 358, 26, 3, 1);
    }

    function drawDisplayDigit(dc, digit, x, y, w, h, t, color) {
        dc.setColor(color, StackTheme.BG);

        // Digits are drawn as solid poster glyphs with overlapping strokes.
        // There are no seven-segment gaps; joints intentionally fuse together.
        if (digit == 0) {
            drawZero(dc, x, y, w, h, t, color);
            return;
        }
        if (digit == 1) {
            drawOne(dc, x, y, w, h, t, color);
            return;
        }
        if (digit == 2) {
            drawTwo(dc, x, y, w, h, t, color);
            return;
        }
        if (digit == 3) {
            drawThree(dc, x, y, w, h, t, color);
            return;
        }
        if (digit == 4) {
            drawFour(dc, x, y, w, h, t, color);
            return;
        }
        if (digit == 5) {
            drawFive(dc, x, y, w, h, t, color);
            return;
        }
        if (digit == 6) {
            drawSix(dc, x, y, w, h, t, color);
            return;
        }
        if (digit == 7) {
            drawSeven(dc, x, y, w, h, t, color);
            return;
        }
        if (digit == 8) {
            drawEight(dc, x, y, w, h, t, color);
            return;
        }
        if (digit == 9) {
            drawNine(dc, x, y, w, h, t, color);
        }
    }

    function drawZero(dc, x, y, w, h, t, color) {
        dc.setColor(color, StackTheme.BG);
        dc.fillRoundedRectangle(x, y, w, h, 11);
        dc.setColor(StackTheme.BG, StackTheme.BG);
        dc.fillRoundedRectangle(x + t, y + t, w - (t * 2), h - (t * 2), 5);
    }

    function drawOne(dc, x, y, w, h, t, color) {
        dc.setColor(color, StackTheme.BG);
        var stemX = x + ((w - t) / 2).toNumber();
        dc.fillRoundedRectangle(stemX, y, t, h, 6);
        dc.fillRoundedRectangle(stemX - 18, y + 8, 30, t, 5);
        dc.fillRoundedRectangle(stemX - 15, y + h - t, t + 38, t, 5);
    }

    function drawTwo(dc, x, y, w, h, t, color) {
        dc.setColor(color, StackTheme.BG);
        var half = (h / 2).toNumber();
        barH(dc, x, y, w, t);
        barV(dc, x + w - t, y, t, half + 4);
        barH(dc, x, y + half - (t / 2).toNumber(), w, t);
        barV(dc, x, y + half - 2, t, half + 2);
        barH(dc, x, y + h - t, w, t);
    }

    function drawThree(dc, x, y, w, h, t, color) {
        dc.setColor(color, StackTheme.BG);
        var half = (h / 2).toNumber();
        barV(dc, x + w - t, y, t, h);
        barH(dc, x, y, w, t);
        barH(dc, x + 8, y + half - (t / 2).toNumber(), w - 8, t);
        barH(dc, x, y + h - t, w, t);
    }

    function drawFour(dc, x, y, w, h, t, color) {
        dc.setColor(color, StackTheme.BG);
        var half = (h / 2).toNumber();
        barV(dc, x, y, t, half + 2);
        barV(dc, x + w - t, y, t, h);
        barH(dc, x, y + half - (t / 2).toNumber(), w, t);
    }

    function drawFive(dc, x, y, w, h, t, color) {
        dc.setColor(color, StackTheme.BG);
        var half = (h / 2).toNumber();
        barH(dc, x, y, w, t);
        barV(dc, x, y, t, half + 3);
        barH(dc, x, y + half - (t / 2).toNumber(), w, t);
        barV(dc, x + w - t, y + half - 1, t, half + 1);
        barH(dc, x, y + h - t, w, t);
    }

    function drawSix(dc, x, y, w, h, t, color) {
        dc.setColor(color, StackTheme.BG);
        var half = (h / 2).toNumber();
        barH(dc, x, y, w, t);
        barV(dc, x, y, t, h);
        barH(dc, x, y + half - (t / 2).toNumber(), w, t);
        barV(dc, x + w - t, y + half - 1, t, half + 1);
        barH(dc, x, y + h - t, w, t);
    }

    function drawSeven(dc, x, y, w, h, t, color) {
        dc.setColor(color, StackTheme.BG);
        barH(dc, x, y, w, t);
        barV(dc, x + w - t, y, t, h);
    }

    function drawEight(dc, x, y, w, h, t, color) {
        dc.setColor(color, StackTheme.BG);
        dc.fillRoundedRectangle(x, y, w, h, 11);
        dc.setColor(StackTheme.BG, StackTheme.BG);
        var innerW = w - (t * 2);
        var innerH = ((h - (t * 3)) / 2).toNumber();
        dc.fillRoundedRectangle(x + t, y + t, innerW, innerH, 4);
        dc.fillRoundedRectangle(x + t, y + (t * 2) + innerH, innerW, innerH, 4);
    }

    function drawNine(dc, x, y, w, h, t, color) {
        dc.setColor(color, StackTheme.BG);
        var half = (h / 2).toNumber();
        barH(dc, x, y, w, t);
        barV(dc, x, y, t, half + 2);
        barV(dc, x + w - t, y, t, h);
        barH(dc, x, y + half - (t / 2).toNumber(), w, t);
        barH(dc, x, y + h - t, w, t);
    }

    function barH(dc, x, y, w, h) {
        dc.fillRoundedRectangle(x, y, w, h, 5);
    }

    function barV(dc, x, y, w, h) {
        dc.fillRoundedRectangle(x, y, w, h, 5);
    }
}
