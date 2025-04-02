import 'package:equatable/equatable.dart';

import '../../model/logout/logout_response.dart';
import '../../model/user/create_user_response.dart';

abstract class LogoutState extends Equatable {
  const LogoutState();

  @override
  List<Object?> get props => [];
}

class LogoutInitialState extends LogoutState {
  const LogoutInitialState();

  @override
  List<Object?> get props => [];
}

class LogoutLoadedState extends LogoutState {
  final LogoutResponse? logoutResponse;

  const LogoutLoadedState({required this.logoutResponse});

  @override
  List<Object?> get props => [logoutResponse];
}

class LogoutErrorState extends LogoutState {
  final String error;

  const LogoutErrorState({required this.error});

  @override
  List<Object?> get props => [error];
}