using Toybox.Application;
using Toybox.Graphics;
using Toybox.Time;
using Toybox.System;
using Toybox.ActivityMonitor;

class DataDrawable extends BasicDrawable{

	var oldType;
	var image, imageX;
	
	function initialize(params as Lang.Dictonary){
		BasicDrawable.initialize(params);
		oldType = null;
		image = null;
	}
	
	public function draw(dc as Graphics.Dc){
		
		dc.setClip(locX, locY, width, height);
		dc.setColor(Global.getBackgroundColor(), Global.getBackgroundColor());
		dc.fillRoundedRectangle(locX, locY, width, height, RADIUS_CORNER);
		dc.setColor(Global.getForegraundColor(), Graphics.COLOR_TRANSPARENT);
		
		var dataType = Application.Properties.getValue(identifier);
		
		if (oldType == null || oldType != dataType || image == null){
			var res = loadImage(dataType);
			if (res != null){
				image = Application.loadResource(res);
			}
		}
		oldType = dataType;
		
		var offset = 5;
		dc.drawBitmap(locX+offset, locY, image);
		offset += offset + image.getWidth();
		
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
	
	
	private function loadImage(dataType){
		var ref = {
			CALORIES => Rez.Drawables.Callory,
			DISTANCE => Rez.Drawables.Distance,
		};
		return ref[dataType];
	}
	
	
}