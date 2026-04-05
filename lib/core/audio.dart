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
  try {
    await player.setVolume(volume);
    // This is the problematic line that sometimes throws -11849
    // We handle PlayerInterruptedException gracefully as it's expected
    // when multiple SFX are triggered in rapid succession
    await player.setAudioSource(AudioSource.asset(assetPath));
    await player.play();
  } on PlayerInterruptedException catch (_) {
    // This is normal and expected when:
    // 1. Audio source is loading but player gets disposed
    // 2. Another audio source loads before this one completes
    // No action needed - just clean up silently
  } on PlayerException catch (e) {
    // Only log actual errors, not interruption cases
    if (e.code != -11849) {
      // Ignore the "Operation Stopped" case which is same as above
      rethrow;
    }
  } finally {
    // Always ensure player is disposed even if loading was interrupted
    await player.dispose();
  }
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
