using Toybox.Application;
using Toybox.WatchUi;
using Toybox.System;
using Toybox.Graphics;
using Toybox.Activity;
using Toybox.ActivityMonitor;
using Toybox.SensorHistory;
using Toybox.Lang;

//*****************************************************************************
class GeneralMenu extends WatchUi.Menu2{
	
	function initialize() {
		Menu2.initialize({:title=> Application.loadResource(Rez.Strings.MenuHeader)});
		addItem(new Item("ThemeD", Rez.Strings.ThemeD, :subMenuPatternThemes));
		addItem(new Item("ThemeN", Rez.Strings.ThemeN, :subMenuPatternThemes));

		addItem(new Item("Circle", Rez.Strings.Circle, :subMenuPatternCircleTypes));
		addItem(new Item("Widget", Rez.Strings.Widget, :subMenuPatternWidgetTypes));
		addItem(new Item("Top", Rez.Strings.Top, :subMenuPatternTopBottomTypes));
		addItem(new Item("Bot", Rez.Strings.Bot, :subMenuPatternTopBottomTypes));
		addItem(new Item("Dt1", Rez.Strings.Dt1, :subMenuPatternDataFields));
		addItem(new Item("Dt2", Rez.Strings.Dt2, :subMenuPatternDataFields));

		addItem(new TogleItem("DNDisN", Rez.Strings.DNDisN));
		addItem(new TogleItem("InvertCircle", Rez.Strings.InvertCircle));
		addItem(new TogleItem("DecorateHours", Rez.Strings.DecorateHours));
		addItem(new TogleItem("SBat", Rez.Strings.SBat));
		addItem(new Item("SBt", Rez.Strings.SBt, :subMenuPatternBluetooth));		
		addItem(new TogleItem("SAl", Rez.Strings.SAl));		
		addItem(new TogleItem("ShowDND", Rez.Strings.ShowDND));
		
		if (!System.getDeviceSettings().is24Hour){
			addItem(new TogleItem("ShowAmPm", Rez.Strings.ShowAmPm));
		}
		if (Toybox has :Weather){
			addItem(new TogleItem("GWLocation", Rez.Strings.GWLocation));
		}
		addItem(new PickerItem("T1TZ", Rez.Strings.T1TZ));
		addItem(new Item("WndU", Rez.Strings.WndU, :subMenuPatternWindSpeeddUnit));
		addItem(new Item("PrU", Rez.Strings.PrU, :subMenuPatternPressureUnit));
		addItem(new PickerItem("keyOW", Rez.Strings.keyOW));
	}
	
	function onHide(){
		Application.getApp().onSettingsChanged();
	}
}


//*****************************************************************************
class Item extends WatchUi.MenuItem{

	var patternMethodSymbol;
	
	function initialize(propName, resLabel, patternMethodSymbol) {
		self.patternMethodSymbol = patternMethodSymbol;
		var label = Application.loadResource(resLabel);
		var value = Application.Properties.getValue(propName);
		//var sublabel = patternMethodSymbol[value]; 
		var sublabel = Patterns.getSublabel(patternMethodSymbol, value);
		MenuItem.initialize(label, sublabel, propName, {});
	}

	function onSelectItem(){
		var weak = self.weak();
		var submenu = new SelectMenu(getLabel(), patternMethodSymbol, getId(), weak);
		WatchUi.pushView(submenu, new SimpleMenuDelegate(), WatchUi.SLIDE_IMMEDIATE);
	}	

	function onSelectSubmenuItem(newValue){
		Application.Properties.setValue(getId(),newValue);
		setSubLabel(Patterns.getSublabel(patternMethodSymbol, newValue));
	}	
}

//*****************************************************************************
class TogleItem extends WatchUi.ToggleMenuItem{
	
	function initialize(propName, resLabel) {
		var label = Application.loadResource(resLabel);
		var enabled = Application.Properties.getValue(propName);
		ToggleMenuItem.initialize(label, null, propName, enabled, {});
	}

	function onSelectItem(){
		Application.Properties.setValue(getId(), isEnabled());
	}	
}

//*****************************************************************************
class PickerItem extends WatchUi.MenuItem{
	
	function initialize(propName, resLabel) {
		var label = Application.loadResource(resLabel);
		var sublabel = Application.Properties.getValue(propName);
		MenuItem.initialize(label, sublabel.toString(), propName, {});
	}

