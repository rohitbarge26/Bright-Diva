import 'dart:io';

import 'package:flutter/material.dart';
import 'package:frequent_flow/utils/route.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final List<String> features = [
    "Biometric",
    "Face Recognition",
    "Push notification",
    "Social Media Integration",
    "Map Integration",
    "Permissions",
    "Change Password"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: features.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(features[index]),
            leading: const Icon(Icons.label),
            onTap: () {
              switch (features[index]) {
                case "Push notification":
                  if (Platform.isAndroid) {
                    Navigator.of(context).pushNamed(ROUT_PUSH_NOTIFICATION);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          "This feature works on Android only",
                        ),
                      ),
                    );
                  }
                  break;
                case "Social Media Integration":
                  Navigator.of(context)
                      .pushNamed(ROUT_SOCIAL_MEDIA_INTEGRATION);
                  break;
                case "Map Integration":
                  Navigator.of(context).pushNamed(ROUT_MAP_INTEGRATION);
                  break;
                case "Permissions":
                  Navigator.of(context).pushNamed(ROUT_PERMISSION);
                  break;
                case "Change Password":
                  Navigator.of(context).pushNamed(ROUT_CHANGE_PASSWORD);
                  break;
              }
            },
          );
        },
      ),
    );
  }
}
