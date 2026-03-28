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
    String? clientMessageId,
    String? nonce,
  }) {
    final jsonData = message.toJson();
    jsonData['sender'] = message.sender.toJson();
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

  String toDataJson() => jsonEncode(data);
}

enum MessageStatus { pending, sent, failed }
