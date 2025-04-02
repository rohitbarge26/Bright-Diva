class DashboardChartResponse {
  double? totalOrderValue;
  double? totalDeliveredValue;
  double? nonDeliveredValue;
  double? totalCashPickup;
  double? deliveredCashPickup;
  double? totalNetDue;

  DashboardChartResponse(
      {this.totalOrderValue,
        this.totalDeliveredValue,
        this.nonDeliveredValue,
        this.totalCashPickup,
        this.deliveredCashPickup,
        this.totalNetDue});

  factory DashboardChartResponse.fromJson(Map<String, dynamic> json) {
    return DashboardChartResponse(
      totalOrderValue: (json['totalOrderValue'] as num?)?.toDouble() ?? 0.0,
      totalDeliveredValue: (json['totalDeliveredValue'] as num?)?.toDouble() ?? 0.0,
      nonDeliveredValue: (json['nonDeliveredValue'] as num?)?.toDouble() ?? 0.0,
      totalCashPickup: (json['totalCashPickup'] as num?)?.toDouble() ?? 0.0,
      deliveredCashPickup: (json['deliveredCashPickup'] as num?)?.toDouble() ?? 0.0,
      totalNetDue: (json['totalNetDue'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['totalOrderValue'] = this.totalOrderValue;
    data['totalDeliveredValue'] = this.totalDeliveredValue;
    data['nonDeliveredValue'] = this.nonDeliveredValue;
    data['totalCashPickup'] = this.totalCashPickup;
    data['deliveredCashPickup'] = this.deliveredCashPickup;
    data['totalNetDue'] = this.totalNetDue;
    return data;
  }
}
