import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:dio/dio.dart';
import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:surface/database/database.dart';
import 'package:surface/logger.dart';
import 'package:surface/providers/database.dart';
import 'package:surface/providers/sn_attachment.dart';
import 'package:surface/providers/sn_network.dart';
import 'package:surface/providers/user_directory.dart';
import 'package:surface/providers/websocket.dart';
import 'package:surface/types/chat.dart';
import 'package:surface/types/websocket.dart';
import 'package:uuid/uuid.dart';

class ChatMessageController extends ChangeNotifier {
  static const kSingleBatchLoadLimit = 100;

  late final SnNetworkProvider _sn;
  late final UserDirectoryProvider _ud;
  late final WebSocketProvider _ws;
  late final SnAttachmentProvider _attach;
  late final DatabaseProvider _dt;

  StreamSubscription? _wsSubscription;

  ChatMessageController(BuildContext context) {
    _sn = context.read<SnNetworkProvider>();
    _ud = context.read<UserDirectoryProvider>();
    _ws = context.read<WebSocketProvider>();
    _attach = context.read<SnAttachmentProvider>();
    _dt = context.read<DatabaseProvider>();
  }

  bool isPending = true;
  bool isLoading = false;

  int? messageTotal;

  bool get isAllLoaded =>
      messageTotal != null && messages.length >= messageTotal!;

  SnChannel? channel;
  SnChannelMember? profile;

  /// Messages are the all the messages that in the channel
  final List<SnChatMessage> messages = List.empty(growable: true);

  /// Unconfirmed messages are the messages that sent by client but did not receive the reply from websocket server.
  /// Stored as a list of nonce to provide the loading state
  final List<String> unconfirmedMessages = List.empty(growable: true);

  final List<SnChannelMember> typingMembers = List.empty(growable: true);
  final Map<int, Timer> typingInactiveTimer = {};

  Future<void> initialize(SnChannel chan) async {
    channel = chan;

    // Fetch channel profile
    final resp = await _sn.client.get(
      '/cgi/im/channels/${chan.keyPath}/me',
    );
    profile = SnChannelMember.fromJson(resp.data);

    _wsSubscription = _ws.pk.stream.listen((event) {
      switch (event.method) {
        case 'events.new':
          if (event.payload?['channel_id'] != channel?.id) break;
          final payload = SnChatMessage.fromJson(event.payload!);
          _addMessage(payload);
          break;
        case 'status.typing':
          if (event.payload?['channel_id'] != channel?.id) break;
          final member = SnChannelMember.fromJson(event.payload!['member']);
          if (member.id == profile?.id) break;
          if (!typingMembers.any((x) => x.id == member.id)) {
            typingMembers.add(member);
            notifyListeners();
          }
          typingInactiveTimer[member.id]?.cancel();
          typingInactiveTimer[member.id] =
              Timer(const Duration(seconds: 3), () {
            typingMembers.removeWhere((x) => x.id == member.id);
            typingInactiveTimer.remove(member.id);
            notifyListeners();
          });
      }
    });

    isPending = false;
    notifyListeners();
  }

  Timer? _typingNotifyTimer;
  bool _typingStatus = false;

  Future<void> _sendTypingStatusPackage() async {
    _ws.conn?.sink.add(jsonEncode(
      WebSocketPackage(
        method: 'status.typing',
        endpoint: 'im',
        payload: {
          'channel_id': channel!.id,
        },
      ).toJson(),
    ));
  }

  void pingTypingStatus() {
    if (!_typingStatus) {
      _sendTypingStatusPackage();
      _typingStatus = true;
    }

    if (_typingNotifyTimer == null || !_typingNotifyTimer!.isActive) {
      _typingNotifyTimer?.cancel();
      _typingNotifyTimer = Timer(const Duration(milliseconds: 1850), () {
        _typingStatus = false;
      });
    }
  }

