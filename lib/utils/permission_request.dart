
import 'package:permission_handler/permission_handler.dart';

class PermissionRequest {
  static Future<bool> checkForPermissions() async {
    // Request Location (GPS) When In Use permission

    var status = await Permission.manageExternalStorage.request();
    var storage = await Permission.storage.request();

    if (await Permission.photos.isGranted &&
        await Permission.videos.isGranted &&
        await Permission.audio.isGranted) {
      print("Media Permissions Already Granted");
      return false;
    }

    Map<Permission, PermissionStatus> statuses = await [
      Permission.photos,
      Permission.videos,
      Permission.audio,
    ].request();

    if (statuses[Permission.photos]!.isGranted &&
        statuses[Permission.videos]!.isGranted &&
        statuses[Permission.audio]!.isGranted) {
      print("Media Permissions Granted");
    } else {
      print("Media Permissions Denied");
    }

    // Check if all permissions have been granted
    if (status == PermissionStatus.granted || storage == PermissionStatus.granted) {
      return true;
    } else {
      return false;
    }




    if(status == PermissionStatus.granted){

    }
  }
}

