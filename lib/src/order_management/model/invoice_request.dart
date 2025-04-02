class InvoiceRequest {
  String? invoiceNumber;
  String? customerId;
  int? amount;
  String? invoiceDate;
  String? currency;
  int? totalUnits;

  InvoiceRequest(
      { this.invoiceNumber,
        required this.customerId,
        required this.amount,
        required this.invoiceDate,
        required this.currency,
        required this.totalUnits});

  InvoiceRequest.fromJson(Map<String, dynamic> json) {
    invoiceNumber = json['invoiceNumber'];
    customerId = json['customerId'];
    amount = json['amount'];
    invoiceDate = json['invoiceDate'];
    currency = json['currency'];
    totalUnits = json['totalUnits'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['invoiceNumber'] = this.invoiceNumber;
    data['customerId'] = this.customerId;
    data['amount'] = this.amount;
    data['invoiceDate'] = this.invoiceDate;
    data['currency'] = this.currency;
    data['totalUnits'] = this.totalUnits;
    return data;
  }
}
