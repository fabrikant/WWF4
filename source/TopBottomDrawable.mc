import Toybox.WatchUi;
import Toybox.Graphics;
import Toybox.System;
import Toybox.Lang;
import Toybox.Math;

class TopBottomDrawable extends DataDrawable {
  var isTop;
  var lastWeatherRead, lastValue;

  function initialize(params) {
    DataDrawable.initialize(params);
    isTop = params[:isTop];
    onSettingsChanged();
  }

  public function onSettingsChanged() {
    DataDrawable.onSettingsChanged();
    lastWeatherRead = null;
    lastValue = null;
  }

  public function draw(dc as Graphics.Dc) {
    beforeDraw(dc);

    var bkColor = backgroundColor();
    var sideColor = backgroundColorSide();
    if (sideColor != bkColor) {
      var radius = Sizes.radiusCorner();
      dc.setColor(sideColor, sideColor);
      dc.fillRectangle(locX, locY, radius, radius);
      dc.setColor(bkColor, bkColor);
      dc.fillCircle(locX + radius, locY + radius, radius);
    }

    if (dataType == TOP_BOTTOM_TYPE_BATTERY) {
      drawBattery(dc);
    } else if (dataType == TOP_BOTTOM_TYPE_DATE) {
      drawDate(dc);
    } else if (dataType == TOP_BOTTOM_TYPE_WEATHER_CONDITION) {
      drawWeatherInfo(dc);
    } else if (dataType == TOP_BOTTOM_TYPE_CITY) {
      drawWeatherInfo(dc);
    } else {
      drawDataField(dc);
    }
  }

  function drawDataField(dc) {
    var value = getValue(dataType);
    if (value == null) {
      return;
    }
    loadImage();

    //draw field
    var widthData = 0;
    if (image != null) {
      widthData += image.getDc().getWidth();
    }

    widthData += dc.getTextWidthInPixels(value.toString(), fontMed);
    var offset = ((width - widthData) / 2).toNumber();
    var topBottomCorrection = topBottomCorrection();
    if (image != null) {
      var imageHeight = image.getDc().getHeight();
      var yOffset =
        imageHeight >= height ? 0 : ((height - imageHeight) / 2).toNumber();
      dc.drawBitmap(locX + offset, locY + yOffset + topBottomCorrection, image);
      offset += image.getDc().getWidth();
    }
    var center = getCenterForFont(fontMed);
    dc.setColor(foregroundColor(), Graphics.COLOR_TRANSPARENT);
    dc.drawText(
      locX + offset,
      center[1] + topBottomCorrection,
      fontMed,
      value,
      Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER
    );
  }

  function updateLastValue() {
    if (lastWeatherUpdate == null) {
      return;
    } else if (lastWeatherRead != null) {
      if (lastWeatherRead == lastWeatherUpdate) {
        return;
      }
    }
    lastWeatherRead = lastWeatherUpdate;
    if (dataType == TOP_BOTTOM_TYPE_WEATHER_CONDITION) {
      lastValue = Application.Storage.getValue(STORAGE_KEY_WEATHER_MAIN);
    }
    if (dataType == TOP_BOTTOM_TYPE_CITY) {
      lastValue = Application.Storage.getValue(STORAGE_KEY_WEATHER_CITY);
    }
  }

  function drawWeatherInfo(dc) {
    updateLastValue();
    if (lastValue != null) {
      var fColor = foregroundColor();
      var center = getCenterForFont(fontSmall);
      dc.setColor(fColor, Graphics.COLOR_TRANSPARENT);
      dc.drawText(
        center[0],
        center[1] + topBottomCorrection(),
        fontSmall,
        lastValue,
        Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
      );
    }
  }

  function drawDate(dc) {
    dc.setColor(foregroundColor(), Graphics.COLOR_TRANSPARENT);
    var now = Time.Gregorian.info(Time.now(), Time.FORMAT_LONG);
    var center = getCenterForFont(fontSmall);
    var value = Lang.format("$1$, $2$ $3$", [
      now.day_of_week,
      now.day,
      now.month,
    ]);
    dc.drawText(
      center[0],
      center[1] + topBottomCorrection(),
      fontSmall,
      value,
      Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
    );
  }

  function drawBattery(dc) {
    if (Graphics.Dc has :setAntiAlias) {
      dc.setAntiAlias(true);
    }

    var bkColor = backgroundColor();
    var fColor = foregroundColor();

    dc.setPenWidth(1);
    dc.setColor(fColor, Graphics.COLOR_TRANSPARENT);
    var value = Math.round(System.getSystemStats().battery);
    var k = 0.45;

    var topBottomCorrection = topBottomCorrection();
    var hBattery = height * k;
    var wBattery = hBattery * 2;
    if (wBattery > width / 3.2) {
      wBattery = width / 3.2;
    }
    var yOffset = 3 + topBottomCorrection;
    var xOffset = -wBattery;

    //Внешний контур
    //[x,y,width,height]
    var external = [
      locX + (width - wBattery) / 2 + xOffset,
      locY + (height - hBattery) / 2 + yOffset,
      wBattery,
      hBattery,
    ];
    dc.drawRectangle(external[0], external[1], external[2], external[3]);
    var hContact = external[3] * 0.6;
    var wContact = external[2];
    dc.fillRoundedRectangle(
      external[0] + 3,
      external[1] + (external[3] - hContact) / 2 - 1,
      wContact,
      hContact,
      3
    );
    dc.setColor(bkColor, Graphics.COLOR_TRANSPARENT);
    dc.fillRectangle(
      external[0] + 1,
      external[1] + 1,
      external[2] - 2,
      external[3] - 2
    );

    if (value > 20) {
      dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_TRANSPARENT);
    } else {
      dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
    }

    var inner = [
      external[0] + 2,
      external[1] + 2,
      external[2] - 4,
      external[3] - 4,
    ];
    dc.fillRectangle(inner[0], inner[1], (inner[2] * value) / 100, inner[3]);

    var center = getCenterForFont(fontSmall);
    dc.setColor(fColor, Graphics.COLOR_TRANSPARENT);
    dc.drawText(
      locX + width / 2,
      center[1] + topBottomCorrection,
      fontSmall,
      value.format("%d") + "%",
      Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER
    );
  }

  function topBottomCorrection() {
    if (isTop == null) {
      return 0;
    } else {
      if (dataType == MOON) {
        return 0;
      } else {
        return isTop ? +4 : -4;
      }
    }
  }
}
