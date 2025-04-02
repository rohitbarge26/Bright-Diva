class OrderEditRequest {
  int? amountOfDelivery;
  bool? partialDelivery;
  String? currency;
  int? deliveredUnits;

  OrderEditRequest(
      {
        required this.amountOfDelivery,
        required this.partialDelivery,
        required this.currency,
        required this.deliveredUnits});

  OrderEditRequest.fromJson(Map<String, dynamic> json) {
    amountOfDelivery = json['amountOfDelivery'];
    partialDelivery = json['partialDelivery'];
    currency = json['currency'];
    deliveredUnits = json['deliveredUnits'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['amountOfDelivery'] = this.amountOfDelivery;
    data['partialDelivery'] = this.partialDelivery;
    data['currency'] = this.currency;
    data['deliveredUnits'] = this.deliveredUnits;
    return data;
  }
}
