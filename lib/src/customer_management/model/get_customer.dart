class GetCustomerResponse {
  List<Customers>? customers;
  int? total;
  String? message;
  String? error;
  int? statusCode;

  GetCustomerResponse(
      {this.customers, this.total, this.message, this.error, this.statusCode});

  GetCustomerResponse.fromJson(Map<String, dynamic> json) {
    if (json['customers'] != null) {
      customers = <Customers>[];
      json['customers'].forEach((v) {
        customers!.add(new Customers.fromJson(v));
      });
    }
    total = json['total'];
    message = json['message'];
    error = json['error'];
    statusCode = json['statusCode'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.customers != null) {
      data['customers'] = this.customers!.map((v) => v.toJson()).toList();
    }
    data['total'] = this.total;
    data['message'] = this.message;
    data['error'] = this.error;
    data['statusCode'] = this.statusCode;
    return data;
  }
}

class Customers {
  String? id;
  String? address;
  String? city;
  String? country;
  String? contactPersonName;
  String? companyName;
  String? mobileNumber;
  String? emailId;
  String? businessRegistrationNumber;
  String? createdAt;
  String? updatedAt;
  String? createdBy;

  Customers(
      {this.id,
        this.address,
        this.city,
        this.country,
        this.contactPersonName,
        this.companyName,
        this.mobileNumber,
        this.emailId,
        this.businessRegistrationNumber,
        this.createdAt,
        this.updatedAt,
        this.createdBy});

  Customers.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    address = json['address'];
    city = json['city'];
    country = json['country'];
    contactPersonName = json['contactPersonName'];
    companyName = json['companyName'];
    mobileNumber = json['mobileNumber'];
    emailId = json['emailId'];
    businessRegistrationNumber = json['businessRegistrationNumber'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    createdBy = json['createdBy'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['address'] = this.address;
    data['city'] = this.city;
    data['country'] = this.country;
    data['contactPersonName'] = this.contactPersonName;
    data['companyName'] = this.companyName;
    data['mobileNumber'] = this.mobileNumber;
    data['emailId'] = this.emailId;
    data['businessRegistrationNumber'] = this.businessRegistrationNumber;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['createdBy'] = this.createdBy;
    return data;
  }
}
