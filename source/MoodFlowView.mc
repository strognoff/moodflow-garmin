import Toybox.WatchUi;
import Toybox.Graphics;
import Toybox.Lang;

//! Main view for MoodFlow
class MoodFlowView extends WatchUi.View {
    
    var moodFlowApp as MoodFlowApp;
    
    // Screen states
    const SCREEN_CHECKIN = 0;
    const SCREEN_TREND = 1;
    const SCREEN_NOTE = 2;
    const SCREEN_SETTINGS = 3;
    
    var currentScreen as Number = 0;
    var selectedMoodIndex as Number = 2;
    var noteText as String = "";
    var noteCharIndex as Number = 0;
    var settingsSelectedItem as Number = 0;
    var settingsEditing as Boolean = false;
    var settingsEditHour as Boolean = true;
    
    // Colors
    const COLOR_SOFT_BLUE = 0x90CAF9;
    const COLOR_SOFT_GREEN = 0xA5D6A7;
    const COLOR_SOFT_LAVENDER = 0xCE93D8;
    const COLOR_WARM_GREY = 0xECEFF1;
    const COLOR_DARK_GREY = 0x37474F;
    
    const BEZEL = 10;
    const CHAR_KEY_W = 20;
    const CHAR_KEY_H = 18;
    
    var chars = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M",
                 "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z",
                 "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "_"];
    
    function initialize(app as MoodFlowApp) {
        View.initialize();
        moodFlowApp = app;
    }
    
    function onShow() as Void {
    }
    
