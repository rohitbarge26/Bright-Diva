class CustomerAddResponse {
  bool? success;
  int? statusCode;
  String? id;

  @override
  String toString() {
    return 'CustomerAddResponse{success: $success, statusCode: $statusCode, id: $id}';
  }

  CustomerAddResponse({this.success, this.statusCode, this.id});

  CustomerAddResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    statusCode = json['statusCode'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    data['statusCode'] = this.statusCode;
    data['id'] = this.id;
    return data;
  }
}
