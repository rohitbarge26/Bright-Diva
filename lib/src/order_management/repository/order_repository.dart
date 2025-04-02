import 'package:dio/dio.dart';
import 'package:frequent_flow/src/order_management/model/add_order_request.dart';
import 'package:frequent_flow/src/order_management/model/add_order_response.dart';
import 'package:frequent_flow/src/order_management/model/edit_order_request.dart';

import '../../../utils/api_constants.dart';
import '../../../utils/header_api_option.dart';
import '../../../utils/response_status.dart';
import '../../customer_management/model/delete_customer.dart';
import '../model/edit_invoice.dart';
import '../model/get_order_by_id.dart';
import '../model/get_order_response.dart';

class OrderRepository {
  Dio _dio = Dio();

  void setDio(Dio dio) {
    _dio = dio;
  }

  Future<OrderAddResponse?> addOrder(OrderAddRequest addOrderRequest) async {
    String url = "$BASE_URL$ADD_ORDER";
    print('URL:$url');
    print('Request :${addOrderRequest.toJson()}');
    try {
      final Response response = await _dio.post(
        url,
        data: addOrderRequest.toJson(),
        options: await HeaderApiConfig.getOptionsWithJWToken(),
      );
      var data = response.data;
      print('Response :$data');
      if (response.statusCode == SUCCESS_CREATE) {
        OrderAddResponse addInvoice = OrderAddResponse.fromJson(data);
        return addInvoice;
      }
    } on DioException catch (e) {
      print('Error Response :${e.response?.data}');
      OrderAddResponse addInvoice = OrderAddResponse.fromJson(e.response?.data);
      return addInvoice;
    }
    return null;
  }

  Future<OrderGetResponse?> getOrderList(int currentPage) async {
    String url = "$BASE_URL$GET_ORDER?page=$currentPage";
    print("URL: $url");
    try {
      final Response response = await _dio.get(
        url,
        options: await HeaderApiConfig.getOptionsWithJWToken(),
      );
      var data = response.data;
      print("Response: $data");
      if (response.statusCode == SUCCESS) {
        OrderGetResponse getOrderResponse = OrderGetResponse.fromJson(data);
        return getOrderResponse;
      }
    } on DioException catch (e) {
      print("Response Error: ${e.response?.data}");
      OrderGetResponse getOrderResponse =
          OrderGetResponse.fromJson(e.response?.data);
      return getOrderResponse;
    }
    return null;
  }

  Future<OrderGetByIdResponse?> getOrderDetails(String orderId) async {
    String url = "$BASE_URL$GET_ORDER_DETAILS$orderId";
    print("URL: $url");
    try {
      final Response response = await _dio.get(
        url,
        options: await HeaderApiConfig.getOptionsWithJWToken(),
      );
      var data = response.data;
      print("Response: $data");
      if (response.statusCode == SUCCESS) {
        OrderGetByIdResponse getByIdResponse =
            OrderGetByIdResponse.fromJson(data);
        return getByIdResponse;
      }
    } on DioException catch (e) {
      print("Response Error: ${e.response?.data}");
      OrderGetByIdResponse getByIdResponse =
          OrderGetByIdResponse.fromJson(e.response?.data);
      return getByIdResponse;
    }
    return null;
  }

  Future<DeleteCustomerResponse?> deleteOrder(String invoiceId) async {
    String url = "$BASE_URL$DELETE_ORDER$invoiceId";
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

  Future<EditInvoiceResponse?> editOrder(
      String orderId, OrderEditRequest orderEditRequest) async {
    String url = "$BASE_URL$EDIT_ORDER$orderId";
    print('URL:$url');
    print('Request: ${orderEditRequest.toJson()}');
    try {
      final Response response = await _dio.put(
        url,
        data: orderEditRequest.toJson(),
        options: await HeaderApiConfig.getOptionsWithJWToken(),
      );
      var data = response.data;
      print('Response :$data');
      if (response.statusCode == SUCCESS) {
        EditInvoiceResponse editCustomerResponse =
            EditInvoiceResponse.fromJson(data);
        return editCustomerResponse;
      }
    } on DioException catch (e) {
      print('Error Response: ${e.response?.data}');
      EditInvoiceResponse editCustomerResponse =
          EditInvoiceResponse.fromJson(e.response?.data);
      return editCustomerResponse;
    }
    return null;
  }
}
