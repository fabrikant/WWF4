using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.System;
using Toybox.Lang;

class BasicDrawable extends WatchUi.Drawable{

	function initialize(params as Lang.Dictonary) {
		Drawable.initialize(params);
	}
	
	public function beforeDraw(dc as Graphics.Dc){
		dc.setClip(locX, locY, width, height);
		dc.setColor(Global.getBackgroundColor(), Global.getBackgroundColor());
		dc.clear();
	}
	
	public function draw(dc as Graphics.Dc){
		beforeDraw(dc);
		drawBorder(dc);
	}
	
	public function drawBorder(dc as Graphics.Dc){
		return;
		dc.setColor(Global.getForegraundColor() , Global.getBackgroundColor());
		dc.drawRectangle(locX, locY, width, height);
	}
	
	public function getCenter() as Lang.Array<Lang.Number>{
		return [locX + width/2, locY + height/2];
	}
	
	public function getCenterForFont(font as WatchUi.FontResource) as Lang.Array<Lang.Number>{
	
		var center = getCenter();
//		System.println("Graphics.getFontDescent(font) = "+Graphics.getFontDescent(font));
//		System.println("Graphics.getFontAscent(font) = "+Graphics.getFontAscent(font));
//		System.println("Graphics.getFontHeight(font) = "+Graphics.getFontHeight(font));
//		System.println(center[1]);
		//center[1] -= (Graphics.getFontDescent(font)-Graphics.getFontAscent(font))/2;
		center[1] += Graphics.getFontDescent(font)/4.toNumber()-1;
		//System.println(center[1]);
		return center;
	}
}