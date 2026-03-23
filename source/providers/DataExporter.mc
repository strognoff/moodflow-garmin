import Toybox.Lang;

//! Exports mood data in various formats
module DataExporter {
    
    function exportJSON(entries as Array<MoodEntry>) as String {
        var json = "{\"app\":\"MoodFlow\",\"version\":\"1.0\",\"entries\":[";
        for (var i = 0; i < entries.size(); i++) {
            var entry = entries[i];
            json += "{\"mood\":" + entry.mood + ",\"note\":\"" + entry.note + "\"}";
            if (i < entries.size() - 1) {
                json += ",";
            }
        }
        json += "]}";
        return json;
    }
    
    function exportCSV(entries as Array<MoodEntry>) as String {
        var csv = "mood,label,note\n";
        for (var i = 0; i < entries.size(); i++) {
            var entry = entries[i];
            var label = MoodConstants.getMoodLabel(entry.mood);
            csv += entry.mood + "," + label + "," + entry.note + "\n";
        }
        return csv;
    }
}
