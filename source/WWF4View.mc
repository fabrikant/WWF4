using Toybox.Graphics;
using Toybox.Lang;
using Toybox.System;
using Toybox.WatchUi;
using Toybox.Activity;

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
    function onLayout(dc as Dc) {
    	
    	fontBig = Application.loadResource(Rez.Fonts.big);
    	fontMed = Application.loadResource(Rez.Fonts.medium);
    	fontSmall = Application.loadResource(Rez.Fonts.small);
    	
        setLayout(Rez.Layouts.WatchFace(dc));
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
			Application.Storage.setValue("Lat", location[0].toFloat());
			Application.Storage.setValue("Lon", location[1].toFloat());
		} else {
			if (Toybox has :Weather){
				location = Toybox.Weather.getCurrentConditions();
				if (location != null) {
					location = location.observationLocationPosition;
			    	if (location != null) {
						location = location.toDegrees();
						Application.Storage.setValue("Lat", location[0].toFloat());
						Application.Storage.setValue("Lon", location[1].toFloat());
					}
				}
			}
		}
		Application.getApp().registerEvents();
    }

    // Update the view
    function onUpdate(dc as Dc) {
		
		if (dayThemeIsSet != nowIsDay){
			onSettingsChanged();
		}
	
        View.onUpdate(dc);
    }

	function onPartialUpdate(dc as Dc){
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

		var themeKey = "Theme";
		dayThemeIsSet = true;
		
		if(!nowIsDay){
			themeKey = "NightTheme";
			dayThemeIsSet = false;
		}
		
		//[backcgroundColorSize, foregroundColorSize, backcgroundColorCenter, foregroundColorCenter, АccentColor]
		var themeNumber = Application.Properties.getValue(themeKey);
		if (themeNumber == THEME_DARK){
			theme = [Graphics.COLOR_BLACK, Graphics.COLOR_WHITE, Graphics.COLOR_BLACK, Graphics.COLOR_WHITE, Graphics.COLOR_DK_GRAY];
		}else if (themeNumber == THEME_LIGHT){
			theme = [Graphics.COLOR_WHITE, Graphics.COLOR_BLACK, Graphics.COLOR_WHITE, Graphics.COLOR_BLACK, Graphics.COLOR_DK_GRAY];
		}else if (themeNumber == THEME_INSTINCT_LIKE_1){
			theme = [Graphics.COLOR_BLACK, Graphics.COLOR_WHITE, Graphics.COLOR_WHITE, Graphics.COLOR_BLACK, Graphics.COLOR_DK_GRAY];
		}else if (themeNumber == THEME_INSTINCT_LIKE_2){
			theme = [0xaa5500, Graphics.COLOR_BLACK, Graphics.COLOR_BLACK, Graphics.COLOR_WHITE, 0xaa5500];
		}else{
			theme = [Graphics.COLOR_BLACK, Graphics.COLOR_WHITE, Graphics.COLOR_WHITE, Graphics.COLOR_BLACK, Graphics.COLOR_DK_GRAY];
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
