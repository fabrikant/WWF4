using Toybox.Application;
using Toybox.Graphics;
using Toybox.Time;
using Toybox.System;
using Toybox.ActivityMonitor;

class DataDrawable extends BasicDrawable{

	var image, dataType;
	
	function initialize(params as Lang.Dictonary){
		BasicDrawable.initialize(params);
		onSettingsChanged();
		Application.getApp().mView.registerNotifyOnSettingsChanged(identifier);
	}
	
	public function onSettingsChanged(){
		image = null;
		dataType = Application.Properties.getValue(identifier);
	}
	
	public function draw(dc as Graphics.Dc){
	
		var bkColor = backgroundColor();
		var fColor = foregroundColor();
		
		dc.setClip(locX, locY, width, height);
		dc.setColor(bkColor, bkColor);
		dc.fillRoundedRectangle(locX, locY, width, height, RADIUS_CORNER);
		dc.setColor(fColor, Graphics.COLOR_TRANSPARENT);
			
		//image
		if (image == null){
			var res = findRes(dataType);
			if (res != null){
				image = createImage(res);
			}
		}
		
		//data
		var offset = 5;
		if (image != null){
			dc.drawBitmap(locX+offset, locY, image);
			offset += image.getDc().getWidth();
		}
		
		var value="";
		if (dataType == CALORIES){
			value = getCalories();
		}else if (dataType == DISTANCE){
			value = getDistance();
		}else if (dataType == STEPS){
			value = getSteps();
		}
		
		var center = getCenterForFont(fontMed);
		dc.drawText(locX+offset, center[1], fontMed, value, Graphics.TEXT_JUSTIFY_LEFT|Graphics.TEXT_JUSTIFY_VCENTER);
		
		drawBorder(dc);
	}
	
	function getSteps(){
		var value = "";
		var info = ActivityMonitor.getInfo();
		if (info has :steps){
			value = info.steps;
			if (value > 99999){
				value = (value/1000).format("%d")+"k";
			}else if (value > 9999){
				value = (value.toFloat()/1000).format("%.1f")+"k";
			}
		}
		return value;
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
			STEPS => Rez.Drawables.Steps,
		};
		return ref[dataType];
	}
	
	
}