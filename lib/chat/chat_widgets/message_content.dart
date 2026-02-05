import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:island/chat/chat_models/chat.dart';
import 'package:island/chat/chat_pod/call.dart';
import 'package:island/core/widgets/content/markdown.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:pretty_diff_text/pretty_diff_text.dart';
import 'package:styled_widget/styled_widget.dart';

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
                  defaultTextStyle: Theme.of(
                    context,
                  ).textTheme.bodyMedium!.copyWith(
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
