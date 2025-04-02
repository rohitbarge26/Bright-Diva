class CurrencyRequest {
  double? hkdToMop;
  double? hkdToCny;

  CurrencyRequest({required this.hkdToMop, required this.hkdToCny});

  CurrencyRequest.fromJson(Map<String, dynamic> json) {
    hkdToMop = json['hkdToMop'];
    hkdToCny = json['hkdToCny'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['hkdToMop'] = this.hkdToMop;
    data['hkdToCny'] = this.hkdToCny;
    return data;
  }
}
