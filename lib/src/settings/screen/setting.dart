import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/svg.dart';
import 'package:frequent_flow/src/settings/bloc/logout/logout_bloc.dart';
import 'package:frequent_flow/src/settings/bloc/logout/logout_event.dart';
import 'package:frequent_flow/src/settings/bloc/logout/logout_state.dart';
import 'package:frequent_flow/src/settings/screen/sub_screens/change_language.dart';
import 'package:frequent_flow/src/settings/screen/sub_screens/create_user.dart';
import 'package:frequent_flow/src/settings/screen/sub_screens/currency.dart';
import 'package:frequent_flow/utils/response_status.dart';
import '../../../change_password/change_password_screen.dart';
import '../../../main.dart';
import '../../../utils/pref_key.dart';
import '../../../utils/prefs.dart';
import '../../../utils/route.dart';
import '../../../widgets/custom_text.dart';
import '../../../widgets/error_dialog.dart';
import '../../MIS_report/screen/mis_report.dart';

class Setting extends StatefulWidget {
  const Setting({super.key});

  @override
  State<Setting> createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  String? userRole;

  @override
  void initState() {
    super.initState();
    print("Get Invoice list");
    userRole = Prefs.getUser('user')?.role!;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LogoutBloc, LogoutState>(
      listener: (BuildContext context, LogoutState state) {
        if (state is LogoutInitialState) {
          const CircularProgressIndicator();
        } else if (state is LogoutLoadedState) {
          int code = state.logoutResponse?.statusCode ?? 0;
          print('Code : $code');
          if (code == SUCCESS) {
            Prefs.remove(TOKEN).then((_) {
              Prefs.setBool(LOGIN_FLAG, false).then((_) {
                rootNavigatorKey.currentState?.pushNamed(ROUT_SPLASH);
              });
            });
          } else {
            showDialog(
                barrierDismissible: false,
                context: context,
                builder: (context) => ErrorAlertDialog(
                    alertLogoPath: 'assets/icon/error_icon.svg',
                    status: AppLocalizations.of(context)!.unableToProcess,
                    statusInfo:
                        AppLocalizations.of(context)!.somethingWentWrong,
                    buttonText: AppLocalizations.of(context)!.btnOkay,
                    onPress: () {
                      Navigator.of(context).pop();
                    }));
          }
        }
      },
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.only(top: 68, right: 16.0, left: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomText(
                text: AppLocalizations.of(context)!.tabSetting,
                fontSize: 18,
                desiredLineHeight: 24,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
                color: const Color(0xFF171717),
              ),
              const SizedBox(
                height: 12,
              ),
              const Divider(
                color: Color(0xFFEEE7E5),
                thickness: 1.0,
                height: 20.0,
              ),
              //Currency
              if (userRole == 'Admin')
                Column(
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => Currency(
                              onBackTap: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 24, top: 16, bottom: 16, right: 24),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SvgPicture.asset(
                                      'assets/icons/currency_exchange.svg',
                                      width: 24,
                                      height: 24,
                                    ),
                                    const SizedBox(width: 16),
                                    CustomText(
                                      text: AppLocalizations.of(context)!
                                          .prCurrencySetup,
                                      fontSize: 14,
                                      desiredLineHeight: 20,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xFF171717),
                                      letterSpacing: 0.01,
                                    ),
                                  ]),
                              const Icon(
                                Icons.keyboard_arrow_right,
                                size: 24,
                                color: Colors.black,
                              )
                            ]),
                      ),
                    ),
                    const Divider(
                      color: Color(0xFFEEE7E5),
                      thickness: 1.0,
                      height: 20.0,
                    ),
                    //MIS Report
                    InkWell(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => MisReport(
                              onBackTap: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 24, top: 16, bottom: 16, right: 24),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SvgPicture.asset(
                                      'assets/icons/mis_report.svg',
                                      width: 24,
                                      height: 24,
                                    ),
                                    const SizedBox(width: 16),
                                    CustomText(
                                      text: AppLocalizations.of(context)!
                                          .misReport,
                                      fontSize: 14,
                                      desiredLineHeight: 20,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xFF171717),
                                      letterSpacing: 0.01,
                                    ),
                                  ]),
                              const Icon(
                                Icons.keyboard_arrow_right,
                                size: 24,
                                color: Colors.black,
                              )
                            ]),
                      ),
                    ),
                    const Divider(
                      color: Color(0xFFEEE7E5),
                      thickness: 1.0,
                      // height: 20.0,
                    ),
                  ],
                ),

              //Change Password
              InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ChangePasswordScreen(
                        onBackTap: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 24, top: 16, bottom: 16, right: 24),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SvgPicture.asset(
                                'assets/icons/change_password_icon.svg',
                                width: 24,
                                height: 24,
                              ),
                              const SizedBox(width: 16),
                              CustomText(
                                text: AppLocalizations.of(context)!
                                    .prChangePassword,
                                fontSize: 14,
                                desiredLineHeight: 20,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF171717),
                                letterSpacing: 0.01,
                              ),
                            ]),
                        const Icon(
                          Icons.keyboard_arrow_right,
                          size: 24,
                          color: Colors.black,
                        )
                      ]),
                ),
              ),
              const Divider(
                color: Color(0xFFEEE7E5),
                thickness: 1.0,
                height: 20.0,
              ),
              //Change Languages
              InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => LanguageSelection(
                        onBackArrowTap: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 24, top: 16, bottom: 16, right: 24),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SvgPicture.asset(
                                'assets/icons/pr_language_icon.svg',
                                width: 24,
                                height: 24,
                              ),
                              const SizedBox(width: 16),
                              CustomText(
                                text: AppLocalizations.of(context)!.prLanguage,
                                fontSize: 14,
                                desiredLineHeight: 20,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF171717),
                                letterSpacing: 0.01,
                              ),
                            ]),
                        const Icon(
                          Icons.keyboard_arrow_right,
                          size: 24,
                          color: Colors.black,
                        )
                      ]),
                ),
              ),
              const Divider(
                color: Color(0xFFEEE7E5),
                thickness: 1.0,
                height: 20.0,
              ),
              //Create User
              if (userRole == 'Admin')
                Column(
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => CreateUser(
                              onBackTap: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 24, top: 16, bottom: 16, right: 24),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SvgPicture.asset(
                                      'assets/icons/create_user.svg',
                                      width: 24,
                                      height: 24,
                                    ),
                                    const SizedBox(width: 16),
                                    CustomText(
                                      text: AppLocalizations.of(context)!
                                          .prCreateUser,
                                      fontSize: 14,
                                      desiredLineHeight: 20,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xFF171717),
                                      letterSpacing: 0.01,
                                    ),
                                  ]),
                              const Icon(
                                Icons.keyboard_arrow_right,
                                size: 24,
                                color: Colors.black,
                              )
                            ]),
                      ),
                    ),
                    const Divider(
                      color: Color(0xFFEEE7E5),
                      thickness: 1.0,
                      height: 20.0,
                    ),
                  ],
                ),
              //Logout
              InkWell(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        surfaceTintColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(19),
                        ),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Align(
                              alignment: Alignment.topRight,
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.of(context).pop();
                                },
                                child: SvgPicture.asset(
                                  'assets/icons/close_icon.svg',
                                  width: 24,
                                  height: 24,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            CustomText(
                              textAlign: TextAlign.center,
                              text: AppLocalizations.of(context)!.prLogOut,
                              fontFamily: 'Inter',
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              desiredLineHeight: 28,
                              letterSpacing: -0.40,
                              color: const Color(0xFF111827),
                            ),
                            const SizedBox(height: 16),
                            CustomText(
                              textAlign: TextAlign.center,
                              text:
                                  AppLocalizations.of(context)!.prLogoutMessage,
                              fontFamily: 'Inter',
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              desiredLineHeight: 20,
                              letterSpacing: -0.14,
                              color: const Color(0xFF1F2937),
                            ),
                            const SizedBox(height: 24.0),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Container(
                                      alignment: Alignment.center,
                                      height: 50,
                                      decoration: ShapeDecoration(
                                        shape: RoundedRectangleBorder(
                                          side: const BorderSide(
                                            width: 1,
                                            strokeAlign:
                                                BorderSide.strokeAlignCenter,
                                            color: Color(0xFFA3A3A3),
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                      ),
                                      child: CustomText(
                                        text:
                                            AppLocalizations.of(context)!.prNo,
                                        fontSize: 16,
                                        desiredLineHeight: 24,
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF404040),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16.0),
                                Expanded(
                                  flex: 1,
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.of(context).pop();
                                      BlocProvider.of<LogoutBloc>(context,
                                              listen: false)
                                          .add(const LogoutUserEvent());
                                    },
                                    child: Container(
                                      alignment: Alignment.center,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(6),
                                        color: const Color(0xFFF85A5A),
                                      ),
                                      child: CustomText(
                                        text:
                                            AppLocalizations.of(context)!.prYes,
                                        fontSize: 16,
                                        desiredLineHeight: 24,
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFFFFFFFF),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 24, top: 20, bottom: 20, right: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SvgPicture.asset(
                              'assets/icons/log_out_icon.svg',
                              width: 24,
                              height: 24,
                            ),
                            const SizedBox(width: 16),
                            CustomText(
                              text: AppLocalizations.of(context)!.prLogOut,
                              fontSize: 14,
                              desiredLineHeight: 20,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF171717),
                              letterSpacing: 0.01,
                            ),
                          ]),
                      const Icon(
                        Icons.keyboard_arrow_right,
                        size: 24,
                        color: Colors.black,
                      )
                    ],
                  ),
                ),
              ),
              const Divider(
                color: Color(0xFFEEE7E5),
                thickness: 1.0,
                height: 20.0,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
