import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:island/core/config.dart';
import 'package:audio_session/audio_session.dart';

final callInviteLoopPlayerProvider = Provider<AudioPlayer>((ref) {
  final player = AudioPlayer();
  ref.onDispose(() {
    player.dispose();
  });
  return player;
});

Future<void> _configureAudioSession() async {
  final session = await AudioSession.instance;
  if (Platform.isIOS) {
    // Let CallKit/LiveKit own the iOS audio session during calls.
    // A startup-wide playback session can override CallKit's voiceChat routing
    // after accepting from the lock screen, which leaves media connected but silent.
    await session.configure(
      const AudioSessionConfiguration(
        avAudioSessionCategory: AVAudioSessionCategory.ambient,
        avAudioSessionCategoryOptions:
            AVAudioSessionCategoryOptions.mixWithOthers,
      ),
    );
    return;
  }
  await session.configure(const AudioSessionConfiguration.music());
  await session.setActive(true);
}

final audioSessionProvider = FutureProvider<void>((ref) async {
  await _configureAudioSession();
});

Future<void> _playSfx(String assetPath, double volume) async {
  final player = AudioPlayer();
  try {
    await player.setVolume(volume);
    // This is the problematic line that sometimes throws -11849
    // We handle PlayerInterruptedException gracefully as it's expected
    // when multiple SFX are triggered in rapid succession
    await player.setAudioSource(AudioSource.asset(assetPath));
    // Do NOT await play(): on iOS its future can hang forever when the
    // audio session cannot activate (e.g. a CallKit call owns it), which
    // would leak this player. Play fire-and-forget and wait for natural
    // completion instead, with a timeout as a backstop.
    unawaited(player.play().catchError((Object _) {}));
    await player.processingStateStream
        .firstWhere((state) => state == ProcessingState.completed)
        .timeout(const Duration(seconds: 10));
  } on TimeoutException {
    // Playback did not finish in time (session unavailable, etc.).
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
  _playSfx('assets/audio/notification.wav', 0.75);
}

void playMessageSfx(WidgetRef ref) {
  final settings = ref.read(appSettingsProvider);
  if (!settings.soundEffects) return;
  _playSfx('assets/audio/messages.wav', 0.75);
}

void playMessageSfxRef(Ref ref) {
  final settings = ref.read(appSettingsProvider);
  if (!settings.soundEffects) return;
  _playSfx('assets/audio/messages.wav', 0.75);
}

/// Plays the incoming-call ringtone exactly once.
///
/// Fire-and-forget: the caller must NOT await this before presenting UI.
/// On iOS the play() future can hang indefinitely while a CallKit session
/// owns the audio session, and under LoopMode.one it never completes until
/// the player is stopped — both would block the incoming-call sheet.
void playCallInvitedSfx(WidgetRef ref) {
  final settings = ref.read(appSettingsProvider);
  if (!settings.soundEffects || (!kIsWeb && Platform.isIOS)) return;

  final player = ref.read(callInviteLoopPlayerProvider);
  unawaited(() async {
    try {
      await player.stop();
      await player.setVolume(0.75);
      // Default LoopMode.off: the ringtone plays once and completes.
      await player.setAudioSource(
        AudioSource.asset('assets/audio/call_invited.wav'),
      );
      await player.play();
    } on PlayerInterruptedException catch (_) {
      // Another ringtone started (or the sheet closed) — stop is handled
      // by the caller.
      await player.stop();
    } on PlayerException catch (e) {
      if (e.code != -11849) rethrow;
    }
  }());
}

Future<void> stopCallInvitedSfx(WidgetRef ref) async {
  final player = ref.read(callInviteLoopPlayerProvider);
  try {
    await player.stop();
  } catch (_) {
    // ponytail: ignore stop races when the sheet closes as timeout fires
  }
}
