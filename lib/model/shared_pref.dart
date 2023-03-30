import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPref {
  SharedPreferences prefs;

  dynamic read(String key) async {
    prefs = await SharedPreferences.getInstance();
    return json.decode(prefs.getString(key)??"");
  }

  void save(String key, value) async {
    prefs = await SharedPreferences.getInstance();
    prefs.setString(key, json.encode(value));
  }

  void remove(String key) async {
    prefs = await SharedPreferences.getInstance();
    prefs.remove(key);
  }

  dynamic checkPreference(String key) async {
    return prefs.containsKey(key);
  }
}
