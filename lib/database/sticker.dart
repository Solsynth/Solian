import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:surface/types/attachment.dart';

class SnStickerConverter extends TypeConverter<SnSticker, String>
    with JsonTypeConverter2<SnSticker, String, Map<String, Object?>> {
  const SnStickerConverter();

  @override
  SnSticker fromSql(String fromDb) {
    return fromJson(jsonDecode(fromDb) as Map<String, dynamic>);
  }

  @override
  String toSql(SnSticker value) {
    return jsonEncode(toJson(value));
  }

  @override
  SnSticker fromJson(Map<String, Object?> json) {
    return SnSticker.fromJson(json);
  }

  @override
  Map<String, Object?> toJson(SnSticker value) {
    return value.toJson();
  }
}

class SnLocalSticker extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get alias => text()();

  TextColumn get fullAlias => text()();

  TextColumn get content => text().map(const SnStickerConverter())();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class SnStickerPackConverter extends TypeConverter<SnStickerPack, String>
    with JsonTypeConverter2<SnStickerPack, String, Map<String, Object?>> {
  const SnStickerPackConverter();

  @override
  SnStickerPack fromSql(String fromDb) {
    return fromJson(jsonDecode(fromDb) as Map<String, dynamic>);
  }

  @override
  String toSql(SnStickerPack value) {
    return jsonEncode(toJson(value));
  }

  @override
  SnStickerPack fromJson(Map<String, Object?> json) {
    return SnStickerPack.fromJson(json);
  }

  @override
  Map<String, Object?> toJson(SnStickerPack value) {
    return value.toJson();
  }
}

class SnLocalStickerPack extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get content => text().map(const SnStickerPackConverter())();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
