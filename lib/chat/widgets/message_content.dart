import 'dart:async';
import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/chat/widgets/chat_message_reaction_sheet.dart';
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
      case 'messages.update.links':
        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              item.type == 'messages.update.links'
                  ? Symbols.link
                  : Symbols.edit,
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
                  newText:
                      item.content ??
                      (item.type == 'messages.update.links'
                          ? 'messageUpdateLinks'.tr()
                          : 'messageUpdateEdited'.tr()),
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
      case 'voice':
        return _VoiceMessageContent(item: item);
      case 'text':
      default:
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(
              child: MouseRegion(
                cursor: SystemMouseCursors.text,
                child: MarkdownTextContent(
                  content: item.content ?? '*${item.type} has no content*',
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
    return item.type != 'text' || (item.content?.isNotEmpty ?? false);
  }

  (IconData, String) _buildSystemMessageSummary(SnChatMessage item) {
    final reason = item.meta['reason']?.toString();
    final isRemoved = reason == 'removed';

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
      default:
        return (Symbols.info_rounded, item.content ?? 'System message');
    }
  }
}

class _VoiceMessageContent extends HookConsumerWidget {
  final SnChatMessage item;
  const _VoiceMessageContent({required this.item});

  String _formatSeconds(Duration duration) {
    final seconds = (duration.inMilliseconds / 1000).floor();
    return '${seconds.clamp(0, 99999)}s';
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
    final buffered =
        useStream(
          player.bufferedPositionStream,
          initialData: Duration.zero,
        ).data ??
        Duration.zero;
    final shownPosition = isScrubbing.value ? scrubPosition.value : position;
    final totalMs = total.inMilliseconds <= 0
        ? 1.0
        : total.inMilliseconds.toDouble();

    Future<void> ensureLoaded() async {
      if (loaded.value || mediaUrl == null) return;
      isLoading.value = true;
      try {
        final headers = token == null
            ? null
            : {'Authorization': 'AtField ${token.token}'};
        final cachedFile = await DefaultCacheManager().getFileFromCache(
          mediaUrl,
        );
        if (cachedFile != null) {
          await player.setFilePath(cachedFile.file.path);
        } else {
          unawaited(
            DefaultCacheManager().downloadFile(mediaUrl, authHeaders: headers),
          );
          await player.setUrl(mediaUrl, headers: headers);
        }
        loaded.value = true;
      } finally {
        isLoading.value = false;
      }
    }

    return Container(
      constraints: const BoxConstraints(maxWidth: 320),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          IconButton(
            visualDensity: VisualDensity.compact,
            icon: Icon(
              isPlaying ? Symbols.pause_circle : Symbols.play_circle,
              size: 24,
            ),
            onPressed: mediaUrl == null || isLoading.value
                ? null
                : () async {
                    await ensureLoaded();
                    if (isPlaying) {
                      await player.pause();
                    } else {
                      await player.play();
                    }
                  },
          ),
          Expanded(
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 2,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
              ),
              child: Slider(
                value: shownPosition.inMilliseconds
                    .clamp(0, totalMs.toInt())
                    .toDouble(),
                secondaryTrackValue: buffered.inMilliseconds
                    .clamp(0, totalMs.toInt())
                    .toDouble(),
                max: totalMs,
                onChangeStart: mediaUrl == null
                    ? null
                    : (value) {
                        isScrubbing.value = true;
                        scrubPosition.value = Duration(
                          milliseconds: value.toInt(),
                        );
                      },
                onChanged: mediaUrl == null
                    ? null
                    : (value) {
                        isScrubbing.value = true;
                        scrubPosition.value = Duration(
                          milliseconds: value.toInt(),
                        );
                      },
                onChangeEnd: mediaUrl == null
                    ? null
                    : (value) async {
                        await ensureLoaded();
                        final target = Duration(milliseconds: value.toInt());
                        await player.seek(target);
                        isScrubbing.value = false;
                      },
                year2023: true,
                padding: EdgeInsets.only(right: 8, left: 4),
              ),
            ),
          ),
          const Gap(6),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: ScaleTransition(scale: animation, child: child),
              );
            },
            child: isPlaying
                ? Text(
                    _formatSeconds(shownPosition),
                    key: const ValueKey('playing-time'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.robotoMono(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  )
                : Text(
                    _formatSeconds(total),
                    key: const ValueKey('paused-time'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.robotoMono(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
          ).padding(right: 4),
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
