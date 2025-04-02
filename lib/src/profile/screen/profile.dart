import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../authentication/models/email/login_response.dart';
import '../../../widgets/custom_text.dart';
import 'dart:convert'; // For JSON decoding
import 'package:shared_preferences/shared_preferences.dart'; // For SharedPreferences

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, required this.onBackTap});

  final void Function() onBackTap;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? _user; // To store the user data

  @override
  void initState() {
    super.initState();
    _loadUserData(); // Load user data when the screen initializes
  }

  // Method to load user data
  Future<void> _loadUserData() async {
    final user =
        await getUser('user'); // Replace 'user_key' with your actual key
    setState(() {
      _user = user;
    });
  }

  // Method to retrieve User object from SharedPreferences
  static Future<User?> getUser(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final userString = prefs.getString(key);
    if (userString != null) {
      final userJson = jsonDecode(userString); // Convert string to JSON
      return User.fromJson(userJson); // Convert JSON to User object
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 68, right: 16.0, left: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // Back button and title
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(width: 10),
                Container(
                  height: 50,
                  alignment: Alignment.centerLeft,
                  child: InkWell(
                    onTap: () {
                      widget.onBackTap();
                    },
                    child: SvgPicture.asset(
                      'assets/icons/back_arrow_icon.svg',
                      width: 40,
                      height: 40,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  height: 50,
                  alignment: Alignment.centerLeft,
                  child: CustomText(
                    text: AppLocalizations.of(context)!.profile,
                    fontSize: 20,
                    desiredLineHeight: 28,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.02,
                    color: const Color(0xFF171717),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Spacing

            // Display user data
            if (_user != null)
              Column(
                children: [
                  _buildProfileItem('Name', _user!.name),
                  _buildProfileItem('Role', _user!.role),
                  _buildProfileItem('Email', _user!.emailId),
                  _buildProfileItem('Phone', _user!.phoneNo),
                  // Add more fields as needed
                ],
              )
            else
              const CircularProgressIndicator(),
            // Show a loader while data is being fetched
          ],
        ),
      ),
    );
  }

  // Helper method to build a profile item row
  Widget _buildProfileItem(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          CustomText(
            text: '$label:',
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black, desiredLineHeight: 24, fontFamily: 'Inter',
          ),
          const SizedBox(width: 10),
          Expanded(
            child: CustomText(
              text: value ?? 'N/A',
              // Display 'N/A' if value is null
              fontSize: 16,
              color: Colors.black54,
              desiredLineHeight: 24,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
