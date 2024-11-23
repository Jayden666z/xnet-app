import 'package:shared_preferences/shared_preferences.dart';

class SpUtil {
  static SharedPreferences? prefs;

  static Future<void> initSP() async {
    prefs ??= await SharedPreferences.getInstance();
  }

  static save(String key, String value) {
    prefs?.setString(key, value);
  }

  static get(String key) {
    if(prefs == null) {

    }
    if(prefs?.get(key) == null) {
      // Logger().e(prefs?.get(key));
      return "";
    }
    return prefs?.get(key);
  }

  static remove(String key) {
    prefs?.remove(key);
  }
}
