import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:permission_handler/permission_handler.dart';

class PermissionRequest {
  static Future<bool> checkForPermissions() async {
    if (kIsWeb) {
      // Web-specific permission handling
      // Most browsers handle file access through file picker dialogs rather than permissions
      print("Running on web - skipping direct permission requests");
      return true; // Or implement web-specific permission checks
    }

    // Mobile-specific permission handling
    try {
      // Request external storage permission (Android only)
      final manageStorageStatus = await Permission.manageExternalStorage.request();
      final storageStatus = await Permission.storage.request();

      // Check media permissions (photos, videos, audio)
      final mediaPermissions = await [
        Permission.photos,
        Permission.videos,
        Permission.audio,
      ].request();

      // Log permission statuses
      print('Manage External Storage: $manageStorageStatus');
      print('Storage: $storageStatus');
      print('Photos: ${mediaPermissions[Permission.photos]}');
      print('Videos: ${mediaPermissions[Permission.videos]}');
      print('Audio: ${mediaPermissions[Permission.audio]}');

      // Return true if either storage permission is granted
      return manageStorageStatus.isGranted || storageStatus.isGranted;
    } catch (e) {
      print('Error requesting permissions: $e');
      return false;
    }
  }

  // Alternative method for web file access
  static Future<bool> requestFileAccess() async {
    if (kIsWeb) {
      // Implement web-specific file access logic
      // For example, trigger a file input dialog
      print("Web file access would be handled through file picker");
      return true;
    }
    return await checkForPermissions();
  }
}