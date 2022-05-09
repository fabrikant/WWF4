using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.System;
using Toybox.Lang;
using Toybox.Math;

class TopDrawable extends BasicDrawable{

	function initialize(params as Lang.Dictonary) {
		BasicDrawable.initialize(params);
	}
	
	public function draw(dc as Graphics.Dc){

		var bkColor = backgroundColor();
		var fColor = foregroundColor();

		dc.setClip(locX, locY, width, height);
		dc.setColor(bkColor, bkColor);
		dc.clear();

		dc.setPenWidth(1);
		dc.setColor(fColor, Graphics.COLOR_TRANSPARENT);
		var value = Math.round(System.getSystemStats().battery);
		var k = 0.45;
		
		var hBattery = height*k;
		var wBattery = width/4*k;
		var yOffset = 3;
		var xOffset = -wBattery;
		
		//Внешний контур
		//[x,y,width,height]
		var external = [locX + (width - wBattery)/2+xOffset, locY + (height - hBattery)/2 + yOffset, wBattery, hBattery];
		dc.drawRectangle(external[0], external[1], external[2], external[3]);
		var hContact = external[3]*0.6;
		var wContact = external[2];
		dc.fillRoundedRectangle(external[0]+3, external[1] + (external[3]-hContact)/2-1, wContact, hContact, 3);
		dc.setColor(bkColor, Graphics.COLOR_TRANSPARENT);
		dc.fillRectangle(external[0]+1, external[1]+1, external[2]-2, external[3]-2);
		
		if (value > 20){
			dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_TRANSPARENT);
		}else{
			dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
		}

		var inner = [external[0]+2,external[1]+2,external[2]-4,external[3]-4];
		dc.fillRectangle(inner[0], inner[1], inner[2]*value/100, inner[3]);

		var center = getCenterForFont(fontSmall);
		dc.setColor(fColor, Graphics.COLOR_TRANSPARENT);
		dc.drawText(locX+ width/2, center[1], fontSmall, value.format("%d")+"%", Graphics.TEXT_JUSTIFY_LEFT |Graphics.TEXT_JUSTIFY_VCENTER);
		
		
		drawBorder(dc);
	}
	
}