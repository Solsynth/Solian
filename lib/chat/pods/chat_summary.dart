import 'dart:async';
import 'dart:math' as math;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:island/core/network.dart';
import 'package:island/core/websocket.dart';
import 'package:island/core/database.dart';
import 'package:island/accounts/account_pod.dart';
import 'package:island/chat/pods/chat_subscribe.dart';
import 'package:island/core/utils/bounded_id_set.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

part 'chat_summary.g.dart';

/// Whether [message] should raise an unread count for the current account,
/// given the member row that carries the room's notify setting. Both the
/// per-room summary and the global badge go through this so they never
/// disagree: a mentions-only room contributes only its mentions, and a muted
/// room contributes nothing.
///
/// A missing member row means the setting is unknown (the room has not been
/// synced yet). Counting then would raise the badge for plain chatter in a
/// mentions-only room, so the count stays at zero until the row lands; the room
/// is still marked unread, which the tile shows either way.
bool _countsForNotification({
  required String? accountId,
  required SnChatMember? member,
  required SnChatMessage message,
}) {
  if (accountId == null) return true;
  if (member == null) return false;
  return switch (member.notify) {
    0 => true,
    1 => message.membersMentioned.contains(accountId),
    _ => false,
  };
}

/// Whether [message] is a real arrival for unread purposes.
///
/// Mirrors the server's own unread query: it skips upload placeholders and
/// `messages.*` mutation rows (edits, attachment and link previews). The one
/// exception is `messages.sync.finalize`, which is how a placeholder turns into
/// the real message the server then counts as unread. `messages.new` carries
/// all of these on one envelope, so the envelope alone cannot decide this.
bool _affectsUnreadState(SnChatMessage message) {
  if (message.type == 'placeholder') return false;
  if (message.type == 'messages.sync.finalize') return true;
  return !message.type.startsWith('messages.');
}

/// Whether this is the signed-in member's own message.
///
/// Mirrors the server's unread query, which excludes rows with `sender_id`
/// equal to the account's member row in that room.
bool _isOwnMessage(SnChatMessage message, SnChatMember? member) =>
    member != null && message.senderId == member.id;

/// The id this arrival stands for, for dedupe and preview purposes.
///
/// A placeholder finalize is a shadow row: its own id is fresh, and
/// `meta['message_id']` names the message it completes. Counting the shadow id
/// would let the completed row count a second time.
String _arrivalMessageId(SnChatMessage message) {
  if (message.type == 'messages.sync.finalize') {
    final target = message.meta['message_id']?.toString();
    if (target != null && target.isNotEmpty) return target;
  }
  return message.id;
}

/// How [message] moves the signed-in account's room summary.
///
/// Any real message from someone else leaves the room unread, but only a
/// message the room's notify level lets through raises the count: a
/// mentions-only room counts just its mentions (plain chatter only sets
/// `has_unread`), and a muted room never counts. This mirrors the server's own
/// unread query, which computes `has_unread` independently of the notify level.
({bool count, bool unread}) _unreadEffect(
  SnChatMessage message, {
  required String? accountId,
  required SnChatMember? member,
}) {
  const quiet = (count: false, unread: false);
  if (!_affectsUnreadState(message)) return quiet;
  if (_isOwnMessage(message, member)) return quiet;
  return (
    count: _countsForNotification(
      accountId: accountId,
      member: member,
      message: message,
    ),
    unread: true,
  );
}

@riverpod
class ChatUnreadCountNotifier extends _$ChatUnreadCountNotifier {
  StreamSubscription<WebSocketPacket>? _subscription;

  /// Ids whose unread increment already happened. Delivery is at-least-once,
  /// so the same message can arrive again after a retry or a resume replay.
  final _countedMessageIds = BoundedIdSet(512);

  @override
  Future<int> build() async {
    // Subscribe to websocket events when this provider is built
    _subscribeToWebSocket();

    // Dispose the subscription when this provider is disposed
    ref.onDispose(() {
      _subscription?.cancel();
    });

    try {
      final client = ref.read(apiClientProvider);
      final response = await client.get('/messager/chat/unread');
      return (response.data as num).toInt();
    } catch (_) {
      return 0;
    }
  }

  void _subscribeToWebSocket() {
    final webSocketService = ref.read(websocketProvider);
    _subscription = webSocketService.dataStream.listen((packet) {
      final isArrivalPacket =
          packet.type == 'messages.new' || packet.type == 'messages.update';
      if (isArrivalPacket && packet.data != null) {
        final message = SnChatMessage.fromJson(packet.data!);
        // Placeholders and `messages.*` mutation rows share these envelopes but
        // are not arrivals. A placeholder finalize is one, and it is how the
        // completed message arrives when the placeholder streamed first.
        if (!_affectsUnreadState(message)) return;
        // A re-delivered frame must not count twice; the total is reconciled
        // from the server on room open and by applySyncedSummaries.
        if (!_countedMessageIds.add(_arrivalMessageId(message))) return;
        final currentSubscribed = ref.read(currentSubscribedChatIdProvider);
        // Only increment if the message is not from the currently subscribed chat
        if (message.chatRoomId == currentSubscribed) return;
        unawaited(_countIfNotifiable(message));
      }
    });
  }

