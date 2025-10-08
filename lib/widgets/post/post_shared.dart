import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/models/post.dart';
import 'package:island/pods/network.dart';
import 'package:island/services/time.dart';
import 'package:island/widgets/account/account_name.dart';
import 'package:island/widgets/alert.dart';
import 'package:island/widgets/content/cloud_file_collection.dart';
import 'package:island/widgets/content/cloud_files.dart';
import 'package:island/widgets/content/embed/embed_list.dart';
import 'package:island/widgets/content/markdown.dart';
import 'package:island/widgets/post/post_replies_sheet.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:styled_widget/styled_widget.dart';

part 'post_shared.g.dart';

const kMessageEnableEmbedTypes = ['text', 'messages.new'];

@riverpod
Future<SnPost?> postFeaturedReply(Ref ref, String id) async {
  final client = ref.watch(apiClientProvider);
  try {
    final resp = await client.get('/sphere/posts/$id/replies/featured');
    return SnPost.fromJson(resp.data);
  } catch (_) {
    return null;
  }
}

class PostVisibilityHelpers {
  static IconData getVisibilityIcon(int visibility) {
    switch (visibility) {
      case 1:
        return Symbols.group;
      case 2:
        return Symbols.link_off;
      case 3:
        return Symbols.lock;
      default:
        return Symbols.public;
    }
  }

  static String getVisibilityText(int visibility) {
    switch (visibility) {
      case 1:
        return 'postVisibilityFriends';
      case 2:
        return 'postVisibilityUnlisted';
      case 3:
        return 'postVisibilityPrivate';
      default:
        return 'postVisibilityPublic';
    }
  }
}

class PostReplyPreview extends HookConsumerWidget {
  final SnPost parent;
  final bool isOpenable;
  final bool isCompact;
  final bool isAutoload;
  final VoidCallback? onOpen;
  const PostReplyPreview({
    super.key,
    required this.parent,
    this.isOpenable = false,
    this.isCompact = false,
    this.isAutoload = true,
    this.onOpen,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final posts = useState<List<SnPost>>([]);
    final loading = useState(false);

    Future<void> fetchMoreReplies({int pageSize = 3}) async {
      final client = ref.read(apiClientProvider);
      loading.value = true;

      try {
        final response = await client.get(
          '/sphere/posts/${parent.id}/replies',
          queryParameters: {'offset': posts.value.length, 'take': pageSize},
        );
        try {
          posts.value = [
            ...posts.value,
            ...response.data.map((e) => SnPost.fromJson(e)),
          ];
        } catch (_) {
          // ignore disposed
        }
      } catch (err) {
        showErrorAlert(err);
      } finally {
        try {
          loading.value = false;
        } catch (_) {
          // ignore disposed
        }
      }
    }

    useEffect(() {
      if (isAutoload) fetchMoreReplies();
      return null;
    }, [parent]);

    final featuredReply =
        isOpenable ? null : ref.watch(PostFeaturedReplyProvider(parent.id));

    final itemWidget =
        isOpenable
            ? Column(
              children: [
                for (final post in posts.value)
                  Column(
                    children: [
                      InkWell(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 8,
                          children: [
                            ProfilePictureWidget(
                              file: post.publisher.picture,
                              radius: 12,
                            ).padding(top: 4),
                            if (post.content?.isNotEmpty ?? false)
                              Expanded(
                                child: MarkdownTextContent(
                                  content: post.content!,
                                  attachments: post.attachments,
                                ).padding(top: 2),
                              )
                            else
                              Expanded(
                                child: Text(
                                  'postHasAttachments',
                                ).plural(post.attachments.length),
                              ),
                          ],
                        ),
                        onTap: () {
                          onOpen?.call();
                          context.pushNamed(
                            'postDetail',
                            pathParameters: {'id': post.id},
                          );
                        },
                      ),
                      if (post.repliesCount > 0)
                        PostReplyPreview(
                          parent: post,
                          isOpenable: true,
                          isCompact: true,
                          isAutoload: false,
                          onOpen: onOpen,
                        ).padding(left: 24),
                    ],
                  ),
                if (loading.value)
                  Row(
                    spacing: 8,
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(),
                      ),
                      Text('loading').tr(),
                    ],
                  )
                else if (posts.value.length < parent.repliesCount)
                  InkWell(
                    child: Row(
                      spacing: 8,
                      children: [
                        const Icon(Symbols.keyboard_arrow_down, size: 20),
                        Text('repliesLoadMore').tr(),
                      ],
                    ),
                    onTap: () {
                      fetchMoreReplies();
                    },
                  ),
              ],
            )
            : (featuredReply!).map(
              data:
                  (data) => Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    spacing: 8,
                    children: [
                      ProfilePictureWidget(
                        file: data.value?.publisher.picture,
                        radius: 12,
                      ).padding(top: 4),
                      if (data.value?.content?.isNotEmpty ?? false)
                        Expanded(
                          child: MarkdownTextContent(
                            content: data.value!.content!,
                            attachments: data.value!.attachments,
                          ),
                        )
                      else
                        Expanded(
                          child: Text(
                            'postHasAttachments',
                          ).plural(data.value?.attachments.length ?? 0),
                        ),
                    ],
                  ),
              error:
                  (e) => Row(
                    spacing: 8,
                    children: [
                      const Icon(Symbols.close, size: 18),
                      Text(e.error.toString()),
                    ],
                  ),
              loading:
                  (_) => Row(
                    spacing: 8,
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(),
                      ),
                      Text('loading').tr(),
                    ],
                  ),
            );

    final contentWidget =
        isCompact
            ? itemWidget
            : Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerLow,
                border: Border.all(
                  color: Theme.of(context).dividerColor.withOpacity(0.5),
                ),
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 4,
                children: [
                  Text('repliesCount')
                      .plural(parent.repliesCount)
                      .fontSize(15)
                      .bold()
                      .padding(horizontal: 5),
                  itemWidget,
                ],
              ),
            );

    return InkWell(
      borderRadius: const BorderRadius.all(Radius.circular(8)),
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          useRootNavigator: true,
          builder: (context) => PostRepliesSheet(post: parent),
        );
      },
      child: contentWidget,
    );
  }
}

