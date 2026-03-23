import Toybox.Lang;
import Toybox.ActivityMonitor;

//! Provides Garmin watch data (sleep, activity, etc.)
module GarminDataProvider {
    
    function getSleepData() as Dictionary {
        var hours = 0.0f;
        var available = false;
        
        if (Toybox has :ActivityMonitor) {
            var info = Toybox.ActivityMonitor.getInfo();
            if (info != null && info has :sleepTime && info.sleepTime != null) {
                hours = info.sleepTime / 3600.0f;
                available = true;
            }
        }
        
        return {
            "quality" => 0,
            "hours" => hours,
            "available" => available
        };
    }
    
    function getActivityData() as Dictionary {
        var steps = 0;
        var heartRate = 0;
        var available = false;
        
        if (Toybox has :ActivityMonitor) {
            var info = Toybox.ActivityMonitor.getInfo();
            if (info != null) {
                if (info has :steps && info.steps != null) {
                    steps = info.steps;
                    available = true;
                }
                if (info has :heartRate && info.heartRate != null) {
                    heartRate = info.heartRate;
                }
            }
        }
        
        return {
            "steps" => steps,
            "heartRate" => heartRate,
            "available" => available
        };
    }
}