  /// Raises the badge for [message] only when the message is a real,
  /// notifiable arrival: mutation envelopes and placeholders stream on the same
  /// `messages.new` envelope but never appear in the server's unread queries,
  /// and a mentions-only room contributes just its mentions.
  Future<void> _countIfNotifiable(SnChatMessage message) async {
    // The notify setting lives on the member row, which is keyed by account.
    // Resolve the signed-in account first: reading it mid-load would see no
    // account and fall through to counting every message.
    final accountId = (await ref.read(userInfoProvider.future))?.id;
    if (!ref.mounted) return;
    final member = accountId == null
        ? null
        : await ref
              .read(databaseProvider)
              .getMemberByRoomAndAccount(message.chatRoomId, accountId);
    if (!ref.mounted) return;
    if (!_unreadEffect(
      message,
      accountId: accountId,
      member: member,
    ).count) {
      return;
    }
    await _incrementCounter();
  }

  Future<void> _incrementCounter() async {
    final current = await future;
    if (!ref.mounted) return;
    state = AsyncData(current + 1);
  }

  Future<void> decrement(int count) async {
    final current = await future;
    state = AsyncData(math.max(current - count, 0));
  }

  void clear() async {
    state = AsyncData(0);
  }

  void setCount(int count) {
    state = AsyncData(math.max(count, 0));
  }
}

@Riverpod(keepAlive: true)
class ChatSummary extends _$ChatSummary {
  /// Ids already folded into the summary; a re-delivered frame is a no-op.
  final _summarizedMessageIds = BoundedIdSet(512);

  Map<String, dynamic> _sanitizeChatMessageJson(Map<String, dynamic> input) {
    final data = Map<String, dynamic>.from(input);
    final meta = data['meta'] is Map<String, dynamic>
        ? Map<String, dynamic>.from(data['meta'] as Map<String, dynamic>)
        : <String, dynamic>{};
    final encryptionMeta = data['encryption_meta'] is Map
        ? Map<String, dynamic>.from(data['encryption_meta'] as Map)
        : null;
    if (encryptionMeta != null) {
      meta['e2ee_is_encrypted'] = true;
      meta['e2ee_ciphertext'] = encryptionMeta['ciphertext'];
      meta['e2ee_header'] = encryptionMeta['header'];
      meta['e2ee_signature'] = encryptionMeta['signature'];
      meta['e2ee_scheme'] = encryptionMeta['scheme'];
      meta['e2ee_epoch'] = encryptionMeta['epoch'];
      meta['e2ee_message_type'] = data['type'];
      meta['e2ee_client_message_id'] = data['client_message_id'];
    }
    data['meta'] = meta;
    return data;
  }

  SnChatMessage? _tryParseChatMessage(dynamic data) {
    if (data is! Map<String, dynamic>) return null;
    try {
      return SnChatMessage.fromJson(_sanitizeChatMessageJson(data));
    } catch (_) {
      return null;
    }
  }

