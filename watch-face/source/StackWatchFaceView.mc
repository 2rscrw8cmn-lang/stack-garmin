using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
using Toybox.Time;
using Toybox.Time.Gregorian as Gregorian;
using Toybox.WatchUi as WatchUi;

//! STACK OFFSET watch face for the Forerunner 265 (416 x 416 AMOLED).
//!
//! Composition rule: TIME FIRST, EVERYTHING ELSE IS PUNCTUATION. The hour sits
//! upper-left in white, the minute lower-right in lime, and everything else is
//! a small graphic note in the negative space around them.
//!
//! Always-on is the SAME composition, not a second layout: identical boxes,
//! identical colon anchoring, identical date and battery positions, drawn with
//! hairline strokes in AOD gray. Waking should read as colour and detail
//! turning on, never as the face rearranging itself.
class StackWatchFaceView extends WatchUi.WatchFace {

    const CX = 208;
    const CY = 208;

    // --- optical boxes for the display numbers ----------------------------
    // Left, top, right, bottom. Numbers are fitted inside and bottom aligned so
    // the baseline never moves. Chosen so the widest digit pair still clears the
    // circular display; see docs/WATCH_FACE_LAYOUT_SPEC.md.
    const HOUR_L = 46.0;
    const HOUR_T = 66.0;
    const HOUR_R = 240.0;
    const HOUR_B = 206.0;

    const MIN_L = 178.0;
    const MIN_T = 214.0;
    const MIN_R = 366.0;
    const MIN_B = 352.0;

    const COLON_GAP = 19;
    const COLON_TOP_Y = 152;
    const COLON_BOT_Y = 190;
    const COLON_R = 11;
    const COLON_R_AOD = 6;

    const DATE_Y = 26;
    const DATE_H = 33;

    // --- secondary data slots ---------------------------------------------
    // x, centre y, mark height. Fonts are held per slot on the instance.
    const SLOT_A_X = 288;
    const SLOT_A_Y = 84;
    const SLOT_A_H = 16;

    const SLOT_B_X = 52;
    const SLOT_B_Y = 250;
    const SLOT_B_H = 30;

    const SLOT_C_X = 52;
    const SLOT_C_Y = 300;
    const SLOT_C_H = 28;

    const SLOT_GAP = 8;

    // Screenshot harness only. -1 uses the live clock; 1042 pins 10:42.
    // Must be -1 in anything shipped.
    const PIN_TIME = -1;
    // Set true to force the always-on state for capture.
    const PIN_SLEEP = false;

    var _sleeping = false;
    var _slotAMetric;
    var _slotBMetric;
    var _slotCMetric;
    var _labelFont;
    var _slotAFont;
    var _slotBFont;
    var _slotCFont;

