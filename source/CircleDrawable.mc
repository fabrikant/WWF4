import Toybox.Lang;
import Toybox.Graphics;
import Toybox.Time;
import Toybox.System;
import Toybox.Application;
import Toybox.Activity;

class CircleDrawable extends BasicDrawable {
  var image, imageEmpty, imageX, imageY, textX, textY;
  var invertColor, fieldType;
  var bkColor, fColor;

  function initialize(params as Lang.Dictonary) {
    BasicDrawable.initialize(params);
    onSettingsChanged();
  }

  public function onSettingsChanged() {
    fieldType = Application.Properties.getValue("Circle");
    invertColor = Application.Properties.getValue("InvertCircle");

    bkColor = backgroundColor();
    fColor = foregroundColor();

    if (invertColor) {
      bkColor = ~bkColor & 0x00ffffff;
      fColor = ~fColor & 0x00ffffff;
    }

    image = null;
    imageEmpty = null;
    imageX = null;
    imageY = null;

    var fontCenter = getCenterForFont(fontMed);
    textX = fontCenter[0];

    if (fieldType == CIRCLE_TYPE_HR) {
      image = Application.loadResource(Rez.Drawables.heart);
      imageEmpty = Application.loadResource(Rez.Drawables.heartEmpty);

      imageX = locX + ((width - image.getWidth()) / 2).toNumber();
      imageY = locY + ((height / 2 - image.getHeight()) / 2).toNumber() + 3;
      textY = fontCenter[1] + (height / 4).toNumber() - 9;
    } else if (fieldType == CIRCLE_TYPE_SECONDS) {
      textY = fontCenter[1];
    }
  }

  public function draw(dc as Graphics.Dc) {
    dc.setClip(locX, locY, width, height);
    if (Application.getApp().mView.isAmoledSaveMode) {
      dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
      dc.clearClip();
      return;
    }

    if (Graphics.Dc has :setAntiAlias) {
      dc.setAntiAlias(true);
    }
    var penWidth = 7;
    dc.setPenWidth(penWidth);

    dc.setColor(bkColor, Graphics.COLOR_TRANSPARENT);

    var center = getCenter();
    var r = width / (2).toNumber() - (penWidth / 2).toNumber() - 1;
    dc.fillCircle(center[0], center[1], r);

    var now = Time.Gregorian.info(Time.now(), Time.FORMAT_SHORT);

    if (now.min % 2 == 0) {
      dc.setColor(Graphics.COLOR_DK_GREEN, Graphics.COLOR_TRANSPARENT);
      dc.drawCircle(center[0], center[1], r);
      dc.setColor(Graphics.COLOR_PURPLE, Graphics.COLOR_TRANSPARENT);
    } else {
      dc.setColor(Graphics.COLOR_PURPLE, Graphics.COLOR_TRANSPARENT);
      dc.drawCircle(center[0], center[1], r);
      dc.setColor(Graphics.COLOR_DK_GREEN, Graphics.COLOR_TRANSPARENT);
    }

    var degreeEnd = 90 - 6 * now.sec;
    if (now.sec != 0) {
      dc.drawArc(
        center[0],
        center[1],
        r,
        Graphics.ARC_CLOCKWISE,
        90,
        degreeEnd
      );
    }

    dc.setColor(fColor, Graphics.COLOR_TRANSPARENT);
    if (fieldType == CIRCLE_TYPE_HR) {
      drawHR(dc, now);
    } else if (fieldType == CIRCLE_TYPE_SECONDS) {
      drawSeconds(dc, now);
    }

    drawBorder(dc);
  }

  private function drawHR(dc, now) {
    var value = null;
    var info = Activity.getActivityInfo();
    if (info != null) {
      if (info has :currentHeartRate) {
        value = info.currentHeartRate;
      }
    }

    if (value != null) {
      if (now.sec % 2 == 0) {
        dc.drawBitmap(imageX, imageY, image);
      } else {
        dc.drawBitmap(imageX, imageY, imageEmpty);
      }
      dc.drawText(
        textX,
        textY,
        fontMed,
        value,
        Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
      );
    } else {
      dc.drawBitmap(imageX, imageY, image);
      dc.drawText(
        textX,
        textY,
        fontMed,
        Application.loadResource(Rez.Strings.NA),
        Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
      );
    }
  }

  private function drawSeconds(dc, now) {
    dc.drawText(
      textX,
      textY,
      fontMed,
      now.sec,
      Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
    );
  }
}
