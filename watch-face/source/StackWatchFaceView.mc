using Toybox.ActivityMonitor as ActivityMonitor;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
using Toybox.Time as Time;
using Toybox.Time.Gregorian as Gregorian;
using Toybox.WatchUi as WatchUi;

class StackWatchFaceView extends WatchUi.WatchFace {
    var _sleeping = false;
    var _displayFont;
    var _utilityFont;
    var _utilitySmallFont;
    var _aodFont;

    function initialize() {
        WatchFace.initialize();

        // Forerunner 265 supports scalable system fonts. Load them once instead of
        // rebuilding display geometry every update. BionicBold is number-only and
        // is the first display-font candidate from WATCH_FACE_LAYOUT_SPEC.md.
        _displayFont = Gfx.getVectorFont({ :face => "BionicBold", :size => 158 });
        _utilityFont = Gfx.getVectorFont({ :face => "RobotoCondensedBold", :size => 24 });
        _utilitySmallFont = Gfx.getVectorFont({ :face => "RobotoCondensedBold", :size => 21 });
        _aodFont = Gfx.getVectorFont({ :face => "RobotoCondensedRegular", :size => 82 });

        // Defensive fallbacks. These should not be used on fr265, but they keep
        // the face alive if a simulator/device font resource is unexpectedly absent.
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

        // Top row stays within the circular safe zone.
        drawDateBadge(dc);
        drawBattery(dc, 290, 83);

        // Real scalable typography replaces the geometric prototype digits.
        // Position each two-digit string as one measured visual mass.
        dc.setColor(StackTheme.TEXT, StackTheme.BG);
        dc.drawText(122, 72, _displayFont, hourText, Gfx.TEXT_JUSTIFY_CENTER);

        dc.setColor(StackTheme.LIME, StackTheme.BG);
        dc.drawText(292, 210, _displayFont, minuteText, Gfx.TEXT_JUSTIFY_CENTER);

        // Colon is independent punctuation between the two masses.
        dc.fillCircle(211, 177, 7);
        dc.fillCircle(211, 204, 7);

        drawSteps(dc, 47, 268);
        drawDecorativeBlocks(dc);
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
        var badgeW = textW + 28;
        var badgeH = 34;
        var badgeX = 208 - (badgeW / 2).toNumber();

        dc.setColor(StackTheme.BLUE, StackTheme.BG);
        dc.fillRoundedRectangle(badgeX, 28, badgeW, badgeH, 8);
        dc.setColor(StackTheme.TEXT, StackTheme.BLUE);
        dc.drawText(208, 31, _utilityFont, label, Gfx.TEXT_JUSTIFY_CENTER);
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
        dc.drawRoundedRectangle(x, y + 4, 26, 12, 3);
        dc.fillRectangle(x + 26, y + 7, 3, 6);

        var fill = ((battery * 18) / 100).toNumber();
        if (fill > 0) {
            dc.fillRoundedRectangle(x + 4, y + 8, fill, 4, 1);
        }

        var label = battery.toString() + "%";
        dc.setColor(StackTheme.TEXT, StackTheme.BG);
        dc.drawText(x + 36, y, _utilitySmallFont, label, Gfx.TEXT_JUSTIFY_LEFT);
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

        // Compact STACK runner mark and value as one horizontal utility object.
        dc.setColor(StackTheme.BLUE, StackTheme.BG);
        dc.fillCircle(x + 9, y + 7, 4);
        dc.fillRoundedRectangle(x + 6, y + 13, 6, 17, 2);
        dc.fillRoundedRectangle(x + 11, y + 16, 17, 5, 2);
        dc.fillRoundedRectangle(x, y + 27, 15, 5, 2);
        dc.fillRoundedRectangle(x + 16, y + 27, 16, 5, 2);

        dc.setColor(StackTheme.TEXT, StackTheme.BG);
        dc.drawText(x + 40, y + 5, _utilityFont, label, Gfx.TEXT_JUSTIFY_LEFT);

        dc.setColor(StackTheme.YELLOW, StackTheme.BG);
        dc.fillCircle(x + 6, y + 51, 8);
    }

    function drawDecorativeBlocks(dc) {
        // Decorative only; neither shape carries a metric/status meaning.
        dc.setColor(StackTheme.PURPLE, StackTheme.BG);
        dc.fillRoundedRectangle(333, 137, 25, 28, 4);
        dc.fillRoundedRectangle(349, 153, 25, 28, 4);

        dc.setColor(StackTheme.CYAN, StackTheme.BG);
        dc.fillRoundedRectangle(103, 350, 77, 19, 4);
        dc.fillRoundedRectangle(158, 334, 22, 35, 4);
    }

    function drawAlwaysOn(dc, hour, minute) {
        var displayHour = getDisplayHour(hour);
        var hourText = twoDigits(displayHour);
        var minuteText = twoDigits(minute);

        // AOD is a separate, quiet typographic composition.
        dc.setColor(StackTheme.AOD, StackTheme.BG);
        dc.drawText(208, 95, _aodFont, hourText, Gfx.TEXT_JUSTIFY_CENTER);
        dc.drawText(208, 220, _aodFont, minuteText, Gfx.TEXT_JUSTIFY_CENTER);
        dc.fillCircle(208, 194, 3);
        dc.fillCircle(208, 207, 3);

        dc.setColor(StackTheme.LIME, StackTheme.BG);
        dc.fillRoundedRectangle(195, 356, 26, 3, 1);
    }
}
