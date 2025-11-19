import 'package:collection/collection.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/models/post.dart';
import 'package:island/widgets/post/post_shared.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:styled_widget/styled_widget.dart';

class PostItemScreenshot extends ConsumerWidget {
  final SnPost item;
  final EdgeInsets? padding;
  final bool isFullPost;
  final bool isShowReference;
  const PostItemScreenshot({
    super.key,
    required this.item,
    this.padding,
    this.isFullPost = false,
    this.isShowReference = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final renderingPadding =
        padding ?? const EdgeInsets.symmetric(horizontal: 8, vertical: 8);

    final mostReaction =
        item.reactionsCount.isEmpty
            ? null
            : item.reactionsCount.entries
                .sortedBy((e) => e.value)
                .map((e) => e.key)
                .last;

    final isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;

    return Material(
      elevation: 0,
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Gap(renderingPadding.vertical),
          PostHeader(
            hideOverlay: true,
            item: item,
            isFullPost: isFullPost,
            isInteractive: false,
            renderingPadding: renderingPadding,
            isRelativeTime: false,
            trailing:
                mostReaction != null
                    ? Row(
                      children: [
                        Text(
                          kReactionTemplates[mostReaction]?.icon ?? '',
                          style: const TextStyle(fontSize: 20),
                        ),
                        const Gap(4),
                        Text(
                          'x${item.reactionsCount[mostReaction]}',
                          style: const TextStyle(fontSize: 11),
                        ),
                      ],
                    )
                    : null,
          ),
          PostBody(
            item: item,
            renderingPadding: renderingPadding,
            isFullPost: isFullPost,
            isTextSelectable: false,
            isInteractive: false,
            hideOverlay: true,
          ),
          if (isShowReference)
            ReferencedPostWidget(
              item: item,
              isInteractive: false,
              renderingPadding: renderingPadding,
            ),
          Container(
            color: Theme.of(context).colorScheme.surfaceContainerLow,
            margin: const EdgeInsets.only(top: 8),
            padding: EdgeInsets.symmetric(
              horizontal: renderingPadding.horizontal,
              vertical: 4,
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 44,
                  height: 44,
                  child: Image.asset(
                    'assets/icons/icon${isDark ? '-dark' : ''}.png',
                    width: 40,
                    height: 40,
                  ),
                ).padding(vertical: 8, right: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Solar Network',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        'sharePostSlogan',
                        style: TextStyle(fontSize: 12),
                      ).tr().opacity(0.9),
                    ],
                  ),
                ),
                QrImageView(
                  data: 'https://solian.app/posts/${item.id}',
                  version: QrVersions.auto,
                  size: 60,
                  errorCorrectionLevel: QrErrorCorrectLevel.M,
                  backgroundColor: Colors.transparent,
                  foregroundColor: Theme.of(context).colorScheme.onSurface,
                  padding: const EdgeInsets.all(8),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
