import 'package:shared_preferences/shared_preferences.dart';

class UserInfo {

  static bool signIn = false;
  static String username = "UnSignIn";

  static SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }


  static Future<void> getInfo() async {
    if ( _prefs.getBool("signIn") ) {
      signIn = true;
      username = _prefs.getString("username");
    }
  }

  static Future<void> clearInfo() async {
    signIn = false;
    username = "UnSignIn";
    _prefs.setBool("signIn", false);
    _prefs.setString("username", "UnSignIn");
  }
}