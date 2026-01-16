import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:island/pods/config.dart';
import 'package:audio_session/audio_session.dart';
import 'package:dart_midi_pro/dart_midi_pro.dart';

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

class MiniSampleSynth {
  final String sampleAsset;
  final int baseNote; // MIDI note of the sample (usually 72 = C5 for lower pitch playback)

  AudioPlayer? currentPlayer;

  MiniSampleSynth({required this.sampleAsset, this.baseNote = 72});

  Future<void> playMidiAsset(String midiAsset) async {
    final data = await rootBundle.load(midiAsset);
    final midi = MidiParser().parseMidiFromBuffer(data.buffer.asUint8List());

    for (final track in midi.tracks) {
      int currentTick = 0;

      for (final event in track) {
        currentTick += event.deltaTime;

        if (event is NoteOnEvent && event.velocity > 0) {
          final note = event.noteNumber;
          final durationTicks = _estimateDuration(track, event);
          final durationMs = _ticksToMs(durationTicks, midi);

          _scheduleNote(
            note: note,
            startMs: _ticksToMs(currentTick, midi),
            durationMs: durationMs,
          );
        }
      }
    }
  }

  void _scheduleNote({
    required int note,
    required int startMs,
    required int durationMs,
  }) {
    Future.delayed(Duration(milliseconds: startMs), () async {
      // Stop any currently playing note
      if (currentPlayer != null) {
        await currentPlayer!.stop();
        await currentPlayer!.dispose();
        currentPlayer = null;
      }

      final player = AudioPlayer();
      currentPlayer = player;

      await player.setAudioSource(AudioSource.asset(sampleAsset));
      final speed = _noteToSpeed(note);
      await player.setSpeed(speed);
      await player.play();

      Future.delayed(Duration(milliseconds: durationMs), () async {
        if (currentPlayer == player) {
          await player.stop();
          await player.dispose();
          currentPlayer = null;
        }
      });
    });
  }

  double _noteToSpeed(int note) {
    return math.pow(2, (note - baseNote) / 12).toDouble();
  }

  int _getTempo(MidiFile midi) {
    for (var track in midi.tracks) {
      for (var event in track) {
        if (event is SetTempoEvent) {
          return event.microsecondsPerBeat;
        }
      }
    }
    return 500000; // default 120 BPM
  }

  int _ticksToMs(int ticks, MidiFile midi) {
    final tempo = _getTempo(midi);
    final ticksPerBeat = midi.header.ticksPerBeat ?? 480;

    return ((ticks * tempo) / ticksPerBeat / 1000).round();
  }

  int _estimateDuration(List<MidiEvent> track, NoteOnEvent on) {
    int ticks = 0;
    bool started = false;

    for (final e in track) {
      if (e == on) {
        started = true;
        continue;
      }
      if (!started) continue;

      ticks += e.deltaTime;

      if (e is NoteOffEvent && e.noteNumber == on.noteNumber) {
        return ticks;
      }
    }
    return 200; // fallback
  }
}