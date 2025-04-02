class CurrencyResponse {
  bool? success;
  int? statusCode;

  CurrencyResponse({this.success, this.statusCode});

  CurrencyResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    statusCode = json['statusCode'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    data['statusCode'] = this.statusCode;
    return data;
  }
}
