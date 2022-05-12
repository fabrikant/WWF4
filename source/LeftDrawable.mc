using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.System;
using Toybox.Application;

class LeftDrawable extends BasicDrawable{

	var drawScale;
	
	function initialize(params as Lang.Dictonary) {
		BasicDrawable.initialize(params);
		onSettingsChanged();
		Application.getApp().mView.registerNotifyOnSettingsChanged(identifier);
	}
	
	public function onSettingsChanged(){
		drawScale = Application.Properties.getValue("ShowBatteryScale");
	}	
	
	public function draw(dc as Graphics.Dc){
		beforeDraw(dc as Graphics.Dc);
		
		drawBattery(dc);
		drawAmPm(dc);
		drawBorder(dc);
	}
	
	function drawAmPm(dc){
		
		if (!System.getDeviceSettings().is24Hour) {
			var center = getCenterForFont(fontSmall);
			var now = Time.Gregorian.info(Time.now(), Time.FORMAT_SHORT);
        	var value = now.hour > 11 ? "P" : "A";
        	dc.setColor(foregroundColor(), Graphics.COLOR_TRANSPARENT);
			dc.drawText(locX+width-5, center[1]- Graphics.getFontAscent(fontSmall), fontSmall, value, Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER);
		}
		
	}
	
	function drawBattery(dc){
		
		if (!drawScale){
			return;
		}
		var value = Math.round(System.getSystemStats().battery);
		var bkColor = backgroundColor();
		var fColor = foregroundColor();
		var scaleWidth = 6;
		var r = (dc.getWidth()/2).toNumber();
		var batHeight  = (height*3/4).toNumber();
		var fullHeight = (batHeight*value/100).toNumber();
		var y = ((height-batHeight)/2).toNumber();
		var yFull = locY+y+batHeight-fullHeight;

		if (value > 20){
			dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_TRANSPARENT);
		}else{
			dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
		}
		dc.setPenWidth(1);
		dc.fillRectangle(0, yFull, width, fullHeight);
		dc.setColor(fColor, fColor);
		dc.drawRectangle(0, yFull, width, fullHeight);
		dc.drawRectangle(locX, locY+y-1, width, batHeight+1);
		dc.setColor(bkColor, bkColor);
		dc.fillCircle(r, r, r-scaleWidth);
		dc.setColor(fColor, fColor);
		dc.drawCircle(r, r, r-scaleWidth);
		dc.drawCircle(r, r, r);
		dc.setColor(bkColor, bkColor);
		dc.fillRectangle(locX, locY, width, y-1);		
		dc.fillRectangle(locX, locY+y+batHeight, width, height);
		
	}
	
}