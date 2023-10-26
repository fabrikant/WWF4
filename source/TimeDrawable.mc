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
		var time = Global.momentToString(Time.now());
		dc.setColor(foregroundColor() , Graphics.COLOR_TRANSPARENT);
		dc.drawText(center[0], center[1], fontBig, time, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
		
		if (Application.Properties.getValue("DecorateHours")){
			var time_w  = dc.getTextWidthInPixels(time, fontBig);
			var col_pos = time.find(":");
			var hours_w = dc.getTextWidthInPixels(time.substring(0, col_pos), fontBig);
			var x_left = center[0]-time_w/2;
			var interval = hours_w / 10;
			dc.setClip(x_left, locY, hours_w, height);
			dc.setColor(backgroundColor(), Graphics.COLOR_TRANSPARENT);
			dc.setPenWidth(1);
			for (var offset = hours_w+2*interval; offset > 0; offset -= interval){
				dc.drawLine(x_left, locY+height-offset, x_left+offset, locY+height);
			}
			dc.setClip(locX, locY, width, height);
		}
		drawBorder(dc);
	}
}