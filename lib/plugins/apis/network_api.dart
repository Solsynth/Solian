import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:island/core/config.dart';
import 'package:island_plugin_foundation/island_plugin_foundation.dart';
import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';

final _log = Logger('PluginNetworkApi');

/// Host-specific API: permission-gated internet and Solar Network requests.
///
/// Lives in the Island app because it depends on the Solar Network server URL
/// and authenticated [Dio] client. The foundation package does not know about
/// Solar Network.
///
/// Requests are asynchronous. Results are delivered to a named JavaScript
/// callback, and the signed-in token is only ever attached by the host.
class PluginNetworkApi extends PluginApi {
  final SharedPreferences _preferences;
  final Dio _solarClient;

  PluginNetworkApi(this._preferences, this._solarClient);

  @override
  Set<PluginPermission> get requiredPermissions => {
    PluginPermission.networkInternet,
    PluginPermission.solarNetworkApi,
  };

  @override
  String jsBindingsFor(Set<PluginPermission> granted) {
    final buf = StringBuffer();
    if (granted.contains(PluginPermission.networkInternet)) {
      buf.writeln('''
var internet = {};
internet.request = function(method, url, options, callback) {
  sendMessage("api:internet:request", JSON.stringify({method: method, url: url, headers: (options && options.headers) || {}, body: options && options.body, callback: callback}));
};
''');
    }
    if (granted.contains(PluginPermission.solarNetworkApi)) {
      buf.writeln('''
var solar = {};
solar.request = function(method, path, options, callback) {
  sendMessage("api:solar:request", JSON.stringify({method: method, url: path, headers: (options && options.headers) || {}, body: options && options.body, callback: callback}));
};
''');
    }
    return buf.toString();
  }

  @override
  void register(JsRuntime runtime) {
    final pluginId = PluginManager.activePluginId;
    final permissions = pluginId == null
        ? const <PluginPermission>{}
        : PluginManager().plugins[pluginId]?.manifest.permissions.toSet() ??
              const <PluginPermission>{};
    if (permissions.contains(PluginPermission.networkInternet)) {
      runtime.onMessage('api:internet:request', (args) {
        _queueRequest(runtime, args, useSolarNetwork: false);
      });
    }
    if (permissions.contains(PluginPermission.solarNetworkApi)) {
      runtime.onMessage('api:solar:request', (args) {
        _queueRequest(runtime, args, useSolarNetwork: true);
      });
    }
  }

  void _queueRequest(
    JsRuntime runtime,
    dynamic args, {
    required bool useSolarNetwork,
  }) {
    try {
      final data = args is String ? jsonDecode(args) : args;
      if (data is! Map) return;
      unawaited(
        _request(
          runtime,
          data.map((key, value) => MapEntry(key.toString(), value)),
          useSolarNetwork: useSolarNetwork,
        ),
      );
    } catch (error) {
      _log.warning('Failed to read plugin network request: $error');
    }
  }

  Future<void> _request(
    JsRuntime runtime,
    Map<String, dynamic> request, {
    required bool useSolarNetwork,
  }) async {
    final callback = request['callback']?.toString();
    if (callback == null || callback.isEmpty) return;

    try {
      final uri = _resolveUri(request['url']?.toString(), useSolarNetwork);
      final headers = _safeHeaders(request['headers']);
      final response = await (useSolarNetwork ? _solarClient : Dio())
          .requestUri<dynamic>(
            uri,
            data: request['body'],
            options: Options(
              method: request['method']?.toString().toUpperCase() ?? 'GET',
              headers: headers,
              responseType: ResponseType.json,
              validateStatus: (_) => true,
              sendTimeout: const Duration(seconds: 15),
              receiveTimeout: const Duration(seconds: 30),
            ),
          );
      runtime.callFunction(callback, [
        {
          'ok':
              response.statusCode != null &&
              response.statusCode! >= 200 &&
              response.statusCode! < 300,
          'status': response.statusCode,
          'data': response.data,
        },
      ]);
    } catch (error) {
      runtime.callFunction(callback, [
        {'ok': false, 'status': null, 'error': error.toString()},
      ]);
    }
  }

  Uri _resolveUri(String? value, bool useSolarNetwork) {
    if (value == null || value.isEmpty) {
      throw ArgumentError('A URL is required');
    }
    if (!useSolarNetwork) {
      final uri = Uri.tryParse(value);
      if (uri == null || (uri.scheme != 'http' && uri.scheme != 'https')) {
        throw ArgumentError('Internet URLs must use HTTP or HTTPS');
      }
      return uri;
    }
    final path = Uri.tryParse(value);
    if (path == null || path.hasScheme || !value.startsWith('/')) {
      throw ArgumentError('Solar Network requests must use a relative path');
    }
    final baseUrl =
        _preferences.getString(kNetworkServerStoreKey) ?? kNetworkServerDefault;
    return Uri.parse(baseUrl).resolveUri(path);
  }

  Map<String, String> _safeHeaders(Object? value) {
    if (value is! Map) return {};
    final headers = <String, String>{};
    for (final entry in value.entries) {
      final name = entry.key.toString();
      if (const {
        'authorization',
        'cookie',
        'host',
      }.contains(name.toLowerCase())) {
        continue;
      }
      headers[name] = entry.value.toString();
    }
    return headers;
  }
}
