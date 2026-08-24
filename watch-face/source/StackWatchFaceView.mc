using Toybox.ActivityMonitor as ActivityMonitor;
using Toybox.Graphics as Gfx;
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

        // Compact top row. Keep both objects comfortably inside the circular safe area.
        drawDateBadge(dc);
        drawBattery(dc, 276, 48);

        // The time is the poster. Push the two groups away from center so the
        // composition feels intentionally offset instead of arranged on a grid.
        drawDisplayDigit(dc, h1, 12, 76, 92, 154, 31, StackTheme.TEXT);
        drawDisplayDigit(dc, h2, 108, 76, 92, 154, 31, StackTheme.TEXT);

        drawDisplayDigit(dc, m1, 202, 214, 88, 154, 31, StackTheme.LIME);
        drawDisplayDigit(dc, m2, 298, 214, 88, 154, 31, StackTheme.LIME);

        // Graphic punctuation lives between the masses rather than attaching to either one.
        dc.setColor(StackTheme.LIME, StackTheme.BG);
        dc.fillCircle(216, 169, 10);
        dc.fillCircle(216, 203, 10);

        drawSteps(dc, 38, 260);
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
        // FORMAT_SHORT guarantees a numeric day_of_week (1=Sun ... 7=Sat),
        // which keeps the badge deterministic across device language settings.
        var label = "TODAY";
        var info = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
        if (info != null) {
            label = weekdayLabel(info.day_of_week) + " " + info.day.toString();
        }

        dc.setColor(StackTheme.BLUE, StackTheme.BG);
        dc.fillRoundedRectangle(118, 26, 128, 42, 9);
        dc.setColor(StackTheme.TEXT, StackTheme.BLUE);
        dc.drawText(182, 35, Gfx.FONT_XTINY, label, Gfx.TEXT_JUSTIFY_CENTER);
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
        dc.drawRoundedRectangle(x, y, 28, 13, 3);
        dc.fillRectangle(x + 28, y + 4, 4, 5);

        var fill = ((battery * 20) / 100).toNumber();
        if (fill > 0) {
            dc.fillRoundedRectangle(x + 4, y + 4, fill, 5, 1);
        }

        var batteryLabel = battery.toString() + "%";
        dc.setColor(StackTheme.TEXT, StackTheme.BG);
        dc.drawText(x + 39, y - 7, Gfx.FONT_XTINY,
            batteryLabel, Gfx.TEXT_JUSTIFY_LEFT);
    }

    function drawSteps(dc, x, y) {
        var steps = 0;
        var activity = ActivityMonitor.getInfo();
        if (activity != null && activity.steps != null) {
            steps = activity.steps;
        }

        var label;
        if (steps >= 1000) {
            var thousands = (steps / 1000).toNumber();
            var hundreds = ((steps % 1000) / 100).toNumber();
            label = thousands.toString() + "." + hundreds.toString() + "K";
        } else {
            label = steps.toString();
        }

        // Compact runner + value unit. Keep the blue mark and white number on one line.
        dc.setColor(StackTheme.BLUE, StackTheme.BG);
        dc.fillCircle(x + 10, y + 7, 5);
        dc.fillRoundedRectangle(x + 7, y + 14, 7, 18, 2);
        dc.fillRoundedRectangle(x + 12, y + 17, 18, 6, 2);
        dc.fillRoundedRectangle(x + 1, y + 28, 16, 6, 2);
        dc.fillRoundedRectangle(x + 18, y + 28, 17, 6, 2);

        dc.setColor(StackTheme.TEXT, StackTheme.BG);
        dc.drawText(x + 43, y + 8, Gfx.FONT_SMALL, label, Gfx.TEXT_JUSTIFY_LEFT);

        // Yellow punctuation sits below the unit, echoing the approved mockup.
        dc.setColor(StackTheme.YELLOW, StackTheme.BG);
        dc.fillCircle(x + 9, y + 60, 11);
    }

    function drawDecorativeBlocks(dc) {
        dc.setColor(StackTheme.PURPLE, StackTheme.BG);
        dc.fillRoundedRectangle(330, 127, 30, 35, 4);
        dc.fillRoundedRectangle(349, 146, 30, 35, 4);

        dc.setColor(StackTheme.CYAN, StackTheme.BG);
        dc.fillRoundedRectangle(104, 349, 92, 23, 4);
        dc.fillRoundedRectangle(166, 331, 30, 41, 4);
    }

    function drawAlwaysOn(dc, hour, minute) {
        var displayHour = getDisplayHour(hour);
        var h1 = (displayHour / 10).toNumber();
        var h2 = displayHour % 10;
        var m1 = (minute / 10).toNumber();
        var m2 = minute % 10;

        drawDisplayDigit(dc, h1, 104, 102, 52, 88, 13, StackTheme.AOD);
        drawDisplayDigit(dc, h2, 162, 102, 52, 88, 13, StackTheme.AOD);
        drawDisplayDigit(dc, m1, 204, 220, 52, 88, 13, StackTheme.AOD);
        drawDisplayDigit(dc, m2, 262, 220, 52, 88, 13, StackTheme.AOD);

        dc.setColor(StackTheme.AOD, StackTheme.BG);
        dc.fillCircle(208, 194, 3);
        dc.fillCircle(208, 208, 3);

        dc.setColor(StackTheme.LIME, StackTheme.BG);
        dc.fillRoundedRectangle(195, 358, 26, 3, 1);
    }

    function drawDisplayDigit(dc, digit, x, y, w, h, t, color) {
        dc.setColor(color, StackTheme.BG);

        if (digit == 0) { drawZero(dc, x, y, w, h, t, color); return; }
        if (digit == 1) { drawOne(dc, x, y, w, h, t, color); return; }
        if (digit == 2) { drawTwo(dc, x, y, w, h, t, color); return; }
        if (digit == 3) { drawThree(dc, x, y, w, h, t, color); return; }
        if (digit == 4) { drawFour(dc, x, y, w, h, t, color); return; }
        if (digit == 5) { drawFive(dc, x, y, w, h, t, color); return; }
        if (digit == 6) { drawSix(dc, x, y, w, h, t, color); return; }
        if (digit == 7) { drawSeven(dc, x, y, w, h, t, color); return; }
        if (digit == 8) { drawEight(dc, x, y, w, h, t, color); return; }
        if (digit == 9) { drawNine(dc, x, y, w, h, t, color); }
    }

    function drawZero(dc, x, y, w, h, t, color) {
        dc.setColor(color, StackTheme.BG);
        dc.fillRoundedRectangle(x, y, w, h, 6);
        dc.setColor(StackTheme.BG, StackTheme.BG);
        dc.fillRoundedRectangle(x + t, y + t, w - (t * 2), h - (t * 2), 2);
    }

    function drawOne(dc, x, y, w, h, t, color) {
        dc.setColor(color, StackTheme.BG);
        var stemX = x + ((w - t) / 2).toNumber();
        dc.fillRoundedRectangle(stemX, y, t, h, 3);
        dc.fillRoundedRectangle(stemX - 21, y + 7, 35, t, 3);
        dc.fillRoundedRectangle(stemX - 18, y + h - t, t + 43, t, 3);
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
        barH(dc, x + 5, y + half - (t / 2).toNumber(), w - 5, t);
        barH(dc, x, y + h - t, w, t);
    }

    function drawFour(dc, x, y, w, h, t, color) {
        dc.setColor(color, StackTheme.BG);
        var half = (h / 2).toNumber();
        barV(dc, x, y, t, half + 3);
        barV(dc, x + w - t, y, t, h);
        barH(dc, x, y + half - (t / 2).toNumber(), w, t);
    }

    function drawFive(dc, x, y, w, h, t, color) {
        dc.setColor(color, StackTheme.BG);
        var half = (h / 2).toNumber();
        barH(dc, x, y, w, t);
        barV(dc, x, y, t, half + 4);
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
        dc.fillRoundedRectangle(x, y, w, h, 6);
        dc.setColor(StackTheme.BG, StackTheme.BG);
        var innerW = w - (t * 2);
        var innerH = ((h - (t * 3)) / 2).toNumber();
        dc.fillRoundedRectangle(x + t, y + t, innerW, innerH, 2);
        dc.fillRoundedRectangle(x + t, y + (t * 2) + innerH, innerW, innerH, 2);
    }

    function drawNine(dc, x, y, w, h, t, color) {
        dc.setColor(color, StackTheme.BG);
        var half = (h / 2).toNumber();
        barH(dc, x, y, w, t);
        barV(dc, x, y, t, half + 3);
        barV(dc, x + w - t, y, t, h);
        barH(dc, x, y + half - (t / 2).toNumber(), w, t);
        barH(dc, x, y + h - t, w, t);
    }

    function barH(dc, x, y, w, h) {
        dc.fillRoundedRectangle(x, y, w, h, 3);
    }

    function barV(dc, x, y, w, h) {
        dc.fillRoundedRectangle(x, y, w, h, 3);
    }
}
