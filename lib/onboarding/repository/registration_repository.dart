import 'package:dio/dio.dart';
import 'package:frequent_flow/onboarding/models/register_user_response.dart';
import 'package:frequent_flow/onboarding/models/user_model.dart';

class RegistrationRepository {
  final Dio _dio = Dio();

  RegistrationRepository();

  Future<RegisterUserResponse?> registerUser(UserModel user) async {
    try {
      final response = await _dio.post('http://192.168.1.2:9000/api/v1/user',
          data: user.toJson(),
          options: Options(headers: {
            "Content-Type": "application/json",
          }));
      final data = response.data;
      print("Success $data");
      print("Success ${response.data['message']}");

      if (response.statusCode == 200) {
        RegisterUserResponse registerUserResponse =
            RegisterUserResponse.fromJson(data['data']);
        print(registerUserResponse.message);
        return registerUserResponse;
      }
    } on DioException catch (error) {
      RegisterUserResponse registerUserResponse =
          RegisterUserResponse.fromJson(error.response?.data);
      return registerUserResponse;
    }

    return null;
  }
}
