import Toybox.WatchUi;
import Toybox.Graphics;
import Toybox.Lang;

//! Main view for MoodFlow app
class MoodFlowView extends WatchUi.View {
    
    var moodFlowApp as MoodFlowApp;
    var moodLabel as String = "Neutral";
    
    //! Mood colors (gradient from red to green)
    var moodColors = [
        Graphics.COLOR_RED,      // 0 - Very Low
        Graphics.COLOR_ORANGE,   // 1 - Low
        Graphics.COLOR_YELLOW,   // 2 - Neutral
        Graphics.COLOR_GREEN,    // 3 - Good
        Graphics.COLOR_DK_GREEN  // 4 - Great
    ];
    
    //! Constructor
    function initialize(app as MoodFlowApp) {
        moodFlowApp = app;
        moodLabel = app.getMoodLabel(app.currentMood);
    }
    
    //! Called when this View is brought to the foreground
    function onShow() as Void {
        moodLabel = moodFlowApp.getMoodLabel(moodFlowApp.currentMood);
    }
    
    //! Called when this View is removed from the foreground
    function onHide() as Void {
    }
    
    //! Update the view
    function onUpdate(dc as Dc) as Void {
        // Clear the screen
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();
        
        var width = dc.getWidth();
        var height = dc.getHeight();
        var centerX = width / 2;
        var centerY = height / 2;
        
        // Get current mood color
        var moodColor = moodColors[moodFlowApp.currentMood];
        
        // Draw mood indicator circle
        var circleRadius = 50;
        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawCircle(centerX, centerY - 30, circleRadius);
        
        // Fill mood circle with mood color
        dc.setColor(moodColor, moodColor);
        dc.fillCircle(centerX, centerY - 30, circleRadius - 5);
        
        // Draw mood label
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX, centerY + 40, Graphics.FONT_MEDIUM, moodLabel, Graphics.TEXT_JUSTIFY_CENTER);
        
        // Draw instructions
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX, height - 30, Graphics.FONT_TINY, "UP/DOWN: Change mood", Graphics.TEXT_JUSTIFY_CENTER);
        
        // Draw average mood if available
        var avgMood = moodFlowApp.getAverageMood();
        if (moodFlowApp.todayMoods.size() > 0) {
            var avgLabel = "Avg: " + moodFlowApp.getMoodLabel(avgMood);
            dc.drawText(centerX, centerY + 70, Graphics.FONT_TINY, avgLabel, Graphics.TEXT_JUSTIFY_CENTER);
            
            // Draw entry count
            var countLabel = moodFlowApp.todayMoods.size() + " entries today";
            dc.drawText(centerX, centerY + 90, Graphics.FONT_TINY, countLabel, Graphics.TEXT_JUSTIFY_CENTER);
        }
    }
}
