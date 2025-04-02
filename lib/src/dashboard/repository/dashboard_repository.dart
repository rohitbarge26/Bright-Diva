import 'package:dio/dio.dart';
import 'package:frequent_flow/src/dashboard/model/dashboard_chart_response.dart';

import '../../../utils/api_constants.dart';
import '../../../utils/header_api_option.dart';
import '../../../utils/response_status.dart';

class DashboardRepository {
  Dio _dio = Dio();

  void setDio(Dio dio) {
    _dio = dio;
  }

  Future<DashboardChartResponse?> getDashboardChartData() async {
    String url = "$BASE_URL$DASHBOARD_DATA";
    print("URL: $url");
    try {
      final Response response = await _dio.get(
        url,
        options: await HeaderApiConfig.getOptionsWithJWToken(),
      );
      var data = response.data;
      print("URL Response: $data");
      if (response.statusCode == SUCCESS) {
        DashboardChartResponse getJobDatesResponse =
        DashboardChartResponse.fromJson(data);
        return getJobDatesResponse;
      }
    } on DioException catch (e) {
      DashboardChartResponse getJobDatesResponse =
      DashboardChartResponse.fromJson(e.response?.data);
      return getJobDatesResponse;
    }
    return null;
  }

}