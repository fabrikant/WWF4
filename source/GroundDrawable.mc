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
//		System.println("xy="+xy);
//		System.println("wh="+wh);		
	}
	
	public function draw(dc as Graphics.Dc){
		
		beforeDraw(dc);
		dc.setColor(Global.getForegraundColor(), Global.getForegraundColor());
		//dc.setColor(Global.getAccentColor(), Global.getAccentColor());
		dc.fillRectangle(locX, locY, width, height);
		
		dc.setColor(Global.getBackgroundColor(), Global.getBackgroundColor());
		dc.fillRoundedRectangle(xy, xy, wh, wh, RADIUS_CORNER);
				
	}


}