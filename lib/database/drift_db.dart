import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:island/database/message.dart';

part 'drift_db.g.dart';

// Define the database
@DriftDatabase(tables: [ChatMessages])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 1;

  // Methods for chat messages
  Future<List<ChatMessage>> getMessagesForRoom(
    int roomId, {
    int offset = 0,
    int limit = 20,
  }) {
    return (select(chatMessages)
          ..where((m) => m.roomId.equals(roomId))
          ..orderBy([(m) => OrderingTerm.desc(m.createdAt)])
          ..limit(limit, offset: offset))
        .get();
  }

  Future<int> saveMessage(ChatMessagesCompanion message) {
    return into(chatMessages).insert(message, mode: InsertMode.insertOrReplace);
  }

  Future<int> updateMessage(ChatMessagesCompanion message) {
    return (update(chatMessages)
      ..where((m) => m.id.equals(message.id.value))).write(message);
  }

  Future<int> updateMessageStatus(String id, MessageStatus status) {
    return (update(chatMessages)..where(
      (m) => m.id.equals(id),
    )).write(ChatMessagesCompanion(status: Value(status)));
  }

  Future<int> deleteMessage(String id) {
    return (delete(chatMessages)..where((m) => m.id.equals(id))).go();
  }

  // Convert between Drift and model objects
  ChatMessagesCompanion messageToCompanion(LocalChatMessage message) {
    return ChatMessagesCompanion(
      id: Value(message.id),
      roomId: Value(message.roomId),
      senderId: Value(message.senderId),
      content: Value(message.toRemoteMessage().content),
      nonce: Value(message.nonce),
      data: Value(jsonEncode(message.data)),
      createdAt: Value(message.createdAt),
      status: Value(message.status),
    );
  }

  LocalChatMessage companionToMessage(ChatMessage dbMessage) {
    final data = jsonDecode(dbMessage.data);
    return LocalChatMessage(
      id: dbMessage.id,
      roomId: dbMessage.roomId,
      senderId: dbMessage.senderId,
      data: data,
      createdAt: dbMessage.createdAt,
      status: dbMessage.status,
      nonce: dbMessage.nonce,
    );
  }
}
