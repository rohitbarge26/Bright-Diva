import 'dart:io';

import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:frequent_flow/authentication/login_email_bloc/login_bloc.dart';
import 'package:frequent_flow/authentication/repository/login_repository.dart';
import 'package:frequent_flow/change_password/bloc/change_password_bloc.dart';
import 'package:frequent_flow/change_password/repository/change_password_repository.dart';
import 'package:frequent_flow/onboarding/bloc/forgot_password_bloc/forgot_password_bloc.dart';
import 'package:frequent_flow/onboarding/registration_bloc/registration_bloc.dart';
import 'package:frequent_flow/onboarding/repository/forgot_password_repository.dart';
import 'package:frequent_flow/onboarding/repository/registration_repository.dart';
import 'package:frequent_flow/onboarding/screens/forgot_password.dart';
import 'package:frequent_flow/permissions/permissions_screen.dart';
import 'package:frequent_flow/src/MIS_report/bloc/mis_bloc.dart';
import 'package:frequent_flow/src/MIS_report/repository/mis_repository.dart';
import 'package:frequent_flow/src/cash_management/bloc/cash_bloc.dart';
import 'package:frequent_flow/src/cash_management/repository/cash_repository.dart';
import 'package:frequent_flow/src/customer_management/bloc/customer_bloc.dart';
import 'package:frequent_flow/src/customer_management/repository/customer_repository.dart';
import 'package:frequent_flow/src/dashboard/dashboard_bloc/dashboard_bloc.dart';
import 'package:frequent_flow/src/dashboard/dashboard_screen.dart';
import 'package:frequent_flow/src/dashboard/home.dart';
import 'package:frequent_flow/src/dashboard/repository/dashboard_repository.dart';
import 'package:frequent_flow/src/expected_payment_date/bloc/expected_bloc.dart';
import 'package:frequent_flow/src/expected_payment_date/repository/expected_date_repository.dart';
import 'package:frequent_flow/src/order_management/invoice_bloc/invoice_bloc.dart';
import 'package:frequent_flow/src/order_management/order_bloc/order_bloc.dart';
import 'package:frequent_flow/src/order_management/repository/InvoiceRepository.dart';
import 'package:frequent_flow/src/order_management/repository/order_repository.dart';
import 'package:frequent_flow/src/settings/bloc/currency/currency_bloc.dart';
import 'package:frequent_flow/src/settings/bloc/logout/logout_bloc.dart';
import 'package:frequent_flow/src/settings/bloc/user_bloc/create_user_bloc.dart';
import 'package:frequent_flow/src/settings/respository/CurrencyResponse.dart';
import 'package:frequent_flow/src/settings/respository/UserRepository.dart';
import 'package:frequent_flow/src/settings/respository/logout_repository.dart';
import 'package:frequent_flow/utils/language_utils.dart';
import 'package:frequent_flow/utils/permission_request.dart';
import 'package:frequent_flow/utils/prefs.dart';
import 'package:frequent_flow/utils/route.dart';

import 'package:provider/provider.dart';
import 'SplashScreen.dart';
import 'authentication/screens/login_email_screen.dart';
import 'onboarding/screens/registration.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const DarwinInitializationSettings initializationSettingsIOS =
      DarwinInitializationSettings();
  const initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
  );
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  await Prefs.init();
  await PermissionRequest.checkForPermissions();
  final LanguageNotifier languageNotifier = LanguageNotifier();
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<RegistrationBloc>(
          create: (context) => RegistrationBloc(RegistrationRepository()),
        ),
        BlocProvider<LoginEmailBloc>(
          create: (context) =>
              LoginEmailBloc(loginRepository: LoginRepository()),
        ),
        BlocProvider<ChangePasswordBloc>(
          create: (context) => ChangePasswordBloc(
              changePasswordRepository: ChangePasswordRepository()),
        ),
        BlocProvider<ForgotPasswordBloc>(
          create: (context) => ForgotPasswordBloc(
              forgotPasswordRepository: ForgotPasswordRepository()),
        ),
        ChangeNotifierProvider<LanguageNotifier>.value(
          value: languageNotifier,
        ),
        BlocProvider<DashboardBloc>(
          create: (context) =>
              DashboardBloc(dashboardRepository: DashboardRepository()),
        ),
        BlocProvider<CustomerBloc>(
          create: (context) =>
              CustomerBloc(customerRepository: CustomerRepository()),
        ),
        BlocProvider<InvoiceBloc>(
          create: (context) =>
              InvoiceBloc(invoiceRepository: InvoiceRepository()),
        ),
        BlocProvider<OrderBloc>(
          create: (context) =>
              OrderBloc(orderRepository: OrderRepository()),
        ),
        BlocProvider<CashBloc>(
          create: (context) =>
              CashBloc(cashRepository: CashRepository()),
        ),
        BlocProvider<CreateUserBloc>(
          create: (context) =>
              CreateUserBloc(userRepository: UserRepository()),
        ),
        BlocProvider<CurrencyBloc>(
          create: (context) =>
              CurrencyBloc(currencyRepository: CurrencyRepository()),
        ),
        BlocProvider<ExpectedBloc>(
          create: (context) =>
              ExpectedBloc(expectedDateRepository: ExpectedDateRepository()),
        ),
        BlocProvider<MisBloc>(
          create: (context) =>
              MisBloc(misRepository: MisRepository()),
        ),
        BlocProvider<LogoutBloc>(
          create: (context) =>
              LogoutBloc(userRepository: LogoutRepository()),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Frequent Flow',
      navigatorKey: rootNavigatorKey,
      locale: Provider.of<LanguageNotifier>(context).locale,
      supportedLocales: const [
        Locale('en'), // English
        Locale.fromSubtags(
            languageCode: 'zh',
            scriptCode: 'Hans'), // Generic Simplified Chinese 'zh_Hans'
        Locale.fromSubtags(
            languageCode: 'zh',
            scriptCode: 'Hant'), // Generic traditional Chinese 'zh_Hant'
      ],
      localizationsDelegates: const [
        CountryLocalizations.delegate,
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
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
          case ROUT_LOGIN_EMAIL:
            return MaterialPageRoute(builder: (BuildContext context) {
              return const SafeArea(top: false, child: LoginEmailScreen());
            });
          case ROUT_HOME:
            return MaterialPageRoute(builder: (BuildContext context) {
              return const SafeArea(top: false, child: HomePage());
            });
          case ROUT_DASHBOARD:
            return MaterialPageRoute(builder: (BuildContext context) {
              return const SafeArea(top: true, child: DashboardScreen());
            });
          case ROUT_REGISTRATION:
            return MaterialPageRoute(builder: (BuildContext context) {
              return const SafeArea(top: true, child: Registration());
            });
          case ROUT_PERMISSION:
            return MaterialPageRoute(
              builder: (context) {
                return const SafeArea(child: PermissionsScreen());
              },
            );
          case ROUT_FORGOT_PASSWORD:
            return MaterialPageRoute(
              builder: (context) {
                return const SafeArea(child: ForgotPasswordScreen());
              },
            );
        }
        return null;
      },
    );
  }
}
