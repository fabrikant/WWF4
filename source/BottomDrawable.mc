using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.System;
using Toybox.Application;
using Toybox.Time;
using Toybox.Time.Gregorian;

class BottomDrawable extends BasicDrawable{
	
	var showField;
	
	function initialize(params as Lang.Dictonary) {
		BasicDrawable.initialize(params);
		onSettingsChanged();
		Application.getApp().mView.registerNotifyOnSettingsChanged(identifier);
	}
	
	public function onSettingsChanged(){
		showField = Application.Properties.getValue("ShowDate");
	}
	
	public function draw(dc as Graphics.Dc){
		dc.setClip(locX, locY, width, height);
		var bkColor = backgroundColor();
		dc.setColor(bkColor, bkColor);
		dc.clear();
		
		if (showField){
			dc.setColor(foregroundColor(), Graphics.COLOR_TRANSPARENT);
			var now = Time.Gregorian.info(Time.now(), Time.FORMAT_LONG);
			var center = getCenterForFont(fontSmall);
			var value = now.day_of_week+", "+now.day+" "+now.month;
			dc.drawText(center[0], center[1], fontSmall, value, Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
		}
		drawBorder(dc);
	}
	
}