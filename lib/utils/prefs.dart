
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../authentication/models/email/login_response.dart';

class Prefs {
  static late SharedPreferences _prefs;

// call this method from iniState() function of mainApp().
  static Future<SharedPreferences> init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
    } catch (e) {}
    return _prefs;
  }

//sets
  static Future<bool> setBool(String key, bool? value) async =>
      await _prefs.setBool(key, value ?? false);

  static Future<bool> setDouble(String key, double? value) async =>
      await _prefs.setDouble(key, value ?? 0.0);

  static Future<bool> setInt(String key, int? value) async =>
      await _prefs.setInt(key, value ?? 0);

  static Future<bool> setString(String key, String? value) async =>
      await _prefs.setString(key, value ?? "");

  static Future<bool> setLocalLangString(String key, String? value) async =>
      await _prefs.setString(key, value ?? "en");

  static Future<bool> setHeaderLangString(String key, String? value) async =>
      await _prefs.setString(key, value ?? "en-US");

  static Future<bool> setUILangString(String key, String? value) async =>
      await _prefs.setString(key, value ?? "en-US");

  static Future<bool> setStringList(String key, List<String> value) async =>
      await _prefs.setStringList(key, value);

  static Future<bool> setBiometricValue(String key, bool? value) async =>
      await _prefs.setBool(key, value ?? false);

  // Save User object
  static Future<bool> setUser(String key, User user) async {
    final userJson = user.toJson(); // Convert User object to JSON
    final userString = jsonEncode(userJson); // Convert JSON to string
    return await _prefs.setString(key, userString);
  }

  // Retrieve User object
  static User? getUser(String key) {
    final userString = _prefs.getString(key);
    if (userString != null) {
      final userJson = jsonDecode(userString); // Convert string to JSON
      return User.fromJson(userJson); // Convert JSON to User object
    }
    return null;
  }

//gets
  static bool getBool(String key) => _prefs.getBool(key) ?? false;

  static double getDouble(String key) => _prefs.getDouble(key) ?? 0.0;

  static int getInt(String key, {int byDefault = 0}) =>
      _prefs.getInt(key) ?? byDefault;

  static String getString(String key) => _prefs.getString(key) ?? "";

  static String getLocalLangString(String key) => _prefs.getString(key) ?? "en";

  static String getHeaderLangString(String key) =>
      _prefs.getString(key) ?? "en-US";

  static String getUILangString(String key) => _prefs.getString(key) ?? "en-US";

  static List<String> getStringList(String key) =>
      _prefs.getStringList(key) ?? [];

  static bool getBiometricValue(String key) => _prefs.getBool(key) ?? false;

//deletes..
  static Future<bool> remove(String key) async => await _prefs.remove(key);

  static Future<bool> clear() async => await _prefs.clear();
}
