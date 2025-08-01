import 'dart:math' as math;
import 'package:collection/collection.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/models/embed.dart';
import 'package:island/models/post.dart';
import 'package:island/pods/config.dart';
import 'package:island/pods/network.dart';
import 'package:island/pods/translate.dart';
import 'package:island/pods/userinfo.dart';
import 'package:island/screens/posts/compose.dart';
import 'package:island/services/responsive.dart';
import 'package:island/services/time.dart';
import 'package:island/widgets/account/account_name.dart';
import 'package:island/widgets/alert.dart';
import 'package:island/widgets/content/cloud_file_collection.dart';
import 'package:island/widgets/content/cloud_files.dart';
import 'package:island/widgets/content/embed/link.dart';
import 'package:island/widgets/content/markdown.dart';
import 'package:island/widgets/post/post_replies_sheet.dart';
import 'package:island/widgets/safety/abuse_report_helper.dart';
import 'package:island/widgets/share/share_sheet.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:super_context_menu/super_context_menu.dart';

part 'post_item.g.dart';

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

class PostActionableItem extends HookConsumerWidget {
  final SnPost item;
  final EdgeInsets? padding;
  final bool isFullPost;
  final bool isShowReference;
  final bool isEmbedReply;
  final bool isEmbedOpenable;
  final double? borderRadius;
  final VoidCallback? onRefresh;
  final Function(SnPost)? onUpdate;
  final VoidCallback? onOpen;
  const PostActionableItem({
    super.key,
    required this.item,
    this.padding,
    this.isFullPost = false,
    this.isShowReference = true,
    this.isEmbedReply = true,
    this.isEmbedOpenable = false,
    this.borderRadius,
    this.onRefresh,
    this.onUpdate,
    this.onOpen,
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
        padding: padding,
        isFullPost: isFullPost,
        isShowReference: isShowReference,
        isEmbedReply: isEmbedReply,
        isEmbedOpenable: isEmbedOpenable,
        isTextSelectable: false,
        onRefresh: onRefresh,
        onUpdate: onUpdate,
        onOpen: onOpen,
      ),
      onTap: () {
        onOpen?.call();
        context.pushNamed('postDetail', pathParameters: {'id': item.id});
      },
    );

