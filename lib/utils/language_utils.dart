import 'package:flutter/material.dart';
import 'package:frequent_flow/utils/pref_key.dart';
import 'package:frequent_flow/utils/prefs.dart';

class LanguageNotifier extends ChangeNotifier {
  Locale _locale = Locale(Prefs.getLocalLangString(LOCAL_LANGUAGE));

  Locale get locale => _locale;

  void changeLanguage(String languageCode) {
    _locale = Locale(languageCode);
    Prefs.setLocalLangString(LOCAL_LANGUAGE, languageCode);
    notifyListeners();
  }
}
