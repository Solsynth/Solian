import 'package:collection/collection.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/posts/posts_models/post.dart';
import 'package:island/core/config.dart';
import 'package:island/core/widgets/content/image.dart';
import 'package:island/core/widgets/content/markdown.dart';
import 'package:island/drive/drive_widgets/cloud_files.dart';
import 'package:island/posts/posts_widgets/post/post_shared.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:styled_widget/styled_widget.dart';

const kAvailableStickers = {
  'angry',
  'clap',
  'confuse',
  'pray',
  'thumb_up',
  'party',
};

bool _getReactionImageAvailable(String symbol) {
  return kAvailableStickers.contains(symbol);
}

Widget _buildReactionIcon(String symbol, double size, {double iconSize = 24}) {
  if (_getReactionImageAvailable(symbol)) {
    return Image.asset(
      'assets/images/stickers/$symbol.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
      alignment: Alignment.bottomCenter,
    );
  } else {
    return Text(
      kReactionTemplates[symbol]?.icon ?? '',
      style: TextStyle(fontSize: iconSize),
    );
  }
}

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

    final mostReaction = item.reactionsCount.isEmpty
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
            trailing: mostReaction != null
                ? Badge(
                    label: Center(
                      child: Text(
                        'x${item.reactionsCount[mostReaction]}',
                        style: const TextStyle(fontSize: 11),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    offset: const Offset(4, 20),
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.75),
                    textColor: Theme.of(context).colorScheme.onPrimary,
                    child: mostReaction.contains('+')
                        ? Consumer(
                            builder: (context, ref, child) {
                              final baseUrl = ref.watch(serverUrlProvider);
                              final stickerUri =
                                  '$baseUrl/sphere/stickers/lookup/$mostReaction/open';
                              return SizedBox(
                                width: 28,
                                height: 28,
                                child: UniversalImage(
                                  uri: stickerUri,
                                  width: 28,
                                  height: 28,
                                  fit: BoxFit.contain,
                                ).center(),
                              );
                            },
                          )
                        : _buildReactionIcon(mostReaction, 32).padding(
                            bottom: _getReactionImageAvailable(mostReaction)
                                ? 2
                                : 0,
                          ),
                  )
                : null,
          ),
          PostBody(
            item: item,
            renderingPadding: renderingPadding,
            isFullPost: isFullPost,
            isRelativeTime: false,
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
          if (item.repliesCount > 0)
            Consumer(
              builder: (context, ref, child) {
                final repliesState = ref.watch(repliesProvider(item.id));
                final posts = repliesState.posts;

                return Container(
                  margin: EdgeInsets.only(
                    left: renderingPadding.horizontal,
                    right: renderingPadding.horizontal,
                    top: 8,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerLow,
                    border: Border.all(
                      color: Theme.of(context).dividerColor.withOpacity(0.5),
                    ),
                    borderRadius: const BorderRadius.all(Radius.circular(8)),
                  ),
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 4,
                    children: [
                      Text(
                        'repliesCount',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ).plural(item.repliesCount).padding(horizontal: 5),
                      if (posts.isEmpty && repliesState.loading)
                        Row(
                          children: [
                            const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            const Gap(8),
                            const Text('loading').tr(),
                          ],
                        ).padding(horizontal: 5),
                      if (posts.isNotEmpty)
                        ...posts.map(
                          (post) => ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 400),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              spacing: 8,
                              children: [
                                ProfilePictureWidget(
                                  file:
                                      post.publisher?.picture ??
                                      post.publisher?.account?.profile.picture,
                                  radius: 12,
                                ).padding(top: 4),
                                if (post.content?.isNotEmpty ?? false)
                                  Expanded(
                                    child: MarkdownTextContent(
                                      content: post.content!,
                                      attachments: post.attachments,
                                      noMentionChip: item.fediverseUri != null,
                                    ).padding(top: 2),
                                  )
                                else
                                  Expanded(
                                    child:
                                        Text(
                                              'postHasAttachments',
                                              style: const TextStyle(height: 2),
                                            )
                                            .plural(post.attachments.length)
                                            .padding(top: 2),
                                  ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
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
