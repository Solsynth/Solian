import 'dart:convert';

import 'package:solar_network_sdk/solar_network_sdk.dart';

class LocalChatMessage {
  final String id;
  final String roomId;
  final String senderId;
  final SnChatMember? sender;
  final Map<String, dynamic> data;
  final DateTime createdAt;
  MessageStatus status;
  final String? clientMessageId;
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
    required this.clientMessageId,
    this.nonce,
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

  /// Number of direct replies the server attributed to this message as a
  /// thread root (carried in [data] as `thread_replies_count`).
  int get threadRepliesCount => _intValue(data['thread_replies_count']);

  /// Returns a copy with a replaced [data] map and/or [repliedMessageId].
  /// The original instance is never mutated.
  LocalChatMessage copyWith({
    Map<String, dynamic>? data,
    String? repliedMessageId,
    bool clearRepliedMessageId = false,
  }) {
    return LocalChatMessage(
      id: id,
      roomId: roomId,
      senderId: senderId,
      sender: sender,
      data: data ?? this.data,
      createdAt: createdAt,
      clientMessageId: clientMessageId,
      nonce: nonce,
      status: status,
      content: content,
      isDeleted: isDeleted,
      updatedAt: updatedAt,
      deletedAt: deletedAt,
      type: type,
      meta: meta,
      membersMentioned: membersMentioned,
      editedAt: editedAt,
      attachments: attachments,
      reactions: reactions,
      repliedMessageId: clearRepliedMessageId
          ? null
          : (repliedMessageId ?? this.repliedMessageId),
      forwardedMessageId: forwardedMessageId,
      localAttachments: localAttachments,
    );
  }

  SnChatMessage toRemoteMessage() {
    return SnChatMessage(
      id: id,
      chatRoomId: roomId,
      senderId: senderId,
      sender: sender ?? _fallbackSender(senderId, roomId),
      type: type,
      content: content,
      clientMessageId: clientMessageId,
      nonce: nonce,
      meta: meta,
      membersMentioned: membersMentioned,
      attachments: attachments
          .map((e) => SnCloudFileReference.fromJson(e))
          .toList(),
      reactions: reactions.map((e) => SnChatReaction.fromJson(e)).toList(),
      reactionsCount: _intMap(data['reactions_count']),
      reactionsMade: _boolMap(data['reactions_made']),
      isThreadRoot: data['is_thread_root'] == true,
      threadRepliesCount: _intValue(data['thread_replies_count']),
      repliedMessageId: repliedMessageId,
      forwardedMessageId: forwardedMessageId,
      createdAt: createdAt,
      updatedAt: updatedAt ?? createdAt,
      deletedAt: deletedAt,
      editedAt: editedAt,
    );
  }

  static LocalChatMessage fromRemoteMessage(
    SnChatMessage message,
    MessageStatus status, {
    String? clientMessageId,
    String? nonce,
  }) {
    final jsonData = message.toJson();
    jsonData.remove('sender');
    final reactionsCount = jsonData.remove('reactions_count');
    final reactionsMade = jsonData.remove('reactions_made');
    final isThreadRoot = jsonData.remove('is_thread_root');
    final threadRepliesCount = jsonData.remove('thread_replies_count');
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
    // Copy reactions_count, reactions_made and thread counters from
    // SnChatMessage to data for easy access
    final msgData = <String, dynamic>{};
    if (reactionsCount is Map && reactionsCount.isNotEmpty) {
      msgData['reactions_count'] = reactionsCount;
    }
    if (reactionsMade is Map && reactionsMade.isNotEmpty) {
      msgData['reactions_made'] = reactionsMade;
    }
    if (isThreadRoot != null) {
      msgData['is_thread_root'] = isThreadRoot == true;
    }
    if (threadRepliesCount is num) {
      msgData['thread_replies_count'] = threadRepliesCount.toInt();
    }
    return LocalChatMessage(
      id: message.id,
      roomId: message.chatRoomId,
      senderId: message.senderId,
      sender: message.sender,
      data: msgData,
      createdAt: message.createdAt,
      status: status,
      clientMessageId: clientMessageId ?? message.clientMessageId,
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

  String toDataJson() {
    final stored = Map<String, dynamic>.from(data);
    for (final key in _structuralDataKeys) {
      stored.remove(key);
    }
    return jsonEncode(stored);
  }

  static const Set<String> _structuralDataKeys = {
    'id',
    'chat_room_id',
    'sender_id',
    'sender',
    'type',
    'content',
    'client_message_id',
    'nonce',
    'meta',
    'members_mentioned',
    'edited_at',
    'attachments',
    'reactions',
    'replied_message_id',
    'forwarded_message_id',
    'created_at',
    'updated_at',
    'deleted_at',
  };

  static Map<String, int> _intMap(dynamic raw) {
    if (raw is! Map) return const {};
    return raw.map(
      (key, value) => MapEntry(
        key.toString(),
        value is int ? value : int.tryParse(value.toString()) ?? 0,
      ),
    );
  }

  static int _intValue(dynamic raw) {
    if (raw is int) return raw;
    return int.tryParse(raw?.toString() ?? '') ?? 0;
  }

  static Map<String, bool> _boolMap(dynamic raw) {
    if (raw is! Map) return const {};
    return raw.map((key, value) => MapEntry(key.toString(), value == true));
  }

  static SnChatMember _fallbackSender(String senderId, String roomId) {
    final now = DateTime.fromMillisecondsSinceEpoch(0);
    return SnChatMember(
      id: senderId,
      chatRoomId: roomId,
      chatRoom: null,
      accountId: senderId,
      createdAt: now,
      updatedAt: now,
      deletedAt: null,
      account: SnAccount(
        id: senderId,
        name: senderId,
        nick: senderId == 'system' ? 'System' : senderId,
        language: '',
        isSuperuser: false,
        automatedId: null,
        profile: SnAccountProfile(
          id: senderId,
          experience: 0,
          level: 1,
          levelingProgress: 0,
          picture: null,
          background: null,
          verification: null,
          createdAt: now,
          updatedAt: now,
          deletedAt: null,
        ),
        perkSubscription: null,
        activatedAt: null,
        createdAt: now,
        updatedAt: now,
        deletedAt: null,
      ),
      nick: null,
      notify: 0,
      joinedAt: null,
      breakUntil: null,
      timeoutUntil: null,
      chatGroupId: null,
      chatGroup: null,
      lastReadAt: null,
      status: null,
      realmNick: null,
      realmBio: null,
      realmExperience: null,
      realmLevel: null,
      realmLevelingProgress: null,
      realmLabel: null,
    );
  }
}

enum MessageStatus { pending, sent, failed }
