using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.System;
using Toybox.Application;

class LeftDrawable extends BasicDrawable{

	var drawScale, showAmPm;
	
	function initialize(params as Lang.Dictonary) {
		BasicDrawable.initialize(params);
		onSettingsChanged();
		Application.getApp().mView.registerNotifyOnSettingsChanged(identifier);
	}
	
	public function onSettingsChanged(){
		drawScale = Application.Properties.getValue("ShowBatteryScale");
		showAmPm = Application.Properties.getValue("ShowAmPm");
	}	
	
	public function draw(dc as Graphics.Dc){
		beforeDraw(dc as Graphics.Dc);
		if (drawScale){
			drawBattery(dc);
		}
		if (showAmPm){ 
			drawAmPm(dc);
		}
		drawBorder(dc);
	}
	
	function drawAmPm(dc){
		if (!System.getDeviceSettings().is24Hour) {
			var center = getCenterForFont(fontSmall);
			var now = Time.Gregorian.info(Time.now(), Time.FORMAT_SHORT);
        	var value = now.hour > 11 ? "P" : "A";
        	var xOfset = dc.getTextWidthInPixels("M", fontSmall)-2;
        	dc.setColor(foregroundColor(), Graphics.COLOR_TRANSPARENT);
			dc.drawText(locX+width-xOfset, center[1]- Graphics.getFontAscent(fontSmall), fontSmall, value, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
			dc.drawText(locX+width-xOfset, center[1], fontSmall, "M", Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
		}
		
	}
	
	function drawBattery(dc){
		
		var value = Math.round(System.getSystemStats().battery);
		var bkColor = backgroundColor();
		var fColor = foregroundColor();
		var scaleWidth = width/4;
		var r = (dc.getWidth()/2).toNumber();
		var batHeight  = (height*3/4).toNumber();
		var fullHeight = (batHeight*value/100).toNumber();
		var y = ((height-batHeight)/2).toNumber();
		var yFull = locY+y+batHeight-fullHeight;

		if (value > 20){
			dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_TRANSPARENT);
		}else{
			dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
		}
		dc.setPenWidth(1);
		//цветной индикатор
		dc.fillRectangle(0, yFull, width, fullHeight);
		
		//Деления
		dc.setColor(fColor, fColor);
		//dc.setColor(accentColor(), Graphics.COLOR_TRANSPARENT);
		var div = batHeight/10;
		for (var i = 1; i<10; i++){
			var divY = locY+y+batHeight-i*div;
			if (divY < yFull){break;}
			dc.drawLine(locX, divY, locX+width, divY);
		}
		
		//Рамка индикатора
		dc.setColor(fColor, fColor);
		//dc.drawRectangle(0, yFull, width, fullHeight);
		dc.drawRectangle(locX, locY+y-1, width, batHeight+1);
		//Обрезка шкалы справа
		dc.setColor(bkColor, bkColor);
		dc.fillCircle(r, r, r-scaleWidth);
		//Правый контур шкалы
		dc.setColor(fColor, fColor);
		dc.drawCircle(r, r, r-scaleWidth);
		//Левый контур
		dc.drawCircle(r, r, r);
		//Убираем артефакты выше и ниже
		dc.setColor(bkColor, bkColor);
		dc.fillRectangle(locX, locY, width, y-1);		
		dc.fillRectangle(locX, locY+y+batHeight, width, height);
		
	}
	
}