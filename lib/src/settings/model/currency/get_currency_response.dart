class GetCurrencyResponse {
  List<Currency>? currency;
  int? statusCode;

  GetCurrencyResponse({this.currency, this.statusCode});

  GetCurrencyResponse.fromJson(Map<String, dynamic> json) {
    if (json['currency'] != null) {
      currency = <Currency>[];
      json['currency'].forEach((v) {
        currency!.add(new Currency.fromJson(v));
      });
    }
    statusCode = json['statusCode'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.currency != null) {
      data['currency'] = this.currency!.map((v) => v.toJson()).toList();
    }
    data['statusCode'] = this.statusCode;
    return data;
  }
}

class Currency {
  String? id;
  String? baseCurrency;
  double? hkdToMop;
  double? hkdToCny;
  String? createdAt;
  String? updatedAt;
  String? createdBy;
  String? updatedBy;

  Currency(
      {this.id,
        this.baseCurrency,
        this.hkdToMop,
        this.hkdToCny,
        this.createdAt,
        this.updatedAt,
        this.createdBy,
        this.updatedBy});

  Currency.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    baseCurrency = json['baseCurrency'];
    hkdToMop = json['hkdToMop'];
    hkdToCny = json['hkdToCny'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    createdBy = json['createdBy'];
    updatedBy = json['updatedBy'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['baseCurrency'] = this.baseCurrency;
    data['hkdToMop'] = this.hkdToMop;
    data['hkdToCny'] = this.hkdToCny;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['createdBy'] = this.createdBy;
    data['updatedBy'] = this.updatedBy;
    return data;
  }
}
