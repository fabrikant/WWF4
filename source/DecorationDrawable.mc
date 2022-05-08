using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.System;
using Toybox.Application;
using Toybox.Time;
using Toybox.Time.Gregorian;

class DecorationDrawable extends BasicDrawable{

	var decorations;
	
	function initialize(params as Lang.Dictonary) {
		BasicDrawable.initialize(params);
		decorations = params[:decoration];
	}
	
	public function draw(dc as Graphics.Dc){
		dc.setClip(locX, locY, width, height);
		dc.setColor(Global.getAccentColor(), Graphics.COLOR_TRANSPARENT);
		
		for (var i=0; i<decorations.size(); i++){
			
			var symbol = decorations[i][:method];			
			var met = dc.method(symbol);
			var p = decorations[i][:params];
			if (symbol == :drawLine){
				met.invoke(p[0],p[1],p[2],p[3]);
			}else if(symbol == :setPenWidth){
				met.invoke(p[0]);
			}
			
		}
		
		
	}
	
}