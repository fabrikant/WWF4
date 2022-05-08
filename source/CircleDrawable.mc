using Toybox.Lang;
using Toybox.Graphics;
using Toybox.Time;
using Toybox.System;
using Toybox.Application;
using Toybox.Activity;

class CircleDrawable extends BasicDrawable{
	
	var image, imageEmpty, imageX, imageY, textY;
	
	function initialize(params as Lang.Dictonary){
		BasicDrawable.initialize(params);
		
		image = Application.loadResource(Rez.Drawables.heart);
		imageEmpty = Application.loadResource(Rez.Drawables.heartEmpty);
		
		imageX = locX + ((width - image.getWidth())/2).toNumber();
		imageY = locY + ((height/2 - image.getHeight())/2).toNumber()+3;
		
		var center = getCenter();
		var fontCenter = getCenterForFont(fontMed);
		var offsetY = fontCenter[1] - center[1];
		textY = fontCenter[1] + (height/4).toNumber()-5;
	}
	
	public function draw(dc as Graphics.Dc){

		dc.setClip(locX, locY, width, height);
		dc.setAntiAlias(true);
		dc.setPenWidth(4);
		dc.setColor(Global.getBackgroundColor(), Graphics.COLOR_TRANSPARENT);
		
		var center = getCenter();
		var r = width/2.toNumber()-2;
		dc.fillCircle(center[0], center[1], r);
		
		var now = Time.Gregorian.info(Time.now(), Time.FORMAT_SHORT);
		
		if (now.min % 2 == 0){
			dc.setColor(Graphics.COLOR_DK_GREEN, Graphics.COLOR_TRANSPARENT);
			dc.drawCircle(center[0], center[1], r);
			dc.setColor(Graphics.COLOR_PURPLE, Graphics.COLOR_TRANSPARENT);
		}else{
			dc.setColor(Graphics.COLOR_PURPLE, Graphics.COLOR_TRANSPARENT);
			dc.drawCircle(center[0], center[1], r);
			dc.setColor(Graphics.COLOR_DK_GREEN, Graphics.COLOR_TRANSPARENT);
		}
		
		var degreeEnd = 90-6*now.sec;
		if (now.sec != 0){
			dc.drawArc(center[0], center[1], r, Graphics.ARC_CLOCKWISE, 90, degreeEnd);
		}
		
				
		var value = null;
		var info = Activity.getActivityInfo();
		if (info != null){
			if (info has :currentHeartRate){
				value = info.currentHeartRate;
			}
		}
		
		if (value != null){
			if (now.sec%2==0){
				dc.drawBitmap(imageX, imageY, image);
			}else{
				dc.drawBitmap(imageX, imageY, imageEmpty);
			}
			dc.setColor(Global.getForegraundColor(), Graphics.COLOR_TRANSPARENT);
			dc.drawText(center[0], textY, fontMed, value, Graphics.TEXT_JUSTIFY_CENTER| Graphics.TEXT_JUSTIFY_VCENTER);
		}else{
			dc.drawBitmap(imageX, imageY, image);
			dc.setColor(Global.getForegraundColor(), Graphics.COLOR_TRANSPARENT);
			dc.drawText(center[0], textY, fontMed, "n/a", Graphics.TEXT_JUSTIFY_CENTER| Graphics.TEXT_JUSTIFY_VCENTER);
		}
		
		
		drawBorder(dc);
	}


}