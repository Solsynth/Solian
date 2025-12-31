import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:html2md/html2md.dart' as html2md;
import 'package:island/models/account.dart';
import 'package:island/models/post.dart';
import 'package:island/pods/network.dart';
import 'package:island/services/time.dart';
import 'package:island/widgets/account/account_name.dart';
import 'package:island/widgets/activitypub/actor_profile.dart';
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

/// Converts HTML content to markdown if contentType indicates HTML (contentType == 1)
String _convertContentToMarkdown(SnPost post) {
  if (post.contentType == 1 && post.content != null) {
    return html2md.convert(post.content!);
  }
  return post.content ?? '';
}

class RepliesState {
  final List<SnPost> posts;
  final bool loading;

  RepliesState({required this.posts, required this.loading});

  RepliesState copyWith({List<SnPost>? posts, bool? loading}) {
    return RepliesState(
      posts: posts ?? this.posts,
      loading: loading ?? this.loading,
    );
  }
}

@riverpod
class RepliesNotifier extends _$RepliesNotifier {
  @override
  RepliesState build(String parentId) {
    return RepliesState(posts: [], loading: false);
  }

  Future<void> fetchMore(int pageSize) async {
    state = state.copyWith(loading: true);

    final client = ref.read(apiClientProvider);

    final response = await client.get(
      '/sphere/posts/$parentId/replies',
      queryParameters: {'offset': state.posts.length, 'take': pageSize},
    );

    if (!ref.mounted) return;

    state = state.copyWith(
      posts: [...state.posts, ...response.data.map((e) => SnPost.fromJson(e))],
      loading: false,
    );
  }
}

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
  final double? itemMaxWidth;
  final VoidCallback? onOpen;
  const PostReplyPreview({
    super.key,
    required this.parent,
    this.isOpenable = false,
    this.isCompact = false,
    this.isAutoload = true,
    this.itemMaxWidth,
    this.onOpen,
  });

  Widget _buildProfilePicture(
    BuildContext context,
    SnPost post, {
    double radius = 16,
  }) {
    // Handle publisher case
    if (post.publisher != null) {
      return ProfilePictureWidget(
        file:
            post.publisher!.picture ?? post.publisher!.account?.profile.picture,
        radius: radius,
      );
    }
    // Handle actor case
    if (post.actor != null) {
      return ActorPictureWidget(actor: post.actor!, radius: radius);
    }
    // Fallback
    return ProfilePictureWidget(fileId: null, radius: radius);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repliesState = ref.watch(repliesProvider(parent.id));

    useEffect(() {
      if (isAutoload) {
        Future(() async {
          try {
            await ref.read(repliesProvider(parent.id).notifier).fetchMore(3);
          } catch (err) {
            showErrorAlert(err);
          }
        });
      }
      return null;
    }, [parent]);

    final featuredReply = isOpenable
        ? null
        : ref.watch(postFeaturedReplyProvider(parent.id));

    Widget itemBuilder(double maxWidth) {
      return isOpenable
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final post in repliesState.posts)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InkWell(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: maxWidth),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: 8,
                            children: [
                              _buildProfilePicture(
                                context,
                                post,
                                radius: 12,
                              ).padding(top: 4),
                              if (post.content?.isNotEmpty ?? false)
                                Expanded(
                                  child: MarkdownTextContent(
                                    content: _convertContentToMarkdown(post),
                                    attachments: post.attachments,
                                  ).padding(top: 2),
                                )
                              else
                                Expanded(
                                  child:
                                      Text(
                                            'postHasAttachments',
                                            style: TextStyle(height: 2),
                                          )
                                          .plural(post.attachments.length)
                                          .padding(top: 2),
                                ),
                            ],
                          ),
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
                          itemMaxWidth: math.max(maxWidth - 24, 200),
                          onOpen: onOpen,
                        ).padding(left: 24),
                    ],
                  ),
                if (repliesState.loading)
                  Row(
                    mainAxisSize: MainAxisSize.min,
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
                else if (repliesState.posts.length < parent.repliesCount)
                  GestureDetector(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      spacing: 8,
                      children: [
                        const Icon(Symbols.keyboard_arrow_down, size: 20),
                        Text('repliesLoadMore').tr(),
                      ],
                    ),
                    onTap: () async {
                      try {
                        await ref
                            .read(repliesProvider(parent.id).notifier)
                            .fetchMore(3);
                      } catch (err) {
                        showErrorAlert(err);
                      }
                    },
                  ),
              ],
            )
          : (featuredReply!).map(
              data: (data) => ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 8,
                  children: [
                    _buildProfilePicture(
                      context,
                      data.value!,
                      radius: 12,
                    ).padding(top: 4),
                    if (data.value?.content?.isNotEmpty ?? false)
                      Expanded(
                        child: MarkdownTextContent(
                          content: _convertContentToMarkdown(data.value!),
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
              ),
              error: (e) => Row(
                spacing: 8,
                children: [
                  const Icon(Symbols.close, size: 18),
                  Text(e.error.toString()),
                ],
              ),
              loading: (_) => Row(
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
    }

    final contentWidget = isCompact
        ? itemBuilder(itemMaxWidth ?? MediaQuery.of(context).size.width)
        : Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerLow,
              border: Border.all(
                color: Theme.of(context).dividerColor.withOpacity(0.5),
              ),
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
            width: double.infinity,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 4,
                  children: [
                    Text('repliesCount')
                        .plural(parent.repliesCount)
                        .fontSize(15)
                        .bold()
                        .padding(horizontal: 5),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: itemBuilder(constraints.maxWidth),
                    ),
                  ],
                );
              },
            ),
          );

    return GestureDetector(
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

  Widget _buildProfilePicture(
    BuildContext context,
    SnPost post, {
    double radius = 16,
  }) {
    // Handle publisher case
    if (post.publisher != null) {
      return ProfilePictureWidget(
        fileId: post.publisher!.picture?.id,
        radius: radius,
      );
    }
    // Handle actor case
    if (post.actor != null) {
      return ActorPictureWidget(actor: post.actor!, radius: radius);
    }
    // Fallback
    return ProfilePictureWidget(fileId: null, radius: radius);
  }

  String _getDisplayName(SnPost post) {
    // Handle publisher case
    if (post.publisher != null) {
      return post.publisher!.nick;
    }
    // Handle actor case
    if (post.actor != null) {
      return post.actor!.displayName ?? post.actor!.username ?? 'Unknown';
    }
    return 'Unknown';
  }

  @override
  Widget build(BuildContext context) {
    final referencePost = item.repliedPost ?? item.forwardedPost;
    final isGone = item.repliedGone || item.forwardedGone;

    if (referencePost == null && !isGone) return const SizedBox.shrink();

    final isReply = item.repliedPost != null || item.repliedGone;

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
          if (isGone)
            Row(
              children: [
                Icon(
                  Symbols.visibility_off,
                  size: 16,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                const SizedBox(width: 8),
                Text(
                  'postReferenceUnavailable'.tr(),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            )
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProfilePicture(context, referencePost!, radius: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getDisplayName(referencePost),
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
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ).padding(bottom: 2),
                      if (referencePost.content?.isNotEmpty ?? false)
                        MarkdownTextContent(
                          content: _convertContentToMarkdown(referencePost),
                          textStyle: const TextStyle(fontSize: 14),
                          isSelectable: false,
                          linesMargin: referencePost.type == 0
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

    if (!isInteractive || isGone) {
      return content;
    }

    return content.gestures(
      onTap: () => context.pushNamed(
        'postDetail',
        pathParameters: {'id': referencePost!.id},
      ),
    );
  }
}

class PostHeader extends HookConsumerWidget {
  final SnPost item;
  final bool isFullPost;
  final Widget? trailing;
  final bool isInteractive;
  final EdgeInsets renderingPadding;
  final bool isRelativeTime;
  final bool isCompact;
  final bool hideOverlay;

  const PostHeader({
    super.key,
    required this.item,
    this.isFullPost = false,
    this.trailing,
    this.isInteractive = true,
    this.renderingPadding = EdgeInsets.zero,
    this.isRelativeTime = true,
    this.isCompact = false,
    this.hideOverlay = false,
  });

  Widget _buildProfilePicture(
    BuildContext context,
    SnPost post, {
    double radius = 16,
  }) {
    // Handle publisher case
    if (post.publisher != null) {
      return ProfilePictureWidget(
        file:
            post.publisher!.picture ?? post.publisher!.account?.profile.picture,
        radius: radius,
        borderRadius: post.publisher!.type == 0 ? null : 6,
      );
    }
    // Handle actor case
    if (post.actor != null) {
      return ActorPictureWidget(actor: post.actor!, radius: radius);
    }
    // Fallback
    return ProfilePictureWidget(fileId: null, radius: radius);
  }

  String _getDisplayName(SnPost post) {
    // Handle publisher case
    if (post.publisher != null) {
      return post.publisher!.nick;
    }
    // Handle actor case
    if (post.actor != null) {
      return post.actor!.displayName ?? post.actor!.username ?? 'unknown'.tr();
    }
    return 'unknown'.tr();
  }

  String? _getPublisherName(SnPost post) {
    // Handle publisher case
    if (post.publisher != null) {
      return post.publisher!.name;
    }
    // Handle actor case
    if (post.actor != null) {
      return '${post.actor!.username}@${post.actor!.instance.domain}';
    }
    return null;
  }

  int _getPublisherType(SnPost post) {
    // Handle publisher case
    if (post.publisher != null) {
      return post.publisher!.type;
    }
    return 0; // Default to user type
  }

  bool _hasAccount(SnPost post) {
    return post.publisher?.account != null;
  }

  SnAccount? _getAccount(SnPost post) {
    return post.publisher?.account;
  }

  SnVerificationMark? _getVerification(SnPost post) {
    return post.publisher?.verification;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: 12,
          children: [
            GestureDetector(
              onTap: isInteractive && _getPublisherName(item) != null
                  ? () {
                      if (item.publisher != null) {
                        context.pushNamed(
                          'publisherProfile',
                          pathParameters: {'name': item.publisher!.name},
                        );
                      }
                    }
                  : null,
              child: _buildProfilePicture(context, item, radius: 16),
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
                            (_hasAccount(item) && _getPublisherType(item) == 0)
                            ? AccountName(
                                hideOverlay: hideOverlay,
                                account: _getAccount(item)!,
                                textOverride: _getDisplayName(item),
                                style: TextStyle(fontWeight: FontWeight.bold),
                                hideVerificationMark: true,
                              )
                            : Text(
                                _getDisplayName(item),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ).bold(),
                      ),
                      if (_getVerification(item) != null)
                        VerificationMark(
                          mark: _getVerification(item)!,
                          hideOverlay: hideOverlay,
                        ),
                      if (item.realm == null)
                        Flexible(
                          child: isCompact
                              ? const SizedBox.shrink()
                              : Text(
                                  '@${_getPublisherName(item) ?? 'unknown'}',
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
                  Text(
                    !isFullPost && isRelativeTime
                        ? (item.publishedAt ?? item.createdAt)!.formatRelative(
                            context,
                          )
                        : (item.publishedAt ?? item.createdAt)!.formatSystem(),
                  ).fontSize(10),
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
  final bool isRelativeTime;
  final bool hideOverlay;

  const PostBody({
    super.key,
    required this.item,
    this.isFullPost = false,
    this.isTextSelectable = true,
    this.translationSection,
    this.isInteractive = true,
    this.renderingPadding = EdgeInsets.zero,
    this.isRelativeTime = true,
    this.hideOverlay = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metadataChildren = <Widget>[];

    if (item.pinMode != null) {
      metadataChildren.add(
        Row(
          spacing: 8,
          children: [
            const Icon(Symbols.push_pin, size: 16),
            Text('pinnedPost'.tr()).fontSize(13),
          ],
        ),
      );
    }
    if (item.tags.isNotEmpty) {
      metadataChildren.add(
        Wrap(
          runAlignment: WrapAlignment.center,
          spacing: 8,
          children: [
            const Icon(Symbols.label, size: 16).padding(top: 2),
            for (final tag in isFullPost ? item.tags : item.tags.take(3))
              InkWell(
                onTap: isInteractive
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
      );
    }
    if (item.categories.isNotEmpty) {
      metadataChildren.add(
        Wrap(
          runAlignment: WrapAlignment.center,
          spacing: 8,
          children: [
            const Icon(Symbols.category, size: 16).padding(top: 2),
            for (final category
                in isFullPost ? item.categories : item.categories.take(2))
              InkWell(
                onTap: isInteractive
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
      );
    }
    if (item.editedAt != null) {
      final text = Text(
        'editedAt'.tr(
          args: [
            !isFullPost && isRelativeTime
                ? item.editedAt!.formatRelative(context)
                : item.editedAt!.formatSystem(),
          ],
        ),
      ).fontSize(13);

      metadataChildren.add(
        Row(
          spacing: 8,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [const Icon(Symbols.edit, size: 16), text],
        ),
      );
    }
    if (item.visibility != 0) {
      metadataChildren.add(
        Row(
          spacing: 8,
          children: [
            const Icon(Symbols.visibility_lock, size: 16),
            Text(
              PostVisibilityHelpers.getVisibilityText(item.visibility).tr(),
            ).fontSize(13),
          ],
        ),
      );
    }
    if (item.awardedScore != 0) {
      metadataChildren.add(
        Row(
          spacing: 8,
          children: [
            const Icon(Symbols.emoji_events, size: 16),
            Text(
              'awardPoints'.tr(args: [item.awardedScore.toString()]),
            ).fontSize(13),
          ],
        ),
      );
    }
    if (item.featuredRecords.isNotEmpty) {
      metadataChildren.add(
        Row(
          spacing: 8,
          children: [
            const Icon(Symbols.highlight, size: 16),
            Text(
              'postFeaturedOn'.tr(
                args: [
                  item.featuredRecords
                      .map((e) => e.featuredAt ?? e.createdAt)
                      .map((e) => e.formatCustom("yyyy/MM/dd"))
                      .join(','),
                ],
              ),
            ).fontSize(13),
          ],
        ),
      );
    }
    if (item.fediverseUri != null) {
      metadataChildren.add(
        Row(
          spacing: 8,
          children: [
            const Icon(Symbols.globe, size: 16),
            Text('fediversePostDescribe'.tr()).fontSize(13),
          ],
        ),
      );
    }

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
                    content: '${_convertContentToMarkdown(item)}...',
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
                  content: item.isTruncated
                      ? '${_convertContentToMarkdown(item)}...'
                      : _convertContentToMarkdown(item),
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
        if (metadataChildren.isNotEmpty)
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 2,
            children: metadataChildren,
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
