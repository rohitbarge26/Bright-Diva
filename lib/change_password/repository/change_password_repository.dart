import 'package:dio/dio.dart';
import 'package:frequent_flow/change_password/models/change_password_request.dart';
import 'package:frequent_flow/change_password/models/change_password_response.dart';
import 'package:frequent_flow/utils/api_constants.dart';
import 'package:frequent_flow/utils/pref_key.dart';
import 'package:frequent_flow/utils/prefs.dart';

import '../../utils/header_api_option.dart';
import '../../utils/response_status.dart';

class ChangePasswordRepository {
  Dio _dio = Dio();

  void setDio(Dio dio) {
    _dio = dio;
  }


  Future<ChangePasswordResponse?> changePassword(
      ChangePasswordRequest changePasswordRequest) async {
    String url = "$BASE_URL$CHANGE_PASSWORD";
    print('URL:$url');
    print('Request :${changePasswordRequest.toJson()}');
    try {
      final Response response = await _dio.post(
        url,
        data: changePasswordRequest.toJson(),
        options: await HeaderApiConfig.getOptionsWithJWToken(),
      );
      var data = response.data;
      print('Response :$data');
      if (response.statusCode == SUCCESS) {
        ChangePasswordResponse addCustomerResponse =
        ChangePasswordResponse.fromJson(data);
        return addCustomerResponse;
      }
    } on DioException catch (e) {
      print("Response Error: ${e.response?.data}");
      ChangePasswordResponse addCustomerResponse =
      ChangePasswordResponse.fromJson(e.response?.data);
      return addCustomerResponse;
    }
    return null;
  }
}
