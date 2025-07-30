import 'package:collection/collection.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/models/post.dart';
import 'package:island/pods/network.dart';
import 'package:island/pods/userinfo.dart';
import 'package:island/services/time.dart';
import 'package:island/widgets/account/account_name.dart';
import 'package:island/widgets/alert.dart';
import 'package:island/widgets/content/cloud_file_collection.dart';
import 'package:island/widgets/content/cloud_files.dart';
import 'package:island/widgets/content/markdown.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:styled_widget/styled_widget.dart';

class PostActionableItem extends HookConsumerWidget {
  final Color? backgroundColor;
  final SnPost item;
  final EdgeInsets? padding;
  final bool isFullPost;
  final bool isShowReference;
  final double? borderRadius;
  final Function? onRefresh;
  final Function(SnPost)? onUpdate;
  const PostActionableItem({
    super.key,
    required this.item,
    this.backgroundColor,
    this.padding,
    this.isFullPost = false,
    this.isShowReference = true,
    this.borderRadius,
    this.onRefresh,
    this.onUpdate,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userInfoProvider);
    final isAuthor = useMemoized(
      () => user.value != null && user.value?.id == item.publisher.accountId,
      [user],
    );

    final widgetItem = InkWell(
      borderRadius:
          borderRadius != null
              ? BorderRadius.all(Radius.circular(borderRadius!))
              : null,
      child: PostItem(
        key: key,
        item: item,
        backgroundColor: backgroundColor,
        padding: padding,
        isFullPost: isFullPost,
        isShowReference: isShowReference,
        isTextSelectable: false,
        onRefresh: onRefresh,
        onUpdate: onUpdate,
      ),
      onTap: () {
        context.pushNamed('postDetail', pathParameters: {'id': item.id});
      },
    );

    return widgetItem;
  }
}

class PostItem extends HookConsumerWidget {
  final SnPost item;
  final Color? backgroundColor;
  final EdgeInsets? padding;
  final bool isFullPost;
  final bool isShowReference;
  final bool isTextSelectable;
  final Function? onRefresh;
  final Function(SnPost)? onUpdate;
  const PostItem({
    super.key,
    required this.item,
    this.backgroundColor,
    this.padding,
    this.isFullPost = false,
    this.isShowReference = true,
    this.isTextSelectable = true,
    this.onRefresh,
    this.onUpdate,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final renderingPadding =
        padding ?? EdgeInsets.symmetric(horizontal: 8, vertical: 8);

    final reacting = useState(false);

    Future<void> reactPost(String symbol, int attitude) async {
      final client = ref.watch(apiClientProvider);
      reacting.value = true;
      await client
          .post(
            '/sphere/posts/${item.id}/reactions',
            data: {'symbol': symbol, 'attitude': attitude},
          )
          .catchError((err) {
            showErrorAlert(err);
            return err;
          })
          .then((resp) {
            final isRemoving = resp.statusCode == 204;
            final delta = isRemoving ? -1 : 1;
            final reactionsCount = Map<String, int>.from(item.reactionsCount);
            reactionsCount[symbol] = (reactionsCount[symbol] ?? 0) + delta;
            onUpdate?.call(item.copyWith(reactionsCount: reactionsCount));
            HapticFeedback.heavyImpact();
          });
      reacting.value = false;
    }

    final mostReaction =
        item.reactionsCount.isEmpty
            ? null
            : item.reactionsCount.entries
                .sortedBy((e) => e.value)
                .map((e) => e.key)
                .first;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Gap(renderingPadding.horizontal),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: 12,
          children: [
            GestureDetector(
              child: ProfilePictureWidget(
                file: item.publisher.picture,
                radius: 16,
              ),
              onTap: () {
                context.pushNamed(
                  'publisherProfile',
                  pathParameters: {'name': item.publisher.name},
                );
              },
            ),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    spacing: 4,
                    children: [
                      Text(item.publisher.nick).bold(),
                      if (item.publisher.verification != null)
                        VerificationMark(mark: item.publisher.verification!),
                      Text('@${item.publisher.name}').fontSize(11),
                    ],
                  ),
                  Text(
                    isFullPost
                        ? (item.publishedAt ?? item.createdAt)!.formatSystem()
                        : (item.publishedAt ?? item.createdAt)!.formatRelative(
                          context,
                        ),
                  ).fontSize(10),
                ],
              ),
            ),
            IconButton(
              icon:
                  mostReaction == null
                      ? const Icon(Symbols.add_reaction)
                      : Badge(
                        label: Text(
                          'x${item.reactionsCount[mostReaction]}',
                          style: TextStyle(fontSize: 11),
                        ),
                        offset: Offset(4, 20),
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.primary.withOpacity(0.75),
                        textColor: Theme.of(context).colorScheme.onPrimary,
                        child: Text(
                          kReactionTemplates[mostReaction]!.icon,
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  useRootNavigator: true,
                  builder: (BuildContext context) {
                    return _PostReactionSheet(
                      reactionsCount: item.reactionsCount,
                      onReact: (symbol, attitude) {
                        reactPost(symbol, attitude);
                      },
                    );
                  },
                );
              },
              padding: EdgeInsets.zero,
              visualDensity: VisualDensity(horizontal: -3, vertical: -3),
            ),
          ],
        ).padding(horizontal: renderingPadding.horizontal, bottom: 4),
        if (!isFullPost && item.type == 1)
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).dividerColor),
              borderRadius: const BorderRadius.all(Radius.circular(16)),
            ),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            margin: EdgeInsets.only(
              left: renderingPadding.horizontal,
              right: renderingPadding.horizontal,
              top: 4,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Badge(
                    label: Text('postArticle').tr(),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    textColor: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
                const Gap(4),
                if (item.title != null)
                  Text(
                    item.title!,
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                if (item.description != null)
                  Text(
                    item.description!,
                    style: Theme.of(context).textTheme.bodyMedium,
                  )
                else
                  MarkdownTextContent(content: '${item.content!}...'),
              ],
            ),
          )
        else if (item.content?.isNotEmpty ?? false)
          Padding(
            padding: EdgeInsets.only(
              left: renderingPadding.horizontal,
              right: renderingPadding.horizontal,
            ),
            child: MarkdownTextContent(
              content: item.content!,
              isSelectable: isTextSelectable,
            ),
          ),
        if (item.attachments.isNotEmpty)
          CloudFileList(
            files: item.attachments,
            padding: EdgeInsets.symmetric(
              horizontal: renderingPadding.horizontal,
              vertical: 4,
            ),
          ),
        if (isShowReference)
          _buildReferencePost(context, item, renderingPadding),
        Gap(renderingPadding.vertical),
      ],
    );
  }
}

