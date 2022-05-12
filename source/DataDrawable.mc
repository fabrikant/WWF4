using Toybox.Application;
using Toybox.Graphics;
using Toybox.Time;
using Toybox.System;
using Toybox.ActivityMonitor;
using Toybox.Activity;

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
			
		var value = getValue(dataType);
		if (value == null){
			value = "N/A";
		}
		
		loadImage();
		//draw field
		var offset = 5;
		if (image != null){
			var imageHeight = image.getDc().getHeight();
			var yOffset = imageHeight >= height ? 0 : ((height - imageHeight)/2).toNumber();
			dc.drawBitmap(locX+offset, locY+yOffset, image);
			offset += image.getDc().getWidth();
		}
		var center = getCenterForFont(fontMed);
		dc.drawText(locX+offset, center[1], fontMed, value, Graphics.TEXT_JUSTIFY_LEFT|Graphics.TEXT_JUSTIFY_VCENTER);
		
		drawBorder(dc);
	}
	
	function loadImage(){
		if (image == null){
			var res = findRes(dataType);
			if (res != null){
				image = createImage(res);
			}
		}
	}
	
	//*************************************************************************
	//GET DATA
	
	function getValue(dataType){
		var value=null;
		if (dataType == CALORIES){
			value = getCalories();
		}else if (dataType == DISTANCE){
			value = getDistance();
		}else if (dataType == STEPS){
			value = getSteps();
		}else if (dataType == FLOOR){
			value = getFloor();
		}else if (dataType == O2){
			value = getOxygenSaturation();
		}else if (dataType == ELEVATION){
			value = getElevation();
		}
		return value;
	}
	
	function getElevation(){

		var value = null;

		var info = Activity.getActivityInfo();
		if (info != null){
			if (info has :altitude){
				if (info.altitude != null){
					value = Global.elevationToString(info.altitude);
				}
			}
		}
		return value;
	}
	
	function getOxygenSaturation(){
	
		var value = null;
		var info = Activity.getActivityInfo();
		var postfix = "";
		if (info != null){
			if (info has :currentOxygenSaturation){
				if (info.currentOxygenSaturation != null){
					value = info.currentOxygenSaturation;
				}
			}
		}
		
		if (value != null){
			return value + "%";
		}
		return value;
		
	}	
	
	function getFloor(){
		var value = null;
		var info = ActivityMonitor.getInfo();
		if (info has :floorsClimbed){
			value = info.floorsClimbed.toString()
				+"|"+info.floorsDescended.toString();
		}
		return value;
	}
		
	function getSteps(){
		var value = null;
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
		var value = null;
		var info = ActivityMonitor.getInfo();
		if (info has :calories){
			value = info.calories;
		}
		return value;
	}

	function getDistance(){
		var value = null;
		var info = ActivityMonitor.getInfo();
		if (info has :distance){
			value = Global.distanceToString(info.distance);
		}
		return value;
	}
	
	
	function findRes(dataType){
		var ref = {
			CALORIES => Rez.Drawables.Callory,
			DISTANCE => Rez.Drawables.Distance,
			STEPS => Rez.Drawables.Steps,
			FLOOR => Rez.Drawables.Floor,
			ELEVATION => Rez.Drawables.Elevation,
			O2 => Rez.Drawables.O2,
		};
		return ref[dataType];
	}
	
	
}