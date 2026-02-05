import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_udid/flutter_udid.dart';

String? _cachedUdid;

Future<String> getUdid() async {
  if (_cachedUdid != null) {
    return _cachedUdid!;
  }
  _cachedUdid = await FlutterUdid.consistentUdid;
  return _cachedUdid!;
}

Future<String> getDeviceName() async {
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  if (Platform.isAndroid) {
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    return androidInfo.device;
  } else if (Platform.isIOS) {
    IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
    return iosInfo.name;
  } else if (Platform.isLinux || Platform.isMacOS || Platform.isWindows) {
    return Platform.localHostname;
  } else {
    return 'unknown'.tr();
  }
}
