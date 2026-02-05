import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:island/chat/chat_models/chat.dart';
import 'package:island/drive/drive_models/file.dart';

class MapConverter extends TypeConverter<Map<String, dynamic>, String> {
  const MapConverter();

  @override
  Map<String, dynamic> fromSql(String fromDb) => json.decode(fromDb);

  @override
  String toSql(Map<String, dynamic> value) => json.encode(value);
}

class ListStringConverter extends TypeConverter<List<String>, String> {
  const ListStringConverter();

  @override
  List<String> fromSql(String fromDb) => List<String>.from(json.decode(fromDb));

  @override
  String toSql(List<String> value) => json.encode(value);
}

class ListMapConverter
    extends TypeConverter<List<Map<String, dynamic>>, String> {
  const ListMapConverter();

  @override
  List<Map<String, dynamic>> fromSql(String fromDb) =>
      List<Map<String, dynamic>>.from(json.decode(fromDb));

  @override
  String toSql(List<Map<String, dynamic>> value) => json.encode(value);
}

class Realms extends Table {
  TextColumn get id => text()();
  TextColumn get slug => text()();
  TextColumn get name => text().nullable()();
  TextColumn get description => text().nullable()();
  TextColumn get verifiedAs => text().nullable()();
  DateTimeColumn get verifiedAt => dateTime().nullable()();
  BoolColumn get isCommunity => boolean()();
  BoolColumn get isPublic => boolean()();
  TextColumn get picture => text().map(const MapConverter()).nullable()();
  TextColumn get background => text().map(const MapConverter()).nullable()();
  TextColumn get accountId => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class ChatRooms extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().nullable()();
  TextColumn get description => text().nullable()();
  IntColumn get type => integer()();
  BoolColumn get isPublic =>
      boolean().nullable().withDefault(const Constant(false))();
  BoolColumn get isCommunity =>
      boolean().nullable().withDefault(const Constant(false))();
  TextColumn get picture => text().map(const MapConverter()).nullable()();
  TextColumn get background => text().map(const MapConverter()).nullable()();
  TextColumn get realmId => text().references(Realms, #id).nullable()();
  TextColumn get accountId => text().nullable()();
  BoolColumn get isPinned =>
      boolean().nullable().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class ChatMembers extends Table {
  TextColumn get id => text()();
  TextColumn get chatRoomId => text().references(ChatRooms, #id)();
  TextColumn get accountId => text()();
  TextColumn get account => text().map(const MapConverter())();
  TextColumn get nick => text().nullable()();
  IntColumn get notify => integer()();
  DateTimeColumn get joinedAt => dateTime().nullable()();
  DateTimeColumn get breakUntil => dateTime().nullable()();
  DateTimeColumn get timeoutUntil => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class ChatMessages extends Table {
  TextColumn get id => text()();
  TextColumn get roomId => text().references(ChatRooms, #id)();
  TextColumn get senderId => text().references(ChatMembers, #id)();
  TextColumn get content => text().nullable()();
  TextColumn get nonce => text().nullable()();
  TextColumn get data => text()();
  DateTimeColumn get createdAt => dateTime()();
  IntColumn get status => intEnum<MessageStatus>()();
  BoolColumn get isDeleted =>
      boolean().nullable().withDefault(const Constant(false))();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  TextColumn get type => text().withDefault(const Constant('text'))();
  TextColumn get meta =>
      text().map(const MapConverter()).withDefault(const Constant('{}'))();
  TextColumn get membersMentioned => text()
      .map(const ListStringConverter())
      .withDefault(const Constant('[]'))();
  DateTimeColumn get editedAt => dateTime().nullable()();
  TextColumn get attachments =>
      text().map(const ListMapConverter()).withDefault(const Constant('[]'))();
  TextColumn get reactions =>
      text().map(const ListMapConverter()).withDefault(const Constant('[]'))();
  TextColumn get repliedMessageId => text().nullable()();
  TextColumn get forwardedMessageId => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class LocalChatMessage {
  final String id;
  final String roomId;
  final String senderId;
  final SnChatMember? sender;
  final Map<String, dynamic> data;
  final DateTime createdAt;
  MessageStatus status;
  final String? nonce;
  final String? content;
  final bool? isDeleted;
  final DateTime? updatedAt;
  final DateTime? deletedAt;
  final String type;
  final Map<String, dynamic> meta;
  final List<String> membersMentioned;
  final DateTime? editedAt;
  final List<Map<String, dynamic>> attachments;
  final List<Map<String, dynamic>> reactions;
  final String? repliedMessageId;
  final String? forwardedMessageId;
  List<UniversalFile>? localAttachments;

  LocalChatMessage({
    required this.id,
    required this.roomId,
    required this.senderId,
    required this.sender,
    required this.data,
    required this.createdAt,
    required this.nonce,
    required this.status,
    this.content,
    this.isDeleted,
    this.updatedAt,
    this.deletedAt,
    required this.type,
    required this.meta,
    required this.membersMentioned,
    this.editedAt,
    required this.attachments,
    required this.reactions,
    this.repliedMessageId,
    this.forwardedMessageId,
    this.localAttachments,
  });

  SnChatMessage toRemoteMessage() {
    if (sender == null) {
      throw Exception('Cannot create remote message without sender');
    }
    final msgData = Map<String, dynamic>.from(data);
    msgData['sender'] = sender!.toJson();
    return SnChatMessage.fromJson(msgData);
  }

  static LocalChatMessage fromRemoteMessage(
    SnChatMessage message,
    MessageStatus status, {
    String? nonce,
  }) {
    final jsonData = message.toJson();
    jsonData.remove('sender');
    // Ensure proper defaults for collections to prevent type cast errors
    if (jsonData['meta'] == null) jsonData['meta'] = <String, dynamic>{};
    if (jsonData['members_mentioned'] == null) {
      jsonData['members_mentioned'] = <String>[];
    }
    if (jsonData['attachments'] == null) {
      jsonData['attachments'] = <Map<String, dynamic>>[];
    }
    if (jsonData['reactions'] == null) {
      jsonData['reactions'] = <Map<String, dynamic>>[];
    }
    final msgData = Map<String, dynamic>.from(jsonData);
    return LocalChatMessage(
      id: message.id,
      roomId: message.chatRoomId,
      senderId: message.senderId,
      sender: message.sender,
      data: msgData,
      createdAt: message.createdAt,
      status: status,
      nonce: nonce ?? message.nonce,
      content: message.content,
      isDeleted: false,
      updatedAt: message.updatedAt,
      deletedAt: null,
      type: message.type,
      meta: message.meta,
      membersMentioned: message.membersMentioned,
      editedAt: message.editedAt,
      attachments: message.attachments.map((e) => e.toJson()).toList(),
      reactions: message.reactions.map((e) => e.toJson()).toList(),
      repliedMessageId: message.repliedMessageId,
      forwardedMessageId: message.forwardedMessageId,
    );
  }
}

enum MessageStatus { pending, sent, failed }
