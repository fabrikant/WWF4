using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.System;
using Toybox.Application;
using Toybox.Lang;

class RightDrawable extends BasicDrawable {
  var imageBluetooth, imageMessage, imageDND, imageAlarm;

  function initialize(params as Lang.Dictonary) {
    BasicDrawable.initialize(params);
    onSettingsChanged();
    Application.getApp().mView.registerNotifyOnSettingsChanged(identifier);
  }

  public function onSettingsChanged() {
    imageBluetooth = null;
    imageMessage = null;
    imageDND = null;
    imageAlarm = null;
  }

  public function draw(dc as Graphics.Dc) {
    var bkColor = backgroundColor();

    dc.setClip(locX, locY, width, height);
    dc.setColor(bkColor, bkColor);
    dc.clear();

    dc.setColor(foregroundColor(), Graphics.COLOR_TRANSPARENT);
    var showBt = false;
    var showAlarm = false;
    var showDND = false;
    var showMessages = false;
    var notifications = System.getDeviceSettings().notificationCount;
    var center = getCenter();

    var showBtProperty = Application.Properties.getValue("SBt");
    var connected = System.getDeviceSettings().connectionAvailable;
    var heightSum = 0;

    if (
      (showBtProperty == BLUETOOTH_SHOW_IF_CONNECT && connected) ||
      (showBtProperty == BLUETOOTH_SHOW_IF_DISCONNECT && !connected)
    ) {
      if (imageBluetooth == null) {
        imageBluetooth = createImage(Rez.Drawables.Bluetooth);
      }
      showBt = true;
      heightSum += imageBluetooth.getDc().getHeight();
    }

    if (System.getDeviceSettings().alarmCount > 0) {
      if (Application.Properties.getValue("SAl")) {
        if (imageAlarm == null) {
          imageAlarm = createImage(Rez.Drawables.Alarm);
        }
        showAlarm = true;
        heightSum += imageAlarm.getDc().getHeight();
      }
    }

    if (System.getDeviceSettings().doNotDisturb) {
      if (Application.Properties.getValue("ShowDND")) {
        if (imageDND == null) {
          imageDND = createImage(Rez.Drawables.DND);
        }
        showDND = true;
        heightSum += imageDND.getDc().getHeight();
      }
    }

    var x = locX + 5;

    if (notifications > 0) {
      if (imageMessage == null) {
        imageMessage = createImage(Rez.Drawables.Message);
      }
      showMessages = true;
      heightSum += imageMessage.getDc().getHeight();
      heightSum += dc.getFontHeight(fontSmall);
    }

    var top = center[1] - heightSum / 2;

    if (showBt) {
      dc.drawBitmap(x, top, imageBluetooth);
      top += imageBluetooth.getDc().getHeight();
    }

    if (showMessages) {
      dc.drawBitmap(x, top, imageMessage);
      top += imageMessage.getDc().getHeight();
      var localY =
        top - (dc.getFontHeight(fontSmall) - dc.getFontAscent(fontSmall)) / 2;
      if (notifications > 9) {
        dc.drawText(
          x,
          localY,
          fontSmall,
          notifications,
          Graphics.TEXT_JUSTIFY_LEFT
        );
      } else {
        dc.drawText(
          x + (imageMessage.getDc().getWidth() / 2).toNumber(),
          localY,
          fontSmall,
          notifications,
          Graphics.TEXT_JUSTIFY_CENTER
        );
      }
      top += dc.getFontHeight(fontSmall);
    }

    if (showDND) {
      dc.drawBitmap(x, top, imageDND);
      top += imageDND.getDc().getHeight();
    }
    if (showAlarm) {
      dc.drawBitmap(x, top, imageAlarm);
    }
    drawBorder(dc);
  }
}
