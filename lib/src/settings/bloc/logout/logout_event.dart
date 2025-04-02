import 'package:equatable/equatable.dart';
abstract class LogoutEvent extends Equatable {
  const LogoutEvent();

  @override
  List<Object> get props => [];
}

class LogoutUserEvent extends LogoutEvent {
  const LogoutUserEvent();

  @override
  List<Object> get props => [];
}
