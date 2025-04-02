import 'package:dio/dio.dart';
import 'package:frequent_flow/src/customer_management/model/add_customer_request.dart';
import 'package:frequent_flow/src/customer_management/model/add_customer_response.dart';

import '../../../utils/api_constants.dart';
import '../../../utils/header_api_option.dart';
import '../../../utils/response_status.dart';
import '../model/delete_customer.dart';
import '../model/edit_customer.dart';
import '../model/get_customer.dart';

class CustomerRepository {
  Dio _dio = Dio();

  void setDio(Dio dio) {
    _dio = dio;
  }

  Future<CustomerAddResponse?> addCustomer(
      CustomerAddRequest addCustomerRequest) async {
    String url = "$BASE_URL$ADD_CUSTOMER";
    print('URL:$url');
    print('Request :${addCustomerRequest.toJson()}');
    try {
      final Response response = await _dio.post(
        url,
        data: addCustomerRequest.toJson(),
        options: await HeaderApiConfig.getOptionsWithJWToken(),
      );
      var data = response.data;
      print('Response :$data');
      if (response.statusCode == SUCCESS_CREATE) {
        CustomerAddResponse addCustomerResponse =
            CustomerAddResponse.fromJson(data);
        print("Data in Repository: ${addCustomerResponse.toString()}");
        return addCustomerResponse;
      }
    } on DioException catch (e) {
      print("Response Error: ${e.response?.data}");
      CustomerAddResponse addCustomerResponse =
          CustomerAddResponse.fromJson(e.response?.data);
      return addCustomerResponse;
    }
    return null;
  }

  Future<GetCustomerResponse?> getCustomer(int currentPage) async {
    String url = "$BASE_URL$GET_CUSTOMER?page=$currentPage";
    print("URL: $url");
    try {
      final Response response = await _dio.get(
        url,
        options: await HeaderApiConfig.getOptionsWithJWToken(),
      );
      var data = response.data;
      print("Response: $data");
      if (response.statusCode == SUCCESS) {
        GetCustomerResponse getCustomerResponse =
            GetCustomerResponse.fromJson(data);
        return getCustomerResponse;
      }
    } on DioException catch (e) {
      print("Response Error: ${e.response?.data}");
      GetCustomerResponse getCustomerResponse =
          GetCustomerResponse.fromJson(e.response?.data);
      return getCustomerResponse;
    }
    return null;
  }

  Future<DeleteCustomerResponse?> deleteCustomer(String customerId) async {
    String url = "$BASE_URL$DELETE_CUSTOMER$customerId";
    print('URL:$url');
    try {
      final Response response = await _dio.delete(
        url,
        options: await HeaderApiConfig.getOptionsWithJWToken(),
      );
      var data = response.data;
      print('Response :$data');
      if (response.statusCode == SUCCESS) {
        DeleteCustomerResponse addCustomerResponse =
        DeleteCustomerResponse.fromJson(data);
        return addCustomerResponse;
      }
    } on DioException catch (e) {
      DeleteCustomerResponse addCustomerResponse =
      DeleteCustomerResponse.fromJson(e.response?.data);
      return addCustomerResponse;
    }
    return null;
  }

  Future<EditCustomerResponse?> editCustomer(String customerId, CustomerAddRequest addCustomerRequest) async {
    String url = "$BASE_URL$EDIT_CUSTOMER$customerId";
    print('URL:$url');
    print('Request: ${addCustomerRequest.toJson()}');
    try {
      final Response response = await _dio.put(
        url,
        data: addCustomerRequest.toJson(),
        options: await HeaderApiConfig.getOptionsWithJWToken(),
      );
      var data = response.data;
      print('Response :$data');
      if (response.statusCode == SUCCESS) {
        EditCustomerResponse editCustomerResponse =
        EditCustomerResponse.fromJson(data);
        return editCustomerResponse;
      }
    } on DioException catch (e) {
      print('Error Response: ${e.response?.data}');
      EditCustomerResponse editCustomerResponse =
      EditCustomerResponse.fromJson(e.response?.data);
      return editCustomerResponse;
    }
    return null;
  }
}
