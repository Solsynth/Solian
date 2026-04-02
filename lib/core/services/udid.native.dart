import 'dart:io';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:easy_localization/easy_localization.dart';

String? _cachedUdid;

Future<String> getUdid() async {
  if (_cachedUdid != null) {
    return _cachedUdid!;
  }

  final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  String rawIdentifier;

  if (Platform.isAndroid) {
    final AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    rawIdentifier = androidInfo.id;
  } else if (Platform.isIOS) {
    final IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
    rawIdentifier = iosInfo.identifierForVendor ?? iosInfo.utsname.machine;
  } else if (Platform.isMacOS) {
    final MacOsDeviceInfo macInfo = await deviceInfo.macOsInfo;
    rawIdentifier = macInfo.systemGUID ?? macInfo.computerName;
  } else if (Platform.isLinux) {
    final LinuxDeviceInfo linuxInfo = await deviceInfo.linuxInfo;
    rawIdentifier = linuxInfo.machineId ?? linuxInfo.id;
  } else if (Platform.isWindows) {
    final WindowsDeviceInfo windowsInfo = await deviceInfo.windowsInfo;
    rawIdentifier = windowsInfo.deviceId;
  } else {
    rawIdentifier = Platform.localHostname;
  }

  // Generate consistent hash identifier
  final bytes = utf8.encode(rawIdentifier);
  final digest = sha256.convert(bytes);
  _cachedUdid = digest.toString();

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
