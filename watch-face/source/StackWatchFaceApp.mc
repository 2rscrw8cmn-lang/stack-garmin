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

    //! Watch faces cannot take input themselves, so the system offers this view
    //! from the Watch Face menu. It is the only way to configure a sideloaded
    //! face, which Garmin Connect never sees.
    function getSettingsView() {
        return [ new StackSettingsMenu(), new StackSettingsMenuDelegate() ];
    }

    function onSettingsChanged() {
        if (_view != null) {
            _view.loadSettings();
        }
        WatchUi.requestUpdate();
    }
}
