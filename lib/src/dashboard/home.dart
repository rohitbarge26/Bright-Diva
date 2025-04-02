import 'package:flutter/material.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:frequent_flow/src/cash_management/screen/cash_receipt.dart';
import 'package:frequent_flow/src/order_management/screen/invoice.dart';
import '../settings/screen/setting.dart';
import 'dashboard_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  List<Widget> _widgetOptions = [];

  @override
  void initState() {
    super.initState();
    _widgetOptions = <Widget>[
      const DashboardScreen(),
      //const Invoice(),
      //const CashReceipt(),
      const Setting()
    ];
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    int numberOfTabs = 4;
    double tabWidth = screenWidth / numberOfTabs;
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: _widgetOptions.elementAt(_selectedIndex),
        bottomNavigationBar: SizedBox(
          width: tabWidth,
          child: BottomNavigationBar(
              backgroundColor: const Color(0xffffffff),
              type: BottomNavigationBarType.fixed,
              items: <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                    icon: const Icon(Icons.dashboard),
                    activeIcon: const Icon(Icons.dashboard, color: Colors.blue),
                    label: AppLocalizations.of(context)!.tabDashboard),
                // BottomNavigationBarItem(
                //   icon: const Icon(Icons.receipt),
                //   activeIcon: const Icon(Icons.receipt, color: Colors.blue),
                //   label: AppLocalizations.of(context)!.tabInvoice,
                // ),
                // BottomNavigationBarItem(
                //   icon: const Icon(Icons.money),
                //   activeIcon: const Icon(Icons.money, color: Colors.blue),
                //   label: AppLocalizations.of(context)!.tabCash,
                // ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.settings),
                  activeIcon: const Icon(Icons.settings, color: Colors.blue),
                  label: AppLocalizations.of(context)!.tabSetting,
                ),
              ],
            currentIndex: _selectedIndex,
            showUnselectedLabels: true,
            selectedItemColor: const Color(0xFFF85A5A),
            unselectedItemColor: const Color(0xFFA3A3A3),
            unselectedLabelStyle: const TextStyle(
                fontSize: 12, fontWeight: FontWeight.w500, height: 1.33),
            onTap: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
          ),
        ),
      ),
    );
  }
}
