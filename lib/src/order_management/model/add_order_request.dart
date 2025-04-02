class OrderAddRequest {
  String? orderNumber;
  String? invoiceNumber;
  int? amountOfDelivery;
  bool? partialDelivery;
  String? currency;
  int? deliveredUnits;
  String? customerId;

  OrderAddRequest(
      {required this.orderNumber,
        required this.invoiceNumber,
        required this.amountOfDelivery,
        required this.partialDelivery,
        required this.currency,
        required this.deliveredUnits,
        required this.customerId});

  OrderAddRequest.fromJson(Map<String, dynamic> json) {
    orderNumber = json['orderNumber'];
    invoiceNumber = json['invoiceNumber'];
    amountOfDelivery = json['amountOfDelivery'];
    partialDelivery = json['partialDelivery'];
    currency = json['currency'];
    deliveredUnits = json['deliveredUnits'];
    customerId = json['customerId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['orderNumber'] = this.orderNumber;
    data['invoiceNumber'] = this.invoiceNumber;
    data['amountOfDelivery'] = this.amountOfDelivery;
    data['partialDelivery'] = this.partialDelivery;
    data['currency'] = this.currency;
    data['deliveredUnits'] = this.deliveredUnits;
    data['customerId'] = this.customerId;
    return data;
  }
}
