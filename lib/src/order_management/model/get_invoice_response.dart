class GetInvoiceResponse {
  List<Invoices>? invoices;
  int? total;
  int? statusCode;

  GetInvoiceResponse({this.invoices, this.total, this.statusCode});

  GetInvoiceResponse.fromJson(Map<String, dynamic> json) {
    if (json['invoices'] != null) {
      invoices = <Invoices>[];
      json['invoices'].forEach((v) {
        invoices!.add(new Invoices.fromJson(v));
      });
    }
    total = json['total'];
    statusCode = json['statusCode'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.invoices != null) {
      data['invoices'] = this.invoices!.map((v) => v.toJson()).toList();
    }
    data['total'] = this.total;
    data['statusCode'] = this.statusCode;
    return data;
  }
}

class Invoices {
  String? id;
  String? invoiceNumber;
  String? customerId;
  String? amount;
  int? totalUnits;
  String? currency;
  String? amountInHkd;
  String? invoiceDate;
  String? createdAt;
  String? updatedAt;
  String? createdBy;
  int? totalPaidAmount;
  int? remainingAmount;
  Customer? customer;

  Invoices(
      {this.id,
        this.invoiceNumber,
        this.customerId,
        this.amount,
        this.totalUnits,
        this.currency,
        this.amountInHkd,
        this.invoiceDate,
        this.createdAt,
        this.updatedAt,
        this.createdBy,
        this.totalPaidAmount,
        this.remainingAmount,
        this.customer});

  Invoices.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    invoiceNumber = json['invoiceNumber'];
    customerId = json['customerId'];
    amount = json['amount'];
    totalUnits = json['totalUnits'];
    currency = json['currency'];
    amountInHkd = json['amountInHkd'];
    invoiceDate = json['invoiceDate'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    createdBy = json['createdBy'];
    totalPaidAmount = json['totalPaidAmount'];
    remainingAmount = json['remainingAmount'];
    customer = json['customer'] != null
        ? new Customer.fromJson(json['customer'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['invoiceNumber'] = this.invoiceNumber;
    data['customerId'] = this.customerId;
    data['amount'] = this.amount;
    data['totalUnits'] = this.totalUnits;
    data['currency'] = this.currency;
    data['amountInHkd'] = this.amountInHkd;
    data['invoiceDate'] = this.invoiceDate;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['createdBy'] = this.createdBy;
    data['totalPaidAmount'] = this.totalPaidAmount;
    data['remainingAmount'] = this.remainingAmount;
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
