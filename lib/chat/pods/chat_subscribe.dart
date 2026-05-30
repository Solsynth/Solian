import "dart:async";
import "dart:convert";
import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:island/accounts/account_pod.dart";
import "package:island/chat/messages_notifier.dart";
import "package:island/chat/pods/chat_room.dart";
import "package:island/chat/pods/chat_summary.dart";
import "package:island/core/lifecycle.dart";
import "package:island/core/network.dart";
import "package:island/core/services/event_bus.dart";
import "package:island/core/websocket.dart";
import "package:logging/logging.dart";
import "package:riverpod_annotation/riverpod_annotation.dart";
import 'package:solar_network_sdk/solar_network_sdk.dart';

part 'chat_subscribe.g.dart';

final currentSubscribedChatIdProvider =
    NotifierProvider<CurrentSubscribedChatIdNotifier, String?>(
      CurrentSubscribedChatIdNotifier.new,
    );

final chatReadSyncProvider = AsyncNotifierProvider<ChatReadSyncNotifier, void>(
  ChatReadSyncNotifier.new,
);

class CurrentSubscribedChatIdNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void set(String? value) => state = value;
}

class ChatReadSyncNotifier extends AsyncNotifier<void> {
  StreamSubscription<WebSocketPacket>? _subscription;

  @override
  FutureOr<void> build() {
    _subscription?.cancel();

    final ws = ref.read(websocketProvider);
    _subscription = ws.dataStream.listen(_handlePacket);

    ref.onDispose(() {
      _subscription?.cancel();
      _subscription = null;
    });
  }

  Future<void> _handlePacket(WebSocketPacket packet) async {
    if (packet.type != 'messages.read') return;

    final data = packet.data;
    if (data is! Map<Object?, Object?>) return;
    final packetData = data as Map<Object?, Object?>;

    final roomId = packetData['chat_room_id']?.toString();
    if (roomId == null || roomId.isEmpty) return;

    final currentUserId = ref.read(userInfoProvider).value?.id;
    final accountId = packetData['account_id']?.toString();
    if (currentUserId != null &&
        accountId != null &&
        accountId != currentUserId) {
      return;
    }

    await ref.read(chatSummaryProvider.notifier).clearUnreadCount(roomId);
  }

  Future<void> markAllRead() async {
    if (state.isLoading) return;

    state = const AsyncLoading();
    try {
      final client = ref.read(apiClientProvider);
      await client.post('/messager/chat/read-all');
      ref.read(chatSummaryProvider.notifier).clearAllUnreadCounts();
      state = const AsyncData(null);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }
}

@riverpod
class ChatSubscribeNotifier extends _$ChatSubscribeNotifier {
  static const Duration _subscribeRefreshInterval = Duration(minutes: 4);
  static const Duration _activityTtl = Duration(seconds: 6);
  static const Duration _typingSendCooldown = Duration(milliseconds: 850);
  static const Duration _uploadProgressThrottle = Duration(seconds: 1);
  late SnChatRoom _chatRoom;
  late SnChatMember _chatIdentity;

  final Map<String, ChatActivityStatus> _activityStatuses = {};
  Timer? _typingCleanupTimer;
  Timer? _typingCooldownTimer;
  Timer? _periodicSubscribeTimer;
  Function? _sendMessage;

  StreamSubscription<ChatTypingEvent>? _typingSub;
  DateTime? _lastUploadStatusSentAt;
  double? _lastUploadStatusSentProgress;

  bool get _isDesktop =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.macOS ||
          defaultTargetPlatform == TargetPlatform.windows ||
          defaultTargetPlatform == TargetPlatform.linux);

  bool _isWebSocketConnected() => ref
      .read(websocketStateProvider)
      .maybeWhen(connected: () => true, orElse: () => false);

  bool _shouldKeepSubscriptionAlive() {
    if (_isDesktop) return true;
    final lifecycleState = ref.read(appLifecycleStateProvider).value;
    return lifecycleState == null ||
        lifecycleState == AppLifecycleState.resumed;
  }

  void _sendPacket(WebSocketPacket packet, {required String context}) {
    if (_sendMessage == null || !_isWebSocketConnected()) return;
    try {
      _sendMessage!(jsonEncode(packet));
    } catch (e, stackTrace) {
      Logger.root.severe(
        '[MessageSubscriber] Failed to send $context for room $roomId',
        e,
        stackTrace,
      );
    }
  }

