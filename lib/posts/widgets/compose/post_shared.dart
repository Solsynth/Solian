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
import 'package:island/accounts/widgets/account/handle_chip.dart';
import 'package:island/accounts/widgets/activitypub/actor_profile.dart';
import 'package:island/core/config.dart';
import 'package:island/core/network.dart';
import 'package:island/core/services/time.dart';
import 'package:island/posts/screens/publisher_profile.dart';
import 'package:island/posts/widgets/compose/post_interactions.dart';
import 'package:island/posts/widgets/compose/post_replies_sheet.dart';
import 'package:island/realms/widgets/realm_label.dart';
import 'package:island/route.gr.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/core/widgets/content/cloud_file_collection.dart';
import 'package:island/shared/widgets/content/image.dart';
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

class SponsoredBadge extends StatelessWidget {
  final bool compact;

  const SponsoredBadge({super.key, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 6 : 8,
        vertical: compact ? 2 : 3,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Symbols.campaign,
            size: compact ? 10 : 12,
            color: theme.colorScheme.onSecondaryContainer,
          ),
          Gap(compact ? 3 : 4),
          Text(
            'postSponsored'.tr(),
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSecondaryContainer,
              fontWeight: FontWeight.w600,
              fontSize: compact ? 9 : null,
            ),
          ),
        ],
      ),
    );
  }
}

/// Converts HTML content to markdown if contentType indicates HTML (contentType == 1)
String _convertContentToMarkdown(SnPost post) {
  if (post.contentType == 1 && post.content != null) {
    return html2md.convert(post.content!);
  }
  return post.content ?? '';
}

IDisplayableCloudFile? _getThumbnailAttachment(SnPost post) {
  final thumbnailId = post.meta?['thumbnail'] as String?;
  if (thumbnailId == null) return null;
  try {
    return post.attachments.firstWhere((a) => a.id == thumbnailId);
  } catch (_) {
    return null;
  }
}

List<dynamic> _getPostEmbeds(SnPost post) {
  final embeds = post.meta?['embeds'];
  return embeds is List ? embeds : const <dynamic>[];
}

bool _urlsMatch(String? left, String? right) {
  if (left == null || right == null) return false;
  final leftUri = Uri.tryParse(left.trim());
  final rightUri = Uri.tryParse(right.trim());
  if (leftUri == null || rightUri == null) return left.trim() == right.trim();

  String normalizePath(Uri uri) {
    final path = uri.path.endsWith('/') && uri.path.length > 1
        ? uri.path.substring(0, uri.path.length - 1)
        : uri.path;
    return path.isEmpty ? '/' : path;
  }

  return leftUri.scheme == rightUri.scheme &&
      leftUri.host == rightUri.host &&
      leftUri.port == rightUri.port &&
      normalizePath(leftUri) == normalizePath(rightUri) &&
      leftUri.query == rightUri.query;
}

SnScrappedLink? _getBlogLinkPreview(SnPost post) {
  if (post.type != 2) return null;

  for (final embed in _getPostEmbeds(post)) {
    if (embed is! Map || embed['type'] != 'link') continue;
    final url = embed['url']?.toString();
    if (_urlsMatch(url, post.content)) {
      try {
        return SnScrappedLink.fromJson(Map<String, dynamic>.from(embed));
      } catch (_) {
        return null;
      }
    }
  }

  return null;
}

List<dynamic> _getVisibleEmbeds(SnPost post) {
  final embeds = _getPostEmbeds(post);
  if (post.type != 2 || (post.content?.isEmpty ?? true)) return embeds;

  return embeds.where((embed) {
    if (embed is! Map || embed['type'] != 'link') return true;
    return !_urlsMatch(embed['url']?.toString(), post.content);
  }).toList();
}

bool _shouldClampRegularPostBody(String content) {
  final normalized = content.trim();
  if (normalized.length > 420) return true;

  final lines = '\n'.allMatches(normalized).length + 1;
  return lines > 8;
}

