import Toybox.Lang;

//! Manages application settings
class SettingsManager {
    private var dataStore as MoodFlowDataStore;
    
    // Settings
    var reminderEnabled as Boolean = true;
    var reminderHour as Number = 20;
    var reminderMinute as Number = 0;
    
    function initialize(dataStore as MoodFlowDataStore) {
        self.dataStore = dataStore;
        load();
    }
    
    function load() as Void {
        var stored = dataStore.getValue("settings");
        if (stored != null) {
            var settings = stored as Dictionary;
            reminderEnabled = settings.get("reminderEnabled") == 1 ? true : false;
            reminderHour = settings.get("reminderHour") as Number;
            reminderMinute = settings.get("reminderMinute") as Number;
        }
    }
    
    function save() as Void {
        var settings = {
            "reminderEnabled" => reminderEnabled ? 1 : 0,
            "reminderHour" => reminderHour,
            "reminderMinute" => reminderMinute
        };
        dataStore.setValue("settings", settings);
    }
    
    function setReminderTime(hour as Number, minute as Number) as Void {
        reminderHour = hour;
        reminderMinute = minute;
        save();
    }
    
    function toggleReminder(enabled as Boolean) as Void {
        reminderEnabled = enabled;
        save();
    }
}
