import 'dart:async';
import 'dart:convert';

import 'package:island/data/message.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

class ChatMessage {
  ChatMessage({
    required this.id,
    required this.roomId,
    required this.senderId,
    required this.content,
    required this.nonce,
    required this.data,
    required this.createdAt,
    required this.status,
    required this.isDeleted,
    required this.updatedAt,
    required this.deletedAt,
    required this.type,
    required this.meta,
    required this.membersMentioned,
    required this.editedAt,
    required this.attachments,
    required this.reactions,
    required this.repliedMessageId,
    required this.forwardedMessageId,
  });

  final String id;
  final String roomId;
  final String senderId;
  final String? content;
  final String? nonce;
  final String data;
  final DateTime createdAt;
  final MessageStatus status;
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
}

class ChatRoom {
  ChatRoom({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.isPublic,
    required this.isCommunity,
    required this.picture,
    required this.background,
    required this.realmId,
    required this.accountId,
    required this.isPinned,
    required this.createdAt,
    required this.updatedAt,
    required this.deletedAt,
  });

  final String id;
  final String? name;
  final String? description;
  final int type;
  final bool? isPublic;
  final bool? isCommunity;
  final Map<String, dynamic>? picture;
  final Map<String, dynamic>? background;
  final String? realmId;
  final String? accountId;
  final bool? isPinned;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
}

class ChatMember {
  ChatMember({
    required this.id,
    required this.chatRoomId,
    required this.accountId,
    required this.account,
    required this.nick,
    required this.notify,
    required this.joinedAt,
    required this.breakUntil,
    required this.timeoutUntil,
    required this.createdAt,
    required this.updatedAt,
    required this.deletedAt,
  });

  final String id;
  final String chatRoomId;
  final String accountId;
  final Map<String, dynamic> account;
  final String? nick;
  final int notify;
  final DateTime? joinedAt;
  final DateTime? breakUntil;
  final DateTime? timeoutUntil;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
}

class Realm {
  Realm({
    required this.id,
    required this.slug,
    required this.name,
    required this.description,
    required this.verifiedAs,
    required this.verifiedAt,
    required this.isCommunity,
    required this.isPublic,
    required this.picture,
    required this.background,
    required this.accountId,
    required this.createdAt,
    required this.updatedAt,
    required this.deletedAt,
  });

  final String id;
  final String slug;
  final String? name;
  final String? description;
  final String? verifiedAs;
  final DateTime? verifiedAt;
  final bool isCommunity;
  final bool isPublic;
  final Map<String, dynamic>? picture;
  final Map<String, dynamic>? background;
  final String? accountId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
}

class PostDraft {
  PostDraft({
    required this.id,
    required this.title,
    required this.description,
    required this.content,
    required this.visibility,
    required this.type,
    required this.lastModified,
    required this.postData,
  });

  final String id;
  final String? title;
  final String? description;
  final String? content;
  final int visibility;
  final int type;
  final DateTime lastModified;
  final String postData;
}

class AppDatabase {
  AppDatabase.native(Future<String?> _);
  AppDatabase.web();
  final Map<String, SnPost> _webDraftStore = {};

  Future<void> close() async {}

  Future<void> reset() async {
    _webDraftStore.clear();
  }

  Future<T> transaction<T>(Future<T> Function() action) async => action();

  Future<int> getLatestMessageTimestamp() async => 0;

  Future<int> countMessagesNewerThan(String roomId, DateTime createdAt) async => 0;

  Future<List<ChatMessage>> getMessagesForRoom(
    String roomId, {
    int offset = 0,
    int limit = 20,
  }) async => const [];

  Future<ChatMessage?> getMessageById(String id) async => null;

  Future<int> saveMessage(ChatMessage message) async => 1;

  Future<int> updateMessage(ChatMessage message) async => 1;

  Future<int> updateMessageStatus(String id, MessageStatus status) async => 1;

  Future<int> deleteMessage(String id) async => 1;

  Future<int> getTotalMessagesForRoom(String roomId) async => 0;

  Future<List<LocalChatMessage>> searchMessages(
    String roomId,
    String query, {
    bool? withAttachments,
    Future<SnAccount?> Function(String accountId)? fetchAccount,
  }) async => const [];