String _truncateRegularPostBody(String content) {
  final normalized = content.trim();
  const maxChars = 420;
  const maxLines = 8;

  var end = normalized.length;
  if (normalized.length > maxChars) {
    end = maxChars;
  }

  var lineCount = 0;
  for (var i = 0; i < math.min(end, normalized.length); i++) {
    if (normalized[i] == '\n') {
      lineCount++;
      if (lineCount >= maxLines) {
        end = i;
        break;
      }
    }
  }

  final truncated = normalized.substring(0, end).trimRight();
  if (truncated.length == normalized.length) return normalized;

  return '$truncated...';
}

Widget _buildArticlePreviewCard(
  BuildContext context,
  SnPost post, {
  EdgeInsetsGeometry padding = const EdgeInsets.only(top: 4),
}) {
  final thumbnail = _getThumbnailAttachment(post);

  return Container(
    padding: padding,
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainerHigh,
      border: Border.all(
        color: Theme.of(context).dividerColor.withOpacity(0.5),
      ),
      borderRadius: const BorderRadius.all(Radius.circular(8)),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (thumbnail != null)
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            child: CloudFileWidget(item: thumbnail),
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
            if (post.title?.isNotEmpty ?? false)
              Text(
                post.title!,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold),
              ),
            if (post.description?.isNotEmpty ?? false)
              Text(
                post.description!,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
          ],
        ).padding(horizontal: 16, vertical: 12),
      ],
    ),
  );
}

Widget _buildBlogPreviewCard(
  BuildContext context,
  SnPost post, {
  EdgeInsetsGeometry padding = const EdgeInsets.only(top: 4),
}) {
  final preview = _getBlogLinkPreview(post);
  final uri = Uri.tryParse(preview?.url ?? post.content ?? '');
  final host = uri?.host ?? '';
  final imageUrl = preview?.imageUrl;
  final hasPreviewImage =
      imageUrl != null &&
      imageUrl.isNotEmpty &&
      imageUrl != preview?.faviconUrl;
  final title = post.title?.isNotEmpty ?? false ? post.title! : preview?.title;
  final description = post.description?.isNotEmpty ?? false
      ? post.description!
      : preview?.description;
  final faviconUrl = preview?.faviconUrl;

  return Container(
    padding: padding,
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainerHigh,
      border: Border.all(
        color: Theme.of(context).dividerColor.withOpacity(0.5),
      ),
      borderRadius: const BorderRadius.all(Radius.circular(8)),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (hasPreviewImage)
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            child: SizedBox(
              height: 180,
              child: UniversalImage(
                uri: imageUrl,
                fit: BoxFit.cover,
                useFallbackImage: false,
              ),
            ),
          ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Badge(
                  label: const Text('postBlog').tr(),
                  backgroundColor: Theme.of(context).colorScheme.tertiary,
                  textColor: Theme.of(context).colorScheme.onTertiary,
                ),
                const Spacer(),
                Icon(
                  Symbols.open_in_new,
                  size: 16,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ],
            ),
            const Gap(4),
            if (title?.isNotEmpty ?? false)
              Text(
                title!,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold),
              ),
            if (description?.isNotEmpty ?? false)
              Text(description!, style: Theme.of(context).textTheme.bodyMedium),
            if (host.isNotEmpty)
              Row(
                children: [
                  if (faviconUrl?.isNotEmpty ?? false) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: UniversalImage(
                        uri: faviconUrl!,
                        width: 14,
                        height: 14,
                        fit: BoxFit.cover,
                        useFallbackImage: false,
                      ),
                    ),
                    const Gap(6),
                  ],
                  Expanded(
                    child: Text(
                      host,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
          ],
        ).padding(horizontal: 16, vertical: 12),
      ],
    ),
  );
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
      parentId: json['parent_id'] as String?,
    );
  }
}