    function initialize() {
        WatchFace.initialize();

        // Default OFFSET data configuration. The slot model means these can be
        // reassigned to any StackMetrics id without touching the layout.
        _slotAMetric = StackMetrics.BATTERY;
        _slotBMetric = StackMetrics.STEPS;
        _slotCMetric = StackMetrics.TEMPERATURE;

        // Fonts load once. The display numerals are polygons drawn by
        // StackDigits, so no font resource is held for the time itself.
        _labelFont = Gfx.getVectorFont({ :face => "RobotoCondensedBold", :size => 24 });
        _slotAFont = Gfx.getVectorFont({ :face => "RobotoCondensedBold", :size => 26 });
        _slotBFont = Gfx.getVectorFont({ :face => "RobotoCondensedBold", :size => 28 });
        _slotCFont = Gfx.getVectorFont({ :face => "RobotoCondensedBold", :size => 34 });

        if (_labelFont == null) { _labelFont = Gfx.FONT_XTINY; }
        if (_slotAFont == null) { _slotAFont = Gfx.FONT_XTINY; }
        if (_slotBFont == null) { _slotBFont = Gfx.FONT_XTINY; }
        if (_slotCFont == null) { _slotCFont = Gfx.FONT_SMALL; }
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
            drawAlwaysOn(dc, hourText, minuteText, hour, minute);
        } else {
            drawOffset(dc, hourText, minuteText);
        }
    }

    // ======================================================================
    // OFFSET
    // ======================================================================

    function drawOffset(dc, hourText, minuteText) {
        drawDate(dc, StackTheme.BLUE, StackTheme.TEXT, 0, 0);
        drawPurpleBlock(dc);

        drawDataSlot(dc, _slotAMetric, SLOT_A_X, SLOT_A_Y, SLOT_A_H, _slotAFont,
            null, 0, 0);

        var hourRight = drawHour(dc, hourText, 1.0, StackTheme.TEXT, 0, 0);
        drawColon(dc, hourRight, StackTheme.LIME, COLON_R, 0, 0);
        drawMinute(dc, minuteText, 1.0, StackTheme.LIME, 0, 0);

        drawDataSlot(dc, _slotBMetric, SLOT_B_X, SLOT_B_Y, SLOT_B_H, _slotBFont,
            null, 0, 0);
        drawDataSlot(dc, _slotCMetric, SLOT_C_X, SLOT_C_Y, SLOT_C_H, _slotCFont,
            null, 0, 0);

        drawCyanBlock(dc);
    }

    // ======================================================================
    // ALWAYS ON - same geometry, hairline strokes, no colour
    // ======================================================================

    function drawAlwaysOn(dc, hourText, minuteText, hour, minute) {
        // Slow deterministic drift so a static composition never sits on the
        // same pixels all day. One step per five minutes is imperceptible.
        var phase = ((hour * 60 + minute) / 5) % 8;
        var dx = shiftX(phase);
        var dy = shiftY(phase);
        var w = StackDigits.AOD_WEIGHT;

        drawDate(dc, null, StackTheme.AOD, dx, dy);

        var hourRight = drawHour(dc, hourText, w, StackTheme.AOD, dx, dy);
        drawColon(dc, hourRight, StackTheme.AOD, COLON_R_AOD, dx, dy);
        drawMinute(dc, minuteText, w, StackTheme.AOD, dx, dy);

        drawDataSlot(dc, _slotAMetric, SLOT_A_X, SLOT_A_Y, SLOT_A_H, _slotAFont,
            StackTheme.AOD, dx, dy);
    }

    function shiftX(phase) {
        if (phase == 1 || phase == 2) { return 1; }
        if (phase == 4 || phase == 5 || phase == 6) { return -1; }
        return 0;
    }

    function shiftY(phase) {
        if (phase == 2 || phase == 3 || phase == 4) { return 1; }
        if (phase == 6 || phase == 7) { return -1; }
        return 0;
    }

    // ======================================================================
    // shared drawing
    // ======================================================================

    //! Fit a display number inside an optical box and draw it.
    //! Scaled to the box, centred horizontally, bottom aligned, then its
    //! measured right edge is returned so neighbouring marks can be placed
    //! against real geometry rather than a guessed text origin.
    function drawDisplayGroup(dc, text, l, t, r, b, weight, color) {
        var unit = StackDigits.unitWidth(text);
        var cap = b - t;
        var byWidth = (r - l) / unit;
        if (byWidth < cap) { cap = byWidth; }

        var width = unit * cap;
        var x = l + ((r - l) - width) / 2.0;
        var y = b - cap;

        StackDigits.drawNumber(dc, text, x, y, cap, weight, color, StackTheme.BG);
        return x + width;
    }

    function drawHour(dc, text, weight, color, dx, dy) {
        return drawDisplayGroup(dc, text, HOUR_L + dx, HOUR_T + dy,
            HOUR_R + dx, HOUR_B + dy, weight, color);
    }

    function drawMinute(dc, text, weight, color, dx, dy) {
        return drawDisplayGroup(dc, text, MIN_L + dx, MIN_T + dy,
            MIN_R + dx, MIN_B + dy, weight, color);
    }

    //! The colon bridges the two number masses, so it hangs off the measured
    //! right edge of the hour rather than off a fixed coordinate.
    function drawColon(dc, hourRight, color, radius, dx, dy) {
        var x = (hourRight + COLON_GAP).toNumber();
        dc.setColor(color, StackTheme.BG);
        dc.fillCircle(x, COLON_TOP_Y + dy, radius);
        dc.fillCircle(x, COLON_BOT_Y + dy, radius);
    }

    //! A small graphic label stuck onto the poster, not a UI pill. In always-on
    //! the fill is dropped and only the gray text stays, in the same place.
    function drawDate(dc, badgeColor, textColor, dx, dy) {
        var label = dateLabel();
        var cx = CX + dx;
        var cy = DATE_Y + dy + (DATE_H / 2);

        if (badgeColor != null) {
            var badgeW = dc.getTextWidthInPixels(label, _labelFont) + 24;
            dc.setColor(badgeColor, StackTheme.BG);
            dc.fillRoundedRectangle(cx - (badgeW / 2).toNumber(), DATE_Y + dy,
                badgeW, DATE_H, 6);
        }

        dc.setColor(textColor, StackTheme.BG);
        dc.drawText(cx, cy, _labelFont, label,
            Gfx.TEXT_JUSTIFY_CENTER | Gfx.TEXT_JUSTIFY_VCENTER);
    }

    //! One secondary metric: graphic mark, then compact value. `tint` overrides
    //! both the mark accent and the value colour for always-on.
    function drawDataSlot(dc, metric, x, cy, iconH, font, tint, dx, dy) {
        if (metric == StackMetrics.NONE) { return; }

        var markColor = (tint == null) ? StackMetrics.accent(metric) : tint;
        var textColor = (tint == null) ? StackTheme.TEXT : tint;

        var w = StackMetrics.drawIcon(dc, metric, x + dx, cy + dy, iconH, markColor);

        dc.setColor(textColor, StackTheme.BG);
        dc.drawText((x + dx + w + SLOT_GAP).toNumber(), cy + dy, font,
            StackMetrics.value(metric),
            Gfx.TEXT_JUSTIFY_LEFT | Gfx.TEXT_JUSTIFY_VCENTER);
    }

    //! Decoration only. Balances the lime minute mass across the lower half.
    function drawCyanBlock(dc) {
        dc.setColor(StackTheme.CYAN, StackTheme.BG);
        dc.fillRectangle(104, 330, 50, 24);
        dc.fillRectangle(104, 350, 68, 24);
    }

    //! Decoration only. Fills the upper-right negative space.
    function drawPurpleBlock(dc) {
        dc.setColor(StackTheme.PURPLE, StackTheme.BG);
        dc.fillRectangle(322, 124, 32, 30);
        dc.fillRectangle(346, 150, 36, 32);
    }

    // ======================================================================
    // clock data
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
}
