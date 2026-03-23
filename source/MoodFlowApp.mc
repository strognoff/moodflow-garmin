import Toybox.Lang;
import Toybox.Application;
import Toybox.WatchUi;

//! Main application entry point for MoodFlow
class MoodFlowApp extends Application.AppBase {
    
    // Current state
    var currentMood as Number = 3;
    var currentView as Number = 0;
    
    // Core components
    var sessionStorage as MoodFlowDataStore?;
    var settingsManager as SettingsManager?;
    var moodEntryManager as MoodEntryManager?;
    var reminderManager as ReminderManager?;
    
    function initialize() {
        AppBase.initialize();
        
        sessionStorage = new MoodFlowDataStore();
        settingsManager = new SettingsManager(sessionStorage);
        moodEntryManager = new MoodEntryManager(sessionStorage);
        reminderManager = new ReminderManager(settingsManager);
    }

    function getInitialView() {
        var mainView = new MoodFlowView(self);
        return [ mainView, new MoodFlowDelegate(mainView) ] as [WatchUi.View, WatchUi.BehaviorDelegate];
    }

    function onStart(state) {
    }

    function onStop(state) {
        moodEntryManager.save();
        settingsManager.save();
    }
    
    // Delegate methods to managers
    function hasTodayMood() as Boolean {
        return moodEntryManager.hasTodayMood();
    }
    
    function replaceTodayMood(mood as Number) as Void {
        moodEntryManager.replaceTodayMood(mood);
    }
    
    function addMoodEntry(mood as Number, note as String) as Void {
        moodEntryManager.addMoodEntry(mood, note);
    }
    
    function getTodayEntries() as Array<MoodEntry> {
        return moodEntryManager.getTodayEntries();
    }
    
    function resetAllData() as Void {
        moodEntryManager.resetAllData();
    }
    
    function getLast7DaysEntries() as Array<MoodEntry> {
        return moodEntryManager.getLast7DaysEntries();
    }
    
    function getAverageMood(entries as Array<MoodEntry>) as Number {
        return moodEntryManager.getAverageMood(entries);
    }
    
    function setReminderTime(hour as Number, minute as Number) as Void {
        settingsManager.setReminderTime(hour, minute);
    }
    
    function toggleReminder(enabled as Boolean) as Void {
        settingsManager.toggleReminder(enabled);
    }
    
    function fireReminder() as Void {
        reminderManager.fireReminder();
    }
    
    function getMoodLabel(mood as Number) as String {
        return MoodConstants.getMoodLabel(mood);
    }
    
    function getMoodColor(mood as Number) as Number {
        return MoodConstants.getMoodColor(mood);
    }
    
    function getSleepData() as Dictionary {
        return GarminDataProvider.getSleepData();
    }
    
    function getActivityData() as Dictionary {
        return GarminDataProvider.getActivityData();
    }
    
    function exportDataJSON() as String {
        return DataExporter.exportJSON(moodEntryManager.moodEntries);
    }
    
    function exportDataCSV() as String {
        return DataExporter.exportCSV(moodEntryManager.moodEntries);
    }
}
