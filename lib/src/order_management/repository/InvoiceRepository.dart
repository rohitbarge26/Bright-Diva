import 'package:dio/dio.dart';
import 'package:frequent_flow/src/order_management/model/get_invoice_response.dart';
import 'package:frequent_flow/src/order_management/model/invoice_request.dart';

import '../../../utils/api_constants.dart';
import '../../../utils/header_api_option.dart';
import '../../../utils/response_status.dart';
import '../../customer_management/model/delete_customer.dart';
import '../model/edit_invoice.dart';
import '../model/edit_invoice_request.dart';
import '../model/get_invoice_by_id.dart';
import '../model/invoice_response.dart';

class InvoiceRepository {
  Dio _dio = Dio();

  void setDio(Dio dio) {
    _dio = dio;
  }

  Future<InvoiceResponse?> addInvoice(InvoiceRequest addInvoiceRequest) async {
    String url = "$BASE_URL$ADD_INVOICE";
    print('URL:$url');
    print('Request :${addInvoiceRequest.toJson()}');
    try {
      final Response response = await _dio.post(
        url,
        data: addInvoiceRequest.toJson(),
        options: await HeaderApiConfig.getOptionsWithJWToken(),
      );
      var data = response.data;
      print('Response :$data');
      if (response.statusCode == SUCCESS_CREATE) {
        InvoiceResponse addInvoice = InvoiceResponse.fromJson(data);
        return addInvoice;
      }
    } on DioException catch (e) {
      InvoiceResponse addInvoice = InvoiceResponse.fromJson(e.response?.data);
      return addInvoice;
    }
    return null;
  }

  Future<GetInvoiceResponse?> getInvoice(int currentPage) async {
    String url = "$BASE_URL$GET_INVOICE?page=$currentPage";
    print('URL:$url');
    try {
      final Response response = await _dio.get(
        url,
        options: await HeaderApiConfig.getOptionsWithJWToken(),
      );
      var data = response.data;
      print('Response :$data');
      if (response.statusCode == SUCCESS) {
        GetInvoiceResponse getInvoice = GetInvoiceResponse.fromJson(data);
        return getInvoice;
      }
    } on DioException catch (e) {
      GetInvoiceResponse getInvoice =
          GetInvoiceResponse.fromJson(e.response?.data);
      return getInvoice;
    }
    return null;
  }

  Future<InvoiceDetailsByIdResponse?> getInvoiceById(String invoiceId) async {
    String url = "$BASE_URL$GET_INVOICE_DETAILS$invoiceId";
    print("URL: $url");
    try {
      final Response response = await _dio.get(
        url,
        options: await HeaderApiConfig.getOptionsWithJWToken(),
      );
      var data = response.data;
      print("Response: $data");
      if (response.statusCode == SUCCESS) {
        InvoiceDetailsByIdResponse getByIdResponse =
            InvoiceDetailsByIdResponse.fromJson(data);
        print("Print Invoice Repository:: ${getByIdResponse.toString()}");
        return getByIdResponse;
      }
    } on DioException catch (e) {
      print("Response Error: ${e.response?.data}");
      InvoiceDetailsByIdResponse getByIdResponse =
          InvoiceDetailsByIdResponse.fromJson(e.response?.data);
      return getByIdResponse;
    }
    return null;
  }

  Future<DeleteCustomerResponse?> deleteInvoice(
      String invoiceId) async {
    String url = "$BASE_URL$DELETE_INVOICE$invoiceId";
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

  Future<EditInvoiceResponse?> editInvoice(String invoiceId, InvoiceEditRequest addCustomerRequest) async {
    String url = "$BASE_URL$EDIT_INVOICE$invoiceId";
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
