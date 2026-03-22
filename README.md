# MoodFlow - Garmin Watch App

A daily mood and emotion tracker for Garmin Connect IQ watches with 7-day trend visualization and correlation with sleep/activity metrics.

## Features

### Core Features
- **5-Point Mood Scale**: Check-in with 1=Very Bad to 5=Very Good (replaces if checking in on the same day)
- **7-Day Trend View**: Visual chart showing mood patterns over the past week
- **Sleep Correlation**: View sleep hours alongside mood trends
- **Activity Correlation**: See step count with mood data
- **Local Storage**: All data stored securely on device
- **Data Management**: Reset all mood data via Settings

### Navigation
- **Swipe Left/Right**: Navigate between Check-in and Trend screens
- **UP/DOWN Buttons**: Select mood level (1-5) on Check-in screen
- **ENTER Button**: Save mood entry (with confirmation if replacing today's mood)
- **MENU Button (M)**: Open Settings from Check-in screen
- **BACK Button**: Exit Settings and return to Check-in screen

### Settings
- **Access**: Press MENU button (M) from the main Check-in screen
- **Reset All Data**: Delete all mood entries with confirmation dialog
- **Clean UI**: Minimal, focused interface matching the app's design

### Visual Design
- **Color-Blind Friendly**: Different colors for mood levels
  - Purple (1) = Very Bad
  - Blue (2) = Bad  
  - Green (3) = Neutral
  - Yellow (4) = Good
  - Orange (5) = Very Good
- **Modern Interface**: Clean layout with soft colors and clear typography
- **Responsive**: Works on both round and rectangular watch displays

## Color Scheme

Calming wellness palette:
- Soft Blue: #90CAF9
- Soft Green: #A5D6A7
- Soft Lavender: #CE93D8
- Warm Grey: #ECEFF1

## Supported Devices

### Forerunner Series
- Forerunner 255
- Forerunner 265
- Forerunner 955
- Forerunner 965

### Fenix Series
- Fenix 7, 7 Pro, 7x
- Fenix 8 series

### Epix Series
- Epix 2, 2 Pro

### Venu Series
- Venu 2, 2 Plus, 3

### Instinct Series
- Instinct 2, 2s, 3

### MARQ Series
- MARQ 2 series

### Vivoactive
- Vivoactive 5

## Technical Details

- **Minimum API Level**: 4.2.0
- **Storage**: Device-local storage for mood entries
- **Sync**: None required - works fully offline
- **Permissions**: Activity data, Sleep data, Vibrate

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

#### Settings Redesign
- **MENU button access**: Settings now only accessible via MENU button (M) from Check-in screen
- **Simplified interface**: Settings screen now features only essential Reset Data option
- **Improved navigation**: BACK button properly exits settings
- **Visual consistency**: Settings header matches MoodFlow check-in screen styling

#### Navigation Improvements
- **Streamlined swipe navigation**: Left/Right swipes now only cycle between Check-in and Trend screens
- **Removed Settings from swipe**: Prevents accidental access to destructive data operations
- **Better button handling**: Migrated to BehaviorDelegate for proper BACK button support

#### UI/UX Enhancements
- **Consistent color scheme**: All screens use the same calming wellness palette
- **Clear visual hierarchy**: Headers and buttons with improved styling
- **Warning indicators**: Red/pink colors for destructive actions (Reset Data)
- **Confirmation dialogs**: Multi-step confirmation prevents accidental data loss

## License

Personal use / Educational purposes

## Author

MoodFlow Garmin Watch App - Part of the strognoff wellness ecosystem