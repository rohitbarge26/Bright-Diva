import 'package:dio/dio.dart';
import 'package:frequent_flow/src/cash_management/model/add_cash_receipt_request.dart';
import 'package:frequent_flow/src/cash_management/model/add_cash_receipt_response.dart';
import 'package:frequent_flow/src/cash_management/model/edit_cash_receipt_request.dart';

import '../../../utils/api_constants.dart';
import '../../../utils/header_api_option.dart';
import '../../../utils/response_status.dart';
import '../../customer_management/model/delete_customer.dart';
import '../../order_management/model/edit_invoice.dart';
import '../model/get_cash_receipt_by_id.dart';
import '../model/get_cash_receipt_response.dart';

class CashRepository {
  Dio _dio = Dio();

  void setDio(Dio dio) {
    _dio = dio;
  }

  Future<CashReceiptResponse?> addCash(
      CashReceiptRequest addCustomerRequest) async {
    String url = "$BASE_URL$ADD_CASH";
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
        CashReceiptResponse addCustomerResponse =
            CashReceiptResponse.fromJson(data);
        return addCustomerResponse;
      }
    } on DioException catch (e) {
      print("Response Error: ${e.response?.data}");
      CashReceiptResponse addCustomerResponse =
          CashReceiptResponse.fromJson(e.response?.data);
      return addCustomerResponse;
    }
    return null;
  }

  Future<CashDetailsByIdResponse?> getCashReceiptById(String cashId) async {
    String url = "$BASE_URL$GET_CASH_DETAILS$cashId";
    print("URL: $url");
    try {
      final Response response = await _dio.get(
        url,
        options: await HeaderApiConfig.getOptionsWithJWToken(),
      );
      var data = response.data;
      print("Response: $data");
      if (response.statusCode == SUCCESS) {
        CashDetailsByIdResponse getByIdResponse =
            CashDetailsByIdResponse.fromJson(data);
        return getByIdResponse;
      }
    } on DioException catch (e) {
      print("Response Error: ${e.response?.data}");
      CashDetailsByIdResponse getByIdResponse =
          CashDetailsByIdResponse.fromJson(e.response?.data);
      return getByIdResponse;
    }
    return null;
  }

  Future<GetCashReceiptResponse?> getCashReceipt(int currentPage) async {
    String url = "$BASE_URL$GET_CASH?page=$currentPage";
    print('URL:$url');
    try {
      final Response response = await _dio.get(
        url,
        options: await HeaderApiConfig.getOptionsWithJWToken(),
      );
      var data = response.data;
      print('Response :$data');
      if (response.statusCode == SUCCESS) {
        GetCashReceiptResponse getInvoice =
            GetCashReceiptResponse.fromJson(data);
        return getInvoice;
      }
    } on DioException catch (e) {
      GetCashReceiptResponse getInvoice =
          GetCashReceiptResponse.fromJson(e.response?.data);
      return getInvoice;
    }
    return null;
  }

  Future<DeleteCustomerResponse?> deleteCashReceipt(
      String cashReceiptId) async {
    String url = "$BASE_URL$DELETE_CASH$cashReceiptId";
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

  Future<EditInvoiceResponse?> editCashReceipt(String cashReceiptId, EditCashReceiptRequest editCashReceiptRequest) async {
    String url = "$BASE_URL$EDIT_CASH$cashReceiptId";
    print('URL:$url');
    print('Request: ${editCashReceiptRequest.toJson()}');
    try {
      final Response response = await _dio.put(
        url,
        data: editCashReceiptRequest.toJson(),
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
