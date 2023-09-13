import 'package:optimized_cached_image/optimized_cached_image.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io' show Platform;
import 'package:device_info_plus/device_info_plus.dart';

class PermissionsService {
  Future<bool> checkAndRequestCameraPermissions() async {
    if (Platform.isAndroid) {
      // Android level is below 13
      String deviceSdk = await DeviceInfo().getDeviceSdkVersion();
      if (int.parse(deviceSdk) < 33) {
        log('deviceSdk: $deviceSdk');
        PermissionStatus permission = await Permission.camera.status;
        if (permission != PermissionStatus.granted) {
          Map<Permission, PermissionStatus> permissions = await [
            Permission.camera,
          ].request();
          return permissions[Permission.camera] == PermissionStatus.granted;
        } else {
          log('permission granted');
          return true;
        }
      } else {
        // if its above 13
        log('deviceSdk: $deviceSdk');
        return await checkAndRequestGalleryPermission();
      }
    } else {
      // if its ios
      return true;
    }
  }

  Future<bool> checkAndRequestGalleryPermission() async {
    if (Platform.isAndroid) {
      String deviceSdk = await DeviceInfo().getDeviceSdkVersion();
      if (int.parse(deviceSdk) < 33) {
        // Android level is below 13
        PermissionStatus permission = await Permission.storage.status;
        if (permission != PermissionStatus.granted) {
          Map<Permission, PermissionStatus> permissions = await [
            Permission.storage,
          ].request();
          return permissions[Permission.storage] == PermissionStatus.granted;
        } else {
          return true;
        }
      } else {
        // if its above 13
        PermissionStatus permission = await Permission.mediaLibrary.status;
        if (permission != PermissionStatus.granted) {
          Map<Permission, PermissionStatus> permissions = await [
            Permission.storage,
          ].request();
          return permissions[Permission.mediaLibrary] ==
              PermissionStatus.granted;
        } else {
          return true;
        }
      }
    } else {
      return true;
    }
  }
}

class DeviceInfo {
  final deviceInfoPlugin = DeviceInfoPlugin();
  Future<String> getDeviceSdkVersion() async {
    AndroidDeviceInfo androidInfo = await deviceInfoPlugin.androidInfo;
    return androidInfo.version.sdkInt.toString();
  }
}
