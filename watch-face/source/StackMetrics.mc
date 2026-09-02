using Toybox.Activity;
using Toybox.ActivityMonitor;
using Toybox.Graphics as Gfx;
using Toybox.SensorHistory;
using Toybox.System as Sys;
using Toybox.Time;
using Toybox.Time.Gregorian as Gregorian;
using Toybox.Weather;

//! Curated data model for the three Hero Time metric slots and step ring.
module StackMetrics {
    enum {
        NONE = 0,
        DISTANCE,
        STEPS,
        HEART_RATE,
        BODY_BATTERY,
        BATTERY,
        TEMPERATURE,
        NOTIFICATIONS,
        SUNRISE,
        SUNSET
    }

    var _activityInfo = null;

    //! Cache the ActivityMonitor read once for a rendered frame.
    function beginFrame() {
        _activityInfo = ActivityMonitor.getInfo();
    }

    function accent(metric) {
        if (metric == DISTANCE) { return StackTheme.CYAN; }
        if (metric == STEPS) { return StackTheme.BRIGHT_BLUE; }
        if (metric == HEART_RATE) { return StackTheme.RED; }
        if (metric == BODY_BATTERY) { return StackTheme.PURPLE; }
        if (metric == BATTERY) { return StackTheme.LIME; }
        if (metric == TEMPERATURE) { return StackTheme.ORANGE; }
        if (metric == NOTIFICATIONS) { return StackTheme.BLUE; }
        return StackTheme.YELLOW;
    }

    function value(metric) {
        if (metric == DISTANCE) { return distanceValue(); }
        if (metric == STEPS) { return stepsValue(); }
        if (metric == HEART_RATE) { return heartRateValue(); }
        if (metric == BODY_BATTERY) { return bodyBatteryValue(); }
        if (metric == BATTERY) { return batteryPercent().toString() + "%"; }
        if (metric == TEMPERATURE) { return temperatureValue(); }
        if (metric == NOTIFICATIONS) { return notificationValue(); }
        if (metric == SUNRISE) { return sunValue(true); }
        if (metric == SUNSET) { return sunValue(false); }
        return "";
    }

    function label(metric) {
        if (metric == DISTANCE) {
            var settings = Sys.getDeviceSettings();
            if (settings != null && settings.distanceUnits == Sys.UNIT_STATUTE) { return "MI"; }
            return "KM";
        }
        if (metric == STEPS) { return "STP"; }
        if (metric == HEART_RATE) { return "HR"; }
        if (metric == BODY_BATTERY) { return "BB"; }
        if (metric == BATTERY) { return "BAT"; }
        if (metric == TEMPERATURE) {
            var tempSettings = Sys.getDeviceSettings();
            if (tempSettings != null && tempSettings.temperatureUnits == Sys.UNIT_STATUTE) { return "F"; }
            return "C";
        }
        if (metric == NOTIFICATIONS) { return "NTF"; }
        if (metric == SUNRISE) { return "RISE"; }
        if (metric == SUNSET) { return "SET"; }
        return "";
    }

    //! Sunrise/sunset and abbreviated step values contain glyphs outside the
    //! intentionally tiny StackMetric atlas and use the utility font instead.
    function usesStackFont(metric) {
        return metric != STEPS && metric != SUNRISE && metric != SUNSET;
    }

    function batteryPercent() {
        var stats = Sys.getSystemStats();
        if (stats == null || stats.battery == null) { return 0; }
        return stats.battery.toNumber();
    }

    function stepFraction() {
        var info = _activityInfo;
        if (info == null || info.steps == null) { return 0.0; }
        var goal = 10000;
        if (info.stepGoal != null && info.stepGoal > 0) { goal = info.stepGoal; }
        var result = info.steps.toFloat() / goal.toFloat();
        if (result < 0.0) { return 0.0; }
        if (result > 1.0) { return 1.0; }
        return result;
    }

    function distanceValue() {
        var info = _activityInfo;
        var meters = 0.0;
        if (info != null && info.distance != null) { meters = info.distance.toFloat(); }
        var settings = Sys.getDeviceSettings();
        if (settings != null && settings.distanceUnits == Sys.UNIT_STATUTE) {
            return oneDecimal(meters / 1609.344);
        }
        return oneDecimal(meters / 1000.0);
    }

    function oneDecimal(value) {
        var tenths = (value * 10.0 + 0.5).toNumber();
        return (tenths / 10).toNumber().toString() + "." + (tenths % 10).toString();
    }

    function stepsValue() {
        var steps = 0;
        if (_activityInfo != null && _activityInfo.steps != null) { steps = _activityInfo.steps; }
        if (steps >= 1000) {
            return (steps / 1000).toNumber().toString() + "." + ((steps % 1000) / 100).toNumber().toString() + "K";
        }
        return steps.toString();
    }

    function heartRateValue() {
        var activity = Activity.getActivityInfo();
        if (activity != null && activity.currentHeartRate != null) {
            return activity.currentHeartRate.toString();
        }
        if (ActivityMonitor has :getHeartRateHistory) {
            var history = ActivityMonitor.getHeartRateHistory(1, true);
            if (history != null) {
                var sample = history.next();
                if (sample != null && sample.heartRate != null
                        && sample.heartRate != ActivityMonitor.INVALID_HR_SAMPLE) {
                    return sample.heartRate.toString();
                }
            }
        }
        return "--";
    }

