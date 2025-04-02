class CashReceiptRequest {
  String? invoiceNumber;
  String? receiptNumber;
  String? customerId;
  int? amount;
  bool? partialDelivery;
  String? cashPickupDate;
  String? pickupTime;
  String? pickedBy;
  String? currency;

  CashReceiptRequest(
      {required this.invoiceNumber,
        required this.receiptNumber,
        required this.customerId,
        required this.amount,
        required this.partialDelivery,
        required this.cashPickupDate,
        required this.pickupTime,
        required this.pickedBy,
        required this.currency});

  CashReceiptRequest.fromJson(Map<String, dynamic> json) {
    invoiceNumber = json['invoiceNumber'];
    receiptNumber = json['receiptNumber'];
    customerId = json['customerId'];
    amount = json['amount'];
    partialDelivery = json['partialDelivery'];
    cashPickupDate = json['cashPickupDate'];
    pickupTime = json['pickupTime'];
    pickedBy = json['pickedBy'];
    currency = json['currency'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['invoiceNumber'] = this.invoiceNumber;
    data['receiptNumber'] = this.receiptNumber;
    data['customerId'] = this.customerId;
    data['amount'] = this.amount;
    data['partialDelivery'] = this.partialDelivery;
    data['cashPickupDate'] = this.cashPickupDate;
    data['pickupTime'] = this.pickupTime;
    data['pickedBy'] = this.pickedBy;
    data['currency'] = this.currency;
    return data;
  }
}
