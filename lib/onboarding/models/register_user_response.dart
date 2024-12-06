class RegisterUserResponse {
  final bool? success;
  final int? statusCode;
  final String? message;
  final String? error;

  RegisterUserResponse(
      {this.success, this.statusCode, this.message, this.error});

  factory RegisterUserResponse.fromJson(Map<String, dynamic> json) {
    return RegisterUserResponse(
        success: json['success'],
        statusCode: json['statusCode'],
        message: json['message'],
        error: json['error']);
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'statusCode': statusCode,
      'message': message,
      'error': error
    };
  }
}
