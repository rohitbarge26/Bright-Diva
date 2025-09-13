import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:permission_handler/permission_handler.dart';

class PermissionRequest {
  static Future<bool> checkForPermissions() async {
    if (kIsWeb) return true;

    try {
      if (Platform.isAndroid) {
        final androidInfo = await DeviceInfoPlugin().androidInfo;

        if (androidInfo.version.sdkInt >= 30) {
          // Android 11+ - Use Scoped Storage, no manageExternalStorage needed
          return true;
        } else if (androidInfo.version.sdkInt >= 29) {
          // Android 10 - Use Scoped Storage
          return true;
        } else {
          // Android < 10 - Need storage permission
          final storageStatus = await Permission.storage.request();
          return storageStatus.isGranted;
        }
      } else {
        // iOS
        return true;
      }
    } catch (e) {
      print('Error requesting permissions: $e');
      return false;
    }
  }
}