	function onSelectItem(){
		var charSet = "0123456789-";
		if (getId().equals("keyOW")){
			charSet = "0123456789abcdef";
		} 
		var picker = new StringPicker(self.weak(), charSet);
		WatchUi.pushView(picker, new StringPickerDelegate(picker), WatchUi.SLIDE_IMMEDIATE);
	}	
	
	function onSetText(value){
		setSubLabel(value);
		if (getId().equals("keyOW")){
			Application.Properties.setValue(getId(), value);
		}else{
			Application.Properties.setValue(getId(), value.toNumber());
		}
	}
}

//*****************************************************************************
//SUBMENU
class SelectMenu extends WatchUi.Menu2{

	
	function initialize(title, patternMethodSymbol, propName, callbackWeak){
		
		Menu2.initialize({:title=> title});
		var propValue = Application.Properties.getValue(propName);
		var method = new Lang.Method(Patterns, patternMethodSymbol);
		var pattern = method.invoke();
		var keys = pattern.keys();
		for (var i=0; i<keys.size(); i++){
			addItem(new SelectItem(keys[i], pattern[keys[i]], callbackWeak));
			if (propValue == keys[i]){
				setFocus(i);
			}
		}
	}
}

//*****************************************************************************
class SelectItem extends WatchUi.MenuItem{
	
	var callbackWeak;
	
	function initialize(identifier, resLabel, callbackWeak) {
		self.callbackWeak = callbackWeak; 
		MenuItem.initialize(Application.loadResource(resLabel), null, identifier, {});
	}

	function onSelectItem(){
		if (callbackWeak.stillAlive()){
			var obj = callbackWeak.get();
			if (obj != null){
				obj.onSelectSubmenuItem(getId());
			}
		}
		WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);	
		
	}
}

//*****************************************************************************
//DELEGATE
class SimpleMenuDelegate extends WatchUi.Menu2InputDelegate{
	
	function initialize() {
        Menu2InputDelegate.initialize();
    }
    
	function onSelect(item){
		item.onSelectItem();
	}
}

module Patterns{
 	
 	function subMenuPatternWindSpeeddUnit(){
		return {
			UNIT_SPEED_MS => Rez.Strings.SpeedUnitMSec,
			UNIT_SPEED_KMH => Rez.Strings.SpeedUnitKmH,
			UNIT_SPEED_MLH => Rez.Strings.SpeedUnitMileH,
			UNIT_SPEED_FTS => Rez.Strings.SpeedUnitFtSec,
			UNIT_SPEED_BOF => Rez.Strings.SpeedUnitBof,
			UNIT_SPEED_KNOTS => Rez.Strings.SpeedUnitKnots,
		};
	}

	function subMenuPatternPressureUnit(){
		return {
			UNIT_PRESSURE_MM_HG => Rez.Strings.PrUMmHg,
			UNIT_PRESSURE_PSI => Rez.Strings.PrUPsi,
			UNIT_PRESSURE_INCH_HG => Rez.Strings.PrUInchHg,
			UNIT_PRESSURE_BAR => Rez.Strings.PrUBar,
			UNIT_PRESSURE_KPA => Rez.Strings.PrUKPa,
		};
	}

	function subMenuPatternDataFields(){
		 var pattern = {
			EMPTY => Rez.Strings.FIELD_TYPE_EMPTY,
			CALORIES => Rez.Strings.FIELD_TYPE_CALORIES,
			DISTANCE => Rez.Strings.FIELD_TYPE_DISTANCE,
			STEPS => Rez.Strings.FIELD_TYPE_STEPS,
			TIME_ZONE => Rez.Strings.FIELD_TYPE_TIME1,
			MOON => Rez.Strings.FIELD_TYPE_MOON,
		};
		
		if (Activity.Info has :currentOxygenSaturation){
			pattern[O2] = Rez.Strings.FIELD_TYPE_O2;
		}
		if (Activity.Info has :altitude){
			pattern[ELEVATION] = Rez.Strings.FIELD_TYPE_ELEVATION;
		}
		if (ActivityMonitor.Info has :floorsClimbed){
			pattern[FLOOR] = Rez.Strings.FIELD_TYPE_FLOOR;
		}
		if ((Toybox has :SensorHistory) && (Toybox.SensorHistory has :getStressHistory)){
			pattern[STRESS] = Rez.Strings.FIELD_TYPE_STRESS;
		}
		if ((Toybox has :SensorHistory) && (Toybox.SensorHistory has :getBodyBatteryHistory)){
			pattern[BODY_BATTERY] = Rez.Strings.FIELD_TYPE_BODY_BATTERY;
		}
		if ((Toybox has :SensorHistory) && (Toybox.SensorHistory has :getTemperatureHistory)){
			pattern[TEMPERATURE] = Rez.Strings.FIELD_TYPE_TEMPERATURE;
		}
		if ((Toybox has :SensorHistory) && (Toybox.SensorHistory has :getPressureHistory)){
			pattern[PRESSURE] = Rez.Strings.FIELD_TYPE_PRESSURE;
		}
		
		pattern[WEIGHT] = Rez.Strings.FIELD_TYPE_WEIGHT;
		return pattern;
	}

