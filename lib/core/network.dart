import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/io.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:island/core/config.dart';
import 'package:island/core/network/media_proxy_server.dart';
import 'package:logging/logging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:solar_network_sdk/solar_network_sdk.dart';

part 'network.g.dart';

class RefreshTokenExpiredException implements Exception {
  final String message;
  RefreshTokenExpiredException([
    this.message = 'Session expired due to inactivity. Please login again.',
  ]);

  @override
  String toString() => message;
}

// Network status enum to track different states
enum NetworkStatus { online, notReady, maintenance, offline }

final connectivityProvider = Provider<Connectivity>((ref) => Connectivity());

final connectivityStatusProvider = StreamProvider<List<ConnectivityResult>>((
  ref,
) async* {
  final connectivity = ref.watch(connectivityProvider);
  yield await connectivity.checkConnectivity();
  yield* connectivity.onConnectivityChanged;
});

bool hasNetworkConnectivity(List<ConnectivityResult> results) {
  return results.any((result) => result != ConnectivityResult.none);
}

bool hasNetworkConnectivityValue(AsyncValue<List<ConnectivityResult>> value) {
  return value.maybeWhen(data: hasNetworkConnectivity, orElse: () => true);
}

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
const String _chatMlsCapability = 'chat.mls.v2';
const Duration _tokenExpirySkew = Duration(seconds: 30);
const Duration _tokenRefreshInterval = Duration(minutes: 5);

Future<_StoredTokenPair?>? _tokenRefreshInFlight;
Future<_StoredTokenPair?>? _forceTokenRefreshInFlight;

typedef IpOverrideConnectionFactory =
    Future<ConnectionTask<SecureSocket>> Function(
      Uri url,
      String? proxyHost,
      int? proxyPort,
    );

IpOverrideConnectionFactory createIpOverrideConnectionFactory({
  required String domainSuffix,
  required String ip,
  int? port,
}) {
  return (Uri uri, String? proxyHost, int? proxyPort) async {
    if (!uri.host.endsWith(domainSuffix)) {
      throw UnimplementedError();
    }
    final targetPort = port ?? uri.port;
    final socketFuture = Socket.connect(ip, targetPort == 0 ? 443 : targetPort)
        .then(
          (socket) => SecureSocket.secure(
            socket,
            host: uri.host,
            onBadCertificate: (_) => true,
          ),
        );
    return ConnectionTask.fromSocket(socketFuture, () {
      Logger.root.fine(
        'Canncelled established IP override connection to ${uri.host} ($ip:$targetPort)',
      );
    });
  };
}

