import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'dart:math' as math;
import 'package:island/models/embed.dart';
import 'package:island/models/post.dart';
import 'package:island/pods/config.dart';
import 'package:island/pods/network.dart';
import 'package:island/pods/userinfo.dart';
import 'package:island/screens/posts/compose.dart';
import 'package:island/services/responsive.dart';
import 'package:island/services/time.dart';
import 'package:island/widgets/account/account_name.dart';
import 'package:island/widgets/alert.dart';
import 'package:island/widgets/app_scaffold.dart';
import 'package:island/widgets/content/cloud_file_collection.dart';
import 'package:island/widgets/content/cloud_files.dart';
import 'package:island/widgets/content/embed/link.dart';
import 'package:island/widgets/content/markdown.dart';
import 'package:island/widgets/safety/abuse_report_helper.dart';
import 'package:island/widgets/post/post_replies_sheet.dart';
import 'package:island/widgets/share/share_sheet.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:super_context_menu/super_context_menu.dart';

class PostItem extends HookConsumerWidget {
  final Color? backgroundColor;
  final SnPost item;
  final EdgeInsets? padding;
  final bool isOpenable;
  final bool isFullPost;
  final bool showReferencePost;
  final Function? onRefresh;
  final Function(SnPost)? onUpdate;
  const PostItem({
    super.key,
    required this.item,
    this.backgroundColor,
    this.padding,
    this.isOpenable = true,
    this.isFullPost = false,
    this.showReferencePost = true,
    this.onRefresh,
    this.onUpdate,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final renderingPadding =
        padding ?? EdgeInsets.symmetric(horizontal: 12, vertical: 16);

    final user = ref.watch(userInfoProvider);
    final isAuthor = useMemoized(
      () => user.value != null && user.value?.id == item.publisher.accountId,
      [user],
    );

    final hasBackground =
        ref.watch(backgroundImageFileProvider).valueOrNull != null;

    Widget child;
    if (item.type == 1 && isFullPost) {
      child = Padding(
        padding: renderingPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                context.push('/publishers/${item.publisher.name}');
              },
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ProfilePictureWidget(file: item.publisher.picture),
                  const Gap(12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.publisher.nick).bold(),
                        if (item.publisher.verification != null)
                          VerificationMark(
                            mark: item.publisher.verification!,
                          ).padding(left: 4),
                      ],
                    ),
                  ),
                  Text(
                    isFullPost
                        ? item.publishedAt?.formatSystem() ?? ''
                        : item.publishedAt?.formatRelative(context) ?? '',
                  ).fontSize(11),
                ],
              ),
            ),
            if (item.visibility != 0)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getVisibilityIcon(item.visibility),
                    size: 14,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _getVisibilityText(item.visibility).tr(),
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ],
              ).padding(top: 10, bottom: 2),
            const Gap(16),
            _ArticlePostDisplay(item: item, isFullPost: isFullPost),
            if (item.tags.isNotEmpty || item.categories.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (item.tags.isNotEmpty)
                    Wrap(
                      children: [
                        for (final tag in item.tags)
                          InkWell(
                            child: Row(
                              spacing: 4,
                              children: [
                                const Icon(Symbols.label, size: 13),
                                Text(tag.name ?? '#${tag.slug}').fontSize(13),
                              ],
                            ),
                            onTap: () {},
                          ),
                      ],
                    ),
                  if (item.categories.isNotEmpty)
                    Wrap(
                      children: [
                        for (final category in item.categories)
                          InkWell(
                            child: Row(
                              spacing: 4,
                              children: [
                                const Icon(Symbols.category, size: 13),
                                Text(
                                  category.name ?? '#${category.slug}',
                                ).fontSize(13),
                              ],
                            ),
                            onTap: () {},
                          ),
                      ],
                    ),
                ],
              ),
            if ((item.repliedPost != null || item.forwardedPost != null) &&
                showReferencePost)
              _buildReferencePost(context, item),
            if (item.attachments.isNotEmpty && item.type != 1)
              CloudFileList(
                files: item.attachments,
                maxWidth: math.min(
                  MediaQuery.of(context).size.width,
                  kWideScreenWidth,
                ),
                minWidth: math.min(
                  MediaQuery.of(context).size.width,
                  kWideScreenWidth,
                ),
              ),
            if (item.meta?['embeds'] != null)
              ...((item.meta!['embeds'] as List<dynamic>)
                  .where((embed) => embed['Type'] == 'link')
                  .map(
                    (embedData) => EmbedLinkWidget(
                      link: SnEmbedLink.fromJson(
                        embedData as Map<String, dynamic>,
                      ),
                      maxWidth: math.min(
                        MediaQuery.of(context).size.width,
                        kWideScreenWidth,
                      ),
                      margin: EdgeInsets.only(top: 8),
                    ),
                  )),
            const Gap(8),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: ActionChip(
                    avatar: Icon(Symbols.reply, size: 16),
                    label: Text(
                      (item.repliesCount > 0)
                          ? 'repliesCount'.plural(item.repliesCount)
                          : 'reply'.tr(),
                    ),
                    visualDensity: const VisualDensity(
                      horizontal: VisualDensity.minimumDensity,
                      vertical: VisualDensity.minimumDensity,
                    ),
                    onPressed: () {
                      if (isOpenable) {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          useRootNavigator: true,
                          builder: (context) => PostRepliesSheet(post: item),
                        );
                      }
                    },
                  ),
                ),
                Expanded(
                  child: PostReactionList(
                    parentId: item.id,
                    reactions: item.reactionsCount,
                    padding: EdgeInsets.zero,
                    onReact: (symbol, attitude, delta) {
                      final reactionsCount = Map<String, int>.from(
                        item.reactionsCount,
                      );
                      reactionsCount[symbol] =
                          (reactionsCount[symbol] ?? 0) + delta;
                      onUpdate?.call(
                        item.copyWith(reactionsCount: reactionsCount),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    } else {
      child = Padding(
        padding: renderingPadding,
        child: Column(
          spacing: 8,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 12,
              children: [
                GestureDetector(
                  child: ProfilePictureWidget(file: item.publisher.picture),
                  onTap: () {
                    context.push('/publishers/${item.publisher.name}');
                  },
                ),
                Expanded(
                  child: GestureDetector(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(item.publisher.nick).bold(),
                            if (item.publisher.verification != null)
                              VerificationMark(
                                mark: item.publisher.verification!,
                              ).padding(left: 4),
                            Spacer(),
                            Text(
                              isFullPost
                                  ? item.publishedAt?.formatSystem() ?? ''
                                  : item.publishedAt?.formatRelative(context) ??
                                      '',
                            ).fontSize(11).alignment(Alignment.bottomRight),
                            const Gap(4),
                          ],
                        ),
                        // Add visibility indicator if not public (visibility != 0)
                        if (item.visibility != 0)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _getVisibilityIcon(item.visibility),
                                size: 14,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _getVisibilityText(item.visibility).tr(),
                                style: TextStyle(
                                  fontSize: 12,
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                ),
                              ),
                            ],
                          ).padding(top: 2, bottom: 2),
                        if (item.type == 1)
                          _ArticlePostDisplay(
                            item: item,
                            isFullPost: isFullPost,
                          )
                        else ...[
                          if (item.title?.isNotEmpty ?? false)
                            Text(
                              item.title!,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          if (item.description?.isNotEmpty ?? false)
                            Text(
                              item.description!,
                              style: Theme.of(
                                context,
                              ).textTheme.bodyMedium?.copyWith(
                                color:
                                    Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                              ),
                            ).padding(bottom: 8),
                          if (item.content?.isNotEmpty ?? false)
                            MarkdownTextContent(
                              content: item.content!,
                              linesMargin:
                                  item.type == 0
                                      ? EdgeInsets.only(bottom: 8)
                                      : null,
                              attachments: item.attachments,
                            ),
                        ],
                        // Render tags and categories if they exist
                        if (item.tags.isNotEmpty || item.categories.isNotEmpty)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (item.tags.isNotEmpty)
                                Wrap(
                                  children: [
                                    for (final tag in item.tags)
                                      InkWell(
                                        child: Row(
                                          spacing: 4,
                                          children: [
                                            const Icon(Symbols.label, size: 13),
                                            Text(
                                              tag.name ?? '#${tag.slug}',
                                            ).fontSize(13),
                                          ],
                                        ),
                                        onTap: () {},
                                      ),
                                  ],
                                ),
                              if (item.categories.isNotEmpty)
                                Wrap(
                                  children: [
                                    for (final category in item.categories)
                                      InkWell(
                                        child: Row(
                                          spacing: 4,
                                          children: [
                                            const Icon(
                                              Symbols.category,
                                              size: 13,
                                            ),
                                            Text(
                                              category.name ??
                                                  '#${category.slug}',
                                            ).fontSize(13),
                                          ],
                                        ),
                                        onTap: () {},
                                      ),
                                  ],
                                ),
                            ],
                          ),
                        // Show truncation hint if post is truncated
                        if (item.isTruncated && !isFullPost && item.type != 1)
                          _PostTruncateHint().padding(
                            bottom:
                                (item.attachments.isNotEmpty ||
                                        item.repliedPost != null ||
                                        item.forwardedPost != null)
                                    ? 8
                                    : null,
                          ),
                        if ((item.repliedPost != null ||
                                item.forwardedPost != null) &&
                            showReferencePost)
                          _buildReferencePost(context, item),
                        if (item.attachments.isNotEmpty && item.type != 1)
                          CloudFileList(
                            files: item.attachments,
                            maxWidth: math.min(
                              MediaQuery.of(context).size.width * 0.85,
                              kWideScreenWidth - 160,
                            ),
                            minWidth: math.min(
                              MediaQuery.of(context).size.width * 0.9,
                              kWideScreenWidth - 160,
                            ),
                          ),
                        // Render embed links
                        if (item.meta?['embeds'] != null)
                          ...((item.meta!['embeds'] as List<dynamic>)
                              .where((embed) => embed['Type'] == 'link')
                              .map(
                                (embedData) => EmbedLinkWidget(
                                  link: SnEmbedLink.fromJson(
                                    embedData as Map<String, dynamic>,
                                  ),
                                  maxWidth: math.min(
                                    MediaQuery.of(context).size.width * 0.85,
                                    kWideScreenWidth - 160,
                                  ),
                                  margin: EdgeInsets.only(top: 8),
                                ),
                              )),
                      ],
                    ),
                    onTap: () {
                      if (isOpenable) {
                        context.push('/posts/${item.id}');
                      }
                    },
                  ),
                ),
              ],
            ),
            Row(
              children: [
                // Replies count button
                Padding(
                  padding: const EdgeInsets.only(left: 52, right: 12),
                  child: ActionChip(
                    avatar: Icon(Symbols.reply, size: 16),
                    label: Text(
                      (item.repliesCount > 0)
                          ? 'repliesCount'.plural(item.repliesCount)
                          : 'reply'.tr(),
                    ),
                    visualDensity: const VisualDensity(
                      horizontal: VisualDensity.minimumDensity,
                      vertical: VisualDensity.minimumDensity,
                    ),
                    onPressed: () {
                      if (isOpenable) {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          useRootNavigator: true,
                          builder: (context) => PostRepliesSheet(post: item),
                        );
                      }
                    },
                  ),
                ),
                // Reactions list
                Expanded(
                  child: PostReactionList(
                    parentId: item.id,
                    reactions: item.reactionsCount,
                    padding: EdgeInsets.zero,
                    onReact: (symbol, attitude, delta) {
                      final reactionsCount = Map<String, int>.from(
                        item.reactionsCount,
                      );
                      reactionsCount[symbol] =
                          (reactionsCount[symbol] ?? 0) + delta;
                      onUpdate?.call(
                        item.copyWith(reactionsCount: reactionsCount),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    return ContextMenuWidget(
      menuProvider: (_) {
        return Menu(
          children: [
            if (isAuthor)
              MenuAction(
                title: 'edit'.tr(),
                image: MenuImage.icon(Symbols.edit),
                callback: () {
                  context.push('/posts/${item.id}/edit').then((value) {
                    if (value != null) {
                      onRefresh?.call();
                    }
                  });
                },
              ),
            if (isAuthor)
              MenuAction(
                title: 'delete'.tr(),
                image: MenuImage.icon(Symbols.delete),
                callback: () {
                  showConfirmAlert(
                    'deletePostHint'.tr(),
                    'deletePost'.tr(),
                  ).then((confirm) {
                    if (confirm) {
                      final client = ref.watch(apiClientProvider);
                      client
                          .delete('/posts/${item.id}')
                          .catchError((err) {
                            showErrorAlert(err);
                            return err;
                          })
                          .then((_) {
                            onRefresh?.call();
                          });
                    }
                  });
                },
              ),
            if (isAuthor) MenuSeparator(),
            MenuAction(
              title: 'copyLink'.tr(),
              image: MenuImage.icon(Symbols.link),
              callback: () {
                Clipboard.setData(
                  ClipboardData(text: 'https://solsynth.dev/posts/${item.id}'),
                );
              },
            ),
            MenuAction(
              title: 'reply'.tr(),
              image: MenuImage.icon(Symbols.reply),
              callback: () {
                context.push(
                  '/posts/compose',
                  extra: PostComposeInitialState(replyingTo: item),
                );
              },
            ),
            MenuAction(
              title: 'forward'.tr(),
              image: MenuImage.icon(Symbols.forward),
              callback: () {
                context.push(
                  '/posts/compose',
                  extra: PostComposeInitialState(forwardingTo: item),
                );
              },
            ),
            MenuSeparator(),
            MenuAction(
              title: 'share'.tr(),
              image: MenuImage.icon(Symbols.share),
              callback: () {
                showShareSheetLink(
                  context: context,
                  link: '${ref.read(serverUrlProvider)}/posts/${item.id}',
                  title: 'sharePost'.tr(),
                  toSystem: true,
                );
              },
            ),
            MenuAction(
              title: 'abuseReport'.tr(),
              image: MenuImage.icon(Symbols.flag),
              callback: () {
                showAbuseReportSheet(
                  context,
                  resourceIdentifier: 'posts:${item.id}',
                );
              },
            ),
          ],
        );
      },
      child: Material(
        color: hasBackground ? Colors.transparent : backgroundColor,
        child: child,
      ),
    );
  }
}

Widget _buildReferencePost(BuildContext context, SnPost item) {
  final referencePost = item.repliedPost ?? item.forwardedPost;
  if (referencePost == null) return const SizedBox.shrink();

  final isReply = item.repliedPost != null;

  return Container(
    padding: const EdgeInsets.all(12),
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
  ).gestures(onTap: () => context.push('/posts/${referencePost.id}'));
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
            '/posts/$parentId/reactions',
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
