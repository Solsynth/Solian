import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:surface/types/attachment.dart';

class SnAttachmentConverter extends TypeConverter<SnAttachment, String>
    with JsonTypeConverter2<SnAttachment, String, Map<String, Object?>> {
  const SnAttachmentConverter();

  @override
  SnAttachment fromSql(String fromDb) {
    return fromJson(jsonDecode(fromDb) as Map<String, dynamic>);
  }

  @override
  String toSql(SnAttachment value) {
    return jsonEncode(toJson(value));
  }

  @override
  SnAttachment fromJson(Map<String, Object?> json) {
    return SnAttachment.fromJson(json);
  }

  @override
  Map<String, Object?> toJson(SnAttachment value) {
    return value.toJson();
  }
}

@TableIndex(name: 'idx_attachment_rid', columns: {#rid})
@TableIndex(name: 'idx_attachment_account', columns: {#accountId})
class SnLocalAttachment extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get rid => text().unique()();

  TextColumn get uuid => text().unique()();

  TextColumn get content => text().map(const SnAttachmentConverter())();

  IntColumn get accountId => integer()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  DateTimeColumn get cacheExpiredAt => dateTime()();
}
