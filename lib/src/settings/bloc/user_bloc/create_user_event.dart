import 'package:equatable/equatable.dart';
import 'package:frequent_flow/src/settings/model/user/create_user_request.dart';

abstract class CreateUserEvent extends Equatable {
  const CreateUserEvent();
  @override
  List<Object> get props => [];
}

class AddNewUser extends CreateUserEvent {
  CreateUserRequest addUserRequest;

  AddNewUser({required this.addUserRequest});

  @override
  List<Object> get props => [addUserRequest];
}