Widget _buildReferencePost(
  BuildContext context,
  SnPost item,
  EdgeInsets renderingPadding,
) {
  final referencePost = item.repliedPost ?? item.forwardedPost;
  if (referencePost == null) return const SizedBox.shrink();

  final isReply = item.repliedPost != null;

  return Container(
    padding: EdgeInsets.symmetric(
      horizontal: renderingPadding.horizontal,
      vertical: 8,
    ),
    margin: EdgeInsets.only(
      top: 8,
      left: renderingPadding.vertical,
      right: renderingPadding.vertical,
    ),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              isReply ? Symbols.reply : Symbols.forward,
              size: 16,
              color: Theme.of(context).colorScheme.secondary,
            ),
            const SizedBox(width: 6),
            Text(
              isReply ? 'repliedTo'.tr() : 'forwarded'.tr(),
              style: TextStyle(
                color: Theme.of(context).colorScheme.secondary,
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProfilePictureWidget(
              fileId: referencePost.publisher.picture?.id,
              radius: 16,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    referencePost.publisher.nick,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  // Add visibility indicator for referenced post if not public
                  if (referencePost.visibility != 0)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getVisibilityIcon(referencePost.visibility),
                          size: 12,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _getVisibilityText(referencePost.visibility).tr(),
                          style: TextStyle(
                            fontSize: 10,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                      ],
                    ).padding(top: 2, bottom: 2),
                  if (referencePost.title?.isNotEmpty ?? false)
                    Text(
                      referencePost.title!,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ).padding(top: 2, bottom: 2),
                  if (referencePost.description?.isNotEmpty ?? false)
                    Text(
                      referencePost.description!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ).padding(bottom: 2),
                  if (referencePost.content?.isNotEmpty ?? false)
                    MarkdownTextContent(
                      content: referencePost.content!,
                      textStyle: const TextStyle(fontSize: 14),
                      isSelectable: false,
                      linesMargin:
                          referencePost.type == 0
                              ? EdgeInsets.only(bottom: 4)
                              : null,
                      attachments: item.attachments,
                    ).padding(bottom: 4),
                  // Truncation hint for referenced post
                  if (referencePost.isTruncated)
                    _PostTruncateHint(
                      isCompact: true,
                      margin: const EdgeInsets.only(top: 4, bottom: 8),
                    ),
                  if (referencePost.attachments.isNotEmpty &&
                      referencePost.type != 1)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Symbols.attach_file,
                          size: 12,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'postHasAttachments'.plural(
                            referencePost.attachments.length,
                          ),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ).padding(vertical: 2),
                ],
              ),
            ),
          ],
        ),
      ],
    ),
  ).gestures(
    onTap:
        () => context.pushNamed(
          'postDetail',
          pathParameters: {'id': referencePost.id},
        ),
  );
}

