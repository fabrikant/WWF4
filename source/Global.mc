using Toybox.Graphics;
using Toybox.WatchUi;
using Toybox.System;
using Toybox.Application;

const RADIUS_CORNER = 15;

var fontBig as WatchUi.FontResource; 
var fontMed as WatchUi.FontResource;
var fontSmall as WatchUi.FontResource;

var lastWeatherUpdate as Toybox.Time.Moment = null;
var theme as Toybox.Lang.Array<Number>;

enum{

	STORAGE_KEY_RESPONCE_CODE,
	STORAGE_KEY_UPDATE_MOMENT,
	STORAGE_KEY_TEMP,
	STORAGE_KEY_HUMIDITY,
	STORAGE_KEY_PRESSURE,
	STORAGE_KEY_ICON,
	STORAGE_KEY_WIND_SPEED,
	STORAGE_KEY_WIND_DEG,
	STORAGE_KEY_VISIBILITY,
	STORAGE_KEY_WEATHER_MAIN,
	STORAGE_KEY_WEATHER_DESCRIPTION,
	STORAGE_KEY_WEATHER_ID,
	STORAGE_KEY_WEATHER_CITY,

	BLUETOOTH_SHOW_IF_CONNECT = 0,
	BLUETOOTH_SHOW_IF_DISCONNECT,
	BLUETOOTH_HIDE,

	EMPTY = 0,

	CALORIES = 1,
	DISTANCE,

	TOP_BOTTOM_TYPE_BATTERY = 1,
	TOP_BOTTOM_TYPE_DATE,
	TOP_BOTTOM_TYPE_WEATHER_CONDITION,
	TOP_BOTTOM_TYPE_CITY,

	
	THEME_DARK = 0,
	THEME_LIGHT,
	THEME_INSTINCT_LIKE_1,
	
	
	CIRCLE_TYPE_HR = 1,
	CIRCLE_TYPE_SECONDS,
	
	
//	HR,
//	STEPS,
//	FLOOR,
//	ACTIVE_DAY,
//	ACTIVE_WEEK,
//	WEIGHT,
//	O2,
//	SUN_EVENT,
//	SUNRISE_EVENT,
//	SUNSET_EVENT,
//	TIME1,
//	PRESSURE,
//	TEMPERATURE,
//	ELEVATION,
//	SOLAR_CHARGE,
//	ALARMS_COUNT,
//	WEATHER_TEMPERATURE,
//	WEATHER_PRESSURE,
//	WEATHER_WIND_SPEED,
//	WEATHER_WIND_DEG,
//	WEATHER_HUM,
//	WEATHER_VISIBILITY,
//	WEATHER_UVI,
//	WEATHER_DEW_POINT,
//	CONNECTED,
//	NOTIFICATIONS,
//	DND,
//	ALARMS,
//	AMPM,
//	SECONDS,
//	NOTIFICATIONS_COUNT,
//	EMPTY,
//	MOON,



//	PICTURE = 1000,
//	NA = "n/a",
//	
//	DARK = 0,
//	DARK_COLOR,
//	DARK_MONOCHROME,
//	DARK_RED_COLOR,
//	DARK_GREEN_COLOR,
//	DARK_BLUE_COLOR,
//	LIGHT,
//	LIGHT_COLOR,
//	LIGHT_MONOCHROME,
//	LIGHT_RED_COLOR,
//	LIGHT_GREEN_COLOR,
//	LIGHT_BLUE_COLOR,
//
//	UNIT_PRESSURE_MM_HG = 0,
//	UNIT_PRESSURE_PSI,
//	UNIT_PRESSURE_INCH_HG,
//	UNIT_PRESSURE_BAR,
//	UNIT_PRESSURE_KPA,
//
	UNIT_SPEED_MS = 0,
	UNIT_SPEED_KMH,
	UNIT_SPEED_MLH,
	UNIT_SPEED_FTS,
	UNIT_SPEED_BOF,
	UNIT_SPEED_KNOTS,

//	WIDGET_TYPE_WEATHER  = 0,
//	WIDGET_TYPE_WEATHER_WIND,
//	WIDGET_TYPE_WEATHER_FIELDS,
//	WIDGET_TYPE_HR,
//	WIDGET_TYPE_SATURATION,
//	WIDGET_TYPE_TEMPERATURE,
//	WIDGET_TYPE_PRESSURE,
//	WIDGET_TYPE_ELEVATION,
//	WIDGET_TYPE_MOON,
//	WIDGET_TYPE_SOLAR,
//	
//	FIELDS_COUNT = 8,
//	STATUS_FIELDS_COUNT = 6,	
}
module Global{

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
		var unit =  Application.Properties.getValue("WinSpeeddUnit");
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
}