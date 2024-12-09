import 'package:flutter/material.dart';
import 'package:frequent_flow/authentication/screens/login_mobile_screen.dart';
import 'package:frequent_flow/authentication/screens/login_option_screen.dart';
import 'package:frequent_flow/modules/map_integration.dart';
import 'package:frequent_flow/social_auth/social_login_screen.dart';
import 'package:frequent_flow/utils/prefs.dart';
import 'package:frequent_flow/utils/route.dart';

import 'SplashScreen.dart';
import 'authentication/screens/login_email_screen.dart';
import 'dashboard/dashboard_screen.dart';
import 'onboarding/screens/registration.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Prefs.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Frequent Flow',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        progressIndicatorTheme:
            const ProgressIndicatorThemeData(color: Color(0xFF2986CC)),
        primaryColor: const Color(0xFF2986CC),
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
          case ROUT_LOGIN_OPTION:
            return MaterialPageRoute(builder: (BuildContext context) {
              return const SafeArea(top: false, child: LoginOptionScreen());
            });
          case ROUT_LOGIN_EMAIL:
            return MaterialPageRoute(builder: (BuildContext context) {
              return const SafeArea(top: false, child: LoginEmailScreen());
            });
          case ROUT_LOGIN_MOBILE:
            return MaterialPageRoute(builder: (BuildContext context) {
              return const SafeArea(top: false, child: LoginMobileScreen());
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
        }
        return null;
      },
    );
  }
}
