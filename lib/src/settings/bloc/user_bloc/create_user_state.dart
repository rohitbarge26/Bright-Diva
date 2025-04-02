import 'package:equatable/equatable.dart';

import '../../model/user/create_user_response.dart';

abstract class CreateUserState extends Equatable {
  const CreateUserState();

  @override
  List<Object?> get props => [];
}

class CreateUserAddInitialState extends CreateUserState {
  const CreateUserAddInitialState();

  @override
  List<Object?> get props => [];
}

class CreateUserAddLoadedState extends CreateUserState {
  final CreateUserResponse? userAddResponse;

  const CreateUserAddLoadedState({required this.userAddResponse});

  @override
  List<Object?> get props => [userAddResponse];
}

class CreateUserAddErrorState extends CreateUserState {
  final String error;

  const CreateUserAddErrorState({required this.error});

  @override
  List<Object?> get props => [error];
}