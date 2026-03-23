import Toybox.WatchUi;
import Toybox.Lang;
import Toybox.Attention;

//! Input delegate for MoodFlow
class MoodFlowDelegate extends WatchUi.BehaviorDelegate {
    
    var view as MoodFlowView;
    
    function initialize(v as MoodFlowView) {
        BehaviorDelegate.initialize();
        view = v;
    }
    
    function onBack() as Boolean {
        if (view.currentScreen == view.SCREEN_SETTINGS) {
            view.exitSettings();
            return true;
        }
        return false;
    }
    
    function onKeyPressed(key as WatchUi.KeyEvent) as Boolean {
        var keyCode = key.getKey();
        var app = view.moodFlowApp;
        
        if (view.showingConfirmDialog) {
            return handleConfirmDialog(keyCode);
        }
        
        if (view.currentScreen == view.SCREEN_CHECKIN) {
            return handleCheckInInput(keyCode, app);
        } else if (view.currentScreen == view.SCREEN_SETTINGS) {
            return handleSettingsInput(keyCode);
        }
        
        return false;
    }
    
    function handleConfirmDialog(keyCode as Number) as Boolean {
        if (keyCode == WatchUi.KEY_UP) {
            view.handleConfirmDialog(false);
            WatchUi.requestUpdate();
            return true;
        } else if (keyCode == WatchUi.KEY_DOWN) {
            view.handleConfirmDialog(true);
            WatchUi.requestUpdate();
            return true;
        }
        return true;
    }
    
    function handleCheckInInput(keyCode as Number, app as MoodFlowApp) as Boolean {
        if (keyCode == WatchUi.KEY_UP) {
            if (view.selectedMoodIndex < 4) {
                view.selectedMoodIndex = view.selectedMoodIndex + 1;
                app.currentMood = view.selectedMoodIndex + 1;
                WatchUi.requestUpdate();
            }
            return true;
        } else if (keyCode == WatchUi.KEY_DOWN) {
            if (view.selectedMoodIndex > 0) {
                view.selectedMoodIndex = view.selectedMoodIndex - 1;
                app.currentMood = view.selectedMoodIndex + 1;
                WatchUi.requestUpdate();
            }
            return true;
        } else if (keyCode == WatchUi.KEY_ENTER) {
            var mood = view.selectedMoodIndex + 1;
            if (app.hasTodayMood()) {
                view.showingConfirmDialog = true;
                view.confirmDialogType = "mood";
            } else {
                app.addMoodEntry(mood, "");
                if (Attention has :vibrate) {
                    Attention.vibrate([new Attention.VibeProfile(50, 100)]);
                }
            }
            WatchUi.requestUpdate();
            return true;
        }
        return false;
    }
    
    function handleSettingsInput(keyCode as Number) as Boolean {
        if (keyCode == WatchUi.KEY_ENTER) {
            view.showingConfirmDialog = true;
            view.confirmDialogType = "reset";
            WatchUi.requestUpdate();
            return true;
        }
        return false;
    }
    
    function onSwipe(e as WatchUi.SwipeEvent) as Boolean {
        var dir = e.getDirection();
        
        if (dir == WatchUi.SWIPE_LEFT) {
            view.navigateLeft();
            return true;
        } else if (dir == WatchUi.SWIPE_RIGHT) {
            view.navigateRight();
            return true;
        }
        
        return false;
    }
}
