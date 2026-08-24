using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
using Toybox.Time as Time;
using Toybox.Time.Gregorian as Gregorian;
using Toybox.WatchUi as WatchUi;
using Toybox.Weather as Weather;

//! STACK OFFSET watch face for the Forerunner 265 (416 x 416 AMOLED).
//!
//! Composition rule: TIME FIRST, EVERYTHING ELSE IS PUNCTUATION. The hour sits
//! upper-left in white, the minute lower-right in lime, and the remaining marks
//! are small graphic notes placed in the negative space around them.
class StackWatchFaceView extends WatchUi.WatchFace {

    // --- screen -----------------------------------------------------------
    const CX = 208;
    const CY = 208;

    // --- optical boxes for the display numbers ----------------------------
    // Left, top, right, bottom. Numbers are fitted inside and bottom aligned so
    // the baseline never moves. The boxes were chosen so the widest digit pair
    // still clears the circular display; see docs/WATCH_FACE_LAYOUT_SPEC.md.
    const HOUR_L = 46.0;
    const HOUR_T = 66.0;
    const HOUR_R = 240.0;
    const HOUR_B = 206.0;

    const MIN_L = 178.0;
    const MIN_T = 214.0;
    const MIN_R = 366.0;
    const MIN_B = 352.0;

    const COLON_GAP = 14;
    const COLON_TOP_Y = 152;
    const COLON_BOT_Y = 190;
    const COLON_R = 11;

    const AOD_HOUR_B = 162.0;
    const AOD_MIN_B = 296.0;
    const AOD_CAP = 80.0;

    // Screenshot harness only. -1 uses the live clock; 1042 pins 10:42.
    // Must be -1 in anything shipped.
    const PIN_TIME = -1;
    // Set true to force the always-on state for capture.
    const PIN_SLEEP = false;

    var _sleeping = false;
    var _labelFont;
    var _valueFont;
    var _tempFont;

    function initialize() {
        WatchFace.initialize();

        // Fonts load once. The display numerals are drawn as polygons by
        // StackDigits, so no large font resource is held for the time itself.
        _labelFont = Gfx.getVectorFont({ :face => "RobotoCondensedBold", :size => 24 });
        _valueFont = Gfx.getVectorFont({ :face => "RobotoCondensedBold", :size => 26 });
        _tempFont = Gfx.getVectorFont({ :face => "RobotoCondensedBold", :size => 48 });

        if (_labelFont == null) { _labelFont = Gfx.FONT_XTINY; }
        if (_valueFont == null) { _valueFont = Gfx.FONT_XTINY; }
        if (_tempFont == null) { _tempFont = Gfx.FONT_MEDIUM; }
    }

    function onEnterSleep() {
        _sleeping = true;
        WatchUi.requestUpdate();
    }

    function onExitSleep() {
        _sleeping = false;
        WatchUi.requestUpdate();
    }

    function onUpdate(dc) {
        if (dc has :setAntiAlias) {
            dc.setAntiAlias(true);
        }

        dc.setColor(StackTheme.BG, StackTheme.BG);
        dc.clear();

        var clock = Sys.getClockTime();
        var hour = clock.hour;
        var minute = clock.min;
        if (PIN_TIME >= 0) {
            hour = PIN_TIME / 100;
            minute = PIN_TIME % 100;
        }
        var hourText = twoDigits(displayHour(hour));
        var minuteText = twoDigits(minute);

        if (_sleeping || PIN_SLEEP) {
            drawAlwaysOn(dc, hourText, minuteText);
        } else {
            drawOffset(dc, hourText, minuteText);
        }
    }

    // ======================================================================
    // OFFSET
    // ======================================================================

    function drawOffset(dc, hourText, minuteText) {
        drawDateBadge(dc);
        drawBattery(dc);
        drawPurpleBlock(dc);

        var hourRight = drawHour(dc, hourText);
        drawColon(dc, hourRight);
        drawMinute(dc, minuteText);

        drawRunner(dc);
        drawWeather(dc);
        drawCyanBlock(dc);
    }

