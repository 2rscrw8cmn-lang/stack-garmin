using Toybox.ActivityMonitor as ActivityMonitor;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
using Toybox.WatchUi as WatchUi;

class StackWatchFaceView extends WatchUi.WatchFace {
    function initialize() {
        WatchFace.initialize();
    }

    function onUpdate(dc) {
        var w = dc.getWidth();
        var cx = w / 2;
        var clock = Sys.getClockTime();
        var minute = clock.min < 10 ? "0" + clock.min.toString() : clock.min.toString();
        var time = clock.hour.toString() + ":" + minute;

        dc.setColor(StackTheme.BG, StackTheme.BG);
        dc.clear();

        dc.setColor(StackTheme.MUTED, StackTheme.BG);
        dc.drawText(cx, 42, Gfx.FONT_SMALL, "STACK", Gfx.TEXT_JUSTIFY_CENTER);

        dc.setColor(StackTheme.TEXT, StackTheme.BG);
        dc.drawText(cx, 92, Gfx.FONT_NUMBER_HOT, time, Gfx.TEXT_JUSTIFY_CENTER);

        drawStats(dc, cx);
        drawTower(dc, cx, 304);
    }

    function drawStats(dc, cx) {
        var battery = Sys.getSystemStats().battery;
        var activityInfo = ActivityMonitor.getInfo();
        var stepsText = "0";
        if (activityInfo != null && activityInfo.steps != null) {
            stepsText = activityInfo.steps.toString();
        }
        var batteryText = battery.toNumber().toString() + "%";

        dc.setColor(StackTheme.DARK, StackTheme.BG);
        dc.fillRectangle(cx - 1, 226, 2, 62);

        dc.setColor(StackTheme.ORANGE, StackTheme.BG);
        dc.drawText(110, 226, Gfx.FONT_XTINY, "STEPS", Gfx.TEXT_JUSTIFY_CENTER);
        dc.setColor(StackTheme.TEXT, StackTheme.BG);
        dc.drawText(110, 258, Gfx.FONT_SMALL, stepsText, Gfx.TEXT_JUSTIFY_CENTER);

        dc.setColor(StackTheme.LIME, StackTheme.BG);
        dc.drawText(306, 226, Gfx.FONT_XTINY, "BATTERY", Gfx.TEXT_JUSTIFY_CENTER);
        dc.setColor(StackTheme.TEXT, StackTheme.BG);
        dc.drawText(306, 258, Gfx.FONT_SMALL, batteryText, Gfx.TEXT_JUSTIFY_CENTER);
    }

    function drawTower(dc, cx, y) {
        var cols = [3, 2, 4, 1, 3, 2, 4, 2];
        var blockW = 26;
        var blockH = 12;
        var gap = 4;
        var totalW = (blockW * 8) + (gap * 7);
        var startX = cx - (totalW / 2);

        for (var c = 0; c < 8; c += 1) {
            for (var r = 0; r < 4; r += 1) {
                var x = startX + c * (blockW + gap);
                var by = y + (3 - r) * (blockH + 3);
                var color = r < cols[c] ? StackTheme.ORANGE : StackTheme.DARK;
                dc.setColor(color, StackTheme.BG);
                dc.fillRectangle(x, by, blockW, blockH);
            }
        }
    }
}
