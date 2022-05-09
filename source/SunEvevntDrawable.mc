using Toybox.Lang;
using Toybox.Graphics;
using Toybox.Time;
using Toybox.System;
using Toybox.Position;
using Toybox.Time.Gregorian;

class SunEventsDrawable extends BasicDrawable{

	var image, imageX, sunriseX, sunsetX;
	var sunCalculator;
	
	function initialize(params as Lang.Dictonary){
		BasicDrawable.initialize(params);
		
		image = createImage(Rez.Drawables.sunEvent);
		var imageWidth = image.getDc().getWidth();
		imageX = locX + ((width - imageWidth)/2).toNumber();

		var offset = 8;
		sunriseX = imageX - offset;
		sunsetX = imageX + imageWidth + offset;
		sunCalculator = new SunCalc();
	}
	
	public function draw(dc as Graphics.Dc){
		
		dc.setClip(locX, locY, width, height);

		var center = getCenterForFont(fontMed);
		dc.setColor(foregroundColor() , Graphics.COLOR_TRANSPARENT);
		dc.drawBitmap(imageX, locY, image);
		
		
		var sunrise = "GPS";
		var sunset = "GPS";
		var sunriseMoment = null;
		var sunsetMoment = null;
		
		var geoLatLong = [Application.Storage.getValue("Lat"), Application.Storage.getValue("Lon")];
		if (geoLatLong != null){
			if (geoLatLong[0] != null && geoLatLong[1] != null){
				var myLocation = new Position.Location(
				    {
				        :latitude => geoLatLong[0],
				        :longitude => geoLatLong[1],
				        :format => :degrees
				    }
				).toRadians();
				var today = Time.today();
				sunriseMoment = sunCalculator.calculate(today, myLocation[0], myLocation[1], SUNRISE);
				sunsetMoment  = sunCalculator.calculate(today, myLocation[0], myLocation[1], SUNSET);
			}
		}
		
		if (sunriseMoment == null){
			sunrise = "N/A";
		}else{
			sunrise = momentToString(sunriseMoment);
		}
		if (sunsetMoment == null){
			sunset = "N/A";
		}else{
			sunset = momentToString(sunsetMoment);
		}

		
		dc.drawText(sunriseX, center[1], fontMed, sunrise, Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER);				
		dc.drawText(sunsetX, center[1], fontMed, sunset, Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);				
			
		drawBorder(dc);
	}
	
	function momentToString(moment){
		var info = Gregorian.info(moment,Time.FORMAT_SHORT);
		var hours = info.hour;
		var f = "%02d";
		if (!System.getDeviceSettings().is24Hour) {
			f = "%02d";
			if (hours > 12) {
				hours = hours - 12;
			}
		}
	
		return hours.format(f)+":"+info.min.format("%02d");
	}
}