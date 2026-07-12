import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:island/chat/utils/chat_room_share_metadata.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

class IosShareSuggestionTarget {
  final String roomId;

  const IosShareSuggestionTarget({required this.roomId});
}

class IosShareSuggestionsService {
  IosShareSuggestionsService._();

  static final instance = IosShareSuggestionsService._();
  static const _channel = MethodChannel(
    'dev.solsynth.solian/share_suggestions',
  );

  bool get _isSupported => !kIsWeb && Platform.isIOS;

  Future<void> donateChatRoom(
    SnChatRoom room, {
    required String? currentUserId,
    required String serverUrl,
  }) async {
    if (!_isSupported) return;

    final displayName = getChatRoomSuggestionDisplayName(room, currentUserId);
    final recipientAccountName = getDirectChatCounterpartAccountName(
      room,
      currentUserId,
    );
    final recipientNick = getDirectChatCounterpartNick(room, currentUserId);
    final recipientFirstName = getDirectChatCounterpartFirstName(
      room,
      currentUserId,
    );
    final recipientPictureUrl = getDirectChatCounterpartPictureUrl(
      room,
      currentUserId,
      serverUrl,
    );

    try {
      await _channel.invokeMethod<void>('donateChatConversation', {
        'roomId': room.id,
        'displayName': displayName,
        'isDirect': room.type == 1,
        'recipientAccountName': recipientAccountName,
        'recipientNick': recipientNick,
        'recipientFirstName': recipientFirstName,
        'recipientPictureUrl': recipientPictureUrl,
      });
    } on PlatformException {
      // Best-effort integration.
    }
  }

  Future<IosShareSuggestionTarget?> consumePendingTarget() async {
    if (!_isSupported) return null;

    try {
      final result = await _channel.invokeMapMethod<String, dynamic>(
        'consumePendingShareTarget',
      );
      final roomId = result?['roomId']?.toString();
      if (roomId == null || roomId.isEmpty) return null;
      return IosShareSuggestionTarget(roomId: roomId);
    } on PlatformException {
      return null;
    }
  }
}
