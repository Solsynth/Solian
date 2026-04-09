import 'dart:async';
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
  static MlsEngine? _engine;
  static bool _initialized = false;
  static Completer<void>? _initCompleter;

  MlsEngineService._();

  static Future<MlsEngineService> getInstance() async {
    if (_instance != null && _initialized && _engine != null) {
      return _instance!;
    }

    if (_initCompleter != null) {
      await _initCompleter!.future;
      return _instance!;
    }

    _initCompleter = Completer<void>();
    try {
      _instance = MlsEngineService._();
      await _instance!._initialize();
      _initCompleter!.complete();
      return _instance!;
    } catch (e) {
      _initCompleter!.completeError(e);
      rethrow;
    } finally {
      _initCompleter = null;
    }
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
      talker.info('Generated new MLS database encryption key');
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

      final dbFile = File(dbPath);
      if (await dbFile.exists()) {
        try {
          _engine = await MlsEngine.create(
            dbPath: dbPath,
            encryptionKey: encryptionKey,
          );
          talker.info('Opened existing MLS database');
        } catch (e) {
          if (e.toString().contains('file is not a database') ||
              e.toString().contains('wrong key') ||
              e.toString().contains('not a database')) {
            talker.warning(
              'Corrupted MLS database, deleting and recreating...',
            );
            await dbFile.delete();
            _engine = await MlsEngine.create(
              dbPath: dbPath,
              encryptionKey: encryptionKey,
            );
            talker.info('Created new MLS database after corruption');
          } else {
            rethrow;
          }
        }
      } else {
        _engine = await MlsEngine.create(
          dbPath: dbPath,
          encryptionKey: encryptionKey,
        );
        talker.info('Created new MLS database');
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
    if (_engine != null) {
      await _engine!.close();
      _engine = null;
      _initialized = false;
      _instance = null;
    }
  }

  static void resetInstance() {
    _instance = null;
    _engine = null;
    _initialized = false;
  }
}

MlsCiphersuite get defaultCiphersuite =>
    MlsCiphersuite.mls128DhkemX25519Aes128GcmSha256Ed25519;