final ipOverrideConnectionFactoryProvider =
    Provider<IpOverrideConnectionFactory?>((ref) {
      final settings = ref.watch(ipOverrideSettingsProvider);
      if (!settings.enabled || settings.overrides.isEmpty) {
        return null;
      }
      final domainSuffix = ref.watch(ipOverrideDomainSuffixProvider);
      if (domainSuffix == null) {
        return null;
      }
      final override = settings.overrides.firstOrNull;
      if (override == null) {
        return null;
      }
      return createIpOverrideConnectionFactory(
        domainSuffix: domainSuffix,
        ip: override.ip,
        port: override.port,
      );
    });

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

  final connectionFactory = ref.watch(ipOverrideConnectionFactoryProvider);
  if (connectionFactory != null) {
    dio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () {
        final client = HttpClient();
        client.connectionFactory = connectionFactory;
        return client;
      },
    );
  }

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
    InterceptorsWrapper(
      onRequest: (options, handler) {
        Logger.root.fine('[API] ${options.method} ${options.uri}');
        handler.next(options);
      },
      onResponse: (options, handler) {
        if (options.statusCode != null &&
            options.statusCode! >= 200 &&
            options.statusCode! < 300) {
          Logger.root.fine(
            '[API] OK ${options.statusCode} ${options.requestOptions.method} ${options.requestOptions.uri}',
          );
        } else {
          Logger.root.warning(
            '[API] FAIL ${options.statusCode} ${options.requestOptions.method} ${options.requestOptions.uri}\nHeaders: ${options.requestOptions.headers}\nRequest: ${options.requestOptions.data}\nResponse: ${options.data}',
          );
        }
        handler.next(options);
      },
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

  final connectionFactory = ref.watch(ipOverrideConnectionFactoryProvider);
  if (connectionFactory != null) {
    dio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () {
        final client = HttpClient();
        client.connectionFactory = connectionFactory;
        return client;
      },
    );
  }

  dio.interceptors.addAll([
    InterceptorsWrapper(
      onRequest: (options, handler) {
        Logger.root.fine('[API] ${options.method} ${options.uri}');
        handler.next(options);
      },
      onResponse: (options, handler) {
        if (options.statusCode != null &&
            options.statusCode! >= 200 &&
            options.statusCode! < 300) {
          Logger.root.fine(
            '[API] OK ${options.statusCode} ${options.requestOptions.method} ${options.requestOptions.uri}',
          );
        } else {
          Logger.root.warning(
            '[API] FAIL ${options.statusCode} ${options.requestOptions.method} ${options.requestOptions.uri}\nHeaders: ${options.requestOptions.headers}\nRequest: ${options.requestOptions.data}\nResponse: ${options.data}',
          );
        }
        handler.next(options);
      },
    ),
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

Future<void> forceRefreshToken({
  required SharedPreferences prefs,
  required String serverUrl,
}) async {
  if (_forceTokenRefreshInFlight != null) {
    await _forceTokenRefreshInFlight;
    return;
  }

  _forceTokenRefreshInFlight = () async {
    final tokenPair = _readTokenPairFromPrefs(prefs);
    if (tokenPair == null) return;
    if (tokenPair.refreshToken == null || tokenPair.refreshToken!.isEmpty) {
      throw RefreshTokenExpiredException();
    }
    if (!_isNotExpired(tokenPair.refreshExpiresAt)) {
      throw RefreshTokenExpiredException();
    }

    final refreshed = await _refreshTokenPairInternal(
      serverUrl: serverUrl,
      prefs: prefs,
      current: tokenPair,
    );
    if (refreshed != null) {
      Logger.root.fine('[Network] Force token refresh completed.');
    }
  }();

  try {
    await _forceTokenRefreshInFlight;
  } finally {
    _forceTokenRefreshInFlight = null;
  }
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
  final issuedAt = _decodeJwtIssuedAt(tokenPair.token);
  final now = DateTime.now();

  if (issuedAt != null) {
    final timeSinceIssued = now.difference(issuedAt);
    if (timeSinceIssued < _tokenRefreshInterval) {
      return false;
    }
  }

  if (_isNotExpired(tokenPair.expiresAt)) return false;
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
  final serverUrl = ref.read(serverUrlProvider);
  return _refreshTokenPairInternal(
    serverUrl: serverUrl,
    prefs: prefs,
    current: current,
    onRefreshed: () => ref.invalidate(tokenProvider),
  );
}

Future<_StoredTokenPair?> _refreshTokenPairInternal({
  required String serverUrl,
  required SharedPreferences prefs,
  required _StoredTokenPair current,
  void Function()? onRefreshed,
}) async {
  if (_tokenRefreshInFlight != null) {
    return _tokenRefreshInFlight;
  }

  _tokenRefreshInFlight = () async {
    final refreshToken = current.refreshToken;
    final client = Dio(
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
      onRefreshed?.call();
      Logger.root.fine('[Network] Access token refreshed.');
      return refreshed;
    } catch (err) {
      Logger.root.warning('[Network] Token refresh failed: $err');
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

DateTime? _decodeJwtIssuedAt(String token) {
  final parts = token.split('.');
  if (parts.length < 2) return null;
  try {
    final normalized = base64Url.normalize(parts[1]);
    final payload = utf8.decode(base64Url.decode(normalized));
    final map = jsonDecode(payload);
    if (map is! Map) return null;
    final iat = map['iat'];
    if (iat is int) {
      return DateTime.fromMillisecondsSinceEpoch(
        iat * 1000,
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

// ==========================================
// Solar Network SDK Client Provider
// ==========================================

/// Provider for the SolarNetworkClient instance.
/// This client wraps all typed API classes for different domains.
final solarNetworkClientProvider = Provider<SolarNetworkClient>((ref) {
  final dio = ref.watch(apiClientProvider);
  final client = SolarNetworkClient.fromDio(dio);

  // Clean up when the provider is disposed
  ref.onDispose(() {
    client.close();
  });

  return client;
});

// ==========================================
// Media Proxy Server Providers
// ==========================================

final mediaProxyServerProvider = Provider<MediaProxyServer>((ref) {
  final server = MediaProxyServer(ref);
  ref.onDispose(() {
    server.stop();
  });
  return server;
});

final mediaProxyUrlProvider = FutureProvider<String?>((ref) async {
  final settings = ref.watch(appSettingsProvider);
  if (!settings.mediaProxyEnabled) {
    return null;
  }

  final server = ref.read(mediaProxyServerProvider);
  if (!server.isRunning) {
    try {
      await server.start();
    } catch (e) {
      Logger.root.severe('[media.proxy] Failed to start: $e');
      return null;
    }
  }
  return server.baseUrl;
});
