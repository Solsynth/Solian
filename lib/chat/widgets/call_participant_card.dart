import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:island/chat/pods/call.dart';
import 'package:island/chat/pods/call_participants.dart';
import 'package:flutter_popup_card/flutter_popup_card.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/widgets/account/account_nameplate.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:styled_widget/styled_widget.dart';

class CallParticipantCard extends HookConsumerWidget {
  final CallParticipantLive live;
  const CallParticipantCard({super.key, required this.live});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = math
        .min(MediaQuery.of(context).size.width - 80, 360)
        .toDouble();
    ref.watch(callProvider);
    final callNotifier = ref.watch(callProvider.notifier);
    final participantAccount = ref.watch(
      callParticipantAccountProvider(live.participant.identity),
    );
    final isAdmin = callNotifier.isAdmin;
    final isLocalParticipant = live.remoteParticipant is LocalParticipant;
    final targetAccountId = participantAccount.value?.id;
    final canModerate =
        isAdmin &&
        !isLocalParticipant &&
        targetAccountId != null &&
        targetAccountId.isNotEmpty;
    final moderationLoading = useState(false);

    Future<void> handleMuteToggle() async {
      moderationLoading.value = true;
      try {
        if (live.remoteParticipant.isMuted) {
          await callNotifier.unmuteParticipantByAccountId(targetAccountId!);
          showSnackBar('Participant unmuted');
        } else {
          await callNotifier.muteParticipantByAccountId(targetAccountId!);
          showSnackBar('Participant muted');
        }
      } catch (err) {
        showErrorAlert(err);
      } finally {
        moderationLoading.value = false;
      }
    }

    Future<void> handleKickParticipant() async {
      final confirmed = await showConfirmAlert(
        'Remove this participant from the call?',
        'Kick participant',
        icon: Symbols.person_remove,
        isDanger: true,
      );
      if (!confirmed) return;

      moderationLoading.value = true;
      try {
        await callNotifier.kickParticipantByAccountId(targetAccountId!);
        showSnackBar('Participant removed');
      } catch (err) {
        showErrorAlert(err);
      } finally {
        moderationLoading.value = false;
      }
    }

    final volumeSliderValue = useState(callNotifier.getParticipantVolume(live));
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final qualityInfo = switch (live.remoteParticipant.connectionQuality) {
      ConnectionQuality.excellent => (
        Symbols.signal_cellular_alt,
        'Excellent',
        colorScheme.primary,
      ),
      ConnectionQuality.good => (
        Symbols.signal_cellular_alt_2_bar,
        'Good',
        colorScheme.secondary,
      ),
      ConnectionQuality.poor => (
        Symbols.signal_cellular_alt_1_bar,
        'Bad',
        colorScheme.error,
      ),
      ConnectionQuality.lost => (
        Symbols.signal_cellular_off,
        'Lost',
        colorScheme.error,
      ),
      _ => (
        Symbols.signal_cellular_null,
        'Connecting',
        colorScheme.onSurfaceVariant,
      ),
    };

