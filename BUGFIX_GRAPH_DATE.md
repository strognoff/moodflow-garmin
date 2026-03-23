# Bug Fix: Graph Showing Wrong Day of Week

## Issue Description
When a mood was entered on Monday, the graph was displaying it on Sunday instead. This was caused by incorrect date/timestamp logic.

## Root Cause

### Original Problem
The `getTodayDayOfYear()` function was using `day_of_week` (1-7) in its calculation:
```monkey-c
return info.day_of_week + (info.day * 1000) + (info.month * 100000);
```

This caused several issues:
1. **Day of week cycles**: `day_of_week` is 1-7 (Sun-Sat), so the same weekday in different weeks would get similar timestamps
2. **Collision risk**: The formula could create overlapping IDs for different dates
3. **Graph mapping**: The trend screen just took the last N entries without verifying which actual calendar day they belonged to

### Example of the Bug
- Monday March 23, 2026: `day_of_week=2` → timestamp mixed with day and month
- The following Monday March 30, 2026: Also `day_of_week=2` → similar timestamp pattern
- Graph displayed entries by insertion order, not by actual calendar date

## Solution

### 1. Fixed Date ID Generation
Changed to use **year, month, and day** for unique date identification:
```monkey-c
return (info.year * 10000) + (info.month * 100) + info.day;
```

**Examples:**
- March 23, 2026 → `20260323`
- March 24, 2026 → `20260324`
- April 1, 2026 → `20260401`

This ensures:
- ✅ Every calendar day gets a unique ID
- ✅ IDs are sortable chronologically
- ✅ No collisions between dates

### 2. Fixed 7-Day Data Retrieval
Updated `getLast7DaysEntries()` to:
- Calculate the actual calendar dates for the last 7 days
- Look up mood entries by their proper date ID
- Return an array where each index corresponds to a specific day (6 days ago → today)
- Return `null` for days without entries

### 3. Fixed Graph Display
Updated `TrendScreen.drawChart()` to:
- Calculate the actual day-of-week label for each of the last 7 days
- Display "S", "M", "T", "W", "T", "F", "S" based on actual calendar dates
- Show neutral mood (3) for days without entries
- Properly align moods with their correct day labels

## Files Modified

1. **`source/managers/MoodEntryManager.mc`** (134 lines)
   - Fixed `getTodayDayOfYear()` - now uses year*10000 + month*100 + day
   - Fixed `getLast7DaysEntries()` - now calculates actual last 7 calendar days

2. **`source/screens/TrendScreen.mc`** (121 lines)
   - Updated `drawChart()` - calculates correct day-of-week labels for each date
   - Handles null entries (days without moods)

## Testing Recommendations

1. **Enter mood today** - Verify it appears under the correct day label on the graph
2. **Check historical data** - If you had old entries with the buggy timestamp format, they may not display correctly (a data migration would be needed for old data)
3. **Multi-day test** - Enter moods on different days of the week and verify graph accuracy
4. **Week boundary** - Test around Sunday/Monday transition to ensure week boundaries work correctly

## Note on Existing Data

⚠️ **Important**: Existing mood entries saved with the old timestamp format will not be compatible with the new format. The app will start fresh tracking from the first entry saved after this fix. This is acceptable since this appears to be in development/testing phase.

If you need to preserve historical data, additional migration logic would be needed to convert old timestamps to the new format.
