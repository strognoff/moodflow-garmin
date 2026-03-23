import Toybox.WatchUi;
import Toybox.Graphics;
import Toybox.Lang;

//! Trend screen showing 7-day mood graph
module TrendScreen {
    
    const COLOR_WARM_GREY = 0xECEFF1;
    const COLOR_DARK_GREY = 0x37474F;
    
    function draw(dc as Dc, app as MoodFlowApp, bezelClearance as Number, isRoundDisplay as Boolean) as Void {
        var width = dc.getWidth();
        var height = dc.getHeight();
        var centerX = width / 2;
        
        dc.setColor(COLOR_WARM_GREY, COLOR_WARM_GREY);
        dc.clear();
        
        dc.setColor(COLOR_DARK_GREY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX, bezelClearance + 2, Graphics.FONT_XTINY, "7-Day Trend", Graphics.TEXT_JUSTIFY_CENTER);
        
        drawChart(dc, app, width, height, bezelClearance, isRoundDisplay);
        drawActivityData(dc, app, width, height, bezelClearance, isRoundDisplay, centerX);
    }
    
    function drawChart(dc as Dc, app as MoodFlowApp, width as Number, height as Number, bezelClearance as Number, isRoundDisplay as Boolean) as Void {
        var effectiveBezel = bezelClearance + (isRoundDisplay ? 8 : 0);
        var chartL = effectiveBezel + 20;
        var chartR = width - effectiveBezel - 8;
        var chartH = (height * 0.30).toNumber();
        var centerY = height / 2;
        var chartT = centerY - (chartH / 2) - 15;
        var chartB = chartT + chartH;
        var chartW = chartR - chartL;
        
        // Grid and Y-axis
        dc.setColor(0xBDBDBD, Graphics.COLOR_TRANSPARENT);
        for (var level = 1; level <= 5; level++) {
            var y = chartB - ((level - 1) * chartH / 4);
            dc.drawLine(chartL, y, chartR, y);
            dc.drawText(chartL - 3, y - 3, Graphics.FONT_XTINY, level.toString(), Graphics.TEXT_JUSTIFY_RIGHT);
        }
        
        // Data points - entries array has 7 elements (last 7 days)
        var entries = app.getLast7DaysEntries();
        var points = [];
        var labels = [];
        var dayLabels = ["S", "M", "T", "W", "T", "F", "S"];
        
        // Calculate day of week for each of the last 7 days
        var now = Toybox.Time.now();
        for (var i = 6; i >= 0; i--) {
            var dayMoment = now.subtract(new Toybox.Time.Duration(i * 86400));
            var dayInfo = Toybox.Time.Gregorian.info(dayMoment, Toybox.Time.FORMAT_SHORT);
            var dayOfWeek = dayInfo.day_of_week;
            labels.add(dayLabels[dayOfWeek - 1]);
            
            // Get mood for this day (default to 3 if no entry)
            var entry = entries[6 - i];
            if (entry != null) {
                points.add(entry.mood);
            } else {
                points.add(3);
            }
        }
        
        // Draw line
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
        
        // Draw points
        for (var i = 0; i < points.size(); i++) {
            var x = chartL + (i * chartW / 6);
            var y = chartB - ((points[i] - 1) * chartH / 4);
            dc.setColor(0x2196F3, Graphics.COLOR_TRANSPARENT);
            dc.fillCircle(x, y, 5);
            dc.setColor(COLOR_WARM_GREY, Graphics.COLOR_TRANSPARENT);
            dc.fillCircle(x, y, 2);
        }
        
        // Vertical grid and labels
        for (var i = 0; i < 7; i++) {
            var x = chartL + (i * chartW / 6);
            dc.setColor(0xE0E0E0, Graphics.COLOR_TRANSPARENT);
            dc.drawLine(x, chartT, x, chartB);
            dc.setColor(COLOR_DARK_GREY, Graphics.COLOR_TRANSPARENT);
            dc.drawText(x, chartB + 1, Graphics.FONT_XTINY, labels[i], Graphics.TEXT_JUSTIFY_CENTER);
        }
    }
    
    function drawActivityData(dc as Dc, app as MoodFlowApp, width as Number, height as Number, bezelClearance as Number, isRoundDisplay as Boolean, centerX as Number) as Void {
        var effectiveBezel = bezelClearance + (isRoundDisplay ? 8 : 0);
        var chartH = (height * 0.30).toNumber();
        var centerY = height / 2;
        var chartT = centerY - (chartH / 2) - 15;
        var chartB = chartT + chartH;
        var dataY = chartB + 35;
        
        var sleepData = app.getSleepData();
        var activityData = app.getActivityData();
        
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
}
