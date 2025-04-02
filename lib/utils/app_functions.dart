import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../main.dart';

Future<void> showExitConfirmationDialog(BuildContext context, String alertMsg,
    String info, String navigationRout, bool isWithParam) async {
  await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      surfaceTintColor: Colors.white,
      title: Text(alertMsg),
      content: Text(info),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            if (navigationRout == 'close') {
              Navigator.of(context).pop();
              SystemNavigator.pop();
              Future.delayed(
                const Duration(seconds: 1),
                () => exit(0),
              );
            } else {
              rootNavigatorKey.currentState?.pushNamedAndRemoveUntil(
                navigationRout,
                (route) => false,
              );
            }
          },
          child: const Text('Yes'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(false);
          },
          child: const Text('No'),
        ),
      ],
    ),
  );
}

Future<String> getCurrentTimezoneName() async {
  final String currentTimezone = await FlutterTimezone.getLocalTimezone();
  return currentTimezone;
}

String getCurrentTimeStamp() {
  DateTime now = DateTime.now();
  String timestamp = now.millisecondsSinceEpoch.toString();
  return timestamp;
}


// Get Date and Time for a specific timezone
Future<String> getDateTimeByTimezone(String timezone) async {
  tz.initializeTimeZones(); // Initialize timezones

// Get the location for the provided timezone
  final location = tz.getLocation(timezone);

// Get the current date and time in the specified timezone
  final now = tz.TZDateTime.now(location);

// Format the current time in a human-readable format
  final formattedTime = DateFormat.yMd().add_jms().format(now);

  return formattedTime;
}

String getCurrentTimeInISO8601Format() {
  // Get the current date and time in UTC
  DateTime now = DateTime.now().toUtc();

  // Format the date and time in ISO 8601 format
  String formattedDate = DateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'").format(now);

  return formattedDate;
}

String generateInvoiceNumber() {
  // Example: Use a timestamp to generate a unique number
  String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
  return "INV-$timestamp"; // Example format: INV-1698765432100
}