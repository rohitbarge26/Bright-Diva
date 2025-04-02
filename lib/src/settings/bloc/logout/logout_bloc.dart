import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frequent_flow/src/settings/bloc/logout/logout_event.dart';
import 'package:frequent_flow/src/settings/bloc/logout/logout_state.dart';
import 'package:frequent_flow/src/settings/respository/logout_repository.dart';

class LogoutBloc extends Bloc<LogoutEvent, LogoutState> {
  LogoutRepository userRepository;
  LogoutBloc({required this.userRepository})
      : super(const LogoutInitialState()) {
    on<LogoutUserEvent>((event, emit) async {
      try {
        final logoutResponseData =
        await userRepository.logout();
        emit(LogoutLoadedState(logoutResponse: logoutResponseData));
      } catch (e) {
        emit(LogoutErrorState(error: e.toString()));
      }
    });
  }}