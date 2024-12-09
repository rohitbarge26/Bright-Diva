import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:frequent_flow/authentication/login_bloc/login_bloc.dart';
import 'package:frequent_flow/authentication/repository/login_repository.dart';
import 'package:frequent_flow/authentication/screens/login_mobile_screen.dart';
import 'package:frequent_flow/change_password/bloc/change_password_bloc.dart';
import 'package:frequent_flow/change_password/change_password_screen.dart';
import 'package:frequent_flow/change_password/repository/change_password_repository.dart';
import 'package:frequent_flow/modules/map_integration.dart';
import 'package:frequent_flow/onboarding/registration_bloc/registration_bloc.dart';
import 'package:frequent_flow/onboarding/repository/registration_repository.dart';
import 'package:frequent_flow/permissions/permissions_screen.dart';
import 'package:frequent_flow/push_notifications/push_notifications_screen.dart';
import 'package:frequent_flow/social_auth/social_login_screen.dart';
import 'package:frequent_flow/utils/prefs.dart';
import 'package:frequent_flow/utils/route.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'SplashScreen.dart';
import 'authentication/screens/login_email_screen.dart';
import 'dashboard/dashboard_screen.dart';
import 'onboarding/screens/registration.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: DarwinInitializationSettings(),
  );
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseMessaging.instance.setAutoInitEnabled(true);
  final fcmToken =
      Platform.isAndroid ? await FirebaseMessaging.instance.getToken() : "";
  print("FCMToken $fcmToken");
  await Prefs.init();
  runApp(MultiBlocProvider(providers: [
    BlocProvider<RegistrationBloc>(
      create: (context) => RegistrationBloc(RegistrationRepository()),
    ),
    BlocProvider<LoginBloc>(
      create: (context) => LoginBloc(loginRepository: LoginRepository()),
    ),
    BlocProvider<ChangePasswordBloc>(
      create: (context) => ChangePasswordBloc(
          changePasswordRepository: ChangePasswordRepository()),
    ),
  ], child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Frequent Flow',
      debugShowCheckedModeBanner: false,
      navigatorKey: rootNavigatorKey,
      theme: ThemeData(
        progressIndicatorTheme:
            const ProgressIndicatorThemeData(color: Color(0xfff68585)),
        primaryColor: const Color(0xfff68585),
        dialogTheme: const DialogTheme(
          backgroundColor: Colors.white,
        ),
      ),
      initialRoute: ROUT_SPLASH,
      onGenerateRoute: (setting) {
        switch (setting.name) {
          case ROUT_SPLASH:
            return MaterialPageRoute(builder: (BuildContext context) {
              return const SafeArea(top: false, child: SplashScreen());
            });
          case ROUT_LOGIN_EMAIL:
            return MaterialPageRoute(builder: (BuildContext context) {
              return const SafeArea(top: false, child: LoginEmailScreen());
            });
          case ROUT_DASHBOARD:
            return MaterialPageRoute(builder: (BuildContext context) {
              return const SafeArea(top: true, child: DashboardScreen());
            });
          case ROUT_REGISTRATION:
            return MaterialPageRoute(builder: (BuildContext context) {
              return const SafeArea(top: true, child: Registration());
            });
          case ROUT_MAP_INTEGRATION:
            return MaterialPageRoute(
              builder: (context) {
                return const SafeArea(child: MapSampleScreen());
              },
            );
          case ROUT_SOCIAL_MEDIA_INTEGRATION:
            return MaterialPageRoute(
              builder: (context) {
                return const SafeArea(child: SocialLogin());
              },
            );
          case ROUT_PERMISSION:
            return MaterialPageRoute(
              builder: (context) {
                return const SafeArea(child: PermissionsScreen());
              },
            );
          case ROUT_PUSH_NOTIFICATION:
            return MaterialPageRoute(
              builder: (context) {
                return const SafeArea(child: PushNotificationsScreen());
              },
            );
          case ROUT_CHANGE_PASSWORD:
            return MaterialPageRoute(
              builder: (context) {
                return const SafeArea(child: ChangePasswordScreen());
              },
            );
        }
        return null;
      },
    );
  }
}
