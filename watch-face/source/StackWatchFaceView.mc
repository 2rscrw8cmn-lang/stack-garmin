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

        if (_sleeping) {
            drawAlwaysOn(dc);
        } else {
            drawOffset(dc);
        }
    }

    function getDisplayHour(clock) {
        var hour = clock.hour;
        var settings = Sys.getDeviceSettings();

        if (settings != null && !settings.is24Hour) {
            hour = hour % 12;
            if (hour == 0) {
                hour = 12;
            }
        }

        return hour;
    }

    function getDateLabel() {
        var date = Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);
        if (date == null) {
            return "";
        }
        return Lang.format("$1$ $2$", [date.day_of_week, date.day]);
    }

    function drawOffset(dc) {
        var clock = Sys.getClockTime();
        var hour = getDisplayHour(clock);
        var hh = hour.format("%02d");
        var mm = clock.min.format("%02d");
        var dateLabel = getDateLabel();

        // Day/date pill: bright, compact, and intentionally separate from the time.
        dc.setColor(StackTheme.BLUE, StackTheme.BG);
        dc.fillRoundedRectangle(142, 34, 132, 42, 11);
        if (dateLabel.length() > 0) {
            dc.setColor(StackTheme.TEXT, StackTheme.BLUE);
            dc.drawText(208, 43, Gfx.FONT_XTINY, dateLabel, Gfx.TEXT_JUSTIFY_CENTER);
        }

        // Time is the graphic. Split and offset instead of centered like a stock Garmin face.
        drawNumber(dc, hh, 44, 88, 15, 3, StackTheme.TEXT, false);
        drawNumber(dc, mm, 198, 226, 15, 3, StackTheme.LIME, false);

        // Oversized lime colon floats between the two number groups.
        dc.setColor(StackTheme.LIME, StackTheme.BG);
        dc.fillCircle(205, 182, 8);
        dc.fillCircle(205, 210, 8);

        drawBattery(dc, 300, 88);
        drawSteps(dc, 48, 247);
        drawDecorativeBlocks(dc);
    }

    function drawAlwaysOn(dc) {
        var clock = Sys.getClockTime();
        var hour = getDisplayHour(clock);
        var hh = hour.format("%02d");
        var mm = clock.min.format("%02d");
        var dateLabel = getDateLabel();

        // Sparse outlined pixels keep the AOD recognizably STACK while reducing lit area.
        drawNumber(dc, hh, 111, 108, 10, 3, StackTheme.AOD, true);
        drawNumber(dc, mm, 111, 220, 10, 3, StackTheme.AOD, true);

        dc.setColor(StackTheme.AOD, StackTheme.BG);
        dc.drawCircle(207, 202, 3);
        dc.drawCircle(207, 214, 3);

        if (dateLabel.length() > 0) {
            dc.setColor(StackTheme.TEXT, StackTheme.BG);
            dc.drawText(208, 330, Gfx.FONT_XTINY, dateLabel, Gfx.TEXT_JUSTIFY_CENTER);
        }

        dc.setColor(StackTheme.LIME, StackTheme.BG);
        dc.fillRoundedRectangle(195, 362, 26, 3, 1);
    }

    function drawBattery(dc, x, y) {
        var stats = Sys.getSystemStats();
        var battery = 0;

        if (stats != null) {
            battery = stats.battery;
        }

        var fill = ((battery * 30) / 100).toNumber();
        if (fill < 0) {
            fill = 0;
        } else if (fill > 30) {
            fill = 30;
        }

        dc.setColor(StackTheme.LIME, StackTheme.BG);
        dc.drawRoundedRectangle(x, y, 38, 18, 4);
        dc.fillRectangle(x + 38, y + 5, 4, 8);
        if (fill > 0) {
            dc.fillRoundedRectangle(x + 4, y + 4, fill, 10, 2);
        }

        dc.setColor(StackTheme.TEXT, StackTheme.BG);
        dc.drawText(x + 58, y - 2, Gfx.FONT_XTINY,
            battery.format("%d%%"), Gfx.TEXT_JUSTIFY_LEFT);
    }

    function drawSteps(dc, x, y) {
        var steps = 0;
        var activity = ActivityMonitor.getInfo();

        // Activity Monitor values are allowed to be null, especially in the simulator
        // before simulated activity data has been configured. Treat missing as zero.
        if (activity != null && activity.steps != null) {
            steps = activity.steps;
        }

        var label;
        if (steps >= 1000) {
            label = Lang.format("$1$K", [(steps / 1000.0).format("%.1f")]);
        } else {
            label = steps.format("%d");
        }

        // Tiny block-built shoe mark instead of a generic Garmin activity icon.
        dc.setColor(StackTheme.CYAN, StackTheme.BG);
        dc.fillRoundedRectangle(x, y + 13, 34, 11, 4);
        dc.fillRectangle(x + 7, y + 6, 13, 11);
        dc.fillRectangle(x + 18, y + 10, 11, 10);
        dc.fillRoundedRectangle(x + 27, y + 18, 12, 6, 3);

        dc.setColor(StackTheme.TEXT, StackTheme.BG);
        dc.drawText(x + 48, y + 5, Gfx.FONT_XTINY, label, Gfx.TEXT_JUSTIFY_LEFT);
    }

    function drawDecorativeBlocks(dc) {
        // Decorative punctuation. These are intentionally not data.
        dc.setColor(StackTheme.PURPLE, StackTheme.BG);
        dc.fillRoundedRectangle(325, 145, 28, 28, 5);
        dc.fillRoundedRectangle(345, 165, 28, 28, 5);

        dc.setColor(StackTheme.YELLOW, StackTheme.BG);
        dc.fillCircle(78, 314, 17);

        dc.setColor(StackTheme.CYAN, StackTheme.BG);
        dc.fillRoundedRectangle(105, 354, 78, 20, 5);
        dc.fillRoundedRectangle(151, 339, 32, 20, 5);
    }

    function drawNumber(dc, value, x, y, cell, gap, color, outline) {
        var chars = value.toCharArray();
        var digitWidth = (cell * 5) + (gap * 4);
        var spacing = 10;

        for (var i = 0; i < chars.size(); i += 1) {
            var digit = chars[i].toNumber() - 48;
            if (digit >= 0 && digit <= 9) {
                drawDigit(dc, digit, x + (i * (digitWidth + spacing)), y, cell, gap, color, outline);
            }
        }
    }

    function drawDigit(dc, digit, x, y, cell, gap, color, outline) {
        var rows = digitRows(digit);
        dc.setColor(color, StackTheme.BG);

        for (var r = 0; r < 7; r += 1) {
            for (var c = 0; c < 5; c += 1) {
                var mask = 1 << (4 - c);
                if ((rows[r] & mask) != 0) {
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

    function digitRows(digit) {
        switch (digit) {
            case 0: return [31, 17, 19, 21, 25, 17, 31];
            case 1: return [4, 12, 4, 4, 4, 4, 14];
            case 2: return [30, 1, 1, 30, 16, 16, 31];
            case 3: return [30, 1, 1, 14, 1, 1, 30];
            case 4: return [18, 18, 18, 31, 2, 2, 2];
            case 5: return [31, 16, 16, 30, 1, 1, 30];
            case 6: return [15, 16, 16, 30, 17, 17, 14];
            case 7: return [31, 1, 2, 4, 8, 8, 8];
            case 8: return [14, 17, 17, 14, 17, 17, 14];
            case 9: return [14, 17, 17, 15, 1, 1, 30];
        }
        return [0, 0, 0, 0, 0, 0, 0];
    }
}
