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
    const RING_VISIBLE_SEGMENTS = 14;
    const METRIC_LEFT_X = 115;
    const METRIC_CENTER_X = 208;
    const METRIC_RIGHT_X = 301;
    const RING_STEPS = 0;
    const RING_INTENSITY_MINUTES = 1;
    const RING_WEEKLY_RUN = 2;
    const RING_BODY_BATTERY = 3;
    const RING_OFF = 4;

    // Masonry geometry. Class level because the block count and the draw pass
    // both walk it, and the two must agree exactly or the step fill lands on
    // the wrong blocks.
    const MASONRY_ROWS = 15;
    const MASONRY_WIDTHS = [52, 68, 44, 60];
    const MASONRY_RADIUS = 181;
    const MASONRY_TILE_H = 22;
    const MASONRY_GAP = 3;
    const MASONRY_ROW_PITCH = 25;
    const MASONRY_TOP = 29;
    const MASONRY_INSET = 4;
    const MASONRY_MIN_W = 10;

    // Screenshot harness only. Keep disabled in commits.
    const PIN_TIME = -1;
    const PIN_STEPS = -1;
    const PIN_SLEEP = false;

    var _width = 416;
    var _height = 416;
    var _scale = 1.0;
    var _sleeping = false;

    // Bottom-up index of the first block in each masonry row, and the total.
    // Measured once in onLayout - the geometry only depends on the panel.
    var _rowBase;
    var _blockTotal = 0;

    var _timeFont;
    var _heroTimeFont;
    var _heroOutlineFont;
    var _metricFont;
    var _utilityFont;
    var _trainerColor;
    var _trainerMono;

    var _ringSource = RING_STEPS;
    var _weeklyRunGoal = 20;
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
        measureMasonry();
        loadResources();
    }

    //! Number the masonry blocks from the bottom row upward so the step fill
    //! reads as courses being laid. The draw pass runs top-down, so each row
    //! needs the running total of everything below it.
    function measureMasonry() {
        var counts = new [MASONRY_ROWS];
        for (var row = 0; row < MASONRY_ROWS; row++) {
            counts[row] = masonryRowCount(row);
        }
        _rowBase = new [MASONRY_ROWS];
        var below = 0;
        for (var row = MASONRY_ROWS - 1; row >= 0; row--) {
            _rowBase[row] = below;
            below += counts[row];
        }
        _blockTotal = below;
    }

    //! Left and right edge of one masonry row, or null where the row falls
    //! outside the bezel. Shared by the count and the draw pass.
    function masonryRowSpan(row) {
        var radius = px(MASONRY_RADIUS);
        var y = px(MASONRY_TOP + row * MASONRY_ROW_PITCH);
        var dy = (y + px(MASONRY_TILE_H) / 2) - (_height / 2);
        var inside = radius * radius - dy * dy;
        if (inside <= 0) { return null; }
        var half = Math.sqrt(inside).toNumber();
        return [ _width / 2 - half + px(MASONRY_INSET), _width / 2 + half - px(MASONRY_INSET) ];
    }

    function masonryRowCount(row) {
        var span = masonryRowSpan(row);
        if (span == null) { return 0; }
        var x = span[0];
        var pattern = row % MASONRY_WIDTHS.size();
        var count = 0;
        while (x < span[1]) {
            var w = px(MASONRY_WIDTHS[pattern]);
            if (x + w > span[1]) { w = span[1] - x; }
            if (w > px(MASONRY_MIN_W)) { count++; }
            x += w + px(MASONRY_GAP);
            pattern = (pattern + 1) % MASONRY_WIDTHS.size();
        }
        return count;
    }

    function loadResources() {
        try {
            _timeFont = WatchUi.loadResource(Rez.Fonts.StackTime);
            _heroTimeFont = WatchUi.loadResource(Rez.Fonts.StackTimeHero);
            _heroOutlineFont = WatchUi.loadResource(Rez.Fonts.StackTimeOutline);
            _metricFont = WatchUi.loadResource(Rez.Fonts.StackMetric);
        } catch (e) {
            _timeFont = null;
            _heroTimeFont = null;
            _heroOutlineFont = null;
            _metricFont = null;
        }

        if (Gfx has :getVectorFont) {
            if (_timeFont == null) {
                _timeFont = Gfx.getVectorFont({ :face => ["RobotoCondensedBold", "RobotoRegular"], :size => px(94) });
            }
            if (_heroTimeFont == null) {
                _heroTimeFont = Gfx.getVectorFont({ :face => ["RobotoCondensedBold", "RobotoRegular"], :size => px(104) });
            }
            if (_heroOutlineFont == null) { _heroOutlineFont = _heroTimeFont; }
            if (_metricFont == null) {
                _metricFont = Gfx.getVectorFont({ :face => ["RobotoCondensedBold", "RobotoRegular"], :size => px(32) });
            }
            _utilityFont = Gfx.getVectorFont({ :face => ["RobotoCondensedBold", "RobotoRegular"], :size => px(26) });
        }
        if (_timeFont == null) { _timeFont = Gfx.FONT_NUMBER_MILD; }
        if (_heroTimeFont == null) { _heroTimeFont = _timeFont; }
        if (_heroOutlineFont == null) { _heroOutlineFont = _heroTimeFont; }
        if (_metricFont == null) { _metricFont = Gfx.FONT_SMALL; }
        if (_utilityFont == null) { _utilityFont = Gfx.FONT_XTINY; }

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
                _ringSource = numberSetting("RingSource", _ringSource);
                _weeklyRunGoal = numberSetting("WeeklyRunGoal", _weeklyRunGoal);
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

    //! AMOLED products report panel state separately from watch-face sleep.
    //! onEnterSleep fires while the panel is powering down too, so keying the
    //! composition off _sleeping alone painted the always-on face for a moment
    //! before the system blanked the screen - the AOD flash. DISPLAY_MODE_OFF
    //! means draw nothing at all.
    function displayOff() {
        if (Sys has :getDisplayMode) {
            return Sys.getDisplayMode() == Sys.DISPLAY_MODE_OFF;
        }
        return false;
    }

    function lowPower() {
        if (Sys has :getDisplayMode) {
            return Sys.getDisplayMode() == Sys.DISPLAY_MODE_LOW_POWER;
        }
        return _sleeping;
    }

    function onUpdate(dc) {
        if (dc has :setAntiAlias) { dc.setAntiAlias(true); }
        dc.setColor(StackTheme.BG, StackTheme.BG);
        dc.clear();

        if (displayOff()) { return; }

        StackMetrics.beginFrame();
        var clock = Sys.getClockTime();
        var hour = clock.hour;
        var minute = clock.min;
        if (PIN_TIME >= 0) {
            hour = PIN_TIME / 100;
            minute = PIN_TIME % 100;
        }
        var hourText = twoDigits(displayHour(hour));
        var minuteText = twoDigits(minute);

        if (lowPower() || PIN_SLEEP) {
            drawAlwaysOn(dc, hourText, minuteText, minute);
        } else {
            drawActive(dc, hourText, minuteText);
        }
    }

    function drawActive(dc, hourText, minuteText) {
        drawStackBackground(dc);
        drawStepRing(dc);
        drawTopUtility(dc, 0, 0, false);
        drawActiveHeroTime(dc, hourText, minuteText);
        drawTrainerBoi(dc);
        drawMetrics(dc);
    }

    //! AOD carries the same time treatment as the active face - outlined hours,
    //! filled minutes, same fonts, same size, same Y - plus the grayscale
    //! runner, dropping only the masonry, ring and metrics. The composition
    //! measures about 5.7% luminance, inside the AMOLED always-on budget, and
    //! the per-minute shift keeps any one pixel from staying lit.
    function drawAlwaysOn(dc, hourText, minuteText, minute) {
        var phase = minute % 8;
        var dx = burnInX(phase);
        var dy = burnInY(phase);
        drawTopUtility(dc, dx, dy, true);
        drawHeroTime(dc, hourText, minuteText, dx, dy);
        drawTrainerBoiBitmap(dc, _trainerMono, dx, dy);
    }

    //! Active Hero Time uses filled and outline-only atlases generated from the
    //! same licensed Skomelr source. The outline interior stays transparent so
    //! the masonry field remains the actual background behind the hour. AOD
    //! shares this function so the two can never drift apart; dx/dy are the
    //! always-on burn-in shift and are zero on the active face.
    function drawActiveHeroTime(dc, hourText, minuteText) {
        drawHeroTime(dc, hourText, minuteText, 0, 0);
    }

    function drawHeroTime(dc, hourText, minuteText, dx, dy) {
        var hourWidth = dc.getTextWidthInPixels(hourText, _heroOutlineFont);
        var minuteWidth = dc.getTextWidthInPixels(minuteText, _heroTimeFont);
        var x = ((_width - hourWidth - minuteWidth) / 2).toNumber() + dx;
        var y = px(100) + dy;

        dc.setColor(StackTheme.TEXT, Gfx.COLOR_TRANSPARENT);
        dc.drawText(x, y, _heroOutlineFont, hourText, Gfx.TEXT_JUSTIFY_LEFT);
        dc.drawText(x + hourWidth, y, _heroTimeFont, minuteText, Gfx.TEXT_JUSTIFY_LEFT);
    }

    //! Low-contrast masonry built from deterministic STACK blocks. Keeping the
    //! pattern static avoids visual flicker and makes it inexpensive to redraw.
    function drawStackBackground(dc) {
        var tileH = px(MASONRY_TILE_H);
        var gap = px(MASONRY_GAP);
        var litCount = litBlockCount();

        for (var row = 0; row < MASONRY_ROWS; row++) {
            var span = masonryRowSpan(row);
            if (span == null) { continue; }

            var y = px(MASONRY_TOP + row * MASONRY_ROW_PITCH);
            var right = span[1];
            var x = span[0];
            var pattern = row % MASONRY_WIDTHS.size();
            var seat = _rowBase[row];

            while (x < right) {
                var w = px(MASONRY_WIDTHS[pattern]);
                if (x + w > right) { w = right - x; }
                if (w > px(MASONRY_MIN_W)) {
                    dc.setColor(blockShade(seat, litCount, row, pattern), StackTheme.BG);
                    dc.fillRectangle(x, y, w, tileH);
                    seat++;
                }
                x += w + gap;
                pattern = (pattern + 1) % MASONRY_WIDTHS.size();
            }
        }
    }

    //! How many blocks the day's steps have earned. stepFraction() already
    //! reads the watch's own step goal and clamps at 1.0, which is also what
    //! holds the wall at full once the goal is met.
    function litBlockCount() {
        if (_blockTotal <= 0) { return 0; }
        var fraction = (PIN_STEPS >= 0)
            ? (PIN_STEPS.toFloat() / 100.0)
            : StackMetrics.stepFraction();
        return (fraction * _blockTotal + 0.5).toNumber();
    }

    //! Earned blocks step up through four tones toward the newest one, so the
    //! wall reads as courses laid over the day rather than one flat slab.
    //! Blocks still to come keep the original three-shade texture untouched.
    function blockShade(index, litCount, row, pattern) {
        if (index >= litCount) {
            var shade = (row + pattern) % 3;
            if (shade == 0) { return StackTheme.BLOCK_LOW; }
            return (shade == 1) ? StackTheme.BLOCK_MID : StackTheme.BLOCK_HIGH;
        }
        if (index == litCount - 1) { return StackTheme.BLOCK_FILL_EDGE; }
        var tier = (index * 3) / litCount;
        if (tier <= 0) { return StackTheme.BLOCK_FILL_1; }
        return (tier == 1) ? StackTheme.BLOCK_FILL_2 : StackTheme.BLOCK_FILL_3;
    }

    //! One Y for both compositions. AOD used to sit 16px higher, so the date
    //! and battery visibly jumped the moment the face went always-on. The
    //! battery glyph still drops out in AOD - that is a lit-pixel choice, and
    //! it costs no movement.
    function drawTopUtility(dc, dx, dy, aod) {
        var color = aod ? StackTheme.AOD : StackTheme.TEXT;
        var y = px(86) + dy;
        dc.setColor(color, Gfx.COLOR_TRANSPARENT);
        dc.drawText(px(108) + dx, y, _utilityFont, dateLabel(), Gfx.TEXT_JUSTIFY_LEFT | Gfx.TEXT_JUSTIFY_VCENTER);
        dc.drawText(px(284) + dx, y, _utilityFont, StackMetrics.batteryPercent().toString() + "%",
            Gfx.TEXT_JUSTIFY_RIGHT | Gfx.TEXT_JUSTIFY_VCENTER);
        if (!aod) {
            StackMetrics.drawIcon(dc, StackMetrics.BATTERY, px(304) + dx, y, px(24), StackTheme.LIME);
        }
    }

    function drawStepRing(dc) {
        if (_ringSource == RING_OFF) { return; }
        var fraction = (PIN_STEPS >= 0)
            ? (PIN_STEPS.toFloat() / 100.0)
            : StackMetrics.ringFraction(_ringSource, _weeklyRunGoal);
        if (fraction < 0.0) { fraction = 0.0; }
        if (fraction > 1.0) { fraction = 1.0; }
        var filled = (fraction * RING_VISIBLE_SEGMENTS + 0.5).toNumber();
        var radius = px(188);
        var segmentSpan = 290.0 / RING_SEGMENTS;
        dc.setPenWidth(px(8));

        // Keep the original 16-slot geometry, but leave the two lowest slots
        // open so the metric shelf has an intentional, symmetrical aperture.
        for (var i = 1; i < RING_SEGMENTS - 1; i++) {
            var start = 215.0 + i * segmentSpan + 2.0;
            var end = 215.0 + (i + 1) * segmentSpan - 2.0;
            var color = StackTheme.EMPTY;
            if (i - 1 < filled) {
                color = ringSegmentColor(i);
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
        if (index <= 2) { return StackTheme.GREEN_1; }
        if (index <= 4) { return StackTheme.GREEN_2; }
        if (index <= 6) { return StackTheme.GREEN_3; }
        if (index <= 8) { return StackTheme.GREEN_4; }
        if (index <= 10) { return StackTheme.GREEN_5; }
        if (index <= 12) { return StackTheme.GREEN_6; }
        return StackTheme.LIME;
    }

    function drawTrainerBoi(dc) {
        drawTrainerBoiBitmap(dc, (_trainerMode == 1) ? _trainerMono : _trainerColor, 0, 0);
    }

    //! AOD always passes the grayscale artwork. "Off" still means off in both
    //! compositions, so the setting keeps working the way it reads.
    function drawTrainerBoiBitmap(dc, bitmap, dx, dy) {
        if (_trainerMode == 2) { return; }
        if (bitmap == null) { return; }
        var x = ((_width - bitmap.getWidth()) / 2).toNumber() + dx;
        dc.drawBitmap(x, px(194) + dy, bitmap);
    }

    function drawMetrics(dc) {
        drawMetric(dc, _metric1, 0, px(METRIC_LEFT_X));
        drawMetric(dc, _metric2, 1, px(METRIC_CENTER_X));
        drawMetric(dc, _metric3, 2, px(METRIC_RIGHT_X));
    }

    function drawMetric(dc, metric, slot, x) {
        if (metric == StackMetrics.NONE) { return; }
        var color = metricColor(slot, metric);
        StackMetrics.drawIcon(dc, metric, x, px(312), px(18), color);

        var value = StackMetrics.value(metric);
        dc.setColor(color, Gfx.COLOR_TRANSPARENT);
        dc.drawText(x, px(316), _metricFont, value, Gfx.TEXT_JUSTIFY_CENTER);
    }

    function metricColor(slot, metric) {
        if (_metricColorMode == 1) {
            return StackTheme.TEXT;
        }
        if (_metricColorMode == 2) {
            if (slot == 0) { return StackTheme.palette(_metric1Color); }
            if (slot == 1) { return StackTheme.palette(_metric2Color); }
            return StackTheme.palette(_metric3Color);
        }
        if (slot == 0) { return StackTheme.CYAN; }
        if (slot == 1) { return StackTheme.RED; }
        return StackTheme.PURPLE;
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