class PostTruncateHint extends StatelessWidget {
  final bool isCompact;
  final EdgeInsets? margin;
  final bool withArrow;

  const PostTruncateHint({
    super.key,
    this.isCompact = false,
    this.margin,
    this.withArrow = false,
  });

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
          if (withArrow) ...[
            SizedBox(width: isCompact ? 3 : 4),
            Icon(
              Symbols.arrow_forward,
              size: isCompact ? 12 : 14,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ],
        ],
      ),
    );
  }
}

class ReferencedPostWidget extends StatelessWidget {
  final SnPost item;
  final bool isInteractive;
  final EdgeInsets renderingPadding;

  const ReferencedPostWidget({
    super.key,
    required this.item,
    this.isInteractive = true,
    this.renderingPadding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    final referencePost = item.repliedPost ?? item.forwardedPost;
    if (referencePost == null) return const SizedBox.shrink();

    final isReply = item.repliedPost != null;

    final content = Container(
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
          color: Theme.of(context).dividerColor.withOpacity(0.5),
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
                    if (referencePost.visibility != 0)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            PostVisibilityHelpers.getVisibilityIcon(
                              referencePost.visibility,
                            ),
                            size: 12,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            PostVisibilityHelpers.getVisibilityText(
                              referencePost.visibility,
                            ).tr(),
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
                                ? const EdgeInsets.only(bottom: 4)
                                : null,
                        attachments: item.attachments,
                      ).padding(bottom: 4),
                    if (referencePost.isTruncated)
                      const PostTruncateHint(
                        isCompact: true,
                        margin: EdgeInsets.only(top: 4, bottom: 8),
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
    );

    if (!isInteractive) {
      return content;
    }

    return content.gestures(
      onTap:
          () => context.pushNamed(
            'postDetail',
            pathParameters: {'id': referencePost.id},
          ),
    );
  }
}

class PostHeader extends StatelessWidget {
  final SnPost item;
  final bool isFullPost;
  final Widget? trailing;
  final bool isInteractive;
  final EdgeInsets renderingPadding;
  final bool isRelativeTime;
  final bool isCompact;

