import Toybox.Lang;
import Toybox.Time;
import Toybox.Time.Gregorian;

//! Manages mood entries storage and retrieval
class MoodEntryManager {
    private var dataStore as MoodFlowDataStore;
    var moodEntries as Array<MoodEntry> = [];
    
    function initialize(dataStore as MoodFlowDataStore) {
        self.dataStore = dataStore;
        load();
    }
    
    function load() as Void {
        var stored = dataStore.getValue("moodEntries");
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
    
    function save() as Void {
        var entriesArray = [];
        for (var i = 0; i < moodEntries.size(); i++) {
            var entry = moodEntries[i];
            entriesArray.add({
                "mood" => entry.mood,
                "timestamp" => entry.timestamp,
                "note" => entry.note
            });
        }
        dataStore.setValue("moodEntries", entriesArray);
    }
    
    function getTodayDayOfYear() as Number {
        var now = Toybox.Time.now();
        var info = Toybox.Time.Gregorian.info(now, Toybox.Time.FORMAT_SHORT);
        // Use year*10000 + month*100 + day to create unique date ID
        // Example: March 23, 2026 = 20260323
        return (info.year * 10000) + (info.month * 100) + info.day;
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
                save();
                return;
            }
        }
        addMoodEntry(mood, "");
    }
    
    function addMoodEntry(mood as Number, note as String) as Void {
        var today = getTodayDayOfYear();
        var entry = new MoodEntry(mood, today, note);
        moodEntries.add(entry);
        save();
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
        save();
    }
    
    function getLast7DaysEntries() as Array {
        var now = Toybox.Time.now();
        var result = [];
        
        // Build array for last 7 days (index 0 = 6 days ago, index 6 = today)
        for (var i = 6; i >= 0; i--) {
            var dayMoment = now.subtract(new Toybox.Time.Duration(i * 86400));
            var dayInfo = Toybox.Time.Gregorian.info(dayMoment, Toybox.Time.FORMAT_SHORT);
            var dayId = (dayInfo.year * 10000) + (dayInfo.month * 100) + dayInfo.day;
            
            // Find entry for this day
            var foundEntry = null;
            for (var j = 0; j < moodEntries.size(); j++) {
                if (moodEntries[j].timestamp == dayId) {
                    foundEntry = moodEntries[j];
                    break;
                }
            }
            
            // Add entry or null
            result.add(foundEntry);
        }
        
        return result;
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
}
