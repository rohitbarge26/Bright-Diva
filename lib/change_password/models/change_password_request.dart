class ChangePasswordRequest {
  final String oldPassword;
  final String newPassword;

  ChangePasswordRequest({
    required this.oldPassword,
    required this.newPassword,
  });

  factory ChangePasswordRequest.fromJson(Map<String, dynamic> json) {
    return ChangePasswordRequest(
      oldPassword: json['email'],
      newPassword: json['password'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': oldPassword,
      'password': newPassword,
    };
  }
}