class PostThreadData {
  final List<ThreadedReplyNode> ancestors;
  final ThreadedReplyNode current;
  final List<ThreadedReplyNode> descendants;
  final bool hasMore;

  const PostThreadData({
    required this.ancestors,
    required this.current,
    required this.descendants,
    this.hasMore = false,
  });

  factory PostThreadData.fromJson(Map<String, dynamic> json) {
    return PostThreadData(
      ancestors:
          (json['ancestors'] as List<dynamic>?)
              ?.map(
                (e) => ThreadedReplyNode.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
      current: ThreadedReplyNode.fromJson(
        json['current'] as Map<String, dynamic>,
      ),
      descendants:
          (json['descendants'] as List<dynamic>?)
              ?.map(
                (e) => ThreadedReplyNode.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
      hasMore: json['has_more'] as bool? ?? false,
    );
  }

  List<ThreadedReplyNode> get allNodes => [
    ...ancestors,
    current,
    ...descendants,
  ];
}

Map<String?, List<ThreadedReplyNode>> buildThreadChildrenMap(
  Iterable<ThreadedReplyNode> nodes, {
  String? hiddenParentId,
  String? hiddenNodeId,
  String? hiddenNodeParentId,
}) {
  final childrenByParentId = <String?, List<ThreadedReplyNode>>{};
  for (final node in nodes) {
    if (node.post.id == hiddenNodeId) continue;
    final parentId = node.parentId == hiddenParentId
        ? hiddenNodeParentId
        : (node.parentId == hiddenNodeId ? hiddenNodeParentId : node.parentId);
    childrenByParentId.putIfAbsent(parentId, () => []).add(node);
  }
  return childrenByParentId;
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

    final client = ref.read(solarNetworkClientProvider);

    final response = await client.dio.get(
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
  final client = ref.watch(solarNetworkClientProvider);
  try {
    final result = await client.sphere.getPostReplies(
      postId: id,
      take: 1,
      order: 'popularity',
    );
    if (result.items.isEmpty) return null;
    return result.items.first;
  } catch (_) {
    return null;
  }
}

final postRepliesPreviewProvider = FutureProvider.autoDispose
    .family<List<SnPost>, String>((ref, id) async {
      final client = ref.watch(solarNetworkClientProvider);
      final result = await client.sphere.getPostReplies(
        postId: id,
        take: 3,
        order: 'popularity',
      );
      return result.items;
    });

class PostVisibilityHelpers {
  static IconData getVisibilityIcon(int visibility) {
    switch (visibility) {
      case 1:
        return Symbols.group;
      case 2:
        return Symbols.link_off;
      case 3:
        return Symbols.lock;
      case 4:
        return Symbols.favorite;
      case 5:
        return Symbols.public;
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
      case 4:
        return 'postVisibilityCloseFriends';
      case 5:
        return 'postVisibilityQuitePublic';
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
  final void Function(String)? onPostTap;
  const PostReplyPreview({
    super.key,
    required this.parent,
    this.isOpenable = false,
    this.isCompact = false,
    this.isAutoload = true,
    this.itemMaxWidth,
    this.onOpen,
    this.onPostTap,
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

  /// Builds a compact attachment preview list for inline display
  Widget _buildAttachmentPreview(
    BuildContext context,
    List<IDisplayableCloudFile> attachments,
  ) {
    const maxVisible = 3;
    final visibleAttachments = attachments.take(maxVisible).toList();
    final remainingCount = attachments.length - maxVisible;

    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 4,
      children: [
        for (final attachment in visibleAttachments)
          _buildAttachmentThumbnail(context, attachment),
        if (remainingCount > 0)
          _buildRemainingCountBadge(context, remainingCount),
      ],
    );
  }

  /// Builds a small thumbnail for a single attachment
  Widget _buildAttachmentThumbnail(
    BuildContext context,
    IDisplayableCloudFile attachment,
  ) {
    final isImage = attachment.mimeType.startsWith('image');
    final isVideo = attachment.mimeType.startsWith('video');
    final isAudio = attachment.mimeType.startsWith('audio');

    Widget content;
    if (isImage) {
      // Show actual image thumbnail using CloudFileWidget which handles auth properly
      content = ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: CloudFileWidget(
          item: attachment,
          fit: BoxFit.cover,
          noBlurhash: true,
        ),
      );
    } else if (isVideo) {
      content = _buildFileTypeIcon(context, attachment, icon: Symbols.videocam);
    } else if (isAudio) {
      content = _buildFileTypeIcon(
        context,
        attachment,
        icon: Symbols.audiotrack,
      );
    } else {
      content = _buildFileTypeIcon(context, attachment);
    }

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.5),
        ),
      ),
      child: content,
    );
  }

  /// Builds an icon-based representation for non-image files
  Widget _buildFileTypeIcon(
    BuildContext context,
    IDisplayableCloudFile attachment, {
    IconData? icon,
  }) {
    final fileIcon = icon ?? _getFileIcon(attachment.mimeType);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          fileIcon,
          size: 20,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        if (attachment.name.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              attachment.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 8,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
      ],
    );
  }

