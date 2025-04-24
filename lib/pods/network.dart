import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:island/models/auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'config.dart';

final userAgentProvider = FutureProvider<String>((ref) async {
  final String platformInfo;
  if (kIsWeb) {
    final deviceInfo = await DeviceInfoPlugin().webBrowserInfo;
    platformInfo = 'Web; ${deviceInfo.vendor}';
  } else if (Platform.isAndroid) {
    final deviceInfo = await DeviceInfoPlugin().androidInfo;
    platformInfo =
        'Android; ${deviceInfo.brand} ${deviceInfo.model}; ${deviceInfo.id}';
  } else if (Platform.isIOS) {
    final deviceInfo = await DeviceInfoPlugin().iosInfo;
    platformInfo = 'iOS; ${deviceInfo.model}; ${deviceInfo.name}';
  } else if (Platform.isMacOS) {
    final deviceInfo = await DeviceInfoPlugin().macOsInfo;
    platformInfo = 'MacOS; ${deviceInfo.model}; ${deviceInfo.hostName}';
  } else if (Platform.isWindows) {
    final deviceInfo = await DeviceInfoPlugin().windowsInfo;
    platformInfo =
        'Windows NT; ${deviceInfo.productName}; ${deviceInfo.computerName}';
  } else if (Platform.isLinux) {
    final deviceInfo = await DeviceInfoPlugin().linuxInfo;
    platformInfo = 'Linux; ${deviceInfo.prettyName}';
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

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (
        RequestOptions options,
        RequestInterceptorHandler handler,
      ) async {
        final atk = await getFreshAtk(ref);
        if (atk != null) {
          options.headers['Authorization'] = 'Bearer $atk';
        }
        final userAgent = ref.watch(userAgentProvider);
        if (userAgent.value != null) {
          options.headers['User-Agent'] = userAgent.value;
        }
        return handler.next(options);
      },
    ),
  );

  return dio;
});

final tokenPairProvider = Provider<AppTokenPair?>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  final tkPairString = prefs.getString(kTokenPairStoreKey);
  if (tkPairString == null) return null;
  return AppTokenPair.fromJson(jsonDecode(tkPairString));
});

Future<(String, String)?> refreshToken(Ref ref, String? rtk) async {
  if (rtk == null) return null;

  final baseUrl = ref.watch(serverUrlProvider);

  final dio = Dio();
  dio.options.baseUrl = baseUrl;

  final resp = await dio.post(
    '/auth/token',
    data: {'grant_type': 'refresh_token', 'refresh_token': rtk},
  );

  final String atk = resp.data['access_token'];
  final String nRtk = resp.data['refresh_token'];
  setTokenPair(ref.watch(sharedPreferencesProvider), atk, nRtk);
  ref.invalidate(tokenPairProvider);

  return (atk, nRtk);
}

Completer<String?>? _refreshCompleter;

Future<String?> getFreshAtk(Ref ref) async {
  final tkPair = ref.watch(tokenPairProvider);
  var atk = tkPair?.accessToken;
  var rtk = tkPair?.refreshToken;

  if (_refreshCompleter != null) {
    return await _refreshCompleter!.future;
  } else {
    _refreshCompleter = Completer<String?>();
  }

  try {
    if (atk != null) {
      final atkParts = atk.split('.');
      if (atkParts.length != 3) {
        throw Exception('invalid format of access token');
      }

      var rawPayload = atkParts[1].replaceAll('-', '+').replaceAll('_', '/');
      switch (rawPayload.length % 4) {
        case 0:
          break;
        case 2:
          rawPayload += '==';
          break;
        case 3:
          rawPayload += '=';
          break;
        default:
          throw Exception('illegal format of access token payload');
      }

      final b64 = utf8.fuse(base64Url);
      final payload = b64.decode(rawPayload);
      final exp = jsonDecode(payload)['exp'];
      if (exp <= DateTime.now().millisecondsSinceEpoch ~/ 1000) {
        log('[Auth] Access token need refresh, doing it at ${DateTime.now()}');
        final result = await refreshToken(ref, rtk);
        if (result == null) {
          atk = null;
        } else {
          atk = result.$1;
        }
      }

      if (atk != null) {
        _refreshCompleter!.complete(atk);
        return atk;
      } else {
        log('[Auth] Access token refresh failed...');
        _refreshCompleter!.complete(null);
      }
    }
  } catch (err) {
    log('[Auth] Failed to authenticate user... $err');
    _refreshCompleter!.completeError(err);
  } finally {
    _refreshCompleter = null;
  }

  return null;
}

Future<void> setTokenPair(
  SharedPreferences prefs,
  String atk,
  String rtk,
) async {
  final tkPair = AppTokenPair(accessToken: atk, refreshToken: rtk);
  final tkPairString = jsonEncode(tkPair);
  prefs.setString(kTokenPairStoreKey, tkPairString);
}
