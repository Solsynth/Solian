import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:island/accounts/widgets/friend_status_toast.dart';
import 'package:island_ui_foundation/island_ui_foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

part 'notification.g.dart';

/// Parses a `notifications.new` payload.
///
/// Ring's model keeps `title`, `content` and `subtitle` nullable — a silent or
/// image-only notice carries none of them — while the SDK model requires a
/// `String`. Reading straight through made those pushes throw inside the
/// socket listener, which surfaced as "notifications never arrive" instead of
/// a blank line of text. Everything optional is filled in here, and a payload
/// with no id at all is rejected so the caller can skip it.
SnNotification? parsePushedNotification(Map<String, dynamic> data) {
  final id = data['id'];
  final topic = data['topic'];
  if (id is! String || id.isEmpty || topic is! String) return null;

  String text(Object? value) => value is String ? value : '';
  final createdAt = DateTime.tryParse(text(data['created_at']));
  final viewedAt = DateTime.tryParse(text(data['viewed_at']));
  final meta = data['meta'];

  return SnNotification(
    createdAt: createdAt ?? DateTime.now(),
    id: id,
    appId: data['app_id'] is String ? data['app_id'] as String : null,
    topic: topic,
    title: text(data['title']),
    subtitle: text(data['subtitle']),
    body: text(data['content']),
    meta: meta is Map ? Map<String, dynamic>.from(meta) : const {},
    viewedAt: viewedAt,
    accountId: text(data['account_id']),
  );
}

const kNotificationBaseDuration = Duration(seconds: 5);

enum NotificationItemType { system, friendStatus }

class NotificationItem implements OverlayNotificationItem {
  @override
  final String id;
  final NotificationItemType type;
  final SnNotification? notification;
  final FriendStatusChangeEvent? friendStatusEvent;
  final DateTime createdAt;
  final int index;
  @override
  final Duration duration;
  @override
  final bool dismissed;

  /// Friend-status notices are capsules that paint their own fill and shape,
  /// so the overlay must not put a card behind them.
  @override
  bool get selfSurfaced => type == NotificationItemType.friendStatus;

  /// A capsule is 34px tall plus its own shadow; the deck's 20px card overlap
  /// would swallow that sentence, so it gets a clear slot of its own.
  @override
  double get stackAdvance => selfSurfaced ? 42 : 0;

  NotificationItem({
    String? id,
    required this.type,
    this.notification,
    this.friendStatusEvent,
    DateTime? createdAt,
    required this.index,
    Duration? duration,
    this.dismissed = false,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now(),
       duration =
           duration ?? kNotificationBaseDuration + Duration(seconds: index);

  factory NotificationItem.system({
    String? id,
    required SnNotification notification,
    required int index,
    Duration? duration,
  }) {
    return NotificationItem(
      id: id,
      type: NotificationItemType.system,
      notification: notification,
      index: index,
      duration: duration,
    );
  }

  factory NotificationItem.friendStatus({
    String? id,
    required FriendStatusChangeEvent event,
    required int index,
    Duration? duration,
  }) {
    return NotificationItem(
      id: id,
      type: NotificationItemType.friendStatus,
      friendStatusEvent: event,
      index: index,
      duration: duration,
    );
  }

  NotificationItem copyWith({
    String? id,
    NotificationItemType? type,
    SnNotification? notification,
    FriendStatusChangeEvent? friendStatusEvent,
    DateTime? createdAt,
    int? index,
    Duration? duration,
    bool? dismissed,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      type: type ?? this.type,
      notification: notification ?? this.notification,
      friendStatusEvent: friendStatusEvent ?? this.friendStatusEvent,
      createdAt: createdAt ?? this.createdAt,
      index: index ?? this.index,
      duration: duration ?? this.duration,
      dismissed: dismissed ?? this.dismissed,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NotificationItem && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

@riverpod
class NotificationState extends _$NotificationState {
  @override
  List<NotificationItem> build() {
    return [];
  }

  void add(SnNotification notification, {Duration? duration}) {
    final newItem = NotificationItem.system(
      notification: notification,
      index: state.length,
      duration: duration,
    );
    state = [...state, newItem];
  }

  void addFriendStatus(FriendStatusChangeEvent event, {Duration? duration}) {
    // Keep at most one live toast per account: refresh the existing toast with
    // the newest event instead of stacking a new one. A fresh duration makes
    // the overlay restart the auto-dismiss timer for the updated content.
    final existingIndex = state.indexWhere(
      (item) =>
          item.type == NotificationItemType.friendStatus &&
          !item.dismissed &&
          item.friendStatusEvent?.account.id == event.account.id,
    );

    if (existingIndex != -1) {
      final updated = state[existingIndex].copyWith(
        friendStatusEvent: event,
        createdAt: DateTime.now(),
        duration: duration ?? kNotificationBaseDuration,
      );
      state = List.from(state)..[existingIndex] = updated;
      return;
    }

    final newItem = NotificationItem.friendStatus(
      event: event,
      index: state.length,
      duration: duration,
    );
    state = [...state, newItem];
  }

  void dismiss(String id) {
    final index = state.indexWhere((item) => item.id == id);
    if (index != -1) {
      state = List.from(state)
        ..[index] = state[index].copyWith(dismissed: true);
    }
  }

  void remove(String id) {
    state = state.where((item) => item.id != id).toList();
  }

  void clear() {
    state = [];
  }
}
