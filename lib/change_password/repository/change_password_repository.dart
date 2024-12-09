import 'package:dio/dio.dart';
import 'package:frequent_flow/change_password/models/change_password_request.dart';
import 'package:frequent_flow/change_password/models/change_password_response.dart';
import 'package:frequent_flow/utils/pref_key.dart';
import 'package:frequent_flow/utils/prefs.dart';

class ChangePasswordRepository {
  final _dio = Dio();

  ChangePasswordRepository();

  Future<ChangePasswordResponse?> changePassword(
      ChangePasswordRequest changePasswordRequest) async {
    print("Change Password request initiated");
    try {
      print(Prefs.getString(TOKEN));
      final response = await _dio.post(
        'http://192.168.1.2:9000/api/v1/user/change-password',
        data: changePasswordRequest.toJson(),
        options: Options(headers: {
          "Authorization": Prefs.getString(TOKEN),
          "Content-Type": "application/json",
        }),
      );

      print(response);

      var data = response.data;
      print(data);

      if (response.statusCode == 200) {
        final changePasswordResponse =
            ChangePasswordResponse.fromJson(data['details']);
        print(changePasswordResponse.message);
        return changePasswordResponse;
      }
    } on DioException catch (e) {
      ChangePasswordResponse changePasswordResponse =
          ChangePasswordResponse.fromJson(e.response!.data);
      print(changePasswordResponse.message);
      return changePasswordResponse;
    } catch (e) {
      print(e.toString());
      return null;
    }

    return null;
  }
}