  ChatMessage messageToCompanion(LocalChatMessage message) {
    final remote = message.toRemoteMessage();
    return ChatMessage(
      id: message.id,
      roomId: message.roomId,
      senderId: message.senderId,
      content: remote.content,
      nonce: message.nonce,
      data: jsonEncode(message.data),
      createdAt: message.createdAt,
      status: message.status,
      isDeleted: message.isDeleted ?? false,
      updatedAt: remote.updatedAt,
      deletedAt: remote.deletedAt,
      type: remote.type,
      meta: remote.meta,
      membersMentioned: remote.membersMentioned,
      editedAt: remote.editedAt,
      attachments: remote.attachments.map((e) => e.toJson()).toList(),
      reactions: remote.reactions.map((e) => e.toJson()).toList(),
      repliedMessageId: remote.repliedMessageId,
      forwardedMessageId: remote.forwardedMessageId,
    );
  }

  Future<LocalChatMessage> companionToMessage(
    ChatMessage dbMessage, {
    Future<SnAccount?> Function(String accountId)? fetchAccount,
  }) async {
    final data = jsonDecode(dbMessage.data) as Map<String, dynamic>;
    final sender = SnChatMember(
      id: 'unknown',
      chatRoomId: dbMessage.roomId,
      accountId: dbMessage.senderId,
      account: SnAccount(
        id: 'unknown',
        name: 'unknown',
        nick: dbMessage.senderId,
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
      nick: dbMessage.senderId,
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

  Future<void> saveChatRooms(
    List<SnChatRoom> rooms, {
    bool override = false,
  }) async {}

  Future<List<SnPost>> getAllPostDrafts() async {
    final drafts = _webDraftStore.values.toList()
      ..sort(
        (a, b) =>
            (b.updatedAt ?? DateTime(0)).compareTo(a.updatedAt ?? DateTime(0)),
      );
    return drafts;
  }

  Future<List<PostDraft>> getAllPostDraftRecords() async {
    return _webDraftStore.values
        .map(
          (post) => PostDraft(
            id: post.id,
            title: post.title,
            description: post.description,
            content: post.content,
            visibility: post.visibility,
            type: post.type,
            lastModified: post.updatedAt ?? DateTime.now(),
            postData: jsonEncode(post.toJson()),
          ),
        )
        .toList();
  }

  Future<List<PostDraft>> searchPostDrafts(String query) async {
    final rows = await getAllPostDraftRecords();
    if (query.isEmpty) return rows;
    final lower = query.toLowerCase();
    return rows.where((draft) {
      return (draft.title ?? '').toLowerCase().contains(lower) ||
          (draft.description ?? '').toLowerCase().contains(lower) ||
          (draft.content ?? '').toLowerCase().contains(lower);
    }).toList();
  }

  Future<void> addPostDraftFromPost(SnPost post) async {
    final updatedPost = post.copyWith(updatedAt: DateTime.now());
    _webDraftStore[updatedPost.id] = updatedPost;
  }

  Future<void> deletePostDraft(String id) async {
    _webDraftStore.remove(id);
  }

  Future<void> clearAllPostDrafts() async {
    _webDraftStore.clear();
  }

  Future<PostDraft?> getPostDraftById(String id) async {
    final draft = _webDraftStore[id];
    if (draft == null) return null;
    return PostDraft(
      id: draft.id,
      title: draft.title,
      description: draft.description,
      content: draft.content,
      visibility: draft.visibility,
      type: draft.type,
      lastModified: draft.updatedAt ?? DateTime.now(),
      postData: jsonEncode(draft.toJson()),
    );
  }

  Future<void> saveMember(SnChatMember member) async {}

  Future<int> saveMessageWithSender(LocalChatMessage message) async => 1;

  Future<void> toggleChatRoomPinned(String roomId) async {}

  Future<List<ChatRoom>> getAllChatRooms() async => const [];

  Future<ChatRoom?> getChatRoomById(String id) async => null;

  Future<List<ChatMember>> getMembersByRoomId(String roomId) async => const [];

  Future<ChatMember?> getMemberByRoomAndAccount(
    String roomId,
    String accountId,
  ) async => null;

  Future<ChatMember?> getMemberById(String id) async => null;

  Future<List<Realm>> getAllRealms() async => const [];

  Future<Realm?> getRealmById(String id) async => null;
}
