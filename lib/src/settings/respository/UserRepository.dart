import 'package:dio/dio.dart';
import 'package:frequent_flow/src/settings/model/user/create_user_request.dart';

import '../../../utils/api_constants.dart';
import '../../../utils/header_api_option.dart';
import '../../../utils/response_status.dart';
import '../model/user/create_user_response.dart';

class UserRepository {
  Dio _dio = Dio();

  void setDio(Dio dio) {
    _dio = dio;
  }

  Future<CreateUserResponse?> addUser(CreateUserRequest addUserRequest) async {
    String url = "$BASE_URL$CREATE_USER";
    print('URL:$url');
    print('Request :${addUserRequest.toJson()}');
    try {
      final Response response = await _dio.post(
        url,
        data: addUserRequest.toJson(),
        options: await HeaderApiConfig.getOptionsWithJWToken(),
      );
      var data = response.data;
      print('Response :$data');
      if (response.statusCode == SUCCESS) {
        CreateUserResponse adduserResponse = CreateUserResponse.fromJson(data);
        return adduserResponse;
      }
    } on DioException catch (e) {
      print("Response Error: ${e.response?.data}");
      CreateUserResponse adduserResponse =
          CreateUserResponse.fromJson(e.response?.data);
      return adduserResponse;
    }
    return null;
  }
}
