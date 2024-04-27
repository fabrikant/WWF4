import Toybox.WatchUi;
import Toybox.Graphics;
import Toybox.System;
import Toybox.Application;
import Toybox.Lang;

class LeftDrawable extends BasicDrawable {
  var drawScale, showAmPm;

  function initialize(params as Lang.Dictonary) {
    BasicDrawable.initialize(params);
    onSettingsChanged();
    Application.getApp().mView.registerNotifyOnSettingsChanged(identifier);
  }

  public function onSettingsChanged() {
    drawScale = Application.Properties.getValue("SBat");
    showAmPm = Application.Properties.getValue("ShowAmPm");
  }

  public function draw(dc as Graphics.Dc) {
    beforeDraw(dc as Graphics.Dc);
    if (drawScale) {
      drawBattery(dc);
    }
    if (showAmPm) {
      drawAmPm(dc);
    }
    drawBorder(dc);
  }

  function drawAmPm(dc) {
    if (!System.getDeviceSettings().is24Hour && showAmPm) {
      var center = getCenterForFont(fontSmall);
      var now = Time.Gregorian.info(Time.now(), Time.FORMAT_SHORT);
      var value = now.hour > 11 ? "P" : "A";
      var xOfset = dc.getTextWidthInPixels("M", fontSmall) - 2;
      dc.setColor(foregroundColor(), Graphics.COLOR_TRANSPARENT);
      dc.drawText(
        locX + width - xOfset,
        center[1] - Graphics.getFontAscent(fontSmall) / 2,
        fontSmall,
        value,
        Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
      );
      dc.drawText(
        locX + width - xOfset,
        center[1] + Graphics.getFontAscent(fontSmall) / 2,
        fontSmall,
        "M",
        Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
      );
    }
  }

  function drawBattery(dc) {
    var value = Math.round(System.getSystemStats().battery);
    var penWidth = 9;
    var interval = 30;
    var bColor = backgroundColor();
    var fColor = foregroundColor();
    var degreeHighLevel = 180 - interval;
    var degreeLowLevel = 180 + interval;
    var xCenter = dc.getWidth() / 2;
    var yCenter = dc.getHeight() / 2;
    var r = xCenter.toNumber() - (penWidth / 2).toNumber();

    dc.setColor(fColor, fColor);
    dc.setPenWidth(penWidth);
    dc.drawArc(
      xCenter,
      yCenter,
      r,
      Graphics.ARC_COUNTER_CLOCKWISE,
      degreeHighLevel - 1,
      degreeLowLevel + 1
    );
    penWidth -= 2;

    dc.setColor(bColor, bColor);
    dc.setPenWidth(penWidth);
    dc.drawArc(
      xCenter,
      yCenter,
      r,
      Graphics.ARC_COUNTER_CLOCKWISE,
      degreeHighLevel,
      degreeLowLevel
    );

    if (value > 20) {
      dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_TRANSPARENT);
    } else {
      dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
    }
    dc.setPenWidth(penWidth);

    var degreeCurrentLevel =
      degreeLowLevel + ((degreeHighLevel - degreeLowLevel) * value) / 100;
    dc.drawArc(
      xCenter,
      yCenter,
      r,
      Graphics.ARC_CLOCKWISE,
      degreeLowLevel,
      degreeCurrentLevel
    );

    if (System.getDeviceSettings().is24Hour || !showAmPm) {
      dc.setColor(fColor, Graphics.COLOR_TRANSPARENT);
      var fontHight = Graphics.getFontAscent(fontSmall);
      var charArray = (value.format("%d") + "%").toCharArray();
      var yCurrent =
        yCenter - fontHight * (charArray.size() / 2).toNumber() + 5;
      var xCurrent = locX + width - dc.getTextWidthInPixels("%", fontSmall) + 2;
      for (var i = 0; i < charArray.size(); i++) {
        dc.drawText(
          xCurrent,
          yCurrent,
          fontSmall,
          charArray[i],
          Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );
        yCurrent += fontHight;
      }
    }
  }
}
