using Toybox.Lang;
using Toybox.Graphics;
using Toybox.System;

class GroundDrawable extends BasicDrawable{

	var xy, wh as Lang.Number;
		
	function initialize(params as Lang.Dictonary){
		
		BasicDrawable.initialize(params);
		var r = height/2;
		var a = (Toybox.Math.sqrt(r*r/2)+3).toNumber();
		xy = r-a;
		wh = height-2*xy;
	}
	
	public function draw(dc as Graphics.Dc){
		
		var bkColor = backgroundColorSide();
		dc.setClip(locX, locY, width, height);
		dc.setColor(bkColor, bkColor);
		dc.fillRectangle(locX, locY, width, height);
		bkColor = backgroundColor();
		dc.setColor(bkColor, bkColor);
		dc.fillRoundedRectangle(xy, xy, wh, wh, Sizes.radiusCorner());
				
	}


}