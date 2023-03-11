//{
//   "lat":55,
//   "lon":75,
//   "timezone":"Asia/Omsk",
//   "timezone_offset":21600,
//   "current":{
//      "dt":1616471820,
//      "sunrise":1616460895,
//      "sunset":1616505492,
//      "temp":-8.47,
//      "feels_like":-12.96,
//      "pressure":1017,
//      "humidity":96,
//      "dew_point":-8.93,
//      "uvi":1.32,
//      "clouds":98,
//      "visibility":5543,
//      "wind_speed":2.16,
//      "wind_deg":206,
//      "wind_gust":2.9,
//      "weather":[
//         {
//            "id":804,
//            "main":"Clouds",
//            "description":"пасмурно",
//            "icon":"04d"
//         }
//      ]
//   },
//   "alerts":[
//      {
//         "sender_name":"",
//         "event":"Гололедно - изморозевое отложение",
//         "start":1616461200,
//         "end":1616562000,
//         "description":"местами гололедные-изморозевые явления"
//      },
//      {
//         "sender_name":"",
//         "event":"Freezing rain, icing",
//         "start":1616461200,
//         "end":1616562000,
//         "description":""
//      },
//      {
//         "sender_name":"",
//         "event":"Fog",
//         "start":1616472000,
//         "end":1616554800,
//         "description":""
//      },
//      {
//         "sender_name":"",
//         "event":"Туман",
//         "start":1616425200,
//         "end":1616554800,
//         "description":"местами"
//      }
//   ]
//}

using Toybox.Background;
using Toybox.Communications;
using Toybox.System;
using Toybox.Position;
using Toybox.Time;


(:background)
class BackgroundService extends System.ServiceDelegate {

	function initialize() {
        ServiceDelegate.initialize();
    }

	function onTemporalEvent() {

		var url = "https://api.openweathermap.org/data/2.5/weather";

		var lat = Application.Storage.getValue(STORAGE_KEY_LAT);
		var lon = Application.Storage.getValue(STORAGE_KEY_LON);
		var appid = Application.Properties.getValue("keyOW");

		//////////////////////////////////////////////////////////
		//DEBUG
		//System.println("onTemporalEvent: "+Time.now().value());
		//////////////////////////////////////////////////////////
		Communications.makeWebRequest(
			url,
			{
				"lat" => lat,
				"lon" => lon,
				"appid" => appid,
				"units" => "metric",
				"lang" => getLang()				
			},
			{},
			method(:responseCallback)
		);
	}

	function responseCallback(responseCode, data) {
		var backgroundData;
		//////////////////////////////////////////////////////////
		//DEBUG
//		System.println("responseCallback: "+Time.now().value());
//		System.println("responseCode: "+responseCode);
//		System.println("data: "+data);
		//////////////////////////////////////////////////////////
		
		 
		if (responseCode == 200) {
			 
			backgroundData = {
				STORAGE_KEY_RESPONCE_CODE => responseCode,
				STORAGE_KEY_UPDATE_MOMENT => Time.now().value(),
				STORAGE_KEY_TEMP => data["main"]["temp"],
				STORAGE_KEY_ICON => data["weather"][0]["icon"],
				STORAGE_KEY_WEATHER_ID => data["weather"][0]["id"],
				STORAGE_KEY_WIND_SPEED => data["wind"]["speed"],
				STORAGE_KEY_WIND_DEG => data["wind"]["deg"],
				STORAGE_KEY_WEATHER_MAIN => data["weather"][0]["main"],
				STORAGE_KEY_WEATHER_CITY => data["name"],
				//STORAGE_KEY_HUMIDITY => data["main"]["humidity"],
				//STORAGE_KEY_PRESSURE => data["main"]["pressure"],
				//STORAGE_KEY_VISIBILITY => data["visibility"],
				//STORAGE_KEY_WEATHER_DESCRIPTION => data["weather"][0]["description"],
			};
		} else {
			backgroundData = {
				STORAGE_KEY_RESPONCE_CODE => responseCode,
				STORAGE_KEY_UPDATE_MOMENT => Time.now().value(),
			};
		}

		Background.exit(backgroundData);
	}
	
	function getLang(){
		
		var res = "en";
		var sysLang = System.getDeviceSettings().systemLanguage;
		
		if (sysLang == System.LANGUAGE_ARA){
			res = "ar";
		}else if (sysLang  == System.LANGUAGE_BUL){
			res = "bg";		
		}else if (sysLang == System.LANGUAGE_CES){
			res = "cz";		
		}else if (sysLang == System.LANGUAGE_CHS){
			res = "zh_cn";		
		}else if (sysLang == System.LANGUAGE_CHT){
			res = "zh_tw";		
		}else if (sysLang == System.LANGUAGE_DAN){
			res = "da";		
		}else if (sysLang == System.LANGUAGE_DEU){
			res = "de";		
		}else if (sysLang == System.LANGUAGE_DUT){
			res = "de";		
		}else if (sysLang == System.LANGUAGE_FIN){
			res = "fi";		
		}else if (sysLang == System.LANGUAGE_FRE){
			res = "fr";		
		}else if (sysLang == System.LANGUAGE_GRE){
			res = "el";		
		}else if (sysLang == System.LANGUAGE_HEB){
			res = "he";		
		}else if (sysLang == System.LANGUAGE_HRV){
			res = "hr";		
		}else if (sysLang == System.LANGUAGE_HUN){
			res = "hu";		
		}else if (sysLang == System.LANGUAGE_IND){
			res = "hi";		
		}else if (sysLang == System.LANGUAGE_ITA){
			res = "it";		
		}else if (sysLang == System.LANGUAGE_JPN){
			res = "ja";		
		}else if (sysLang == System.LANGUAGE_KOR){
			res = "	kr";		
		}else if (sysLang == System.LANGUAGE_LAV){
			res = "la";		
		}else if (sysLang == System.LANGUAGE_LIT){
			res = "lt";		
		}else if (sysLang == System.LANGUAGE_NOB){
			res = "no";		
		}else if (sysLang == System.LANGUAGE_POL){
			res = "pl";		
		}else if (sysLang == System.LANGUAGE_POR){
			res = "pt";		
		}else if (sysLang == System.LANGUAGE_RON){
			res = "ro";		
		}else if (sysLang == System.LANGUAGE_RUS){
			res = "ru";		
		}else if (sysLang == System.LANGUAGE_SLO){
			res = "sk";		
		}else if (sysLang == System.LANGUAGE_SLV){
			res = "	sl";		
		}else if (sysLang == System.LANGUAGE_SPA){
			res = "sp";		
		}else if (sysLang == System.LANGUAGE_SWE){
			res = "sv";		
		}else if (sysLang == System.LANGUAGE_THA){
			res = "th";		
		}else if (sysLang == System.LANGUAGE_TUR){
			res = "tr";		
		}else if (sysLang == System.LANGUAGE_UKR){
			res = "ua";		
		}else if (sysLang == System.LANGUAGE_VIE){
			res = "vi";		
		}else if (sysLang == System.LANGUAGE_ZSM){
			res = "zu";		
		}
		return res;
	}	
}