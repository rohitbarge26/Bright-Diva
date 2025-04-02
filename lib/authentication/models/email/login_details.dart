class LoginDetails {
  final String emailAddress;
  final String password;

  LoginDetails({
    required this.emailAddress,
    required this.password,
  });

  factory LoginDetails.fromJson(Map<String, dynamic> json) {
    return LoginDetails(
      emailAddress: json['email'],
      password: json['password'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': emailAddress,
      'password': password,
    };
  }
}