  const PostHeader({
    super.key,
    required this.item,
    this.isFullPost = false,
    this.trailing,
    this.isInteractive = true,
    this.renderingPadding = EdgeInsets.zero,
    this.isRelativeTime = true,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (item.pinMode != null)
          Row(
            spacing: 4,
            children: [
              const Icon(Symbols.keep, size: 15, fill: 1),
              Text('pinnedPost').tr().fontSize(13),
            ],
          ).opacity(0.8).padding(horizontal: 8, bottom: 4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: 12,
          children: [
            GestureDetector(
              onTap:
                  isInteractive
                      ? () {
                        context.pushNamed(
                          'publisherProfile',
                          pathParameters: {'name': item.publisher.name},
                        );
                      }
                      : null,
              child: ProfilePictureWidget(
                file: item.publisher.picture,
                radius: 16,
                borderRadius: item.publisher.type == 0 ? null : 6,
              ),
            ),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    spacing: 4,
                    children: [
                      Flexible(
                        child:
                            Text(
                              item.publisher.nick,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ).bold(),
                      ),
                      if (item.publisher.verification != null)
                        VerificationMark(mark: item.publisher.verification!),
                      if (item.realm == null)
                        Flexible(
                          child:
                              isCompact
                                  ? const SizedBox.shrink()
                                  : Text(
                                    '@${item.publisher.name}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ).fontSize(11),
                        )
                      else
                        ...([
                          const Icon(Symbols.arrow_right, size: 14),
                          Flexible(
                            child: InkWell(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                spacing: 5,
                                children: [
                                  Flexible(
                                    child: Text(
                                      item.realm!.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  ProfilePictureWidget(
                                    file: item.realm!.picture,
                                    fallbackIcon: Symbols.group,
                                    radius: 9,
                                  ),
                                ],
                              ),
                              onTap: () {
                                GoRouter.of(context).pushNamed(
                                  'realmDetail',
                                  pathParameters: {'slug': item.realm!.slug},
                                );
                              },
                            ),
                          ),
                        ]),
                    ],
                  ),
                  Row(
                    spacing: 6,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        !isFullPost && isRelativeTime
                            ? (item.publishedAt ?? item.createdAt)!
                                .formatRelative(context)
                            : (item.publishedAt ?? item.createdAt)!
                                .formatSystem(),
                      ).fontSize(10),
                      if (item.editedAt != null)
                        Text(
                          'editedAt'.tr(
                            args: [
                              !isFullPost && isRelativeTime
                                  ? item.editedAt!.formatRelative(context)
                                  : item.editedAt!.formatSystem(),
                            ],
                          ),
                        ).fontSize(10),
                      if (item.visibility != 0)
                        Text(
                          PostVisibilityHelpers.getVisibilityText(
                            item.visibility,
                          ).tr(),
                        ).fontSize(10),
                    ],
                  ),
                ],
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ],
    ).padding(horizontal: renderingPadding.horizontal, bottom: 4);
  }
}

class PostBody extends ConsumerWidget {
  final SnPost item;
  final bool isFullPost;
  final bool isTextSelectable;
  final Widget? translationSection;
  final bool isInteractive;
  final EdgeInsets renderingPadding;

