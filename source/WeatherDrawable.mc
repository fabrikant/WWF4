using Toybox.Graphics;
using Toybox.System;
using Toybox.Time;
using Toybox.Application;
using Toybox.Math;

class WeatherDrawable extends BasicDrawable{

	var lastWeatherRead;
	var buffBitmap;
	
	function initialize(params as Lang.Dictonary){
		BasicDrawable.initialize(params);
		onSettingsChanged();
		Application.getApp().mView.registerNotifyOnSettingsChanged(identifier);
	}
	
	public function onSettingsChanged(){
		lastWeatherRead = null;
		buffBitmap = null;		
	}

	public function draw(dc as Graphics.Dc){
		
		dc.setClip(locX, locY, width, height);

		if (lastWeatherUpdate == null){

			var geoLatLong = [Application.Storage.getValue(STORAGE_KEY_LAT), Application.Storage.getValue(STORAGE_KEY_LON)];
			var responseCode = Application.Storage.getValue(STORAGE_KEY_RESPONCE_CODE);
			
			if (geoLatLong[0] == null || geoLatLong[1] == null){
				drawNoData(dc, Application.loadResource(Rez.Strings.NoLocation));
			}else if (Application.Properties.getValue("keyOW").equals("")){
				drawNoData(dc, Application.loadResource(Rez.Strings.NoApiKey));
			}else if (responseCode != null && responseCode != 200){
				drawNoData(dc, Lang.format("$1$: $2$", [Application.loadResource(Rez.Strings.Error), responseCode]));
			}else{
				drawNoData(dc, Application.loadResource(Rez.Strings.WaitingData));
			}
		}else{
			
			if (Time.now().value() - lastWeatherUpdate > 10800){
				Application.getApp().registerEvents();
				drawNoData(dc, Application.loadResource(Rez.Strings.OldData));
			}else{
				drawWeather(dc);
			}			
		}
		drawBorder(dc);
	}
	
