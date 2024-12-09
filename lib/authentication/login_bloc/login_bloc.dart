import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:frequent_flow/authentication/models/login_details.dart';
import 'package:frequent_flow/authentication/models/login_response.dart';
import 'package:frequent_flow/authentication/repository/login_repository.dart';
import 'package:frequent_flow/utils/prefs.dart';

import '../../utils/pref_key.dart';

part 'login_event.dart';

part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginRepository loginRepository;

  LoginBloc({required this.loginRepository}) : super(LoginInitial()) {
    // on<LoginEvent>((event, e_loginUser //   // TODO: implement event handler
    // });
    on<LoginUser>(_loginUser);
  }

  FutureOr<void> _loginUser(LoginUser event, Emitter<LoginState> emit) async {
    emit(LoginLoading());
    try {
      print(event.loginDetails.toJson());
      final loginResponse = await loginRepository.loginUser(event.loginDetails);

      if (loginResponse != null) { // This condition is wrong
        print(loginResponse.toJson());
        Prefs.setString(TOKEN, loginResponse.token);
        Prefs.setString(REFRESH_TOKEN_KEY, loginResponse.refreshToken);
        emit(LoginSuccess(loginResponse: loginResponse));
      } else {
        emit(const LoginError(error: "Unexpected Error"));
      }
    } catch (e) {
      emit(LoginError(error: e.toString()));
    }
  }
}
