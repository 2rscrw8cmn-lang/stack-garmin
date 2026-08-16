module StackZones {
    function zoneFor(hr, thresholds) {
        if (hr == null || thresholds == null || thresholds.size() < 6) { return 0; }
        if (hr <= thresholds[1]) { return 1; }
        if (hr <= thresholds[2]) { return 2; }
        if (hr <= thresholds[3]) { return 3; }
        if (hr <= thresholds[4]) { return 4; }
        return 5;
    }
}
