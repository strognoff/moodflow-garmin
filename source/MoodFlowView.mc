import Toybox.WatchUi;
import Toybox.Graphics;
import Toybox.Lang;

//! Main view for MoodFlow
class MoodFlowView extends WatchUi.View {
    
    var moodFlowApp as MoodFlowApp;
    
    // Screen states
    const SCREEN_CHECKIN = 0;
    const SCREEN_TREND = 1;
    const SCREEN_SETTINGS = 2;
    
    var currentScreen as Number = 0;
    var selectedMoodIndex as Number = 2;
    var settingsSelectedItem as Number = 0;
    var settingsScrollOffset as Number = 0;
    var settingsEditing as Boolean = false;
    var showingConfirmDialog as Boolean = false;
    var confirmDialogType as String = "";
    
    // Settings menu items
    const SETTINGS_ITEM_RESET = 0;
    const SETTINGS_ITEMS_COUNT = 1;
    
    // Display properties
    var isRoundDisplay as Boolean = false;
    var displayWidth as Number = 240;
    var displayHeight as Number = 240;
    var bezelClearance as Number = 10;
    
    // Colors
    const COLOR_SOFT_BLUE = 0x90CAF9;
    const COLOR_SOFT_GREEN = 0xA5D6A7;
    const COLOR_SOFT_LAVENDER = 0xCE93D8;
    const COLOR_WARM_GREY = 0xECEFF1;
    const COLOR_DARK_GREY = 0x37474F;
    
    // Mood emoji indicators (Unicode - color-blind friendly with shape + color)
    // Using text symbols that render well on Connect IQ devices
    const MOOD_EMOJIS = ["1", "2", "3", "4", "5"];  // Fallback when Unicode emoji not supported
    const MOOD_LABELS = ["Very Bad", "Bad", "Neutral", "Good", "Very Good"];
    
    function initialize(app as MoodFlowApp) {
        View.initialize();
        moodFlowApp = app;
    }
    
    function onShow() as Void {
        // Detect display shape and set bezel clearance
        detectDisplayShape();
    }
    
    function detectDisplayShape() as Void {
        // Use System.getDeviceSettings to detect display type
        if (Toybox.System has :getDeviceSettings) {
            var settings = Toybox.System.getDeviceSettings();
            if (settings != null && settings has :screenShape) {
                isRoundDisplay = (settings.screenShape == 1); // 1 = ROUND
            } else if (settings != null && settings has :screenWidth && settings has :screenHeight) {
                // Fallback: check aspect ratio
                var w = settings.screenWidth;
                var h = settings.screenHeight;
                if (h > w * 1.05) {
                    isRoundDisplay = true;
                }
            }
        }
        
        // Set bezel clearance based on display shape
        // Round displays need more clearance for curved edges
        if (isRoundDisplay) {
            bezelClearance = 18;
        } else {
            bezelClearance = 10;
        }
    }
    
    function getBezel() as Number {
        return bezelClearance;
    }
    
    function onUpdate(dc as Dc) as Void {
        if (currentScreen == SCREEN_CHECKIN) {
            drawCheckInScreen(dc);
            // Show confirmation dialog overlay if needed
            if (showingConfirmDialog && confirmDialogType.equals("mood")) {
                drawConfirmMoodDialog(dc);
            }
        } else if (currentScreen == SCREEN_TREND) {
            drawTrendScreen(dc);
        } else if (currentScreen == SCREEN_SETTINGS) {
            drawSettingsScreen(dc);
        }
    }
    
