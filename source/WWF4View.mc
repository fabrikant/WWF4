using Toybox.Graphics;
using Toybox.Lang;
using Toybox.System;
using Toybox.WatchUi;
using Toybox.Activity;

class WWF4View extends WatchUi.WatchFace {

	var circle;
	
    function initialize() {
        WatchFace.initialize();
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
    
    	if (lastWeatharUpdate == null){
    		lastWeatharUpdate = Application.Storage.getValue(STORAGE_KEY_UPDATE_MOMENT);
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
    }

    // Update the view
    function onUpdate(dc as Dc) {
        // Get and show the current time
//        var clockTime = System.getClockTime();
//        var timeString = Lang.format("$1$:$2$", [clockTime.hour, clockTime.min.format("%02d")]);
//        var view = View.findDrawableById("TimeLabel") as Text;
//        view.setText(timeString);

        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);
    }

	function onPartialUpdate(dc as Dc){
		circle.draw(dc);
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
