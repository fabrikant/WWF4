using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.System;
using Toybox.Application;
using Toybox.Time;
using Toybox.Time.Gregorian;
using Toybox.Lang;

class DecorationDrawable extends BasicDrawable {
  var decorations;

  function initialize(params as Lang.Dictonary) {
    BasicDrawable.initialize(params);
    decorations = params[:decoration];
  }

  public function draw(dc as Graphics.Dc) {
    dc.setClip(locX, locY, width, height);
    dc.setColor(foregroundColor(), Graphics.COLOR_TRANSPARENT);

    for (var i = 0; i < decorations.size(); i++) {
      var symbol = decorations[i][:method];
      var met = dc.method(symbol);
      var p = decorations[i][:params];

      switch (p.size()) {
        case 0:
          met.invoke();
          break;
        case 1:
          met.invoke(p[0]);
          break;
        case 2:
          met.invoke(p[0], p[1]);
          break;
        case 3:
          met.invoke(p[0], p[1], p[2]);
          break;
        case 4:
          met.invoke(p[0], p[1], p[2], p[3]);
          break;
        case 5:
          met.invoke(p[0], p[1], p[2], p[3], p[4]);
          break;
        case 6:
          met.invoke(p[0], p[1], p[2], p[3], p[4], p[5]);
          break;
        case 7:
          met.invoke(p[0], p[1], p[2], p[3], p[4], p[5], p[6]);
          break;
        case 8:
          met.invoke(p[0], p[1], p[2], p[3], p[4], p[5], p[6], p[7]);
          break;
        case 9:
          met.invoke(p[0], p[1], p[2], p[3], p[4], p[5], p[6], p[7], p[8]);
          break;
        case 10:
          met.invoke(
            p[0],
            p[1],
            p[2],
            p[3],
            p[4],
            p[5],
            p[6],
            p[7],
            p[8],
            p[9]
          );
          break;
      }
    }
  }
}
