import 'dart:async';
import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/chat/widgets/chat_message_reaction_sheet.dart';
import 'package:island/chat/e2ee_message_display.dart';
import 'package:gap/gap.dart';
import 'package:island/chat/pods/call.dart';
import 'package:island/core/config.dart';
import 'package:island/core/network.dart';
import 'package:island/shared/widgets/content/markdown.dart';
import 'package:just_audio/just_audio.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:pretty_diff_text/pretty_diff_text.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

double _parsePlaceholderProgress(dynamic value) {
  if (value is num) return value.toDouble().clamp(0.0, 1.0);
  if (value is String) {
    return (double.tryParse(value) ?? 0).clamp(0.0, 1.0);
  }
  return 0;
}

class MessageContent extends StatelessWidget {
  final SnChatMessage item;
  final String? translatedText;
  final bool isSelectable;

  const MessageContent({
    super.key,
    required this.item,
    this.translatedText,
    this.isSelectable = true,
  });

  @override
  Widget build(BuildContext context) {
    final resolved = resolveE2eeDisplayContentForMessage(item);
    final resolvedContent = resolved.content;
    if (item.type.startsWith('system.')) {
      final (icon, text) = _buildSystemMessageSummary(item);
      return Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 16,
            color: Theme.of(
              context,
            ).colorScheme.onSurfaceVariant.withOpacity(0.7),
          ),
          const Gap(6),
          Flexible(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurfaceVariant.withOpacity(0.7),
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      );
    }

