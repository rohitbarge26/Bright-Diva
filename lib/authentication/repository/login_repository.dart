import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:frequent_flow/authentication/models/email/login_details.dart';
import 'package:frequent_flow/utils/api_constants.dart';

import '../../utils/header_api_option.dart';
import '../models/email/login_response.dart';

class LoginRepository {
  final _dio = Dio();

  LoginRepository();

  /*Future<LoginResponse?> loginUser(LoginDetails loginDetails) async {
    print(loginDetails.toJson());
    String url = BASE_URL + LOGIN;
    print(url);
    try {
      final response = await _dio.post(
        url,
        data: loginDetails.toJson(),
        options: await HeaderApiConfig.getOptions(),
      );

      var data = response.data;
      print("LoginResponse   ::: $data");
      if (response.statusCode == 200) {
        // Need to check this
        final loginResponse = LoginResponse.fromJson(data);
        print("LoginResponse   ::: $loginResponse");
        print(loginResponse.toJson());
        return loginResponse;
      }
    } on DioException catch (e) {
      LoginResponse loginResponse = LoginResponse.fromJson(e.response!.data);
      return loginResponse;
    }

    return null;
  }*/

  Future<LoginResponse> loginUser(LoginDetails loginDetails) async {
    try {
      final response = await _dio.post(
        BASE_URL + LOGIN,
        data: loginDetails.toJson(),
        options: await HeaderApiConfig.getOptions(),
      );

      if (response.statusCode == 200) {
        return LoginResponse.fromJson(response.data);
      } else {
        return LoginResponse.withError(
            'Server error: ${response.statusCode} - ${response.statusMessage}'
        );
      }
    } on DioException catch (e) {
      if (e.response != null) {
        try {
          return LoginResponse.fromJson(e.response!.data);
        } catch (_) {
          return LoginResponse.withError(
              'Failed to process server response (${e.response?.statusCode})'
          );
        }
      }
      return LoginResponse.withError(
          e.message ?? 'Network connection failed'
      );
    } catch (e) {
      return LoginResponse.withError('Unexpected error occurred');
    }
  }
}