  Future<void> _saveMessageToLocal(Iterable<SnChatMessage> messages) async {
    await _dt.db.snLocalChatMessage.insertAll(
        messages.map(
          (ele) => SnLocalChatMessageCompanion.insert(
            id: Value(ele.id),
            content: ele,
            channelId: channel!.id,
            createdAt: Value(ele.createdAt),
          ),
        ),
        onConflict: DoNothing());
  }

  Future<void> _addUnconfirmedMessage(SnChatMessage message) async {
    SnChatMessage? quoteEvent;
    if (message.quoteEventId != null) {
      quoteEvent = await getMessage(message.quoteEventId as int);
    }

    final attachmentRid = List<String>.from(
      message.body['attachments']?.cast<String>() ?? [],
    );
    final attachments = await _attach.getMultiple(attachmentRid);
    message = message.copyWith(
      preload: SnChatMessagePreload(
        quoteEvent: quoteEvent,
        attachments: attachments,
      ),
    );

    messages.insert(0, message);
    unconfirmedMessages.add(message.uuid);
    notifyListeners();
  }

  Future<void> _addMessage(SnChatMessage message) async {
    SnChatMessage? quoteEvent;
    if (message.quoteEventId != null) {
      quoteEvent = await getMessage(message.quoteEventId as int);
    }

    final attachmentRid = List<String>.from(
      message.body['attachments']?.cast<String>() ?? [],
    );
    final attachments = await _attach.getMultiple(attachmentRid);
    message = message.copyWith(
      preload: SnChatMessagePreload(
        quoteEvent: quoteEvent,
        attachments: attachments,
      ),
    );

    final idx = messages.indexWhere((e) => e.uuid == message.uuid);
    if (idx != -1) {
      unconfirmedMessages.remove(message.uuid);
      messages[idx] = message;
    } else {
      messages.insert(0, message);
    }
    await _applyMessage(message);
    notifyListeners();

    if (isCheckedUpdate) {
      await _dt.db.snLocalChatMessage.insertOne(
        SnLocalChatMessageCompanion.insert(
          id: Value(message.id),
          content: message,
          channelId: channel!.id,
          createdAt: Value(message.createdAt),
        ),
        onConflict: DoUpdate(
          (_) => SnLocalChatMessageCompanion.custom(
            content: Constant(jsonEncode(message.toJson())),
          ),
        ),
      );
    } else {
      incomeStrandedQueue.add(message);
    }
  }

  Future<void> _applyMessage(SnChatMessage message) async {
    if (message.channelId != channel?.id) return;

    switch (message.type) {
      case 'messages.edit':
        if (message.relatedEventId != null) {
          final idx =
              messages.indexWhere((x) => x.id == message.relatedEventId);
          if (idx != -1) {
            final newBody = Map<String, dynamic>.from(message.body);
            newBody.remove('related_event');
            messages[idx] = messages[idx].copyWith(
              body: newBody,
              updatedAt: message.updatedAt,
            );
          }
          if (message.relatedEventId != null) {
            await (_dt.db.snLocalChatMessage.update()
                  ..where((e) => e.id.equals(message.relatedEventId!)))
                .write(
              SnLocalChatMessageCompanion.custom(
                content: Constant(jsonEncode(messages[idx].toJson())),
              ),
            );
          }
        }
      case 'messages.delete':
        if (message.relatedEventId != null) {
          messages.removeWhere((x) => x.id == message.relatedEventId);
          if (message.relatedEventId != null) {
            await (_dt.db.snLocalChatMessage.delete()
                  ..where((e) => e.id.equals(message.relatedEventId!)))
                .go();
          }
        }
    }
  }

