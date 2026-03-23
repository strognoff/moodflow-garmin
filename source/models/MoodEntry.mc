import Toybox.Lang;

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
