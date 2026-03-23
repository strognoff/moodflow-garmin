import Toybox.Lang;

//! Constants and utility functions for mood handling
module MoodConstants {
    // Mood constants (1-5 scale as per spec)
    const MOOD_VERY_BAD = 1;
    const MOOD_BAD = 2;
    const MOOD_NEUTRAL = 3;
    const MOOD_GOOD = 4;
    const MOOD_VERY_GOOD = 5;
    
    // Color-blind friendly mood colors
    function getMoodColor(mood as Number) as Number {
        if (mood == 1) { return 0x9C27B0; } // Purple - Very Bad
        if (mood == 2) { return 0x2196F3; } // Blue - Bad
        if (mood == 3) { return 0x4CAF50; } // Green - Neutral
        if (mood == 4) { return 0xFFEB3B; } // Yellow - Good
        return 0xFF9800; // Orange - Very Good
    }
    
    function getMoodLabel(mood as Number) as String {
        if (mood == 1) { return "Very Bad"; }
        if (mood == 2) { return "Bad"; }
        if (mood == 3) { return "Neutral"; }
        if (mood == 4) { return "Good"; }
        return "Very Good";
    }
}
