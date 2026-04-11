import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:island/core/services/push_provider.dart';
import 'package:logging/logging.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:unifiedpush/unifiedpush.dart';
import 'package:unifiedpush_platform_interface/unifiedpush_platform_interface.dart';
import 'package:unifiedpush_storage_interface/distributor_storage.dart';
import 'package:unifiedpush_storage_interface/keys_storage.dart';
import 'package:unifiedpush_storage_interface/registrations_storage.dart';
import 'package:unifiedpush_storage_interface/storage.dart';

const kUnifiedPushInstance = 'island-main';
const kUnifiedPushDbusName = 'dev.solsynth.solian';

bool _isInitialized = false;
Completer<PushEndpoint>? _registrationCompleter;

Future<void> initializeUnifiedPush(List<String> args) async {
  if (kIsWeb || !(Platform.isAndroid || Platform.isLinux) || _isInitialized) {
    return;
  }

  LinuxOptions? linuxOptions;
  if (Platform.isLinux) {
    linuxOptions = LinuxOptions(
      dbusName: kUnifiedPushDbusName,
      storage: _UnifiedPushPrefsStorage(await SharedPreferences.getInstance()),
      background: args.contains('--unifiedpush-bg'),
    );
  }

  await UnifiedPush.initialize(
    onNewEndpoint: _onNewEndpoint,
    onRegistrationFailed: _onRegistrationFailed,
    onUnregistered: _onUnregistered,
    onMessage: _onMessage,
    onTempUnavailable: _onTempUnavailable,
    linuxOptions: linuxOptions,
  );
  _isInitialized = true;
}

Future<String> registerUnifiedPush(Dio apiClient) async {
  if (!_isInitialized) {
    await initializeUnifiedPush(const []);
  }

  final canUseDefaultDistributor =
      await UnifiedPush.tryUseCurrentOrDefaultDistributor();
  if (!canUseDefaultDistributor) {
    final distributors = await UnifiedPush.getDistributors();
    if (distributors.isEmpty) {
      throw Exception(
        'No UnifiedPush distributor is installed on this device.',
      );
    }

    await UnifiedPush.saveDistributor(distributors.first);
  }

  _registrationCompleter = Completer<PushEndpoint>();
  await UnifiedPush.register(instance: kUnifiedPushInstance);
  final endpoint = await _registrationCompleter!.future.timeout(
    const Duration(seconds: 20),
    onTimeout: () {
      throw TimeoutException(
        'Timed out while waiting for a UnifiedPush endpoint.',
      );
    },
  );

  await apiClient.put(
    '/ring/notifications/subscription',
    data: {
      'type': PushNotificationProvider.unifiedpush.remoteType,
      'device_token': endpoint.url,
    },
  );
  return endpoint.url;
}

void _onNewEndpoint(PushEndpoint endpoint, String instance) {
  Logger.root.info('[UnifiedPush] New endpoint received for $instance');
  _registrationCompleter?.complete(endpoint);
  _registrationCompleter = null;
}

void _onRegistrationFailed(FailedReason reason, String instance) {
  Logger.root.severe(
    '[UnifiedPush] Registration failed for $instance: $reason',
  );
  _registrationCompleter?.completeError(
    Exception('UnifiedPush registration failed: $reason'),
  );
  _registrationCompleter = null;
}

void _onUnregistered(String instance) {
  Logger.root.info('[UnifiedPush] Unregistered instance: $instance');
}

void _onTempUnavailable(String instance) {
  Logger.root.warning('[UnifiedPush] Temporarily unavailable for $instance');
}

void _onMessage(PushMessage message, String instance) {
  final content = utf8.decode(message.content, allowMalformed: true);
  Logger.root.info(
    '[UnifiedPush] Message received for $instance (decrypted=${message.decrypted}): $content',
  );
}

const _kUnifiedPushDistributorKey = 'unifiedpush_distributor';
const _kUnifiedPushRegistrationsKey = 'unifiedpush_registrations';
const _kUnifiedPushKeysKey = 'unifiedpush_keys';

class _UnifiedPushPrefsStorage implements UnifiedPushStorage {
  final SharedPreferences prefs;

  _UnifiedPushPrefsStorage(this.prefs);

  @override
  Future<void> init() async {}

  @override
  DistributorStorage get distrib => _PrefsDistributorStorage(prefs);

  @override
  KeysStorage get keys => _PrefsKeysStorage(prefs);

  @override
  RegistrationsStorage get registrations => _PrefsRegistrationsStorage(prefs);
}

class _PrefsDistributorStorage implements DistributorStorage {
  final SharedPreferences prefs;

  _PrefsDistributorStorage(this.prefs);

  @override
  String? get() => prefs.getString(_kUnifiedPushDistributorKey);

  @override
  Future<void> set(String distributor) async {
    await prefs.setString(_kUnifiedPushDistributorKey, distributor);
  }

  @override
  Future<void> ack() async {}

  @override
  Future<void> remove() async {
    await prefs.remove(_kUnifiedPushDistributorKey);
  }
}

class _PrefsRegistrationsStorage implements RegistrationsStorage {
  final SharedPreferences prefs;

  _PrefsRegistrationsStorage(this.prefs);

  Map<String, String> _read() {
    final raw = prefs.getString(_kUnifiedPushRegistrationsKey);
    if (raw == null || raw.isEmpty) return {};
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return decoded.map((key, value) => MapEntry(key, value.toString()));
      }
    } catch (_) {}
    return {};
  }

  Future<void> _write(Map<String, String> registrations) async {
    await prefs.setString(
      _kUnifiedPushRegistrationsKey,
      jsonEncode(registrations),
    );
  }

  @override
  TokenInstance? getFromInstance(String instance) {
    final registrations = _read();
    final token = registrations[instance];
    if (token == null) return null;
    return TokenInstance(token, instance);
  }

  @override
  TokenInstance? getFromToken(String token) {
    final registrations = _read();
    for (final entry in registrations.entries) {
      if (entry.value == token) {
        return TokenInstance(token, entry.key);
      }
    }
    return null;
  }

  @override
  Future<void> save(TokenInstance token) async {
    final registrations = _read();
    registrations[token.instance] = token.token;
    await _write(registrations);
  }

  @override
  Future<bool> remove(String instance) async {
    final registrations = _read();
    registrations.remove(instance);
    await _write(registrations);
    return registrations.isNotEmpty;
  }

  @override
  Future<void> removeAll() async {
    await prefs.remove(_kUnifiedPushRegistrationsKey);
  }
}

class _PrefsKeysStorage implements KeysStorage {
  final SharedPreferences prefs;

  _PrefsKeysStorage(this.prefs);

  Map<String, String> _read() {
    final raw = prefs.getString(_kUnifiedPushKeysKey);
    if (raw == null || raw.isEmpty) return {};
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return decoded.map((key, value) => MapEntry(key, value.toString()));
      }
    } catch (_) {}
    return {};
  }

  Future<void> _write(Map<String, String> keys) async {
    await prefs.setString(_kUnifiedPushKeysKey, jsonEncode(keys));
  }

  @override
  String? get(String instance) => _read()[instance];

  @override
  Future<void> set(String instance, String serializedKey) async {
    final keys = _read();
    keys[instance] = serializedKey;
    await _write(keys);
  }

  @override
  Future<void> remove(String instance) async {
    final keys = _read();
    keys.remove(instance);
    await _write(keys);
  }
}
