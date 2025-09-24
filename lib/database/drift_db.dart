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
  int get schemaVersion => 7;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      if (from < 2) {
        // Add isDeleted column with default value false
        await m.addColumn(chatMessages, chatMessages.isDeleted);
      }
      if (from < 4) {
        // Drop old draft tables if they exist
        await m.createTable(postDrafts);
      }
      if (from < 6) {
        // Migrate from old schema to new schema with separate searchable fields
        await _migrateToVersion6(m);
      }
      if (from < 7) {
        // Add new columns from SnChatMessage, ignore if they already exist
        final columnsToAdd = [
          chatMessages.updatedAt,
          chatMessages.deletedAt,
          chatMessages.type,
          chatMessages.meta,
          chatMessages.membersMentioned,
          chatMessages.editedAt,
          chatMessages.attachments,
          chatMessages.reactions,
          chatMessages.repliedMessageId,
          chatMessages.forwardedMessageId,
        ];

        for (final column in columnsToAdd) {
          try {
            await m.addColumn(chatMessages, column);
          } catch (e) {
            // Column already exists, skip
          }
        }
      }
    },
  );

  Future<void> _migrateToVersion6(Migrator m) async {
    // Rename existing table to old if it exists
    try {
      await customStatement(
        'ALTER TABLE post_drafts RENAME TO post_drafts_old',
      );
    } catch (e) {
      // Table might not exist
    }

    // Drop the table
    await customStatement('DROP TABLE IF EXISTS post_drafts');

    // Create new table
    await m.createTable(postDrafts);

    // Migrate existing data if any
    try {
      final oldDrafts =
          await customSelect(
            'SELECT id, post, lastModified FROM post_drafts_old',
            readsFrom: {postDrafts},
          ).get();

      for (final row in oldDrafts) {
        final postJson = row.read<String>('post');
        final id = row.read<String>('id');
        final lastModified = row.read<DateTime>('lastModified');

        if (postJson.isNotEmpty) {
          final post = SnPost.fromJson(jsonDecode(postJson));
          await into(postDrafts).insert(
            PostDraftsCompanion(
              id: Value(id),
              title: Value(post.title),
              description: Value(post.description),
              content: Value(post.content),
              visibility: Value(post.visibility),
              type: Value(post.type),
              lastModified: Value(lastModified),
              postData: Value(postJson),
            ),
          );
        }
      }

      // Drop old table
      await customStatement('DROP TABLE IF EXISTS post_drafts_old');
    } catch (e) {
      // If migration fails, just recreate the table
      await m.createTable(postDrafts);
    }
  }

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

  Future<int> deleteMessage(String id) {
    return (delete(chatMessages)..where((m) => m.id.equals(id))).go();
  }

  Future<int> getTotalMessagesForRoom(String roomId) {
    return (select(
      chatMessages,
    )..where((m) => m.roomId.equals(roomId))).get().then((list) => list.length);
  }

  Future<List<LocalChatMessage>> searchMessages(
    String roomId,
    String query, {
    bool? withAttachments,
  }) async {
    var selectStatement = select(chatMessages)
      ..where((m) => m.roomId.equals(roomId));

    if (query.isNotEmpty) {
      final searchTerm = '%$query%';
      selectStatement =
          selectStatement..where(
            (m) =>
                m.content.like(searchTerm) |
                m.meta.like(searchTerm) |
                m.attachments.like(searchTerm) |
                m.type.like(searchTerm),
          );
    }

    if (withAttachments == true) {
      selectStatement =
          selectStatement..where((m) => m.attachments.equals('[]').not());
    }

    final messages =
        await (selectStatement
              ..orderBy([(m) => OrderingTerm.desc(m.createdAt)]))
            .get();
    return messages.map((msg) => companionToMessage(msg)).toList();
  }

  // Convert between Drift and model objects
  ChatMessagesCompanion messageToCompanion(LocalChatMessage message) {
    final remote = message.toRemoteMessage();
    return ChatMessagesCompanion(
      id: Value(message.id),
      roomId: Value(message.roomId),
      senderId: Value(message.senderId),
      content: Value(remote.content),
      nonce: Value(message.nonce),
      data: Value(jsonEncode(message.data)),
      createdAt: Value(message.createdAt),
      status: Value(message.status),
      updatedAt: Value(remote.updatedAt),
      deletedAt: Value(remote.deletedAt),
      type: Value(remote.type),
      meta: Value(remote.meta),
      membersMentioned: Value(remote.membersMentioned),
      editedAt: Value(remote.editedAt),
      attachments: Value(remote.attachments.map((e) => e.toJson()).toList()),
      reactions: Value(remote.reactions.map((e) => e.toJson()).toList()),
      repliedMessageId: Value(remote.repliedMessageId),
      forwardedMessageId: Value(remote.forwardedMessageId),
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
      content: dbMessage.content,
      isDeleted: dbMessage.isDeleted,
      updatedAt: dbMessage.updatedAt,
      deletedAt: dbMessage.deletedAt,
      type: dbMessage.type,
      meta: dbMessage.meta,
      membersMentioned: dbMessage.membersMentioned,
      editedAt: dbMessage.editedAt,
      attachments: dbMessage.attachments,
      reactions: dbMessage.reactions,
      repliedMessageId: dbMessage.repliedMessageId,
      forwardedMessageId: dbMessage.forwardedMessageId,
    );
  }

  // Methods for post drafts
  Future<List<SnPost>> getAllPostDrafts() async {
    final drafts = await select(postDrafts).get();
    return drafts
        .map((draft) => SnPost.fromJson(jsonDecode(draft.postData)))
        .toList();
  }

  Future<List<PostDraft>> getAllPostDraftRecords() async {
    return await select(postDrafts).get();
  }

  Future<List<PostDraft>> searchPostDrafts(String query) async {
    if (query.isEmpty) {
      return await select(postDrafts).get();
    }

    final searchTerm = '%${query.toLowerCase()}%';
    return await (select(postDrafts)
          ..where(
            (draft) =>
                draft.title.like(searchTerm) |
                draft.description.like(searchTerm) |
                draft.content.like(searchTerm),
          )
          ..orderBy([(draft) => OrderingTerm.desc(draft.lastModified)]))
        .get();
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

  Future<PostDraft?> getPostDraftById(String id) async {
    return await (select(postDrafts)
      ..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
  }
}
