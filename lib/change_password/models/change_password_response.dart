
class ChangePasswordResponse {
  final int? statusCode;
  final bool? success;
  final String? message;

  ChangePasswordResponse({
    required this.statusCode,
    required this.success,
    required this.message,
  });

  factory ChangePasswordResponse.fromJson(Map<String, dynamic>? json) {
    return ChangePasswordResponse(
      statusCode: json?['statusCode'],
      success: json?['success'],
      message: json?['message'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'statusCode': statusCode,
      'success': success,
      'message': message,
    };
  }
}
