import 'package:dio/dio.dart';
import 'package:frequent_flow/src/expected_payment_date/model/expected_date_request.dart';

import '../../../utils/api_constants.dart';
import '../../../utils/header_api_option.dart';
import '../../../utils/response_status.dart';
import '../model/mis_data_response.dart';

class MisRepository {
  Dio _dio = Dio();

  void setDio(Dio dio) {
    _dio = dio;
  }

  Future<MISDataResponse?> getMISReport(String type, String fromDate,
      String toDate, String customerId) async {
    String url = "";

    if (customerId == '') {
      url = "$BASE_URL$MISREPORT?type=$type&fromDate=$fromDate&toDate=$toDate";
    } else {
      url =
      "$BASE_URL$MISREPORT?type=$type&fromDate=$fromDate&toDate=$toDate&customerId=$customerId";
    }
    print('URL:$url');
    try {
      final Response response = await _dio.get(
        url,
        options: await HeaderApiConfig.getOptionsWithJWToken(),
      );
      var data = response.data;
      print('Response :$data');
      if (response.statusCode == SUCCESS) {
        MISDataResponse adduserResponse = MISDataResponse.fromJson(data);
        return adduserResponse;
      }
    } on DioException catch (e) {
      print("Response Error: ${e.response?.data}");
      MISDataResponse adduserResponse =
      MISDataResponse.fromJson(e.response?.data);
      return adduserResponse;
    }
    return null;
  }
}
