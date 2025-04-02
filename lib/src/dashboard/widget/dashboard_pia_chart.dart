import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../model/dashboard_chart_response.dart';

class DashboardBarChart extends StatelessWidget {
  final DashboardChartResponse response;

  const DashboardBarChart({super.key, required this.response});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300, // Set a fixed height
      width: double.infinity, // Allow full width
      child: BarChart(
        BarChartData(
          barGroups: _createBarGroups(response),
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: Colors.black, width: 1),
          ),
          gridData: FlGridData(
            show: true,
            drawHorizontalLine: true, // Show horizontal grid lines
            drawVerticalLine: false, // Hide vertical grid lines
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Colors.grey.shade300, // Light grey for grid lines
                strokeWidth: 1,
                dashArray: [5, 5], // Dashed lines for better visibility
              );
            },
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Text(value.toInt().toString()),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  List<String> labels = [
                    'Total Order',
                    'Delivered',
                    'Non-Delivered',
                    'Cash Pickup',
                    'Delivered Cash',
                    'Net Due'
                  ];
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      labels[value.toInt()],
                      style: const TextStyle(fontSize: 10),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<BarChartGroupData> _createBarGroups(DashboardChartResponse response) {
    return [
      BarChartGroupData(
        x: 0,
        barRods: [
          BarChartRodData(
            toY: double.parse(response.totalOrderValue?.toStringAsFixed(2) ?? '0'),
            color: Colors.blue,
            width: 15,
          )
        ],
      ),
      BarChartGroupData(
        x: 1,
        barRods: [
          BarChartRodData(
            toY: double.parse(response.totalDeliveredValue?.toStringAsFixed(2) ?? '0'),
            color: Colors.green,
            width: 15,
          )
        ],
      ),
      BarChartGroupData(
        x: 2,
        barRods: [
          BarChartRodData(
            toY: double.parse(response.nonDeliveredValue?.toStringAsFixed(2) ?? '0'),
            color: Colors.red,
            width: 15,
          )
        ],
      ),
      BarChartGroupData(
        x: 3,
        barRods: [
          BarChartRodData(
            toY: double.parse(response.totalCashPickup?.toStringAsFixed(2) ?? '0'),
            color: Colors.orange,
            width: 15,
          )
        ],
      ),
      BarChartGroupData(
        x: 4,
        barRods: [
          BarChartRodData(
            toY: double.parse(response.deliveredCashPickup?.toStringAsFixed(2) ?? '0'),
            color: Colors.purple,
            width: 15,
          )
        ],
      ),
      BarChartGroupData(
        x: 5,
        barRods: [
          BarChartRodData(
            toY: double.parse(response.totalNetDue?.toStringAsFixed(2) ?? '0'),
            color: Colors.yellow,
            width: 15,
          )
        ],
      ),
    ];
  }

}
