using Toybox.Application;
using Toybox.WatchUi as WatchUi;

//! On-device settings for the STACK watch face.
//!
//! settings.xml only reaches the user through Garmin Connect / Garmin Express,
//! and neither ever sees a sideloaded face, so the defined settings were not
//! reachable on the watch at all. AppBase.getSettingsView() (API 3.2.0) is the
//! supported route for watch faces: the system offers it from the Watch Face
//! menu, since watch faces are not allowed to take input themselves.
module StackSettingsData {

    //! Choice tables are [property value, string resource]. A null resource
    //! means the value renders itself, which is how the numeric goal is listed.
    function choicesFor(key) {
        if (key.equals("Metric1") || key.equals("Metric2") || key.equals("Metric3")) {
            return [
                [StackMetrics.NONE, Rez.Strings.MetricNone],
                [StackMetrics.DISTANCE, Rez.Strings.MetricDistance],
                [StackMetrics.STEPS, Rez.Strings.MetricSteps],
                [StackMetrics.HEART_RATE, Rez.Strings.MetricHeartRate],
                [StackMetrics.BODY_BATTERY, Rez.Strings.MetricBodyBattery],
                [StackMetrics.BATTERY, Rez.Strings.MetricBattery],
                [StackMetrics.TEMPERATURE, Rez.Strings.MetricTemperature],
                [StackMetrics.NOTIFICATIONS, Rez.Strings.MetricNotifications],
                [StackMetrics.SUNRISE, Rez.Strings.MetricSunrise],
                [StackMetrics.SUNSET, Rez.Strings.MetricSunset],
                [StackMetrics.VO2_MAX, Rez.Strings.MetricVo2Max],
                [StackMetrics.RECOVERY, Rez.Strings.MetricRecovery],
                [StackMetrics.WEEKLY_RUN_DISTANCE, Rez.Strings.MetricWeeklyRun],
                [StackMetrics.STRESS, Rez.Strings.MetricStress]
            ];
        }
        if (key.equals("Metric1Color") || key.equals("Metric2Color") || key.equals("Metric3Color")) {
            return [
                [0, Rez.Strings.ColorCyan],
                [1, Rez.Strings.ColorBrightBlue],
                [2, Rez.Strings.ColorBlue],
                [3, Rez.Strings.ColorYellow],
                [4, Rez.Strings.ColorOrange],
                [5, Rez.Strings.ColorRed],
                [6, Rez.Strings.ColorLime],
                [7, Rez.Strings.ColorPurple],
                [8, Rez.Strings.ColorDeepPurple],
                [9, Rez.Strings.ColorWhite]
            ];
        }
        if (key.equals("MetricColorMode")) {
            return [
                [0, Rez.Strings.MetricAutomatic],
                [1, Rez.Strings.MetricMatchTime],
                [2, Rez.Strings.MetricIndividual]
            ];
        }
        if (key.equals("RingSource")) {
            return [
                [0, Rez.Strings.RingSourceSteps],
                [1, Rez.Strings.RingSourceIntensity],
                [2, Rez.Strings.RingSourceWeeklyRun],
                [3, Rez.Strings.RingSourceBodyBattery],
                [4, Rez.Strings.RingSourceOff]
            ];
        }
        if (key.equals("TrainerBoiMode")) {
            return [
                [0, Rez.Strings.TrainerFullColor],
                [1, Rez.Strings.TrainerMono],
                [2, Rez.Strings.TrainerOff]
            ];
        }
        if (key.equals("WeeklyRunGoal")) {
            return [
                [5, null], [10, null], [15, null], [20, null], [25, null],
                [30, null], [40, null], [50, null], [65, null], [80, null]
            ];
        }
        return [];
    }

