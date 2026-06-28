import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:island/accounts/widgets/friend_status_toast.dart';
import 'package:island_ui_foundation/island_ui_foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

part 'notification.g.dart';

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
