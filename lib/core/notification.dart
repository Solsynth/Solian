import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

part 'notification.g.dart';

const kNotificationBaseDuration = Duration(seconds: 5);
const kNotificationStackedDuration = Duration(seconds: 1);

class NotificationItem {
  final String id;
  final SnNotification notification;
  final DateTime createdAt;
  final int index;
  final Duration duration;
  final bool dismissed;

  NotificationItem({
    String? id,
    required this.notification,
    DateTime? createdAt,
    required this.index,
    Duration? duration,
    this.dismissed = false,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now(),
       duration =
           duration ?? kNotificationBaseDuration + Duration(seconds: index);

  NotificationItem copyWith({
    String? id,
    SnNotification? notification,
    DateTime? createdAt,
    int? index,
    Duration? duration,
    bool? dismissed,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      notification: notification ?? this.notification,
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
  final Map<String, Timer> _timers = {};

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
    _timers[newItem.id] = Timer(newItem.duration, () => dismiss(newItem.id));
  }

  void dismiss(String id) {
    _timers[id]?.cancel();
    _timers.remove(id);
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
    for (final timer in _timers.values) {
      timer.cancel();
    }
    _timers.clear();
    state = [];
  }
}