    return ContextMenuWidget(
      menuProvider: (_) {
        return Menu(
          children: [
            if (isAuthor)
              MenuAction(
                title: 'edit'.tr(),
                image: MenuImage.icon(Symbols.edit),
                callback: () {
                  context
                      .pushNamed('postEdit', pathParameters: {'id': item.id})
                      .then((value) {
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
                          .delete('/sphere/posts/${item.id}')
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
                context.pushNamed(
                  'postCompose',
                  extra: PostComposeInitialState(replyingTo: item),
                );
              },
            ),
            MenuAction(
              title: 'forward'.tr(),
              image: MenuImage.icon(Symbols.forward),
              callback: () {
                context.pushNamed(
                  'postCompose',
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
                  resourceIdentifier: 'post/${item.id}',
                );
              },
            ),
          ],
        );
      },
      child: Material(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius:
            borderRadius != null
                ? BorderRadius.all(Radius.circular(borderRadius!))
                : null,
        child: widgetItem,
      ),
    );
  }
}

class PostItem extends HookConsumerWidget {
  final SnPost item;
  final EdgeInsets? padding;
  final bool isFullPost;
  final bool isShowReference;
  final bool isEmbedReply;
  final bool isEmbedOpenable;
  final bool isTextSelectable;
  final VoidCallback? onRefresh;
  final Function(SnPost)? onUpdate;
  final VoidCallback? onOpen;
  const PostItem({
    super.key,
    required this.item,
    this.padding,
    this.isFullPost = false,
    this.isShowReference = true,
    this.isEmbedReply = true,
    this.isEmbedOpenable = false,
    this.isTextSelectable = true,
    this.onRefresh,
    this.onUpdate,
    this.onOpen,
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

    final postLanguage =
        item.content != null
            ? ref.watch(detectStringLanguageProvider(item.content!))
            : null;

    final currentLanguage = context.locale.toString();
    final translatableLanguage =
        postLanguage != null
            ? postLanguage.substring(0, 2) != currentLanguage.substring(0, 2)
            : false;

    final translating = useState(false);
    final translatedText = useState<String?>(null);

    Future<void> translate() async {
      if (translatedText.value != null) {
        translatedText.value = null;
        return;
      }

      if (translating.value) return;
      if (item.content == null) return;
      translating.value = true;
      try {
        final text = await ref.watch(
          translateStringProvider(
            TranslateQuery(
              text: item.content!,
              lang: currentLanguage.substring(0, 2),
            ),
          ).future,
        );
        translatedText.value = text;
      } catch (err) {
        showErrorAlert(err);
      } finally {
        translating.value = false;
      }
    }

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
                        label: Center(
                          child: Text(
                            'x${item.reactionsCount[mostReaction]}',
                            style: TextStyle(fontSize: 11),
                            textAlign: TextAlign.center,
                          ),
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
              style: ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(
                  (item.reactionsMade[mostReaction] ?? false)
                      ? Theme.of(context).colorScheme.primary.withOpacity(0.5)
                      : null,
                ),
              ),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  useRootNavigator: true,
                  builder: (BuildContext context) {
                    return _PostReactionSheet(
                      reactionsCount: item.reactionsCount,
                      reactionsMade: item.reactionsMade,
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                MarkdownTextContent(
                  content:
                      item.isTruncated ? '${item.content!}...' : item.content!,
                  isSelectable: isTextSelectable,
                ),
                if (translatedText.value?.isNotEmpty ?? false)
                  ...([
                    Row(
                      children: [
                        Expanded(child: Divider()),
                        const Gap(8),
                        Text('translated').tr().fontSize(11).opacity(0.75),
                      ],
                    ),
                    MarkdownTextContent(
                      content: translatedText.value!,
                      isSelectable: isTextSelectable,
                    ),
                  ]),
                if (translatableLanguage)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: translating.value ? null : translate,
                      style: ButtonStyle(
                        padding: WidgetStatePropertyAll(EdgeInsets.zero),
                        visualDensity: const VisualDensity(
                          horizontal: 0,
                          vertical: -4,
                        ),
                        foregroundColor: WidgetStatePropertyAll(
                          translatedText.value == null ? null : Colors.grey,
                        ),
                      ),
                      icon: const Icon(Symbols.translate),
                      label:
                          translatedText.value != null
                              ? Text('translated').tr()
                              : translating.value
                              ? Text('translating').tr()
                              : Text('translate').tr(),
                    ),
                  ),
              ],
            ),
          ),
        if (item.isTruncated && item.type != 1)
          _PostTruncateHint(
            isCompact: true,
            margin: EdgeInsets.only(
              top: 4,
              bottom: 4,
              left: renderingPadding.horizontal,
              right: renderingPadding.horizontal,
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
        if (item.meta?['embeds'] != null)
          ...((item.meta!['embeds'] as List<dynamic>)
              .where((embed) => embed['Type'] == 'link')
              .map(
                (embedData) => EmbedLinkWidget(
                  link: SnEmbedLink.fromJson(embedData as Map<String, dynamic>),
                  maxWidth: math.min(
                    MediaQuery.of(context).size.width,
                    kWideScreenWidth,
                  ),
                  margin: EdgeInsets.only(
                    top: 4,
                    bottom: 4,
                    left: renderingPadding.horizontal,
                    right: renderingPadding.horizontal,
                  ),
                ),
              )),
        if (isShowReference)
          _buildReferencePost(context, item, renderingPadding),
        if (item.repliesCount > 0 && isEmbedReply)
          PostReplyPreview(
            parent: item,
            isOpenable: isEmbedOpenable,
            onOpen: onOpen,
          ).padding(horizontal: renderingPadding.horizontal, top: 8),
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

    Future<void> fetchMoreReplies({int pageSize = 1}) async {
      final client = ref.read(apiClientProvider);
      loading.value = true;

      try {
        final response = await client.get(
          '/sphere/posts/${parent.id}/replies',
          queryParameters: {'offset': posts.value.length, 'take': pageSize},
        );
        posts.value = [
          ...posts.value,
          ...response.data.map((e) => SnPost.fromJson(e)),
        ];
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
            : featuredReply!.when(
              data:
                  (value) => Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 8,
                    children: [
                      ProfilePictureWidget(
                        file: value!.publisher.picture,
                        radius: 12,
                      ).padding(top: 4),
                      if (value.content?.isNotEmpty ?? false)
                        Expanded(
                          child: MarkdownTextContent(content: value.content!),
                        )
                      else
                        Expanded(
                          child: Text(
                            'postHasAttachments',
                          ).plural(value.attachments.length),
                        ),
                    ],
                  ),
              error:
                  (error, _) => Row(
                    spacing: 8,
                    children: [
                      const Icon(Symbols.close, size: 18),
                      Text(error.toString()),
                    ],
                  ),
              loading:
                  () => Row(
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
                border: Border.all(color: Theme.of(context).dividerColor),
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 4,
                children: [
                  Text('repliesCount')
                      .plural(parent.repliesCount)
                      .tr()
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

class PostReactionList extends HookConsumerWidget {
  final String parentId;
  final Map<String, int> reactions;
  final Map<String, bool> reactionsMade;
  final Function(String symbol, int attitude, int delta)? onReact;
  final EdgeInsets? padding;
  const PostReactionList({
    super.key,
    required this.parentId,
    required this.reactions,
    required this.reactionsMade,
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
                                reactionsMade: reactionsMade,
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
  final Map<String, bool> reactionsMade;
  final Function(String symbol, int attitude) onReact;
  const _PostReactionSheet({
    required this.reactionsCount,
    required this.reactionsMade,
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
              _buildReactionSection(
                context,
                Symbols.mood,
                'reactionPositive'.tr(),
                0,
              ),
              _buildReactionSection(
                context,
                Symbols.sentiment_neutral,
                'reactionNeutral'.tr(),
                1,
              ),
              _buildReactionSection(
                context,
                Symbols.mood_bad,
                'reactionNegative'.tr(),
                2,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReactionSection(
    BuildContext context,
    IconData icon,
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
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: 8,
          children: [Icon(icon), Text(title).fontSize(17).bold()],
        ).padding(horizontal: 24, top: 16, bottom: 6),
        SizedBox(
          height: 120,
          child: GridView.builder(
            scrollDirection: Axis.horizontal,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 1,
              mainAxisExtent: 120,
              mainAxisSpacing: 8.0,
              crossAxisSpacing: 8.0,
              childAspectRatio: 1.0,
            ),
            padding: EdgeInsets.symmetric(horizontal: 16),
            itemCount: allReactions.length,
            itemBuilder: (context, index) {
              final symbol = allReactions[index];
              final count = reactionsCount[symbol] ?? 0;
              return Card(
                margin: EdgeInsets.symmetric(vertical: 4),
                color:
                    (reactionsMade[symbol] ?? false)
                        ? Theme.of(context).colorScheme.primaryContainer
                        : Theme.of(context).colorScheme.surfaceContainerLowest,
                child: InkWell(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  onTap: () {
                    onReact(symbol, attitude);
                    Navigator.pop(context);
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        kReactionTemplates[symbol]?.icon ?? '',
                        textAlign: TextAlign.center,
                      ).fontSize(24),
                      Text(
                        ReactInfo.getTranslationKey(symbol),
                        textAlign: TextAlign.center,
                      ).tr(),
                      if (count > 0)
                        Text(
                          'x$count',
                          textAlign: TextAlign.center,
                        ).bold().padding(bottom: 4)
                      else
                        const Gap(20),
                    ],
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