  void _sendSubscribe({required String reason}) {
    if (!_shouldKeepSubscriptionAlive()) return;
    Logger.root.info('[MessageSubscriber] Subscribing room $roomId ($reason)');
    _sendPacket(
      WebSocketPacket(
        type: 'messages.subscribe',
        data: {'chat_room_id': roomId},
        endpoint: 'messager',
      ),
      context: 'subscribe ($reason)',
    );
  }

  void _sendUnsubscribe({required String reason}) {
    Logger.root.info(
      '[MessageSubscriber] Unsubscribing room $roomId ($reason)',
    );
    _sendPacket(
      WebSocketPacket(
        type: 'messages.unsubscribe',
        data: {'chat_room_id': roomId},
        endpoint: 'messager',
      ),
      context: 'unsubscribe ($reason)',
    );
  }

  void _cleanupResources() {
    if (_typingCleanupTimer != null) {
      _typingCleanupTimer!.cancel();
      _typingCleanupTimer = null;
    }
    if (_periodicSubscribeTimer != null) {
      _periodicSubscribeTimer!.cancel();
      _periodicSubscribeTimer = null;
    }
    _typingSub?.cancel();
  }

  List<ChatActivityStatus> _currentActivities() {
    final activities = _activityStatuses.values.toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return activities;
  }

  void _emitActivityState() {
    if (ref.mounted) state = _currentActivities();
  }

  bool _isStaleActivity(DateTime timestamp) {
    final now = DateTime.now().toUtc();
    return now.difference(timestamp).abs() > _activityTtl;
  }

  int _roundedUploadProgress(double progress) => (progress * 100).round();

  void _sendActivityPacket({
    required String activityType,
    double? progress,
    required String context,
  }) {
    final now = DateTime.now().toUtc();
    _sendPacket(
      WebSocketPacket(
        type: 'messages.typing',
        data: {
          'chat_room_id': roomId,
          'ts': now.millisecondsSinceEpoch,
          'type': activityType,
          ...?progress == null ? null : {'progress': progress},
        },
        endpoint: 'messager',
      ),
      context: context,
    );
  }

