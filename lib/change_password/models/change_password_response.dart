import 'dart:ffi';

class ChangePasswordResponse {
  final Int statusCode;
  final String success;
  final String error;
  final String message;

  ChangePasswordResponse({
    required this.statusCode,
    required this.success,
    required this.error,
    required this.message,
  });

  factory ChangePasswordResponse.fromJson(Map<String, dynamic> json) {
    return ChangePasswordResponse(
      statusCode: json['statusCode'],
      success: json['success'],
      error: json['error'],
      message: json['message'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'statusCode': statusCode,
      'success': success,
      'error': error,
      'message': message,
    };
  }
}
