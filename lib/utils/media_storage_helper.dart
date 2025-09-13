import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class MediaStoreHelper {
  static Future<void> saveFileToDownloads(File file, String fileName) async {
    // This requires a plugin that supports MediaStore API
    // You might need to use: https://pub.dev/packages/media_store
    // Or implement platform-specific code via method channels

    // Example using method channel (simplified):
    try {
      const channel = MethodChannel('file_download_channel');
      await channel.invokeMethod('saveToDownloads', {
        'filePath': file.path,
        'fileName': fileName,
        'mimeType': 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
      });
    } catch (e) {
      print('Error saving to MediaStore: $e');
      // Fallback: just save to app directory
    }
  }
}