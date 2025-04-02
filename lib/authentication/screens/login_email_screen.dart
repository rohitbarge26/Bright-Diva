import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:frequent_flow/authentication/login_email_bloc/login_bloc.dart';
import 'package:frequent_flow/authentication/models/email/login_details.dart';
import 'package:frequent_flow/widgets/custom_alert.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../multi_language/model/language_list_response.dart';
import '../../utils/pref_key.dart';
import '../../utils/prefs.dart';
import '../../utils/route.dart';
import '../../utils/validation.dart';
import '../../widgets/custom_text.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../widgets/language_selection_dialog.dart';

class LoginEmailScreen extends StatefulWidget {
  const LoginEmailScreen({super.key});

  @override
  State<LoginEmailScreen> createState() => _LoginEmailScreenState();
}

class _LoginEmailScreenState extends State<LoginEmailScreen> {
  bool _obscureText = true;
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final _formEmailKey = GlobalKey<FormState>();
  Color buttonColor = const Color(0xFF88C2F7); // Initialize the button color
  String passwordErrorText = '';
  String emailErrorText = '';
  bool isButtonEnabled = false;
  bool clickLogin = false;
  int loginAttemptCount = 2;
  bool isBiometricDialogVisible = false;
  List<LanguageListData>? languageList;
  GlobalKey<State> loadingDialogKey = GlobalKey();

