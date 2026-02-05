import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:island/core/config.dart';
import 'package:audio_session/audio_session.dart';

final sfxPlayerProvider = Provider<AudioPlayer>((ref) {
  final player = AudioPlayer();
  ref.onDispose(() {
    player.dispose();
  });
  return player;
});

Future<void> _configureAudioSession() async {
  final session = await AudioSession.instance;
  await session.configure(
    const AudioSessionConfiguration(
      avAudioSessionCategory: AVAudioSessionCategory.playback,
      avAudioSessionCategoryOptions:
          AVAudioSessionCategoryOptions.mixWithOthers,
    ),
  );
  await session.setActive(true);
}

final audioSessionProvider = FutureProvider<void>((ref) async {
  await _configureAudioSession();
});

final notificationSfxProvider = FutureProvider<void>((ref) async {
  final player = ref.watch(sfxPlayerProvider);
  await player.setVolume(0.75);
  await player.setAudioSource(
    AudioSource.asset('assets/audio/notification.wav'),
    preload: true,
  );
});

final messageSfxProvider = FutureProvider<void>((ref) async {
  final player = ref.watch(sfxPlayerProvider);
  await player.setAudioSource(
    AudioSource.asset('assets/audio/messages.wav'),
    preload: true,
  );
});

Future<void> _playSfx(String assetPath, double volume) async {
  final player = AudioPlayer();
  await player.setVolume(volume);
  await player.setAudioSource(AudioSource.asset(assetPath));
  await player.play();
  await player.dispose();
}

void playNotificationSfx(WidgetRef ref) {
  final settings = ref.read(appSettingsProvider);
  if (!settings.soundEffects) return;
  _playSfx('assets/audio/notification.mp3', 0.75);
}

void playMessageSfx(WidgetRef ref) {
  final settings = ref.read(appSettingsProvider);
  if (!settings.soundEffects) return;
  _playSfx('assets/audio/messages.mp3', 0.75);
}