    function drawCheckInScreen(dc as Dc) as Void {
        var width = dc.getWidth();
        var height = dc.getHeight();
        var centerX = width / 2;
        var centerY = height / 2;
        
        dc.setColor(COLOR_WARM_GREY, COLOR_WARM_GREY);
        dc.clear();
        
        // Header
        dc.setColor(COLOR_SOFT_BLUE, COLOR_SOFT_BLUE);
        dc.fillRectangle(0, 0, width, (height * 0.15).toNumber());
        
        dc.setColor(COLOR_DARK_GREY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX, bezelClearance + 15, Graphics.FONT_TINY, "MoodFlow", Graphics.TEXT_JUSTIFY_CENTER);
        
        // Mood selection circles
        var startX = bezelClearance + 15;
        var endX = width - bezelClearance - 15;
        var moodY = centerY - 20;
        var spacing = (endX - startX) / 4;
        var baseDim = width < height ? width : height;
        var circleR = (baseDim * 0.09).toNumber();
        if (circleR < 20) { circleR = 20; }
        
        var moodColors = [0x9C27B0, 0x2196F3, 0x4CAF50, 0xFFEB3B, 0xFF9800];
        
        for (var i = 0; i < 5; i++) {
            var x = startX + (i * spacing);
            var sel = (i == selectedMoodIndex);
            
            if (sel) {
                // Selected: white circle with colored ring
                dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_WHITE);
                dc.fillCircle(x, moodY, circleR);
                
                dc.setColor(moodColors[i], Graphics.COLOR_TRANSPARENT);
                dc.setPenWidth(4);
                dc.drawCircle(x, moodY, circleR + 3);
                dc.setPenWidth(1);
            } else {
                // Not selected: colored circle
                dc.setColor(moodColors[i], moodColors[i]);
                dc.fillCircle(x, moodY, circleR);
            }
            
            // Number below circle
            dc.setColor(COLOR_DARK_GREY, Graphics.COLOR_TRANSPARENT);
            dc.drawText(x, moodY + circleR + 4, Graphics.FONT_XTINY, (i + 1).toString(), Graphics.TEXT_JUSTIFY_CENTER);
        }
        
        // Selected mood label
        var mood = selectedMoodIndex + 1;
        dc.setColor(COLOR_DARK_GREY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX, moodY + circleR + 22, Graphics.FONT_MEDIUM, moodFlowApp.getMoodLabel(mood), Graphics.TEXT_JUSTIFY_CENTER);
        
        // Today's average - moved lower to avoid overlap
        var todayEntries = moodFlowApp.getTodayEntries();
        if (todayEntries.size() > 0) {
            var avg = moodFlowApp.getAverageMood(todayEntries);
            dc.setColor(0x757575, Graphics.COLOR_TRANSPARENT);
            dc.drawText(centerX, moodY + circleR + 55, Graphics.FONT_XTINY, "Today avg: " + moodFlowApp.getMoodLabel(avg), Graphics.TEXT_JUSTIFY_CENTER);
        }
        
        // Navigation arrows
        dc.setColor(COLOR_SOFT_LAVENDER, Graphics.COLOR_TRANSPARENT);
        dc.fillPolygon([[bezelClearance, centerY], [bezelClearance + 12, centerY - 8], [bezelClearance + 12, centerY + 8]]);
        dc.fillPolygon([[width - bezelClearance, centerY], [width - bezelClearance - 12, centerY - 8], [width - bezelClearance - 12, centerY + 8]]);
        
