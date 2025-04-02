class LoginResponse {
  String? message;
  String? error;
  bool? success;
  User? user;
  int? statusCode;
  String? token;

  LoginResponse(
      {this.message,
        this.error,
        this.success,
        this.user,
        this.statusCode,
        this.token});

  LoginResponse.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    error = json['error'];
    success = json['success'];
    user = json['user'] != null ? new User.fromJson(json['user']) : null;
    statusCode = json['statusCode'];
    token = json['token'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['message'] = this.message;
    data['error'] = this.error;
    data['success'] = this.success;
    if (this.user != null) {
      data['user'] = this.user!.toJson();
    }
    data['statusCode'] = this.statusCode;
    data['token'] = this.token;
    return data;
  }
}

class User {
  String? id;
  String? name;
  String? username;
  String? emailId;
  String? password;
  String? role;
  String? phoneNo;
  String? token;
  String? createdAt;
  Null? updatedAt;
  String? createdBy;

  User(
      {this.id,
        this.name,
        this.username,
        this.emailId,
        this.password,
        this.role,
        this.phoneNo,
        this.token,
        this.createdAt,
        this.updatedAt,
        this.createdBy});

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    username = json['username'];
    emailId = json['emailId'];
    password = json['password'];
    role = json['role'];
    phoneNo = json['phoneNo'];
    token = json['token'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    createdBy = json['createdBy'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['username'] = this.username;
    data['emailId'] = this.emailId;
    data['password'] = this.password;
    data['role'] = this.role;
    data['phoneNo'] = this.phoneNo;
    data['token'] = this.token;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['createdBy'] = this.createdBy;
    return data;
  }
}
