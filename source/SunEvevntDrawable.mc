import Toybox.Lang;
import Toybox.Graphics;
import Toybox.Time;
import Toybox.System;
import Toybox.Position;
import Toybox.Time.Gregorian;
import Toybox.Application;

class SunEventsDrawable extends BasicDrawable {
  var image, imageX, sunriseX, sunsetX;
  var sunCalculator;

  function initialize(params) {
    BasicDrawable.initialize(params);
    sunCalculator = new SunCalc();
    onSettingsChanged();
    Application.getApp().mView.registerNotifyOnSettingsChanged(identifier);
  }

  public function onSettingsChanged() {
    image = createImage(Rez.Drawables.sunEvent);
    var imageWidth = image.getDc().getWidth();
    imageX = locX + ((width - imageWidth) / 2).toNumber();

    var offset = 8;
    sunriseX = imageX - offset;
    sunsetX = imageX + imageWidth + offset;
  }

  public function draw(dc as Graphics.Dc) {
    dc.setClip(locX, locY, width, height);

    var center = getCenterForFont(fontMed);
    dc.setColor(foregroundColor(), Graphics.COLOR_TRANSPARENT);
    var imageHeight = image.getDc().getHeight();
    var yOffset =
      imageHeight >= height ? 0 : ((height - imageHeight) / 2).toNumber();

    dc.drawBitmap(imageX, locY + yOffset, image);

    var sunrise = "GPS";
    var sunset = "GPS";
    var sunriseMoment = null;
    var sunsetMoment = null;

    var geoLatLong = [
      Application.Storage.getValue(STORAGE_KEY_LAT),
      Application.Storage.getValue(STORAGE_KEY_LON),
    ];
    if (geoLatLong != null) {
      if (geoLatLong[0] != null && geoLatLong[1] != null) {
        var myLocation = (
          new Position.Location({
            :latitude => geoLatLong[0],
            :longitude => geoLatLong[1],
            :format => :degrees,
          })
        ).toRadians();
        var today = Time.today();
        today = today.add(new Time.Duration(Gregorian.SECONDS_PER_DAY));
        sunriseMoment = sunCalculator.calculate(
          today,
          myLocation[0],
          myLocation[1],
          SUNRISE
        );
        sunsetMoment = sunCalculator.calculate(
          today,
          myLocation[0],
          myLocation[1],
          SUNSET
        );
      }
    }

    if (sunriseMoment == null) {
      sunrise = Application.loadResource(Rez.Strings.NA);
    } else {
      sunrise = momentToString(sunriseMoment);
    }
    if (sunsetMoment == null) {
      sunset = Application.loadResource(Rez.Strings.NA);
    } else {
      sunset = momentToString(sunsetMoment);
    }

    //To day or not to day
    nowIsDay = true;

    if (DNDisN && System.getDeviceSettings().doNotDisturb) {
      nowIsDay = false;
    } else {
      if (sunriseMoment != null && sunsetMoment != null) {
        var now = Time.now();
        if (!(now.greaterThan(sunriseMoment) && now.lessThan(sunsetMoment))) {
          nowIsDay = false;
        }
      }
    }
    dc.drawText(
      sunriseX,
      center[1],
      fontMed,
      sunrise,
      Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER
    );
    dc.drawText(
      sunsetX,
      center[1],
      fontMed,
      sunset,
      Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER
    );

    drawBorder(dc);
  }

  function momentToString(moment) {
    var info = Gregorian.info(moment, Time.FORMAT_SHORT);
    var hours = info.hour;
    var f = "%02d";
    if (!System.getDeviceSettings().is24Hour) {
      f = "%02d";
      if (hours > 12) {
        hours = hours - 12;
      }
    }

    //System.println(info.day+"."+info.month+"."+info.year+" "+hours.format(f)+":"+info.min.format("%02d"));
    return hours.format(f) + ":" + info.min.format("%02d");
  }
}
