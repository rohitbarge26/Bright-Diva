import 'dart:async';

import 'package:flutter/material.dart';

import '../../utils/app_functions.dart';
import '../../utils/route.dart';
import '../../utils/validation.dart';
import '../../widgets/custom_text.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  final pinController = TextEditingController();

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
  Color buttonColor = const Color(0xFFFDBABA); // Initialize the button color
  String passwordErrorText = '';
  String confirmPasswordText = '';
  bool isVerifyingOTP = false;
  bool isResendCode = false;
  String resendMessage = '';
  int minutes = 1;
  int seconds = 0;

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
                Padding(
                  padding: const EdgeInsets.only(left: 24, right: 24),
                  child: Container(
                    key: _formKey,
                    width: double.infinity,
                    height: null,
                    child:  Column(
                      children: [
                        Padding(
                          padding:
                              EdgeInsets.only(left: 16.0, right: 16.0, top: 48),
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
                              left: 16.0,
                              right: 16.0,
                              top: 32.0,
                              bottom: 32),
                          child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color:
                                        const Color(0xFFE5E5E5),
                                        width: 1),
                                    borderRadius:
                                    BorderRadius.circular(8),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 8.0),
                                    child: TextFormField(
                                      controller: emailController,
                                      onChanged: (value) {
                                        setState(() {
                                          // Use the EmailValidator to validate and set error text
                                          emailErrorText = Validator
                                              .emailValidate(
                                              value)
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
                                        labelText:
                                        'Email',
                                        labelStyle: TextStyle(
                                          color: Color(0xFF737373),
                                        ),
                                        border: InputBorder.none,
                                      ),
                                    ),
                                  ),
                                ),
                                Visibility(
                                  visible:
                                  emailErrorText.isNotEmpty,
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
                                    borderRadius:
                                    BorderRadius.circular(8),
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
                                        color: Color(
                                            0xFFFFFFFF)),
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
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
