import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:openmls/openmls.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class MlsEngineService {
  static MlsEngineService? _instance;
  static MlsEngine? _engine;
  static bool _initialized = false;
  static Completer<void>? _initCompleter;
  static Future<void> _engineQueue = Future<void>.value();
  static final Map<String, Future<void>> _groupQueues = {};

  MlsEngineService._();

  /// Whether an MLS room has requested the native engine in this process.
  static bool get isReady => _initialized && _engine != null;

  /// Serializes native OpenMLS SQLite operations so concurrent async tasks
  /// never interleave FFI transactions on the same database handle.
  Future<T> runSerialized<T>(Future<T> Function(MlsEngine engine) action) {
    final completer = Completer<T>();
    final previous = _engineQueue;
    _engineQueue = previous.catchError((_) {}).then((_) async {
      try {
        final result = await action(engine);
        completer.complete(result);
      } catch (e, st) {
        completer.completeError(e, st);
      }
    });
    return completer.future;
  }

  /// Serializes multi-step group lifecycle workflows (bootstrap, external join,
  /// welcome, commit processing) per MLS group ID.
  static Future<T> runForGroup<T>(
    String mlsGroupId,
    Future<T> Function() action,
  ) {
    final completer = Completer<T>();
    final previous = _groupQueues[mlsGroupId] ?? Future<void>.value();
    final current = previous.catchError((_) {}).then((_) async {
      try {
        final result = await action();
        completer.complete(result);
      } catch (e, st) {
        completer.completeError(e, st);
      }
    });
    _groupQueues[mlsGroupId] = current;
    current.whenComplete(() {
      if (identical(_groupQueues[mlsGroupId], current)) {
        _groupQueues.remove(mlsGroupId);
      }
    });
    return completer.future;
  }

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
      aOptions: AndroidOptions(),
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
      Logger.root.info('Generated new MLS database encryption key');
    }

    final encryptionKey = base64Decode(dbKeyBase64);

    String dbPath;
    if (kIsWeb) {
      dbPath = 'mls_db';
      _engine = await MlsEngine.create(
        dbPath: dbPath,
        encryptionKey: encryptionKey,
      );
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
          Logger.root.info('Opened existing MLS database');
        } catch (e) {
          if (e.toString().contains('file is not a database') ||
              e.toString().contains('wrong key') ||
              e.toString().contains('not a database')) {
            final backupPath =
                '$dbPath.unreadable.${DateTime.now().toUtc().millisecondsSinceEpoch}';
            Logger.root.warning(
              'MLS database cannot be opened; preserving it at $backupPath '
              'before creating a recovery database.',
            );
            await dbFile.rename(backupPath);
            _engine = await MlsEngine.create(
              dbPath: dbPath,
              encryptionKey: encryptionKey,
            );
            Logger.root.info('Created new MLS database after corruption');
          } else {
            rethrow;
          }
        }
      } else {
        _engine = await MlsEngine.create(
          dbPath: dbPath,
          encryptionKey: encryptionKey,
        );
        Logger.root.info('Created new MLS database');
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
