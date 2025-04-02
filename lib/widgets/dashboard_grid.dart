import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../src/dashboard/model/dashboard_chart_response.dart';

class DashboardGrid extends StatelessWidget {
  final DashboardChartResponse response;

  const DashboardGrid({super.key, required this.response});

  @override
  Widget build(BuildContext context) {
    // Convert response data to a Map<String, double>
    final Map<String, double> data = {
      AppLocalizations.of(context)!.totalOrder: response.totalOrderValue ?? 0,
      AppLocalizations.of(context)!.delivered:
          response.totalDeliveredValue ?? 0,
      AppLocalizations.of(context)!.nonDelivered:
          response.nonDeliveredValue ?? 0,
      AppLocalizations.of(context)!.cashPickUp: response.totalCashPickup ?? 0,
      AppLocalizations.of(context)!.deliveredCash:
          response.deliveredCashPickup ?? 0,
      AppLocalizations.of(context)!.netDue: response.totalNetDue ?? 0,
    };

    // Image paths (Replace with actual paths)
    final Map<String, String> icons = {
      AppLocalizations.of(context)!.totalOrder: 'assets/icons/total_order.svg',
      AppLocalizations.of(context)!.delivered: 'assets/icons/delivered.svg',
      AppLocalizations.of(context)!.nonDelivered:
          'assets/icons/non_delivered.svg',
      AppLocalizations.of(context)!.cashPickUp: 'assets/icons/cash_pickup.svg',
      AppLocalizations.of(context)!.deliveredCash:
          'assets/icons/cash_delivered.svg',
      AppLocalizations.of(context)!.netDue: 'assets/icons/due_amount.svg',
    };

    final double screenWidth = MediaQuery.of(context).size.width;
    final int crossAxisCount = screenWidth > 700 ? 4 : 3; // Adjust based on screen width
    final double childAspectRatio = screenWidth > 700 ? 1.2 : 0.8; // Adjust based on screen width


    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: childAspectRatio,
        ),
        itemCount: data.length,
        itemBuilder: (context, index) {
          String key = data.keys.elementAt(index);
          double value = data[key] ?? 0;

          return Card(
            color: Colors.white,
            // White background
            elevation: 5,
            // Slight elevation
            shadowColor: Colors.grey,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: const BorderSide(
                  color: Colors.black, width: 0.5), // Black border
            ),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    icons[key] ?? 'assets/icons/default.svg',
                    height: 30,
                    width: 30,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    value.toStringAsFixed(2), // Ensure 2 decimal places
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.blue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    key,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ]),
          );
        },
      ),
    );
  }
}
