import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:surface/types/keypair.dart';

class SnKeyPairConverter extends TypeConverter<SnKeyPair, String>
    with JsonTypeConverter2<SnKeyPair, String, Map<String, Object?>> {
  const SnKeyPairConverter();

  @override
  SnKeyPair fromSql(String fromDb) {
    return fromJson(jsonDecode(fromDb) as Map<String, dynamic>);
  }

  @override
  String toSql(SnKeyPair value) {
    return jsonEncode(toJson(value));
  }

  @override
  SnKeyPair fromJson(Map<String, Object?> json) {
    return SnKeyPair.fromJson(json);
  }

  @override
  Map<String, Object?> toJson(SnKeyPair value) {
    return value.toJson();
  }
}

class SnLocalKeyPair extends Table {
  TextColumn get id => text()();

  IntColumn get accountId => integer()();

  TextColumn get publicKey => text()();

  TextColumn get privateKey => text().nullable()();
}
