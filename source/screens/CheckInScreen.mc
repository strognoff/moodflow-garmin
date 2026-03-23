import Toybox.WatchUi;
import Toybox.Graphics;
import Toybox.Lang;

//! Check-in screen for mood selection
module CheckInScreen {
    
    const COLOR_SOFT_BLUE = 0x90CAF9;
    const COLOR_WARM_GREY = 0xECEFF1;
    const COLOR_DARK_GREY = 0x37474F;
    const COLOR_SOFT_LAVENDER = 0xCE93D8;
    
    function draw(dc as Dc, app as MoodFlowApp, selectedMoodIndex as Number, bezelClearance as Number, showingConfirmDialog as Boolean) as Void {
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
                dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_WHITE);
                dc.fillCircle(x, moodY, circleR);
                
                dc.setColor(moodColors[i], Graphics.COLOR_TRANSPARENT);
                dc.setPenWidth(4);
                dc.drawCircle(x, moodY, circleR + 3);
                dc.setPenWidth(1);
            } else {
                dc.setColor(moodColors[i], moodColors[i]);
                dc.fillCircle(x, moodY, circleR);
            }
            
            dc.setColor(COLOR_DARK_GREY, Graphics.COLOR_TRANSPARENT);
            dc.drawText(x, moodY + circleR + 4, Graphics.FONT_XTINY, (i + 1).toString(), Graphics.TEXT_JUSTIFY_CENTER);
        }
        
        // Selected mood label
        var mood = selectedMoodIndex + 1;
        dc.setColor(COLOR_DARK_GREY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX, moodY + circleR + 22, Graphics.FONT_MEDIUM, app.getMoodLabel(mood), Graphics.TEXT_JUSTIFY_CENTER);
        
        // Today's average
        var todayEntries = app.getTodayEntries();
        if (todayEntries.size() > 0) {
            var avg = app.getAverageMood(todayEntries);
            dc.setColor(0x757575, Graphics.COLOR_TRANSPARENT);
            dc.drawText(centerX, moodY + circleR + 55, Graphics.FONT_XTINY, "Today avg: " + app.getMoodLabel(avg), Graphics.TEXT_JUSTIFY_CENTER);
        }
        
        // Navigation arrows
        dc.setColor(COLOR_SOFT_LAVENDER, Graphics.COLOR_TRANSPARENT);
        dc.fillPolygon([[bezelClearance, centerY], [bezelClearance + 12, centerY - 8], [bezelClearance + 12, centerY + 8]]);
        dc.fillPolygon([[width - bezelClearance, centerY], [width - bezelClearance - 12, centerY - 8], [width - bezelClearance - 12, centerY + 8]]);
        
        // Footer with navigation hints
        dc.setColor(0x9E9E9E, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX, height - bezelClearance - 2, Graphics.FONT_XTINY, "< Graph  Stgs >", Graphics.TEXT_JUSTIFY_CENTER);
        
        if (showingConfirmDialog) {
            drawConfirmMoodDialog(dc, centerX, centerY, bezelClearance);
        }
    }
    
    function drawConfirmMoodDialog(dc as Dc, centerX as Number, centerY as Number, bezelClearance as Number) as Void {
        var width = dc.getWidth();
        
        dc.setColor(0x000000, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(0, 0, width, dc.getHeight());
        
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_WHITE);
        dc.fillRectangle(bezelClearance + 10, centerY - 40, width - 2 * (bezelClearance + 10), 80);
        dc.setColor(COLOR_DARK_GREY, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(2);
        dc.drawRectangle(bezelClearance + 10, centerY - 40, width - 2 * (bezelClearance + 10), 80);
        dc.setPenWidth(1);
        
        dc.setColor(COLOR_DARK_GREY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX, centerY - 25, Graphics.FONT_XTINY, "Replace today's", Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(centerX, centerY - 10, Graphics.FONT_XTINY, "mood?", Graphics.TEXT_JUSTIFY_CENTER);
        
        dc.setColor(0x9E9E9E, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX, centerY + 15, Graphics.FONT_XTINY, "UP:No DOWN:Yes", Graphics.TEXT_JUSTIFY_CENTER);
    }
}
