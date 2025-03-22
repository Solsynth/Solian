import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:surface/types/realm.dart';

class SnRealmConverter extends TypeConverter<SnRealm, String>
    with JsonTypeConverter2<SnRealm, String, Map<String, Object?>> {
  const SnRealmConverter();

  @override
  SnRealm fromSql(String fromDb) {
    return fromJson(jsonDecode(fromDb) as Map<String, dynamic>);
  }

  @override
  String toSql(SnRealm value) {
    return jsonEncode(toJson(value));
  }

  @override
  SnRealm fromJson(Map<String, Object?> json) {
    return SnRealm.fromJson(json);
  }

  @override
  Map<String, Object?> toJson(SnRealm value) {
    return value.toJson();
  }
}

@TableIndex(name: 'idx_realm_alias', columns: {#alias})
@TableIndex(name: 'idx_realm_account', columns: {#accountId})
class SnLocalRealm extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get alias => text().unique()();

  TextColumn get content => text().map(const SnRealmConverter())();

  IntColumn get accountId => integer()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  DateTimeColumn get cacheExpiredAt => dateTime()();
}
