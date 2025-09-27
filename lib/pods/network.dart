import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:island/models/auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talker_dio_logger/talker_dio_logger.dart';
import 'package:island/talker.dart';

import 'config.dart';

final imagePickerProvider = Provider((ref) => ImagePicker());

final userAgentProvider = FutureProvider<String>((ref) async {
  // Helper function to sanitize strings for HTTP headers
  String sanitizeForHeader(String input) {
    // Remove or replace characters that are not allowed in HTTP headers
    // Keep only ASCII printable characters (32-126) and replace others with underscore
    return input.runes.map((rune) {
      if (rune >= 32 && rune <= 126) {
        return String.fromCharCode(rune);
      } else {
        return '_';
      }
    }).join();
  }

  final String platformInfo;
  if (kIsWeb) {
    final deviceInfo = await DeviceInfoPlugin().webBrowserInfo;
    platformInfo = 'Web; ${sanitizeForHeader(deviceInfo.vendor ?? 'Unknown')}';
  } else if (Platform.isAndroid) {
    final deviceInfo = await DeviceInfoPlugin().androidInfo;
    platformInfo =
        'Android; ${sanitizeForHeader(deviceInfo.brand)} ${sanitizeForHeader(deviceInfo.model)}; ${sanitizeForHeader(deviceInfo.id)}';
  } else if (Platform.isIOS) {
    final deviceInfo = await DeviceInfoPlugin().iosInfo;
    platformInfo =
        'iOS; ${sanitizeForHeader(deviceInfo.model)}; ${sanitizeForHeader(deviceInfo.name)}';
  } else if (Platform.isMacOS) {
    final deviceInfo = await DeviceInfoPlugin().macOsInfo;
    platformInfo =
        'MacOS; ${sanitizeForHeader(deviceInfo.model)}; ${sanitizeForHeader(deviceInfo.hostName)}';
  } else if (Platform.isWindows) {
    final deviceInfo = await DeviceInfoPlugin().windowsInfo;
    platformInfo =
        'Windows NT; ${sanitizeForHeader(deviceInfo.productName)}; ${sanitizeForHeader(deviceInfo.computerName)}';
  } else if (Platform.isLinux) {
    final deviceInfo = await DeviceInfoPlugin().linuxInfo;
    platformInfo = 'Linux; ${sanitizeForHeader(deviceInfo.prettyName)}';
  } else {
    platformInfo = 'Unknown';
  }

  final packageInfo = await PackageInfo.fromPlatform();

  return 'Solian/${packageInfo.version}+${packageInfo.buildNumber} ($platformInfo)';
});

final apiClientProvider = Provider<Dio>((ref) {
  final serverUrl = ref.watch(serverUrlProvider);
  final dio = Dio(
    BaseOptions(
      baseUrl: serverUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ),
  );

  dio.interceptors.addAll([
    InterceptorsWrapper(
      onRequest: (
        RequestOptions options,
        RequestInterceptorHandler handler,
      ) async {
        try {
          final token = await getToken(ref.watch(tokenProvider));
          if (token != null) {
            options.headers['Authorization'] = 'AtField $token';
          }
        } catch (err) {
          // ignore
        }

        final userAgent = ref.read(userAgentProvider);
        if (userAgent.value != null) {
          options.headers['User-Agent'] = userAgent.value;
        }
        return handler.next(options);
      },
    ),
    TalkerDioLogger(
      talker: talker,
      settings: const TalkerDioLoggerSettings(
        printRequestHeaders: false,
        printResponseHeaders: false,
        printResponseMessage: false,
        printRequestData: false,
        printResponseData: false,
      ),
    ),
  ]);

  return dio;
});

final tokenProvider = Provider<AppToken?>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  final tokenString = prefs.getString(kTokenPairStoreKey);
  if (tokenString == null) return null;
  return AppToken.fromJson(jsonDecode(tokenString));
});

// Token refresh functionality removed as per backend changes

Future<String?> getToken(AppToken? token) async {
  return token?.token;
}

Future<void> setToken(SharedPreferences prefs, String token) async {
  final appToken = AppToken(token: token);
  final tokenString = jsonEncode(appToken);
  prefs.setString(kTokenPairStoreKey, tokenString);
}
