import Toybox.Lang;
import Toybox.Attention;

//! Manages reminder notifications
class ReminderManager {
    private var settingsManager as SettingsManager;
    var lastReminderDate as String = "";
    
    function initialize(settingsManager as SettingsManager) {
        self.settingsManager = settingsManager;
    }
    
    function fireReminder() as Void {
        if (Attention has :vibrate) {
            var vibeData = [new Attention.VibeProfile(100, 500)];
            Attention.vibrate(vibeData);
        }
    }
    
    function shouldFireReminder() as Boolean {
        return settingsManager.reminderEnabled;
    }
}
