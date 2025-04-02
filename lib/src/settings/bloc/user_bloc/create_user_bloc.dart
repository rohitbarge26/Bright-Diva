import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frequent_flow/src/settings/respository/UserRepository.dart';

import 'create_user_event.dart';
import 'create_user_state.dart';

class CreateUserBloc extends Bloc<CreateUserEvent, CreateUserState> {
  UserRepository userRepository;
  int currentPage = 0;
  bool isFetching = false;

  CreateUserBloc({required this.userRepository})
      : super(const CreateUserAddInitialState()) {
    on<AddNewUser>((event, emit) async {
      try {
        final userAddResponse =
        await userRepository.addUser(event.addUserRequest);
        emit(CreateUserAddLoadedState(userAddResponse: userAddResponse));
      } catch (e) {
        emit(CreateUserAddErrorState(error: e.toString()));
      }
    });
  }}