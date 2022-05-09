using Toybox.Lang;
using Toybox.Graphics;
using Toybox.Time;
using Toybox.System;

class TimeDrawable extends BasicDrawable{

	function initialize(params as Lang.Dictonary){
		if(params[:autocenter]){
			params[:locX] = ((System.getDeviceSettings().screenWidth - params[:width])/2).toNumber();
			params[:locY] = ((System.getDeviceSettings().screenHeight - params[:height])/2).toNumber();
			System.println("locX="+params[:locX]);
			System.println("locY="+params[:locY]);
		}
		BasicDrawable.initialize(params);
	}
	
	public function draw(dc as Graphics.Dc){

		dc.setClip(locX, locY, width, height);
		var center = getCenterForFont(fontBig);
		var now = Time.Gregorian.info(Time.now(), Time.FORMAT_SHORT);
		
        var hours = now.hour;
        var hourFormat = "%02d";
        if (!System.getDeviceSettings().is24Hour) {
        	hourFormat = "%d";
            if (hours > 12) {
                hours = hours - 12;
            }
        }
		var time = Lang.format("$1$:$2$", [hours.format(hourFormat), now.min.format("%02d")]);
		dc.setColor(foregroundColor() , Graphics.COLOR_TRANSPARENT);
		dc.drawText(center[0], center[1], fontBig, time, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
		
		drawBorder(dc);
	}
}