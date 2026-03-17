import Toybox.WatchUi;
import Toybox.Lang;

//! Input delegate for MoodFlow
class MoodFlowDelegate extends WatchUi.InputDelegate {
    
    var moodFlowView as MoodFlowView;
    
    function initialize(view as MoodFlowView) {
        WatchUi.InputDelegate.initialize();
        moodFlowView = view;
    }
    
    //! Handle key presses
    function onKeyPressed(key as WatchUi.KeyEvent) as Boolean {
        var app = moodFlowView.moodFlowApp;
        var keyCode = key.getKey();
        
        if (keyCode == WatchUi.KEY_UP) {
            // Increase mood
            if (app.currentMood < 4) {
                app.currentMood++;
                moodFlowView.moodLabel = app.getMoodLabel(app.currentMood);
                WatchUi.requestUpdate();
            }
            return true;
        } else if (keyCode == WatchUi.KEY_DOWN) {
            // Decrease mood
            if (app.currentMood > 0) {
                app.currentMood--;
                moodFlowView.moodLabel = app.getMoodLabel(app.currentMood);
                WatchUi.requestUpdate();
            }
            return true;
        } else if (keyCode == WatchUi.KEY_ENTER) {
            // Save current mood entry
            app.saveMoodEntry(app.currentMood);
            
            // Show confirmation
            WatchUi.requestUpdate();
            return true;
        }
        
        return false;
    }
}