  @override
  List<ChatActivityStatus> build(String roomId) {
    final chatRoomAsync = ref.watch(chatRoomProvider(roomId));
    final chatIdentityAsync = ref.watch(chatRoomIdentityProvider(roomId));
    ref.watch(messagesProvider(roomId));

    _cleanupResources();

    if (chatRoomAsync.isLoading || chatIdentityAsync.isLoading) {
      return [];
    }

    if (chatRoomAsync.value == null || chatIdentityAsync.value == null) {
      return [];
    }

    _chatRoom = chatRoomAsync.value!;
    _chatIdentity = chatIdentityAsync.value!;

    // Subscribe to messages
    final wsState = ref.read(websocketStateProvider.notifier);
    _sendMessage = wsState.sendMessage;
    _sendSubscribe(reason: 'initial');

    Future.microtask(
      () => ref.read(currentSubscribedChatIdProvider.notifier).set(roomId),
    );

    // Send initial read receipt
    sendReadReceipt();

    // Real-time message events are handled directly by MessagesNotifier
    // through RealtimeMessageHandler to avoid duplicate event processing.

    // Listen for typing events via Event Bus
    _typingSub = eventBus.on<ChatTypingEvent>().listen((event) {
      if (event.roomId != _chatRoom.id) return;
      if (event.sender.id == _chatIdentity.id) return;
      final timestamp = (event.timestamp ?? DateTime.now()).toUtc();
      if (_isStaleActivity(timestamp)) return;

      final previous = _activityStatuses[event.sender.id];
      if (previous != null && timestamp.isBefore(previous.timestamp)) {
        return;
      }

      _activityStatuses[event.sender.id] = ChatActivityStatus(
        sender: event.sender,
        timestamp: timestamp,
        activityType: event.activityType,
        progress: event.progress,
      );
      _emitActivityState();
    });

    // Set up typing status cleanup timer
    _typingCleanupTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (_activityStatuses.isNotEmpty) {
        final now = DateTime.now().toUtc();
        _activityStatuses.removeWhere(
          (_, status) => now.difference(status.timestamp) > _activityTtl,
        );
        _emitActivityState();
      }
    });

    // Keep subscription alive before the backend expiry window.
    _periodicSubscribeTimer = Timer.periodic(_subscribeRefreshInterval, (_) {
      if (ref.mounted) _sendSubscribe(reason: 'periodic-refresh');
    });

    ref.listen(appLifecycleStateProvider, (previous, next) {
      if (_isDesktop) return;
      final lifecycleState = next.value;
      if (lifecycleState == AppLifecycleState.paused ||
          lifecycleState == AppLifecycleState.inactive) {
        // Unsubscribe when app goes to background
        _sendUnsubscribe(reason: 'app-background');
      } else if (lifecycleState == AppLifecycleState.resumed) {
        // Resubscribe when app comes back to foreground
        _sendSubscribe(reason: 'app-resumed');
      }
    });

    ref.listen(websocketStateProvider, (previous, next) {
      final wasConnected =
          previous?.maybeWhen(connected: () => true, orElse: () => false) ??
          false;
      final isConnected = next.maybeWhen(
        connected: () => true,
        orElse: () => false,
      );
      if (!wasConnected && isConnected) {
        _sendSubscribe(reason: 'ws-reconnected');
      }
    });

    final subscribedNotifier = ref.watch(
      currentSubscribedChatIdProvider.notifier,
    );

    ref.onCancel(() {
      Future.microtask(() {
        if (!ref.mounted) return;
        final current = ref.read(currentSubscribedChatIdProvider);
        if (current == roomId) {
          subscribedNotifier.set(null);
        }
      });
      // Defer to avoid ref.read() inside lifecycle callback
      Future.microtask(() {
        if (!ref.mounted) return;
        _sendUnsubscribe(reason: 'provider-cancel');
      });
      try {
        _cleanupResources();
      } catch (e, stackTrace) {
        Logger.root.severe(
          '[MessageSubscriber] Error during cleanup for room $roomId',
          e,
          stackTrace,
        );
      }
      try {
        if (_typingCooldownTimer != null) {
          _typingCooldownTimer!.cancel();
        }
      } catch (e, stackTrace) {
        Logger.root.severe(
          '[MessageSubscriber] Error cancelling typing cooldown timer for room $roomId',
          e,
          stackTrace,
        );
      }
    });

    return _currentActivities();
  }

  void sendReadReceipt() {
    if (!ref.mounted) return;
    _sendPacket(
      WebSocketPacket(
        type: 'messages.read',
        data: {'chat_room_id': roomId},
        endpoint: 'messager',
      ),
      context: 'read-receipt',
    );
  }

  void sendTypingStatus() {
    // Don't send if we're already in a cooldown period
    if (_typingCooldownTimer != null) return;

    _sendActivityPacket(activityType: 'typing', context: 'typing-status');

    _typingCooldownTimer = Timer(_typingSendCooldown, () {
      _typingCooldownTimer = null;
    });
  }

  void sendUploadingStatus(double progress, {bool force = false}) {
    final clamped = progress.clamp(0.0, 1.0);
    final now = DateTime.now().toUtc();
    final isComplete = clamped >= 1.0;
    final sameBucket =
        _lastUploadStatusSentProgress != null &&
        _roundedUploadProgress(_lastUploadStatusSentProgress!) ==
            _roundedUploadProgress(clamped);
    final withinThrottle =
        _lastUploadStatusSentAt != null &&
        now.difference(_lastUploadStatusSentAt!) < _uploadProgressThrottle;

    if (!force && sameBucket) return;
    if (!force && withinThrottle && !isComplete) return;
    if (!force &&
        _lastUploadStatusSentProgress != null &&
        clamped < _lastUploadStatusSentProgress!) {
      return;
    }

    _sendActivityPacket(
      activityType: 'uploading',
      progress: clamped,
      context: 'uploading-status',
    );
    _lastUploadStatusSentAt = now;
    _lastUploadStatusSentProgress = clamped;

    if (isComplete) {
      _lastUploadStatusSentAt = null;
      _lastUploadStatusSentProgress = null;
    }
  }
}

class ChatActivityStatus {
  final SnChatMember sender;
  final DateTime timestamp;
  final String activityType;
  final double? progress;

  const ChatActivityStatus({
    required this.sender,
    required this.timestamp,
    required this.activityType,
    required this.progress,
  });

  String get senderName =>
      (sender.nick?.isNotEmpty == true) ? sender.nick! : sender.account.nick;

  bool get isUploading => activityType == 'uploading';
}
