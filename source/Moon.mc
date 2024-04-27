import Toybox.Time;
import Toybox.Time.Gregorian;
import Toybox.System;
import Toybox.Graphics;
import Toybox.Math;

module Moon {
  function moonPhase(d) {
    //var now = Time.now();
    var date = Time.Gregorian.info(d, Time.FORMAT_SHORT);
    // date.month, date.day date.year

    var n0 = 0;
    var f0 = 0.0;

    //current date
    var Y1 = date.year;
    var M1 = date.month;
    var D1 = date.day;

    var YY1 = n0;
    var MM1 = n0;
    var K11 = n0;
    var K21 = n0;
    var K31 = n0;
    var JD1 = n0;
    var IP1 = f0;

    // calculate the Julian date at 12h UT
    YY1 = Y1 - ((12 - M1) / 10).toNumber();
    MM1 = M1 + 9;
    if (MM1 >= 12) {
      MM1 = MM1 - 12;
    }
    K11 = (365.25 * (YY1 + 4712)).toNumber();
    K21 = (30.6 * MM1 + 0.5).toNumber();
    K31 = ((YY1 / 100 + 49).toNumber() * 0.75).toNumber() - 38;

    JD1 = K11 + K21 + D1 + 59; // for dates in Julian calendar
    if (JD1 > 2299160) {
      JD1 = JD1 - K31; // for Gregorian calendar
    }

    // calculate moon's age in days
    IP1 = normalize((JD1 - 2451550.1) / 29.530588853);
    var AG1 = IP1 * 29.53;

    if (AG1 < 1) {
      AG1 += 1;
    }
    //return AG1.toNumber();
    return { :IP1 => IP1, :AG1 => Math.round(AG1).format("%d") };
  }

  ///////////////////////////////////////////////////////////////////////////
  function normalize(v) {
    v = v - v.toNumber();
    if (v < 0) {
      v = v + 1;
    }
    return v;
  }

  ///////////////////////////////////////////////////////////////////////////
  function abs(v) {
    if (v < 0) {
      return -v;
    } else {
      return v;
    }
  }

  ///////////////////////////////////////////////////////////////////////////
  function drawMoon(phase, size, color, backgroundColor) {
    var buffImage = null;
    var imageOptions = {
      :width => size,
      :height => size,
      :palette => [color, backgroundColor],
    };
    if (Graphics has :createBufferedBitmap) {
      var bufferedBitmapRef = Graphics.createBufferedBitmap(imageOptions);
      buffImage = bufferedBitmapRef.get();
    } else {
      buffImage = new Graphics.BufferedBitmap(imageOptions);
    }

    var dc = buffImage.getDc();
    var w = dc.getWidth();
    var rPos;
    var xPos, xPos1, xPos2;
    var shift = w / 2;
    var r = 0.8 * shift;

    dc.setColor(backgroundColor, backgroundColor);
    dc.clear();

    for (var yPos = 0; yPos <= r; yPos++) {
      xPos = Math.sqrt(r * r - yPos * yPos);

      dc.setColor(backgroundColor, backgroundColor);
      dc.drawLine(shift - xPos, yPos + shift, xPos + shift, yPos + shift);
      dc.drawLine(shift - xPos, shift - yPos, xPos + shift, shift - yPos);

      // Determine the edges of the lighted part of the moon
      rPos = 2 * xPos;
      if (phase < 0.5) {
        xPos1 = -xPos;
        xPos2 = rPos - 2 * phase * rPos - xPos;
      } else {
        xPos1 = xPos;
        xPos2 = xPos - 2 * phase * rPos + rPos;
      }
      dc.setColor(color, color);
      dc.drawLine(shift - xPos1, yPos + shift, xPos2 + shift, yPos + shift);
      dc.drawLine(shift - xPos1, shift - yPos, xPos2 + shift, shift - yPos);
    }

    dc.setColor(color, color);
    dc.drawCircle(shift, shift, r);

    return buffImage;
  }
}
