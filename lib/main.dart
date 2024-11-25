import 'package:flutter/material.dart';
import 'package:frequent_flow/utils/route.dart';

import 'SplashScreen.dart';
import 'dashboard/dashboard_screen.dart';

void main() {
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
          case ROUT_DASHBOARD:
            return MaterialPageRoute(builder: (BuildContext context) {
              return const SafeArea(top: true, child: DashboardScreen());
            });
        }
        return null;
      },
    );
  }
}

