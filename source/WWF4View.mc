using Toybox.Graphics;
using Toybox.Lang;
using Toybox.System;
using Toybox.WatchUi;
using Toybox.Activity;
using Toybox.Math;

class WWF4View extends WatchUi.WatchFace {

	var circle;
	var notifyOnSettingsChanged;
	
    function initialize() {
        WatchFace.initialize();
        notifyOnSettingsChanged = [];
        nowIsDay = true;
        setTheme();
    }

    // Load your resources here
    function onLayout(dc) {
    	
    	fontBig = Application.loadResource(Rez.Fonts.big);
    	fontMed = Application.loadResource(Rez.Fonts.medium);
    	fontSmall = Application.loadResource(Rez.Fonts.small);
    	
    	Sizes.calculate();
        setLayout(Rez.Layouts.WatchFace(dc));
        Sizes.clearMemory();
        circle = findDrawableById("Circle");
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() {
    
    	if (lastWeatherUpdate == null){
    		lastWeatherUpdate = Application.Storage.getValue(STORAGE_KEY_UPDATE_MOMENT);
    	}
    	
       	var location = Activity.getActivityInfo().currentLocation;
    	if (location != null) {
			location = location.toDegrees();
			Application.Storage.setValue(STORAGE_KEY_LAT, location[0].toFloat());
			Application.Storage.setValue(STORAGE_KEY_LON, location[1].toFloat());
		} else {
			if (Toybox has :Weather){
				if (Application.Properties.getValue("GWLocation")){
					location = Toybox.Weather.getCurrentConditions();
					if (location != null) {
						location = location.observationLocationPosition;
						if (location != null) {
							location = location.toDegrees();
							Application.Storage.setValue(STORAGE_KEY_LAT, location[0].toFloat());
							Application.Storage.setValue(STORAGE_KEY_LON, location[1].toFloat());
						}
					}
				}
			}
		}
		Application.getApp().registerEvents();
    }

    // Update the view
    function onUpdate(dc) {
		
		if (dayThemeIsSet != nowIsDay){
			onSettingsChanged();
		}
	
        View.onUpdate(dc);
    }

	function onPartialUpdate(dc){
		circle.draw(dc);
	}
	
	function onSettingsChanged(){
		setTheme();
		circle.onSettingsChanged();
		for (var i = 0; i < notifyOnSettingsChanged.size(); i++){
			var id = notifyOnSettingsChanged[i];
			var obj = findDrawableById(id);
			obj.onSettingsChanged();
			
		}
	}
	
	function registerNotifyOnSettingsChanged(id){
		if (notifyOnSettingsChanged.indexOf(id)){
			notifyOnSettingsChanged.add(id);
		}
	}
	
	function setTheme(){

		var themeKey = "ThemeD";
		dayThemeIsSet = true;
		
		if(!nowIsDay){
			themeKey = "ThemeN";
			dayThemeIsSet = false;
		}
		
		//[backcgroundColorSize, foregroundColorSize, backcgroundColorCenter, foregroundColorCenter]
		var themeNumber = Application.Properties.getValue(themeKey);
		if (themeNumber == THEME_DARK){
			theme = [Graphics.COLOR_BLACK, Graphics.COLOR_WHITE, Graphics.COLOR_BLACK, Graphics.COLOR_WHITE];
		}else if (themeNumber == THEME_LIGHT){
			theme = [Graphics.COLOR_WHITE, Graphics.COLOR_BLACK, Graphics.COLOR_WHITE, Graphics.COLOR_BLACK];
		}else if (themeNumber == THEME_INSTINCT_LIKE_1){
			theme = [Graphics.COLOR_BLACK, Graphics.COLOR_WHITE, Graphics.COLOR_WHITE, Graphics.COLOR_BLACK];
		}else if (themeNumber == THEME_INSTINCT_LIKE_2){
			theme = [Graphics.COLOR_DK_GRAY, Graphics.COLOR_WHITE, Graphics.COLOR_WHITE, Graphics.COLOR_BLACK];
		}else if (themeNumber == THEME_INSTINCT_LIKE_3){
			theme = [Graphics.COLOR_DK_GRAY, Graphics.COLOR_BLACK, Graphics.COLOR_WHITE, Graphics.COLOR_BLACK];
		}else if (themeNumber == THEME_BLUE_YELLOW){
			theme = [Graphics.COLOR_DK_BLUE, Graphics.COLOR_WHITE, Graphics.COLOR_YELLOW, Graphics.COLOR_BLACK];
		}else{
			theme = [Graphics.COLOR_BLACK, Graphics.COLOR_WHITE, Graphics.COLOR_WHITE, Graphics.COLOR_BLACK];
		}
	} 
	
    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() {
    }

    // The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep() {
    }

    // Terminate any active timers and prepare for slow updates.
    function onEnterSleep() {
    }

}
