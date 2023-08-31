import Toybox.WatchUi;
import Toybox.System;

class WatchDelegate extends  WatchUi.WatchFaceDelegate{

    function onPress(event){
        var coord = event.getCoordinates();
        
        System.println("x="+coord[0]);
        System.println("y="+coord[1]);
    }

    function onPowerBudgetExceeded(powerInfo) {
        System.println(powerInfo);
    }
}