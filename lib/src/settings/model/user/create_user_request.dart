class CreateUserRequest {
  String? name;
  String? username;
  String? role;
  String? phoneNo;
  String? emailId;
  String? password;

  CreateUserRequest(
      {required this.name,
        required this.username,
        required this.role,
        required this.phoneNo,
        required this.emailId,
        required this.password});

  CreateUserRequest.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    username = json['username'];
    role = json['role'];
    phoneNo = json['phoneNo'];
    emailId = json['emailId'];
    password = json['password'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['username'] = this.username;
    data['role'] = this.role;
    data['phoneNo'] = this.phoneNo;
    data['emailId'] = this.emailId;
    data['password'] = this.password;
    return data;
  }
}
