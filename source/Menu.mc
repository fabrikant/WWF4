using Toybox.Application;
using Toybox.WatchUi;
using Toybox.System;
using Toybox.Graphics;
using Toybox.Activity;
using Toybox.ActivityMonitor;

//*****************************************************************************
class GeneralMenu extends WatchUi.Menu2{
	
	function initialize() {
		Menu2.initialize({:title=> Application.loadResource(Rez.Strings.MenuHeader)});
		addItem(new Item("Theme", Rez.Strings.Theme, subMenuPatternThemes()));
		addItem(new Item("NightTheme", Rez.Strings.NightTheme, subMenuPatternThemes()));
		addItem(new TogleItem("DNDisNight", Rez.Strings.DNDisNight));
		addItem(new TogleItem("InvertCircle", Rez.Strings.InvertCircle));
		addItem(new TogleItem("ShowBatteryScale", Rez.Strings.ShowBatteryScale));
		addItem(new Item("ShowBluetooth", Rez.Strings.ShowBluetooth, subMenuPatternBluetooth()));		
		addItem(new TogleItem("ShowAlarm", Rez.Strings.ShowAlarm));		
		addItem(new TogleItem("ShowDND", Rez.Strings.ShowDND));
		addItem(new TogleItem("ShowAmPm", Rez.Strings.ShowAmPm));
		addItem(new Item("CircleType", Rez.Strings.CircleType, subMenuPatternCircleTypes()));
		addItem(new Item("Top", Rez.Strings.Top, subMenuPatternTopBottomTypes()));
		addItem(new Item("Bottom", Rez.Strings.Bottom, subMenuPatternTopBottomTypes()));
		addItem(new Item("Data1", Rez.Strings.Data1, subMenuPatternDataFields()));
		addItem(new Item("Data2", Rez.Strings.Data2, subMenuPatternDataFields()));
		addItem(new Item("WindSpeeddUnit", Rez.Strings.WindSpeeddUnit, subMenuPatternWindSpeeddUnit()));
	}
	
 	private function subMenuPatternWindSpeeddUnit(){
		return {
			UNIT_SPEED_MS => Rez.Strings.SpeedUnitMSec,
			UNIT_SPEED_KMH => Rez.Strings.SpeedUnitKmH,
			UNIT_SPEED_MLH => Rez.Strings.SpeedUnitMileH,
			UNIT_SPEED_FTS => Rez.Strings.SpeedUnitFtSec,
			UNIT_SPEED_BOF => Rez.Strings.SpeedUnitBof,
			UNIT_SPEED_KNOTS => Rez.Strings.SpeedUnitKnots,
		};
		
		
	}

	private function subMenuPatternDataFields(){
		return {
			EMPTY => Rez.Strings.FIELD_TYPE_EMPTY,
			CALORIES => Rez.Strings.FIELD_TYPE_CALORIES,
			DISTANCE => Rez.Strings.FIELD_TYPE_DISTANCE,
			STEPS => Rez.Strings.FIELD_TYPE_STEPS,
			FLOOR => Rez.Strings.FIELD_TYPE_FLOOR,
			O2 => Rez.Strings.FIELD_TYPE_O2,
			ELEVATION => Rez.Strings.FIELD_TYPE_ELEVATION,
		};
	}

	private function subMenuPatternTopBottomTypes(){
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
	
	private function subMenuPatternThemes(){
		return {
			THEME_DARK => Rez.Strings.ThemeDark,
			THEME_LIGHT => Rez.Strings.ThemeLight,
			THEME_INSTINCT_LIKE_1 => Rez.Strings.ThemeInstinctLike1,
		};
	}

	private function subMenuPatternBluetooth(){
		return {
			BLUETOOTH_SHOW_IF_CONNECT => Rez.Strings.ShowBluetoothIfConnect,
			BLUETOOTH_SHOW_IF_DISCONNECT => Rez.Strings.ShowBluetoothIfDisconnect,
			BLUETOOTH_HIDE => Rez.Strings.ShowBluetoothHide,
		};
	}
	
	private function subMenuPatternCircleTypes(){
		return {
			CIRCLE_TYPE_HR => Rez.Strings.FIELD_TYPE_HR,
			CIRCLE_TYPE_SECONDS => Rez.Strings.FIELD_TYPE_SECONDS,
		};
	}

	function onHide(){
		Application.getApp().onSettingsChanged();
	}
}


//*****************************************************************************
class Item extends WatchUi.MenuItem{

	var submenuPattern;
	
	function initialize(propName, resLabel, submenuPattern) {
		self.submenuPattern = submenuPattern;
		var label = Application.loadResource(resLabel);
		var value = Application.Properties.getValue(propName);
		var sublabel = submenuPattern[value]; 
		MenuItem.initialize(label, sublabel, propName, {});
	}

	function onSelectItem(){
		var weak = self.weak();
		var submenu = new SelectMenu(getLabel(), submenuPattern, getId(), weak);
		WatchUi.pushView(submenu, new SimpleMenuDelegate(), WatchUi.SLIDE_IMMEDIATE);
	}	

	function onSelectSubmenuItem(newValue){
		Application.Properties.setValue(getId(),newValue);
		setSubLabel(submenuPattern[newValue]);
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
//SUBMENU
class SelectMenu extends WatchUi.Menu2{

	
	function initialize(title, pattern, propName, callbackWeak){
		
		Menu2.initialize({:title=> title});
		var propValue = Application.Properties.getValue(propName);
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
