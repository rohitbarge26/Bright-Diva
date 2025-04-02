class ExpectedDateRequest {
  String? customerId;
  String? invoiceDate;
  String? expectedPaymentDate;

  ExpectedDateRequest(
      {required this.customerId, required this.invoiceDate, required this.expectedPaymentDate});

  ExpectedDateRequest.fromJson(Map<String, dynamic> json) {
    customerId = json['customerId'];
    invoiceDate = json['invoiceDate'];
    expectedPaymentDate = json['expectedPaymentDate'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['customerId'] = this.customerId;
    data['invoiceDate'] = this.invoiceDate;
    data['expectedPaymentDate'] = this.expectedPaymentDate;
    return data;
  }
}
