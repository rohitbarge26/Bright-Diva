import 'package:dio/dio.dart';
import 'package:frequent_flow/src/expected_payment_date/model/expected_date_request.dart';

import '../../../utils/api_constants.dart';
import '../../../utils/header_api_option.dart';
import '../../../utils/response_status.dart';
import '../model/expected_date_response.dart';

class ExpectedDateRepository {
  Dio _dio = Dio();

  void setDio(Dio dio) {
    _dio = dio;
  }

  Future<ExpectedDateResponse?> updateExpectedDate(ExpectedDateRequest request, String? invoiceId) async {
    String url = "$BASE_URL$EDIT_INVOICE$invoiceId";
    print('URL:$url');
    print('Request :${request.toJson()}');
    try {
      final Response response = await _dio.put(
        url,
        data: request.toJson(),
        options: await HeaderApiConfig.getOptionsWithJWToken(),
      );
      var data = response.data;
      print('Response :$data');
      if (response.statusCode == SUCCESS) {
        ExpectedDateResponse adduserResponse = ExpectedDateResponse.fromJson(data);
        return adduserResponse;
      }
    } on DioException catch (e) {
      print("Response Error: ${e.response?.data}");
      ExpectedDateResponse adduserResponse =
      ExpectedDateResponse.fromJson(e.response?.data);
      return adduserResponse;
    }
    return null;
  }


}