import 'package:dio/dio.dart';
import 'package:frequent_flow/utils/pref_key.dart';
import 'package:frequent_flow/utils/prefs.dart';
import 'app_functions.dart';

class HeaderApiConfig {
  static Future<Options> getOptions() async {
    return Options(
      headers: {
        "Content-Type": "application/json",
      },
    );
  }

  static Future<Options> getOptionsWithJWToken() async {
    String jwt = Prefs.getString(TOKEN);
    print('Token: $jwt');
    return Options(headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $jwt",
    });
  }
}