  SnChatSummary? _tryParseSummary(dynamic data) {
    if (data is! Map) return null;
    try {
      final json = Map<String, dynamic>.from(data);
      final last = _tryParseChatMessage(json['last_message']);
      if (last != null) {
        json['last_message'] = last.toJson();
      }
      return SnChatSummary.fromJson(json);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<Map<String, SnChatSummary>> build() async {
    final client = ref.watch(apiClientProvider);
    final resp = await client.get('/messager/chat/summary');

    final Map<String, dynamic> data = resp.data;
    final summaries = data.map((key, value) {
      return MapEntry(
        key,
        _tryParseSummary(value) ??
            const SnChatSummary(
              unreadCount: 0,
              hasUnread: false,
              lastMessage: null,
            ),
      );
    });

    final ws = ref.watch(websocketProvider);
    final subscription = ws.dataStream.listen((WebSocketPacket pkt) {
      if (!pkt.type.startsWith('messages')) return;
      if (pkt.type == 'messages.new') {
        final message = _tryParseChatMessage(pkt.data);
        if (message == null) return;
        updateLastMessage(message.chatRoomId, message);
      } else if (pkt.type == 'messages.update') {
        final message = _tryParseChatMessage(pkt.data);
        // `messages.update` is also how a placeholder finalize (a real arrival)
        // is delivered, so the packet type alone must not decide whether the
        // summary folds this; updateLastMessage classifies the payload type.
        if (message == null) return;
        updateLastMessage(message.chatRoomId, message);
      }
    });

    ref.onDispose(() {
      subscription.cancel();
    });

    return summaries;
  }

  void applySyncedSummaries(
    List<dynamic> rawSummaries, {
    Set<String> removedRoomIds = const {},
  }) {
    final updates = <String, SnChatSummary>{};

    for (final raw in rawSummaries.whereType<Map>()) {
      final json = Map<String, dynamic>.from(raw);
      final roomId = json['room_id']?.toString() ?? json['roomId']?.toString();
      if (roomId == null || roomId.isEmpty) continue;

      final summary = _tryParseSummary(json);
      if (summary == null) continue;
      updates[roomId] = summary;
    }

    if (updates.isEmpty && removedRoomIds.isEmpty) return;

    final current = state.maybeWhen(
      data: (value) => value,
      orElse: () => const <String, SnChatSummary>{},
    );
    final next = Map<String, SnChatSummary>.from(current)
      ..removeWhere((key, _) => removedRoomIds.contains(key))
      ..addAll(updates);

    state = AsyncData(next);
    ref
        .read(chatUnreadCountProvider.notifier)
        .setCount(
          next.values.fold<int>(0, (sum, item) => sum + item.unreadCount),
        );
  }

  Future<void> clearUnreadCount(String chatId) async {
    state.whenData((summaries) {
      final summary = summaries[chatId];
      if (summary != null) {
        // Decrement global unread count
        final unreadToDecrement = summary.unreadCount;
        if (unreadToDecrement > 0) {
          ref
              .read(chatUnreadCountProvider.notifier)
              .decrement(unreadToDecrement);
        }

        state = AsyncData({
          ...summaries,
          chatId: SnChatSummary(
            unreadCount: 0,
            hasUnread: false,
            lastMessage: summary.lastMessage,
          ),
        });
      }
    });
  }

  void clearAllUnreadCounts() {
    state.whenData((summaries) {
      state = AsyncData({
        for (final entry in summaries.entries)
          entry.key: SnChatSummary(
            unreadCount: 0,
            hasUnread: false,
            lastMessage: entry.value.lastMessage,
          ),
      });
      ref.read(chatUnreadCountProvider.notifier).clear();
    });
  }


  /// Folds an incoming [message] into [chatId]'s summary.
  ///
  /// Both the room-scoped message notifier and the socket listener report
  /// arrivals. The id claim in [_summarizedMessageIds] makes whichever arrives
  /// first the only one that moves the summary, so the counter can never take
  /// the same message twice.
  void updateLastMessage(String chatId, SnChatMessage message) {
    // Upload placeholders are not messages: they must never become the room
    // preview, and they must not claim the id their finalize arrives under.
    if (message.type == 'placeholder') return;
    // At-least-once delivery replays a frame until it is acked, so the same
    // message must only move the summary once. A finalize stands for the
    // placeholder it completes, so it is claimed under that message's id.
    if (!_summarizedMessageIds.add(_arrivalMessageId(message))) return;
    // Mutation envelopes arrive on `messages.new` with `messages.*` payloads.
    // Only an edit changes the preview, and only as the content of the message
    // it edits; a finalize instead upgrades the placeholder preview below, and
    // every other mutation row here is not an arrival at all.
    if (message.type.startsWith('messages.') &&
        message.type != 'messages.sync.finalize') {
      if (message.type == 'messages.update') {
        final targetId = message.meta['message_id']?.toString();
        updateMessageContent(
          chatId,
          targetId == null ? message : message.copyWith(id: targetId),
        );
      }
      return;
    }
    // The finalize shadow carries the completed content of the placeholder it
    // replaced, which the timeline renders as a regular message row.
    final arrival = message.type == 'messages.sync.finalize'
        ? message.copyWith(id: _arrivalMessageId(message), type: 'text')
        : message;
    unawaited(_foldIncomingMessage(chatId, arrival));
  }

  Future<void> _foldIncomingMessage(
    String chatId,
    SnChatMessage message,
  ) async {
    final accountId = (await ref.read(userInfoProvider.future))?.id;
    if (!ref.mounted) return;
    final member = accountId == null
        ? null
        : await ref
              .read(databaseProvider)
              .getMemberByRoomAndAccount(chatId, accountId);
    if (!ref.mounted) return;

    final effect = _unreadEffect(
      message,
      accountId: accountId,
      member: member,
    );
    final isOpen = chatId == ref.read(currentSubscribedChatIdProvider);
    final raisesUnread = !isOpen && effect.unread;
    final counts = !isOpen && effect.count;

    state.whenData((summaries) {
      final summary = summaries[chatId];
      if (summary == null) return;
      final existing = summary.lastMessage;
      // A replayed older row still arrived, so it still counts; only the
      // preview must never move backwards.
      final movesPreview =
          existing == null || !message.createdAt.isBefore(existing.createdAt);
      state = AsyncData({
        ...summaries,
        chatId: SnChatSummary(
          unreadCount: summary.unreadCount + (counts ? 1 : 0),
          hasUnread: summary.hasUnread || raisesUnread,
          lastMessage: movesPreview ? message : existing,
        ),
      });
    });
  }

  /// Shows a message the signed-in account just sent as the room preview.
  ///
  /// The websocket echo may be missed when the user has already left the room,
  /// and an own message must never raise the unread badge. Claiming the id in
  /// the re-delivery guard keeps the later socket frame from counting it.
  void applyOwnSentMessage(String chatId, SnChatMessage message) {
    if (!_summarizedMessageIds.add(message.id)) return;

    state.whenData((summaries) {
      final summary = summaries[chatId];
      if (summary == null) return;
      final existing = summary.lastMessage;
      if (existing != null && existing.createdAt.isAfter(message.createdAt)) {
        return;
      }
      state = AsyncData({
        ...summaries,
        chatId: SnChatSummary(
          unreadCount: summary.unreadCount,
          hasUnread: summary.hasUnread,
          lastMessage: message,
        ),
      });
    });
  }

  /// Applies the newest message synced by the cross-room message sync.
  ///
  /// The list tile renders its preview, timestamp, ordering and unread state
  /// from this summary, not from the message store. A global sync commits rows
  /// for rooms that are not open, so without this the list keeps showing the
  /// previous message until the next rooms sync happens to run.
  ///
  /// [newMessagesByRoom] carries only the synced messages that were not stored
  /// before, which keeps the unread bump idempotent across the sync's repeated
  /// rounds. Each id is claimed in the re-delivery guard as it is counted, so
  /// the socket frame for the same message never folds it a second time.
  Future<void> applySyncedLastMessages({
    required Map<String, SnChatMessage> latestByRoom,
    required Map<String, List<SnChatMessage>> newMessagesByRoom,
  }) async {
    if (latestByRoom.isEmpty) return;

    final currentSubscribed = ref.read(currentSubscribedChatIdProvider);
    final accountId = ref.read(userInfoProvider).value?.id;
    final db = ref.read(databaseProvider);
    final current = state.maybeWhen(
      data: (summaries) => summaries,
      orElse: () => const <String, SnChatSummary>{},
    );
    final next = Map<String, SnChatSummary>.from(current);
    var changed = false;

    for (final entry in latestByRoom.entries) {
      final chatId = entry.key;
      final message = entry.value;
      final summary = next[chatId];
      if (summary == null) continue;

      // Sync pages ascend, but a resumed cursor can replay older rows; never
      // move a preview backwards.
      final existing = summary.lastMessage;
      if (existing != null && !message.createdAt.isAfter(existing.createdAt)) {
        continue;
      }

      var unread = 0;
      var hasUnread = false;
      if (chatId != currentSubscribed) {
        // One member read per room: it carries both the notify setting and the
        // read marker.
        final member = accountId == null
            ? null
            : await db.getMemberByRoomAndAccount(chatId, accountId);

        // A catch-up backfills days of history, so only what arrived after this
        // member's read marker is still unread. Reading on another device must
        // not reopen a badge here.
        final lastReadAt = member?.lastReadAt?.toUtc();

        for (final newMessage
            in newMessagesByRoom[chatId] ?? const <SnChatMessage>[]) {
          // Claiming the id here is what makes the bump safe against the socket
          // path: a live frame for the same message can arrive while this sync
          // is still in flight, and whichever folds it first takes the count.
          if (!_summarizedMessageIds.add(newMessage.id)) continue;
          if (lastReadAt != null &&
              !newMessage.createdAt.toUtc().isAfter(lastReadAt)) {
            continue;
          }
          final effect = _unreadEffect(
            newMessage,
            accountId: accountId,
            member: member,
          );
          if (effect.count) unread += 1;
          if (effect.unread) hasUnread = true;
        }
      }

      next[chatId] = SnChatSummary(
        unreadCount: summary.unreadCount + unread,
        hasUnread: summary.hasUnread || hasUnread,
        lastMessage: message,
      );
      changed = true;
    }

    if (!changed) return;
    state = AsyncData(next);
    ref
        .read(chatUnreadCountProvider.notifier)
        .setCount(
          next.values.fold<int>(0, (sum, item) => sum + item.unreadCount),
        );
  }

  void updateMessageContent(String chatId, SnChatMessage message) {
    state.whenData((summaries) {
      final summary = summaries[chatId];
      if (summary != null && summary.lastMessage?.id == message.id) {
        state = AsyncData({
          ...summaries,
          chatId: SnChatSummary(
            unreadCount: summary.unreadCount,
            hasUnread: summary.hasUnread,
            lastMessage: message,
          ),
        });
      }
    });
  }
}
