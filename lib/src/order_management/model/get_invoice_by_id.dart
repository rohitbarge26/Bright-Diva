class InvoiceDetailsByIdResponse {
  String? message;
  String? error;
  InvoiceDetails? invoice;
  int? totalPaidAmount;
  int? remainingAmount;
  int? statusCode;

  InvoiceDetailsByIdResponse(
      {this.message,
      this.error,
      this.invoice,
      this.totalPaidAmount,
      this.remainingAmount,
      this.statusCode});

  InvoiceDetailsByIdResponse.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    error = json['error'];
    invoice = json['invoice'] != null
        ? new InvoiceDetails.fromJson(json['invoice'])
        : null;
    totalPaidAmount = json['totalPaidAmount'];
    remainingAmount = json['remainingAmount'];
    statusCode = json['statusCode'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['message'] = this.message;
    data['error'] = this.error;
    if (this.invoice != null) {
      data['invoice'] = this.invoice!.toJson();
    }
    data['totalPaidAmount'] = this.totalPaidAmount;
    data['remainingAmount'] = this.remainingAmount;
    data['statusCode'] = this.statusCode;
    return data;
  }
}

class InvoiceDetails {
  String? id;
  String? invoiceNumber;
  String? customerId;
  String? amount;
  int? totalUnits;
  String? currency;
  String? amountInHkd;
  String? invoiceDate;
  String? expectedPaymentDate;
  String? createdAt;
  String? updatedAt;
  String? createdBy;
  Customer? customer;

  InvoiceDetails(
      {this.id,
      this.invoiceNumber,
      this.customerId,
      this.amount,
      this.totalUnits,
      this.currency,
      this.amountInHkd,
      this.invoiceDate,
      this.expectedPaymentDate,
      this.createdAt,
      this.updatedAt,
      this.createdBy,
      this.customer});

  InvoiceDetails.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    invoiceNumber = json['invoiceNumber'];
    customerId = json['customerId'];
    amount = json['amount'];
    totalUnits = json['totalUnits'];
    currency = json['currency'];
    amountInHkd = json['amountInHkd'];
    invoiceDate = json['invoiceDate'];
    expectedPaymentDate = json['expectedPaymentDate'] ?? 'N/A';
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
    data['invoiceNumber'] = this.invoiceNumber;
    data['customerId'] = this.customerId;
    data['amount'] = this.amount;
    data['totalUnits'] = this.totalUnits;
    data['currency'] = this.currency;
    data['amountInHkd'] = this.amountInHkd;
    data['invoiceDate'] = this.invoiceDate;
    data['expectedPaymentDate'] = this.expectedPaymentDate;
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

  @override
  String toString() {
    return 'Customer{id: $id, address: $address, city: $city, country: $country, contactPersonName: $contactPersonName, companyName: $companyName, mobileNumber: $mobileNumber, emailId: $emailId, businessRegistrationNumber: $businessRegistrationNumber, createdAt: $createdAt, updatedAt: $updatedAt, createdBy: $createdBy}';
  }
}
