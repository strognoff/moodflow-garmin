import Toybox.WatchUi;
import Toybox.Graphics;
import Toybox.Lang;

//! Settings screen
module SettingsScreen {
    
    const COLOR_SOFT_BLUE = 0x90CAF9;
    const COLOR_WARM_GREY = 0xECEFF1;
    const COLOR_DARK_GREY = 0x37474F;
    
    function draw(dc as Dc, bezelClearance as Number, showingConfirmDialog as Boolean) as Void {
        var width = dc.getWidth();
        var height = dc.getHeight();
        var centerX = width / 2;
        var centerY = height / 2;
        
        dc.setColor(COLOR_WARM_GREY, COLOR_WARM_GREY);
        dc.clear();
        
        if (showingConfirmDialog) {
            drawConfirmDialog(dc, centerX, centerY, width, height, bezelClearance);
            return;
        }
        
        // Header
        dc.setColor(COLOR_SOFT_BLUE, COLOR_SOFT_BLUE);
        dc.fillRectangle(0, 0, width, (height * 0.15).toNumber());
        
        dc.setColor(COLOR_DARK_GREY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX, bezelClearance + 15, Graphics.FONT_TINY, "Settings", Graphics.TEXT_JUSTIFY_CENTER);
        
        // Reset button
        var btnW = width - 2 * (bezelClearance + 20);
        var btnH = 60;
        var btnX = centerX - (btnW / 2);
        var btnY = centerY - (btnH / 2);
        
        dc.setColor(0xFFCDD2, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(btnX, btnY, btnW, btnH);
        
        dc.setColor(0xE57373, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(3);
        dc.drawRectangle(btnX, btnY, btnW, btnH);
        dc.setPenWidth(1);
        
        dc.setColor(0xC62828, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX, btnY + 12, Graphics.FONT_SMALL, "Reset All Data", Graphics.TEXT_JUSTIFY_CENTER);
        dc.setColor(0x757575, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX, btnY + 35, Graphics.FONT_XTINY, "Clear all moods", Graphics.TEXT_JUSTIFY_CENTER);
        
        // Bottom hints
        dc.setColor(0x9E9E9E, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX, height - bezelClearance - 15, Graphics.FONT_XTINY, "ENTER to reset", Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(centerX, height - bezelClearance - 2, Graphics.FONT_XTINY, "BACK to exit", Graphics.TEXT_JUSTIFY_CENTER);
    }
    
    function drawConfirmDialog(dc as Dc, centerX as Number, centerY as Number, width as Number, height as Number, bezelClearance as Number) as Void {
        dc.setColor(0x000000, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(0, 0, width, height);
        
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
        
        dc.setColor(0xC62828, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX, dialogY + 10, Graphics.FONT_SMALL, "Reset All Data?", Graphics.TEXT_JUSTIFY_CENTER);
        dc.setColor(0xE57373, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX, dialogY + 28, Graphics.FONT_XTINY, "This will delete all", Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(centerX, dialogY + 42, Graphics.FONT_XTINY, "mood entries!", Graphics.TEXT_JUSTIFY_CENTER);
        
        dc.setColor(0x9E9E9E, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX, dialogY + dialogH - 18, Graphics.FONT_XTINY, "UP:No  DOWN:Yes", Graphics.TEXT_JUSTIFY_CENTER);
    }
}