	function drawNoData(dc, reason){
		
		var bkColor = backgroundColor();
		dc.setColor(bkColor, bkColor);
		dc.fillRoundedRectangle(locX, locY, width, height, Sizes.radiusCorner());
		dc.setColor(foregroundColor(), Graphics.COLOR_TRANSPARENT);
		var center = getCenterForFont(fontSmall);
		dc.drawText(center[0], center[1], fontSmall, reason, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
		
	}
	
	function drawWeather(dc){
		readWeather();
		if (buffBitmap instanceof Graphics.BufferedBitmap){
			dc.drawBitmap(locX, locY, buffBitmap);
		}		
		
	}
	
	function readWeather(){
		if (lastWeatherUpdate == null){
			return;
		}else if (lastWeatherRead != null){
			if(lastWeatherRead == lastWeatherUpdate){
				return;
			}
		}
		var bkColor = backgroundColor();
		var fColor = foregroundColor();
		
		//need read
		//load data
		lastWeatherRead = lastWeatherUpdate;
		var res = findResByCode(Application.Storage.getValue(STORAGE_KEY_WEATHER_ID), Application.Storage.getValue(STORAGE_KEY_ICON));
		if (res == null){
			res = Rez.Drawables.NA;
		}
		var image = createImage(res);
		var temp = Global.temperatureToString(Application.Storage.getValue(STORAGE_KEY_TEMP));
		if (! temp.equals("")){
			temp = temp+"°";
		}
		var direction = Application.Storage.getValue(STORAGE_KEY_WIND_DEG);
		var speed = Global.speedToString(Application.Storage.getValue(STORAGE_KEY_WIND_SPEED));
		
		//create buffBitmap
		if ( Graphics has :createBufferedBitmap){
			buffBitmap = Graphics.createBufferedBitmap({ 
				:width => width, 
				:height => height}).get();
		}else{
			buffBitmap = new Graphics.BufferedBitmap({ 
				:width => width, 
				:height => height});
		}
		var dc = buffBitmap.getDc();
		var sizeColor = backgroundColorSize();
		dc.setColor(sizeColor, sizeColor);
		dc.fillRectangle(0, 0, width, height);
		dc.setColor(bkColor, bkColor);
		dc.fillRoundedRectangle(0, 0, width+Sizes.radiusCorner()+1, height+Sizes.radiusCorner()+1, Sizes.radiusCorner());
		dc.setColor(fColor, Graphics.COLOR_TRANSPARENT);
		
		//image
		var y = ((dc.getHeight() - image.getDc().getHeight())/2).toNumber();
		var offset = 5;
		dc.drawBitmap(offset, y, image);
		
		//temperature
		offset += image.getDc().getWidth()+offset;
		var center = getCenterForFont(fontMed);
		dc.drawText(offset, center[1]-locY, fontMed, temp, Graphics.TEXT_JUSTIFY_LEFT|Graphics.TEXT_JUSTIFY_VCENTER);
		
		//wind arrow
		offset += dc.getTextWidthInPixels(temp, fontMed);
		var windArrowSize = (height*2/3).toNumber();
		var windDirection = windDirection((height*0.4).toNumber(), direction.toNumber(), [offset, 0], [windArrowSize, windArrowSize]);
		
		//Убедимся, что стрелка влезет в поле
		//Если стрелка вылезает за поле справа, пригласим её назад
		//Если высота стрелки больше windArrowSize (неудачно развернулась), прижмем её вверх
		//Если меньше разместим примерно в центе отведенного ей поля 
		var xWindOffset = 0;
		var yWindMin = 99999;
		var yWindMax = 0;
		for (var i = 0; i < windDirection.size(); i++){
			var diff = windDirection[i][0] - width;
			if (diff > xWindOffset){
				xWindOffset = diff;
			}
			if (windDirection[i][1]< yWindMin){
				yWindMin = windDirection[i][1];
			}
			if (windDirection[i][1]> yWindMax){
				yWindMax = windDirection[i][1];
			}
		}
		
		var windH = yWindMax - yWindMin;
		var yWindOffset = yWindMin;
		if (windH < windArrowSize){
			yWindOffset -= (windArrowSize-windH)/2+1;
		}
		
		for (var i = 0; i < windDirection.size(); i++){
			if (xWindOffset > 0){
				windDirection[i][0] -= xWindOffset+1;
			}
			windDirection[i][1] -= yWindOffset;
		}
		
		dc.fillPolygon(windDirection);
		
		//wind speed
		var speedWidth = dc.getTextWidthInPixels(speed, fontSmall);
		if (offset+speedWidth > width){
			dc.drawText(width-1, height*2/3+2, fontSmall, speed, Graphics.TEXT_JUSTIFY_RIGHT| Graphics.TEXT_JUSTIFY_VCENTER);
		}else{
			dc.drawText(offset+(width-offset)/2, height*2/3+2, fontSmall, speed, Graphics.TEXT_JUSTIFY_CENTER| Graphics.TEXT_JUSTIFY_VCENTER);
		}
		
	}
	
	private function windDirection(size, angle, leftTop, fieldSize){
		
		var angleRad = Math.toRadians(angle);
		var centerPoint = [leftTop[0]+fieldSize[0]/2, leftTop[1]+fieldSize[1]/2];
		var coords = [
			[-size*3/8,-size/2], 
			[0,size/2], 
			[size*3/8,-size/2], 
			[0, -size/4]
		];
	    var result = new [4];
        var cos = Math.cos(angleRad);
        var sin = Math.sin(angleRad);
        // Transform the coordinates
        for (var i = 0; i < 4; i += 1) {
            var x = (coords[i][0] * cos) - (coords[i][1] * sin) + 0.5;
            var y = (coords[i][0] * sin) + (coords[i][1] * cos) + 0.5;
            result[i] = [x + centerPoint[0], y + centerPoint[1]];
            
        }
        return result;
	}
	
	private function findResByCode(id, icon){
		var codes;
		if (id < 300){
			codes = codes200();
		}else if (id < 500){
			codes = codes300();
		}else if (id < 600){
			codes = codes500();
		}else if (id < 700){
			codes = codes600();
		}else if (id < 800){
			codes = codes700();
		}else{
			codes = codes800();
		}
		
		var len = icon.length();
		var key = id.toString()+icon.substring(len-1, len);
		
		return codes[key];
	}
	
	private function codes200(){
		//Thunderstorm
		return {"200d" => Rez.Drawables.Code200d,
				"200n" => Rez.Drawables.Code200n,
				"201d" => Rez.Drawables.Code201d,
				"201n" => Rez.Drawables.Code201n,
				"202d" => Rez.Drawables.Code202d,
				"202n" => Rez.Drawables.Code202n,
				"210d" => Rez.Drawables.Code210d,
				"210n" => Rez.Drawables.Code210n,
				"211d" => Rez.Drawables.Code211d,
				"211n" => Rez.Drawables.Code211n,
				"212d" => Rez.Drawables.Code212d,
				"212n" => Rez.Drawables.Code212n,
				"221d" => Rez.Drawables.Code221d,
				"221n" => Rez.Drawables.Code221n,
				"230d" => Rez.Drawables.Code230d,
				"230n" => Rez.Drawables.Code230n,
				"231d" => Rez.Drawables.Code231d,
				"231n" => Rez.Drawables.Code231n,
				"232d" => Rez.Drawables.Code232d,
				"232n" => Rez.Drawables.Code232n,};
	}
	
	
	private function codes300(){
		//Drizzle
		return {"300d" => Rez.Drawables.Code300d,
			"300n" => Rez.Drawables.Code300n,
			"301d" => Rez.Drawables.Code301d,
			"301n" => Rez.Drawables.Code301n,
			"302d" => Rez.Drawables.Code302d,
			"302n" => Rez.Drawables.Code302n,
			"310d" => Rez.Drawables.Code310d,
			"310n" => Rez.Drawables.Code310n,
			"311d" => Rez.Drawables.Code311d,
			"311n" => Rez.Drawables.Code311n,
			"312d" => Rez.Drawables.Code312d,
			"312n" => Rez.Drawables.Code312n,
			"313d" => Rez.Drawables.Code313d,
			"313n" => Rez.Drawables.Code313n,
			"314d" => Rez.Drawables.Code314d,
			"314n" => Rez.Drawables.Code314n,
			"321d" => Rez.Drawables.Code321d,
			"321n" => Rez.Drawables.Code321n,};	
	}
	
	private function codes500(){
		//Rain
		return {"500d" => Rez.Drawables.Code500d,
				"500n" => Rez.Drawables.Code500n,
				"501d" => Rez.Drawables.Code501d,
				"501n" => Rez.Drawables.Code501n,
				"502d" => Rez.Drawables.Code502d,
				"502n" => Rez.Drawables.Code502n,
				"503d" => Rez.Drawables.Code503d,
				"503n" => Rez.Drawables.Code503n,
				"504d" => Rez.Drawables.Code504d,
				"504n" => Rez.Drawables.Code504n,
				"511d" => Rez.Drawables.Code511d,
				"511n" => Rez.Drawables.Code511n,
				"520d" => Rez.Drawables.Code520d,
				"520n" => Rez.Drawables.Code520n,
				"521d" => Rez.Drawables.Code521d,
				"521n" => Rez.Drawables.Code521n,
				"522d" => Rez.Drawables.Code522d,
				"522n" => Rez.Drawables.Code522n,
				"531d" => Rez.Drawables.Code531d,
				"531n" => Rez.Drawables.Code531n,};	
	}
	
	private function codes600(){
		//Snow
		return {"600d" => Rez.Drawables.Code600d,
				"600n" => Rez.Drawables.Code600n,
				"601d" => Rez.Drawables.Code601d,
				"601n" => Rez.Drawables.Code601n,
				"602d" => Rez.Drawables.Code602d,
				"602n" => Rez.Drawables.Code602n,
				"611d" => Rez.Drawables.Code611d,
				"611n" => Rez.Drawables.Code611n,
				"612d" => Rez.Drawables.Code612d,
				"612n" => Rez.Drawables.Code612n,
				"613d" => Rez.Drawables.Code613d,
				"613n" => Rez.Drawables.Code613n,
				"615d" => Rez.Drawables.Code615d,
				"615n" => Rez.Drawables.Code615n,
				"616d" => Rez.Drawables.Code616d,
				"616n" => Rez.Drawables.Code616n,
				"620d" => Rez.Drawables.Code620d,
				"620n" => Rez.Drawables.Code620n,
				"621d" => Rez.Drawables.Code621d,
				"621n" => Rez.Drawables.Code621n,
				"622d" => Rez.Drawables.Code622d,
				"622n" => Rez.Drawables.Code622n,};	
	}
	
	private function codes700(){
		//Atmosphere
		return {"701d" => Rez.Drawables.Code701d,
				"701n" => Rez.Drawables.Code701n,
				"711d" => Rez.Drawables.Code711d,
				"711n" => Rez.Drawables.Code711n,
				"721d" => Rez.Drawables.Code721d,
				"721n" => Rez.Drawables.Code721n,
				"731d" => Rez.Drawables.Code731d,
				"731n" => Rez.Drawables.Code731n,
				"741d" => Rez.Drawables.Code741d,
				"741n" => Rez.Drawables.Code741n,
				"751d" => Rez.Drawables.Code751d,
				"751n" => Rez.Drawables.Code751n,
				"761d" => Rez.Drawables.Code761d,
				"761n" => Rez.Drawables.Code761n,
				"762d" => Rez.Drawables.Code762d,
				"762n" => Rez.Drawables.Code762n,
				"771d" => Rez.Drawables.Code771d,
				"771n" => Rez.Drawables.Code771n,
				"781d" => Rez.Drawables.Code781d,
				"781n" => Rez.Drawables.Code781n,};	
	}
	
	private function codes800(){
		//Cloud
		return {"800d" => Rez.Drawables.Code800d,
				"800n" => Rez.Drawables.Code800n,
				"801d" => Rez.Drawables.Code801d,
				"801n" => Rez.Drawables.Code801n,
				"802d" => Rez.Drawables.Code802d,
				"802n" => Rez.Drawables.Code802n,
				"803d" => Rez.Drawables.Code803d,
				"803n" => Rez.Drawables.Code803n,
				"804d" => Rez.Drawables.Code804d,
				"804n" => Rez.Drawables.Code804n,};	
	}
}