  const PostBody({
    super.key,
    required this.item,
    this.isFullPost = false,
    this.isTextSelectable = true,
    this.translationSection,
    this.isInteractive = true,
    this.renderingPadding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!isFullPost && item.type == 1)
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHigh,
              border: Border.all(
                color: Theme.of(context).dividerColor.withOpacity(0.5),
              ),
              borderRadius: const BorderRadius.all(Radius.circular(8)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            margin: EdgeInsets.only(
              top: 4,
              left: renderingPadding.horizontal,
              right: renderingPadding.vertical,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Badge(
                    label: const Text('postArticle').tr(),
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
                  MarkdownTextContent(
                    content: '${item.content!}...',
                    attachments: item.attachments,
                  ),
              ],
            ),
          )
        else if ((item.content?.isNotEmpty ?? false) ||
            (item.title?.isNotEmpty ?? false) ||
            (item.description?.isNotEmpty ?? false))
          Padding(
            padding: EdgeInsets.only(
              left: renderingPadding.horizontal,
              right: renderingPadding.horizontal,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if ((item.title?.isNotEmpty ?? false) ||
                    (item.description?.isNotEmpty ?? false))
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (item.title?.isNotEmpty ?? false)
                        Text(
                          item.title!,
                          style: Theme.of(context).textTheme.titleMedium!
                              .copyWith(fontWeight: FontWeight.bold),
                        ),
                      if (item.description?.isNotEmpty ?? false)
                        Text(
                          item.description!,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                    ],
                  ).padding(bottom: 4),
                MarkdownTextContent(
                  content:
                      item.isTruncated
                          ? '${item.content!}...'
                          : item.content ?? '',
                  isSelectable: isTextSelectable,
                  attachments: item.attachments,
                ),
                if (translationSection != null) translationSection!,
              ],
            ),
          ),
        if (item.isTruncated && item.type != 1)
          PostTruncateHint(
            isCompact: true,
            withArrow: isInteractive,
            margin: EdgeInsets.only(
              top: 4,
              bottom: 4,
              left: renderingPadding.horizontal,
              right: renderingPadding.horizontal,
            ),
          ),
        if (item.attachments.isNotEmpty && item.type != 1)
          CloudFileList(
            files: item.attachments,
            isColumn: !isInteractive,
            padding: EdgeInsets.symmetric(
              horizontal: renderingPadding.horizontal,
              vertical: 4,
            ),
          ),
        if (item.tags.isNotEmpty || item.categories.isNotEmpty)
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 2,
            children: [
              if (item.tags.isNotEmpty)
                Wrap(
                  runAlignment: WrapAlignment.center,
                  spacing: 8,
                  children: [
                    const Icon(Symbols.label, size: 16).padding(top: 2),
                    for (final tag
                        in isFullPost ? item.tags : item.tags.take(3))
                      InkWell(
                        onTap:
                            isInteractive
                                ? () {
                                  GoRouter.of(context).pushNamed(
                                    'postTagDetail',
                                    pathParameters: {'slug': tag.slug},
                                  );
                                }
                                : null,
                        child: Text('#${tag.name ?? tag.slug}'),
                      ),
                    if (!isFullPost && item.tags.length > 3)
                      Text('+${item.tags.length - 3}').opacity(0.6),
                  ],
                ),
              if (item.categories.isNotEmpty)
                Wrap(
                  runAlignment: WrapAlignment.center,
                  spacing: 8,
                  children: [
                    const Icon(Symbols.category, size: 16).padding(top: 2),
                    for (final category
                        in isFullPost
                            ? item.categories
                            : item.categories.take(2))
                      InkWell(
                        onTap:
                            isInteractive
                                ? () {
                                  GoRouter.of(context).pushNamed(
                                    'postCategoryDetail',
                                    pathParameters: {'slug': category.slug},
                                  );
                                }
                                : null,
                        child: Text(category.categoryDisplayTitle),
                      ),
                    if (!isFullPost && item.categories.length > 2)
                      Text('+${item.categories.length - 2}').opacity(0.6),
                  ],
                ),
            ],
          ).padding(horizontal: renderingPadding.horizontal + 4, top: 4),
        if (item.meta?['embeds'] != null)
          EmbedListWidget(
            embeds: item.meta!['embeds'] as List<dynamic>,
            isInteractive: isInteractive,
            isFullPost: isFullPost,
            renderingPadding: renderingPadding,
          ),
      ],
    );
  }
}
