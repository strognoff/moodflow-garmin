import Toybox.Lang;
import Toybox.Application;
import Toybox.WatchUi;
import Toybox.Attention;

//! Main application entry point for MoodFlow
class MoodFlowApp extends Application.AppBase {
    
    // Mood constants (1-5 scale as per spec)
    const MOOD_VERY_BAD = 1;
    const MOOD_BAD = 2;
    const MOOD_NEUTRAL = 3;
    const MOOD_GOOD = 4;
    const MOOD_VERY_GOOD = 5;
    
    // Current state
    var currentMood as Number = 3;
    var currentView as Number = 0; // 0=CheckIn, 1=Trend, 2=Note, 3=Settings
    var sessionStorage as MoodFlowDataStore?;
    
    // Settings
    var reminderEnabled as Boolean = true;
    var reminderHour as Number = 20;
    var reminderMinute as Number = 0;
    
    // Data
    var moodEntries as Array<MoodEntry> = [];
    var lastReminderDate as String = "";
    
    function initialize() {
        AppBase.initialize();
        
        sessionStorage = new MoodFlowDataStore();
        loadSettings();
        loadMoodEntries();
    }

    function getInitialView() {
        // Create factory that defers view creation until runtime
        // This avoids alphabetical compilation order issues
        return [ new MoodFlowViewFactory(self) ] as [WatchUi.View];
    }

    function onStart(state) {
    }

    function onStop(state) {
        saveMoodEntries();
        saveSettings();
    }
    
    // ============================================
    // Settings Management
    // ============================================
    function loadSettings() as Void {
        var stored = sessionStorage.getValue("settings");
        if (stored != null) {
            var settings = stored as Dictionary;
            reminderEnabled = settings.get("reminderEnabled") == 1 ? true : false;
            reminderHour = settings.get("reminderHour") as Number;
            reminderMinute = settings.get("reminderMinute") as Number;
        }
    }
    
    function saveSettings() as Void {
        var settings = {
            "reminderEnabled" => reminderEnabled ? 1 : 0,
            "reminderHour" => reminderHour,
            "reminderMinute" => reminderMinute
        };
        sessionStorage.setValue("settings", settings);
    }
    
    // ============================================
    // Mood Entry Management
    // ============================================
    function loadMoodEntries() as Void {
        var stored = sessionStorage.getValue("moodEntries");
        if (stored != null) {
            moodEntries = [];
            var entries = stored as Array;
            for (var i = 0; i < entries.size(); i++) {
                var entryDict = entries[i] as Dictionary;
                var entry = new MoodEntry(
                    entryDict.get("mood") as Number,
                    entryDict.get("timestamp") as Number,
                    entryDict.get("note") as String
                );
                moodEntries.add(entry);
            }
        }
    }
    
    function saveMoodEntries() as Void {
        var entriesArray = [];
        for (var i = 0; i < moodEntries.size(); i++) {
            var entry = moodEntries[i];
            entriesArray.add({
                "mood" => entry.mood,
                "timestamp" => entry.timestamp,
                "note" => entry.note
            });
        }
        sessionStorage.setValue("moodEntries", entriesArray);
    }
    
    function addMoodEntry(mood as Number, note as String) as Void {
        var entry = new MoodEntry(mood, moodEntries.size(), note);
        moodEntries.add(entry);
        saveMoodEntries();
    }
    
    function getTodayEntries() as Array<MoodEntry> {
        var todayIndex = moodEntries.size();
        var todayEntries = [];
        if (todayIndex > 0) {
            for (var i = todayIndex - 1; i >= 0; i--) {
                todayEntries.add(moodEntries[i]);
                if (i == 0) { break; }
            }
        }
        return todayEntries;
    }
    
    function getLast7DaysEntries() as Array<MoodEntry> {
        var count = moodEntries.size() > 7 ? 7 : moodEntries.size();
        var entries = [];
        for (var i = 0; i < count; i++) {
            entries.add(moodEntries[moodEntries.size() - 1 - i]);
        }
        return entries;
    }
    
    function getAverageMood(entries as Array<MoodEntry>) as Number {
        if (entries.size() == 0) {
            return 3;
        }
        var sum = 0;
        for (var i = 0; i < entries.size(); i++) {
            sum += entries[i].mood;
        }
        return sum / entries.size();
    }
    
    // ============================================
    // Reminder Management
    // ============================================
    function fireReminder() as Void {
        if (Attention has :vibrate) {
            var vibeData = [new Attention.VibeProfile(100, 500)];
            Attention.vibrate(vibeData);
        }
    }
    
    function setReminderTime(hour as Number, minute as Number) as Void {
        reminderHour = hour;
        reminderMinute = minute;
        saveSettings();
    }
    
    function toggleReminder(enabled as Boolean) as Void {
        reminderEnabled = enabled;
        saveSettings();
    }
    
    // ============================================
    // Mood Labels & Colors
    // ============================================
    function getMoodLabel(mood as Number) as String {
        if (mood == 1) { return "Very Bad"; }
        if (mood == 2) { return "Bad"; }
        if (mood == 3) { return "Neutral"; }
        if (mood == 4) { return "Good"; }
        return "Very Good";
    }
    
    // Color-blind friendly mood colors
    function getMoodColor(mood as Number) as Number {
        if (mood == 1) { return 0x9C27B0; } // Purple - Very Bad
        if (mood == 2) { return 0x2196F3; } // Blue - Bad
        if (mood == 3) { return 0x4CAF50; } // Green - Neutral
        if (mood == 4) { return 0xFFEB3B; } // Yellow - Good
        return 0xFF9800; // Orange - Very Good
    }
    
    // ============================================
    // Garmin Data (simulated)
    // ============================================
    function getSleepData() as Dictionary {
        return {
            "quality" => 75,
            "hours" => 7.5f,
            "available" => true
        };
    }
    
    function getActivityData() as Dictionary {
        return {
            "steps" => 8500,
            "heartRate" => 68,
            "available" => true
        };
    }
    
    // ============================================
    // Data Export
    // ============================================
    function exportDataJSON() as String {
        var json = "{\"app\":\"MoodFlow\",\"version\":\"1.0\",\"entries\":[";
        for (var i = 0; i < moodEntries.size(); i++) {
            var entry = moodEntries[i];
            json += "{\"mood\":" + entry.mood + ",\"note\":\"" + entry.note + "\"}";
            if (i < moodEntries.size() - 1) {
                json += ",";
            }
        }
        json += "]}";
        return json;
    }
    
    function exportDataCSV() as String {
        var csv = "mood,label,note\n";
        for (var i = 0; i < moodEntries.size(); i++) {
            var entry = moodEntries[i];
            csv += entry.mood + "," + getMoodLabel(entry.mood) + "," + entry.note + "\n";
        }
        return csv;
    }
}

//! Mood Entry class
class MoodEntry {
    var mood as Number;
    var timestamp as Number;
    var note as String;
    
    function initialize(mood as Number, timestamp as Number, note as String) {
        self.mood = mood;
        self.timestamp = timestamp;
        self.note = note;
    }
}