        // Footer with navigation hints
        dc.setColor(0x9E9E9E, Graphics.COLOR_TRANSPARENT);
        dc.drawText(bezelClearance + 120, 245, Graphics.FONT_XTINY, "< Graph M=Stgs", Graphics.TEXT_JUSTIFY_CENTER);
        
    }
    
    function drawTrendScreen(dc as Dc) as Void {
        var width = dc.getWidth();
        var height = dc.getHeight();
        var centerX = width / 2;
        
        dc.setColor(COLOR_WARM_GREY, COLOR_WARM_GREY);
        dc.clear();
        
        // Title
        dc.setColor(COLOR_DARK_GREY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX, bezelClearance + 2, Graphics.FONT_XTINY, "7-Day Trend", Graphics.TEXT_JUSTIFY_CENTER);
        
        // Chart dimensions - centered vertically on screen
        // Account for bezel clearance on round displays
        var effectiveBezel = bezelClearance + (isRoundDisplay ? 8 : 0);
        var chartL = effectiveBezel + 20;
        var chartR = width - effectiveBezel - 8;
        var chartH = (height * 0.30).toNumber();  // Chart height: 30% of screen
        var centerY = height / 2;
        var chartT = centerY - (chartH / 2) - 15;  // Center chart vertically, slightly above true center
        var chartB = chartT + chartH;  // Bottom of chart
        var chartW = chartR - chartL;
        
        // Draw horizontal grid lines and Y-axis labels
        // Level 1 at bottom (chartB), Level 5 at top (chartT)
        dc.setColor(0xBDBDBD, Graphics.COLOR_TRANSPARENT);
        for (var level = 1; level <= 5; level++) {
            var y = chartB - ((level - 1) * chartH / 4);
            dc.drawLine(chartL, y, chartR, y);
            dc.drawText(chartL - 3, y - 3, Graphics.FONT_XTINY, level.toString(), Graphics.TEXT_JUSTIFY_RIGHT);
        }
        
        // Prepare data points
        var entries = moodFlowApp.getLast7DaysEntries();
        var points = [];
        var labels = ["S", "M", "T", "W", "T", "F", "S"];
        
        for (var i = 0; i < 7; i++) {
            points.add(3);
        }
        
        var count = entries.size() < 7 ? entries.size() : 7;
        for (var i = 0; i < count; i++) {
            points[7 - count + i] = entries[i].mood;
        }
        
        // Draw mood line
        dc.setColor(0x2196F3, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(2);
        for (var i = 0; i < points.size() - 1; i++) {
            var x1 = chartL + (i * chartW / 6);
            var y1 = chartB - ((points[i] - 1) * chartH / 4);
            var x2 = chartL + ((i + 1) * chartW / 6);
            var y2 = chartB - ((points[i + 1] - 1) * chartH / 4);
            dc.drawLine(x1, y1, x2, y2);
        }
        dc.setPenWidth(1);
        
        // Draw data points
        for (var i = 0; i < points.size(); i++) {
            var x = chartL + (i * chartW / 6);
            var y = chartB - ((points[i] - 1) * chartH / 4);
            dc.setColor(0x2196F3, Graphics.COLOR_TRANSPARENT);
            dc.fillCircle(x, y, 5);
            dc.setColor(COLOR_WARM_GREY, Graphics.COLOR_TRANSPARENT);
            dc.fillCircle(x, y, 2);
        }
        
        // Draw vertical grid lines and day labels
        for (var i = 0; i < 7; i++) {
            var x = chartL + (i * chartW / 6);
            dc.setColor(0xE0E0E0, Graphics.COLOR_TRANSPARENT);
            dc.drawLine(x, chartT, x, chartB);
            dc.setColor(COLOR_DARK_GREY, Graphics.COLOR_TRANSPARENT);
            dc.drawText(x, chartB + 1, Graphics.FONT_XTINY, labels[i], Graphics.TEXT_JUSTIFY_CENTER);
        }
        
        // Data section - centered below chart with much more spacing
        var sleepData = moodFlowApp.getSleepData();
        var activityData = moodFlowApp.getActivityData();
        var dataY = chartB + 35;  // Start below day labels with much more space
        
        if (sleepData.get("available") as Boolean) {
            dc.setColor(COLOR_DARK_GREY, Graphics.COLOR_TRANSPARENT);
            dc.drawText(centerX, dataY, Graphics.FONT_XTINY, "Sleep: " + (sleepData.get("hours") as Float).format("%.1f") + "h", Graphics.TEXT_JUSTIFY_CENTER);
            dataY = dataY + 12;
        }
        
        if (activityData.get("available") as Boolean) {
            dc.setColor(COLOR_DARK_GREY, Graphics.COLOR_TRANSPARENT);
            dc.drawText(centerX, dataY, Graphics.FONT_XTINY, "Steps: " + (activityData.get("steps") as Number), Graphics.TEXT_JUSTIFY_CENTER);
        }
    }
    

    function drawSettingsScreen(dc as Dc) as Void {
        var width = dc.getWidth();
        var height = dc.getHeight();
        var centerX = width / 2;
        var centerY = height / 2;
        
        dc.setColor(COLOR_WARM_GREY, COLOR_WARM_GREY);
        dc.clear();
        
        // Confirmation dialog overlay
        if (showingConfirmDialog) {
            drawSettingsConfirmDialog(dc);
            return;
        }
        
        // Header
        dc.setColor(COLOR_SOFT_BLUE, COLOR_SOFT_BLUE);
        dc.fillRectangle(0, 0, width, (height * 0.15).toNumber());
        
        dc.setColor(COLOR_DARK_GREY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX, bezelClearance + 15, Graphics.FONT_TINY, "Settings", Graphics.TEXT_JUSTIFY_CENTER);
        
        // Reset Data button - centered
        var btnW = width - 2 * (bezelClearance + 20);
        var btnH = 60;
        var btnX = centerX - (btnW / 2);
        var btnY = centerY - (btnH / 2);
        
        // Button background
        dc.setColor(0xFFCDD2, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(btnX, btnY, btnW, btnH);
        
        // Button border
        dc.setColor(0xE57373, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(3);
        dc.drawRectangle(btnX, btnY, btnW, btnH);
        dc.setPenWidth(1);
        
        // Button text
        dc.setColor(0xC62828, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX, btnY + 12, Graphics.FONT_SMALL, "Reset All Data", Graphics.TEXT_JUSTIFY_CENTER);
        dc.setColor(0x757575, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX, btnY + 35, Graphics.FONT_XTINY, "Clear all moods", Graphics.TEXT_JUSTIFY_CENTER);
        
        // Bottom hints
        dc.setColor(0x9E9E9E, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX, height - bezelClearance - 15, Graphics.FONT_XTINY, "ENTER to reset", Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(centerX, height - bezelClearance - 2, Graphics.FONT_XTINY, "BACK to exit", Graphics.TEXT_JUSTIFY_CENTER);
    }
    

    function drawSettingsConfirmDialog(dc as Dc) as Void {
        var width = dc.getWidth();
        var height = dc.getHeight();
        var centerX = width / 2;
        var centerY = height / 2;
        
        // Semi-transparent background
        dc.setColor(0x000000, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(0, 0, width, height);
        
        // Dialog box
        var dialogW = width - 2 * (bezelClearance + 10);
        var dialogH = 90;
        var dialogX = bezelClearance + 10;
        var dialogY = centerY - (dialogH / 2);
        
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_WHITE);
        dc.fillRectangle(dialogX, dialogY, dialogW, dialogH);
        dc.setColor(0xE57373, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(3);
        dc.drawRectangle(dialogX, dialogY, dialogW, dialogH);
        dc.setPenWidth(1);
        
        // Dialog content
        dc.setColor(0xC62828, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX, dialogY + 10, Graphics.FONT_SMALL, "Reset All Data?", Graphics.TEXT_JUSTIFY_CENTER);
        dc.setColor(0xE57373, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX, dialogY + 28, Graphics.FONT_XTINY, "This will delete all", Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(centerX, dialogY + 42, Graphics.FONT_XTINY, "mood entries!", Graphics.TEXT_JUSTIFY_CENTER);
        
        // Buttons hint
        dc.setColor(0x9E9E9E, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX, dialogY + dialogH - 18, Graphics.FONT_XTINY, "UP:No  DOWN:Yes", Graphics.TEXT_JUSTIFY_CENTER);
    }
    
    function drawConfirmMoodDialog(dc as Dc) as Void {
        var width = dc.getWidth();
        var height = dc.getHeight();
        var centerX = width / 2;
        var centerY = height / 2;
        
        // Semi-transparent overlay
        dc.setColor(0x000000, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(0, 0, width, height);
        
        // Dialog background
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_WHITE);
        dc.fillRectangle(bezelClearance + 10, centerY - 40, width - 2 * (bezelClearance + 10), 80);
        dc.setColor(COLOR_DARK_GREY, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(2);
        dc.drawRectangle(bezelClearance + 10, centerY - 40, width - 2 * (bezelClearance + 10), 80);
        dc.setPenWidth(1);
        
        // Dialog text
        dc.setColor(COLOR_DARK_GREY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX, centerY - 25, Graphics.FONT_XTINY, "Replace today's", Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(centerX, centerY - 10, Graphics.FONT_XTINY, "mood?", Graphics.TEXT_JUSTIFY_CENTER);
        
        dc.setColor(0x9E9E9E, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX, centerY + 15, Graphics.FONT_XTINY, "UP:No DOWN:Yes", Graphics.TEXT_JUSTIFY_CENTER);
    }
    

    
    function navigateLeft() as Void {
        if (currentScreen == SCREEN_CHECKIN) {
            currentScreen = SCREEN_TREND;
        } else if (currentScreen == SCREEN_TREND) {
            currentScreen = SCREEN_CHECKIN;
        }
        WatchUi.requestUpdate();
    }
    
    function navigateRight() as Void {
        if (currentScreen == SCREEN_TREND) {
            currentScreen = SCREEN_CHECKIN;
        } else if (currentScreen == SCREEN_CHECKIN) {
            currentScreen = SCREEN_TREND;
        }
        WatchUi.requestUpdate();
    }
    
    function openSettings() as Void {
        currentScreen = SCREEN_SETTINGS;
        settingsSelectedItem = 0;
        settingsScrollOffset = 0;
        WatchUi.requestUpdate();
    }
    
    function exitSettings() as Void {
        currentScreen = SCREEN_CHECKIN;
        settingsSelectedItem = 0;
        settingsScrollOffset = 0;
        WatchUi.requestUpdate();
    }
    

    function handleConfirmDialog(confirmed as Boolean) as Void {
        if (confirmDialogType.equals("reset")) {
            if (confirmed) {
                moodFlowApp.resetAllData();
                if (Attention has :vibrate) {
                    Attention.vibrate([new Attention.VibeProfile(100, 200)]);
                }
            }
            showingConfirmDialog = false;
            confirmDialogType = "";
        } else if (confirmDialogType.equals("mood")) {
            if (confirmed) {
                var mood = selectedMoodIndex + 1;
                moodFlowApp.replaceTodayMood(mood);
                if (Attention has :vibrate) {
                    Attention.vibrate([new Attention.VibeProfile(50, 100)]);
                }
            }
            showingConfirmDialog = false;
            confirmDialogType = "";
        }
    }
}

//! Input delegate for MoodFlow
class MoodFlowDelegate extends WatchUi.BehaviorDelegate {
    
    var view as MoodFlowView;
    
    function initialize(v as MoodFlowView) {
        BehaviorDelegate.initialize();
        view = v;
    }
    
    function onBack() as Boolean {
        // Handle BACK button press
        if (view.currentScreen == view.SCREEN_SETTINGS) {
            view.exitSettings();
            return true;
        }
        return false;
    }
    
    function onKeyPressed(key as WatchUi.KeyEvent) as Boolean {
        var keyCode = key.getKey();
        var app = view.moodFlowApp;
        
        // Handle confirmation dialogs
        if (view.showingConfirmDialog) {
            if (keyCode == WatchUi.KEY_UP) {
                // No/Cancel
                view.handleConfirmDialog(false);
                WatchUi.requestUpdate();
                return true;
            } else if (keyCode == WatchUi.KEY_DOWN) {
                // Yes/Confirm
                view.handleConfirmDialog(true);
                WatchUi.requestUpdate();
                return true;
            }
            return true;
        }
        
        if (view.currentScreen == view.SCREEN_CHECKIN) {
            if (keyCode == WatchUi.KEY_UP) {
                if (view.selectedMoodIndex < 4) {
                    view.selectedMoodIndex = view.selectedMoodIndex + 1;
                    app.currentMood = view.selectedMoodIndex + 1;
                    WatchUi.requestUpdate();
                }
                return true;
            } else if (keyCode == WatchUi.KEY_DOWN) {
                if (view.selectedMoodIndex > 0) {
                    view.selectedMoodIndex = view.selectedMoodIndex - 1;
                    app.currentMood = view.selectedMoodIndex + 1;
                    WatchUi.requestUpdate();
                }
                return true;
            } else if (keyCode == WatchUi.KEY_ENTER) {
                var mood = view.selectedMoodIndex + 1;
                // Check if today already has a mood
                if (app.hasTodayMood()) {
                    view.showingConfirmDialog = true;
                    view.confirmDialogType = "mood";
                } else {
                    app.addMoodEntry(mood, "");
                    if (Attention has :vibrate) {
                        Attention.vibrate([new Attention.VibeProfile(50, 100)]);
                    }
                }
                WatchUi.requestUpdate();
                return true;
            } else if (keyCode == WatchUi.KEY_MENU) {
                // Open settings from main screen
                view.openSettings();
                return true;
            }
        } else if (view.currentScreen == view.SCREEN_SETTINGS) {
            if (keyCode == WatchUi.KEY_ENTER) {
                // Trigger reset confirmation
                view.showingConfirmDialog = true;
                view.confirmDialogType = "reset";
                WatchUi.requestUpdate();
                return true;
            }
        }
        
        return false;
    }

    
    function onSwipe(e as WatchUi.SwipeEvent) as Boolean {
        var dir = e.getDirection();
        
        if (dir == WatchUi.SWIPE_LEFT) {
            view.navigateLeft();
            return true;
        } else if (dir == WatchUi.SWIPE_RIGHT) {
            view.navigateRight();
            return true;
        }
        
        return false;
    }
}