    function titleFor(key) {
        if (key.equals("Metric1")) { return Rez.Strings.Metric1Title; }
        if (key.equals("Metric2")) { return Rez.Strings.Metric2Title; }
        if (key.equals("Metric3")) { return Rez.Strings.Metric3Title; }
        if (key.equals("Metric1Color")) { return Rez.Strings.Metric1ColorTitle; }
        if (key.equals("Metric2Color")) { return Rez.Strings.Metric2ColorTitle; }
        if (key.equals("Metric3Color")) { return Rez.Strings.Metric3ColorTitle; }
        if (key.equals("MetricColorMode")) { return Rez.Strings.MetricColorModeTitle; }
        if (key.equals("RingSource")) { return Rez.Strings.RingSourceTitle; }
        if (key.equals("TrainerBoiMode")) { return Rez.Strings.TrainerBoiModeTitle; }
        return Rez.Strings.WeeklyRunGoalTitle;
    }

    function currentValue(key, fallback) {
        try {
            var value = Application.Properties.getValue(key);
            if (value != null) { return value.toNumber(); }
        } catch (e) {
            // Fall through to the documented default.
        }
        return fallback;
    }

    //! Label for whatever the property is set to right now, used as the
    //! sub-label on the parent row so the menu reads as a summary.
    function labelForCurrent(key) {
        var choices = choicesFor(key);
        var value = currentValue(key, -1);
        for (var i = 0; i < choices.size(); i++) {
            if (choices[i][0] == value) {
                return labelFor(choices[i]);
            }
        }
        return value.toString();
    }

    function labelFor(choice) {
        if (choice[1] == null) { return choice[0].toString(); }
        return WatchUi.loadResource(choice[1]);
    }
}

//! Top level of the on-device settings menu.
class StackSettingsMenu extends WatchUi.Menu2 {
    function initialize() {
        Menu2.initialize({ :title => WatchUi.loadResource(Rez.Strings.AppName) });
        addKey("Metric1");
        addKey("Metric2");
        addKey("Metric3");
        addKey("MetricColorMode");
        addKey("Metric1Color");
        addKey("Metric2Color");
        addKey("Metric3Color");
        addKey("RingSource");
        addKey("WeeklyRunGoal");
        addKey("TrainerBoiMode");
    }

    function addKey(key) {
        addItem(new WatchUi.MenuItem(
            WatchUi.loadResource(StackSettingsData.titleFor(key)),
            StackSettingsData.labelForCurrent(key),
            key,
            null));
    }
}

class StackSettingsMenuDelegate extends WatchUi.Menu2InputDelegate {
    function initialize() {
        Menu2InputDelegate.initialize();
    }

    function onSelect(item) {
        var key = item.getId();
        WatchUi.pushView(
            new StackChoiceMenu(key),
            new StackChoiceMenuDelegate(key, item),
            WatchUi.SLIDE_LEFT);
    }
}

//! One property's choices, with the active one marked.
class StackChoiceMenu extends WatchUi.Menu2 {
    function initialize(key) {
        Menu2.initialize({ :title => WatchUi.loadResource(StackSettingsData.titleFor(key)) });
        var choices = StackSettingsData.choicesFor(key);
        var current = StackSettingsData.currentValue(key, -1);
        for (var i = 0; i < choices.size(); i++) {
            var value = choices[i][0];
            addItem(new WatchUi.MenuItem(
                StackSettingsData.labelFor(choices[i]),
                (value == current) ? "•" : null,
                value,
                null));
        }
    }
}

class StackChoiceMenuDelegate extends WatchUi.Menu2InputDelegate {
    var _key;
    var _parentItem;

    function initialize(key, parentItem) {
        Menu2InputDelegate.initialize();
        _key = key;
        _parentItem = parentItem;
    }

    function onSelect(item) {
        try {
            Application.Properties.setValue(_key, item.getId());
        } catch (e) {
            // A read-only store leaves the previous value in place.
        }
        if (_parentItem != null) {
            _parentItem.setSubLabel(StackSettingsData.labelForCurrent(_key));
        }
        // setValue does not raise onSettingsChanged, so pull the new value into
        // the live view ourselves.
        var app = Application.getApp();
        if (app != null) {
            app.onSettingsChanged();
        }
        WatchUi.popView(WatchUi.SLIDE_RIGHT);
    }
}
