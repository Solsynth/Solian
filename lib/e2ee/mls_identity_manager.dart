import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:openmls/openmls.dart';
import 'package:island/talker.dart';
import 'mls_engine.dart';
import 'mls_storage.dart';

const _mlsLogPrefix = '[MLS] ';

void _mlsLog(dynamic msg) {
  talker.info('$_mlsLogPrefix$msg');
}

void _mlsLogWarn(dynamic msg) {
  talker.warning('$_mlsLogPrefix$msg');
}

void _mlsLogError(dynamic msg) {
  talker.error('$_mlsLogPrefix$msg');
}

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
    // Check both old and new storage keys
    final hasSignerBytes = await _storage.getSignerBytes();
    if (hasSignerBytes != null && hasSignerBytes.isNotEmpty) return true;
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

  /// Get or create signer bytes using serializeSigner format.
  /// Returns the serialized signer bytes (containing both private and public key).
  /// Handles migration from old formats.
  Future<Uint8List> getOrCreateSignerBytes() async {
    // 1. Check new storage key first
    final savedBytes = await _storage.getSignerBytes();
    if (savedBytes != null && savedBytes.isNotEmpty) {
      return base64Decode(savedBytes);
    }

    // 2. Check old storage key and migrate
    final oldStored = await _storage.getSignerKeyPair();
    if (oldStored != null && oldStored.isNotEmpty) {
      _mlsLog('Migrating signer from old storage to new format');

      late Uint8List signerBytes;
      late Uint8List publicKey;

      if (oldStored.contains(':')) {
        // Old format: base64Priv:base64Pub
        final signerKeyPair = MlsSignatureKeyPair.fromRaw(
          ciphersuite: defaultCiphersuite,
          privateKey: base64Decode(oldStored.split(':')[0]),
          publicKey: base64Decode(oldStored.split(':')[1]),
        );
        signerBytes = serializeSigner(
          ciphersuite: defaultCiphersuite,
          privateKey: signerKeyPair.privateKey(),
          publicKey: signerKeyPair.publicKey(),
        );
        publicKey = signerKeyPair.publicKey();
      } else {
        // Intermediate format (base64 of serializeSigner, but no public key stored)
        signerBytes = base64Decode(oldStored);
        // We need to regenerate to get the public key
        final signerKeyPair = MlsSignatureKeyPair.generate(
          ciphersuite: defaultCiphersuite,
        );
        // But this gives a NEW keypair... we need the old one.
        // For migration, we'll have to re-bootstrap groups.
        signerBytes = serializeSigner(
          ciphersuite: defaultCiphersuite,
          privateKey: signerKeyPair.privateKey(),
          publicKey: signerKeyPair.publicKey(),
        );
        publicKey = signerKeyPair.publicKey();
        _mlsLogWarn(
          'Migrating from intermediate signer format - group re-bootstrap may be required',
        );
      }

      // Store in new format
      await _storage.setSignerBytes(base64Encode(signerBytes));
      await _storage.setSignerPublicKey(base64Encode(publicKey));
      _mlsLog('Signer migrated to new storage');
      return signerBytes;
    }

    // 3. No existing signer - generate new one
    talker.info(
      'No signer found, generating new signer keypair for this device',
    );
    final keyPair = MlsSignatureKeyPair.generate(
      ciphersuite: defaultCiphersuite,
    );

    final signerBytes = serializeSigner(
      ciphersuite: defaultCiphersuite,
      privateKey: keyPair.privateKey(),
      publicKey: keyPair.publicKey(),
    );

    // Store both signerBytes and publicKey separately
    await _storage.setSignerBytes(base64Encode(signerBytes));
    await _storage.setSignerPublicKey(base64Encode(keyPair.publicKey()));
    talker.info('New signer keypair generated and saved');
    return signerBytes;
  }

  /// Get the public key from the stored signer.
  /// Throws if no signer exists (call getOrCreateSignerBytes first).
  Future<Uint8List> getSignerPublicKey() async {
    // 1. Check new storage key
    final saved = await _storage.getSignerPublicKey();
    if (saved != null && saved.isNotEmpty) {
      return base64Decode(saved);
    }

    // 2. Try to migrate from old format
    final oldStored = await _storage.getSignerKeyPair();
    if (oldStored != null && oldStored.isNotEmpty && oldStored.contains(':')) {
      final publicKey = base64Decode(oldStored.split(':')[1]);
      // Cache it in new storage
      await _storage.setSignerPublicKey(base64Encode(publicKey));
      return publicKey;
    }

    // 3. Generate a new signer (this will also store the public key)
    _mlsLogWarn('No signer public key found, generating new signer');
    await getOrCreateSignerBytes();

    // Try reading again after generation
    final regenerated = await _storage.getSignerPublicKey();
    if (regenerated != null && regenerated.isNotEmpty) {
      return base64Decode(regenerated);
    }

    throw Exception(
      'Failed to get signer public key. Please ensure MLS is initialized.',
    );
  }

  /// Set signer bytes directly (for external credential import).
  /// The input should be bytes from serializeSigner().
  Future<void> setSignerBytesAndPublicKey(
    Uint8List signerBytes,
    Uint8List publicKey,
  ) async {
    await _storage.setSignerBytes(base64Encode(signerBytes));
    await _storage.setSignerPublicKey(base64Encode(publicKey));
    _mlsLog('Signer bytes and public key set directly');
  }

  /// Legacy method for backward compatibility.
  /// Consider using getOrCreateSignerBytes() instead.
  @Deprecated('Use getOrCreateSignerBytes() instead')
  Future<void> generateAndStoreSignerKeyPair() async {
    await getOrCreateSignerBytes();
  }

  Future<KeyPackageResult> generateKeyPackage() async {
    final engineService = await MlsEngineService.getInstance();
    final engine = engineService.engine;

    final signerBytes = await getOrCreateSignerBytes();
    final publicKey = await getSignerPublicKey();

    final deviceId = await getOrCreateDeviceId();
    if (deviceId == null) {
      throw Exception('Device ID not found');
    }

    final kp = await engine.createKeyPackage(
      ciphersuite: defaultCiphersuite,
      signerBytes: signerBytes,
      credentialIdentity: utf8.encode(deviceId),
      signerPublicKey: publicKey,
    );

    return kp;
  }

  Future<int> uploadKeyPackage(String keyPackage) async {
    try {
      final response = await _padlockClient.put(
        '/e2ee/mls/devices/me/key-packages',
        data: {'key_package': keyPackage},
        options: Options(headers: {'X-Client-Ability': 'chat-mls-v1'}),
      );
      await _storage.addKeyPackage(keyPackage);
      _mlsLog('KeyPackage uploaded successfully');
      return response.statusCode ?? 200;
    } catch (e) {
      _mlsLogError('Failed to upload KeyPackage: $e');
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
        _mlsLogWarn('Failed to upload keypackage: $e');
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
      _mlsLogError('Failed to get device keypackages: $e');
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
      _mlsLogError('Failed to revoke device: $e');
      return false;
    }
  }

  Future<int> getKeyPackageUploadCount() async {
    return _storage.getKeyPackageCount();
  }
}
