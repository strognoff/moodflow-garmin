import Toybox.WatchUi;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Attention;

//! Main view for MoodFlow
class MoodFlowView extends WatchUi.View {
    
    var moodFlowApp as MoodFlowApp;
    
    // Screen states
    const SCREEN_CHECKIN = 0;
    const SCREEN_TREND = 1;
    const SCREEN_SETTINGS = 2;
    
    var currentScreen as Number = 0;
    var selectedMoodIndex as Number = 2;
    var showingConfirmDialog as Boolean = false;
    var confirmDialogType as String = "";
    
    // Display properties
    var isRoundDisplay as Boolean = false;
    var bezelClearance as Number = 10;
    
    function initialize(app as MoodFlowApp) {
        View.initialize();
        moodFlowApp = app;
    }
    
    function onShow() as Void {
        detectDisplayShape();
    }
    
    function detectDisplayShape() as Void {
        if (Toybox.System has :getDeviceSettings) {
            var settings = Toybox.System.getDeviceSettings();
            if (settings != null && settings has :screenShape) {
                isRoundDisplay = (settings.screenShape == 1);
            } else if (settings != null && settings has :screenWidth && settings has :screenHeight) {
                var w = settings.screenWidth;
                var h = settings.screenHeight;
                if (h > w * 1.05) {
                    isRoundDisplay = true;
                }
            }
        }
        
        if (isRoundDisplay) {
            bezelClearance = 18;
        } else {
            bezelClearance = 10;
        }
    }
    
    function onUpdate(dc as Dc) as Void {
        if (currentScreen == SCREEN_CHECKIN) {
            CheckInScreen.draw(dc, moodFlowApp, selectedMoodIndex, bezelClearance, showingConfirmDialog);
        } else if (currentScreen == SCREEN_TREND) {
            TrendScreen.draw(dc, moodFlowApp, bezelClearance, isRoundDisplay);
        } else if (currentScreen == SCREEN_SETTINGS) {
            SettingsScreen.draw(dc, bezelClearance, showingConfirmDialog);
        }
    }
    
    function navigateLeft() as Void {
        if (currentScreen == SCREEN_CHECKIN) {
            currentScreen = SCREEN_TREND;
        } else if (currentScreen == SCREEN_TREND) {
            currentScreen = SCREEN_CHECKIN;
        } else if (currentScreen == SCREEN_SETTINGS) {
            currentScreen = SCREEN_CHECKIN;
        }
        WatchUi.requestUpdate();
    }
    
    function navigateRight() as Void {
        if (currentScreen == SCREEN_TREND) {
            currentScreen = SCREEN_CHECKIN;
        } else if (currentScreen == SCREEN_CHECKIN) {
            currentScreen = SCREEN_SETTINGS;
        }
        WatchUi.requestUpdate();
    }
    
    function openSettings() as Void {
        currentScreen = SCREEN_SETTINGS;
        WatchUi.requestUpdate();
    }
    
    function exitSettings() as Void {
        currentScreen = SCREEN_CHECKIN;
        WatchUi.requestUpdate();
    }
    
    function handleConfirmDialog(confirmed as Boolean) as Void {
        if (confirmDialogType.equals("reset")) {
            if (confirmed) {
                moodFlowApp.resetAllData();
                if (Attention has :vibrate) {
                    Attention.vibrate([new Attention.VibeProfile(100, 200)]);
                }
            }
            showingConfirmDialog = false;
            confirmDialogType = "";
        } else if (confirmDialogType.equals("mood")) {
            if (confirmed) {
                var mood = selectedMoodIndex + 1;
                moodFlowApp.replaceTodayMood(mood);
                if (Attention has :vibrate) {
                    Attention.vibrate([new Attention.VibeProfile(50, 100)]);
                }
            }
            showingConfirmDialog = false;
            confirmDialogType = "";
        }
    }
}
