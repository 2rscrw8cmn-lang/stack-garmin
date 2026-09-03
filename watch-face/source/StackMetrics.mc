using Toybox.Activity;
using Toybox.ActivityMonitor;
using Toybox.Complications;
using Toybox.Graphics as Gfx;
using Toybox.SensorHistory;
using Toybox.System as Sys;
using Toybox.Time;
using Toybox.Time.Gregorian as Gregorian;
using Toybox.UserProfile;
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
        SUNSET,
        VO2_MAX,
        RECOVERY,
        WEEKLY_RUN_DISTANCE,
        STRESS
    }

    var _activityInfo = null;
    var _weatherInfo = null;
    var _weatherLoaded = false;
    var _bodyBattery = null;
    var _bodyBatteryLoaded = false;
    var _weeklyRunMeters = null;
    var _weeklyRunLoaded = false;

    //! Cache the ActivityMonitor read once for a rendered frame.
    function beginFrame() {
        _activityInfo = ActivityMonitor.getInfo();
        _weatherInfo = null;
        _weatherLoaded = false;
        _bodyBattery = null;
        _bodyBatteryLoaded = false;
        _weeklyRunMeters = null;
        _weeklyRunLoaded = false;
    }

    function accent(metric) {
        if (metric == DISTANCE) { return StackTheme.CYAN; }
        if (metric == STEPS) { return StackTheme.BRIGHT_BLUE; }
        if (metric == HEART_RATE) { return StackTheme.RED; }
        if (metric == BODY_BATTERY) { return StackTheme.PURPLE; }
        if (metric == BATTERY) { return StackTheme.LIME; }
        if (metric == TEMPERATURE) { return StackTheme.ORANGE; }
        if (metric == NOTIFICATIONS) { return StackTheme.BLUE; }
        if (metric == VO2_MAX) { return StackTheme.LIME; }
        if (metric == RECOVERY) { return StackTheme.YELLOW; }
        if (metric == WEEKLY_RUN_DISTANCE) { return StackTheme.CYAN; }
        if (metric == STRESS) { return StackTheme.ORANGE; }
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
        if (metric == VO2_MAX) { return vo2MaxValue(); }
        if (metric == RECOVERY) { return recoveryValue(); }
        if (metric == WEEKLY_RUN_DISTANCE) { return weeklyRunDistanceValue(); }
        if (metric == STRESS) { return stressValue(); }
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
        if (metric == VO2_MAX) { return "VO2"; }
        if (metric == RECOVERY) { return "REC"; }
        if (metric == WEEKLY_RUN_DISTANCE) { return "WK"; }
        if (metric == STRESS) { return "STR"; }
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

    //! Ring source ids mirror StackWatchFaceView's configurable source list:
    //! steps, weekly intensity minutes, weekly run distance, and Body Battery.
    function ringFraction(source, weeklyRunGoal) {
        if (source == 0) { return stepFraction(); }
        if (source == 1) { return intensityMinutesFraction(); }
        if (source == 2) { return weeklyRunFraction(weeklyRunGoal); }
        if (source == 3) {
            var bodyBattery = bodyBatteryNumber();
            return (bodyBattery == null) ? 0.0 : bodyBattery.toFloat() / 100.0;
        }
        return 0.0;
    }

    function intensityMinutesFraction() {
        var info = _activityInfo;
        if (info == null || info.activeMinutesWeek == null
                || info.activeMinutesWeekGoal == null || info.activeMinutesWeekGoal <= 0) {
            return 0.0;
        }
        return info.activeMinutesWeek.total.toFloat() / info.activeMinutesWeekGoal.toFloat();
    }

    function weeklyRunFraction(goal) {
        if (goal == null || goal <= 0) { return 0.0; }
        var meters = weeklyRunMeters();
        if (meters == null) { return 0.0; }
        return distanceFromMeters(meters).toFloat() / goal.toFloat();
    }

    function distanceValue() {
        var info = _activityInfo;
        var centimeters = 0.0;
        if (info != null && info.distance != null) { centimeters = info.distance.toFloat(); }
        var settings = Sys.getDeviceSettings();
        if (settings != null && settings.distanceUnits == Sys.UNIT_STATUTE) {
            return oneDecimal(centimeters / 160934.4);
        }
        return oneDecimal(centimeters / 100000.0);
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
        var value = bodyBatteryNumber();
        return (value == null) ? "--" : value.toString();
    }

    function bodyBatteryNumber() {
        if (_bodyBatteryLoaded) { return _bodyBattery; }
        _bodyBatteryLoaded = true;
        if (SensorHistory has :getBodyBatteryHistory) {
            var history = SensorHistory.getBodyBatteryHistory({ :period => 1 });
            if (history != null) {
                var sample = history.next();
                if (sample != null && sample.data != null) {
                    _bodyBattery = sample.data.toNumber();
                    return _bodyBattery;
                }
            }
        }
        return null;
    }

    function temperatureValue() {
        var current = weatherInfo();
        if (current == null || current.temperature == null) { return "--"; }
        var temperature = current.temperature;
        var settings = Sys.getDeviceSettings();
        if (settings != null && settings.temperatureUnits == Sys.UNIT_STATUTE) {
            temperature = (temperature * 9.0 / 5.0) + 32.0;
        }
        return temperature.toNumber().toString();
    }

    function vo2MaxValue() {
        var profile = UserProfile.getProfile();
        if (profile == null || !(profile has :vo2maxRunning) || profile.vo2maxRunning == null) {
            return "--";
        }
        return profile.vo2maxRunning.toString();
    }

    function recoveryValue() {
        if (_activityInfo == null || !(_activityInfo has :timeToRecovery)
                || _activityInfo.timeToRecovery == null) {
            return "--";
        }
        return _activityInfo.timeToRecovery.toString();
    }

    function stressValue() {
        if (_activityInfo == null || !(_activityInfo has :stressScore)
                || _activityInfo.stressScore == null) {
            return "--";
        }
        return _activityInfo.stressScore.toString();
    }

    function weeklyRunDistanceValue() {
        var meters = weeklyRunMeters();
        if (meters == null) { return "--"; }
        return oneDecimal(distanceFromMeters(meters));
    }

    function weeklyRunMeters() {
        if (_weeklyRunLoaded) { return _weeklyRunMeters; }
        _weeklyRunLoaded = true;
        if (!(Complications has :getComplication)) { return null; }
        try {
            var id = new Complications.Id(Complications.COMPLICATION_TYPE_WEEKLY_RUN_DISTANCE);
            var complication = Complications.getComplication(id);
            if (complication != null && complication.value != null) {
                _weeklyRunMeters = complication.value.toFloat();
            }
        } catch (e) {
            _weeklyRunMeters = null;
        }
        return _weeklyRunMeters;
    }

    function distanceFromMeters(meters) {
        var settings = Sys.getDeviceSettings();
        if (settings != null && settings.distanceUnits == Sys.UNIT_STATUTE) {
            return meters.toFloat() / 1609.344;
        }
        return meters.toFloat() / 1000.0;
    }

    function notificationValue() {
        var settings = Sys.getDeviceSettings();
        if (settings == null || settings.notificationCount == null) { return "0"; }
        return settings.notificationCount.toString();
    }

    function sunValue(isRise) {
        var current = weatherInfo();
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
        else if (metric == BATTERY) { drawBatteryIcon(dc, x, cy, h, color); }
        else if (metric == TEMPERATURE) { drawWeatherIcon(dc, x, cy, h); }
        else if (metric == NOTIFICATIONS) { drawMessageIcon(dc, x, cy, h); }
        else if (metric == SUNRISE || metric == SUNSET) { drawHorizonIcon(dc, x, cy, h); }
        else if (metric == VO2_MAX) { drawLungsIcon(dc, x, cy, h); }
        else if (metric == RECOVERY) { drawRecoveryIcon(dc, x, cy, h); }
        else if (metric == WEEKLY_RUN_DISTANCE) { drawRunIcon(dc, x, cy, h); }
        else if (metric == STRESS) { drawStressIcon(dc, x, cy, h); }
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

    function drawBatteryIcon(dc, x, cy, h, color) {
        var percent = batteryPercent();
        var batteryColor = color;
        if (percent <= 10) { batteryColor = StackTheme.RED; }
        else if (percent <= 20) { batteryColor = StackTheme.YELLOW; }
        var w = h * 4 / 3;
        var bodyH = h * 2 / 3;
        var left = x - w / 2;
        var top = cy - bodyH / 2;

        dc.setColor(batteryColor, StackTheme.BG);
        dc.setPenWidth(2);
        dc.drawRoundedRectangle(left, top, w, bodyH, 3);
        dc.fillRectangle(x + w / 2 + 1, cy - bodyH / 5, 3, bodyH * 2 / 5);
        dc.setPenWidth(1);

        var innerLeft = left + 4;
        var innerTop = top + 4;
        var innerH = bodyH - 8;
        var segmentW = (w - 11) / 4;
        var filled = (percent == 0) ? 0 : ((percent + 24) / 25).toNumber();
        for (var i = 0; i < 4; i++) {
            dc.setColor((i < filled) ? batteryColor : StackTheme.EMPTY, StackTheme.BG);
            dc.fillRectangle(innerLeft + i * (segmentW + 1), innerTop, segmentW, innerH);
        }
        dc.setColor(color, StackTheme.BG);
    }

    function drawWeatherIcon(dc, x, cy, h) {
        var current = weatherInfo();
        var condition = (current == null) ? null : current.condition;
        var rainy = condition == Weather.CONDITION_RAIN
            || condition == Weather.CONDITION_SCATTERED_SHOWERS
            || condition == Weather.CONDITION_THUNDERSTORMS;
        var cloudy = rainy || condition == Weather.CONDITION_PARTLY_CLOUDY
            || condition == Weather.CONDITION_MOSTLY_CLOUDY;

        if (!cloudy) {
            dc.fillCircle(x, cy, h / 4);
            dc.setPenWidth(2);
            dc.drawLine(x, cy - h / 2, x, cy - h / 3);
            dc.drawLine(x, cy + h / 3, x, cy + h / 2);
            dc.drawLine(x - h / 2, cy, x - h / 3, cy);
            dc.drawLine(x + h / 3, cy, x + h / 2, cy);
            dc.setPenWidth(1);
            return;
        }

        dc.fillCircle(x - h / 5, cy, h / 4);
        dc.fillCircle(x + h / 6, cy - h / 8, h / 3);
        dc.fillRectangle(x - h / 2, cy, h, h / 4);
        if (rainy) {
            dc.setPenWidth(2);
            dc.drawLine(x - h / 4, cy + h / 3, x - h / 4, cy + h / 2);
            dc.drawLine(x + h / 4, cy + h / 3, x + h / 4, cy + h / 2);
            dc.setPenWidth(1);
        }
    }

    function drawLungsIcon(dc, x, cy, h) {
        var r = h / 4;
        dc.fillCircle(x - r, cy, r);
        dc.fillCircle(x + r, cy, r);
        dc.fillRectangle(x - 1, cy - h / 2, 3, h / 2);
    }

    function drawRecoveryIcon(dc, x, cy, h) {
        var r = h / 2;
        dc.setPenWidth(2);
        dc.drawCircle(x, cy, r);
        dc.drawLine(x, cy, x, cy - h / 4);
        dc.drawLine(x, cy, x + h / 4, cy);
        dc.setPenWidth(1);
    }

    function drawRunIcon(dc, x, cy, h) {
        dc.fillCircle(x + h / 5, cy - h / 3, h / 6);
        dc.setPenWidth(3);
        dc.drawLine(x, cy - h / 6, x + h / 5, cy);
        dc.drawLine(x, cy - h / 6, x - h / 3, cy);
        dc.drawLine(x + h / 5, cy, x + h / 2, cy + h / 3);
        dc.drawLine(x + h / 5, cy, x - h / 5, cy + h / 2);
        dc.setPenWidth(1);
    }

    function drawStressIcon(dc, x, cy, h) {
        dc.setPenWidth(2);
        dc.drawLine(x - h / 2, cy - h / 4, x - h / 4, cy + h / 4);
        dc.drawLine(x - h / 4, cy + h / 4, x, cy - h / 4);
        dc.drawLine(x, cy - h / 4, x + h / 4, cy + h / 4);
        dc.drawLine(x + h / 4, cy + h / 4, x + h / 2, cy - h / 4);
        dc.setPenWidth(1);
    }

    function weatherInfo() {
        if (!_weatherLoaded) {
            _weatherInfo = Weather.getCurrentConditions();
            _weatherLoaded = true;
        }
        return _weatherInfo;
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
