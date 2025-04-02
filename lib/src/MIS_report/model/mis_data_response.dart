class MISDataResponse {
  String? message;
  String? error;
  bool? success;
  String? url;
  int? statusCode;

  MISDataResponse(
      {this.message, this.error, this.success, this.url, this.statusCode});

  MISDataResponse.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    error = json['error'];
    success = json['success'];
    url = json['url'];
    statusCode = json['statusCode'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['message'] = this.message;
    data['error'] = this.error;
    data['success'] = this.success;
    data['url'] = this.url;
    data['statusCode'] = this.statusCode;
    return data;
  }
}
