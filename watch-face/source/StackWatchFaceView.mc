using Toybox.Application;
using Toybox.Graphics as Gfx;
using Toybox.Math;
using Toybox.System as Sys;
using Toybox.Time;
using Toybox.Time.Gregorian as Gregorian;
using Toybox.WatchUi as WatchUi;

//! STACK Hero Time watch face. The 416px anchors mirror the canonical mockup;
//! all geometry is scaled from the actual round display dimensions.
class StackWatchFaceView extends WatchUi.WatchFace {
    const BASE_SIZE = 416.0;
    const RING_SEGMENTS = 16;

    // Screenshot harness only. Keep disabled in commits.
    const PIN_TIME = -1;
    const PIN_STEPS = -1;
    const PIN_SLEEP = false;

    var _width = 416;
    var _height = 416;
    var _scale = 1.0;
    var _sleeping = false;

    var _timeFont;
    var _metricFont;
    var _utilityFont;
    var _metricFallbackFont;
    var _trainerColor;
    var _trainerMono;

    var _hourColor = 0;
    var _colonColor = 3;
    var _minuteColor = 5;
    var _ringMode = 0;
    var _ringColor = 0;
    var _metricColorMode = 0;
    var _metric1Color = 0;
    var _metric2Color = 5;
    var _metric3Color = 7;
    var _trainerMode = 0;
    var _metric1 = StackMetrics.DISTANCE;
    var _metric2 = StackMetrics.HEART_RATE;
    var _metric3 = StackMetrics.BODY_BATTERY;

    function initialize() {
        WatchFace.initialize();
        loadSettings();
    }

    function onLayout(dc) {
        _width = dc.getWidth();
        _height = dc.getHeight();
        var shortSide = (_width < _height) ? _width : _height;
        _scale = shortSide.toFloat() / BASE_SIZE;
        loadResources();
    }

    function loadResources() {
        try {
            _timeFont = WatchUi.loadResource(Rez.Fonts.StackTime);
            _metricFont = WatchUi.loadResource(Rez.Fonts.StackMetric);
        } catch (e) {
            _timeFont = null;
            _metricFont = null;
        }

        if (Gfx has :getVectorFont) {
            if (_timeFont == null) {
                _timeFont = Gfx.getVectorFont({ :face => ["RobotoCondensedBold", "RobotoRegular"], :size => px(94) });
            }
            if (_metricFont == null) {
                _metricFont = Gfx.getVectorFont({ :face => ["RobotoCondensedBold", "RobotoRegular"], :size => px(32) });
            }
            _utilityFont = Gfx.getVectorFont({ :face => ["RobotoCondensedBold", "RobotoRegular"], :size => px(15) });
            _metricFallbackFont = Gfx.getVectorFont({ :face => ["RobotoCondensedBold", "RobotoRegular"], :size => px(26) });
        }
        if (_timeFont == null) { _timeFont = Gfx.FONT_NUMBER_MILD; }
        if (_metricFont == null) { _metricFont = Gfx.FONT_SMALL; }
        if (_utilityFont == null) { _utilityFont = Gfx.FONT_XTINY; }
        if (_metricFallbackFont == null) { _metricFallbackFont = Gfx.FONT_XTINY; }

        try {
            _trainerColor = WatchUi.loadResource(Rez.Drawables.TrainerBoiColor);
            _trainerMono = WatchUi.loadResource(Rez.Drawables.TrainerBoiMono);
        } catch (e) {
            _trainerColor = null;
            _trainerMono = null;
        }
    }

    function onShow() {
        loadSettings();
    }

    function loadSettings() {
        try {
            if (Application has :Properties) {
                _hourColor = numberSetting("HourColor", _hourColor);
                _colonColor = numberSetting("ColonColor", _colonColor);
                _minuteColor = numberSetting("MinuteColor", _minuteColor);
                _ringMode = numberSetting("RingMode", _ringMode);
                _ringColor = numberSetting("RingColor", _ringColor);
                _metricColorMode = numberSetting("MetricColorMode", _metricColorMode);
                _metric1Color = numberSetting("Metric1Color", _metric1Color);
                _metric2Color = numberSetting("Metric2Color", _metric2Color);
                _metric3Color = numberSetting("Metric3Color", _metric3Color);
                _trainerMode = numberSetting("TrainerBoiMode", _trainerMode);
                _metric1 = numberSetting("Metric1", _metric1);
                _metric2 = numberSetting("Metric2", _metric2);
                _metric3 = numberSetting("Metric3", _metric3);
            }
        } catch (e) {
            // Defaults are deliberately complete and simulator-safe.
        }
    }