    if (item.type == 'messages.delete' || item.deletedAt != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Symbols.delete,
            size: 16,
            color: Theme.of(
              context,
            ).colorScheme.onSurfaceVariant.withOpacity(0.6),
          ),
          const Gap(4),
          Text(
            item.content ?? 'Deleted a message',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontSize: 13,
              color: Theme.of(
                context,
              ).colorScheme.onSurfaceVariant.withOpacity(0.6),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      );
    }

    switch (item.type) {
      case 'call.start':
      case 'call.ended':
        return _MessageContentCall(
          isEnded: item.type == 'call.ended',
          duration: item.meta['duration']?.toDouble(),
        );
      case 'messages.update':
        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Symbols.edit,
              size: 16,
              color: Theme.of(
                context,
              ).colorScheme.onSurfaceVariant.withOpacity(0.6),
            ),
            const Gap(4),
            if (item.meta['previous_content'] is String)
              Flexible(
                child: PrettyDiffText(
                  oldText: item.meta['previous_content'],
                  newText: item.content ?? 'messageUpdateEdited'.tr(),
                  defaultTextStyle: Theme.of(context).textTheme.bodyMedium!
                      .copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                  addedTextStyle: TextStyle(
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.primaryFixedDim.withOpacity(0.4),
                  ),
                  deletedTextStyle: TextStyle(
                    decoration: TextDecoration.lineThrough,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurfaceVariant.withOpacity(0.7),
                  ),
                ),
              )
            else
              Text(
                item.content ?? 'Edited a message',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurfaceVariant.withOpacity(0.6),
                ),
              ),
          ],
        );
      case 'messages.reaction.added':
      case 'messages.reaction.removed':
        final symbol =
            item.meta['symbol']?.toString() ??
            (item.meta['reaction'] is Map
                ? (item.meta['reaction'] as Map)['symbol']?.toString()
                : null);
        final isAdded = item.type == 'messages.reaction.added';
        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              isAdded ? Symbols.add_reaction : Symbols.do_not_disturb_on,
              size: 16,
              color: Theme.of(
                context,
              ).colorScheme.onSurfaceVariant.withOpacity(0.7),
            ),
            const Gap(6),
            if (symbol != null && symbol.isNotEmpty)
              buildReactionIcon(symbol, 18, iconSize: 14),
            if (symbol != null && symbol.isNotEmpty) const Gap(6),
            Text(
              symbol == null || symbol.isEmpty
                  ? (isAdded ? 'Added a reaction' : 'Removed a reaction')
                  : (isAdded
                        ? 'Reacted with $symbol'
                        : 'Removed reaction $symbol'),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurfaceVariant.withOpacity(0.7),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        );
      case 'messages.pinned':
      case 'messages.unpinned':
        final isPinned = item.type == 'messages.pinned';
        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              isPinned ? Symbols.push_pin : Icons.push_pin_outlined,
              size: 16,
              color: Theme.of(
                context,
              ).colorScheme.onSurfaceVariant.withOpacity(0.7),
            ),
            const Gap(6),
            Flexible(
              child: Text(
                isPinned ? 'Pinned a message' : 'Unpinned a message',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurfaceVariant.withOpacity(0.7),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        );
      case 'voice':
        return _VoiceMessageContent(item: item);
      case 'placeholder':
        return _PlaceholderMessageContent(item: item);
      case 'text':
      default:
        if (resolved.isEncrypted && resolved.decryptFailed) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Symbols.lock_open_right,
                size: 16,
                color: Theme.of(context).colorScheme.error.withOpacity(0.9),
              ),
              const Gap(6),
              Text(
                'Unable to decrypt this message.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.error.withOpacity(0.9),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          );
        }
        if (resolved.isEncrypted && resolved.emptyAfterDecrypt) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Symbols.lock_open_right,
                size: 16,
                color: Theme.of(
                  context,
                ).colorScheme.onSurfaceVariant.withOpacity(0.8),
              ),
              const Gap(6),
              Text(
                'Encrypted message has no text content.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurfaceVariant.withOpacity(0.8),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          );
        }
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(
              child: MouseRegion(
                cursor: SystemMouseCursors.text,
                child: MarkdownTextContent(
                  content: resolvedContent ?? '*${item.type} has no content*',
                  isSelectable: isSelectable,
                  linesMargin: EdgeInsets.zero,
                ),
              ),
            ),
            if (translatedText?.isNotEmpty ?? false)
              ...([
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: math.min(
                      280,
                      MediaQuery.of(context).size.width * 0.4,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('translated').tr().fontSize(11).opacity(0.75),
                      const Gap(8),
                      Flexible(child: Divider()),
                    ],
                  ).padding(vertical: 4),
                ),
                MouseRegion(
                  cursor: SystemMouseCursors.text,
                  child: MarkdownTextContent(
                    content: translatedText!,
                    isSelectable: isSelectable,
                    linesMargin: EdgeInsets.zero,
                  ),
                ),
              ]),
          ],
        );
    }
  }

  static bool hasContent(SnChatMessage item) {
    if (item.type == 'messages.sync.finalize' ||
        item.type == 'messages.sync.links') {
      return false;
    }
    final resolved = resolveE2eeDisplayContentForMessage(item);
    return item.type != 'text' ||
        (resolved.content?.isNotEmpty ?? false) ||
        resolved.decryptFailed ||
        resolved.emptyAfterDecrypt;
  }

  (IconData, String) _buildSystemMessageSummary(SnChatMessage item) {
    final reason = item.meta['reason']?.toString();
    final isRemoved = reason == 'removed';
    final timeoutUntilRaw =
        item.meta['timeout_until'] ??
        item.meta['timeoutUntil'] ??
        item.meta['until'];
    final targetName =
        item.meta['member_nick']?.toString() ??
        item.meta['member_name']?.toString() ??
        item.meta['target_nick']?.toString() ??
        item.meta['target_name']?.toString() ??
        item.meta['display_name']?.toString();
    final timeoutUntil = switch (timeoutUntilRaw) {
      DateTime value => value,
      String value => DateTime.tryParse(value),
      _ => null,
    };

    switch (item.type) {
      case 'system.member.joined':
        return (Symbols.group_add, item.content ?? 'A member joined the chat');
      case 'system.member.left':
        return (
          isRemoved ? Symbols.person_remove : Symbols.logout,
          item.content ??
              (isRemoved ? 'A member was removed' : 'A member left'),
        );
      case 'system.chat.updated':
        return (Symbols.edit_note, item.content ?? 'Chat info updated');
      case 'system.e2ee.enabled':
        return (Symbols.lock, item.content ?? 'This chat now uses E2EE');
      case 'system.e2ee.rotate_required':
        return (
          Symbols.key_vertical,
          item.content ?? 'E2EE sender key rotation required',
        );
      case 'system.e2ee.history_unavailable':
        return (
          Symbols.history,
          item.content ?? 'Message history is no longer available',
        );
      case 'system.call.member.joined':
        return (
          Symbols.phone_in_talk,
          item.content ?? 'A member joined the call',
        );
      case 'system.call.member.left':
        return (
          isRemoved ? Symbols.call_end : Symbols.logout,
          item.content ??
              (isRemoved
                  ? 'A member was removed from the call'
                  : 'A member left the call'),
        );
      case 'system.member.timed_out':
        return (
          Symbols.timer_pause,
          item.content ??
              switch ((targetName, timeoutUntil)) {
                (final name?, final until?) =>
                  '$name was timed out until ${DateFormat('yyyy-MM-dd HH:mm').format(until.toLocal())}',
                (null, final until?) =>
                  'A member was timed out until ${DateFormat('yyyy-MM-dd HH:mm').format(until.toLocal())}',
                (final name?, null) => '$name was timed out',
                _ => 'A member was timed out',
              },
        );
      case 'system.member.timeout_removed':
        return (
          Symbols.timer_off,
          item.content ??
              (targetName != null
                  ? '$targetName can chat again'
                  : 'A member timeout was removed'),
        );
      default:
        return (Symbols.info_rounded, item.content ?? 'System message');
    }
  }
}

