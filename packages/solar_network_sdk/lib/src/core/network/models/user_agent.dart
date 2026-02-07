import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';

class UserAgentConfig {
  final String appName;
  final String? customUserAgent;

  UserAgentConfig({this.appName = 'SolarNetworkSDK', this.customUserAgent});

  Future<String> build() async {
    if (customUserAgent != null) return customUserAgent!;

    final platformInfo = await _getPlatformInfo();
    final packageInfo = await PackageInfo.fromPlatform();

    return '$appName/${packageInfo.version}+${packageInfo.buildNumber} ($platformInfo)';
  }

  Future<String> _getPlatformInfo() async {
    String sanitizeForHeader(String input) {
      return input.runes.map((rune) {
        if (rune >= 32 && rune <= 126) {
          return String.fromCharCode(rune);
        } else {
          return '_';
        }
      }).join();
    }

    if (kIsWeb) {
      final deviceInfo = await DeviceInfoPlugin().webBrowserInfo;
      return 'Web; ${sanitizeForHeader(deviceInfo.vendor ?? 'Unknown')}';
    } else if (Platform.isAndroid) {
      final deviceInfo = await DeviceInfoPlugin().androidInfo;
      return 'Android; ${sanitizeForHeader(deviceInfo.brand)} ${sanitizeForHeader(deviceInfo.model)}; ${sanitizeForHeader(deviceInfo.id)}';
    } else if (Platform.isIOS) {
      final deviceInfo = await DeviceInfoPlugin().iosInfo;
      return 'iOS; ${sanitizeForHeader(deviceInfo.model)}; ${sanitizeForHeader(deviceInfo.name)}';
    } else if (Platform.isMacOS) {
      final deviceInfo = await DeviceInfoPlugin().macOsInfo;
      return 'MacOS; ${sanitizeForHeader(deviceInfo.model)}; ${sanitizeForHeader(deviceInfo.hostName)}';
    } else if (Platform.isWindows) {
      final deviceInfo = await DeviceInfoPlugin().windowsInfo;
      return 'Windows NT; ${sanitizeForHeader(deviceInfo.productName)}; ${sanitizeForHeader(deviceInfo.computerName)}';
    } else if (Platform.isLinux) {
      final deviceInfo = await DeviceInfoPlugin().linuxInfo;
      return 'Linux; ${sanitizeForHeader(deviceInfo.prettyName)}';
    } else {
      return 'Unknown';
    }
  }
}
