import 'package:island/models/account.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

part 'notification.g.dart';

const kNotificationBaseDuration = Duration(seconds: 5);
const kNotificationStackedDuration = Duration(seconds: 1);

class NotificationItem {
  final String id;
  final SnNotification notification;
  final DateTime createdAt;
  final int index;
  final Duration duration;

  NotificationItem({
    String? id,
    required this.notification,
    DateTime? createdAt,
    required this.index,
    Duration? duration,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now(),
       duration =
           duration ?? kNotificationBaseDuration + Duration(seconds: index);

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
    final newItem = NotificationItem(
      notification: notification,
      index: state.length,
      duration: duration,
    );
    state = [...state, newItem];
  }

  void remove(String id) {
    state = state.where((item) => item.id != id).toList();
  }

  void clear() {
    state = [];
  }
}
