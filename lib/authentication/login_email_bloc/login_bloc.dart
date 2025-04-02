import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:frequent_flow/authentication/models/email/login_details.dart';
import 'package:frequent_flow/authentication/models/email/login_response.dart';
import 'package:frequent_flow/authentication/repository/login_repository.dart';
import 'package:frequent_flow/utils/prefs.dart';

import '../../utils/pref_key.dart';

part 'login_event.dart';

part 'login_state.dart';

class LoginEmailBloc extends Bloc<LoginEvent, LoginState> {
  LoginRepository loginRepository;

  LoginEmailBloc({required this.loginRepository}) : super(LoginInitial()) {
    // on<LoginEvent>((event, e_loginUser //   // TODO: implement event handler
    // });
    on<LoginUser>(_loginUser);
  }

  FutureOr<void> _loginUser(LoginUser event, Emitter<LoginState> emit) async {
    emit(LoginLoading());
    try {
      final loginResponse = await loginRepository.loginUser(event.loginDetails);

      if (loginResponse != null) {
        // This condition is wrong
        print(loginResponse.toJson());
        if (loginResponse.error == null) {
          Prefs.setString(TOKEN, loginResponse.token);
          Prefs.setString(USER_ROLE,loginResponse.user!.role!);
          print('User Role: ${Prefs.getString(USER_ROLE)}');
          await Prefs.setUser('user', loginResponse.user!);
          emit(LoginSuccess(loginResponse: loginResponse));
        } else {
          emit(LoginError(error: loginResponse.error ?? "Unexpected error"));
        }
      } else {
        emit(const LoginError(error: "Unexpected Error"));
      }
    } catch (e) {
      emit(LoginError(error: e.toString()));
    }
  }
}
