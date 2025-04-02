class EditCashReceiptRequest {
  int? amount;
  bool? partialDelivery;
  String? cashPickupDate;
  String? pickupTime;
  String? pickedBy;
  String? currency;

  EditCashReceiptRequest(
      {required this.amount,
        required this.partialDelivery,
        required this.cashPickupDate,
        required this.pickupTime,
        required this.pickedBy,
        required this.currency});

  EditCashReceiptRequest.fromJson(Map<String, dynamic> json) {
    amount = json['amount'];
    partialDelivery = json['partialDelivery'];
    cashPickupDate = json['cashPickupDate'];
    pickupTime = json['pickupTime'];
    pickedBy = json['pickedBy'];
    currency = json['currency'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['amount'] = this.amount;
    data['partialDelivery'] = this.partialDelivery;
    data['cashPickupDate'] = this.cashPickupDate;
    data['pickupTime'] = this.pickupTime;
    data['pickedBy'] = this.pickedBy;
    data['currency'] = this.currency;
    return data;
  }
}
