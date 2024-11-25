import 'package:flutter/material.dart';

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
    "API Module",
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
              ScaffoldMessenger.of(context).clearSnackBars();
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Tapped on ${features[index]}")));
            },
          );
        },
      ),
    );
  }
}