    function onUpdate(dc as Dc) as Void {
        if (currentScreen == SCREEN_CHECKIN) {
            drawCheckInScreen(dc);
        } else if (currentScreen == SCREEN_TREND) {
            drawTrendScreen(dc);
        } else if (currentScreen == SCREEN_NOTE) {
            drawNoteScreen(dc);
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
        
        dc.setColor(COLOR_SOFT_BLUE, COLOR_SOFT_BLUE);
        dc.fillRectangle(0, 0, width, (height * 0.15).toNumber());
        
        dc.setColor(COLOR_DARK_GREY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX, BEZEL + 15, Graphics.FONT_TINY, "MoodFlow", Graphics.TEXT_JUSTIFY_CENTER);
        
        var startX = BEZEL + 15;
        var endX = width - BEZEL - 15;
        var moodY = centerY - 30;
        var spacing = (endX - startX) / 4;
        var baseDim = width < height ? width : height;
        var circleR = (baseDim * 0.08).toNumber();
        if (circleR < 22) { circleR = 22; }
        
        var moodColors = [0x9C27B0, 0x2196F3, 0x4CAF50, 0xFFEB3B, 0xFF9800];
        var moodShapes = ["d", "o", "O", "t", "s"];
        
        for (var i = 0; i < 5; i++) {
            var x = startX + (i * spacing);
            var sel = (i == selectedMoodIndex);
            
            dc.setColor(COLOR_WARM_GREY, COLOR_WARM_GREY);
            dc.fillCircle(x, moodY, circleR + 2);
            
            dc.setColor(moodColors[i], moodColors[i]);
            dc.fillCircle(x, moodY, circleR);
            
            if (sel) {
                dc.setColor(COLOR_DARK_GREY, Graphics.COLOR_TRANSPARENT);
                dc.setPenWidth(3);
                dc.drawCircle(x, moodY, circleR + 4);
                dc.setPenWidth(1);
            }
            
            var shapeCol = sel ? Graphics.COLOR_WHITE : COLOR_DARK_GREY;
            dc.setColor(shapeCol, Graphics.COLOR_TRANSPARENT);
            dc.drawText(x, moodY - 6, Graphics.FONT_TINY, moodShapes[i], Graphics.TEXT_JUSTIFY_CENTER);
            dc.drawText(x, moodY + 8, Graphics.FONT_TINY, (i + 1).toString(), Graphics.TEXT_JUSTIFY_CENTER);
        }
        
        var mood = selectedMoodIndex + 1;
        dc.setColor(COLOR_DARK_GREY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX, moodY + circleR + 25, Graphics.FONT_MEDIUM, moodFlowApp.getMoodLabel(mood), Graphics.TEXT_JUSTIFY_CENTER);
        
        var todayEntries = moodFlowApp.getTodayEntries();
        if (todayEntries.size() > 0) {
            var avg = moodFlowApp.getAverageMood(todayEntries);
            dc.setColor(0x757575, Graphics.COLOR_TRANSPARENT);
            dc.drawText(centerX, moodY + circleR + 50, Graphics.FONT_TINY, "Avg: " + moodFlowApp.getMoodLabel(avg), Graphics.TEXT_JUSTIFY_CENTER);
        }
        
        var bottomY = height - BEZEL - 25;
        dc.setColor(0x9E9E9E, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX, bottomY, Graphics.FONT_TINY, "ENT:Save Swipe:Nav", Graphics.TEXT_JUSTIFY_CENTER);
        
        dc.setColor(COLOR_SOFT_LAVENDER, Graphics.COLOR_TRANSPARENT);
        dc.fillPolygon([[BEZEL, centerY], [BEZEL + 12, centerY - 8], [BEZEL + 12, centerY + 8]]);
        dc.fillPolygon([[width - BEZEL, centerY], [width - BEZEL - 12, centerY - 8], [width - BEZEL - 12, centerY + 8]]);
    }
    
    function drawTrendScreen(dc as Dc) as Void {
        var width = dc.getWidth();
        var height = dc.getHeight();
        var centerX = width / 2;
        
        dc.setColor(COLOR_WARM_GREY, COLOR_WARM_GREY);
        dc.clear();
        
        dc.setColor(COLOR_DARK_GREY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX, BEZEL + 5, Graphics.FONT_TINY, "7-Day Trend", Graphics.TEXT_JUSTIFY_CENTER);
        
        var chartL = 35;
        var chartR = width - 12;
        var chartT = 45;
        var chartB = height - 50;
        var chartW = chartR - chartL;
        var chartH = chartB - chartT;
        
        dc.setColor(0xBDBDBD, Graphics.COLOR_TRANSPARENT);
        for (var level = 1; level <= 5; level++) {
            var y = chartB - ((level - 1) * chartH / 4);
            dc.drawLine(chartL, y, chartR, y);
            dc.drawText(chartL - 5, y - 4, Graphics.FONT_TINY, level.toString(), Graphics.TEXT_JUSTIFY_RIGHT);
        }
        
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
        
        for (var i = 0; i < points.size(); i++) {
            var x = chartL + (i * chartW / 6);
            var y = chartB - ((points[i] - 1) * chartH / 4);
            dc.setColor(0x2196F3, Graphics.COLOR_TRANSPARENT);
            dc.fillCircle(x, y, 6);
            dc.setColor(COLOR_WARM_GREY, Graphics.COLOR_TRANSPARENT);
            dc.fillCircle(x, y, 3);
        }
        
        for (var i = 0; i < 7; i++) {
            var x = chartL + (i * chartW / 6);
            dc.setColor(0xE0E0E0, Graphics.COLOR_TRANSPARENT);
            dc.drawLine(x, chartT, x, chartB);
            dc.setColor(COLOR_DARK_GREY, Graphics.COLOR_TRANSPARENT);
            dc.drawText(x, chartB + 5, Graphics.FONT_TINY, labels[i], Graphics.TEXT_JUSTIFY_CENTER);
        }
        
        var sleepData = moodFlowApp.getSleepData();
        var activityData = moodFlowApp.getActivityData();
        var corrY = chartB + 25;
        
        if (sleepData.get("available") as Boolean) {
            dc.setColor(COLOR_SOFT_LAVENDER, Graphics.COLOR_TRANSPARENT);
            dc.fillRectangle(chartL, corrY, chartW / 2 - 5, 18);
            dc.setColor(COLOR_DARK_GREY, Graphics.COLOR_TRANSPARENT);
            dc.drawText(chartL + 5, corrY + 2, Graphics.FONT_TINY, "Sleep: " + (sleepData.get("hours") as Float).format("%.1f") + "h", Graphics.TEXT_JUSTIFY_LEFT);
        }
        
        if (activityData.get("available") as Boolean) {
            dc.setColor(COLOR_SOFT_GREEN, Graphics.COLOR_TRANSPARENT);
            dc.fillRectangle(chartL + chartW / 2 + 5, corrY, chartW / 2 - 5, 18);
            dc.setColor(COLOR_DARK_GREY, Graphics.COLOR_TRANSPARENT);
            dc.drawText(chartL + chartW / 2 + 10, corrY + 2, Graphics.FONT_TINY, "Steps: " + (activityData.get("steps") as Number), Graphics.TEXT_JUSTIFY_LEFT);
        }
        
        var legY = height - BEZEL - 8;
        dc.setColor(0x2196F3, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(chartL + 5, legY, 3);
        dc.setColor(COLOR_DARK_GREY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(chartL + 12, legY - 4, Graphics.FONT_TINY, "Mood", Graphics.TEXT_JUSTIFY_LEFT);
        dc.setColor(0x9E9E9E, Graphics.COLOR_TRANSPARENT);
        dc.drawText(width - BEZEL - 5, legY - 4, Graphics.FONT_TINY, "Swipe", Graphics.TEXT_JUSTIFY_RIGHT);
    }
    
    function drawNoteScreen(dc as Dc) as Void {
        var width = dc.getWidth();
        var height = dc.getHeight();
        var centerX = width / 2;
        
        dc.setColor(COLOR_WARM_GREY, COLOR_WARM_GREY);
        dc.clear();
        
        dc.setColor(COLOR_DARK_GREY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX, BEZEL, Graphics.FONT_TINY, "Add Note", Graphics.TEXT_JUSTIFY_CENTER);
        
        var boxTop = 35;
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(BEZEL, boxTop, width - 2 * BEZEL, 35);
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(1);
        dc.drawRectangle(BEZEL, boxTop, width - 2 * BEZEL, 35);
        
        var dispText = noteText;
        if (dispText.length() > 15) {
            dispText = dispText.substring(dispText.length() - 15, dispText.length());
        }
        dc.drawText(centerX, boxTop + 8, Graphics.FONT_TINY, dispText, Graphics.TEXT_JUSTIFY_CENTER);
        
        var gridTop = boxTop + 50;
        var gridL = BEZEL + 5;
        var perRow = 9;
        
        var hlX = gridL + (noteCharIndex % perRow) * CHAR_KEY_W;
        var hlY = gridTop + (noteCharIndex / perRow).toNumber() * (CHAR_KEY_H + 2);
        dc.setColor(COLOR_SOFT_BLUE, COLOR_SOFT_BLUE);
        dc.fillRectangle(hlX - 1, hlY - 1, CHAR_KEY_W + 2, CHAR_KEY_H + 2);
        
        for (var i = 0; i < chars.size(); i++) {
            var row = (i / perRow).toNumber();
            var col = i % perRow;
            var x = gridL + col * CHAR_KEY_W;
            var y = gridTop + row * (CHAR_KEY_H + 2);
            var hl = (i == noteCharIndex);
            dc.setColor(hl ? Graphics.COLOR_WHITE : COLOR_DARK_GREY, Graphics.COLOR_TRANSPARENT);
            dc.drawText(x + CHAR_KEY_W / 2, y + 2, Graphics.FONT_TINY, chars[i], Graphics.TEXT_JUSTIFY_CENTER);
        }
        
        var btnY = height - BEZEL - 35;
        var btnW = 60;
        var btnH = 28;
        
        dc.setColor(COLOR_SOFT_LAVENDER, COLOR_SOFT_LAVENDER);
        dc.fillRectangle(BEZEL + 5, btnY, btnW, btnH);
        dc.setColor(COLOR_DARK_GREY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(BEZEL + 5 + btnW / 2, btnY + 6, Graphics.FONT_TINY, "Back", Graphics.TEXT_JUSTIFY_CENTER);
        
        dc.setColor(COLOR_SOFT_GREEN, COLOR_SOFT_GREEN);
        dc.fillRectangle(width - BEZEL - btnW - 5, btnY, btnW, btnH);
        dc.drawText(width - BEZEL - btnW / 2 - 5, btnY + 6, Graphics.FONT_TINY, "Done", Graphics.TEXT_JUSTIFY_CENTER);
        
        dc.setColor(0xFFCDD2, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(centerX - 30, btnY, 60, btnH);
        dc.setColor(0xC62828, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX, btnY + 6, Graphics.FONT_TINY, "Del", Graphics.TEXT_JUSTIFY_CENTER);
        
        dc.setColor(0x9E9E9E, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX, height - BEZEL - 5, Graphics.FONT_TINY, "UP:DOWN:Select ENT:Add", Graphics.TEXT_JUSTIFY_CENTER);
    }
    
    function drawSettingsScreen(dc as Dc) as Void {
        var width = dc.getWidth();
        var height = dc.getHeight();
        var centerX = width / 2;
        
        dc.setColor(COLOR_WARM_GREY, COLOR_WARM_GREY);
        dc.clear();
        
        dc.setColor(COLOR_DARK_GREY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX, BEZEL, Graphics.FONT_TINY, "Settings", Graphics.TEXT_JUSTIFY_CENTER);
        
        var startY = 40;
        var itemH = 40;
        
        var remStatus = moodFlowApp.reminderEnabled ? "ON" : "OFF";
        var timeStr = moodFlowApp.reminderHour.toString() + ":" + moodFlowApp.reminderMinute.toString();
        
        var items = [
            "Reminder: " + remStatus,
            "Time: " + timeStr,
            "Export JSON",
            "Export CSV",
            "Clear Data"
        ];
        
        for (var i = 0; i < items.size(); i++) {
            var y = startY + i * itemH;
            var sel = (i == settingsSelectedItem);
            
            if (sel) {
                if (settingsEditing && i == 4) {
                    dc.setColor(0xFFCDD2, COLOR_SOFT_LAVENDER);
                } else {
                    dc.setColor(COLOR_SOFT_LAVENDER, COLOR_SOFT_LAVENDER);
                }
                dc.fillRectangle(BEZEL, y, width - 2 * BEZEL, itemH - 5);
            }
            
            dc.setColor(COLOR_DARK_GREY, Graphics.COLOR_TRANSPARENT);
            dc.drawText(centerX, y + 10, Graphics.FONT_TINY, items[i], Graphics.TEXT_JUSTIFY_CENTER);
        }
        
        if (settingsEditing && settingsSelectedItem == 1) {
            var edY = startY + 1 * itemH;
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            dc.fillRectangle(centerX - 50, edY + 30, 100, 35);
            dc.setColor(COLOR_DARK_GREY, Graphics.COLOR_TRANSPARENT);
            dc.setPenWidth(2);
            dc.drawRectangle(centerX - 50, edY + 30, 100, 35);
            dc.setPenWidth(1);
            
            var hStr = moodFlowApp.reminderHour.toString();
            var mStr = moodFlowApp.reminderMinute.toString();
            
            if (settingsEditHour) {
                dc.setColor(COLOR_SOFT_BLUE, COLOR_SOFT_BLUE);
                dc.fillRectangle(centerX - 45, edY + 35, 35, 25);
            }
            dc.setColor(settingsEditHour ? Graphics.COLOR_WHITE : COLOR_DARK_GREY, Graphics.COLOR_TRANSPARENT);
            dc.drawText(centerX - 27, edY + 38, Graphics.FONT_MEDIUM, hStr, Graphics.TEXT_JUSTIFY_CENTER);
            
            dc.setColor(COLOR_DARK_GREY, Graphics.COLOR_TRANSPARENT);
            dc.drawText(centerX, edY + 38, Graphics.FONT_MEDIUM, ":", Graphics.TEXT_JUSTIFY_CENTER);
            
            if (!settingsEditHour) {
                dc.setColor(COLOR_SOFT_BLUE, COLOR_SOFT_BLUE);
                dc.fillRectangle(centerX + 10, edY + 35, 35, 25);
            }
            dc.setColor(!settingsEditHour ? Graphics.COLOR_WHITE : COLOR_DARK_GREY, Graphics.COLOR_TRANSPARENT);
            dc.drawText(centerX + 27, edY + 38, Graphics.FONT_MEDIUM, mStr, Graphics.TEXT_JUSTIFY_CENTER);
            
            dc.setColor(0x9E9E9E, Graphics.COLOR_TRANSPARENT);
            dc.drawText(centerX, edY + 70, Graphics.FONT_TINY, "UP:DOWN:Change", Graphics.TEXT_JUSTIFY_CENTER);
        }
        
        dc.setColor(0x9E9E9E, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX, height - BEZEL - 5, Graphics.FONT_TINY, "UP:DOWN:Select ENT:Edit", Graphics.TEXT_JUSTIFY_CENTER);
    }
    
    function navigateLeft() as Void {
        if (currentScreen == SCREEN_CHECKIN) {
            currentScreen = SCREEN_TREND;
        } else if (currentScreen == SCREEN_TREND) {
            currentScreen = SCREEN_NOTE;
        } else if (currentScreen == SCREEN_NOTE) {
            currentScreen = SCREEN_SETTINGS;
        }
        WatchUi.requestUpdate();
    }
    
    function navigateRight() as Void {
        if (currentScreen == SCREEN_SETTINGS) {
            currentScreen = SCREEN_NOTE;
        } else if (currentScreen == SCREEN_NOTE) {
            currentScreen = SCREEN_TREND;
        } else if (currentScreen == SCREEN_TREND) {
            currentScreen = SCREEN_CHECKIN;
        }
        WatchUi.requestUpdate();
    }
    
    function handleNoteNav(dir as String) as Void {
        var perRow = 9;
        var total = chars.size();
        
        if (dir.equals("up")) {
            var newIdx = noteCharIndex - perRow;
            if (newIdx >= 0) { noteCharIndex = newIdx; }
        } else if (dir.equals("down")) {
            var newIdx = noteCharIndex + perRow;
            if (newIdx < total) { noteCharIndex = newIdx; }
        } else if (dir.equals("left")) {
            if (noteCharIndex % perRow > 0) { noteCharIndex = noteCharIndex - 1; }
        } else if (dir.equals("right")) {
            var maxInRow = (noteCharIndex / perRow).toNumber() * perRow + perRow - 1;
            if (noteCharIndex < total - 1 && noteCharIndex < maxInRow) { noteCharIndex = noteCharIndex + 1; }
        }
    }
    
    function handleSettingsNav(dir as String) as Void {
        if (settingsEditing) {
            if (settingsSelectedItem == 1) {
                if (dir.equals("up")) {
                    if (settingsEditHour) {
                        moodFlowApp.reminderHour = (moodFlowApp.reminderHour + 1) % 24;
                    } else {
                        moodFlowApp.reminderMinute = (moodFlowApp.reminderMinute + 5) % 60;
                    }
                } else if (dir.equals("down")) {
                    if (settingsEditHour) {
                        moodFlowApp.reminderHour = (moodFlowApp.reminderHour - 1 + 24) % 24;
                    } else {
                        moodFlowApp.reminderMinute = (moodFlowApp.reminderMinute - 5 + 60) % 60;
                    }
                } else if (dir.equals("left")) {
                    settingsEditHour = true;
                } else if (dir.equals("right")) {
                    settingsEditHour = false;
                }
                moodFlowApp.saveSettings();
            }
        } else {
            if (dir.equals("up")) {
                if (settingsSelectedItem > 0) { settingsSelectedItem = settingsSelectedItem - 1; }
            } else if (dir.equals("down")) {
                if (settingsSelectedItem < 4) { settingsSelectedItem = settingsSelectedItem + 1; }
            }
        }
    }
    
    function handleSettingsAction() as Void {
        if (settingsSelectedItem == 0) {
            moodFlowApp.toggleReminder(!moodFlowApp.reminderEnabled);
        } else if (settingsSelectedItem == 1) {
            settingsEditing = !settingsEditing;
        } else if (settingsSelectedItem == 2) {
            moodFlowApp.sessionStorage.setValue("exportBuffer", moodFlowApp.exportDataJSON());
        } else if (settingsSelectedItem == 3) {
            moodFlowApp.sessionStorage.setValue("exportBuffer", moodFlowApp.exportDataCSV());
        } else if (settingsSelectedItem == 4) {
            if (!settingsEditing) {
                settingsEditing = true;
            } else {
                moodFlowApp.moodEntries = [];
                moodFlowApp.saveMoodEntries();
                settingsEditing = false;
            }
        }
    }
}

//! Input delegate for MoodFlow
class MoodFlowDelegate extends WatchUi.InputDelegate {
    
    var view as MoodFlowView;
    
    function initialize(v as MoodFlowView) {
        InputDelegate.initialize();
        view = v;
    }
    
    function onKeyPressed(key as WatchUi.KeyEvent) as Boolean {
        var keyCode = key.getKey();
        var app = view.moodFlowApp;
        
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
                app.addMoodEntry(mood, "");
                if (Attention has :vibrate) {
                    Attention.vibrate([new Attention.VibeProfile(50, 100)]);
                }
                WatchUi.requestUpdate();
                return true;
            }
        } else if (view.currentScreen == view.SCREEN_NOTE) {
            if (keyCode == WatchUi.KEY_UP) {
                view.handleNoteNav("up");
                WatchUi.requestUpdate();
                return true;
            } else if (keyCode == WatchUi.KEY_DOWN) {
                view.handleNoteNav("down");
                WatchUi.requestUpdate();
                return true;
            } else if (keyCode == WatchUi.KEY_LEFT) {
                view.handleNoteNav("left");
                WatchUi.requestUpdate();
                return true;
            } else if (keyCode == WatchUi.KEY_RIGHT) {
                view.handleNoteNav("right");
                WatchUi.requestUpdate();
                return true;
            } else if (keyCode == WatchUi.KEY_ENTER) {
                if (view.noteText.length() < 50) {
                    view.noteText = view.noteText + view.chars[view.noteCharIndex];
                }
                WatchUi.requestUpdate();
                return true;
            } else if (keyCode == WatchUi.KEY_MENU) {
                if (view.noteText.length() > 0) {
                    view.noteText = view.noteText.substring(0, view.noteText.length() - 1);
                }
                WatchUi.requestUpdate();
                return true;
            } else if (keyCode == WatchUi.KEY_ESC) {
                var mood = view.selectedMoodIndex + 1;
                var note = view.noteText;
                app.addMoodEntry(mood, note);
                view.noteText = "";
                view.currentScreen = view.SCREEN_CHECKIN;
                WatchUi.requestUpdate();
                return true;
            }
        } else if (view.currentScreen == view.SCREEN_SETTINGS) {
            if (keyCode == WatchUi.KEY_UP) {
                view.handleSettingsNav("up");
                WatchUi.requestUpdate();
                return true;
            } else if (keyCode == WatchUi.KEY_DOWN) {
                view.handleSettingsNav("down");
                WatchUi.requestUpdate();
                return true;
            } else if (keyCode == WatchUi.KEY_LEFT) {
                view.handleSettingsNav("left");
                WatchUi.requestUpdate();
                return true;
            } else if (keyCode == WatchUi.KEY_RIGHT) {
                view.handleSettingsNav("right");
                WatchUi.requestUpdate();
                return true;
            } else if (keyCode == WatchUi.KEY_ENTER) {
                view.handleSettingsAction();
                WatchUi.requestUpdate();
                return true;
            } else if (keyCode == WatchUi.KEY_ESC) {
                if (view.settingsEditing) {
                    view.settingsEditing = false;
                }
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