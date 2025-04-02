class EditCustomerResponse {
  String? error;
  bool? success;
  int? statusCode;

  EditCustomerResponse(
      {this.error, this.success, this.statusCode});

  EditCustomerResponse.fromJson(Map<String, dynamic> json) {
    error = json['error'];
    success = json['success'];
    statusCode = json['statusCode'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['error'] = this.error;
    data['success'] = this.success;
    data['statusCode'] = this.statusCode;
    return data;
  }
}
