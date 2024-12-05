import 'package:dio/dio.dart';
import 'package:frequent_flow/onboarding/models/user_model.dart';

class RegistrationRepository {
  final Dio _dio = Dio();

  RegistrationRepository();

  Future<String> registerUser(UserModel user) async {
    try {
      final response = await _dio.post(
        'http://192.168.1.2:9000/api/v1/user',
        data: user.toJson(),
        options: Options(
          headers: {
            "Content-Type": "application/json",
          }
        )
      );
      print("Success ${response.data['message']}");

      if (response.statusCode == 200) {
        return response.data['message'];
      } else {
        throw Exception("Failed to register user");
      }
    } on DioException catch (error) {
      print(error.toString());
      throw Exception(
          error.response?.data['error'] ?? "Unknown error occurred");
    } catch (error) {
      print(error.toString());
      throw Exception("Unknown error occurred");
    }
  }
}
