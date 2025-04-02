class OrderGetByIdResponse {
  Order? order;
  String? message;
  String? error;
  int? statusCode;

  OrderGetByIdResponse({this.order, this.message, this.error, this.statusCode});

  OrderGetByIdResponse.fromJson(Map<String, dynamic> json) {
    order = json['order'] != null ? new Order.fromJson(json['order']) : null;
    message = json['message'];
    error = json['error'];
    statusCode = json['statusCode'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.order != null) {
      data['order'] = this.order!.toJson();
    }
    data['message'] = this.message;
    data['error'] = this.error;
    data['statusCode'] = this.statusCode;
    return data;
  }
}

class Order {
  String? id;
  String? orderNumber;
  String? invoiceNumber;
  bool? partialDelivery;
  String? amountOfDelivery;
  String? currency;
  int? deliveredUnits;
  String? amountInHkd;
  String? customerId;
  String? createdAt;
  String? updatedAt;
  String? createdBy;
  Customer? customer;

  Order(
      {this.id,
        this.orderNumber,
        this.invoiceNumber,
        this.partialDelivery,
        this.amountOfDelivery,
        this.currency,
        this.deliveredUnits,
        this.amountInHkd,
        this.customerId,
        this.createdAt,
        this.updatedAt,
        this.createdBy,
        this.customer});

  Order.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    orderNumber = json['orderNumber'];
    invoiceNumber = json['invoiceNumber'];
    partialDelivery = json['partialDelivery'];
    amountOfDelivery = json['amountOfDelivery'];
    currency = json['currency'];
    deliveredUnits = json['deliveredUnits'];
    amountInHkd = json['amountInHkd'];
    customerId = json['customerId'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    createdBy = json['createdBy'];
    customer = json['customer'] != null
        ? new Customer.fromJson(json['customer'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['orderNumber'] = this.orderNumber;
    data['invoiceNumber'] = this.invoiceNumber;
    data['partialDelivery'] = this.partialDelivery;
    data['amountOfDelivery'] = this.amountOfDelivery;
    data['currency'] = this.currency;
    data['deliveredUnits'] = this.deliveredUnits;
    data['amountInHkd'] = this.amountInHkd;
    data['customerId'] = this.customerId;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['createdBy'] = this.createdBy;
    if (this.customer != null) {
      data['customer'] = this.customer!.toJson();
    }
    return data;
  }
}

class Customer {
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

  Customer(
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

  Customer.fromJson(Map<String, dynamic> json) {
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
