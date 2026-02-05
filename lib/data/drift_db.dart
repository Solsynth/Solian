import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:island/data/draft.dart';
import 'package:island/data/message.dart';
import 'package:island/accounts/accounts_models/account.dart';
import 'package:island/chat/chat_models/chat.dart';
import 'package:island/posts/posts_models/post.dart';
import 'package:island/realms/realms_models/realm.dart';

part 'drift_db.g.dart';

// Define the database
@DriftDatabase(
  tables: [Realms, ChatRooms, ChatMembers, ChatMessages, PostDrafts],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 12;

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
      if (from < 8) {
        // Add new tables for separate sender and room data
        await m.createTable(chatRooms);
        await m.createTable(chatMembers);
      }
      if (from < 9) {
        // Remove unused columns from chat_members
        await customStatement('ALTER TABLE chat_members DROP COLUMN role');
        await customStatement('ALTER TABLE chat_members DROP COLUMN is_bot');
        await customStatement('ALTER TABLE chat_members DROP COLUMN status');
        await customStatement(
          'ALTER TABLE chat_members DROP COLUMN last_typed',
        );
      }
      if (from < 10) {
        // Add realms table and update chat_rooms foreign key
        await m.createTable(realms);
        // The realmId column in chat_rooms already exists, just need to ensure the foreign key constraint
      }
      if (from < 11) {
        // Add isPinned column to chat_rooms table
        await customStatement(
          'ALTER TABLE chat_rooms ADD COLUMN is_pinned INTEGER DEFAULT 0',
        );
      }
      if (from < 12) {
        // Add new columns to realms table
        await customStatement(
          'ALTER TABLE realms ADD COLUMN slug TEXT NOT NULL DEFAULT \'\'',
        );
        await customStatement(
          'ALTER TABLE realms ADD COLUMN verified_as TEXT NULL',
        );
        await customStatement(
          'ALTER TABLE realms ADD COLUMN verified_at DATETIME NULL',
        );
        await customStatement(
          'ALTER TABLE realms ADD COLUMN is_community INTEGER NOT NULL DEFAULT 0',
        );
        await customStatement(
          'ALTER TABLE realms ADD COLUMN is_public INTEGER NOT NULL DEFAULT 0',
        );
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
      final oldDrafts = await customSelect(
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
    return (update(chatMessages)..where((m) => m.id.equals(id))).write(
      ChatMessagesCompanion(status: Value(status)),
    );
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
    Future<SnAccount?> Function(String accountId)? fetchAccount,
  }) async {
    var selectStatement = select(chatMessages)
      ..where((m) => m.roomId.equals(roomId));

    if (query.isNotEmpty) {
      final searchTerm = '%$query%';
      selectStatement = selectStatement
        ..where(
          (m) =>
              m.content.like(searchTerm) |
              m.meta.like(searchTerm) |
              m.attachments.like(searchTerm) |
              m.type.like(searchTerm),
        );
    }

    if (withAttachments == true) {
      selectStatement = selectStatement
        ..where((m) => m.attachments.equals('[]').not());
    }

    final messages =
        await (selectStatement
              ..orderBy([(m) => OrderingTerm.desc(m.createdAt)]))
            .get();
    final messageFutures = messages
        .map((msg) => companionToMessage(msg, fetchAccount: fetchAccount))
        .toList();
    return await Future.wait(messageFutures);
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

  Future<LocalChatMessage> companionToMessage(
    ChatMessage dbMessage, {
    Future<SnAccount?> Function(String accountId)? fetchAccount,
  }) async {
    final data = jsonDecode(dbMessage.data);
    SnChatMember? sender;
    try {
      final senderRow = await (select(
        chatMembers,
      )..where((m) => m.id.equals(dbMessage.senderId))).getSingle();
      SnAccount senderAccount;
      senderAccount = SnAccount.fromJson(senderRow.account);

      sender = SnChatMember(
        id: senderRow.id,
        chatRoomId: senderRow.chatRoomId,
        accountId: senderRow.accountId,
        account: senderAccount,
        nick: senderRow.nick,
        notify: senderRow.notify,
        joinedAt: senderRow.joinedAt,
        breakUntil: senderRow.breakUntil,
        timeoutUntil: senderRow.timeoutUntil,
        status: null,
        createdAt: senderRow.createdAt,
        updatedAt: senderRow.updatedAt,
        deletedAt: senderRow.deletedAt,
        chatRoom: null,
      );
    } catch (err) {
      // Fallback to dummy sender with senderId as display name
      sender = SnChatMember(
        id: 'unknown',
        chatRoomId: dbMessage.roomId,
        accountId: dbMessage.senderId,
        account: SnAccount(
          id: 'unknown',
          name: 'unknown',
          nick: dbMessage.senderId, // Show the ID instead of Unknown
          activatedAt: null,
          profile: SnAccountProfile(
            picture: null,
            id: 'unknown',
            experience: 0,
            level: 1,
            levelingProgress: 0.0,
            background: null,
            verification: null,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            deletedAt: null,
          ),
          language: '',
          isSuperuser: false,
          automatedId: null,
          perkSubscription: null,
          deletedAt: null,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        nick: dbMessage.senderId, // Show the senderId as fallback
        notify: 0,
        joinedAt: null,
        breakUntil: null,
        timeoutUntil: null,
        status: null,
        lastTyped: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        deletedAt: null,
        chatRoom: null,
      );
    }
    return LocalChatMessage(
      id: dbMessage.id,
      roomId: dbMessage.roomId,
      senderId: dbMessage.senderId,
      sender: sender,
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

  ChatRoomsCompanion companionFromRoom(SnChatRoom room) {
    return ChatRoomsCompanion(
      id: Value(room.id),
      name: Value(room.name),
      description: Value(room.description),
      type: Value(room.type),
      isPublic: Value(room.isPublic),
      isCommunity: Value(room.isCommunity),
      picture: Value(room.picture?.toJson()),
      background: Value(room.background?.toJson()),
      realmId: Value(room.realmId),
      accountId: Value(room.accountId),
      createdAt: Value(room.createdAt),
      updatedAt: Value(room.updatedAt),
      deletedAt: Value(room.deletedAt),
    );
  }

  ChatMembersCompanion companionFromMember(SnChatMember member) {
    return ChatMembersCompanion(
      id: Value(member.id),
      chatRoomId: Value(member.chatRoomId),
      accountId: Value(member.accountId),
      account: Value(member.account.toJson()),
      nick: Value(member.nick),
      notify: Value(member.notify),
      joinedAt: Value(member.joinedAt),
      breakUntil: Value(member.breakUntil),
      timeoutUntil: Value(member.timeoutUntil),
      createdAt: Value(member.createdAt),
      updatedAt: Value(member.updatedAt),
      deletedAt: Value(member.deletedAt),
    );
  }

  RealmsCompanion companionFromRealm(SnRealm realm) {
    return RealmsCompanion(
      id: Value(realm.id),
      slug: Value(realm.slug),
      name: Value(realm.name),
      description: Value(realm.description),
      verifiedAs: Value(realm.verifiedAs),
      verifiedAt: Value(realm.verifiedAt),
      isCommunity: Value(realm.isCommunity),
      isPublic: Value(realm.isPublic),
      picture: Value(realm.picture?.toJson()),
      background: Value(realm.background?.toJson()),
      accountId: Value(realm.accountId),
      createdAt: Value(realm.createdAt),
      updatedAt: Value(realm.updatedAt),
      deletedAt: Value(realm.deletedAt),
    );
  }

  Future<void> saveChatRooms(
    List<SnChatRoom> rooms, {
    bool override = false,
  }) async {
    await transaction(() async {
      if (override) {
        // 1. Identify rooms to remove
        final remoteRoomIds = rooms.map((r) => r.id).toSet();
        final currentRooms = await select(chatRooms).get();
        final currentRoomIds = currentRooms.map((r) => r.id).toSet();
        final idsToRemove = currentRoomIds.difference(remoteRoomIds);

        if (idsToRemove.isNotEmpty) {
          final idsList = idsToRemove.toList();
          // Remove messages
          await (delete(
            chatMessages,
          )..where((t) => t.roomId.isIn(idsList))).go();
          // Remove members
          await (delete(
            chatMembers,
          )..where((t) => t.chatRoomId.isIn(idsList))).go();
          // Remove rooms
          await (delete(chatRooms)..where((t) => t.id.isIn(idsList))).go();
        }
      }

      // 2. Upsert realms first
      final realmsToSave = rooms
          .where((room) => room.realm != null)
          .map((room) => room.realm!)
          .toSet()
          .toList();
      await batch((batch) {
        for (final realm in realmsToSave) {
          batch.insert(
            realms,
            companionFromRealm(realm),
            mode: InsertMode.insertOrReplace,
          );
        }
      });

      // 3. Upsert remote rooms
      await batch((batch) async {
        for (final room in rooms) {
          // Preserve local isPinned status
          final currentRoom = await (select(
            chatRooms,
          )..where((r) => r.id.equals(room.id))).getSingleOrNull();
          final isPinned = currentRoom?.isPinned ?? false;

          batch.insert(
            chatRooms,
            companionFromRoom(room).copyWith(isPinned: Value(isPinned)),
            mode: InsertMode.insertOrReplace,
          );
          for (final member in room.members ?? []) {
            batch.insert(
              chatMembers,
              companionFromMember(member),
              mode: InsertMode.insertOrReplace,
            );
          }
        }
      });
    });
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
    return await (select(
      postDrafts,
    )..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
  }

  Future<void> saveMember(SnChatMember member) async {
    await into(
      chatMembers,
    ).insert(companionFromMember(member), mode: InsertMode.insertOrReplace);
  }

  Future<int> saveMessageWithSender(LocalChatMessage message) async {
    // First save the sender if it exists
    if (message.sender != null) {
      await saveMember(message.sender!);
    }
    // Then save the message
    return await saveMessage(messageToCompanion(message));
  }

  Future<void> toggleChatRoomPinned(String roomId) async {
    final room = await (select(
      chatRooms,
    )..where((r) => r.id.equals(roomId))).getSingleOrNull();
    if (room != null) {
      final newPinnedStatus = !(room.isPinned ?? false);
      await (update(chatRooms)..where((r) => r.id.equals(roomId))).write(
        ChatRoomsCompanion(isPinned: Value(newPinnedStatus)),
      );
    }
  }
}
