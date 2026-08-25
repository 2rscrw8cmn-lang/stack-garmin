using Toybox.Activity;
using Toybox.SensorHistory;
using Toybox.ActivityMonitor;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
using Toybox.Time;
using Toybox.Time.Gregorian as Gregorian;
using Toybox.Weather;

//! Secondary data for the STACK watch face.
//!
//! A metric is three things: a compact value string, a graphic mark, and an
//! accent colour. The face renders metrics into fixed slots, so adding or
//! swapping one never touches the layout.
//!
//! Values are deliberately built by concatenation rather than format(): tiny
//! dynamic strings through format() have crashed this face before. Every
//! reader returns a fallback instead of throwing when Garmin has no data.
module StackMetrics {
    enum {
        NONE = 0,
        BATTERY,
        TEMPERATURE,
        STEPS,
        HEART_RATE,
        BODY_BATTERY,
        NOTIFICATIONS,
        SUNRISE,
        SUNSET
    }

    //! Accent colour for a metric's graphic mark.
    function accent(metric) {
        if (metric == BATTERY) { return StackTheme.LIME; }
        if (metric == TEMPERATURE) { return StackTheme.YELLOW; }
        if (metric == STEPS) { return StackTheme.BLUE; }
        if (metric == HEART_RATE) { return StackTheme.PINK; }
        if (metric == BODY_BATTERY) { return StackTheme.CYAN; }
        if (metric == NOTIFICATIONS) { return StackTheme.PURPLE; }
        return StackTheme.YELLOW;
    }

    // ==================================================================
    // values
    // ==================================================================

    function value(metric) {
        if (metric == BATTERY) { return batteryValue(); }
        if (metric == TEMPERATURE) { return temperatureValue(); }
        if (metric == STEPS) { return stepsValue(); }
        if (metric == HEART_RATE) { return heartRateValue(); }
        if (metric == BODY_BATTERY) { return bodyBatteryValue(); }
        if (metric == NOTIFICATIONS) { return notificationValue(); }
        if (metric == SUNRISE) { return sunValue(true); }
        if (metric == SUNSET) { return sunValue(false); }
        return "";
    }

    function batteryPercent() {
        var stats = Sys.getSystemStats();
        if (stats == null || stats.battery == null) { return 0; }
        return stats.battery.toNumber();
    }

    function batteryValue() {
        return batteryPercent().toString() + "%";
    }

    function temperatureValue() {
        var current = Weather.getCurrentConditions();
        if (current == null || current.temperature == null) { return "--°"; }

        var temp = current.temperature;
        var settings = Sys.getDeviceSettings();
        if (settings != null && settings.temperatureUnits == Sys.UNIT_STATUTE) {
            temp = (temp * 9.0 / 5.0) + 32.0;
        }
        return temp.toNumber().toString() + "°";
    }

    function stepsValue() {
        var steps = 0;
        var info = ActivityMonitor.getInfo();
        if (info != null && info.steps != null) {
            steps = info.steps;
        }
        if (steps >= 1000) {
            var thousands = (steps / 1000).toNumber();
            var hundreds = ((steps % 1000) / 100).toNumber();
            return thousands.toString() + "." + hundreds.toString() + "K";
        }
        return steps.toString();
    }

    function heartRateValue() {
        var activity = Activity.getActivityInfo();
        if (activity != null && activity.currentHeartRate != null) {
            return activity.currentHeartRate.toString();
        }

        // Fall back to the most recent stored sample when there is no live one.
        if (ActivityMonitor has :getHeartRateHistory) {
            var hist = ActivityMonitor.getHeartRateHistory(1, true);
            if (hist != null) {
                var sample = hist.next();
                if (sample != null && sample.heartRate != null
                        && sample.heartRate != ActivityMonitor.INVALID_HR_SAMPLE) {
                    return sample.heartRate.toString();
                }
            }
        }
        return "--";
    }

    function bodyBatteryValue() {
        // Not every device in the family exposes Body Battery history.
        if (SensorHistory has :getBodyBatteryHistory) {
            var hist = SensorHistory.getBodyBatteryHistory({ :period => 1 });
            if (hist != null) {
                var sample = hist.next();
                if (sample != null && sample.data != null) {
                    return sample.data.toNumber().toString();
                }
            }
        }
        return "--";
    }

    function notificationValue() {
        var settings = Sys.getDeviceSettings();
        if (settings == null || settings.notificationCount == null) { return "0"; }
        return settings.notificationCount.toString();
    }

    function sunValue(rise) {
        var current = Weather.getCurrentConditions();
        if (current == null || current.observationLocationPosition == null) {
            return "--:--";
        }

        var moment;
        if (rise) {
            moment = Weather.getSunrise(current.observationLocationPosition, Time.now());
        } else {
            moment = Weather.getSunset(current.observationLocationPosition, Time.now());
        }
        if (moment == null) { return "--:--"; }

        var info = Gregorian.info(moment, Time.FORMAT_SHORT);
        if (info == null || info.hour == null || info.min == null) { return "--:--"; }

        var hour = info.hour;
        var settings = Sys.getDeviceSettings();
        if (settings != null && !settings.is24Hour) {
            hour = hour % 12;
            if (hour == 0) { hour = 12; }
        }

        var mins = info.min.toString();
        if (info.min < 10) { mins = "0" + mins; }
        return hour.toString() + ":" + mins;
    }

