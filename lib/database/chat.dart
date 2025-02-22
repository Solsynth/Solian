import 'package:drift/drift.dart';
import 'package:surface/types/chat.dart';

class SnLocalChatChannel extends Table {
  IntColumn get id => integer().autoIncrement()();

  BlobColumn get content => blob().map(TypeConverter.jsonb(
    fromJson: (json) => SnChannel.fromJson(json as Map<String, Object?>),
    toJson: (pref) => pref.toJson(),
  ))();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class SnLocalChatMessage extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get channelId => integer()();

  BlobColumn get content => blob().map( TypeConverter.jsonb(
    fromJson: (json) => SnChatMessage.fromJson(json as Map<String, Object?>),
    toJson: (pref) => pref.toJson(),
  ))();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}