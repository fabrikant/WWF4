import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Time;
import Toybox.Background;

(:background)
class WWF4App extends Application.AppBase {
  var mView;

  function initialize() {
    AppBase.initialize();
    loadGlobalValues();
  }

  function loadGlobalValues() {
    DNDisN = Application.Properties.getValue("DNDisN");
  }

  // triggered by settings change in GCM
  function onSettingsChanged() {
    loadGlobalValues();
    mView.onSettingsChanged();
    registerEvents();
    WatchUi.requestUpdate(); // update the view to reflect changes
  }

  // Return the initial view of your application here
  function getInitialView() {
    mView = new WWF4View();
    return [mView, new WatchDelegate()];
  }

  function getSettingsView() {
    return [new GeneralMenu(), new SimpleMenuDelegate()];
  }

  ///////////////////////////////////////////////////////////////////////////
  // Background
  function onBackgroundData(data) {
    //////////////////////////////////////////////////////////
    //DEBUG
    //System.println("onBackgroundData "+Tools.momentToString(Time.now()));
    //System.println("data: "+data);
    //////////////////////////////////////////////////////////
    if (data != null) {
      if (data[STORAGE_KEY_RESPONCE_CODE] != null) {
        Application.Storage.setValue(
          STORAGE_KEY_RESPONCE_CODE,
          data[STORAGE_KEY_RESPONCE_CODE]
        );
        if (data[STORAGE_KEY_RESPONCE_CODE].toNumber() == 200) {
          lastWeatherUpdate = data[STORAGE_KEY_UPDATE_MOMENT];
          var keys = data.keys();
          for (var i = 0; i < keys.size(); i++) {
            if (data[keys[i]] == null) {
              Application.Storage.deleteValue(keys[i]);
            } else {
              Application.Storage.setValue(keys[i], data[keys[i]]);
            }
          }
        }
      }
    }
    registerEvents();
  }

  function registerEvents() {
    //////////////////////////////////////////////////////////
    //DEBUG
    //System.println("registerEvents");
    //System.println("geoLocation "+[Application.Storage.getValue(STORAGE_KEY_LAT), Application.Storage.getValue(STORAGE_KEY_LON)]);
    //System.println("apiKey "+Application.Properties.getValue("keyOW"));
    //////////////////////////////////////////////////////////

    var geoLatLong = [
      Application.Storage.getValue(STORAGE_KEY_LAT),
      Application.Storage.getValue(STORAGE_KEY_LON),
    ];
    if (geoLatLong[0] == null || geoLatLong[1] == null) {
      return;
    }
    if (geoLatLong[0] == 0 && geoLatLong[1] == 0) {
      return;
    }
    var kewOw = Application.Properties.getValue("keyOW");
    if (kewOw.equals("")) {
      if (Toybox has :Complications) {
        if (Toybox.Complications has :getComplications) {
          //try to get owm api key from RoseOfWind
          var iter = Toybox.Complications.getComplications();
          var compl = iter.next();
          while (compl != null) {
            if (compl.shortLabel != null) {
              if (compl.shortLabel.equals("owm_key")) {
                if (compl.value != null) {
                  if (!compl.value.equals("")) {
                    kewOw = compl.value;
                    Application.Properties.setValue("keyOW", kewOw);
                    break;
                  }
                }
              }
            }
            compl = iter.next();
          }
        }
      }
    }
    if (kewOw.equals("")) {
      return;
    }
    var registeredTime = Background.getTemporalEventRegisteredTime();
    if (registeredTime != null) {
      //////////////////////////////////////////////////////////
      //DEBUG
      //System.println("now: "+Tools.momentToString(Time.now())+" Event already set: "+Tools.momentToString(registeredTime));
      //////////////////////////////////////////////////////////
      return;
    }
    var lastTime = Background.getLastTemporalEventTime();
    var duration = new Time.Duration(600);
    var now = Time.now();
    if (lastTime == null) {
      //////////////////////////////////////////////////////////
      //DEBUG
      //System.println("reg ev now 1");
      //////////////////////////////////////////////////////////
      Background.registerForTemporalEvent(now);
    } else {
      if (now.greaterThan(lastTime.add(duration))) {
        //////////////////////////////////////////////////////////
        //DEBUG
        //System.println("reg ev now 2");
        //////////////////////////////////////////////////////////
        Background.registerForTemporalEvent(now);
      } else {
        var nextTime = lastTime.add(duration);
        //////////////////////////////////////////////////////////
        //DEBUG
        //System.println("reg ev "+Tools.momentToString(nextTime));
        //////////////////////////////////////////////////////////
        Background.registerForTemporalEvent(nextTime);
      }
    }
  }

  function getServiceDelegate() {
    return [new BackgroundService()];
  }
}

function getApp() as WWF4App {
  return Application.getApp() as WWF4App;
}
