import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class CheckPermission {
  final plugin = DeviceInfoPlugin();

  isStoragePermission() async {
    final android = await plugin.androidInfo;
    var isStorage = android.version.sdkInt < 33
        ? await Permission.storage.request()
        : PermissionStatus.granted;
    if (isStorage == PermissionStatus.permanentlyDenied) {
      openAppSettings();
    }
   else if (!isStorage.isGranted) {
      await Permission.storage.request();
      if (!isStorage.isGranted) {
        return false;
      } else {
        return true;
      }
    } else {
      return true;
    }
  }
}
