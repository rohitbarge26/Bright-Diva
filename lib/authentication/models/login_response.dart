class LoginResponse {
  final String? error;
  final String? token;
  final String? refreshToken;

  LoginResponse({
    this.error,
    this.token,
    this.refreshToken,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      error: json['error'],
      token: json['token'],
      refreshToken: json['refreshToken'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'error': error,
      'token': token,
      'refreshToken': refreshToken,
    };
  }
}
