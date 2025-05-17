import 'package:drift/drift.dart';
import 'package:island/models/chat.dart';
import 'package:island/models/file.dart';

class ChatMessages extends Table {
  TextColumn get id => text()();
  TextColumn get roomId => text()();
  TextColumn get senderId => text()();
  TextColumn get content => text().nullable()();
  TextColumn get nonce => text().nullable()();
  TextColumn get data => text()();
  DateTimeColumn get createdAt => dateTime()();
  IntColumn get status => intEnum<MessageStatus>()();

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
  List<UniversalFile>? localAttachments;

  LocalChatMessage({
    required this.id,
    required this.roomId,
    required this.senderId,
    required this.data,
    required this.createdAt,
    required this.nonce,
    required this.status,
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
    );
  }
}

enum MessageStatus { pending, sent, failed }
