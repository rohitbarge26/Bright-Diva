class OrderEditRequest {
  int? amountOfDelivery;
  bool? partialDelivery;
  String? currency;
  int? deliveredUnits;
  String? deliveredBy;

  OrderEditRequest(
      {
        required this.amountOfDelivery,
        required this.partialDelivery,
        required this.currency,
        required this.deliveredUnits,
        required this.deliveredBy});

  OrderEditRequest.fromJson(Map<String, dynamic> json) {
    amountOfDelivery = json['amountOfDelivery'];
    partialDelivery = json['partialDelivery'];
    currency = json['currency'];
    deliveredUnits = json['deliveredUnits'];
    deliveredBy = json['deliveredBy'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['amountOfDelivery'] = this.amountOfDelivery;
    data['partialDelivery'] = this.partialDelivery;
    data['currency'] = this.currency;
    data['deliveredUnits'] = this.deliveredUnits;
    data['deliveredBy'] = this.deliveredBy;
    return data;
  }
}
