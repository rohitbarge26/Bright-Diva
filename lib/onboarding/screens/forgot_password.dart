import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';

import '../../utils/app_functions.dart';
import '../../utils/route.dart';
import '../../utils/validation.dart';
import '../../widgets/custom_error.dart';
import '../../widgets/custom_text.dart';
import '../../widgets/custom_toast.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  final pinController = TextEditingController();
  final focusNode = FocusNode();

  bool isButtonEnabled = false;
  bool backButtonVisible = true;
  bool clickEmailSubmit = true;
  bool clickOTPSubmit = false;
  bool clickResetPassword = false;
  String emailErrorText = '';
  String otpErrorText = '';

  int timeLeft = 0;
  bool timerStartedOnce = false;
  Timer? timer;
  bool _obscurePasswordText = true;
  bool _obscureConfirmPasswordText = true;
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  Color buttonColor = const Color(0xFFFDBABA);
  Color buttonEmailColor = const Color(0xFFFDBABA);
  Color buttonOTPColor = const Color(0xFFFDBABA);
  Color buttonSetPasswordColor = const Color(0xFFFDBABA);

  String passwordErrorText = '';
  String confirmPasswordText = '';
  bool isVerifyingOTP = false;
  bool isResendCode = false;
  String resendMessage = '';
  int minutes = 1;
  int seconds = 0;

  final defaultPinTheme = PinTheme(
    width: 60,
    height: 70,
    textStyle: const TextStyle(
      fontSize: 24,
      fontFamily: 'Inter',
      fontWeight: FontWeight.w600,
    ),
    decoration: BoxDecoration(
      border: Border.all(color: const Color(0xFFEEE7E5), width: 1),
      borderRadius: BorderRadius.circular(9),
    ),
  );

  void _startTimer() {
    setState(() {
      timerStartedOnce = true;
    });
    Timer.periodic(const Duration(seconds: 1), (timer) {
      this.timer = timer;
      if (timeLeft > 0) {
        setState(() {
          timeLeft--;
          minutes = timeLeft ~/ 60;
          seconds = timeLeft % 60;
        });
      } else {
        setState(() {
          minutes = 1;
          seconds = 0;
        });
        timer.cancel();
      }
    });
  }

  bool validateOTP() {
    return pinController.text.length == 4;
  }

  void _updateOTPSubmitColor(String text) {
    setState(() {
      bool isOTPFieldValid = validateOTP();
      isButtonEnabled = isOTPFieldValid;
      buttonOTPColor =
          isOTPFieldValid ? const Color(0xFFF85A5A) : const Color(0xFFFDBABA);
    });
  }

  void _updateSetPasswordBtnColor() {
    setState(() {
      bool isPasswordValid =
          Validator.passwordValidate(passwordController.text);
      bool isConfirmPassword = Validator.confirmPasswordMatch(
          passwordController.text, confirmPasswordController.text);
      isButtonEnabled = isConfirmPassword && isPasswordValid;
      buttonSetPasswordColor =
          isButtonEnabled ? const Color(0xFFF85A5A) : const Color(0xFFFDBABA);
    });
  }

  void _onEmailSubmit() {
    //API call to get OTP
  }

  void _onOTPSubmit() {
    if (!validateOTP()) {
      return;
    } else {
      setState(() {
        isVerifyingOTP = true;
      });

      int intValue = int.parse(pinController.text);
      //API call to validate otp
    }
  }

  void _onSetPassword() {
    //API to call set new Password
  }

  @override
  void dispose() {
    pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) => showExitConfirmationDialog(
          context,
          'Confirm Exit',
          'Do you want to exit the password recovery process?',
          ROUT_SPLASH,
          false),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Visibility(
                  visible: clickEmailSubmit,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 24, right: 24),
                    child: Container(
                      key: _formKey,
                      width: double.infinity,
                      height: null,
                      child: Column(
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(
                                left: 16.0, right: 16.0, top: 48),
                            child: Column(
                              children: [
                                CustomText(
                                    text: 'Forgot Password',
                                    fontSize: 24,
                                    desiredLineHeight: 29.05,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF262626)),
                                SizedBox(
                                  height: 16,
                                ),
                                CustomText(
                                    text:
                                        'Please enter your email address to receive your One Time Password code.',
                                    textAlign: TextAlign.center,
                                    fontSize: 14,
                                    desiredLineHeight: 20,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w400,
                                    color: Color(0xFF737373)),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 16.0, right: 16.0, top: 32.0, bottom: 32),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: const Color(0xFFE5E5E5),
                                          width: 1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 8.0),
                                      child: TextFormField(
                                        controller: emailController,
                                        onChanged: (value) {
                                          setState(() {
                                            // Use the EmailValidator to validate and set error text
                                            emailErrorText = Validator
                                                    .emailValidate(value)
                                                ? ''
                                                : 'Please enter a valid email address';
                                          });
                                        },
                                        style: const TextStyle(
                                          fontFamily: 'Inter',
                                          color: Color(0xFF171717),
                                          fontWeight: FontWeight.w400,
                                          height: 1.25,
                                          fontSize: 16,
                                          // Other text style properties like fontWeight, fontFamily, etc. can also be added here.
                                        ),
                                        decoration: const InputDecoration(
                                          labelText: 'Email',
                                          labelStyle: TextStyle(
                                            color: Color(0xFF737373),
                                          ),
                                          border: InputBorder.none,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Visibility(
                                    visible: emailErrorText.isNotEmpty,
                                    child: CustomText(
                                      text: emailErrorText,
                                      fontSize: 12,
                                      desiredLineHeight: 16,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xFFF85A5A),
                                      textAlign: TextAlign.left,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 32,
                                  ),
                                  Container(
                                    width: double.infinity,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      color: const Color(0xFFF85A5A),
                                    ),
                                    child: TextButton(
                                      onPressed: isButtonEnabled
                                          ? _onEmailSubmit
                                          : null,
                                      child: const CustomText(
                                          text: 'Send',
                                          fontSize: 16,
                                          desiredLineHeight: 24,
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFFFFFFFF)),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 32,
                                  ),
                                ]),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Visibility(
                  visible: clickOTPSubmit,
                  child: Column(children: [
                    const Padding(
                      padding:
                          EdgeInsets.only(left: 16.0, right: 16.0, top: 48),
                      child: Column(
                        children: [
                          CustomText(
                              text: 'Password Recovery',
                              fontSize: 24,
                              desiredLineHeight: 29.05,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF404040)),
                          SizedBox(
                            height: 8,
                          ),
                          CustomText(
                              text: 'A code has been sent to your email.',
                              textAlign: TextAlign.center,
                              fontSize: 14,
                              desiredLineHeight: 20,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF737373)),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 16.0, right: 16.0, top: 32.0, bottom: 32),
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Visibility(
                              visible: otpErrorText.isNotEmpty,
                              child: Column(
                                children: [
                                  CustomError(errorText: otpErrorText),
                                  const SizedBox(
                                    height: 18,
                                  )
                                ],
                              ),
                            ),
                            Visibility(
                              visible: resendMessage.isNotEmpty,
                              child: Column(
                                children: [
                                  CustomToast(
                                      text: resendMessage, freeWidth: 124),
                                  const SizedBox(
                                    height: 18,
                                  )
                                ],
                              ),
                            ),
                            Pinput(
                              controller: pinController,
                              length: 4,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              focusNode: focusNode,
                              defaultPinTheme: defaultPinTheme,
                              focusedPinTheme: defaultPinTheme.copyWith(
                                  decoration: BoxDecoration(
                                border: Border.all(
                                  color: const Color(0xFFF85A5A),
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(9),
                              )),
                              onChanged: (value) =>
                                  _updateOTPSubmitColor(value),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            // Visibility(
                            //   visible: otpErrorText.isNotEmpty,
                            //   child: CustomText(
                            //     text: otpErrorText,
                            //     fontSize: 12,
                            //     desiredLineHeight: 16,
                            //     fontFamily: 'Inter',
                            //     fontWeight: FontWeight.w500,
                            //     color: const Color(0xFFF85A5A),
                            //     textAlign: TextAlign.left,
                            //   ),
                            // ),
                            const SizedBox(
                              height: 32,
                            ),
                            Column(children: [
                              InkWell(
                                onTap: () {
                                  // If timeLeft > 0, do nothing
                                  if (timeLeft == 0) {
                                    setState(() {
                                      isResendCode = true;
                                      //   set timeLeft to 60 and start timer once the code is sent successfully
                                    });
                                    /*BlocProvider.of<
                                        RegistrationBloc>(
                                        context)
                                        .add(
                                      SendOTP(
                                        sendOTPRequest: SendOTPRequest(
                                            type: 'Email',
                                            address:
                                            emailController
                                                .text,
                                            source:
                                            'FORGOT_PASSWORD'),
                                      ),
                                    );*/
                                  }
                                },
                                child: CustomText(
                                  text: timeLeft > 0
                                      ? '${'Resend New Code in'} ${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}'
                                      : '${'Resend'} ${timerStartedOnce ? ' ${'New'}' : ''} ${'Code'}',
                                  fontSize: 14,
                                  desiredLineHeight: 16.94,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w500,
                                  color: timeLeft > 0
                                      ? const Color(0xFFB3A7A4)
                                      : const Color(0xFF1F2937),
                                ),
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              Container(
                                width: double.infinity,
                                height: 50,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: buttonOTPColor,
                                ),
                                child: TextButton(
                                  onPressed:
                                      isButtonEnabled ? _onOTPSubmit : null,
                                  child: const CustomText(
                                      text: 'Verify',
                                      fontSize: 16,
                                      desiredLineHeight: 24,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFFFFFFFF)),
                                ),
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    timer?.cancel();
                                    timerStartedOnce = false;
                                    timeLeft = 0;
                                    minutes = 1;
                                    seconds = 0;
                                    emailErrorText = '';
                                    otpErrorText = '';
                                    resendMessage = '';
                                    clickEmailSubmit = true;
                                    clickOTPSubmit = false;
                                    isButtonEnabled = true;
                                    isVerifyingOTP = false;
                                    pinController.clear();
                                  });
                                },
                                child: const CustomText(
                                  text: 'Change Email',
                                  fontSize: 14,
                                  desiredLineHeight: 16.94,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF4B5563),
                                  textDecoration: TextDecoration.underline,
                                ),
                              ),
                            ]),
                          ]),
                    ),
                  ]),
                ),
                Visibility(
                  visible: clickResetPassword,
                  child: Column(children: [
                    const Padding(
                      padding:
                          EdgeInsets.only(left: 16.0, right: 16.0, top: 48),
                      child: CustomText(
                          text: 'Set a new password',
                          fontSize: 24,
                          desiredLineHeight: 29.05,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF262626)),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 16.0, right: 16.0, top: 32.0, bottom: 32),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: const Color(0xFFE5E5E5), width: 1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Stack(children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 8.0, right: 50.0),
                                  child: TextFormField(
                                    controller: passwordController,
                                    obscureText: _obscurePasswordText,
                                    onChanged: (value) {
                                      setState(() {
                                        passwordErrorText = Validator
                                                .passwordValidate(value)
                                            ? ''
                                            : 'Password do not meet requirements:\n\u2022 Must contain at least 8 characters\n\u2022 Must contain one special symbol (#, &, % etc)\n\u2022 Must contain one number (0-9)';
                                      });
                                      _updateSetPasswordBtnColor();
                                    },
                                    style: const TextStyle(
                                      fontFamily: 'Inter',
                                      color: Color(0xFF737373),
                                      fontSize: 16,
                                      // Other text style properties like fontWeight, fontFamily, etc. can also be added here.
                                    ),
                                    decoration: const InputDecoration(
                                      labelText: 'Password',
                                      labelStyle: TextStyle(
                                        color: Color(0xFF737373),
                                      ),
                                      border: InputBorder.none,
                                    ),
                                    keyboardType: TextInputType.visiblePassword,
                                    textInputAction: TextInputAction.done,
                                  ),
                                ),
                                Positioned(
                                  right: 14,
                                  top: 10,
                                  bottom: 0,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _obscurePasswordText =
                                            !_obscurePasswordText;
                                      });
                                    },
                                    child: Icon(
                                      _obscurePasswordText
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                      color: const Color(0xFFA3A3A3),
                                    ),
                                  ),
                                ),
                              ]),
                            ),
                            Visibility(
                              visible: passwordErrorText.isNotEmpty,
                              child: CustomText(
                                text: passwordErrorText,
                                fontSize: 12,
                                desiredLineHeight: 16,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFFF85A5A),
                                textAlign: TextAlign.left,
                              ),
                            ),
                            const SizedBox(
                              height: 12,
                            ),
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: const Color(0xFFE5E5E5), width: 1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Stack(children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 8.0, right: 50.0),
                                  child: TextFormField(
                                    controller: confirmPasswordController,
                                    obscureText: _obscureConfirmPasswordText,
                                    onChanged: (value) {
                                      setState(() {
                                        confirmPasswordText =
                                            Validator.confirmPasswordMatch(
                                                    passwordController.text,
                                                    value)
                                                ? ''
                                                : 'Passwords do not match';
                                      });
                                      _updateSetPasswordBtnColor();
                                    },
                                    style: const TextStyle(
                                      fontFamily: 'Inter',
                                      color: Color(0xFF737373),
                                      fontSize: 16,
                                      // Other text style properties like fontWeight, fontFamily, etc. can also be added here.
                                    ),
                                    decoration: const InputDecoration(
                                      labelText: 'Confirm Password',
                                      labelStyle: TextStyle(
                                        color: Color(0xFF737373),
                                      ),
                                      border: InputBorder.none,
                                    ),
                                    keyboardType: TextInputType.visiblePassword,
                                    textInputAction: TextInputAction.done,
                                  ),
                                ),
                                Positioned(
                                  right: 14,
                                  top: 10,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _obscureConfirmPasswordText =
                                            !_obscureConfirmPasswordText;
                                      });
                                    },
                                    child: Icon(
                                      _obscureConfirmPasswordText
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                      color: const Color(0xFFA3A3A3),
                                    ),
                                  ),
                                ),
                              ]),
                            ),
                            Visibility(
                              visible: confirmPasswordText.isNotEmpty,
                              child: CustomText(
                                text: confirmPasswordText,
                                fontSize: 12,
                                desiredLineHeight: 16,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFFF85A5A),
                                textAlign: TextAlign.left,
                              ),
                            ),
                            const SizedBox(
                              height: 32,
                            ),
                            Container(
                              width: double.infinity,
                              height: 50,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: buttonSetPasswordColor,
                              ),
                              child: TextButton(
                                onPressed:
                                    isButtonEnabled ? _onSetPassword : null,
                                child: const CustomText(
                                    text: 'Confirm',
                                    fontSize: 16,
                                    desiredLineHeight: 24,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFFFFFFFF)),
                              ),
                            ),
                            const SizedBox(
                              height: 32,
                            ),
                          ]),
                    ),
                  ]),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