    //! Fit a display number inside an optical box and draw it.
    //! The group is scaled to the box, centred horizontally and bottom aligned,
    //! then its measured right edge is returned so neighbouring marks can be
    //! placed against real geometry rather than a guessed text origin.
    function drawDisplayGroup(dc, text, l, t, r, b, color) {
        var unit = StackDigits.unitWidth(text);
        var cap = b - t;
        var byWidth = (r - l) / unit;
        if (byWidth < cap) { cap = byWidth; }

        var width = unit * cap;
        var x = l + ((r - l) - width) / 2.0;
        var y = b - cap;

        dc.setColor(color, StackTheme.BG);
        StackDigits.drawNumber(dc, text, x, y, cap);

        return x + width;
    }

    function drawHour(dc, text) {
        return drawDisplayGroup(dc, text, HOUR_L, HOUR_T, HOUR_R, HOUR_B,
            StackTheme.TEXT);
    }

    function drawMinute(dc, text) {
        return drawDisplayGroup(dc, text, MIN_L, MIN_T, MIN_R, MIN_B,
            StackTheme.LIME);
    }

    //! The colon bridges the two number masses, so it hangs off the measured
    //! right edge of the hour rather than off a fixed coordinate.
    function drawColon(dc, hourRight) {
        var x = (hourRight + COLON_GAP).toNumber();
        dc.setColor(StackTheme.LIME, StackTheme.BG);
        dc.fillCircle(x, COLON_TOP_Y, COLON_R);
        dc.fillCircle(x, COLON_BOT_Y, COLON_R);
    }

    //! Small graphic label stuck onto the poster, not a UI pill.
    function drawDateBadge(dc) {
        var label = dateLabel();
        var textW = dc.getTextWidthInPixels(label, _labelFont);
        var badgeW = textW + 24;
        var badgeH = 33;
        var badgeX = CX - (badgeW / 2).toNumber();
        var badgeY = 26;

        dc.setColor(StackTheme.BLUE, StackTheme.BG);
        dc.fillRoundedRectangle(badgeX, badgeY, badgeW, badgeH, 6);

        dc.setColor(StackTheme.TEXT, StackTheme.BLUE);
        dc.drawText(CX, badgeY + (badgeH / 2), _labelFont, label,
            Gfx.TEXT_JUSTIFY_CENTER | Gfx.TEXT_JUSTIFY_VCENTER);
    }

    function drawBattery(dc) {
        var pct = batteryPercent();
        var x = 288;
        var y = 76;
        var w = 28;
        var h = 15;

        dc.setColor(StackTheme.LIME, StackTheme.BG);
        dc.setPenWidth(3);
        dc.drawRoundedRectangle(x, y, w, h, 4);
        dc.setPenWidth(1);
        dc.fillRectangle(x + w + 1, y + 4, 3, 7);

        var fill = ((w - 8) * pct / 100).toNumber();
        if (fill > 0) {
            dc.fillRectangle(x + 4, y + 4, fill, 7);
        }

        dc.setColor(StackTheme.TEXT, StackTheme.BG);
        dc.drawText(x + 38, y + 7, _valueFont, pct.toString() + "%",
            Gfx.TEXT_JUSTIFY_LEFT | Gfx.TEXT_JUSTIFY_VCENTER);
    }

