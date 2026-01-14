import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:island/pods/config.dart';

final sfxPlayerProvider = Provider<AudioPlayer>((ref) {
  final player = AudioPlayer();
  ref.onDispose(() {
    player.dispose();
  });
  return player;
});

final notificationSfxProvider = FutureProvider<void>((ref) async {
  final player = ref.watch(sfxPlayerProvider);
  await player.setVolume(0.75);
  await player.setAudioSource(
    AudioSource.asset('assets/audio/notification.mp3'),
    preload: true,
  );
});

final messageSfxProvider = FutureProvider<void>((ref) async {
  final player = ref.watch(sfxPlayerProvider);
  await player.setAudioSource(
    AudioSource.asset('assets/audio/messages.mp3'),
    preload: true,
  );
});

void playNotificationSfx(WidgetRef ref) {
  final settings = ref.read(appSettingsProvider);
  if (!settings.soundEffects) return;
  final player = ref.read(sfxPlayerProvider);
  player.play();
}

void playMessageSfx(WidgetRef ref) {
  final settings = ref.read(appSettingsProvider);
  if (!settings.soundEffects) return;
  final player = ref.read(sfxPlayerProvider);
  player.play();
}
