import Toybox.Lang;
import Toybox.Application;
import Toybox.WatchUi;
import Toybox.Attention;
import Toybox.ActivityMonitor;
import Toybox.Time;
import Toybox.Time.Gregorian;

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
        var mainView = new MoodFlowView(self);
        return [ mainView, new MoodFlowDelegate(mainView) ] as [WatchUi.View, WatchUi.BehaviorDelegate];
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
    
    function getTodayDayOfYear() as Number {
        var now = Toybox.Time.now();
        var info = Toybox.Time.Gregorian.info(now, Toybox.Time.FORMAT_SHORT);
        return info.day_of_week + (info.day * 1000) + (info.month * 100000);
    }
    
    function hasTodayMood() as Boolean {
        var today = getTodayDayOfYear();
        for (var i = moodEntries.size() - 1; i >= 0; i--) {
            if (moodEntries[i].timestamp == today) {
                return true;
            }
        }
        return false;
    }
    
    function replaceTodayMood(mood as Number) as Void {
        var today = getTodayDayOfYear();
        for (var i = moodEntries.size() - 1; i >= 0; i--) {
            if (moodEntries[i].timestamp == today) {
                moodEntries[i].mood = mood;
                saveMoodEntries();
                return;
            }
        }
        // If not found, add new entry
        addMoodEntry(mood, "");
    }
    
    function addMoodEntry(mood as Number, note as String) as Void {
        var today = getTodayDayOfYear();
        var entry = new MoodEntry(mood, today, note);
        moodEntries.add(entry);
        saveMoodEntries();
    }
    
    function getTodayEntries() as Array<MoodEntry> {
        var today = getTodayDayOfYear();
        var todayEntries = [];
        for (var i = 0; i < moodEntries.size(); i++) {
            if (moodEntries[i].timestamp == today) {
                todayEntries.add(moodEntries[i]);
            }
        }
        return todayEntries;
    }
    
    function resetAllData() as Void {
        moodEntries = [];
        saveMoodEntries();
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
    // Garmin Data (from watch)
    // ============================================
    function getSleepData() as Dictionary {
        var hours = 0.0f;
        var available = false;
        
        // Try to get sleep data from ActivityMonitor
        if (Toybox has :ActivityMonitor) {
            var info = Toybox.ActivityMonitor.getInfo();
            if (info != null && info has :sleepTime && info.sleepTime != null) {
                hours = info.sleepTime / 3600.0f; // Convert seconds to hours
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