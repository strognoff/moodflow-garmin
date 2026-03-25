# MoodFlow - Garmin Watch App

Track your daily mood and emotions with a beautiful, intuitive interface designed for Garmin Connect IQ watches. Features 7-day trend visualization with automatic correlation to sleep and activity metrics.

## Features

### Core Features
- **5-Point Mood Scale**: Check-in daily with an intuitive scale from 1 (Very Bad) to 5 (Very Good)
- **Smart Daily Tracking**: One entry per day with smart replacement if checking in multiple times
- **7-Day Trend Visualization**: Beautiful chart showing your mood patterns over the past week with accurate day-of-week labels
- **Health Correlations**: Automatic correlation with Garmin sleep hours and step count data
- **Fully Offline**: All data stored securely on your device with no sync required
- **Data Management**: Clean slate option via Settings with multi-step confirmation protection

### Navigation
- **Swipe Left/Right**: Seamlessly navigate between Check-in and Trend screens
- **UP/DOWN Buttons**: Select your mood level (1-5) on the Check-in screen
- **ENTER Button**: Save your mood entry with smart confirmation if replacing today's mood
- **MENU Button (M)**: Access Settings from the main Check-in screen
- **BACK Button**: Exit Settings and return to Check-in screen

### Settings
- **Intentional Access**: Press MENU button (M) from Check-in screen to prevent accidental opening
- **Reset All Data**: Clean, prominent button with red warning styling
- **Multi-Step Confirmation**: UP (No) or DOWN (Yes) confirmation dialog prevents accidental data loss
- **Minimal Interface**: Focused design with only essential options

### Visual Design
- **Color-Blind Friendly Palette**: Distinct, accessible colors for each mood level
  - Purple (1) = Very Bad
  - Blue (2) = Bad  
  - Green (3) = Neutral
  - Yellow (4) = Good
  - Orange (5) = Very Good
- **Modern Wellness Aesthetic**: Calming soft colors and clear typography
- **Responsive Layout**: Optimized for both round and rectangular watch displays
- **Consistent Design Language**: Unified color scheme and styling across all screens

## Color Scheme

Calming wellness palette designed for daily use:
- Soft Blue: #90CAF9
- Soft Green: #A5D6A7
- Soft Lavender: #CE93D8
- Warm Grey: #ECEFF1

## Supported Devices

### Forerunner Series
- Forerunner 255, 255s
- Forerunner 265, 265s
- Forerunner 955
- Forerunner 965

### Fenix Series
- Fenix 7, 7s, 7x
- Fenix 7 Pro, 7s Pro, 7x Pro (with and without WiFi variants)
- Fenix 8 (43mm, 47mm, Solar 47mm, Solar 51mm)
- Fenix 8 Pro 47mm

### Epix Series
- Epix 2
- Epix 2 Pro (42mm, 47mm, 51mm)

### Descent Series
- Descent Mk3 (43mm, 51mm)

### Enduro Series
- Enduro 3

### MARQ Series
- MARQ 2
- MARQ 2 Aviator

### D2 Series
- D2 Air X10
- D2 Mach 1
- D2 Mach 2

## Technical Details

- **Minimum API Level**: 4.2.0
- **Storage**: Device-local storage for mood entries
- **Sync**: None required - works fully offline
- **Permissions**: Activity data, Sleep data, Vibrate
- **Architecture**: Modular design with separation of concerns (all files under 150 lines)

## Project Structure

```
source/
├── MoodFlowApp.mc - Application entry point
├── MoodFlowView.mc - Main view coordinator
├── MoodFlowDataStore.mc - Storage wrapper
├── models/ - Data structures and constants
├── managers/ - Business logic (mood entries, settings, reminders)
├── providers/ - External data access (Garmin data, exports)
├── screens/ - UI components (Check-in, Trend, Settings)
└── delegates/ - Input handling
```

## Building

Build and test using Visual Studio Code with the Garmin Connect IQ extension:

1. Open the project in VS Code
2. Press F5 or use the Run configuration in `.vscode/launch.json`
3. Select your target device (default: fenix8solar51mm)

Alternatively, use the Garmin Monkey C compiler:
```bash
monkeyc -f monkey.jungle -o output.prg -w
```

## Changelog

### Recent Updates (March 2026)

#### Graph Date Bug Fix (Critical)
- **Fixed incorrect day-of-week display**: Moods now appear on the correct day in the 7-day trend chart
- **Improved date ID generation**: Changed from day_of_week-based to year*10000 + month*100 + day format (e.g., 20260323)
- **Accurate 7-day retrieval**: getLast7DaysEntries() now calculates actual calendar dates instead of using insertion order
- **Proper day labels**: Trend chart displays correct S/M/T/W/T/F/S labels based on actual calendar dates
- **Collision prevention**: Unique date IDs ensure no overlap between different dates

#### Settings Redesign
- **MENU button access**: Settings now only accessible via MENU button (M) from Check-in screen
- **Simplified interface**: Clean, minimal design with single essential Reset Data option
- **Improved safety**: Red/pink warning colors and multi-step confirmation dialog
- **Better navigation**: BACK button properly exits settings, preventing accidental swipe access
- **Visual consistency**: Settings header matches MoodFlow check-in screen styling

#### Navigation Improvements
- **Streamlined swipe navigation**: Left/Right swipes now only cycle between Check-in and Trend screens
- **Removed Settings from swipe**: Prevents accidental access to destructive data operations
- **Better button handling**: Migrated to BehaviorDelegate for proper BACK button support across all screens
- **Intentional design**: Settings require deliberate MENU button press

#### Code Architecture Refactoring
- **Modular structure**: Broke down monolithic files into focused components
- **File size limit**: All files now under 150 lines for better maintainability
- **Separation of concerns**: Clear boundaries between models, managers, providers, screens, and delegates
- **Improved testability**: Isolated components easier to test and modify
- **Enhanced scalability**: New features can be added without bloating existing files

#### UI/UX Enhancements
- **Consistent color scheme**: All screens use the same calming wellness palette
- **Clear visual hierarchy**: Headers and buttons with improved styling
- **Warning indicators**: Prominent red/pink colors for destructive actions
- **Confirmation dialogs**: Multi-step confirmation prevents accidental data loss
- **Responsive design**: Optimized layouts for various watch form factors

## License

Personal use / Educational purposes

## Author

MoodFlow Garmin Watch App - Part of the strognoff wellness ecosystem