  Future<void> sendMessage(
    String type,
    String content, {
    int? quoteId,
    int? relatedId,
    List<String>? attachments,
    SnChatMessage? editingMessage,
  }) async {
    if (channel == null) return;
    const uuid = Uuid();
    final nonce = uuid.v4();
    final body = {
      'text': content,
      'algorithm': 'plain',
      if (quoteId != null) 'quote_event': quoteId,
      if (relatedId != null) 'related_event': relatedId,
      if (attachments != null && attachments.isNotEmpty)
        'attachments': attachments,
    };

    // Mock the message locally
    final createdAt = DateTime.now();
    final message = SnChatMessage(
      id: 0,
      createdAt: createdAt,
      updatedAt: createdAt,
      deletedAt: null,
      uuid: nonce,
      body: body,
      type: type,
      channel: channel!,
      channelId: channel!.id,
      sender: profile!,
      senderId: profile!.id,
      quoteEventId: quoteId,
      relatedEventId: relatedId,
    );
    _addUnconfirmedMessage(message);

    // Send to server
    try {
      await _sn.client.request(
        editingMessage != null
            ? '/cgi/im/channels/${channel!.keyPath}/messages/${editingMessage.id}'
            : '/cgi/im/channels/${channel!.keyPath}/messages',
        data: {
          'type': type,
          'uuid': nonce,
          'body': body,
        },
        options: Options(
          method: editingMessage != null ? 'PUT' : 'POST',
        ),
      );
    } catch (err) {
      // ignore
    }
  }

  Future<void> deleteMessage(SnChatMessage message) async {
    if (message.channelId != channel?.id) return;

    try {
      await _sn.client.delete(
        '/cgi/im/channels/${channel!.keyPath}/messages/${message.id}',
      );
    } catch (err) {
      // ignore
    }
  }

  bool isCheckedUpdate = false;
  List<SnChatMessage> incomeStrandedQueue = List.empty(growable: true);

  /// Check the local storage is up to date with the server.
  /// If the local storage is not up to date, it will be updated.
  Future<void> checkUpdate() async {
    isLoading = true;
    notifyListeners();

    final mostRecentMessage = await (_dt.db.snLocalChatMessage.select()
          ..where((e) => e.channelId.equals(channel!.id))
          ..limit(1)
          ..orderBy([
            (e) =>
                OrderingTerm(expression: e.createdAt, mode: OrderingMode.desc)
          ]))
        .getSingleOrNull();
    if (mostRecentMessage == null) {
      // Initial load
      await loadMessages(take: 20);
      isCheckedUpdate = true;
      return;
    }

    try {
      final resp = await _sn.client.get(
        '/cgi/im/channels/${channel!.keyPath}/events/update',
        queryParameters: {
          'pivot': mostRecentMessage.content.id,
        },
      );
      if (resp.data['up_to_date'] == true) return;
      // Only preload the first 100 messages to prevent first time check update cause load to server and waste local storage.
      // FIXME If the local is missing more than 100 messages, it won't be fetched, this is a problem, we need to fix it.
      final countToFetch = math.min(resp.data['count'] as int, 100);

      for (int idx = 0; idx < countToFetch; idx += kSingleBatchLoadLimit) {
        await getMessages(kSingleBatchLoadLimit, idx, forceRemote: true);
      }
    } catch (err) {
      rethrow;
    } finally {
      await loadMessages();
      isLoading = false;

      isCheckedUpdate = true;
      _saveMessageToLocal(incomeStrandedQueue).then((_) {
        incomeStrandedQueue.clear();
      });

      notifyListeners();
    }
  }

  /// Get a single event from the current channel
  /// If it was not found in local storage we will look it up in remote
  Future<SnChatMessage?> getMessage(int id) async {
    SnChatMessage? out;
    final local = await (_dt.db.snLocalChatMessage.select()
          ..limit(1)
          ..where((e) => e.id.equals(id)))
        .getSingleOrNull();
    if (local != null) {
      out = local.content;
    }

    if (out == null) {
      try {
        final resp = await _sn.client
            .get('/cgi/im/channels/${channel!.keyPath}/events/$id');
        out = SnChatMessage.fromJson(resp.data);
        _saveMessageToLocal([out]);
      } catch (_) {
        // ignore, maybe not found
      }
    }

    // Preload some related things if found
    if (out != null) {
      await _ud.listAccount([out.sender.accountId]);

      final attachments = await _attach.getMultiple(
        out.body['attachments']?.cast<String>() ?? [],
      );
      out = out.copyWith(
        preload: SnChatMessagePreload(
          attachments: attachments,
        ),
      );
    }

    return out;
  }