class _VoiceMessageContent extends HookConsumerWidget {
  final SnChatMessage item;
  const _VoiceMessageContent({required this.item});

  String _formatSeconds(Duration duration) {
    final totalSeconds = (duration.inMilliseconds / 1000).floor().clamp(
      0,
      99999,
    );
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final serverUrl = ref.watch(serverUrlProvider);
    final token = ref.watch(tokenProvider);
    final player = useMemoized(() => AudioPlayer(), []);
    final isLoading = useState(false);
    final loaded = useState(false);
    final isScrubbing = useState(false);
    final scrubPosition = useState(Duration.zero);
    final waveformBars = useState<List<double>?>(null);
    final waveformSource = useState<String?>(null);

    useEffect(() {
      return () => player.dispose();
    }, [player]);

    final durationMs = (() {
      final raw = item.meta['duration_ms'];
      if (raw is int) return raw;
      return int.tryParse(raw?.toString() ?? '');
    })();
    final voiceUrl = item.meta['voice_url']?.toString();
    final mediaUrl = voiceUrl == null
        ? null
        : (voiceUrl.startsWith('http') ? voiceUrl : '$serverUrl$voiceUrl');
    final position =
        useStream(player.positionStream, initialData: Duration.zero).data ??
        Duration.zero;
    final total =
        useStream(
          player.durationStream,
          initialData: Duration(milliseconds: durationMs ?? 0),
        ).data ??
        Duration(milliseconds: durationMs ?? 0);
    final playerState = useStream(player.playerStateStream).data;
    final isPlaying = playerState?.playing ?? false;
    final isCompleted =
        playerState?.processingState == ProcessingState.completed;
    final shownPosition = isScrubbing.value ? scrubPosition.value : position;
    final totalMs = total.inMilliseconds <= 0
        ? 1.0
        : total.inMilliseconds.toDouble();

    Future<void> generateWaveform(dynamic file) async {
      final path = file.path?.toString();
      if (path == null || path.isEmpty || waveformSource.value == path) return;
      waveformSource.value = path;

      try {
        final bytes = await file.readAsBytes();
        if (bytes.isEmpty) return;

        const barCount = 64;
        final bars = <double>[];
        final window = (bytes.length / barCount).ceil();
        const startOffset = 1024;

        for (var i = 0; i < barCount; i++) {
          final start = math.min(startOffset + (i * window), bytes.length);
          final end = math.min(start + window, bytes.length);
          if (start >= end) {
            bars.add(0.12);
            continue;
          }

          var sum = 0.0;
          var samples = 0;
          for (var j = start; j < end; j += 8) {
            sum += (bytes[j] - 128).abs().toDouble();
            samples++;
          }

          final normalized = samples == 0
              ? 0.12
              : math.sqrt((sum / samples) / 128.0);
          bars.add(normalized.clamp(0.12, 1.0));
        }

        waveformBars.value = bars;
      } catch (_) {}
    }

    Future<void> ensureLoaded() async {
      if (loaded.value || mediaUrl == null) return;
      isLoading.value = true;
      try {
        final headers = token == null
            ? null
            : {'Authorization': 'Bearer ${token.token}'};
        final cachedFile = await DefaultCacheManager().getFileFromCache(
          mediaUrl,
        );
        if (cachedFile != null) {
          unawaited(generateWaveform(cachedFile.file));
          await player.setFilePath(cachedFile.file.path);
        } else {
          final download = DefaultCacheManager().downloadFile(
            mediaUrl,
            authHeaders: headers,
          );
          unawaited(
            download.then((downloaded) {
              unawaited(generateWaveform(downloaded.file));
            }),
          );
          await player.setUrl(mediaUrl, headers: headers);
        }
        loaded.value = true;
      } finally {
        isLoading.value = false;
      }
    }

    useEffect(() {
      if (mediaUrl == null) return null;
      unawaited(() async {
        final cachedFile = await DefaultCacheManager().getFileFromCache(
          mediaUrl,
        );
        if (cachedFile != null) {
          await generateWaveform(cachedFile.file);
          return;
        }
        final headers = token == null
            ? null
            : {'Authorization': 'Bearer ${token.token}'};
        try {
          final downloaded = await DefaultCacheManager().downloadFile(
            mediaUrl,
            authHeaders: headers,
          );
          await generateWaveform(downloaded.file);
        } catch (_) {}
      }());
      return null;
    }, [mediaUrl, token?.token]);

    return Container(
      constraints: const BoxConstraints(maxWidth: 320),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          IconButton(
            visualDensity: VisualDensity.compact,
            icon: Icon(
              isPlaying ? Symbols.pause_circle : Symbols.play_circle,
              size: 22,
            ),
            onPressed: mediaUrl == null || isLoading.value
                ? null
                : () async {
                    await ensureLoaded();
                    if (isPlaying) {
                      await player.pause();
                    } else {
                      final replayFromStart =
                          isCompleted ||
                          (total.inMilliseconds > 0 &&
                              position >=
                                  total - const Duration(milliseconds: 250));
                      if (replayFromStart) {
                        await player.seek(Duration.zero);
                      }
                      await player.play();
                    }
                  },
          ),
          Expanded(
            child: Row(
              children: [
                SizedBox(
                  height: 28,
                  width: 180,
                  child: _VoiceWaveformProgress(
                    bars: waveformBars.value,
                    progress: (shownPosition.inMilliseconds / totalMs).clamp(
                      0.0,
                      1.0,
                    ),
                    onSeekStart: mediaUrl == null
                        ? null
                        : (ratio) {
                            isScrubbing.value = true;
                            scrubPosition.value = Duration(
                              milliseconds: (ratio.clamp(0.0, 1.0) * totalMs)
                                  .toInt(),
                            );
                          },
                    onSeekUpdate: mediaUrl == null
                        ? null
                        : (ratio) {
                            isScrubbing.value = true;
                            scrubPosition.value = Duration(
                              milliseconds: (ratio.clamp(0.0, 1.0) * totalMs)
                                  .toInt(),
                            );
                          },
                    onSeekEnd: mediaUrl == null
                        ? null
                        : () async {
                            await ensureLoaded();
                            await player.seek(scrubPosition.value);
                            isScrubbing.value = false;
                          },
                  ),
                ),
                const Gap(8),
                Flexible(
                  flex: 1,
                  child: Text(
                    '${_formatSeconds(shownPosition)} / ${_formatSeconds(total)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 11,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (isLoading.value) ...[
            const Gap(6),
            SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _VoiceWaveformProgress extends StatelessWidget {
  final List<double>? bars;
  final double progress;
  final ValueChanged<double>? onSeekStart;
  final ValueChanged<double>? onSeekUpdate;
  final Future<void> Function()? onSeekEnd;

  const _VoiceWaveformProgress({
    required this.bars,
    required this.progress,
    this.onSeekStart,
    this.onSeekUpdate,
    this.onSeekEnd,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final waveform = bars;

    if (waveform == null || waveform.isEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: LinearProgressIndicator(
          value: progress.clamp(0.0, 1.0),
          minHeight: 4,
          color: colorScheme.primary,
          backgroundColor: colorScheme.surfaceContainerHighest,
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final barCount = waveform.length;
        const spacing = 1.0;
        final barWidth =
            ((constraints.maxWidth - (barCount - 1) * spacing) / barCount)
                .clamp(1.5, 3.2);
        final playedBars = progress.clamp(0.0, 1.0) * barCount;

        double ratioFromDx(double dx) {
          if (constraints.maxWidth <= 0) return 0;
          return (dx / constraints.maxWidth).clamp(0.0, 1.0);
        }

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: onSeekUpdate == null
              ? null
              : (details) {
                  onSeekUpdate!(ratioFromDx(details.localPosition.dx));
                  if (onSeekEnd != null) unawaited(onSeekEnd!());
                },
          onHorizontalDragStart: onSeekStart == null
              ? null
              : (details) =>
                    onSeekStart!(ratioFromDx(details.localPosition.dx)),
          onHorizontalDragUpdate: onSeekUpdate == null
              ? null
              : (details) =>
                    onSeekUpdate!(ratioFromDx(details.localPosition.dx)),
          onHorizontalDragEnd: onSeekEnd == null
              ? null
              : (_) => unawaited(onSeekEnd!()),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: List.generate(barCount, (index) {
                final normalized = waveform[index].clamp(0.12, 1.0);
                final height = 5 + (normalized * 15);
                final fill = (playedBars - index).clamp(0.0, 1.0);
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 120),
                  curve: Curves.easeOutCubic,
                  width: barWidth,
                  height: height,
                  margin: EdgeInsets.only(
                    right: index == barCount - 1 ? 0 : spacing,
                  ),
                  decoration: BoxDecoration(
                    color: Color.lerp(
                      colorScheme.surfaceContainerHighest,
                      colorScheme.primary,
                      fill,
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                );
              }),
            ),
          ),
        );
      },
    );
  }
}

class _MessageContentCall extends StatelessWidget {
  final bool isEnded;
  final double? duration;

  const _MessageContentCall({required this.isEnded, this.duration});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          isEnded ? Symbols.call_end : Symbols.phone_in_talk,
          size: 16,
          color: Theme.of(context).colorScheme.primary,
        ),
        Gap(4),
        Text(
          isEnded
              ? 'Call ended after ${formatDuration(Duration(seconds: duration!.toInt()))}'
              : 'Call started',
          style: TextStyle(color: Theme.of(context).colorScheme.primary),
        ),
      ],
    );
  }
}

class _PlaceholderMessageContent extends StatelessWidget {
  final SnChatMessage item;

  const _PlaceholderMessageContent({required this.item});

  @override
  Widget build(BuildContext context) {
    final kind = item.meta['placeholder_kind']?.toString();
    final colorScheme = Theme.of(context).colorScheme;

    if (kind == 'streaming') {
      final content = item.meta['placeholder_content']?.toString() ?? '';
      return Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox.square(
            dimension: 14,
            child: Theme(
              data: Theme.of(context).copyWith(
                progressIndicatorTheme: const ProgressIndicatorThemeData(
                  circularTrackPadding: EdgeInsets.zero,
                ),
              ),
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: colorScheme.primary.withOpacity(0.7),
              ),
            ),
          ),
          Flexible(
            child: Text(
              content.isNotEmpty ? content : 'chatPlaceholderStreaming'.tr(),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant.withOpacity(0.8),
              ),
            ),
          ),
        ],
      );
    }

    if (kind == 'uploading') {
      final progress = _parsePlaceholderProgress(
        item.meta['placeholder_progress'],
      );
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox.square(
                dimension: 14,
                child: Theme(
                  data: Theme.of(context).copyWith(
                    progressIndicatorTheme: const ProgressIndicatorThemeData(
                      circularTrackPadding: EdgeInsets.zero,
                    ),
                  ),
                  child: CircularProgressIndicator(
                    value: progress > 0 ? progress : null,
                    strokeWidth: 2,
                    color: colorScheme.primary.withOpacity(0.7),
                  ),
                ),
              ),
              const Gap(8),
              Text(
                'chatPlaceholderUploading'.tr(
                  args: ['${(progress * 100).toInt()}%'],
                ),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant.withOpacity(0.8),
                ),
              ),
            ],
          ),
          if (progress > 0) ...[
            const Gap(6),
            SizedBox(
              width: 180,
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 3,
                borderRadius: BorderRadius.circular(2),
                color: colorScheme.primary,
                backgroundColor: colorScheme.surfaceContainerHighest,
              ),
            ),
          ],
        ],
      );
    }

    // Fallback for unknown placeholder kind
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox.square(
          dimension: 14,
          child: Theme(
            data: Theme.of(context).copyWith(
              progressIndicatorTheme: const ProgressIndicatorThemeData(
                circularTrackPadding: EdgeInsets.zero,
              ),
            ),
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: colorScheme.primary.withOpacity(0.7),
            ),
          ),
        ),
        Text(
          'Processing...',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant.withOpacity(0.6),
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }
}
