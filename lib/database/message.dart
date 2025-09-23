import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:island/models/chat.dart';
import 'package:island/models/file.dart';

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

class ChatMessages extends Table {
  TextColumn get id => text()();
  TextColumn get roomId => text()();
  TextColumn get senderId => text()();
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
  TextColumn get membersMentioned =>
      text()
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
    return SnChatMessage.fromJson(data);
  }

  static LocalChatMessage fromRemoteMessage(
    SnChatMessage message,
    MessageStatus status, {
    String? nonce,
  }) {
    return LocalChatMessage(
      id: message.id,
      roomId: message.chatRoomId,
      senderId: message.senderId,
      data: message.toJson(),
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
