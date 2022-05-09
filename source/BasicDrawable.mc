using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.System;
using Toybox.Lang;

class BasicDrawable extends WatchUi.Drawable{

	var centerPosition;
	
	function initialize(params as Lang.Dictonary) {
		centerPosition = params[:centerPosition];
		if (centerPosition == null){
			centerPosition = -1;
		}
		Drawable.initialize(params);
	}
	
	public function beforeDraw(dc as Graphics.Dc){
		dc.setClip(locX, locY, width, height);
		dc.setColor(backgroundColor(), backgroundColor());
		dc.clear();
	}
	
	public function draw(dc as Graphics.Dc){
		beforeDraw(dc);
		drawBorder(dc);
	}
	
	public function drawBorder(dc as Graphics.Dc){
		return;
		dc.setColor(accentColor() , accentColor());
		dc.drawRectangle(locX, locY, width, height);
	}
	
	public function getCenter() as Lang.Array<Lang.Number>{
		return [locX + width/2, locY + height/2];
	}
	
	public function getCenterForFont(font as WatchUi.FontResource) as Lang.Array<Lang.Number>{
		var center = getCenter();
		center[1] += Graphics.getFontDescent(font)/4.toNumber()-1;
		return center;
	}
	
	function createImage(resorse){
		var _bitmap = Application.loadResource(resorse);
		var _bufferedBitmap = new Graphics.BufferedBitmap({
			:bitmapResource => _bitmap,
			:width => _bitmap.getWidth(),
			:height => _bitmap.getHeight()
		});
		_bufferedBitmap.setPalette([foregroundColor(), Graphics.COLOR_TRANSPARENT]);
		return _bufferedBitmap;
	}
	
	function backgroundColor(){
		switch (centerPosition){
			case true:
				return theme[2];
			case false:
				return theme[0];
			default:
				return Graphics.COLOR_TRANSPARENT;
		}
	}
	
	function foregroundColor(){
		switch (centerPosition){
			case true:{
				return theme[3];
			}
			case false:{
				return theme[1];
			}
			default:{
				return Graphics.COLOR_TRANSPARENT;
			}
		}
	}
	
	function backgroundColorSize(){
		return theme[0];
	}
	
	function accentColor(){
		return theme[4];
	}
	
}