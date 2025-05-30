import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:frequent_flow/change_password/models/change_password_request.dart';
import 'package:frequent_flow/change_password/models/change_password_response.dart';
import 'package:frequent_flow/change_password/repository/change_password_repository.dart';

part 'change_password_event.dart';

part 'change_password_state.dart';

class ChangePasswordBloc
    extends Bloc<ChangePasswordEvent, ChangePasswordState> {
  ChangePasswordRepository changePasswordRepository;

  ChangePasswordBloc({required this.changePasswordRepository})
      : super(ChangePasswordInitial()) {
    on<ChangePassword>(_handleChangePassword);
  }

  Future<void> _handleChangePassword(
      ChangePassword event, Emitter<ChangePasswordState> emit) async {
    emit(ChangePasswordLoading());
    try {
      final changePasswdResponse =
      await changePasswordRepository.changePassword(event.changePasswordRequest);
      emit(ChangePasswordSuccess(response: changePasswdResponse));
      if (changePasswdResponse != null) {
        emit(ChangePasswordError(error: changePasswdResponse.message ?? "Password change failed"));
      } else {
        emit(const ChangePasswordError(error: "Unexpected Error"));
      }
    } catch (error) {
      emit(ChangePasswordError(error: error.toString()));
    }
  }
}
