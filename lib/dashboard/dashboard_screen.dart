import 'package:flutter/material.dart';
import 'package:frequent_flow/utils/route.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final List<String> features = [
    "Login",
    "Registration",
    "Forgot Password",
    "Change Password",
    "Biometric",
    "Face Recognition",
    "Push notification",
    "Social Media Integration",
    "Map Integration",
    "Permissions"
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
                case "Map Integration":
                  Navigator.of(context).pushNamed(ROUT_MAP_INTEGRATION);
                case "Social Media Integration":
                  Navigator.of(context).pushNamed(ROUT_SOCIAL_MEDIA_INTEGRATION);
              }
            },
          );
        },
      ),
    );
  }
}
