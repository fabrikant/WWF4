using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.System;
using Toybox.Application;

class RightDrawable extends BasicDrawable{

	var imageBluetooth, imageMessage, imageDND, imageAlarm;
	
	function initialize(params as Lang.Dictonary) {
		BasicDrawable.initialize(params);
		imageBluetooth = null;
		imageMessage = null;
		imageDND = null;
		imageAlarm = null;
	}
	
	
	public function draw(dc as Graphics.Dc){

		var bkColor = backgroundColor();

		dc.setClip(locX, locY, width, height);
		dc.setColor(bkColor, bkColor);
		dc.clear();
		
		dc.setColor(foregroundColor(), Graphics.COLOR_TRANSPARENT);
		var showBt = false;
		var showAlarm = false;
		var showDND = false;
		var notifications = System.getDeviceSettings().notificationCount;
		var center = getCenter();
		
		var showBtProperty = Application.Properties.getValue("ShowBluetooth");
		var connected = System.getDeviceSettings().connectionAvailable;
		
		if ((showBtProperty == BLUETOOTH_SHOW_IF_CONNECT && connected) ||(showBtProperty == BLUETOOTH_SHOW_IF_DISCONNECT && !connected)){
			if (imageBluetooth == null){
				imageBluetooth = createImage(Rez.Drawables.Bluetooth);
			}
			showBt = true;
		}
		
		if (System.getDeviceSettings().alarmCount > 0){
			if (Application.Properties.getValue("ShowAlarm")){
				if (imageAlarm == null){
					imageAlarm = createImage(Rez.Drawables.Alarm);
				}
				showAlarm = true;
			}
		}

		if (System.getDeviceSettings().doNotDisturb){
			if (Application.Properties.getValue("ShowDND")){
				if (imageDND == null){
					imageDND = createImage(Rez.Drawables.DND);
				}
				showDND = true;
			}
		}
		
		var top = center[1];
		var bottom = center[1];
		var x = locX + 5;
		
		if (notifications > 0){
			if (imageMessage == null){
				imageMessage = createImage(Rez.Drawables.Message);
			}
			
			top -= imageMessage.getDc().getHeight();
			dc.drawBitmap(x, top, imageMessage);
			dc.drawText(x, bottom, fontSmall, notifications, Graphics.TEXT_JUSTIFY_LEFT);
			bottom += dc.getFontHeight(fontSmall);	
		}
		
		if (showBt){
			top -= imageBluetooth.getDc().getHeight();
			dc.drawBitmap(x, top, imageBluetooth);
		}
		if(showDND){
			dc.drawBitmap(x, bottom, imageDND);
			bottom += imageDND.getDc().getHeight();
		}
		if(showAlarm){
			dc.drawBitmap(x, bottom, imageAlarm);
		}
		drawBorder(dc);
	}
	
}