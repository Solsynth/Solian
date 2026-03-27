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
const String _chatMlsCapability = 'chat-mls-v1';
const Duration _tokenExpirySkew = Duration(seconds: 30);

Future<_StoredTokenPair?>? _tokenRefreshInFlight;

final padlockApiClientProvider = Provider<Dio>((ref) {
  final serverUrl = ref.watch(serverUrlProvider);
  final dio = Dio(
    BaseOptions(
      baseUrl: '$serverUrl/padlock',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'X-Client-Ability': [_chatE2eeCapability, _chatMlsCapability].join(','),
      },
    ),
  );

  dio.interceptors.addAll([
    InterceptorsWrapper(
      onRequest:
          (RequestOptions options, RequestInterceptorHandler handler) async {
            try {
              final token = await getValidAuthToken(ref);
              if (token?.isNotEmpty ?? false) {
                options.headers['Authorization'] = 'Bearer ${token!}';
              }
            } catch (err) {
              // ignore
            }

            final userAgent = ref.read(userAgentProvider);
            if (userAgent.value != null) {
              options.headers['User-Agent'] = userAgent.value;
            }

            if (options.path.startsWith('/e2ee/mls')) {
              options.headers['X-Client-Ability'] = _chatMlsCapability;
            }

            return handler.next(options);
          },
      onResponse: (response, handler) async {
        final responseData = response.data;
        if (responseData is Map &&
            response.requestOptions.path.endsWith('/padlock/auth/token')) {
          final token = responseData['token'];
          if (token is String && token.isNotEmpty) {
            await setToken(
              ref.read(sharedPreferencesProvider),
              token,
              refreshToken: responseData['refresh_token'] as String?,
              expiresIn: _tryInt(responseData['expires_in']),
              refreshExpiresIn: _tryInt(responseData['refresh_expires_in']),
            );
            ref.invalidate(tokenProvider);
          }
        }

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
          final networkStatusNotifier = ref.read(
            networkStatusProvider.notifier,
          );
          networkStatusNotifier.setOnline();
        }
        return handler.next(response);
      },
      onError: (error, handler) {
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
              final token = await getValidAuthToken(ref);
              if (token?.isNotEmpty ?? false) {
                options.headers['Authorization'] = 'Bearer ${token!}';
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
      onResponse: (response, handler) async {
        final responseData = response.data;
        if (responseData is Map &&
            response.requestOptions.path.endsWith('/padlock/auth/token')) {
          final token = responseData['token'];
          if (token is String && token.isNotEmpty) {
            await setToken(
              ref.read(sharedPreferencesProvider),
              token,
              refreshToken: responseData['refresh_token'] as String?,
              expiresIn: _tryInt(responseData['expires_in']),
              refreshExpiresIn: _tryInt(responseData['refresh_expires_in']),
            );
            ref.invalidate(tokenProvider);
          }
        }

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
  final tokenPair = _readTokenPairFromPrefs(prefs);
  if (tokenPair == null) return null;
  return AppToken(token: tokenPair.token);
});

Future<String?> getValidAuthToken(Ref ref) async {
  final prefs = ref.read(sharedPreferencesProvider);
  var tokenPair = _readTokenPairFromPrefs(prefs);
  if (tokenPair != null && _shouldRefreshToken(tokenPair)) {
    tokenPair = await _refreshTokenPair(
      ref: ref,
      prefs: prefs,
      current: tokenPair,
    );
  }
  return tokenPair?.token;
}

Future<String?> getToken(AppToken? token) async {
  return token?.token;
}

Future<void> setToken(
  SharedPreferences prefs,
  String token, {
  String? refreshToken,
  int? expiresIn,
  int? refreshExpiresIn,
}) async {
  final existing = _readTokenPairFromPrefs(prefs);
  final sameAsExisting = existing?.token == token;
  final preservedRefreshToken =
      refreshToken ?? (sameAsExisting ? existing?.refreshToken : null);
  final now = DateTime.now();
  final tokenPair = _StoredTokenPair(
    token: token,
    refreshToken: preservedRefreshToken,
    expiresAt: expiresIn != null
        ? now.add(Duration(seconds: expiresIn))
        : (sameAsExisting ? existing?.expiresAt : null) ??
              _decodeJwtExpiry(token),
    refreshExpiresAt: refreshExpiresIn != null
        ? now.add(Duration(seconds: refreshExpiresIn))
        : (sameAsExisting ? existing?.refreshExpiresAt : null) ??
              (preservedRefreshToken != null
                  ? _decodeJwtExpiry(preservedRefreshToken)
                  : null),
  );
  await _saveTokenPair(prefs, tokenPair);
}

_StoredTokenPair? _readTokenPairFromPrefs(SharedPreferences prefs) {
  final raw = prefs.getString(kTokenPairStoreKey);
  if (raw == null || raw.isEmpty) return null;

  dynamic decoded;
  try {
    decoded = jsonDecode(raw);
  } catch (_) {
    return _StoredTokenPair(token: raw);
  }

  if (decoded is String) {
    return _StoredTokenPair(token: decoded);
  }

  if (decoded is! Map) return null;

  final map = Map<String, dynamic>.from(decoded);
  final token = (map['token'] ?? map['access_token']) as String?;
  if (token == null || token.isEmpty) return null;

  final refreshToken = map['refresh_token'] as String?;
  final expiresIn = _tryInt(map['expires_in']);
  final refreshExpiresIn = _tryInt(map['refresh_expires_in']);
  final expiresAt = _parseDateTime(map['expires_at']);
  final refreshExpiresAt = _parseDateTime(map['refresh_expires_at']);
  final now = DateTime.now();

  return _StoredTokenPair(
    token: token,
    refreshToken: refreshToken,
    expiresAt:
        expiresAt ??
        (expiresIn != null ? now.add(Duration(seconds: expiresIn)) : null) ??
        _decodeJwtExpiry(token),
    refreshExpiresAt:
        refreshExpiresAt ??
        (refreshExpiresIn != null
            ? now.add(Duration(seconds: refreshExpiresIn))
            : null) ??
        (refreshToken != null ? _decodeJwtExpiry(refreshToken) : null),
  );
}

Future<void> _saveTokenPair(
  SharedPreferences prefs,
  _StoredTokenPair tokenPair,
) async {
  final payload = <String, dynamic>{
    'token': tokenPair.token,
    if (tokenPair.refreshToken != null) 'refresh_token': tokenPair.refreshToken,
    if (tokenPair.expiresAt != null)
      'expires_at': tokenPair.expiresAt!.toUtc().toIso8601String(),
    if (tokenPair.refreshExpiresAt != null)
      'refresh_expires_at': tokenPair.refreshExpiresAt!
          .toUtc()
          .toIso8601String(),
  };
  await prefs.setString(kTokenPairStoreKey, jsonEncode(payload));
}

bool _shouldRefreshToken(_StoredTokenPair tokenPair) {
  if (_isNotExpired(tokenPair.expiresAt)) return false;
  // Legacy stored tokens may not have refresh token; skip refresh in that case.
  if (tokenPair.refreshToken == null || tokenPair.refreshToken!.isEmpty) {
    return false;
  }
  return _isNotExpired(tokenPair.refreshExpiresAt);
}

Future<_StoredTokenPair?> _refreshTokenPair({
  required Ref ref,
  required SharedPreferences prefs,
  required _StoredTokenPair current,
}) async {
  if (_tokenRefreshInFlight != null) {
    return _tokenRefreshInFlight;
  }

  _tokenRefreshInFlight = () async {
    final refreshToken = current.refreshToken;
    final client = Dio(
      BaseOptions(
        baseUrl: ref.read(serverUrlProvider),
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    try {
      final payload = <String, dynamic>{
        'grant_type': 'refresh_token',
        if (refreshToken?.isNotEmpty ?? false) 'refresh_token': refreshToken,
      };
      final response = await client.post('/padlock/auth/token', data: payload);
      final data = Map<String, dynamic>.from(response.data as Map);
      final nextToken = data['token'] as String?;
      if (nextToken == null || nextToken.isEmpty) {
        return current;
      }

      final now = DateTime.now();
      final expiresIn = _tryInt(data['expires_in']);
      final refreshExpiresIn = _tryInt(data['refresh_expires_in']);
      final nextRefreshToken =
          (data['refresh_token'] as String?) ?? current.refreshToken;
      final refreshed = _StoredTokenPair(
        token: nextToken,
        refreshToken: nextRefreshToken,
        expiresAt:
            (expiresIn != null
                ? now.add(Duration(seconds: expiresIn))
                : null) ??
            _decodeJwtExpiry(nextToken),
        refreshExpiresAt:
            (refreshExpiresIn != null
                ? now.add(Duration(seconds: refreshExpiresIn))
                : null) ??
            (nextRefreshToken != null
                ? _decodeJwtExpiry(nextRefreshToken)
                : null),
      );

      await _saveTokenPair(prefs, refreshed);
      ref.invalidate(tokenProvider);
      talker.debug('[Network] Access token refreshed.');
      return refreshed;
    } catch (err) {
      talker.warning('[Network] Token refresh failed: $err');
      return current;
    } finally {
      client.close();
    }
  }();

  try {
    return await _tokenRefreshInFlight;
  } finally {
    _tokenRefreshInFlight = null;
  }
}

bool _isNotExpired(DateTime? dateTime) {
  if (dateTime == null) return false;
  return dateTime.isAfter(DateTime.now().add(_tokenExpirySkew));
}

int? _tryInt(dynamic value) {
  if (value is int) return value;
  if (value is String) return int.tryParse(value);
  return null;
}

DateTime? _parseDateTime(dynamic value) {
  if (value is! String || value.isEmpty) return null;
  return DateTime.tryParse(value)?.toLocal();
}

DateTime? _decodeJwtExpiry(String token) {
  final parts = token.split('.');
  if (parts.length < 2) return null;
  try {
    final normalized = base64Url.normalize(parts[1]);
    final payload = utf8.decode(base64Url.decode(normalized));
    final map = jsonDecode(payload);
    if (map is! Map) return null;
    final exp = map['exp'];
    if (exp is int) {
      return DateTime.fromMillisecondsSinceEpoch(
        exp * 1000,
        isUtc: true,
      ).toLocal();
    }
  } catch (_) {
    return null;
  }
  return null;
}

class _StoredTokenPair {
  final String token;
  final String? refreshToken;
  final DateTime? expiresAt;
  final DateTime? refreshExpiresAt;

  const _StoredTokenPair({
    required this.token,
    this.refreshToken,
    this.expiresAt,
    this.refreshExpiresAt,
  });
}
