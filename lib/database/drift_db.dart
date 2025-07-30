import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:island/database/message.dart';
import 'package:island/database/draft.dart';
import 'package:island/models/post.dart';

part 'drift_db.g.dart';

// Define the database
@DriftDatabase(tables: [ChatMessages, PostDrafts])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      if (from < 2) {
        // Add isRead column with default value false
        await m.addColumn(chatMessages, chatMessages.isRead);
      }
      if (from < 4) {
        // Drop old draft tables if they exist
        await m.createTable(postDrafts);
      }
    },
  );

  // Methods for chat messages
  Future<List<ChatMessage>> getMessagesForRoom(
    String roomId, {
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
    return into(chatMessages).insert(message, mode: InsertMode.insertOrReplace);
  }

  Future<int> updateMessageStatus(String id, MessageStatus status) {
    return (update(chatMessages)..where(
      (m) => m.id.equals(id),
    )).write(ChatMessagesCompanion(status: Value(status)));
  }

  Future<int> markMessageAsRead(String id) {
    return (update(chatMessages)..where(
      (m) => m.id.equals(id),
    )).write(ChatMessagesCompanion(isRead: const Value(true)));
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
      isRead: Value(message.isRead),
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
      isRead: dbMessage.isRead,
    );
  }

  // Methods for post drafts
  Future<List<SnPost>> getAllPostDrafts() async {
    final drafts = await select(postDrafts).get();
    return drafts
        .map((draft) => SnPost.fromJson(jsonDecode(draft.post)))
        .toList();
  }

  Future<void> addPostDraft(PostDraftsCompanion entry) async {
    await into(postDrafts).insert(entry, mode: InsertMode.replace);
  }

  Future<void> deletePostDraft(String id) async {
    await (delete(postDrafts)..where((tbl) => tbl.id.equals(id))).go();
  }

  Future<void> clearAllPostDrafts() async {
    await delete(postDrafts).go();
  }
}
