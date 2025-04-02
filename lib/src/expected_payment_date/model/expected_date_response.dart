class ExpectedDateResponse {
  String? message;
  String? error;
  bool? success;
  String? id;
  int? statusCode;

  ExpectedDateResponse(
      {this.message, this.error, this.success, this.id, this.statusCode});

  ExpectedDateResponse.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    error = json['error'];
    success = json['success'];
    id = json['id'];
    statusCode = json['statusCode'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['message'] = this.message;
    data['error'] = this.error;
    data['success'] = this.success;
    data['id'] = this.id;
    data['statusCode'] = this.statusCode;
    return data;
  }
}
