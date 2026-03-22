import 'dart:math' as math;

import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:html2md/html2md.dart' as html2md;
import 'package:island/accounts/widgets/account/account_name.dart';
import 'package:island/accounts/widgets/activitypub/actor_profile.dart';
import 'package:island/core/network.dart';
import 'package:island/core/services/time.dart';
import 'package:island/posts/widgets/compose/post_replies_sheet.dart';
import 'package:island/route.gr.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/core/widgets/content/cloud_file_collection.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:island/core/widgets/embeds/embed_list.dart';
import 'package:island/shared/widgets/content/markdown.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

part 'post_shared.g.dart';

const kMessageEnableEmbedTypes = ['text', 'messages.new'];
const kPostThreadingLineWidth = 1.0;

/// Converts HTML content to markdown if contentType indicates HTML (contentType == 1)
String _convertContentToMarkdown(SnPost post) {
  if (post.contentType == 1 && post.content != null) {
    return html2md.convert(post.content!);
  }
  return post.content ?? '';
}

class RepliesState {
  final List<ThreadedReplyNode> flatNodes;
  final Map<String, List<ThreadedReplyNode>> childrenByParentId;
  final int totalCount;
  final bool loading;

  RepliesState({
    required this.flatNodes,
    required this.childrenByParentId,
    required this.totalCount,
    required this.loading,
  });

  RepliesState copyWith({
    List<ThreadedReplyNode>? flatNodes,
    Map<String, List<ThreadedReplyNode>>? childrenByParentId,
    int? totalCount,
    bool? loading,
  }) {
    return RepliesState(
      flatNodes: flatNodes ?? this.flatNodes,
      childrenByParentId: childrenByParentId ?? this.childrenByParentId,
      totalCount: totalCount ?? this.totalCount,
      loading: loading ?? this.loading,
    );
  }

  List<ThreadedReplyNode> getChildrenOf(String? parentId) {
    return childrenByParentId[parentId] ?? [];
  }

  bool get hasMore => flatNodes.length < totalCount;
}

class ThreadedReplyNode {
  final SnPost post;
  final int depth;
  final String? parentId;

  const ThreadedReplyNode({
    required this.post,
    required this.depth,
    this.parentId,
  });

  factory ThreadedReplyNode.fromJson(Map<String, dynamic> json) {
    return ThreadedReplyNode(
      post: SnPost.fromJson(json['post'] as Map<String, dynamic>),
      depth: json['depth'] as int? ?? 0,
      parentId: json['parentId'] as String?,
    );
  }
}

@riverpod
class RepliesNotifier extends _$RepliesNotifier {
  @override
  RepliesState build(String parentId) {
    return RepliesState(
      flatNodes: const [],
      childrenByParentId: const {},
      totalCount: 0,
      loading: false,
    );
  }

