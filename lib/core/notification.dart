import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';
import 'package:island/core/config.dart';

part 'notification.g.dart';

Future<void> speakNotification(
  SnNotification notification, {
  String? voice,
  double speechRate = 1.0,
  double pitch = 1.0,
  double volume = 1.0,
  String language = 'en-US',
}) async {
  final tts = FlutterTts();
  await tts.setVolume(volume);
  await tts.setSpeechRate(speechRate);
  await tts.setPitch(pitch);
  await tts.setLanguage(language);
  if (voice != null && voice.isNotEmpty) {
    await tts.setVoice({'name': voice, 'locale': language});
  }
  if (!kIsWeb) {
    await tts.setIosAudioCategory(IosTextToSpeechAudioCategory.ambient, [
      IosTextToSpeechAudioCategoryOptions.allowBluetooth,
      IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
      IosTextToSpeechAudioCategoryOptions.mixWithOthers,
    ], IosTextToSpeechAudioMode.voicePrompt);
  }
  final parts = <String>[];
  if (notification.title.isNotEmpty) parts.add(notification.title);
  if (notification.subtitle.isNotEmpty) parts.add(notification.subtitle);
  if (notification.content.isNotEmpty) parts.add(notification.content);

  if (parts.isNotEmpty) {
    await tts.speak(parts.join('. '));
  }
}

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

  Future<void> _speakNotification(SnNotification notification) async {
    final settings = ref.read(appSettingsProvider);
    if (!settings.enableTts) return;
    await speakNotification(
      notification,
      voice: settings.ttsVoice,
      speechRate: settings.ttsSpeechRate,
      pitch: settings.ttsPitch,
      volume: settings.ttsVolume,
      language: settings.ttsLanguage,
    );
  }

  void add(SnNotification notification, {Duration? duration}) {
    final newItem = NotificationItem(
      notification: notification,
      index: state.length,
      duration: duration,
    );
    state = [...state, newItem];
    _timers[newItem.id] = Timer(newItem.duration, () => dismiss(newItem.id));
    _speakNotification(notification);
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