    // ==================================================================
    // marks
    //
    // Every mark draws inside a box `h` tall, left edge at x, centred on cy,
    // and returns the advance to the value text.
    // ==================================================================

    function drawIcon(dc, metric, x, cy, h, color) {
        dc.setColor(color, StackTheme.BG);

        if (metric == BATTERY) { return batteryIcon(dc, x, cy, h); }
        if (metric == TEMPERATURE) { return discIcon(dc, x, cy, h); }
        if (metric == STEPS) { return runnerIcon(dc, x, cy, h); }
        if (metric == HEART_RATE) { return heartIcon(dc, x, cy, h); }
        if (metric == BODY_BATTERY) { return boltIcon(dc, x, cy, h); }
        if (metric == NOTIFICATIONS) { return messageIcon(dc, x, cy, h); }
        if (metric == SUNRISE || metric == SUNSET) { return horizonIcon(dc, x, cy, h); }
        return 0;
    }

    function px(v) {
        return (v + 0.5).toNumber();
    }

    function uQuad(dc, x, y, s, ax, ay, bx, by, cx, cy, dx, dy) {
        dc.fillPolygon([
            [px(x + ax * s), px(y + ay * s)],
            [px(x + bx * s), px(y + by * s)],
            [px(x + cx * s), px(y + cy * s)],
            [px(x + dx * s), px(y + dy * s)]
        ]);
    }

    function batteryIcon(dc, x, cy, h) {
        var w = h * 1.85;
        var top = px(cy - h / 2.0);
        var ih = px(h * 0.44);

        dc.setPenWidth(3);
        dc.drawRoundedRectangle(px(x), top, px(w), px(h), px(h * 0.28));
        dc.setPenWidth(1);
        dc.fillRectangle(px(x + w + 1), px(cy - h * 0.22), 3, ih);

        var fill = ((w - 8) * batteryPercent() / 100).toNumber();
        if (fill > 0) {
            dc.fillRectangle(px(x + 4), px(cy - h * 0.22), fill, ih);
        }
        return w + 5;
    }

    function discIcon(dc, x, cy, h) {
        dc.fillCircle(px(x + h / 2.0), px(cy), px(h / 2.0));
        return h;
    }

    //! Deliberately blunt: head, one arm-and-torso stroke, two legs. Detail
    //! disappears at this size, so the silhouette carries the whole idea.
    function runnerIcon(dc, x, cy, h) {
        var y = cy - h * 0.50;
        dc.fillCircle(px(x + 0.600 * h), px(y + 0.130 * h), px(0.145 * h));
        uQuad(dc, x, y, h, 0.884, 0.225, 0.354, 0.455, 0.446, 0.665, 0.976, 0.435);
        uQuad(dc, x, y, h, 0.370, 0.618, 0.790, 0.998, 0.930, 0.842, 0.510, 0.462);
        uQuad(dc, x, y, h, 0.344, 0.488, -0.026, 0.878, 0.126, 1.022, 0.496, 0.632);
        return h * 1.00;
    }

    function heartIcon(dc, x, cy, h) {
        var r = px(h * 0.27);
        dc.fillCircle(px(x + h * 0.29), px(cy - h * 0.13), r);
        dc.fillCircle(px(x + h * 0.71), px(cy - h * 0.13), r);
        dc.fillPolygon([
            [px(x + h * 0.02), px(cy - h * 0.10)],
            [px(x + h * 0.98), px(cy - h * 0.10)],
            [px(x + h * 0.50), px(cy + h * 0.48)]
        ]);
        return h;
    }

    function boltIcon(dc, x, cy, h) {
        uQuad(dc, x, cy - h * 0.5, h, 0.62, 0.00, 0.20, 0.58, 0.56, 0.58, 0.76, 0.20);
        uQuad(dc, x, cy - h * 0.5, h, 0.50, 0.44, 0.82, 0.44, 0.34, 1.00, 0.44, 0.60);
        return h * 0.86;
    }

    function messageIcon(dc, x, cy, h) {
        dc.fillRoundedRectangle(px(x), px(cy - h * 0.40), px(h), px(h * 0.62),
            px(h * 0.18));
        dc.fillPolygon([
            [px(x + h * 0.22), px(cy + h * 0.14)],
            [px(x + h * 0.52), px(cy + h * 0.14)],
            [px(x + h * 0.24), px(cy + h * 0.50)]
        ]);
        return h;
    }

    function horizonIcon(dc, x, cy, h) {
        dc.fillCircle(px(x + h * 0.50), px(cy - h * 0.08), px(h * 0.30));
        dc.fillRectangle(px(x), px(cy + h * 0.26), px(h), px(h * 0.14));
        return h;
    }
}