  Future<void> fetchMore(int pageSize) async {
    state = state.copyWith(loading: true);

    final client = ref.read(apiClientProvider);

    final response = await client.get(
      '/sphere/posts/$parentId/replies/threaded',
      queryParameters: {'offset': state.flatNodes.length, 'take': pageSize},
    );

    if (!ref.mounted) return;

    final newNodes = (response.data as List<dynamic>)
        .map((e) => ThreadedReplyNode.fromJson(e as Map<String, dynamic>))
        .toList();

    final newChildrenByParentId = Map<String, List<ThreadedReplyNode>>.from(
      state.childrenByParentId,
    );
    for (final node in newNodes) {
      final parentId = node.parentId;
      if (parentId != null) {
        newChildrenByParentId.putIfAbsent(parentId, () => []);
        newChildrenByParentId[parentId]!.add(node);
      }
    }

    final totalCount =
        int.tryParse(response.headers.value('X-Total') ?? '0') ??
        state.totalCount;

    state = state.copyWith(
      flatNodes: [...state.flatNodes, ...newNodes],
      childrenByParentId: newChildrenByParentId,
      totalCount: totalCount,
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
    return ProfilePictureWidget(file: null, radius: radius);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repliesState = ref.watch(repliesProvider(parent.id));

    useEffect(() {
      if (isAutoload) {
        Future(() async {
          try {
            if (context.mounted) {
              await ref.read(repliesProvider(parent.id).notifier).fetchMore(3);
            }
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

    Widget buildReplyNode(
      ThreadedReplyNode node,
      double maxWidth, {
      double indent = 24,
    }) {
      final post = node.post;
      final children = repliesState.getChildrenOf(post.id);
      return Column(
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
                        noMentionChip: post.fediverseUri != null,
                      ).padding(top: 2),
                    )
                  else
                    Expanded(
                      child: Text(
                        'postHasAttachments',
                        style: TextStyle(height: 2),
                      ).plural(post.attachments.length).padding(top: 2),
                    ),
                ],
              ),
            ),
            onTap: () {
              onOpen?.call();
              context.router.push(PostDetailRoute(id: post.id));
            },
          ),
          for (final child in children)
            buildReplyNode(
              child,
              math.max(maxWidth - indent, 200),
              indent: indent,
            ).padding(left: indent),
        ],
      );
    }

    Widget itemBuilder(double maxWidth) {
      final topLevelNodes = repliesState.flatNodes
          .where((n) => n.depth == 0)
          .toList();
      return isOpenable
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final node in topLevelNodes)
                  buildReplyNode(node, maxWidth),
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
                else if (repliesState.hasMore)
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
                        .plural(parent.threadedRepliesCount)
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

class ReferencedPostWidget extends HookConsumerWidget {
  final SnPost item;
  final bool isInteractive;
  final EdgeInsets renderingPadding;
  final bool isCollapsible;

  const ReferencedPostWidget({
    super.key,
    required this.item,
    this.isInteractive = true,
    this.renderingPadding = EdgeInsets.zero,
    this.isCollapsible = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final referencePost = item.repliedPost ?? item.forwardedPost;
    final isGone = item.repliedGone || item.forwardedGone;

    if (referencePost == null) {
      if (!isGone) return const SizedBox.shrink();
      // When the post is gone (deleted), we still show a placeholder
      // but we can't show the PostHeader since referencePost is null
    }

    final isReply = item.repliedPost != null || item.repliedGone;

    // Collapsible state - default to expanded (not collapsed)
    final isCollapsed = useState(false);

    Widget buildContent() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row with icon, label and collapse button
          InkWell(
            onTap: isCollapsible
                ? () => isCollapsed.value = !isCollapsed.value
                : null,
            child: Row(
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
                const Spacer(),
                if (isCollapsible)
                  Icon(
                    isCollapsed.value
                        ? Symbols.keyboard_arrow_down
                        : Symbols.keyboard_arrow_up,
                    size: 20,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
              ],
            ),
          ),
          if (!isCollapsed.value) ...[
            const Gap(8),
            // Only show PostHeader if referencePost is not null
            if (referencePost != null)
              PostHeader(
                item: referencePost,
                isFullPost: false,
                isCompact: true,
                showLowerLine: true,
                renderingPadding: EdgeInsets.zero,
                isInteractive: isInteractive,
              ),
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
              ).padding(left: 8, bottom: 8)
            else if (referencePost != null)
              // Use PostHeader for the referenced post with threading line
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Threading line column - connects down to current PostHeader
                    SizedBox(
                      width: 32,
                      child: Column(
                        children: [
                          // Line extending down from referenced post's avatar area
                          Expanded(
                            child: Container(
                              width: kPostThreadingLineWidth,
                              color: Theme.of(context).dividerColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Gap(12),
                    // Referenced post content using PostHeader
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Content
                          if (referencePost.content?.isNotEmpty ?? false)
                            MarkdownTextContent(
                              content: _convertContentToMarkdown(referencePost),
                              textStyle: const TextStyle(fontSize: 14),
                              isSelectable: false,
                              linesMargin: referencePost.type == 0
                                  ? const EdgeInsets.only(bottom: 4)
                                  : null,
                              attachments: referencePost.attachments,
                              noMentionChip: referencePost.fediverseUri != null,
                            ).padding(top: 8),
                          if (referencePost.title?.isNotEmpty ?? false)
                            Text(
                              referencePost.title!,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ).padding(top: 8, bottom: 4),
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
                            ).padding(bottom: 4),
                          if (referencePost.isTruncated)
                            const PostTruncateHint(
                              isCompact: true,
                              margin: EdgeInsets.only(top: 4, bottom: 4),
                            ),
                          // Attachments indicator
                          if (referencePost.attachments.isNotEmpty &&
                              referencePost.type != 1)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Symbols.attach_file,
                                  size: 12,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.secondary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'postHasAttachments'.plural(
                                    referencePost.attachments.length,
                                  ),
                                  style: TextStyle(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.secondary,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ).padding(top: 4),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ],
      );
    }

    final content = Padding(
      padding: EdgeInsets.only(
        left: renderingPadding.horizontal,
        right: renderingPadding.horizontal,
        top: 8,
      ),
      child: buildContent(),
    );

    if (!isInteractive || isGone || referencePost == null) {
      return content;
    }

    return GestureDetector(
      onTap: () => context.router.push(PostDetailRoute(id: referencePost.id)),
      child: content,
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
  final bool showUpperLine;
  final bool showLowerLine;

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
    this.showUpperLine = false,
    this.showLowerLine = false,
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
    return ProfilePictureWidget(file: null, radius: radius);
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
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 12,
          children: [
            // Avatar column with optional line extension
            Column(
              children: [
                if (showUpperLine)
                  Container(
                    width: kPostThreadingLineWidth,
                    height: 12,
                    color: Theme.of(context).dividerColor,
                  ).center().width(28),
                GestureDetector(
                  onTap: isInteractive && _getPublisherName(item) != null
                      ? () {
                          if (item.publisher != null) {
                            context.router.push(
                              PublisherProfileRoute(name: item.publisher!.name),
                            );
                          }
                        }
                      : null,
                  child: _buildProfilePicture(context, item, radius: 16),
                ),
                if (showLowerLine)
                  Container(
                    width: kPostThreadingLineWidth,
                    height: 6,
                    color: Theme.of(context).dividerColor,
                  ).center().width(28),
              ],
            ),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (showUpperLine) const Gap(12),
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
                                context.router.push(
                                  RealmDetailRoute(slug: item.realm!.slug),
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
            ?trailing,
          ],
        ),
      ],
    ).padding(
      horizontal: renderingPadding.horizontal,
      bottom: showLowerLine ? 0 : 4,
    );
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
  final bool hideAttachments;
  final double? textScale;

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
    this.hideAttachments = false,
    this.textScale,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metadataChildren = <Widget>[];

    if (item.debugRank != null && kDebugMode) {
      metadataChildren.add(
        Row(
          spacing: 8,
          children: [
            const Icon(Symbols.rule, size: 16),
            Text('Rank: ${item.debugRank}').fontSize(13),
          ],
        ),
      );
    }
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
                        context.router.push(
                          PostCategoryDetailRoute(
                            slug: tag.slug,
                            isCategory: false,
                          ),
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
                        context.router.push(
                          PostCategoryDetailRoute(
                            slug: category.slug,
                            isCategory: true,
                          ),
                        );
                      }
                    : null,
                child: Text(category.categoryTranslationKey.tr()),
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

    SnCloudFile? getThumbnailAttachment() {
      final thumbnailId = item.meta?['thumbnail'] as String?;
      if (thumbnailId == null) return null;
      try {
        return item.attachments.firstWhere((a) => a.id == thumbnailId);
      } catch (_) {
        return null;
      }
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
            margin: EdgeInsets.only(
              top: 4,
              left: renderingPadding.horizontal,
              right: renderingPadding.vertical,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (getThumbnailAttachment() != null)
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(8),
                    ),
                    child: CloudFileWidget(item: getThumbnailAttachment()!),
                  ),
                Column(
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
                        style: Theme.of(context).textTheme.titleMedium!
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                    if (item.description?.isNotEmpty ?? false)
                      Text(
                        item.description!,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                  ],
                ).padding(horizontal: 16, vertical: 12),
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
                  linesMargin: item.type == 1 && isFullPost
                      ? const EdgeInsets.symmetric(vertical: 8)
                      : const EdgeInsets.symmetric(vertical: 4),
                  textStyle: TextStyle(
                    fontSize:
                        Theme.of(context).textTheme.bodyMedium!.fontSize! *
                        (textScale ?? 1),
                  ),
                  content: item.isTruncated
                      ? '${_convertContentToMarkdown(item)}...'
                      : _convertContentToMarkdown(item),
                  isSelectable: isTextSelectable,
                  attachments: item.attachments,
                  noMentionChip: item.fediverseUri != null,
                ),
                ?translationSection,
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
        if (item.attachments.isNotEmpty && item.type != 1 && !hideAttachments)
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