    function numberSetting(key, fallback) {
        var value = Application.Properties.getValue(key);
        return (value == null) ? fallback : value.toNumber();
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
        if (dc has :setAntiAlias) { dc.setAntiAlias(true); }
        dc.setColor(StackTheme.BG, StackTheme.BG);
        dc.clear();

        StackMetrics.beginFrame();
        var clock = Sys.getClockTime();
        var hour = clock.hour;
        var minute = clock.min;
        if (PIN_TIME >= 0) {
            hour = PIN_TIME / 100;
            minute = PIN_TIME % 100;
        }
        var hourText = displayHour(hour).toString();
        var minuteText = twoDigits(minute);

        if (_sleeping || PIN_SLEEP) {
            drawAlwaysOn(dc, hourText, minuteText, hour, minute);
        } else {
            drawActive(dc, hourText, minuteText);
        }
    }

    function drawActive(dc, hourText, minuteText) {
        drawStepRing(dc);
        drawTopUtility(dc, 0, 0, false);
        drawHeroTime(dc, hourText, minuteText, px(76),
            StackTheme.palette(_hourColor), StackTheme.palette(_colonColor), StackTheme.palette(_minuteColor));
        drawTrainerBoi(dc);
        drawMetricShelf(dc);
        drawMetrics(dc);
    }

    //! AOD is intentionally a separate reduced composition: time plus quiet
    //! date/battery only, with no ring, metrics, or Trainer Boi bitmap.
    function drawAlwaysOn(dc, hourText, minuteText, hour, minute) {
        var phase = ((hour * 60 + minute) / 5) % 8;
        var dx = burnInX(phase);
        var dy = burnInY(phase);
        drawTopUtility(dc, dx, dy, true);
        drawHeroTime(dc, hourText, minuteText, px(88) + dy, StackTheme.AOD, StackTheme.AOD, StackTheme.AOD);
        dc.setColor(StackTheme.AOD_FAINT, StackTheme.BG);
        dc.fillRectangle((_width / 2) - px(2) + dx, px(327) + dy, px(4), px(4));
        dc.fillRectangle((_width / 2) - px(46) + dx, px(366) + dy, px(92), px(2));
    }

    function drawHeroTime(dc, hourText, minuteText, y, hourColor, colonColor, minuteColor) {
        var colon = ":";
        var hourWidth = dc.getTextWidthInPixels(hourText, _timeFont);
        var colonWidth = dc.getTextWidthInPixels(colon, _timeFont);
        var minuteWidth = dc.getTextWidthInPixels(minuteText, _timeFont);
        var total = hourWidth + colonWidth + minuteWidth;
        var x = ((_width - total) / 2).toNumber();

        dc.setColor(hourColor, Gfx.COLOR_TRANSPARENT);
        dc.drawText(x, y, _timeFont, hourText, Gfx.TEXT_JUSTIFY_LEFT);
        x += hourWidth;
        dc.setColor(colonColor, Gfx.COLOR_TRANSPARENT);
        dc.drawText(x, y, _timeFont, colon, Gfx.TEXT_JUSTIFY_LEFT);
        x += colonWidth;
        dc.setColor(minuteColor, Gfx.COLOR_TRANSPARENT);
        dc.drawText(x, y, _timeFont, minuteText, Gfx.TEXT_JUSTIFY_LEFT);
    }

    function drawTopUtility(dc, dx, dy, aod) {
        var color = aod ? StackTheme.AOD : StackTheme.TEXT;
        var y = px(62) + dy;
        dc.setColor(color, Gfx.COLOR_TRANSPARENT);
        dc.drawText(px(108) + dx, y, _utilityFont, dateLabel(), Gfx.TEXT_JUSTIFY_LEFT | Gfx.TEXT_JUSTIFY_VCENTER);
        dc.drawText(px(284) + dx, y, _utilityFont, StackMetrics.batteryPercent().toString() + "%",
            Gfx.TEXT_JUSTIFY_RIGHT | Gfx.TEXT_JUSTIFY_VCENTER);
        if (!aod) {
            dc.setColor(StackTheme.YELLOW, StackTheme.BG);
            dc.fillRectangle(px(205) + dx, px(57) + dy, px(8), px(8));
            StackMetrics.drawIcon(dc, StackMetrics.BATTERY, px(300) + dx, y, px(15), StackTheme.LIME);
        }
    }

    function drawStepRing(dc) {
        var fraction = (PIN_STEPS >= 0) ? (PIN_STEPS.toFloat() / 100.0) : StackMetrics.stepFraction();
        if (fraction < 0.0) { fraction = 0.0; }
        if (fraction > 1.0) { fraction = 1.0; }
        var filled = (fraction * RING_SEGMENTS + 0.5).toNumber();
        var radius = px(188);
        var segmentSpan = 290.0 / RING_SEGMENTS;
        dc.setPenWidth(px(8));

        for (var i = 0; i < RING_SEGMENTS; i++) {
            var start = 215.0 + i * segmentSpan + 2.0;
            var end = 215.0 + (i + 1) * segmentSpan - 2.0;
            var color = StackTheme.EMPTY;
            if (i < filled) {
                color = (_ringMode == 1) ? StackTheme.palette(_ringColor) : ringSegmentColor(i);
            }
            dc.setColor(color, StackTheme.BG);
            dc.drawLine(ringX(start, radius), ringY(start, radius), ringX(end, radius), ringY(end, radius));
        }
        dc.setPenWidth(1);
    }

