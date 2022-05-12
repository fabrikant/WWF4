using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.System;
using Toybox.Application;

class LeftDrawable extends BasicDrawable{

	
	function initialize(params as Lang.Dictonary) {
		BasicDrawable.initialize(params);
		onSettingsChanged();
		Application.getApp().mView.registerNotifyOnSettingsChanged(identifier);
	}
	
	public function onSettingsChanged(){
	}	
	
	public function draw(dc as Graphics.Dc){
		beforeDraw(dc as Graphics.Dc);
		
		drawBattery(dc);
		drawBorder(dc);
	}
	
	function drawBattery(dc){
		
		var value = Math.round(System.getSystemStats().battery);
		var bkColor = backgroundColor();
		var fColor = foregroundColor();
		var scaleWidth = 7;
		var r = (dc.getWidth()/2).toNumber();
		var batHeight  = (height*2/3).toNumber();
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