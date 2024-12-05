part of 'registration_bloc.dart';

sealed class RegistrationState extends Equatable {
  const RegistrationState();
}

final class RegistrationInitial extends RegistrationState {
  @override
  List<Object> get props => [];
}

final class RegistrationLoading extends RegistrationState {
  @override
  List<Object?> get props => [];
}

final class RegistrationSuccess extends RegistrationState {
  final String message;

  const RegistrationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

final class RegistrationError extends RegistrationState {
  final String error;

  const RegistrationError(this.error);

  @override
  List<Object?> get props => [error];
}
