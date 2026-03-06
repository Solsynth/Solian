import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:island/core/config.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talker_dio_logger/talker_dio_logger.dart';
import 'package:island/talker.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

part 'network.g.dart';

// Network status enum to track different states
enum NetworkStatus { online, notReady, maintenance, offline }

// Provider for network status using Riverpod v3 annotation
@riverpod
class NetworkStatusNotifier extends _$NetworkStatusNotifier {
  @override
  NetworkStatus build() {
    return NetworkStatus.online;
  }

  void setOnline() {
    state = NetworkStatus.online;
  }

  void setMaintenance() {
    state = NetworkStatus.maintenance;
  }

  void setOffline() {
    state = NetworkStatus.offline;
  }

  void setNotReady() {
    state = NetworkStatus.notReady;
  }
}

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

const String _chatE2eeCapability = 'chat-e2ee-v1';

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
        'X-Client-Ability': [_chatE2eeCapability].join(','),
      },
    ),
  );

  dio.interceptors.addAll([
    InterceptorsWrapper(
      onRequest:
          (RequestOptions options, RequestInterceptorHandler handler) async {
            try {
              final token = await getToken(ref.watch(tokenProvider));
              if (token != null) {
                options.headers['Authorization'] = 'Bearer $token';
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
      onResponse: (response, handler) {
        // Check for 503 status code (Service Unavailable/Maintenance)
        if (response.statusCode == 503) {
          final networkStatusNotifier = ref.read(
            networkStatusProvider.notifier,
          );
          if (response.headers.value('X-NotReady') != null) {
            networkStatusNotifier.setNotReady();
          } else {
            networkStatusNotifier.setMaintenance();
          }
        } else if (response.statusCode != null &&
            response.statusCode! >= 200 &&
            response.statusCode! < 300) {
          // Set online status for successful responses
          final networkStatusNotifier = ref.read(
            networkStatusProvider.notifier,
          );
          networkStatusNotifier.setOnline();
        }
        return handler.next(response);
      },
      onError: (error, handler) {
        // Handle network errors and set offline status
        if (error.response?.statusCode == 503) {
          final networkStatusNotifier = ref.read(
            networkStatusProvider.notifier,
          );
          if (error.response?.headers.value('X-NotReady') != null) {
            networkStatusNotifier.setNotReady();
          } else {
            networkStatusNotifier.setMaintenance();
          }
        }
        return handler.next(error);
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
    RetryInterceptor(
      dio: dio,
      retries: 3,
      retryDelays: const [
        Duration(milliseconds: 300),
        Duration(milliseconds: 500),
        Duration(milliseconds: 1000),
      ],
      retryEvaluator: (err, _) => err.requestOptions.method == 'GET',
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