	function subMenuPatternTopBottomTypes(){
		var dict =  {
			EMPTY => Rez.Strings.FIELD_TYPE_EMPTY,
			TOP_BOTTOM_TYPE_BATTERY => Rez.Strings.FIELD_TYPE_BATTERY,
			TOP_BOTTOM_TYPE_DATE => Rez.Strings.FIELD_TYPE_DATE,
			TOP_BOTTOM_TYPE_WEATHER_CONDITION => Rez.Strings.FIELD_TYPE_WEATHER_CONDITION,
			TOP_BOTTOM_TYPE_CITY => Rez.Strings.FIELD_TYPE_CITY,
		};
		//add data fields types
		var dictDataFields = subMenuPatternDataFields();
		var keys = dictDataFields.keys();
		for (var i = 0; i < keys.size(); i++){
			dict.put(keys[i], dictDataFields[keys[i]]);
		} 
		return dict;
	}
	
	function subMenuPatternWidgetTypes(){
		var dict =  {
			EMPTY => Rez.Strings.FIELD_TYPE_EMPTY,
			TOP_BOTTOM_TYPE_CITY => Rez.Strings.FIELD_TYPE_CITY,
			TOP_BOTTOM_TYPE_BATTERY => Rez.Strings.FIELD_TYPE_BATTERY,
			TOP_BOTTOM_TYPE_DATE => Rez.Strings.FIELD_TYPE_DATE,
			TOP_BOTTOM_TYPE_WEATHER_CONDITION => Rez.Strings.FIELD_TYPE_WEATHER_CONDITION,
			WEATHER => Rez.Strings.FIELD_TYPE_WEATHER,
		};
		//add data fields types
		var dictDataFields = subMenuPatternDataFields();
		var keys = dictDataFields.keys();
		for (var i = 0; i < keys.size(); i++){
			dict.put(keys[i], dictDataFields[keys[i]]);
		} 
		return dict;
	}

	function subMenuPatternThemes(){
		return {
			THEME_DARK => Rez.Strings.ThemeDark,
			THEME_LIGHT => Rez.Strings.ThemeLight,
			THEME_INSTINCT_LIKE_1 => Rez.Strings.ThemeInstinctLike1,
			THEME_INSTINCT_LIKE_2 => Rez.Strings.ThemeInstinctLike2,
			THEME_INSTINCT_LIKE_3 => Rez.Strings.ThemeInstinctLike3,
			THEME_INSTINCT_LIKE_4 => Rez.Strings.ThemeInstinctLike4,
			THEME_INSTINCT_LIKE_5 => Rez.Strings.ThemeInstinctLike5,
			THEME_BLUE_YELLOW => Rez.Strings.ThemeBlueYellow,			
		};
	}

	function subMenuPatternBluetooth(){
		return {
			BLUETOOTH_SHOW_IF_CONNECT => Rez.Strings.ShowBluetoothIfConnect,
			BLUETOOTH_SHOW_IF_DISCONNECT => Rez.Strings.ShowBluetoothIfDisconnect,
			BLUETOOTH_HIDE => Rez.Strings.ShowBluetoothHide,
		};
	}
	
	function subMenuPatternCircleTypes(){
		return {
			CIRCLE_TYPE_HR => Rez.Strings.FIELD_TYPE_HR,
			CIRCLE_TYPE_SECONDS => Rez.Strings.FIELD_TYPE_SECONDS,
		};
	}
	
	function getSublabel(methodSymbol, value){
		var method = new Lang.Method(Patterns, methodSymbol);
		var pattern = method.invoke();
		return pattern[value];
	}

}