    function ringX(angle, radius) {
        return (_width / 2 + Math.sin(angle * Math.PI / 180.0) * radius).toNumber();
    }

    function ringY(angle, radius) {
        return (_height / 2 - Math.cos(angle * Math.PI / 180.0) * radius).toNumber();
    }

    function ringSegmentColor(index) {
        if (index <= 2) { return StackTheme.CYAN; }
        if (index <= 5) { return StackTheme.BLUE; }
        if (index == 6) { return StackTheme.BRIGHT_BLUE; }
        if (index <= 8) { return StackTheme.YELLOW; }
        if (index <= 12) { return StackTheme.RED; }
        return StackTheme.PURPLE;
    }

    function drawTrainerBoi(dc) {
        if (_trainerMode == 2) { return; }
        var bitmap = (_trainerMode == 1) ? _trainerMono : _trainerColor;
        if (bitmap == null) { return; }
        var x = ((_width - bitmap.getWidth()) / 2).toNumber();
        dc.drawBitmap(x, px(202), bitmap);
    }

    function drawMetricShelf(dc) {
        var y = px(301);
        var left = px(52);
        var right = px(364);
        dc.setPenWidth(px(4));
        dc.setColor(StackTheme.EMPTY, StackTheme.BG);
        dc.drawLine(left, y, right, y);
        dc.setColor(metricColor(0, _metric1), StackTheme.BG);
        dc.drawLine(px(102), y, px(126), y);
        dc.setColor(metricColor(1, _metric2), StackTheme.BG);
        dc.drawLine(px(196), y, px(220), y);
        dc.setColor(metricColor(2, _metric3), StackTheme.BG);
        dc.drawLine(px(290), y, px(314), y);
        dc.setPenWidth(1);

        dc.setColor(StackTheme.EMPTY, StackTheme.BG);
        for (var i = 0; i < 4; i++) {
            dc.fillRectangle(px(149), px(319 + i * 13), px(4), px(8));
            dc.fillRectangle(px(263), px(319 + i * 13), px(4), px(8));
        }
    }

    function drawMetrics(dc) {
        drawMetric(dc, _metric1, 0, px(105));
        drawMetric(dc, _metric2, 1, px(208));
        drawMetric(dc, _metric3, 2, px(311));
    }

    function drawMetric(dc, metric, slot, x) {
        if (metric == StackMetrics.NONE) { return; }
        var color = metricColor(slot, metric);
        StackMetrics.drawIcon(dc, metric, x, px(315), px(18), color);

        var value = StackMetrics.value(metric);
        var font = StackMetrics.usesStackFont(metric) ? _metricFont : _metricFallbackFont;
        dc.setColor(StackTheme.TEXT, Gfx.COLOR_TRANSPARENT);
        dc.drawText(x, px(318), font, value, Gfx.TEXT_JUSTIFY_CENTER);
        dc.setColor(color, Gfx.COLOR_TRANSPARENT);
        dc.drawText(x, px(376), _utilityFont, StackMetrics.label(metric),
            Gfx.TEXT_JUSTIFY_CENTER | Gfx.TEXT_JUSTIFY_VCENTER);
    }

    function metricColor(slot, metric) {
        if (_metricColorMode == 1) {
            if (slot == 0) { return StackTheme.palette(_hourColor); }
            if (slot == 1) { return StackTheme.palette(_colonColor); }
            return StackTheme.palette(_minuteColor);
        }
        if (_metricColorMode == 2) {
            if (slot == 0) { return StackTheme.palette(_metric1Color); }
            if (slot == 1) { return StackTheme.palette(_metric2Color); }
            return StackTheme.palette(_metric3Color);
        }
        return StackMetrics.accent(metric);
    }

    function px(value) {
        return (value * _scale + 0.5).toNumber();
    }

    function burnInX(phase) {
        if (phase == 1 || phase == 2) { return px(2); }
        if (phase == 4 || phase == 5 || phase == 6) { return -px(2); }
        return 0;
    }

    function burnInY(phase) {
        if (phase == 2 || phase == 3 || phase == 4) { return px(2); }
        if (phase == 6 || phase == 7) { return -px(2); }
        return 0;
    }

    function displayHour(hour) {
        var settings = Sys.getDeviceSettings();
        if (settings != null && !settings.is24Hour) {
            var twelve = hour % 12;
            return (twelve == 0) ? 12 : twelve;
        }
        return hour;
    }

    function twoDigits(value) {
        return (value < 10) ? "0" + value.toString() : value.toString();
    }

    function dateLabel() {
        var info = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
        if (info == null || info.day == null || info.month == null) { return "DAY --/--"; }
        return weekdayLabel(info.day_of_week) + " " + info.month.toString() + "/" + info.day.toString();
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
