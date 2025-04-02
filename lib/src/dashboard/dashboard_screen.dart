import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/svg.dart';
import 'package:frequent_flow/src/dashboard/dashboard_bloc/dashboard_event.dart';
import 'package:frequent_flow/src/dashboard/dashboard_bloc/dashboard_state.dart';
import '../../utils/prefs.dart';
import '../../widgets/custom_text.dart';
import '../../widgets/dashboard_grid.dart';
import '../cash_management/screen/cash_receipt.dart';
import '../customer_management/screen/add_customer.dart';
import '../expected_payment_date/screens/expected_date.dart';
import '../order_management/screen/invoice.dart';
import '../order_management/screen/orderPlace.dart';
import '../profile/screen/profile.dart';
import 'dashboard_bloc/dashboard_bloc.dart';
import 'model/dashboard_chart_response.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  DashboardChartResponse dashboardChartResponse = DashboardChartResponse();
  bool isDashboardChartData = false;
  String? userRole;

  @override
  void initState() {
    super.initState();
    print("Dashboard API Request");
    BlocProvider.of<DashboardBloc>(context, listen: false)
        .add(const DashboardChartData());
    userRole = Prefs.getUser('user')?.role!;
  }

  // Method to refresh dashboard data
  Future<void> _refreshDashboardData() async {
    BlocProvider.of<DashboardBloc>(context, listen: false)
        .add(const DashboardChartData());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DashboardBloc, DashboardState>(
      listener: (context, state) {
        if (state is DashboardChartLoadedState) {
          setState(() {
            isDashboardChartData = true;
            dashboardChartResponse = state.dashboardChartResponse!;
          });
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFFFC6C6).withOpacity(0.2),
        body: RefreshIndicator(
          onRefresh: _refreshDashboardData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(), // Ensure scrolling works
            child: Column(mainAxisSize: MainAxisSize.max, children: [
              Padding(
                padding: const EdgeInsets.only(top: 68, right: 16.0, left: 16),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CustomText(
                            text: AppLocalizations.of(context)!.welcomeNote,
                            fontSize: 18,
                            desiredLineHeight: 24,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF171717),
                          ),
                          InkWell(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => ProfileScreen(
                                      onBackTap: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ),
                                );
                              },
                              child: const Icon(Icons.person, size: 36)),
                        ],
                      ),
                      //Dashboard Pia-Chart
                      DashboardGrid(response: dashboardChartResponse),
                      const Divider(
                        color: Color(0xFFEEE7E5),
                        thickness: 1.0,
                      ),
                      //Invoice
                      InkWell(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => Invoice(
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
                                        'assets/icons/add_invoice.svg',
                                        width: 24,
                                        height: 24,
                                      ),
                                      const SizedBox(width: 16),
                                      CustomText(
                                        text: AppLocalizations.of(context)!.tabInvoice,
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
                      ),
                      //Delivery Order
                      InkWell(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => OrderPlace(
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
                                        'assets/icons/order.svg',
                                        width: 24,
                                        height: 24,
                                      ),
                                      const SizedBox(width: 16),
                                      CustomText(
                                        text: AppLocalizations.of(context)!
                                            .raiseOrder,
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
                      ),
                      //Expected Payment date
                      InkWell(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ExpectedDate(
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
                                        'assets/icons/expected_payment_date.svg',
                                        width: 24,
                                        height: 24,
                                      ),
                                      const SizedBox(width: 16),
                                      CustomText(
                                        text: AppLocalizations.of(context)!
                                            .expectedPaymentDate,
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
                      ),
                      //Cash Receipt
                      InkWell(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => CashReceipt(
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
                                        'assets/icons/cash_receipt.svg',
                                        width: 24,
                                        height: 24,
                                      ),
                                      const SizedBox(width: 16),
                                      CustomText(
                                        text: AppLocalizations.of(context)!
                                            .cashReceipt,
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
                      ),
                      //Add Customer
                      if (userRole == 'Admin')
                        Column(
                          children: [
                            InkWell(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => AddCustomer(
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
                                              'assets/icons/add_customer.svg',
                                              width: 24,
                                              height: 24,
                                            ),
                                            const SizedBox(width: 16),
                                            CustomText(
                                              text: AppLocalizations.of(context)!
                                                  .addCustomer,
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
                            ),
                          ],
                        ),
                    ]),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
