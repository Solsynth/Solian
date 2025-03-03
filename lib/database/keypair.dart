import 'package:drift/drift.dart';

class SnLocalKeyPair extends Table {
  TextColumn get id => text()();

  IntColumn get accountId => integer()();

  TextColumn get publicKey => text()();

  TextColumn get privateKey => text().nullable()();

  BoolColumn get isActive => boolean().withDefault(Constant(false))();
}
