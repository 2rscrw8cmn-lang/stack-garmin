using Toybox.Application as Application;
using Toybox.WatchUi as WatchUi;

class StackWatchFaceApp extends Application.AppBase {
    var _view;

    function initialize() {
        AppBase.initialize();
    }

    function getInitialView() {
        _view = new StackWatchFaceView();
        return [ _view ];
    }

    function onSettingsChanged() {
        if (_view != null) {
            _view.loadSettings();
        }
        WatchUi.requestUpdate();
    }
}
