import 'package:equatable/equatable.dart';

import '../models/mobile/login_mobile_get_otp_request.dart';

sealed class LoginMobileEvent extends Equatable {
  const LoginMobileEvent();
}

final class LoginMobileUserOTP extends LoginMobileEvent {
  final LoginMobileGetOTPRequest loginMobileGetOTPRequest;

  const LoginMobileUserOTP({
    required this.loginMobileGetOTPRequest,
  });

  @override
  List<Object?> get props => [loginMobileGetOTPRequest];
}
