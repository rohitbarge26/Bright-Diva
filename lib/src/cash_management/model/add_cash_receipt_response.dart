class CashReceiptResponse {
  String? message;
  String? error;
  bool? success;
  int? statusCode;
  String? id;

  CashReceiptResponse(
      {this.message, this.error, this.success, this.statusCode, this.id});

  CashReceiptResponse.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    error = json['error'];
    success = json['success'];
    statusCode = json['statusCode'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['message'] = this.message;
    data['error'] = this.error;
    data['success'] = this.success;
    data['statusCode'] = this.statusCode;
    data['id'] = this.id;
    return data;
  }
}