    function bodyBatteryValue() {
        if (SensorHistory has :getBodyBatteryHistory) {
            var history = SensorHistory.getBodyBatteryHistory({ :period => 1 });
            if (history != null) {
                var sample = history.next();
                if (sample != null && sample.data != null) { return sample.data.toNumber().toString(); }
            }
        }
        return "--";
    }

    function temperatureValue() {
        var current = Weather.getCurrentConditions();
        if (current == null || current.temperature == null) { return "--"; }
        var temperature = current.temperature;
        var settings = Sys.getDeviceSettings();
        if (settings != null && settings.temperatureUnits == Sys.UNIT_STATUTE) {
            temperature = (temperature * 9.0 / 5.0) + 32.0;
        }
        return temperature.toNumber().toString();
    }

    function notificationValue() {
        var settings = Sys.getDeviceSettings();
        if (settings == null || settings.notificationCount == null) { return "0"; }
        return settings.notificationCount.toString();
    }

    function sunValue(isRise) {
        var current = Weather.getCurrentConditions();
        if (current == null || current.observationLocationPosition == null) { return "--:--"; }
        var moment = isRise
            ? Weather.getSunrise(current.observationLocationPosition, Time.now())
            : Weather.getSunset(current.observationLocationPosition, Time.now());
        if (moment == null) { return "--:--"; }
        var info = Gregorian.info(moment, Time.FORMAT_SHORT);
        if (info == null || info.hour == null || info.min == null) { return "--:--"; }
        var hour = info.hour;
        var settings = Sys.getDeviceSettings();
        if (settings != null && !settings.is24Hour) {
            hour = hour % 12;
            if (hour == 0) { hour = 12; }
        }
        var minute = info.min.toString();
        if (info.min < 10) { minute = "0" + minute; }
        return hour.toString() + ":" + minute;
    }

    function drawIcon(dc, metric, x, cy, h, color) {
        dc.setColor(color, StackTheme.BG);
        if (metric == DISTANCE) { drawDistanceIcon(dc, x, cy, h, color); }
        else if (metric == STEPS) { drawStepsIcon(dc, x, cy, h); }
        else if (metric == HEART_RATE) { drawHeartIcon(dc, x, cy, h); }
        else if (metric == BODY_BATTERY) { drawBoltIcon(dc, x, cy, h); }
        else if (metric == BATTERY) { drawBatteryIcon(dc, x, cy, h); }
        else if (metric == TEMPERATURE) { dc.fillCircle(x, cy, h / 2); }
        else if (metric == NOTIFICATIONS) { drawMessageIcon(dc, x, cy, h); }
        else if (metric == SUNRISE || metric == SUNSET) { drawHorizonIcon(dc, x, cy, h); }
    }

    function drawDistanceIcon(dc, x, cy, h, color) {
        var r = h / 3;
        var topY = cy - h / 4;
        dc.fillCircle(x, topY, r);
        dc.fillPolygon([[x - r, topY + r / 2], [x + r, topY + r / 2], [x, cy + h / 2]]);
        dc.setColor(StackTheme.BG, StackTheme.BG);
        dc.fillCircle(x, topY, h / 9);
        dc.setColor(color, StackTheme.BG);
    }

    function drawStepsIcon(dc, x, cy, h) {
        var s = h / 3;
        dc.fillRectangle(x - s, cy, s, s);
        dc.fillRectangle(x, cy - s, s, s);
        dc.fillRectangle(x, cy, s, s);
    }

    function drawHeartIcon(dc, x, cy, h) {
        var r = h / 4;
        dc.fillCircle(x - r, cy - r / 2, r);
        dc.fillCircle(x + r, cy - r / 2, r);
        dc.fillPolygon([[x - h / 2, cy - r / 3], [x + h / 2, cy - r / 3], [x, cy + h / 2]]);
    }

    function drawBoltIcon(dc, x, cy, h) {
        dc.fillPolygon([[x, cy - h / 2], [x - h / 3, cy + h / 8], [x, cy + h / 8]]);
        dc.fillPolygon([[x, cy - h / 8], [x + h / 3, cy - h / 8], [x - h / 8, cy + h / 2]]);
    }

    function drawBatteryIcon(dc, x, cy, h) {
        var w = h;
        dc.setPenWidth(2);
        dc.drawRoundedRectangle(x - w / 2, cy - h / 3, w, h * 2 / 3, 3);
        dc.fillRectangle(x + w / 2 + 1, cy - h / 8, 2, h / 4);
        var fill = ((w - 6) * batteryPercent() / 100).toNumber();
        if (fill > 0) { dc.fillRectangle(x - w / 2 + 3, cy - h / 5, fill, h * 2 / 5); }
        dc.setPenWidth(1);
    }

    function drawMessageIcon(dc, x, cy, h) {
        dc.fillRoundedRectangle(x - h / 2, cy - h / 3, h, h * 2 / 3, 3);
        dc.fillPolygon([[x - h / 4, cy + h / 4], [x, cy + h / 4], [x - h / 4, cy + h / 2]]);
    }

    function drawHorizonIcon(dc, x, cy, h) {
        dc.fillCircle(x, cy, h / 3);
        dc.fillRectangle(x - h / 2, cy + h / 5, h, 3);
    }
}
