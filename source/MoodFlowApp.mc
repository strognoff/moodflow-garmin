import Toybox.Lang;
import Toybox.Application;
import Toybox.WatchUi;

//! Main application entry point for MoodFlow
class MoodFlowApp extends Application.AppBase {

    //! Current mood entry
    var currentMood as Number = 2; // Default: Neutral (0-4 scale)
    
    //! Session storage
    var sessionStorage as MoodFlowStorage?;
    
    //! Today's mood entries
    var todayMoods as Array<Number> = [];
    
    function initialize() {
        AppBase.initialize();
        
        // Initialize storage
        sessionStorage = new MoodFlowStorage();
        
        // Load today's moods
        loadTodayMoods();
    }

    function getInitialView() {
        // Return the main view with its delegate
        var mainView = new MoodFlowView(self);
        return [ mainView, new MoodFlowDelegate(mainView) ] as [WatchUi.View, WatchUi.InputDelegate];
    }

    function onStart(state) {
        // App started
    }

    function onStop(state) {
        // App stopped - save state
        saveMoodEntry(currentMood);
    }
    
    //! Load today's mood entries from storage
    function loadTodayMoods() as Void {
        var storedMoods = sessionStorage.getValue("todayMoods");
        if (storedMoods != null) {
            todayMoods = storedMoods;
        }
    }
    
    //! Save a mood entry
    function saveMoodEntry(mood as Number) as Void {
        todayMoods.add(mood);
        sessionStorage.setValue("todayMoods", todayMoods);
    }
    
    //! Get mood label for current mood
    function getMoodLabel(mood as Number) as String {
        if (mood == 0) {
            return "Very Low";
        } else if (mood == 1) {
            return "Low";
        } else if (mood == 2) {
            return "Neutral";
        } else if (mood == 3) {
            return "Good";
        } else {
            return "Great";
        }
    }
    
    //! Get average mood for today
    function getAverageMood() as Number {
        if (todayMoods.size() == 0) {
            return 2;
        }
        
        var sum = 0;
        for (var i = 0; i < todayMoods.size(); i++) {
            sum += todayMoods[i];
        }
        return sum / todayMoods.size();
    }
}
