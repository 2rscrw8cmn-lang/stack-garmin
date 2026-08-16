using Toybox.Application as Application;

class StackRunFieldApp extends Application.AppBase {
    function initialize() {
        AppBase.initialize();
    }

    function getInitialView() {
        return [ new StackRunFieldView() ];
    }
}