    return PopupCard(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SizedBox(
        width: width,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (canModerate) ...[
                  Text(
                    'Moderation',
                    style: textTheme.labelMedium?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Gap(8),
                  Row(
                    children: [
                      IconButton.filledTonal(
                        onPressed: moderationLoading.value
                            ? null
                            : handleMuteToggle,
                        icon: Icon(
                          live.remoteParticipant.isMuted
                              ? Symbols.mic
                              : Symbols.mic_off,
                        ),
                        tooltip: live.remoteParticipant.isMuted
                            ? 'Unmute'
                            : 'Mute',
                      ),
                      const Gap(8),
                      IconButton.filledTonal(
                        onPressed: moderationLoading.value
                            ? null
                            : handleKickParticipant,
                        icon: const Icon(Symbols.person_remove),
                        tooltip: 'Remove',
                        style: IconButton.styleFrom(
                          foregroundColor: colorScheme.error,
                        ),
                      ),
                    ],
                  ),
                  const Gap(12),
                ],
                // Volume
                Text(
                  'Volume',
                  style: textTheme.labelMedium?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Gap(4),
                Row(
                  children: [
                    Icon(
                      Symbols.volume_up,
                      size: 20,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    Expanded(
                      child: Slider(
                        max: 2,
                        value: volumeSliderValue.value,
                        onChanged: (v) => volumeSliderValue.value = v,
                        onChangeEnd: (v) =>
                            callNotifier.setParticipantVolume(live, v),
                        year2023: true,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 44,
                      child: Text(
                        '${(volumeSliderValue.value * 100).toStringAsFixed(0)}%',
                        textAlign: TextAlign.end,
                        style: textTheme.labelLarge?.copyWith(
                          fontFeatures: [const FontFeature.tabularFigures()],
                        ),
                      ),
                    ),
                  ],
                ),
                const Gap(8),
                // Connection
                Row(
                  children: [
                    Icon(qualityInfo.$1, size: 20, color: qualityInfo.$3),
                    const Gap(8),
                    Text(
                      qualityInfo.$2,
                      style: textTheme.bodyMedium?.copyWith(
                        color: qualityInfo.$3,
                      ),
                    ),
                  ],
                ),
                const Gap(4),
                // Stats
                _CallParticipantStatsPanel(participant: live.remoteParticipant),
              ],
            ).padding(horizontal: 16, top: 16),
            AccountNameplate(
              name: live.participant.identity,
              isOutlined: false,
            ),
          ],
        ),
      ),
    );
  }
}

class _CallParticipantStatsPanel extends StatefulWidget {
  final Participant participant;
  const _CallParticipantStatsPanel({required this.participant});

  @override
  State<_CallParticipantStatsPanel> createState() =>
      _CallParticipantStatsPanelState();
}

