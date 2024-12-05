import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frequent_flow/onboarding/repository/registration_repository.dart';

import '../models/user_model.dart';

part 'registration_event.dart';

part 'registration_state.dart';

class RegistrationBloc extends Bloc<RegistrationEvent, RegistrationState> {
  final RegistrationRepository registrationRepository;

  RegistrationBloc(this.registrationRepository) : super(RegistrationInitial()) {
    // on<RegistrationEvent>((event, emit) {
    //   // TODO: implement event handler
    // });
    on<RegisterUserEvent>(_handleRegisterUserEvent);
  }

  Future<void> _handleRegisterUserEvent(
      RegisterUserEvent event, Emitter<RegistrationState> emit) async {
    emit(RegistrationLoading());
    try {
      final message = await registrationRepository.registerUser(event.user);
      print("Message $message");
      emit(RegistrationSuccess(message));
    } catch (error) {
      emit(RegistrationError(error.toString()));
    }
  }
}