  /// Gets appropriate icon for MIME type
  IconData _getFileIcon(String? mimeType) {
    if (mimeType == null) return Symbols.insert_drive_file;
    if (mimeType.startsWith('image/')) return Symbols.image;
    if (mimeType.startsWith('video/')) return Symbols.videocam;
    if (mimeType.startsWith('audio/')) return Symbols.audiotrack;
    if (mimeType.startsWith('text/')) return Symbols.description;
    if (mimeType.contains('pdf')) return Symbols.picture_as_pdf;
    if (mimeType.contains('zip') || mimeType.contains('compressed')) {
      return Symbols.folder_zip;
    }
    return Symbols.attach_file;
  }

  /// Builds a badge showing remaining attachment count
  Widget _buildRemainingCountBadge(BuildContext context, int count) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.5),
        ),
      ),
      child: Center(
        child: Text(
          '+$count',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
      ),
    );
  }

  /// Builds a compact reaction preview for inline display
  Widget _buildCompactReactions(
    BuildContext context,
    WidgetRef ref,
    Map<String, int> reactions,
  ) {
    const maxVisible = 3;
    final sortedReactions = reactions.entries.where((e) => e.value > 0).toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final visibleReactions = sortedReactions.take(maxVisible).toList();
    final remainingCount = sortedReactions.length - maxVisible;

    if (visibleReactions.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: [
        for (final entry in visibleReactions)
          _buildCompactReactionChip(context, ref, entry.key, entry.value),
        if (remainingCount > 0)
          _buildRemainingReactionsBadge(context, remainingCount),
      ],
    );
  }

  /// Builds a single compact reaction chip
  Widget _buildCompactReactionChip(
    BuildContext context,
    WidgetRef ref,
    String symbol,
    int count,
  ) {
    final theme = Theme.of(context);
    final reactionInfo = kReactionTemplates[symbol];
    final hasSticker = _getReactionImageAvailable(symbol);
    final isCustom = symbol.contains('+');

    Widget icon;
    if (isCustom) {
      // Custom reactions use server-side sticker lookup
      final serverUrl = ref.read(serverUrlProvider);
      icon = ClipRRect(
        borderRadius: BorderRadius.circular(2),
        child: Image.network(
          '$serverUrl/sphere/stickers/lookup/$symbol/open',
          width: 16,
          height: 16,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) =>
              const Text('🏷️', style: TextStyle(fontSize: 11)),
        ),
      );
    } else if (hasSticker) {
      icon = Image.asset(
        'assets/images/stickers/$symbol.webp',
        width: 16,
        height: 16,
        fit: BoxFit.contain,
      );
    } else {
      // Fall back to emoji icon
      icon = Text(
        reactionInfo?.icon ?? '❓',
        style: const TextStyle(fontSize: 12, height: 1),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: theme.dividerColor.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 4,
        children: [
          icon,
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurfaceVariant,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a badge showing remaining reaction count
  Widget _buildRemainingReactionsBadge(BuildContext context, int count) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: theme.dividerColor.withOpacity(0.25)),
      ),
      child: Text(
        '+$count',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: theme.colorScheme.onSurfaceVariant,
          height: 1,
        ),
      ),
    );
  }

  /// Checks if reaction has a sticker image asset
  /// Based on kAvailableStickers in post_reaction_sheet.dart
  bool _getReactionImageAvailable(String symbol) {
    return kAvailableStickers.contains(symbol);
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

    final previewReplies = isOpenable
        ? null
        : ref.watch(postRepliesPreviewProvider(parent.id));

    Widget buildReplyNode(
      ThreadedReplyNode node,
      double maxWidth, {
      double indent = 24,
    }) {
      final post = node.post;
      final children = repliesState.getChildrenOf(post.id);
      final showReactions = post.reactionsCount.isNotEmpty;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 4,
                children: [
                  Row(
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
                      else if (post.attachments.isNotEmpty)
                        Expanded(
                          child: _buildAttachmentPreview(
                            context,
                            post.attachments,
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
                  if (showReactions)
                    Padding(
                      padding: const EdgeInsets.only(left: 32),
                      child: _buildCompactReactions(
                        context,
                        ref,
                        post.reactionsCount,
                      ),
                    ),
                  if (post.repliesCount > children.length)
                    Padding(
                      padding: const EdgeInsets.only(left: 32),
                      child: Text('repliesCount')
                          .plural(post.repliesCount)
                          .fontSize(12)
                          .opacity(0.7),
                    ),
                ],
              ),
            ),
            onTap: () {
              onOpen?.call();
              if (onPostTap != null) {
                onPostTap!(post.id);
              } else {
                context.router.push(PostDetailRoute(id: post.id));
              }
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
          : (previewReplies!).map(
              data: (data) => ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 4,
                  children: [
                    for (final post in data.value) ...[
                      Row(
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
                              ),
                            )
                          else if (post.attachments.isNotEmpty)
                            Expanded(
                              child: _buildAttachmentPreview(
                                context,
                                post.attachments,
                              ).padding(bottom: 4),
                            )
                          else
                            Expanded(
                              child: Text(
                                'postHasAttachments',
                              ).plural(post.attachments.length),
                            ),
                        ],
                      ),
                      if (post.reactionsCount.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(left: 32),
                          child: _buildCompactReactions(
                            context,
                            ref,
                            post.reactionsCount,
                          ),
                        ),
                      if (post.repliesCount > 0)
                        Padding(
                          padding: const EdgeInsets.only(left: 32),
                          child: Text('repliesCount')
                              .plural(post.repliesCount)
                              .fontSize(12)
                              .opacity(0.7),
                        ),
                    ],
                    if (parent.repliesCount > data.value.length)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          'repliesCount'.plural(parent.repliesCount),
                          style: Theme.of(context).textTheme.bodySmall,
                        ).opacity(0.8),
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

class ReferencedPostWidget extends HookConsumerWidget {
  final SnPost item;
  final bool isInteractive;
  final EdgeInsets renderingPadding;
  final bool isCollapsible;
  final bool hideOverlay;
  final void Function(String)? onPostTap;

  const ReferencedPostWidget({
    super.key,
    required this.item,
    this.isInteractive = true,
    this.renderingPadding = EdgeInsets.zero,
    this.isCollapsible = true,
    this.hideOverlay = false,
    this.onPostTap,
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
                hideOverlay: hideOverlay,
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
                      child: referencePost.type == 1
                          ? _buildArticlePreviewCard(context, referencePost)
                          : referencePost.type == 2
                          ? _buildBlogPreviewCard(context, referencePost)
                          : Builder(
                              builder: (context) {
                                final referenceContent =
                                    _convertContentToMarkdown(referencePost);
                                final shouldTruncateReferenceBody =
                                    (referencePost.content?.isNotEmpty ??
                                        false) &&
                                    _shouldClampRegularPostBody(
                                      referenceContent,
                                    );
                                final referencePreviewContent =
                                    shouldTruncateReferenceBody
                                    ? _truncateRegularPostBody(referenceContent)
                                    : (referencePost.isTruncated
                                          ? '$referenceContent...'
                                          : referenceContent);

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (referencePost.title?.isNotEmpty ??
                                        false)
                                      Text(
                                        referencePost.title!,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onSurface,
                                        ),
                                      ).padding(top: 8, bottom: 4),
                                    if (referencePost.description?.isNotEmpty ??
                                        false)
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
                                    if (referencePost.content?.isNotEmpty ??
                                        false)
                                      MarkdownTextContent(
                                        content: referencePreviewContent,
                                        textStyle: const TextStyle(
                                          fontSize: 14,
                                        ),
                                        isSelectable: false,
                                        linesMargin: referencePost.type == 0
                                            ? const EdgeInsets.only(bottom: 4)
                                            : null,
                                        attachments: referencePost.attachments,
                                        noMentionChip:
                                            referencePost.fediverseUri != null,
                                      ).padding(top: 4),
                                    if (referencePost.isTruncated ||
                                        shouldTruncateReferenceBody)
                                      const PostTruncateHint(
                                        isCompact: true,
                                        margin: EdgeInsets.only(
                                          top: 4,
                                          bottom: 4,
                                        ),
                                      ),
                                    if (referencePost.attachments.isNotEmpty)
                                      CloudFileList(
                                        files: referencePost.attachments,
                                        padding: const EdgeInsets.only(top: 8),
                                        maxHeight: 240,
                                        disableZoomIn: true,
                                      ),
                                  ],
                                );
                              },
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
      onTap: () {
        if (onPostTap != null) {
          onPostTap!(referencePost.id);
        } else {
          context.router.push(PostDetailRoute(id: referencePost.id));
        }
      },
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
      final publisher = post.publisher!;
      return publisher.realmNick?.trim().isNotEmpty == true
          ? publisher.realmNick!.trim()
          : publisher.nick;
    }
    // Handle actor case
    if (post.actor != null) {
      return post.actor!.displayName ?? post.actor!.username;
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

  SnRealmLabel? _getRealmLabel(SnPost post) {
    return post.publisher?.realmLabel;
  }

  Widget _buildHandleChip(BuildContext context, SnPost post) {
    final theme = Theme.of(context);

    // Handle publisher case
    if (post.publisher != null) {
      return HandleChip(
        handle: post.publisher!.name,
        allowCopy: false,
        maxLines: 1,
        textStyle: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
        borderRadius: 8,
      );
    }

    // Handle actor case (fediverse) - always show as remote with domain
    if (post.actor != null) {
      return HandleChip(
        handle: post.actor!.username,
        domain: post.actor!.instance.domain,
        isRemote: true,
        allowCopy: false,
        maxLines: 1,
        textStyle: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
        borderRadius: 8,
      );
    }

    return const SizedBox.shrink();
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
                  onTap:
                      isInteractive &&
                          (_getPublisherName(item) != null ||
                              item.actor != null)
                      ? () {
                          if (item.publisher != null) {
                            showPublisherProfileAttentionModal(
                              item.publisher!.name,
                            );
                          } else if (item.actor != null) {
                            context.router.push(
                              FediverseActorProfileRoute(
                                id: item.actor!.id,
                                fullHandle: item.actor!.fullHandle,
                              ),
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
                  if (item.boostedBy != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          const Icon(Symbols.repeat, size: 14),
                          const Gap(4),
                          ActorPictureWidget(actor: item.boostedBy!, radius: 8),
                          const Gap(4),
                          Text(
                            'boostedBy'.tr(
                              args: ['@${item.boostedBy!.username}'],
                            ),
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                          ),
                        ],
                      ),
                    ),
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
                                suffixWidgets: [
                                  if (item.publisher?.isModerateSubscription ??
                                      false)
                                    Tooltip(
                                      message: 'publisherGatekeptHintShort'
                                          .tr(),
                                      child: Icon(
                                        Symbols.lock,
                                        size: 14,
                                        fill: 1,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.error,
                                      ),
                                    ),
                                ],
                              )
                            : Text(
                                _getDisplayName(item),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ).bold(),
                      ),
                      if (_getRealmLabel(item) != null)
                        RealmLabelWidget(
                          label: _getRealmLabel(item)!,
                          fontSize: 9,
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
                              : _buildHandleChip(context, item),
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
                        ? (item.publishedAt ?? item.createdAt)?.formatRelative(
                                context,
                              ) ??
                              ''
                        : (item.publishedAt ?? item.createdAt)
                                  ?.formatSystem() ??
                              '',
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
    final visibleEmbeds = _getVisibleEmbeds(item);
    final useCompactArticlePreview =
        item.type == 1 && (!isFullPost || item.forwardedPostId != null);
    final useCompactBlogPreview =
        item.type == 2 && (!isFullPost || item.forwardedPostId != null);
    final resolvedContent = _convertContentToMarkdown(item);
    final shouldClampRegularBody =
        !isFullPost &&
        item.type == 0 &&
        (item.content?.isNotEmpty ?? false) &&
        _shouldClampRegularPostBody(resolvedContent);
    final previewContent = shouldClampRegularBody
        ? _truncateRegularPostBody(resolvedContent)
        : (item.isTruncated ? '$resolvedContent...' : resolvedContent);
    final baseTextStyle = TextStyle(
      fontSize:
          Theme.of(context).textTheme.bodyMedium!.fontSize! * (textScale ?? 1),
    );

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
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (tag.isProtected) ...[
                      const Icon(Symbols.lock, size: 14),
                      const Gap(2),
                    ],
                    Text('#${tag.name ?? tag.slug}'),
                  ],
                ),
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
            if (!item.isCached) Text('Uncached'),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (useCompactArticlePreview)
          Padding(
            padding: EdgeInsets.only(
              top: 4,
              left: renderingPadding.horizontal,
              right: renderingPadding.horizontal,
            ),
            child: _buildArticlePreviewCard(
              context,
              item,
              padding: EdgeInsets.zero,
            ),
          )
        else if (useCompactBlogPreview)
          Padding(
            padding: EdgeInsets.only(
              top: 4,
              left: renderingPadding.horizontal,
              right: renderingPadding.horizontal,
            ),
            child: _buildBlogPreviewCard(
              context,
              item,
              padding: EdgeInsets.zero,
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
                  linesMargin: item.type == 1 && !useCompactArticlePreview
                      ? const EdgeInsets.symmetric(vertical: 8)
                      : const EdgeInsets.symmetric(vertical: 4),
                  textStyle: baseTextStyle,
                  content: previewContent,
                  isSelectable: isTextSelectable,
                  attachments: item.attachments,
                  noMentionChip: item.fediverseUri != null,
                ),
                ?translationSection,
              ],
            ),
          ),
        if ((item.isTruncated && item.type != 1 && item.type != 2) ||
            shouldClampRegularBody)
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
        if (item.attachments.isNotEmpty &&
            item.type != 1 &&
            item.type != 2 &&
            !hideAttachments)
          CloudFileList(
            files: item.attachments,
            sourcePost: item,
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
        if (visibleEmbeds.isNotEmpty)
          EmbedListWidget(
            embeds: visibleEmbeds,
            isInteractive: isInteractive,
            isFullPost: isFullPost,
            renderingPadding: renderingPadding,
          ),
      ],
    );
  }
}
