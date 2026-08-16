using Toybox.Graphics as Gfx;
using Toybox.Lang as Lang;
using Toybox.UserProfile as UserProfile;
using Toybox.WatchUi as WatchUi;

class StackRunFieldView extends WatchUi.DataField {
    hidden var _hr;
    hidden var _speed;
    hidden var _distance;
    hidden var _elapsed;
    hidden var _zones;
    hidden var _zone;
    hidden var _targetZone;

    function initialize() {
        DataField.initialize();
        _hr = null;
        _speed = null;
        _distance = null;
        _elapsed = null;
        _zone = 0;
        _targetZone = 2;
        _zones = UserProfile.getHeartRateZones(UserProfile.HR_ZONE_SPORT_RUNNING);
    }

    function compute(info) {
        _hr = info.currentHeartRate;
        _speed = info.currentSpeed;
        _distance = info.elapsedDistance;
        _elapsed = info.elapsedTime;
        _zone = StackZones.zoneFor(_hr, _zones);
    }

    function onUpdate(dc) {
        var w = dc.getWidth();
        var h = dc.getHeight();
        dc.setColor(StackTheme.BG, StackTheme.BG);
        dc.clear();

        if (w >= 300 && h >= 300) {
            drawFull(dc, w, h);
        } else {
            drawCompact(dc, w, h);
        }
    }

    function drawFull(dc, w, h) {
        var cx = w / 2;
        dc.setColor(StackTheme.MUTED, StackTheme.BG);
        dc.drawText(cx, 26, Gfx.FONT_XTINY, "STACK  •  EASY", Gfx.TEXT_JUSTIFY_CENTER);

        dc.setColor(StackTheme.TEXT, StackTheme.BG);
        dc.drawText(cx, 70, Gfx.FONT_NUMBER_HOT, hrText(), Gfx.TEXT_JUSTIFY_CENTER);
        dc.setColor(StackTheme.MUTED, StackTheme.BG);
        dc.drawText(cx, 198, Gfx.FONT_XTINY, "HEART RATE", Gfx.TEXT_JUSTIFY_CENTER);

        drawZoneStack(dc, 48, 236, w - 96);

        dc.setColor(StackTheme.TEXT, StackTheme.BG);
        dc.drawText(105, 357, Gfx.FONT_XTINY, paceText(), Gfx.TEXT_JUSTIFY_CENTER);
        dc.drawText(311, 357, Gfx.FONT_XTINY, distanceText(), Gfx.TEXT_JUSTIFY_CENTER);
        dc.setColor(StackTheme.MUTED, StackTheme.BG);
        dc.drawText(105, 390, Gfx.FONT_XTINY, "PACE /MI", Gfx.TEXT_JUSTIFY_CENTER);
        dc.drawText(311, 390, Gfx.FONT_XTINY, elapsedText(), Gfx.TEXT_JUSTIFY_CENTER);
    }

    function drawCompact(dc, w, h) {
        var cx = w / 2;
        var cy = h / 2;
        dc.setColor(StackTheme.TEXT, StackTheme.BG);
        dc.drawText(cx, cy - 34, Gfx.FONT_LARGE, hrText(), Gfx.TEXT_JUSTIFY_CENTER);
        dc.setColor(StackTheme.ORANGE, StackTheme.BG);
        dc.drawText(cx, cy + 28, Gfx.FONT_XTINY, zoneText(), Gfx.TEXT_JUSTIFY_CENTER);
    }

    function drawZoneStack(dc, x, y, width) {
        var blockH = 17;
        var gap = 5;
        for (var z = 5; z >= 1; z -= 1) {
            var row = 5 - z;
            var by = y + row * (blockH + gap);
            var active = z == _zone;
            var target = z == _targetZone;
            var color = active ? StackTheme.ORANGE : StackTheme.DARK;

            dc.setColor(StackTheme.MUTED, StackTheme.BG);
            dc.drawText(x - 8, by - 7, Gfx.FONT_XTINY, "Z" + z.format("%d"), Gfx.TEXT_JUSTIFY_RIGHT);
            dc.setColor(color, StackTheme.BG);
            dc.fillRectangle(x, by, width, blockH);

            if (target && !active) {
                dc.setColor(StackTheme.BLUE, StackTheme.BG);
                dc.drawRectangle(x - 2, by - 2, width + 4, blockH + 4);
            }
        }
    }

    function hrText() {
        return _hr == null ? "--" : _hr.format("%d");
    }

    function zoneText() {
        return _zone == 0 ? "ZONE --" : "ZONE " + _zone.format("%d");
    }

    function paceText() {
        if (_speed == null || _speed <= 0.01) { return "--:--"; }
        var totalSeconds = (1609.344 / _speed).toNumber();
        var minutes = totalSeconds / 60;
        var seconds = totalSeconds % 60;
        return Lang.format("$1$:$2$", [minutes, seconds.format("%02d")]);
    }

    function distanceText() {
        if (_distance == null) { return "--.--"; }
        return (_distance / 1609.344).format("%.2f");
    }

    function elapsedText() {
        if (_elapsed == null) { return "--:--"; }
        var totalSeconds = (_elapsed / 1000).toNumber();
        var minutes = totalSeconds / 60;
        var seconds = totalSeconds % 60;
        return Lang.format("$1$:$2$", [minutes, seconds.format("%02d")]);
    }
}
