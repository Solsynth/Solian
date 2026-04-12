import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logging/logging.dart';

class MlsStorage {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  static const _keyDeviceId = 'mls_device_id';
  static const _keyCredential = 'mls_credential';
  static const _keyKeyPackages = 'mls_key_packages';
  static const _keyGroupStates = 'mls_group_states';
  static const _keySignerKeyPair = 'mls_signer_keypair';
  static const _keySignerBytes = 'mls_signer_bytes';
  static const _keySignerPublicKey = 'mls_signer_public_key';
  static const _keyAccountId = 'mls_account_id';

  Future<void> setAccountId(String accountId) async {
    await _storage.write(key: _keyAccountId, value: accountId);
  }

  Future<String?> getAccountId() async {
    return _storage.read(key: _keyAccountId);
  }

  Future<String?> getDeviceId() async {
    return _storage.read(key: _keyDeviceId);
  }

  Future<void> setDeviceId(String deviceId) async {
    await _storage.write(key: _keyDeviceId, value: deviceId);
  }

  Future<String?> getCredential() async {
    return _storage.read(key: _keyCredential);
  }

  Future<void> setCredential(String credential) async {
    await _storage.write(key: _keyCredential, value: credential);
  }

  Future<void> deleteCredential() async {
    await _storage.delete(key: _keyCredential);
  }

  Future<List<String>> getKeyPackages() async {
    final raw = await _storage.read(key: _keyKeyPackages);
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        return decoded.map((e) => e.toString()).toList();
      }
    } catch (_) {}
    return [];
  }

  Future<void> setKeyPackages(List<String> keyPackages) async {
    await _storage.write(key: _keyKeyPackages, value: jsonEncode(keyPackages));
  }

  Future<void> addKeyPackage(String keyPackage) async {
    final existing = await getKeyPackages();
    existing.add(keyPackage);
    await setKeyPackages(existing);
  }

  Future<void> removeKeyPackage(String keyPackage) async {
    final existing = await getKeyPackages();
    existing.remove(keyPackage);
    await setKeyPackages(existing);
  }

  Future<int> getKeyPackageCount() async {
    return (await getKeyPackages()).length;
  }

  Future<Map<String, dynamic>?> getGroupState(String roomId) async {
    final raw = await _storage.read(key: '${_keyGroupStates}_$roomId');
    if (raw == null || raw.isEmpty) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {}
    return null;
  }

  Future<void> setGroupState(String roomId, Map<String, dynamic> state) async {
    await _storage.write(
      key: '${_keyGroupStates}_$roomId',
      value: jsonEncode(state),
    );
  }

  Future<void> deleteGroupState(String roomId) async {
    await _storage.delete(key: '${_keyGroupStates}_$roomId');
  }

  Future<List<String>> getAllGroupIds() async {
    final all = await _storage.readAll();
    return all.keys
        .where((k) => k.startsWith(_keyGroupStates))
        .map((k) => k.substring(_keyGroupStates.length + 1))
        .toList();
  }

  Future<void> clearAll() async {
    await _storage.deleteAll();
  }

  Future<void> clearAllForLogout() async {
    final keysToPreserve = [
      _keyDeviceId,
      _keyAccountId,
      'mls_db_encryption_key',
    ];

    final allKeys = await _storage.readAll();
    for (final key in allKeys.keys) {
      if (!keysToPreserve.contains(key)) {
        await _storage.delete(key: key);
      }
    }

    Logger.root.info(
      'MLS storage cleared for logout, preserved deviceId and accountId',
    );
  }

  Future<void> deleteAccountData() async {
    final deviceId = await getDeviceId();
    await clearAll();
    if (deviceId != null) {
      await setDeviceId(deviceId);
    }
  }

  Future<String?> getSignerKeyPair() async {
    return _storage.read(key: _keySignerKeyPair);
  }

  Future<void> setSignerKeyPair(String signerKeyPair) async {
    await _storage.write(key: _keySignerKeyPair, value: signerKeyPair);
  }

  Future<bool> hasSignerKeyPair() async {
    final raw = await _storage.read(key: _keySignerKeyPair);
    return raw != null && raw.isNotEmpty;
  }

  // New: signer bytes (from serializeSigner)
  Future<String?> getSignerBytes() async {
    return _storage.read(key: _keySignerBytes);
  }

  Future<void> setSignerBytes(String base64Value) async {
    await _storage.write(key: _keySignerBytes, value: base64Value);
  }

  // New: signer public key (stored separately for easy access)
  Future<String?> getSignerPublicKey() async {
    return _storage.read(key: _keySignerPublicKey);
  }

  Future<void> setSignerPublicKey(String base64Value) async {
    await _storage.write(key: _keySignerPublicKey, value: base64Value);
  }
}