class _CallParticipantStatsPanelState
    extends State<_CallParticipantStatsPanel> {
  final List<EventsListener<TrackEvent>> _listeners = [];
  Map<String, String> _audioStats = {};
  Map<String, String> _videoStats = {};

  double _audioTxKbps = 0;
  double _audioRxKbps = 0;
  double _videoTxKbps = 0;
  double _videoRxKbps = 0;

  @override
  void initState() {
    super.initState();
    widget.participant.addListener(_onParticipantChanged);
    _onParticipantChanged();
  }

  @override
  void didUpdateWidget(covariant _CallParticipantStatsPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.participant == widget.participant) return;
    oldWidget.participant.removeListener(_onParticipantChanged);
    widget.participant.addListener(_onParticipantChanged);
    _onParticipantChanged();
  }

  @override
  void dispose() {
    widget.participant.removeListener(_onParticipantChanged);
    _disposeTrackListeners();
    super.dispose();
  }

  void _disposeTrackListeners() {
    for (final listener in _listeners) {
      unawaited(listener.dispose());
    }
    _listeners.clear();
  }

  String _toKbps(num value) {
    if (value.isNaN || value.isInfinite) return '0 kbps';
    return '${value.toInt()} kbps';
  }

  void _onParticipantChanged() {
    _disposeTrackListeners();
    _audioStats = {};
    _videoStats = {};

    final tracks = [
      ...widget.participant.videoTrackPublications,
      ...widget.participant.audioTrackPublications,
    ];
    for (final publication in tracks) {
      final track = publication.track;
      if (track == null) continue;
      _setUpTrackListener(track);
    }

    if (mounted) {
      setState(() {});
    }
  }

  void _setUpTrackListener(Track track) {
    final listener = track.createListener();
    _listeners.add(listener);

    if (track is LocalVideoTrack) {
      listener.on<VideoSenderStatsEvent>((event) {
        if (!mounted) return;
        _videoTxKbps = event.currentBitrate.toDouble();
        final next = <String, String>{'tx': _toKbps(event.currentBitrate)};
        final firstStats =
            event.stats['f'] ?? event.stats['h'] ?? event.stats['q'];
        if (firstStats != null) {
          if (firstStats.mimeType != null) {
            next['codec'] =
                '${firstStats.mimeType!.split('/').last}/${firstStats.clockRate ?? '-'}';
          }
          next['size/fps'] =
              '${firstStats.frameWidth ?? '-'}x${firstStats.frameHeight ?? '-'} @ ${firstStats.framesPerSecond?.toStringAsFixed(1) ?? '-'}fps';
        }
        setState(() {
          _videoStats = next;
        });
      });
      return;
    }

    if (track is RemoteVideoTrack) {
      listener.on<VideoReceiverStatsEvent>((event) {
        if (!mounted) return;
        _videoRxKbps = event.currentBitrate.toDouble();
        final next = <String, String>{'rx': _toKbps(event.currentBitrate)};
        if (event.stats.mimeType != null) {
          next['codec'] =
              '${event.stats.mimeType!.split('/').last}/${event.stats.clockRate ?? '-'}';
        }
        next['size/fps'] =
            '${event.stats.frameWidth ?? '-'}x${event.stats.frameHeight ?? '-'} @ ${event.stats.framesPerSecond?.toStringAsFixed(1) ?? '-'}fps';
        next['jitter'] = '${event.stats.jitter?.toStringAsFixed(3) ?? '-'} s';
        next['frames dropped'] = '${event.stats.framesDropped ?? 0}';
        setState(() {
          _videoStats = next;
        });
      });
      return;
    }

    if (track is LocalAudioTrack) {
      listener.on<AudioSenderStatsEvent>((event) {
        if (!mounted) return;
        _audioTxKbps = event.currentBitrate.toDouble();
        final next = <String, String>{'tx': _toKbps(event.currentBitrate)};
        if (event.stats.mimeType != null) {
          next['codec'] =
              '${event.stats.mimeType!.split('/').last}/${event.stats.clockRate ?? '-'}/${event.stats.channels ?? '-'}ch';
        }
        setState(() {
          _audioStats = next;
        });
      });
      return;
    }

    if (track is RemoteAudioTrack) {
      listener.on<AudioReceiverStatsEvent>((event) {
        if (!mounted) return;
        _audioRxKbps = event.currentBitrate.toDouble();
        final next = <String, String>{'rx': _toKbps(event.currentBitrate)};
        if (event.stats.mimeType != null) {
          next['codec'] =
              '${event.stats.mimeType!.split('/').last}/${event.stats.clockRate ?? '-'}/${event.stats.channels ?? '-'}ch';
        }
        next['jitter'] = '${event.stats.jitter?.toStringAsFixed(3) ?? '-'} s';
        next['packets lost'] = '${event.stats.packetsLost ?? 0}';
        setState(() {
          _audioStats = next;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final labelStyle = textTheme.labelSmall;
    final valueStyle = textTheme.bodySmall?.copyWith(
      fontFamily: 'monospace',
      fontFeatures: [const FontFeature.tabularFigures()],
    );

    final totalTx = _audioTxKbps + _videoTxKbps;
    final totalRx = _audioRxKbps + _videoRxKbps;

    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: colorScheme.surfaceContainerHighest,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 180),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Stats',
                style: textTheme.labelMedium?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Gap(8),
              Row(
                children: [
                  Icon(
                    Symbols.upload,
                    size: 16,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const Gap(6),
                  Text('Up ${_toKbps(totalTx)}', style: valueStyle),
                  const Gap(16),
                  Icon(
                    Symbols.download,
                    size: 16,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const Gap(6),
                  Text('Down ${_toKbps(totalRx)}', style: valueStyle),
                ],
              ),
              if (_audioStats.isNotEmpty) ...[
                const Gap(10),
                Text('Audio', style: labelStyle),
                ..._audioStats.entries.map(
                  (e) => Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text('${e.key}: ${e.value}', style: valueStyle),
                  ),
                ),
              ],
              if (_videoStats.isNotEmpty) ...[
                const Gap(10),
                Text('Video', style: labelStyle),
                ..._videoStats.entries.map(
                  (e) => Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text('${e.key}: ${e.value}', style: valueStyle),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class CallParticipantRegion extends ConsumerWidget {
  final CallParticipantLive participant;
  final Widget child;
  const CallParticipantRegion({
    super.key,
    required this.participant,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      child: child,
      onTapDown: (details) {
        showCallParticipantCard(
          context,
          participant,
          offset: details.localPosition,
        );
      },
    );
  }
}

Future<void> showCallParticipantCard(
  BuildContext context,
  CallParticipantLive participant, {
  Offset? offset,
}) async {
  await showPopupCard<void>(
    offset: offset ?? Offset.zero,
    context: context,
    builder: (popupContext) => CallParticipantCard(live: participant),
    alignment: Alignment.center,
    dimBackground: true,
  );
}
