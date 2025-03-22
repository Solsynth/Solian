import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:surface/database/account.dart';
import 'package:surface/database/attachment.dart';
import 'package:surface/database/chat.dart';
import 'package:surface/database/database.steps.dart';
import 'package:surface/database/keypair.dart';
import 'package:surface/database/realm.dart';
import 'package:surface/database/sticker.dart';
import 'package:surface/types/chat.dart';
import 'package:surface/types/attachment.dart';
import 'package:surface/types/account.dart';
import 'package:surface/types/realm.dart';

part 'database.g.dart';

@DriftDatabase(tables: [
  SnLocalChatChannel,
  SnLocalChatMessage,
  SnLocalChannelMember,
  SnLocalKeyPair,
  SnLocalAccount,
  SnLocalAttachment,
  SnLocalSticker,
  SnLocalStickerPack,
  SnLocalRealm,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? e]) : super(e ?? _openConnection());

  @override
  int get schemaVersion => 4;

  static QueryExecutor _openConnection() {
    return driftDatabase(
      name: 'solar_network_data',
      native: const DriftNativeOptions(
        databaseDirectory: getApplicationSupportDirectory,
      ),
      web: DriftWebOptions(
        sqlite3Wasm: Uri.parse('sqlite3.wasm'),
        driftWorker: Uri.parse('drift_worker.dart.js'),
      ),
    );
  }

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onUpgrade: stepByStep(from1To2: (m, schema) async {
        // Nothing else to do here
      }, from2To3: (m, schema) async {
        // Nothing else to do here, too
      }, from3To4: (m, schema) async {
        m.createTable(schema.snLocalRealm);
        m.createIndex(schema.idxRealmAccount);
        m.createIndex(schema.idxRealmAlias);
      }),
    );
  }
}