  /// Get message from local storage first, then from the server.
  /// Will not check local storage is up to date with the server.
  /// If you need to do the sync, do the `checkUpdate` instead.
  Future<List<SnChatMessage>> getMessages(
    int take,
    int offset, {
    bool forceLocal = false,
    bool forceRemote = false,
  }) async {
    final localTotal = await _dt.db.snLocalChatMessage
        .count(where: (e) => e.channelId.equals(channel!.id))
        .getSingle();

    late List<SnChatMessage> out;
    if ((localTotal >= take + offset || forceLocal) && !forceRemote) {
      final result = await (_dt.db.snLocalChatMessage.select()
            ..where((e) => e.channelId.equals(channel!.id))
            ..orderBy([
              (e) =>
                  OrderingTerm(expression: e.createdAt, mode: OrderingMode.desc)
            ])
            ..limit(take, offset: offset))
          .get();
      out = result.map((e) => e.content).toList();
    } else {
      final resp = await _sn.client.get(
        '/cgi/im/channels/${channel!.keyPath}/events',
        queryParameters: {
          'take': take,
          'offset': offset,
        },
      );
      messageTotal = resp.data['count'] as int?;
      out = List<SnChatMessage>.from(
        resp.data['data']?.map((e) => SnChatMessage.fromJson(e)) ?? [],
      );
      _saveMessageToLocal(out);
    }

    // Preload attachments
    final attachmentRid = List<String>.from(
      out.expand((e) => (e.body['attachments'] as List<dynamic>?) ?? []),
    );
    final attachments = await _attach.getMultiple(attachmentRid);

    // Putting preload back to data
    for (var i = 0; i < out.length; i++) {
      // Preload related events (quoted)
      SnChatMessage? quoteEvent;
      if (out[i].quoteEventId != null) {
        quoteEvent = await getMessage(out[i].quoteEventId as int);
      }

      out[i] = out[i].copyWith(
        preload: SnChatMessagePreload(
          quoteEvent: quoteEvent,
          attachments: attachments
              .where(
                (ele) =>
                    out[i].body['attachments']?.contains(ele?.rid) ?? false,
              )
              .toList(),
        ),
      );
    }

    // Preload sender accounts
    final accountId = out
        .where((ele) => ele.sender.accountId >= 0)
        .map((ele) => ele.sender.accountId)
        .toSet();
    await _ud.listAccount(accountId);

    return out;
  }

  /// The load messages method work as same as the `getMessages` method.
  /// But it won't return the messages instead append them to the value that controller has.
  /// At the same time, this method provide the `isLoading` state.
  /// The `skip` parameter is no longer required since it will skip the messages count that already loaded.
  Future<void> loadMessages({int take = 20}) async {
    isLoading = true;
    notifyListeners();

    try {
      final out = await getMessages(take, messages.length);
      messages.addAll(out);
    } catch (err) {
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Timer? _readEventDebounce;
  int? _readEventAnchor;

  void readEvent(int id) {
    if (_readEventAnchor != null) {
      _readEventAnchor = math.max(_readEventAnchor!, id);
    } else {
      _readEventAnchor = id;
    }
    if (_readEventDebounce?.isActive ?? false) {
      _readEventDebounce?.cancel();
    }

    _readEventDebounce = Timer(const Duration(milliseconds: 500), () {
      _sendReadEvent();
    });
  }

  void _sendReadEvent() {
    _ws.conn?.sink.add(jsonEncode(
      WebSocketPackage(
        method: 'events.read',
        endpoint: 'im',
        payload: {
          'channel_member_id': profile!.id,
          'event_id': _readEventAnchor,
        },
      ).toJson(),
    ));
    logging.debug('[Messaging] Send read event request: $_readEventAnchor');
  }

  @override
  void dispose() {
    _wsSubscription?.cancel();
    if (_readEventDebounce?.isActive ?? false) {
      _sendReadEvent();
    }
    _readEventDebounce?.cancel();
    super.dispose();
  }
}
