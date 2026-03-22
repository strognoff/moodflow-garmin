# MoodFlow - Garmin Watch App

A daily mood and emotion tracker for Garmin Connect IQ watches with 7-day trend visualization and correlation with sleep/activity metrics.

## Features

### Core Features
- **5-Point Mood Scale**: Check-in with 1=Very Bad to 5=Very Good
- **Optional Notes**: Add context to your mood entries
- **7-Day Trend View**: Visual chart showing mood patterns
- **Sleep Correlation**: View sleep quality alongside mood
- **Activity Correlation**: See steps/heart rate with mood data
- **Local Storage**: All data stored securely on device
- **Data Export**: JSON and CSV export for personal records
- **Daily Reminder**: Configurable vibration notification

### Navigation
- **Swipe Left/Right**: Navigate between Check-in, Trend, Note, and Settings screens
- **Hold Tap**: Quick access to add notes
- **Back Button**: Return to previous screen

### Accessibility
- **Color-Blind Friendly**: Different shapes + colors for mood levels
  - Purple Diamond (◆) = Very Bad
  - Blue Diamond (◇) = Bad  
  - Green Circle (○) = Neutral
  - Yellow Triangle (△) = Good
  - Orange Star (☆) = Very Good

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
- **Storage**: Device-local with optional export
- **Sync**: None required - works fully offline
- **Permissions**: Activity data, Sleep data, Notifications, Vibrate

## Building

```bash
# Using Garmin Monkey C compiler
monkeyc -f project.jungle -y private-key.der -o output.prg -w
```

## Data Export

Export your mood data as:
- **JSON**: Full structured data with timestamps
- **CSV**: Spreadsheet-compatible format

## License

Personal use / Educational purposes

## Author

MoodFlow Garmin Watch App - Part of the strognoff wellness ecosystem