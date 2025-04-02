class GetCashReceiptResponse {
  bool? success;
  int? statusCode;
  List<CashReceiptData>? data;
  String? message;
  String? error;
  int? total;

  GetCashReceiptResponse(
      {this.success,
        this.statusCode,
        this.data,
        this.message,
        this.error,
        this.total});

  GetCashReceiptResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    statusCode = json['statusCode'];
    if (json['data'] != null) {
      data = <CashReceiptData>[];
      json['data'].forEach((v) {
        data!.add(new CashReceiptData.fromJson(v));
      });
    }
    message = json['message'];
    error = json['error'];
    total = json['total'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    data['statusCode'] = this.statusCode;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['message'] = this.message;
    data['error'] = this.error;
    data['total'] = this.total;
    return data;
  }
}

class CashReceiptData {
  String? id;
  String? receiptNumber;
  String? invoiceNumber;
  String? customerId;
  String? amount;
  String? currency;
  String? amountInHkd;
  String? pickedBy;
  String? cashPickupDate;
  String? pickupTime;
  String? createdAt;
  String? updatedAt;
  String? createdBy;
  Customer? customer;

  CashReceiptData(
      {this.id,
        this.receiptNumber,
        this.invoiceNumber,
        this.customerId,
        this.amount,
        this.currency,
        this.amountInHkd,
        this.pickedBy,
        this.cashPickupDate,
        this.pickupTime,
        this.createdAt,
        this.updatedAt,
        this.createdBy,
        this.customer});

  CashReceiptData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    receiptNumber = json['receiptNumber'];
    invoiceNumber = json['invoiceNumber'];
    customerId = json['customerId'];
    amount = json['amount'];
    currency = json['currency'];
    amountInHkd = json['amountInHkd'];
    pickedBy = json['pickedBy'];
    cashPickupDate = json['cashPickupDate'];
    pickupTime = json['pickupTime'];
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
    data['receiptNumber'] = this.receiptNumber;
    data['invoiceNumber'] = this.invoiceNumber;
    data['customerId'] = this.customerId;
    data['amount'] = this.amount;
    data['currency'] = this.currency;
    data['amountInHkd'] = this.amountInHkd;
    data['pickedBy'] = this.pickedBy;
    data['cashPickupDate'] = this.cashPickupDate;
    data['pickupTime'] = this.pickupTime;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['createdBy'] = this.createdBy;
    data['invoice_number'] = this.invoiceNumber;
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