    //! Chunky STACK pictogram, not a Garmin line icon. Carries no value in v1.
    function drawRunner(dc) {
        dc.setColor(StackTheme.BLUE, StackTheme.BG);
        dc.fillCircle(90, 220, 7);
        dc.fillPolygon([[75, 231], [82, 246], [92, 242], [87, 227]]);
        dc.fillPolygon([[83, 233], [97, 239], [99, 233], [86, 226]]);
        dc.fillPolygon([[101, 238], [108, 228], [104, 224], [95, 234]]);
        dc.fillPolygon([[80, 226], [67, 224], [66, 231], [78, 234]]);
        dc.fillPolygon([[64, 225], [56, 235], [61, 239], [69, 229]]);
        dc.fillPolygon([[83, 248], [98, 255], [102, 248], [88, 239]]);
        dc.fillPolygon([[96, 249], [89, 263], [95, 266], [103, 253]]);
        dc.fillPolygon([[91, 268], [101, 270], [102, 265], [93, 262]]);
        dc.fillPolygon([[79, 240], [68, 250], [72, 257], [85, 248]]);
        dc.fillPolygon([[67, 251], [59, 264], [64, 268], [73, 256]]);
        dc.fillPolygon([[60, 264], [53, 268], [56, 272], [63, 269]]);
    }

    function drawWeather(dc) {
        dc.setColor(StackTheme.YELLOW, StackTheme.BG);
        dc.fillCircle(76, 298, 20);

        dc.setColor(StackTheme.TEXT, StackTheme.BG);
        dc.drawText(110, 298, _tempFont, temperatureLabel(),
            Gfx.TEXT_JUSTIFY_LEFT | Gfx.TEXT_JUSTIFY_VCENTER);
    }

    //! Decoration only. Balances the lime minute mass across the lower half.
    function drawCyanBlock(dc) {
        dc.setColor(StackTheme.CYAN, StackTheme.BG);
        dc.fillRectangle(98, 324, 54, 26);
        dc.fillRectangle(98, 346, 82, 26);
    }

    //! Decoration only. Fills the upper-right negative space.
    function drawPurpleBlock(dc) {
        dc.setColor(StackTheme.PURPLE, StackTheme.BG);
        dc.fillRectangle(320, 120, 34, 32);
        dc.fillRectangle(344, 148, 40, 34);
    }

    // ======================================================================
    // ALWAYS ON
    // ======================================================================

    function drawAlwaysOn(dc, hourText, minuteText) {
        var l = CX - 64.0;
        var r = CX + 64.0;

        drawDisplayGroup(dc, hourText, l, AOD_HOUR_B - AOD_CAP, r, AOD_HOUR_B,
            StackTheme.AOD);
        drawDisplayGroup(dc, minuteText, l, AOD_MIN_B - AOD_CAP, r, AOD_MIN_B,
            StackTheme.AOD);

        dc.setColor(StackTheme.AOD, StackTheme.BG);
        dc.fillCircle(CX, 182, 5);
        dc.fillCircle(CX, 200, 5);
        dc.drawText(CX, 340, _labelFont, dateLabel(),
            Gfx.TEXT_JUSTIFY_CENTER | Gfx.TEXT_JUSTIFY_VCENTER);

        dc.setColor(StackTheme.LIME, StackTheme.BG);
        dc.fillRectangle(194, 358, 28, 4);
    }

    // ======================================================================
    // data
    // ======================================================================

    function displayHour(hour) {
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

    function dateLabel() {
        var info = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
        if (info == null || info.day == null) {
            return "STACK";
        }
        return weekdayLabel(info.day_of_week) + " " + info.day.toString();
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

    function batteryPercent() {
        var stats = Sys.getSystemStats();
        if (stats == null || stats.battery == null) {
            return 0;
        }
        return stats.battery.toNumber();
    }

    //! Built by concatenation on purpose: format() has produced
    //! "Unexpected input to format" crashes here with odd inputs.
    function temperatureLabel() {
        var current = Weather.getCurrentConditions();
        if (current == null || current.temperature == null) {
            return "--°";
        }

        var temp = current.temperature;
        var settings = Sys.getDeviceSettings();
        if (settings != null && settings.temperatureUnits == Sys.UNIT_STATUTE) {
            temp = (temp * 9.0 / 5.0) + 32.0;
        }

        return temp.toNumber().toString() + "°";
    }
}
