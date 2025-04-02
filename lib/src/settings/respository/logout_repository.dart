import 'package:dio/dio.dart';
import '../../../utils/api_constants.dart';
import '../../../utils/header_api_option.dart';
import '../../../utils/response_status.dart';
import '../model/currency/get_currency_response.dart';
import '../model/currency/currency_response.dart';
import '../model/logout/logout_response.dart';

class LogoutRepository {
  Dio _dio = Dio();

  void setDio(Dio dio) {
    _dio = dio;
  }

  Future<LogoutResponse?> logout() async {
    String url = "$BASE_URL$LOGOUT";
    print('URL:$url');
    try {
      final Response response = await _dio.get(
        url,
        options: await HeaderApiConfig.getOptionsWithJWToken(),
      );
      var data = response.data;
      print('Response :$data');
      if (response.statusCode == SUCCESS) {
        LogoutResponse adduserResponse = LogoutResponse.fromJson(data);
        return adduserResponse;
      }
    } on DioException catch (e) {
      print("Response Error: ${e.response?.data}");
      LogoutResponse adduserResponse =
          LogoutResponse.fromJson(e.response?.data);
      return adduserResponse;
    }
    return null;
  }
}
