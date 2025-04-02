import 'package:dio/dio.dart';
import 'package:frequent_flow/src/settings/model/currency/currency_request.dart';
import '../../../utils/api_constants.dart';
import '../../../utils/header_api_option.dart';
import '../../../utils/response_status.dart';
import '../model/currency/get_currency_response.dart';
import '../model/currency/currency_response.dart';

class CurrencyRepository {
  Dio _dio = Dio();

  void setDio(Dio dio) {
    _dio = dio;
  }

  Future<CurrencyResponse?> updateCurrency(CurrencyRequest currencyRequest, String? user_id) async {
    String url = "$BASE_URL$CURRENCY_EDIT$user_id";
    print('URL:$url');
    print('Request :${currencyRequest.toJson()}');
    try {
      final Response response = await _dio.put(
        url,
        data: currencyRequest.toJson(),
        options: await HeaderApiConfig.getOptionsWithJWToken(),
      );
      var data = response.data;
      print('Response :$data');
      if (response.statusCode == SUCCESS) {
        CurrencyResponse adduserResponse = CurrencyResponse.fromJson(data);
        return adduserResponse;
      }
    } on DioException catch (e) {
      print("Response Error: ${e.response?.data}");
      CurrencyResponse adduserResponse =
      CurrencyResponse.fromJson(e.response?.data);
      return adduserResponse;
    }
    return null;
  }

  Future<GetCurrencyResponse?> getCurrencyRate() async {
    String url = "$BASE_URL$CURRENCY_LIST";
    print('URL:$url');
    try {
      final Response response = await _dio.get(
          url,
          options: await HeaderApiConfig.getOptionsWithJWToken(),
    );
    var data = response.data;
    print('Response :$data');
    if (response.statusCode == SUCCESS) {
      GetCurrencyResponse adduserResponse = GetCurrencyResponse.fromJson(data);
    return adduserResponse;
    }
    } on DioException catch (e) {
    print("Response Error: ${e.response?.data}");
    GetCurrencyResponse adduserResponse =
    GetCurrencyResponse.fromJson(e.response?.data);
    return adduserResponse;
    }
    return null;
  }
}