class PostReactionList extends HookConsumerWidget {
  final String parentId;
  final Map<String, int> reactions;
  final Function(String symbol, int attitude, int delta)? onReact;
  final EdgeInsets? padding;
  const PostReactionList({
    super.key,
    required this.parentId,
    required this.reactions,
    this.padding,
    this.onReact,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final submitting = useState(false);

    Future<void> reactPost(String symbol, int attitude) async {
      final client = ref.watch(apiClientProvider);
      submitting.value = true;
      await client
          .post(
            '/sphere/posts/$parentId/reactions',
            data: {'symbol': symbol, 'attitude': attitude},
          )
          .catchError((err) {
            showErrorAlert(err);
            return err;
          })
          .then((resp) {
            var isRemoving = resp.statusCode == 204;
            onReact?.call(symbol, attitude, isRemoving ? -1 : 1);
            HapticFeedback.heavyImpact();
          });
      submitting.value = false;
    }

    return SizedBox(
      height: 28,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: padding ?? EdgeInsets.zero,
        children: [
          if (onReact != null)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ActionChip(
                avatar: Icon(Symbols.add_reaction),
                label: Text('react').tr(),
                visualDensity: const VisualDensity(
                  horizontal: VisualDensity.minimumDensity,
                  vertical: VisualDensity.minimumDensity,
                ),
                onPressed:
                    submitting.value
                        ? null
                        : () {
                          showModalBottomSheet(
                            context: context,
                            builder: (BuildContext context) {
                              return _PostReactionSheet(
                                reactionsCount: reactions,
                                onReact: (symbol, attitude) {
                                  reactPost(symbol, attitude);
                                },
                              );
                            },
                          );
                        },
              ),
            ),
          for (final symbol in reactions.keys)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ActionChip(
                avatar: Text(kReactionTemplates[symbol]?.icon ?? '?'),
                label: Row(
                  spacing: 4,
                  children: [
                    Text(symbol),
                    Text('x${reactions[symbol]}').bold(),
                  ],
                ),
                onPressed:
                    submitting.value
                        ? null
                        : () {
                          reactPost(
                            symbol,
                            kReactionTemplates[symbol]?.attitude ?? 0,
                          );
                        },
                visualDensity: const VisualDensity(
                  horizontal: VisualDensity.minimumDensity,
                  vertical: VisualDensity.minimumDensity,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _PostReactionSheet extends StatelessWidget {
  final Map<String, int> reactionsCount;
  final Function(String symbol, int attitude) onReact;
  const _PostReactionSheet({
    required this.reactionsCount,
    required this.onReact,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(top: 16, left: 20, right: 16, bottom: 12),
          child: Row(
            children: [
              Text(
                'reactions'.plural(
                  reactionsCount.isNotEmpty
                      ? reactionsCount.values.reduce((a, b) => a + b)
                      : 0,
                ),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.5,
                ),
              ),
              const Spacer(),

              IconButton(
                icon: const Icon(Symbols.close),
                onPressed: () => Navigator.pop(context),
                style: IconButton.styleFrom(minimumSize: const Size(36, 36)),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: ListView(
            children: [
              _buildReactionSection(context, 'Positive Reactions', 0),
              _buildReactionSection(context, 'Neutral Reactions', 1),
              _buildReactionSection(context, 'Negative Reactions', 2),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReactionSection(
    BuildContext context,
    String title,
    int attitude,
  ) {
    final allReactions =
        kReactionTemplates.entries
            .where((entry) => entry.value.attitude == attitude)
            .map((entry) => entry.key)
            .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title).fontSize(20).bold().padding(horizontal: 20, vertical: 12),
        SizedBox(
          height: 84,
          child: GridView.builder(
            scrollDirection: Axis.horizontal,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 1,
              mainAxisExtent: 100,
              mainAxisSpacing: 8.0,
              crossAxisSpacing: 8.0,
              childAspectRatio: 2.0,
            ),
            itemCount: allReactions.length,
            itemBuilder: (context, index) {
              final symbol = allReactions[index];
              final count = reactionsCount[symbol] ?? 0;
              return InkWell(
                onTap: () {
                  onReact(symbol, attitude);
                  Navigator.pop(context);
                },
                child: GridTile(
                  header: Text(
                    kReactionTemplates[symbol]?.icon ?? '',
                    textAlign: TextAlign.center,
                  ).fontSize(24),
                  footer: Text(
                    count > 0 ? 'x$count' : '',
                    textAlign: TextAlign.center,
                  ).bold().padding(bottom: 12),
                  child: Center(
                    child: Text(symbol, textAlign: TextAlign.center),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _PostTruncateHint extends StatelessWidget {
  final bool isCompact;
  final EdgeInsets? margin;

  const _PostTruncateHint({this.isCompact = false, this.margin});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? EdgeInsets.only(top: isCompact ? 4 : 8),
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 8 : 12,
        vertical: isCompact ? 4 : 8,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Symbols.more_horiz,
            size: isCompact ? 14 : 16,
            color: Theme.of(context).colorScheme.secondary,
          ),
          SizedBox(width: isCompact ? 4 : 6),
          Flexible(
            child: Text(
              'postTruncated'.tr(),
              style: TextStyle(
                fontSize: isCompact ? 10 : 12,
                color: Theme.of(context).colorScheme.secondary,
                fontStyle: FontStyle.italic,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(width: isCompact ? 3 : 4),
          Icon(
            Symbols.arrow_forward,
            size: isCompact ? 12 : 14,
            color: Theme.of(context).colorScheme.secondary,
          ),
        ],
      ),
    );
  }
}

class _ArticlePostDisplay extends StatelessWidget {
  final SnPost item;
  final bool isFullPost;

  const _ArticlePostDisplay({required this.item, required this.isFullPost});

  @override
  Widget build(BuildContext context) {
    if (isFullPost) {
      // Full article view
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (item.title?.isNotEmpty ?? false)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                item.title!,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          if (item.description?.isNotEmpty ?? false)
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Text(
                item.description!,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          if (item.content?.isNotEmpty ?? false)
            MarkdownTextContent(
              content: item.content!,
              textStyle: Theme.of(context).textTheme.bodyLarge,
              attachments: item.attachments,
            ),
        ],
      );
    } else {
      // Truncated/Card view
      String? previewContent;
      if (item.description?.isNotEmpty ?? false) {
        previewContent = item.description!;
      } else if (item.content?.isNotEmpty ?? false) {
        previewContent = item.content!;
      }

      return Card(
        elevation: 0,
        margin: const EdgeInsets.only(top: 4),
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (item.title?.isNotEmpty ?? false)
                Text(
                  item.title!,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              if (previewContent != null) ...[
                const Gap(8),
                Text(
                  previewContent,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.surfaceContainerHighest.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Symbols.article,
                      size: 16,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'postArticle'.tr(),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 4),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }
  }
}

// Helper method to get the appropriate icon for each visibility status
IconData _getVisibilityIcon(int visibility) {
  switch (visibility) {
    case 1: // Friends
      return Symbols.group;
    case 2: // Unlisted
      return Symbols.link_off;
    case 3: // Private
      return Symbols.lock;
    default: // Public (0) or unknown
      return Symbols.public;
  }
}

// Helper method to get the translation key for each visibility status
String _getVisibilityText(int visibility) {
  switch (visibility) {
    case 1: // Friends
      return 'postVisibilityFriends';
    case 2: // Unlisted
      return 'postVisibilityUnlisted';
    case 3: // Private
      return 'postVisibilityPrivate';
    default: // Public (0) or unknown
      return 'postVisibilityPublic';
  }
}
