import 'dart:convert';
import 'dart:math';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:openmls/openmls.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:island/talker.dart';

class MlsEngineService {
  static MlsEngineService? _instance;
  MlsEngine? _engine;
  bool _initialized = false;

  MlsEngineService._();

  static Future<MlsEngineService> getInstance() async {
    if (_instance == null) {
      _instance = MlsEngineService._();
      await _instance!._initialize();
    } else if (!_instance!._initialized) {
      await _instance!._initialize();
    }
    return _instance!;
  }

  Future<void> _initialize() async {
    if (_initialized && _engine != null) return;

    await Openmls.init();

    const secureStorage = FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
      iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
    );

    String? dbKeyBase64 = await secureStorage.read(
      key: 'mls_db_encryption_key',
    );
    if (dbKeyBase64 == null) {
      final newKey = Uint8List(32);
      final random = Random.secure();
      for (var i = 0; i < 32; i++) {
        newKey[i] = random.nextInt(256);
      }
      dbKeyBase64 = base64Encode(newKey);
      await secureStorage.write(
        key: 'mls_db_encryption_key',
        value: dbKeyBase64,
      );
    }

    final encryptionKey = base64Decode(dbKeyBase64);

    String dbPath;
    if (kIsWeb) {
      dbPath = 'mls_db';
    } else {
      final appSupportDir = await getApplicationSupportDirectory();
      final dbDir = Directory(appSupportDir.path);
      if (!await dbDir.exists()) {
        await dbDir.create(recursive: true);
      }
      dbPath = '${appSupportDir.path}/mls_encrypted.db';

      // Check if database file exists and is valid
      final dbFile = File(dbPath);
      if (await dbFile.exists()) {
        try {
          _engine = await MlsEngine.create(
            dbPath: dbPath,
            encryptionKey: encryptionKey,
          );
        } catch (e) {
          if (e.toString().contains('file is not a database') ||
              e.toString().contains('wrong key')) {
            talker.warning(
              'Corrupted MLS database, deleting and recreating...',
            );
            await dbFile.delete();
            _engine = await MlsEngine.create(
              dbPath: dbPath,
              encryptionKey: encryptionKey,
            );
          } else {
            rethrow;
          }
        }
      } else {
        _engine = await MlsEngine.create(
          dbPath: dbPath,
          encryptionKey: encryptionKey,
        );
      }
    }

    _initialized = true;
  }

  MlsEngine get engine {
    if (_engine == null) {
      throw StateError('MlsEngine not initialized. Call getInstance() first.');
    }
    return _engine!;
  }

  bool get isInitialized => _initialized && _engine != null;

  Future<void> close() async {
    await _engine?.close();
    _engine = null;
    _initialized = false;
  }

  static void resetInstance() {
    _instance = null;
  }
}

MlsCiphersuite get defaultCiphersuite =>
    MlsCiphersuite.mls128DhkemX25519Aes128GcmSha256Ed25519;
