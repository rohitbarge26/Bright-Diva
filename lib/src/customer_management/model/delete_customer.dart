class DeleteCustomerResponse {
  bool? success;
  String? message;
  String? error;
  int? statusCode;

  DeleteCustomerResponse(
      {this.success, this.message, this.error, this.statusCode});

  DeleteCustomerResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    error = json['error'];
    statusCode = json['statusCode'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    data['message'] = this.message;
    data['error'] = this.error;
    data['statusCode'] = this.statusCode;
    return data;
  }
}
