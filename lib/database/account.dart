import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:surface/types/account.dart';

class SnAccountConverter extends TypeConverter<SnAccount, String>
    with JsonTypeConverter2<SnAccount, String, Map<String, Object?>> {
  const SnAccountConverter();

  @override
  SnAccount fromSql(String fromDb) {
    return fromJson(jsonDecode(fromDb) as Map<String, dynamic>);
  }

  @override
  String toSql(SnAccount value) {
    return jsonEncode(toJson(value));
  }

  @override
  SnAccount fromJson(Map<String, Object?> json) {
    return SnAccount.fromJson(json);
  }

  @override
  Map<String, Object?> toJson(SnAccount value) {
    return value.toJson();
  }
}

@TableIndex(name: 'idx_account_name', columns: {#name})
class SnLocalAccount extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get name => text()();

  TextColumn get content => text().map(const SnAccountConverter())();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
