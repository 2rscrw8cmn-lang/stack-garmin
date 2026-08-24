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

        // BionicBold is the approved primary display face for OFFSET on fr265.
        // Load vector fonts once and keep the render path lightweight.
        _displayFont = Gfx.getVectorFont({ :face => "BionicBold", :size => 220 });
        _utilityFont = Gfx.getVectorFont({ :face => "RobotoCondensedBold", :size => 23 });
        _utilitySmallFont = Gfx.getVectorFont({ :face => "RobotoCondensedBold", :size => 19 });
        _aodFont = Gfx.getVectorFont({ :face => "RobotoCondensedRegular", :size => 88 });

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
        var hourText = displayHourText(hour);
        var minuteText = twoDigits(minute);

        drawDateBadge(dc);
        drawBattery(dc, 286, 80);

        // OFFSET is one diagonal typographic composition, not two separate rows.
        // Oversize the two masses and let the circular canvas provide the crop/energy.
        dc.setColor(StackTheme.TEXT, StackTheme.BG);
        dc.drawText(118, 42, _displayFont, hourText, Gfx.TEXT_JUSTIFY_CENTER);

        dc.setColor(StackTheme.LIME, StackTheme.BG);
        dc.drawText(298, 172, _displayFont, minuteText, Gfx.TEXT_JUSTIFY_CENTER);

        // Small independent punctuation between the two masses.
        dc.fillCircle(211, 166, 7);
        dc.fillCircle(211, 193, 7);

        drawSteps(dc, 50, 274);
        drawDecorativeBlocks(dc);
    }

    function displayHourText(hour) {
        var settings = Sys.getDeviceSettings();
        if (settings != null && !settings.is24Hour) {
            var twelve = hour % 12;
            if (twelve == 0) { twelve = 12; }
            return twelve.toString();
        }
        return twoDigits(hour);
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
        var badgeH = 31;
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

        var label = battery.toString() + "%";
        dc.setColor(StackTheme.TEXT, StackTheme.BG);
        dc.drawText(x + 34, y, _utilitySmallFont, label, Gfx.TEXT_JUSTIFY_LEFT);
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

        // Compact chunky shoe/run mark. One object, one value, no label.
        dc.setColor(StackTheme.BLUE, StackTheme.BG);
        dc.fillRoundedRectangle(x, y + 13, 32, 9, 4);
        dc.fillRoundedRectangle(x + 5, y + 6, 14, 10, 3);
        dc.fillRoundedRectangle(x + 17, y + 10, 12, 9, 3);
        dc.fillRoundedRectangle(x + 27, y + 17, 10, 5, 2);

        dc.setColor(StackTheme.TEXT, StackTheme.BG);
        dc.drawText(x + 45, y + 3, _utilityFont, label, Gfx.TEXT_JUSTIFY_LEFT);
    }

    function drawDecorativeBlocks(dc) {
        // Purple punctuation fills the upper-right negative space.
        dc.setColor(StackTheme.PURPLE, StackTheme.BG);
        dc.fillRoundedRectangle(335, 128, 24, 28, 4);
        dc.fillRoundedRectangle(351, 144, 24, 28, 4);

        // Cyan punctuation anchors the lower-left without becoming another metric.
        dc.setColor(StackTheme.CYAN, StackTheme.BG);
        dc.fillRoundedRectangle(96, 350, 80, 19, 4);
        dc.fillRoundedRectangle(153, 333, 23, 36, 4);
    }

    function drawAlwaysOn(dc, hour, minute) {
        var hourText = displayHourText(hour);
        var minuteText = twoDigits(minute);

        dc.setColor(StackTheme.AOD, StackTheme.BG);
        dc.drawText(208, 88, _aodFont, hourText, Gfx.TEXT_JUSTIFY_CENTER);
        dc.drawText(208, 214, _aodFont, minuteText, Gfx.TEXT_JUSTIFY_CENTER);
        dc.fillCircle(208, 190, 3);
        dc.fillCircle(208, 204, 3);

        dc.setColor(StackTheme.LIME, StackTheme.BG);
        dc.fillRoundedRectangle(195, 356, 26, 3, 1);
    }
}
