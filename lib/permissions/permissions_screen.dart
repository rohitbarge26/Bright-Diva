import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionsScreen extends StatefulWidget {
  const PermissionsScreen({super.key});

  @override
  State<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends State<PermissionsScreen> {
  // State variables to hold the status of each permission
  PermissionStatus _locationStatus = PermissionStatus.denied;
  PermissionStatus _notificationsStatus = PermissionStatus.denied;
  PermissionStatus _cameraStatus = PermissionStatus.denied;
  PermissionStatus _microphoneStatus = PermissionStatus.denied;
  PermissionStatus _contactsStatus = PermissionStatus.denied;

  @override
  void initState() {
    super.initState();
    // Check initial permission statuses when the screen loads
    _checkPermissions();
  }

  // Method to check the current status of all permissions
  Future<void> _checkPermissions() async {
    final location = await Permission.location.status;
    final notifications = await Permission.notification.status;
    final camera = await Permission.camera.status;
    final microphone = await Permission.microphone.status;
    final contacts = await Permission.contacts.status;

    setState(() {
      _locationStatus = location;
      _notificationsStatus = notifications;
      _cameraStatus = camera;
      _microphoneStatus = microphone;
      _contactsStatus = contacts;
    });
  }

  // Helper method to request a permission and update its status
  Future<void> _requestPermission(Permission permission) async {
    final status = await permission.request();
    // After requesting, update all statuses to reflect any changes
    // (e.g., if granting one permission affects another, or just to refresh UI)
    _checkPermissions();
  }

  // Helper method to get an icon based on permission status
  Widget _getPermissionStatusIcon(PermissionStatus status) {
    switch (status) {
      case PermissionStatus.granted:
        return const Icon(Icons.check_circle, color: Colors.green);
      case PermissionStatus.denied:
        return const Icon(Icons.cancel, color: Colors.red);
      case PermissionStatus.restricted:
      case PermissionStatus.limited:
        return const Icon(Icons.warning, color: Colors.orange);
      case PermissionStatus.permanentlyDenied:
        return const Icon(Icons.block, color: Colors.redAccent);
      default:
        return const Icon(Icons.help_outline, color: Colors.grey);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Permissions Demo"),
        backgroundColor: Colors.deepPurple,
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20),
      ),
      body: RefreshIndicator(
        onRefresh: _checkPermissions, // Allows pull-to-refresh for statuses
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            _buildPermissionTile(
              title: "Location",
              status: _locationStatus,
              onTap: () async {
                print("Requesting location permission");
                await _requestPermission(Permission.location);
              },
              permissionTypeForAppSettings: Permission.location,
            ),
            _buildPermissionTile(
              title: "Notifications",
              status: _notificationsStatus,
              onTap: () async {
                print("Requesting Notifications permission");
                await _requestPermission(Permission.notification);
              },
              permissionTypeForAppSettings: Permission.notification,
            ),
            _buildPermissionTile(
              title: "Camera",
              status: _cameraStatus,
              onTap: () async {
                print("Requesting Camera permission");
                await _requestPermission(Permission.camera);
              },
              permissionTypeForAppSettings: Permission.camera,
            ),
            _buildPermissionTile(
              title: "Microphone",
              status: _microphoneStatus,
              onTap: () async {
                print("Requesting Microphone permission");
                await _requestPermission(Permission.microphone);
              },
              permissionTypeForAppSettings: Permission.microphone,
            ),
            _buildPermissionTile(
              title: "Contacts",
              status: _contactsStatus,
              onTap: () async {
                print("Requesting Contacts permission");
                await _requestPermission(Permission.contacts);
              },
              permissionTypeForAppSettings: Permission.contacts,
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget to build each permission list tile
  Widget _buildPermissionTile({
    required String title,
    required PermissionStatus status,
    required VoidCallback onTap,
    required Permission permissionTypeForAppSettings,
  }) {
    return Card(
      elevation: 2.0,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        leading: _getPermissionStatusIcon(status),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Text('Status: ${status.toString().split('.').last}'),
        trailing: status == PermissionStatus.permanentlyDenied
            ? IconButton(
                icon: const Icon(Icons.settings, color: Colors.blue),
                tooltip: 'Open App Settings',
                onPressed: () async {
                  print("Opening app settings for $title");
                  await openAppSettings();
                },
              )
            : const Icon(Icons.arrow_forward_ios),
        onTap: (status == PermissionStatus.permanentlyDenied)
            ? null
            : onTap, // Disable tap if permanently denied
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      ),
    );
  }
}
