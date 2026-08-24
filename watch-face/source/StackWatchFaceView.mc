using Toybox.ActivityMonitor as ActivityMonitor;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
using Toybox.Time as Time;
using Toybox.Time.Gregorian as Gregorian;
using Toybox.WatchUi as WatchUi;
using Toybox.Weather as Weather;

class StackWatchFaceView extends WatchUi.WatchFace {
    var _sleeping = false;
    var _displayFont;
    var _utilityFont;
    var _utilitySmallFont;
    var _aodFont;

    function initialize() {
        WatchFace.initialize();

        // BionicBold is now the locked display family for OFFSET.
        _displayFont = Gfx.getVectorFont({ :face => "BionicBold", :size => 238 });
        _utilityFont = Gfx.getVectorFont({ :face => "RobotoCondensedBold", :size => 24 });
        _utilitySmallFont = Gfx.getVectorFont({ :face => "RobotoCondensedBold", :size => 20 });
        _aodFont = Gfx.getVectorFont({ :face => "RobotoCondensedRegular", :size => 86 });

        if (_displayFont == null) { _displayFont = Gfx.FONT_NUMBER_HOT; }
        if (_utilityFont == null) { _utilityFont = Gfx.FONT_XTINY; }
        if (_utilitySmallFont == null) { _utilitySmallFont = Gfx.FONT_XTINY; }
        if (_aodFont == null) { _aodFont = Gfx.FONT_NUMBER_MEDIUM; }
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
        var hourText = twoDigits(displayHour);
        var minuteText = twoDigits(minute);

        // Top utility row.
        drawDateBadge(dc);
        drawBattery(dc, 292, 78);

        // Main poster typography. The leading zero is deliberate graphic structure.
        dc.setColor(StackTheme.TEXT, StackTheme.BG);
        dc.drawText(112, 56, _displayFont, hourText, Gfx.TEXT_JUSTIFY_CENTER);

        dc.setColor(StackTheme.LIME, StackTheme.BG);
        dc.drawText(292, 190, _displayFont, minuteText, Gfx.TEXT_JUSTIFY_CENTER);

        // Colon bridges the two masses without joining either one.
        dc.fillCircle(211, 166, 7);
        dc.fillCircle(211, 194, 7);

        // Purposeful lower-left utility stack.
        drawWeather(dc, 50, 267);
        drawSteps(dc, 55, 318);

        // One non-functional accent piece is enough.
        drawPurpleBlock(dc);
    }

    function getDisplayHour(hour) {
        var settings = Sys.getDeviceSettings();
        if (settings != null && !settings.is24Hour) {
            var twelve = hour % 12;
            if (twelve == 0) { twelve = 12; }
            return twelve;
        }
        return hour;
    }

    function twoDigits(value) {
        if (value < 10) {
            return "0" + value.toString();
        }
        return value.toString();
    }

    function drawDateBadge(dc) {
        var label = "TODAY";
        var info = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
        if (info != null) {
            label = weekdayLabel(info.day_of_week) + " " + info.day.toString();
        }

        var textW = dc.getTextWidthInPixels(label, _utilityFont);
        var badgeW = textW + 24;
        var badgeH = 32;
        var badgeX = 208 - (badgeW / 2).toNumber();

        dc.setColor(StackTheme.BLUE, StackTheme.BG);
        dc.fillRoundedRectangle(badgeX, 26, badgeW, badgeH, 7);
        dc.setColor(StackTheme.TEXT, StackTheme.BLUE);
        dc.drawText(208, 28, _utilityFont, label, Gfx.TEXT_JUSTIFY_CENTER);
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
        dc.drawRoundedRectangle(x, y + 4, 24, 11, 3);
        dc.fillRectangle(x + 24, y + 7, 3, 5);

        var fill = ((battery * 16) / 100).toNumber();
        if (fill > 0) {
            dc.fillRoundedRectangle(x + 4, y + 8, fill, 3, 1);
        }

        dc.setColor(StackTheme.TEXT, StackTheme.BG);
        dc.drawText(x + 34, y, _utilitySmallFont,
            battery.toString() + "%", Gfx.TEXT_JUSTIFY_LEFT);
    }

    function drawWeather(dc, x, y) {
        var label = "--°";
        var current = Weather.getCurrentConditions();

        if (current != null && current.temperature != null) {
            var temp = current.temperature;
            var settings = Sys.getDeviceSettings();

            if (settings != null && settings.temperatureUnits == Sys.UNIT_STATUTE) {
                temp = (temp * 9.0 / 5.0) + 32.0;
            }

            label = temp.toNumber().toString() + "°";
        }

        drawSun(dc, x + 12, y + 13);

        dc.setColor(StackTheme.TEXT, StackTheme.BG);
        dc.drawText(x + 36, y, _utilityFont, label, Gfx.TEXT_JUSTIFY_LEFT);
    }

    function drawSun(dc, cx, cy) {
        dc.setColor(StackTheme.YELLOW, StackTheme.BG);
        dc.fillCircle(cx, cy, 8);

        dc.fillRectangle(cx - 2, cy - 16, 4, 5);
        dc.fillRectangle(cx - 2, cy + 11, 4, 5);
        dc.fillRectangle(cx - 16, cy - 2, 5, 4);
        dc.fillRectangle(cx + 11, cy - 2, 5, 4);
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

        // Chunky cyan shoe/run mark rather than a miniature stick figure.
        dc.setColor(StackTheme.CYAN, StackTheme.BG);
        dc.fillRoundedRectangle(x, y + 10, 29, 10, 4);
        dc.fillRoundedRectangle(x + 7, y + 4, 13, 11, 3);
        dc.fillRoundedRectangle(x + 22, y + 14, 12, 6, 3);

        dc.setColor(StackTheme.TEXT, StackTheme.BG);
        dc.drawText(x + 43, y, _utilityFont, label, Gfx.TEXT_JUSTIFY_LEFT);
    }

    function drawPurpleBlock(dc) {
        dc.setColor(StackTheme.PURPLE, StackTheme.BG);
        dc.fillRoundedRectangle(336, 133, 25, 29, 4);
        dc.fillRoundedRectangle(351, 149, 25, 29, 4);
    }

    function drawAlwaysOn(dc, hour, minute) {
        var displayHour = getDisplayHour(hour);
        var hourText = twoDigits(displayHour);
        var minuteText = twoDigits(minute);

        dc.setColor(StackTheme.AOD, StackTheme.BG);
        dc.drawText(208, 96, _aodFont, hourText, Gfx.TEXT_JUSTIFY_CENTER);
        dc.drawText(208, 218, _aodFont, minuteText, Gfx.TEXT_JUSTIFY_CENTER);
        dc.fillCircle(208, 191, 3);
        dc.fillCircle(208, 204, 3);

        dc.setColor(StackTheme.LIME, StackTheme.BG);
        dc.fillRoundedRectangle(195, 355, 26, 3, 1);
    }
}
