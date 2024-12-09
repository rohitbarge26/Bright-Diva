import 'package:dio/dio.dart';
import 'package:frequent_flow/authentication/models/login_details.dart';

import '../models/login_response.dart';

class LoginRepository {
  final _dio = Dio();

  LoginRepository();

  Future<LoginResponse?> loginUser(LoginDetails loginDetails) async {
    print(loginDetails.toJson());
    try {
      final response = await _dio.post(
        'http://192.168.1.2:9000/api/v1/login',
        data: loginDetails.toJson(),
        options: Options(headers: {
          "Content-Type": "application/json",
        }),
      );

      var data = response.data;

      if (response.statusCode == 200) {
        final loginResponse = LoginResponse.fromJson(data['data']);
        print("LoginResponse");
        print(loginResponse.toJson());
        return loginResponse;
      }
    } on DioException catch (e) {
      LoginResponse loginResponse = LoginResponse.fromJson(e.response!.data);
      return loginResponse;
    }

    return null;
  }
}
