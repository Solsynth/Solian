import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:openmls/openmls.dart';
import 'package:island/talker.dart';
import 'mls_engine.dart';
import 'mls_storage.dart';

class MlsIdentityManager {
  final MlsStorage _storage;
  final Dio _padlockClient;

  MlsIdentityManager({required MlsStorage storage, required Dio padlockClient})
    : _storage = storage,
      _padlockClient = padlockClient;

  Future<String?> getOrCreateDeviceId() async {
    var deviceId = await _storage.getDeviceId();
    if (deviceId != null && deviceId.isNotEmpty) {
      return deviceId;
    }
    deviceId = _generateDeviceId();
    await _storage.setDeviceId(deviceId);
    return deviceId;
  }

  String _generateDeviceId() {
    final random = DateTime.now().millisecondsSinceEpoch.toString();
    final bytes = utf8.encode(random);
    return base64Url.encode(bytes).replaceAll('=', '');
  }

  Future<bool> hasCredential() async {
    return _storage.hasSignerKeyPair();
  }

  Future<String?> getCredential() async {
    return _storage.getSignerKeyPair();
  }

  Future<void> setCredential(String credential) async {
    await _storage.setSignerKeyPair(credential);
  }

  Future<void> deleteCredential() async {
    await _storage.deleteCredential();
  }

  Future<void> generateAndStoreSignerKeyPair() async {
    final existing = await _storage.getSignerKeyPair();
    if (existing != null && existing.isNotEmpty) {
      talker.debug('Signer keypair already exists');
      return;
    }

    final keyPair = MlsSignatureKeyPair.generate(
      ciphersuite: defaultCiphersuite,
    );
    final privateKey = keyPair.privateKey();
    final publicKey = keyPair.publicKey();

    final serialized = '${base64Encode(privateKey)}:${base64Encode(publicKey)}';
    await _storage.setSignerKeyPair(serialized);
    talker.debug('Signer keypair generated and stored');
  }

  Future<KeyPackageResult> generateKeyPackage() async {
    final engineService = await MlsEngineService.getInstance();
    final engine = engineService.engine;

    final signerKeyPairRaw = await _storage.getSignerKeyPair();
    if (signerKeyPairRaw == null) {
      throw Exception('Signer keypair not found');
    }

    final signerKeyPair = MlsSignatureKeyPair.fromRaw(
      ciphersuite: defaultCiphersuite,
      privateKey: base64Decode(signerKeyPairRaw.split(':')[0]),
      publicKey: base64Decode(signerKeyPairRaw.split(':')[1]),
    );

    final deviceId = await getOrCreateDeviceId();
    if (deviceId == null) {
      throw Exception('Device ID not found');
    }

    final kp = await engine.createKeyPackage(
      ciphersuite: defaultCiphersuite,
      signerBytes: signerKeyPair.privateKey(),
      credentialIdentity: utf8.encode(deviceId),
      signerPublicKey: signerKeyPair.publicKey(),
    );

    return kp;
  }

  Future<int> uploadKeyPackage(String keyPackage) async {
    try {
      final response = await _padlockClient.post(
        '/e2ee/mls/devices/me/key-packages',
        data: {'key_package': keyPackage},
        options: Options(headers: {'X-Client-Ability': 'chat-mls-v1'}),
      );
      await _storage.addKeyPackage(keyPackage);
      talker.debug('KeyPackage uploaded successfully');
      return response.statusCode ?? 200;
    } catch (e) {
      talker.error('Failed to upload KeyPackage: $e');
      rethrow;
    }
  }

  Future<int> uploadKeyPackages(List<String> keyPackages) async {
    var uploaded = 0;
    for (final kp in keyPackages) {
      try {
        await uploadKeyPackage(kp);
        uploaded++;
      } catch (e) {
        talker.warning('Failed to upload keypackage: $e');
      }
    }
    return uploaded;
  }

  Future<List<Map<String, dynamic>>> getDeviceKeyPackages(
    String accountId,
  ) async {
    try {
      final response = await _padlockClient.get(
        '/e2ee/mls/keys/$accountId/devices',
        options: Options(headers: {'X-Client-Ability': 'chat-mls-v1'}),
      );
      if (response.data is List) {
        return (response.data as List)
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
      }
      return [];
    } catch (e) {
      talker.error('Failed to get device keypackages: $e');
      return [];
    }
  }

  Future<bool> revokeDevice(String deviceId) async {
    try {
      final response = await _padlockClient.post(
        '/e2ee/mls/devices/$deviceId/revoke',
        options: Options(headers: {'X-Client-Ability': 'chat-mls-v1'}),
      );
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      talker.error('Failed to revoke device: $e');
      return false;
    }
  }

  Future<int> getKeyPackageUploadCount() async {
    return _storage.getKeyPackageCount();
  }
}
