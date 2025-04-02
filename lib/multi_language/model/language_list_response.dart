class LanguageListResponse {
  int? statusCode;
  bool? success;
  String? error;
  List<LanguageListData>? data;

  LanguageListResponse({this.statusCode, this.success, this.error, this.data});

  LanguageListResponse.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];
    success = json['success'];
    error = json['error'];
    if (json['data'] != null) {
      data = <LanguageListData>[];
      json['data'].forEach((v) {
        data!.add(new LanguageListData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['statusCode'] = this.statusCode;
    data['success'] = this.success;
    data['error'] = this.error;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
  /// **Static method to provide default English & Chinese data**
  static LanguageListResponse getStaticLanguages() {
    return LanguageListResponse(
      statusCode: 200,
      success: true,
      data: [
        LanguageListData(
          id: "1",
          name: "English",
          cultureCode: "en",
          flagImage: "🇬🇧", // You can use a URL instead
        ),
        LanguageListData(
          id: "2",
          name: "中文",
          cultureCode: "zh",
          flagImage: "🇨🇳",
        ),
      ],
    );
  }
}

class LanguageListData {
  String? id;
  String? name;
  String? cultureCode;
  String? flagImage;

  LanguageListData({this.id, this.name, this.cultureCode, this.flagImage});

  LanguageListData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    cultureCode = json['cultureCode'];
    flagImage = json['flagImage'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['cultureCode'] = this.cultureCode;
    data['flagImage'] = this.flagImage;
    return data;
  }
}
