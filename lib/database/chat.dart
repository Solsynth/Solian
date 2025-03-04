import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:surface/types/chat.dart';

class SnChannelConverter extends TypeConverter<SnChannel, String>
    with JsonTypeConverter2<SnChannel, String, Map<String, Object?>> {
  const SnChannelConverter();

  @override
  SnChannel fromSql(String fromDb) {
    return fromJson(jsonDecode(fromDb) as Map<String, dynamic>);
  }

  @override
  String toSql(SnChannel value) {
    return jsonEncode(toJson(value));
  }

  @override
  SnChannel fromJson(Map<String, Object?> json) {
    return SnChannel.fromJson(json);
  }

  @override
  Map<String, Object?> toJson(SnChannel value) {
    return value.toJson();
  }
}

@TableIndex(name: 'idx_channel_alias', columns: {#alias})
class SnLocalChatChannel extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get alias => text()();

  TextColumn get content => text().map(const SnChannelConverter())();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class SnMessageConverter extends TypeConverter<SnChatMessage, String>
    with JsonTypeConverter2<SnChatMessage, String, Map<String, Object?>> {
  const SnMessageConverter();

  @override
  SnChatMessage fromSql(String fromDb) {
    return fromJson(jsonDecode(fromDb) as Map<String, dynamic>);
  }

  @override
  String toSql(SnChatMessage value) {
    return jsonEncode(toJson(value));
  }

  @override
  SnChatMessage fromJson(Map<String, Object?> json) {
    return SnChatMessage.fromJson(json);
  }

  @override
  Map<String, Object?> toJson(SnChatMessage value) {
    return value.toJson();
  }
}

@TableIndex(name: 'idx_chat_channel', columns: {#channelId})
class SnLocalChatMessage extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get channelId => integer()();

  IntColumn get senderId => integer().nullable()();

  TextColumn get content => text().map(const SnMessageConverter())();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class SnChannelMemberConverter extends TypeConverter<SnChannelMember, String>
    with JsonTypeConverter2<SnChannelMember, String, Map<String, Object?>> {
  const SnChannelMemberConverter();

  @override
  SnChannelMember fromSql(String fromDb) {
    return fromJson(jsonDecode(fromDb) as Map<String, dynamic>);
  }

  @override
  String toSql(SnChannelMember value) {
    return jsonEncode(toJson(value));
  }

  @override
  SnChannelMember fromJson(Map<String, Object?> json) {
    return SnChannelMember.fromJson(json);
  }

  @override
  Map<String, Object?> toJson(SnChannelMember value) {
    return value.toJson();
  }
}

class SnLocalChannelMember extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get channelId => integer()();

  IntColumn get accountId => integer()();

  TextColumn get content => text().map(SnChannelMemberConverter())();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  DateTimeColumn get cacheExpiredAt => dateTime()();
}
