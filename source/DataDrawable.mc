using Toybox.Application;
using Toybox.Graphics;
using Toybox.Time;
using Toybox.System;
using Toybox.ActivityMonitor;

class DataDrawable extends BasicDrawable{

	var image, imageX;
	
	function initialize(params as Lang.Dictonary){
		BasicDrawable.initialize(params);
		onSettingsChanged();
		Application.getApp().mView.registerNotifyOnSettingsChanged(identifier);
	}
	
	public function onSettingsChanged(){
		image = null;
	}
	
	public function draw(dc as Graphics.Dc){
	
		var bkColor = backgroundColor();
		var fColor = foregroundColor();
		
		dc.setClip(locX, locY, width, height);
		dc.setColor(bkColor, bkColor);
		dc.fillRoundedRectangle(locX, locY, width, height, RADIUS_CORNER);

		dc.setColor(fColor, Graphics.COLOR_TRANSPARENT);
		var dataType = Application.Properties.getValue(identifier);
		
		if (image == null){
			var res = findRes(dataType);
			if (res != null){
				image = createImage(res);
			}
		}
		
		var offset = 5;
		if (image == null){
			dc.drawBitmap(locX+offset, locY, image);
			offset += image.getDc().getWidth();
		}
		
		var value="";
		if (dataType == CALORIES){
			value = getCalories();
		}else if (dataType == DISTANCE){
			value = getDistance();
		}
		
		var center = getCenterForFont(fontMed);
		dc.drawText(locX+offset, center[1], fontMed, value, Graphics.TEXT_JUSTIFY_LEFT|Graphics.TEXT_JUSTIFY_VCENTER);
		drawBorder(dc);
	}
	
	function getCalories(){
		var value = "";
		var info = ActivityMonitor.getInfo();
		if (info has :calories){
			value = info.calories;
		}
		return value;
	}

	function getDistance(){
		var value = "";
		var info = ActivityMonitor.getInfo();
		if (info has :distance){
			value = Global.distanceToString(info.distance);
		}
		return value;
	}
	
	
	private function findRes(dataType){
		var ref = {
			CALORIES => Rez.Drawables.Callory,
			DISTANCE => Rez.Drawables.Distance,
		};
		return ref[dataType];
	}
	
	
}