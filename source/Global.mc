using Toybox.Graphics;
using Toybox.WatchUi;
using Toybox.System;
using Toybox.Application;
using Toybox.Time;
using Toybox.Lang;


var fontBig as WatchUi.FontResource; 
var fontMed as WatchUi.FontResource;
var fontSmall as WatchUi.FontResource;


var lastWeatherUpdate as Toybox.Time.Moment = null;
var theme as Toybox.Lang.Array<Number>;
var nowIsDay;
var dayThemeIsSet;
var DNDisNight;

enum{

	STORAGE_KEY_RESPONCE_CODE,
	STORAGE_KEY_UPDATE_MOMENT,
	STORAGE_KEY_TEMP,
	STORAGE_KEY_ICON,
	STORAGE_KEY_WIND_SPEED,
	STORAGE_KEY_WIND_DEG,
	STORAGE_KEY_WEATHER_ID,
	STORAGE_KEY_WEATHER_CITY,
	STORAGE_KEY_WEATHER_MAIN,
//	STORAGE_KEY_WEATHER_DESCRIPTION,
//	STORAGE_KEY_HUMIDITY,
//	STORAGE_KEY_PRESSURE,
//	STORAGE_KEY_VISIBILITY,

	BLUETOOTH_SHOW_IF_CONNECT = 0,
	BLUETOOTH_SHOW_IF_DISCONNECT,
	BLUETOOTH_HIDE,
	
	THEME_DARK = 0,
	THEME_LIGHT,
	THEME_INSTINCT_LIKE_1,
	THEME_INSTINCT_LIKE_2,
	
	
	CIRCLE_TYPE_HR = 1,
	CIRCLE_TYPE_SECONDS,

	EMPTY = 0,
	TOP_BOTTOM_TYPE_BATTERY,
	TOP_BOTTOM_TYPE_DATE,
	TOP_BOTTOM_TYPE_WEATHER_CONDITION,
	TOP_BOTTOM_TYPE_CITY,
	CALORIES,
	DISTANCE,
	STEPS,
	FLOOR,
	O2,
	ELEVATION,
	TIME_ZONE,
	MOON,
	
	UNIT_SPEED_MS = 0,
	UNIT_SPEED_KMH,
	UNIT_SPEED_MLH,
	UNIT_SPEED_FTS,
	UNIT_SPEED_BOF,
	UNIT_SPEED_KNOTS,

}
module Global{

	function elevationToString(rawData){
		var value = rawData;//meters
		if (System.getDeviceSettings().elevationUnits ==  System.UNIT_STATUTE){ /*foot*/
			value = rawData*3.281;
		}
		if (value > 9999){
			value = (value/1000).format("%.1f")+"k";
		}else{
			value = value.format("%d");
		}
		return value;
	}

	function distanceToString(rawData){
		var value = rawData;//santimeters
		if (System.getDeviceSettings().distanceUnits == System.UNIT_METRIC){ /*km*/
			value = rawData/100000.0;
		}else{ /*mile*/
			value = rawData/160934.4;
		}
		var fString = "%.2f";
		if (value >= 10){
			fString = "%.1f";
		}if (value >= 100){
			fString = "%d";
		}
		return value.format(fString);
	}

	function speedToString(rawData){
		var value = rawData;//meters/sec
		var unit =  Application.Properties.getValue("WindSpeeddUnit");
		if (unit == UNIT_SPEED_KMH){ /*km/h*/
			value = rawData*3.6;
		}else if (unit == UNIT_SPEED_MLH){ /*mile/h*/
			value = rawData*2.237;
		}else if (unit == UNIT_SPEED_FTS){ /*ft/s*/
			value = rawData*3.281;
		}else if (unit == UNIT_SPEED_BOF){ /*Beaufort*/
			value = Global.getBeaufort(rawData);
		}else if (unit == UNIT_SPEED_KNOTS){ /*knots*/
			value = rawData*1.94384;
		}
		return value.format("%d");
	}

	function getBeaufort(rawData){
		if(rawData >= 33){
			return 12;
		}else if(rawData >= 28.5){
			return 11;
		}else if(rawData >= 24.5){
			return 10;
		}else if(rawData >= 20.8){
			return 9;
		}else if(rawData >= 17.2){
			return 8;
		}else if(rawData >= 13.9){
			return 7;
		}else if(rawData >= 10.8){
			return 6;
		}else if(rawData >= 8){
			return 5;
		}else if(rawData >= 5.5){
			return 4;
		}else if(rawData >= 3.4){
			return 3;
		}else if(rawData >= 1.6){
			return 2;
		}else if(rawData >= 0.3){
			return 1;
		}else {
			return 0;
		}
	}

	function temperatureToString(rawData){
		
		var value;
		if (rawData != null){
			if (System.getDeviceSettings().temperatureUnits == System.UNIT_STATUTE){ /*F*/
				value = ((rawData*9/5) + 32);
			}else{
				value = rawData;
			}
		}else{
			value = "";
		}	
		return value.format("%d");
	}

	function momentToString(moment){
		var greg = Time.Gregorian.info(moment, Time.FORMAT_SHORT);
        var hours = greg.hour;
        var hourFormat = "%02d";
        if (!System.getDeviceSettings().is24Hour) {
        	hourFormat = "%d";
            if (hours > 12) {
                hours = hours - 12;
            }
        }
		return Lang.format("$1$:$2$", [hours.format(hourFormat), greg.min.format("%02d")]);
	}
	
}