  void showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          surfaceTintColor: Colors.white,
          shadowColor: Colors.white,
          key: loadingDialogKey,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(19),
          ),
          child: Container(
            height: 180,
            padding: const EdgeInsets.all(16),
            child: const Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                      strokeWidth: 10.0,
                      color: Color(0xFF2986CC),
                      strokeCap: StrokeCap.round),
                  SizedBox(height: 24),
                  Text(
                    'Please Wait...',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF171717),
                      fontSize: 20,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.40,
                    ),
                  ),
                ]),
          ),
        );
      },
    );
  }

  void hideLoadingDialog() {
    if (loadingDialogKey.currentContext != null) {
      Navigator.of(loadingDialogKey.currentContext!, rootNavigator: true).pop();
    }
  }

  @override
  void initState() {
    String savedEmail = Prefs.getString(SAVED_EMAIL);
    if (savedEmail.isNotEmpty) {
      emailController.text = Prefs.getString(SAVED_EMAIL);
    }

    super.initState();
  }

  void _updateButtonColor() {
    setState(() {
      bool isEmailValid = Validator.emailValidate(emailController.text);
      bool isPasswordValid =
          Validator.emptyFieldValidate(passwordController.text);
      isButtonEnabled = isEmailValid && isPasswordValid;
      buttonColor =
          isButtonEnabled ? const Color(0xFF2986CC) : const Color(0xFF88C2F7);
    });
  }

  void _onButtonPressed() async {
    showLoadingDialog(context);
    setState(() {
      clickLogin = true;
    });
    FocusScope.of(context).requestFocus(FocusNode());
    // String? fcmToken = Prefs.getString(FCM_TOKEN);
    LoginDetails loginDetails = LoginDetails(
      emailAddress: emailController.text,
      password: passwordController.text,
    );
    print("Login details");
    context.read<LoginEmailBloc>().add(LoginUser(loginDetails: loginDetails));
  }

  void _showErrorDialog(BuildContext context, String errorMessage) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomAlert(
          title: "Error",
          message: errorMessage,
          buttonText: "OK",
          onButtonTap: () => Navigator.of(context).pop(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LoginEmailBloc, LoginState>(
      listener: (context, state) {
        if (state is LoginSuccess) {
          // Set login flag to true
          print("LoginSuccess");
          hideLoadingDialog();
          clickLogin = false;
          print(state.loginResponse.toJson());
          Prefs.setBool(LOGIN_FLAG, true);
          // Navigate to Dashboard
          Navigator.of(context).pushNamedAndRemoveUntil(
            ROUT_HOME,
            (route) => false,
          );
        } else if (state is LoginError) {
          hideLoadingDialog();
          clickLogin = false;
          print("login error");
          _showErrorDialog(context, state.error);
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: const Color(0xFFFFC6C6).withOpacity(0.2),
          body: SizedBox(
            height: MediaQuery.of(context).size.height,
            child: Stack(children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Form(
                    key: _formEmailKey,
                    child: Container(
                        margin: const EdgeInsets.all(5),
                        width: double.infinity,
                        height: null,
                        // You can set a specific height if needed
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(19),
                          color: Colors.white, // White background
                          border: Border.all(
                            color: Colors.black, // Black border
                            width: 1.0, // Border width
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              // Grey shadow
                              spreadRadius: 2,
                              // Spread radius
                              blurRadius: 5,
                              // Blur radius
                              offset: const Offset(0, 3), // Shadow position
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 48),
                              child: CustomText(
                                  text:
                                      AppLocalizations.of(context)!.labelLogin,
                                  fontSize: 24,
                                  desiredLineHeight: 29.05,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF262626)),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 16.0,
                                  right: 16.0,
                                  top: 32.0,
                                  bottom: 32.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
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
                                            emailErrorText = Validator
                                                    .emailValidate(value)
                                                ? ''
                                                : 'Please enter a valid email address';
                                          });
                                          _updateButtonColor();
                                        },
                                        style: const TextStyle(
                                          fontFamily: 'Inter',
                                          color: Color(0xFF171717),
                                          fontWeight: FontWeight.w400,
                                          height: 1.25,
                                          fontSize: 16,
                                        ),
                                        decoration: InputDecoration(
                                          labelText:
                                              AppLocalizations.of(context)!
                                                  .email,
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
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          left: 4, top: 12.0),
                                      child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(
                                              width: 16,
                                              height: 16,
                                              child: SvgPicture.asset(
                                                'assets/icon/error_icon.svg',
                                                height: 12.67,
                                                width: 12.67,
                                                alignment: Alignment.center,
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 4,
                                            ),
                                            Expanded(
                                              child: CustomText(
                                                text: emailErrorText,
                                                fontSize: 12,
                                                desiredLineHeight: 16,
                                                fontFamily: 'Inter',
                                                fontWeight: FontWeight.w500,
                                                color: const Color(0xFFF85A5A),
                                              ),
                                            ),
                                          ]),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 12,
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: const Color(0xFFE5E5E5),
                                          width: 1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Stack(children: <Widget>[
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 8.0, right: 46),
                                        child: TextFormField(
                                          controller: passwordController,
                                          obscureText: _obscureText,
                                          onChanged: (value) {
                                            setState(() {
                                              passwordErrorText =
                                                  Validator.emptyFieldValidate(
                                                          value)
                                                      ? ''
                                                      : '';
                                            });
                                            _updateButtonColor();
                                          },
                                          style: const TextStyle(
                                            fontFamily: 'Inter',
                                            color: Color(0xFF171717),
                                            fontWeight: FontWeight.w400,
                                            height: 1.25,
                                            fontSize: 16,
                                          ),
                                          decoration: InputDecoration(
                                            labelText:
                                                AppLocalizations.of(context)!
                                                    .password,
                                            labelStyle: TextStyle(
                                              color: Color(0xFF737373),
                                            ),
                                            border: InputBorder.none,
                                          ),
                                          keyboardType:
                                              TextInputType.visiblePassword,
                                          textInputAction: TextInputAction.done,
                                        ),
                                      ),
                                      Positioned(
                                        right: 14,
                                        top: 0,
                                        bottom: 0,
                                        child: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              _obscureText = !_obscureText;
                                            });
                                          },
                                          child: Icon(
                                            _obscureText
                                                ? Icons.visibility_off
                                                : Icons.visibility,
                                            color: const Color(0xffa3a3a3),
                                            size: 24,
                                          ),
                                        ),
                                      ),
                                    ]),
                                  ),
                                  Visibility(
                                    visible: passwordErrorText.isNotEmpty,
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          left: 4, top: 12.0),
                                      child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(
                                              width: 16,
                                              height: 16,
                                              child: SvgPicture.asset(
                                                'assets/icon/error_icon.svg',
                                                height: 12.67,
                                                width: 12.67,
                                                alignment: Alignment.center,
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 4,
                                            ),
                                            Expanded(
                                              child: CustomText(
                                                text: passwordErrorText,
                                                fontSize: 12,
                                                desiredLineHeight: 16,
                                                fontFamily: 'Inter',
                                                fontWeight: FontWeight.w500,
                                                color: const Color(0xFFF85A5A),
                                              ),
                                            ),
                                          ]),
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
                                      color: buttonColor,
                                    ),
                                    child: TextButton(
                                      onPressed: isButtonEnabled
                                          ? _onButtonPressed
                                          : null,
                                      child: CustomText(
                                          text: AppLocalizations.of(context)!
                                              .labelLogin,
                                          fontSize: 16,
                                          desiredLineHeight: 24,
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFFFFFFFF)),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 12,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        alignment: Alignment.centerLeft,
                                        child: InkWell(
                                          onTap: () {
                                            Navigator.pushNamed(
                                                context, ROUT_FORGOT_PASSWORD);
                                          },
                                          child: CustomText(
                                              text:
                                                  AppLocalizations.of(context)!
                                                      .forgotPassword,
                                              fontSize: 16,
                                              desiredLineHeight: 14.52,
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFF737373)),
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () {
                                          languageList = LanguageListResponse
                                                  .getStaticLanguages()
                                              .data;
                                          showDialog(
                                              barrierDismissible: false,
                                              context: context,
                                              builder: (context) =>
                                                  LanguageSelectionDialog(
                                                    onChangeLanguageTap: () {
                                                      Navigator.of(context)
                                                          .pop();
                                                      hideLoadingDialog();
                                                    },
                                                    data: languageList,
                                                  ));
                                        },
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            SvgPicture.asset(
                                              'assets/icons/language_icon.svg',
                                              height: 20,
                                              width: 20,
                                            ),
                                            const SizedBox(width: 4),
                                            CustomText(
                                                text: AppLocalizations.of(
                                                        context)!
                                                    .labelLanguage,
                                                fontSize: 16,
                                                desiredLineHeight: 16.94,
                                                fontFamily: 'Inter',
                                                color: Colors.black,
                                                fontWeight: FontWeight.w500),
                                            const SizedBox(width: 4),
                                            Center(
                                              child: SvgPicture.asset(
                                                'assets/icons/expand_more.svg',
                                                height: 20,
                                                width: 20,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                ],
                              ),
                            ),
                          ],
                        )), /*Container(
                        width: double.infinity,
                        height: null,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(19),
                          color: const Color(0xFFE5E5E5),
                        ),
                        child: ),*/
                  ),
                ],
              ),
              Positioned(
                bottom: 20, // Adjust the position as needed
                left: 5,
                right: 5,
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomText(
                          text: 'Copyright 2025 @ BrightDiva',
                          color: Colors.white,
                          fontSize: 14,
                          desiredLineHeight: 20,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w300),
                      CustomText(
                          text: '|',
                          color: Colors.white,
                          fontSize: 14,
                          desiredLineHeight: 20,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w300),
                      RichText(
                        text: TextSpan(
                          children: [
                            const TextSpan(
                              text: 'Powered By - ',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            TextSpan(
                              text: 'eDigiTech',
                              style: const TextStyle(
                                color: Colors.blue,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.underline,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  // Open the link in a browser
                                  launchUrl(
                                      Uri.parse('https://www.edigitech.in'));
                                },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Center(
                child: Visibility(
                  visible: clickLogin,
                  child: const CircularProgressIndicator(
                    color: Color(0XFFF85A5A),
                  ),
                ),
              ),
            ]),
          ),
        );
      },
    );
  }
}
