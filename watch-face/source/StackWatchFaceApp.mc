using Toybox.Application as Application;

class StackWatchFaceApp extends Application.AppBase {
    function initialize() {
        AppBase.initialize();
    }

    function getInitialView() {
        return [ new StackWatchFaceView() ];
    }
}
