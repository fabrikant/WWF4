using Toybox.Graphics;
using Toybox.System;
using Toybox.Lang;
using Toybox.Math;

module Sizes{

	var screenH, screenW;
	var centralSquare;
	var fieldH, timeFieldH;
	var circle;
	
	function radiusCorner(){
		return 15;
	}
	
	function calculateScreen(){
		screenH = Toybox.System.getDeviceSettings().screenHeight;
		screenW = Toybox.System.getDeviceSettings().screenWidth;
	}
	
	function calculateCentralSquare(){

		var r = (screenW < screenH ? screenW : screenH)/2;
		//var w = Math.round(Math.sqrt(r*r/2)).toNumber()*2+Math.round(radiusCorner()/3).toNumber();
		
		var rCorn = radiusCorner();
		var cornOffset = rCorn - Math.round(Math.sqrt(rCorn*rCorn/2)).toNumber();
		var w = Math.round(Math.sqrt(r*r/2)).toNumber()*2+cornOffset;
		//[x,y,w,h]
		centralSquare = [Math.round((screenW-w)/2).toNumber(), Math.round((screenH-w)/2).toNumber(), w, w];
	}
	
	function calculateFieldsSizes(){
		fieldH = Math.round(centralSquare[3]/7).toNumber();
		timeFieldH = centralSquare[3]-4*fieldH;
	}
	 
	function calculateCircle(){
		var circleOffset = 2;
		circle = [0, 0, Math.round(2.5*fieldH).toNumber()];
		circle[1] = centralSquare[1]+2*fieldH-circle[2]+circleOffset;
		circle[0] = centralSquare[0]+centralSquare[2]-circle[2]+circleOffset;
	}
	
	function calculate(){
		calculateScreen();
		calculateCentralSquare();
		calculateFieldsSizes();
		calculateCircle();
	}
	
	function clearMemory(){
		screenH = null;
		screenW = null;
		centralSquare = null;
		fieldH = null;
		timeFieldH = null;
		circle = null; 
	}
}