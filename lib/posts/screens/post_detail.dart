import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:auto_route/auto_route.dart';
import 'package:dio/dio.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island_ui_foundation/island_ui_foundation.dart'
    show DraggableOverlaySheet;
import 'package:island/core/config.dart';
import 'package:island/core/network.dart';
import 'package:island/core/translate.dart';
import 'package:island/accounts/account_pod.dart';
import 'package:island/posts/pods/bookmarks.dart';
import 'package:island/core/services/time.dart';
import 'package:island/posts/compose.dart';
import 'package:island/core/services/responsive.dart';
import 'package:island/posts/screens/compose_blog.dart';
import 'package:island/posts/widgets/compose/compose_dialog.dart';
import 'package:island/posts/widgets/compose/embed_view_renderer.dart';
import 'package:island/posts/widgets/compose/post_award_history_sheet.dart';
import 'package:island/posts/widgets/compose/post_award_sheet.dart';
import 'package:island/posts/widgets/compose/post_item.dart';
import 'package:island/posts/widgets/compose/post_pin_sheet.dart';
import 'package:island/posts/widgets/compose/post_quick_reply.dart';
import 'package:island/posts/widgets/compose/post_replies.dart';
import 'package:island/posts/widgets/compose/post_interactions.dart';
import 'package:island/posts/widgets/post_detail_content.dart';
import 'package:island/posts/widgets/publisher_collection_info.dart';
import 'package:island/posts/widgets/compose/post_shared.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:island/tickets/widgets/ticket_fire.dart';
import 'package:island/route.gr.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/shared/widgets/attention_modal.dart';
import 'package:island/shared/widgets/app_scaffold.dart' hide PageBackButton;
import 'package:island/core/widgets/content/cloud_file_collection.dart';
import 'package:island/shared/widgets/layouts/attention_modal_scaffold.dart';
import 'package:island/shared/widgets/layouts/sheet_scaffold.dart';
import 'package:island/shared/widgets/extended_refresh_indicator.dart';
import 'package:island/shared/widgets/response.dart';
import 'package:island/core/utils/share_utils.dart';
import 'package:island/sharing/share_sheet.dart';
import 'package:island/shared/widgets/content/image.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

part 'post_detail.g.dart';

@riverpod
Future<SnPost?> post(Ref ref, String id) async {
  final client = ref.watch(solarNetworkClientProvider);
  return await client.sphere.getPost(id);
}

final postStateProvider =
    NotifierProvider.family<PostState, AsyncValue<SnPost?>, String>(
      PostState.new,
    );

class PostState extends Notifier<AsyncValue<SnPost?>> {
  final String arg;

  PostState(this.arg);

  @override
  AsyncValue<SnPost?> build() {
    ref.listen<AsyncValue<SnPost?>>(
      postProvider(arg),
      (_, next) => state = next,
    );
    return const AsyncValue.loading();
  }

  void updatePost(SnPost? newPost) {
    if (newPost != null) {
      state = AsyncData(newPost);
    }
  }
}

bool _isMediaPost(SnPost? post) {
  return post != null && post.type == 0 && post.attachments.isNotEmpty;
}

class CollectionNeighborArgs {
  final String publisherName;
  final String slug;
  final String postId;
  final bool isNext;

  const CollectionNeighborArgs({
    required this.publisherName,
    required this.slug,
    required this.postId,
    required this.isNext,
  });

  @override
  bool operator ==(Object other) {
    return other is CollectionNeighborArgs &&
        other.publisherName == publisherName &&
        other.slug == slug &&
        other.postId == postId &&
        other.isNext == isNext;
  }

  @override
  int get hashCode => Object.hash(publisherName, slug, postId, isNext);
}

final collectionNeighborProvider = FutureProvider.autoDispose
    .family<SnPost?, CollectionNeighborArgs>((ref, args) async {
      final client = ref.watch(solarNetworkClientProvider);
      try {
        return args.isNext
            ? await client.sphere.getPublisherCollectionNextPost(
                publisherName: args.publisherName,
                slug: args.slug,
                postId: args.postId,
              )
            : await client.sphere.getPublisherCollectionPrevPost(
                publisherName: args.publisherName,
                slug: args.slug,
                postId: args.postId,
              );
      } catch (err) {
        if (err is DioException && err.response?.statusCode == 404) {
          return null;
        }
        rethrow;
      }
    });

const _postDetailMaxWidth = 640.0;

/// Posts shorter than this are not worth a translate action.
const _minTranslatableLength = 20;

String? _getBlogUrl(SnPost post) {
  final candidates = [post.content, post.embedView?.uri];
  for (final candidate in candidates) {
    final uri = Uri.tryParse(candidate ?? '');
    if (uri != null && uri.hasScheme && uri.host.isNotEmpty) {
      return uri.toString();
    }
  }
  return null;
}

String? extractInternalPostIdFromUri(Uri url) {
  if (url.scheme == 'solian' &&
      url.host == 'posts' &&
      url.pathSegments.isNotEmpty) {
    return url.pathSegments.first;
  }
  if ((url.scheme == 'http' || url.scheme == 'https') &&
      url.host == 'solian.app' &&
      url.pathSegments.length >= 2 &&
      url.pathSegments.first == 'posts') {
    return url.pathSegments[1];
  }
  return null;
}

Future<void> showPostDetailAttentionModal(String id) async {
  showAttentionModal(
    id: 'post-detail:$id',
    replaceIfExists: true,
    barrierDismissible: true,
    builder: (context, dismiss) =>
        PostDetailAttentionModal(id: id, onDismiss: dismiss),
  );
}

void showPostCollectionAttentionModal(
  SnPost post,
  SnPostCollection collection,
) {
  final publisherName = post.publisher?.name;
  if (publisherName == null || publisherName.isEmpty) return;

  showAttentionModal(
    id: 'post-collection:${post.id}:${collection.slug}',
    replaceIfExists: true,
    barrierDismissible: true,
    builder: (_, dismiss) => PublisherCollectionDetailSheet(
      publisherName: publisherName,
      collection: collection,
      onDismiss: dismiss,
    ),
  );
}

void showPostCollectionBrowserAttentionModal(SnPost post) {
  showAttentionModal(
    id: 'post-collection-browser:${post.id}',
    replaceIfExists: true,
    barrierDismissible: true,
    builder: (_, dismiss) =>
        _PublicCollectionBrowserSheet(post: post, onDismiss: dismiss),
  );
}

bool openPostDetailAttentionModalForUri(Uri url) {
  final postId = extractInternalPostIdFromUri(url);
  if (postId == null) return false;
  showPostDetailAttentionModal(postId);
  return true;
}

class PostRealmBadge extends StatelessWidget {
  final SnRealm realm;

  const PostRealmBadge({super.key, required this.realm});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        dense: true,
        leading: realm.picture != null
            ? ProfilePictureWidget(file: realm.picture, radius: 16)
            : CircleAvatar(
                radius: 16,
                backgroundColor: theme.colorScheme.primaryContainer,
                child: Icon(
                  Symbols.public,
                  size: 18,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
        title: Text(
          realm.name,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          'realm'.tr(),
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: FilledButton.tonal(
          onPressed: () {
            context.router.push(RealmDetailRoute(slug: realm.slug));
          },
          child: Text('open'.tr()),
        ),
      ),
    );
  }
}

class PostActionButtons extends HookConsumerWidget {
  final SnPost post;
  final EdgeInsets renderingPadding;
  final bool noBottomPadding;
  final VoidCallback? onRefresh;
  final Function(SnPost)? onUpdate;
  final ValueChanged<String>? onTranslate;

  const PostActionButtons({
    super.key,
    required this.post,
    this.renderingPadding = EdgeInsets.zero,
    this.noBottomPadding = false,
    this.onRefresh,
    this.onUpdate,
    this.onTranslate,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final user = ref.watch(userInfoProvider);
    final isAuthor =
        user.value != null && user.value?.id == post.publisher?.accountId;

    String formatScore(int score) {
      if (score >= 1000000) {
        double value = score / 1000000;
        return value % 1 == 0
            ? '${value.toInt()}m'
            : '${value.toStringAsFixed(1)}m';
      } else if (score >= 1000) {
        double value = score / 1000;
        return value % 1 == 0
            ? '${value.toInt()}k'
            : '${value.toStringAsFixed(1)}k';
      } else {
        return score.toString();
      }
    }

    final bookmarkStatus = ref.watch(bookmarkStatusProvider(post.id));
    final isBookmarked = bookmarkStatus.when(
      data: (bookmark) => bookmark != null,
      loading: () => false,
      error: (_, _) => false,
    );

    final hairline = theme.colorScheme.outline.withOpacity(0.12);
    final idleColor = theme.colorScheme.onSurfaceVariant;

    /// A slot on the response rail: icon + label, with an optional live
    /// counter in tabular figures. The rail reads as a meter for the post's
    /// circulation rather than a toolbar.
    Widget buildRailSlot({
      required IconData icon,
      required String label,
      required VoidCallback? onPressed,
      VoidCallback? onLongPress,
      bool isSelected = false,
      String? count,
      String? tooltip,
    }) {
      final inkColor = isSelected ? theme.colorScheme.primary : idleColor;
      return Tooltip(
        message: tooltip ?? label,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onPressed,
          onLongPress: onLongPress,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 15),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 150),
                  switchInCurve: Curves.easeOut,
                  switchOutCurve: Curves.easeIn,
                  child: Icon(
                    icon,
                    key: ValueKey(icon),
                    size: 18,
                    color: inkColor,
                  ),
                ),
                const Gap(6),
                Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: inkColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (count != null) ...[
                  const Gap(4),
                  Text(
                    count,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    }

    /// Icon-first response rail for compact screens. Labels stay available
    /// through semantics/tooltips, while the fixed slots avoid wrapping the
    /// primary actions into an uneven grid.
    Widget buildCompactRailSlot({
      required IconData icon,
      required String label,
      required VoidCallback? onPressed,
      VoidCallback? onLongPress,
      bool isSelected = false,
      String? count,
      String? tooltip,
    }) {
      final inkColor = isSelected ? theme.colorScheme.primary : idleColor;
      return Expanded(
        child: Tooltip(
          message: tooltip ?? label,
          child: Semantics(
            button: true,
            label: label,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: onPressed,
              onLongPress: onLongPress,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                height: 58,
                decoration: BoxDecoration(
                  color: isSelected
                      ? theme.colorScheme.primary.withOpacity(0.12)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, size: 20, color: inkColor),
                    const SizedBox(height: 1),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        label,
                        maxLines: 1,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: inkColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (count != null)
                      Text(
                        count,
                        maxLines: 1,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: inkColor.withOpacity(0.8),
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    /// Quiet icon + text action for the context strip and author console.
    /// A null [onPressed] renders the action disabled and dimmed.
    Widget buildGhostAction({
      required IconData icon,
      required String label,
      required VoidCallback? onPressed,
      VoidCallback? onLongPress,
      Color? color,
      String? tooltip,
    }) {
      final enabled = onPressed != null;
      final inkColor = enabled
          ? (color ?? idleColor)
          : theme.colorScheme.onSurfaceVariant.withOpacity(0.38);
      return Tooltip(
        message: tooltip ?? label,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onPressed,
          onLongPress: onLongPress,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: 6,
              children: [
                Icon(icon, size: 16, color: inkColor),
                Text(
                  label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: inkColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // ---- Band 1: the response rail. Five equal slots, hairline-divided
    // when the width allows; Reply carries the live conversation count and
    // Award carries the points earned.
    final railSlots = <Widget>[
      buildRailSlot(
        icon: Symbols.reply,
        label: 'reply'.tr(),
        count: post.repliesCount > 0 ? formatScore(post.repliesCount) : null,
        onPressed: () {
          PostComposeDialog.show(
            context,
            initialState: PostComposeInitialState(replyingTo: post),
          );
        },
      ),
      buildRailSlot(
        icon: Symbols.forward,
        label: 'forward'.tr(),
        onPressed: () {
          PostComposeDialog.show(
            context,
            initialState: PostComposeInitialState(forwardingTo: post),
          );
        },
      ),
      buildRailSlot(
        icon: Symbols.emoji_events,
        label: post.awardedScore > 0
            ? '${formatScore(post.awardedScore)} pts'
            : 'award'.tr(),
        tooltip: 'award'.tr(),
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            useRootNavigator: true,
            builder: (context) => PostAwardSheet(post: post),
          );
        },
        onLongPress: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (context) => PostSupportHistorySheet(postId: post.id),
          );
        },
      ),
      buildRailSlot(
        icon: isBookmarked ? Symbols.bookmark_added : Symbols.bookmark,
        label: isBookmarked ? 'unbookmark'.tr() : 'bookmark'.tr(),
        isSelected: isBookmarked,
        onPressed: () async {
          try {
            await toggleBookmark(
              ref,
              postId: post.id,
              currentlyBookmarked: isBookmarked,
            );
          } catch (err) {
            showErrorAlert(err);
          }
        },
      ),
      buildRailSlot(
        icon: Symbols.share,
        label: 'share'.tr(),
        onPressed: () => _showPostShareSheet(context, ref, post),
      ),
    ];

    final compactRailSlots = <Widget>[
      buildCompactRailSlot(
        icon: Symbols.reply,
        label: 'reply'.tr(),
        count: post.repliesCount > 0 ? formatScore(post.repliesCount) : null,
        onPressed: () {
          PostComposeDialog.show(
            context,
            initialState: PostComposeInitialState(replyingTo: post),
          );
        },
      ),
      buildCompactRailSlot(
        icon: Symbols.forward,
        label: 'forward'.tr(),
        onPressed: () {
          PostComposeDialog.show(
            context,
            initialState: PostComposeInitialState(forwardingTo: post),
          );
        },
      ),
      buildCompactRailSlot(
        icon: Symbols.emoji_events,
        label: 'award'.tr(),
        count: post.awardedScore > 0
            ? '${formatScore(post.awardedScore)} pts'
            : null,
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            useRootNavigator: true,
            builder: (context) => PostAwardSheet(post: post),
          );
        },
        onLongPress: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (context) => PostSupportHistorySheet(postId: post.id),
          );
        },
      ),
      buildCompactRailSlot(
        icon: isBookmarked ? Symbols.bookmark_added : Symbols.bookmark,
        label: isBookmarked ? 'unbookmark'.tr() : 'bookmark'.tr(),
        isSelected: isBookmarked,
        onPressed: () async {
          try {
            await toggleBookmark(
              ref,
              postId: post.id,
              currentlyBookmarked: isBookmarked,
            );
          } catch (err) {
            showErrorAlert(err);
          }
        },
      ),
      buildCompactRailSlot(
        icon: Symbols.share,
        label: 'share'.tr(),
        onPressed: () => _showPostShareSheet(context, ref, post),
      ),
    ];

    // ---- Band 2: context strip. Understanding the post, not acting on it.
    final translatableText = post.content?.trim() ?? '';
    final isTranslatable = translatableText.length >= _minTranslatableLength;
    final contextActions = <Widget>[
      buildGhostAction(
        icon: Symbols.forum,
        label: 'thread'.tr(),
        onPressed: () => _showPostThreadSheet(context, post),
      ),
      if (post.publisherCollections.isNotEmpty)
        buildGhostAction(
          icon: Symbols.collections,
          label: 'collections'.tr(),
          onPressed: () => showPostCollectionBrowserAttentionModal(post),
        ),
      if (onTranslate != null)
        buildGhostAction(
          icon: Symbols.translate,
          label: 'translate'.tr(),
          tooltip: isTranslatable ? null : 'untranslatable'.tr(),
          onPressed: isTranslatable
              ? () => onTranslate!(translatableText)
              : null,
        ),
    ];

    // ---- Band 3: author console. Rare management, kept out of the social
    // rail; delete sits apart in the danger color.
    final authorActions = <Widget>[
      buildGhostAction(
        icon: Symbols.edit,
        label: 'edit'.tr(),
        onPressed: () {
          if (post.type == 1) {
            context.router.push(ArticleEditRoute(id: post.id)).then((value) {
              if (value != null) {
                onRefresh?.call();
              }
            });
          } else if (post.type == 2) {
            BlogComposeDialog.show(context, originalPost: post).then((value) {
              if (value != null) {
                onRefresh?.call();
              }
            });
          } else {
            PostComposeDialog.show(context, originalPost: post).then((value) {
              if (value == true) {
                onRefresh?.call();
              }
            });
          }
        },
      ),
      buildGhostAction(
        icon: post.pinMode == null ? Symbols.keep : Symbols.keep_off,
        label: post.pinMode == null ? 'pinPost'.tr() : 'unpinPost'.tr(),
        onPressed: () {
          if (post.pinMode == null) {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (context) => PostPinSheet(post: post),
            ).then((value) {
              if (value is int) {
                onUpdate?.call(post.copyWith(pinMode: value));
              }
            });
          } else {
            showConfirmAlert('unpinPostHint'.tr(), 'unpinPost'.tr()).then((
              confirm,
            ) async {
              if (confirm) {
                final client = ref.watch(solarNetworkClientProvider);
                try {
                  if (context.mounted) showLoadingModal(context);
                  await client.sphere.unpinPost(post.id);
                  onUpdate?.call(post.copyWith(pinMode: null));
                } catch (err) {
                  showErrorAlert(err);
                } finally {
                  if (context.mounted) hideLoadingModal(context);
                }
              }
            });
          }
        },
      ),
      buildGhostAction(
        icon: Symbols.delete,
        label: 'delete'.tr(),
        color: theme.colorScheme.error,
        onPressed: () {
          showConfirmAlert(
            'deletePostHint'.tr(),
            'deletePost'.tr(),
            isDanger: true,
          ).then((confirm) {
            if (confirm) {
              final client = ref.watch(solarNetworkClientProvider);
              client.sphere
                  .deletePost(post.id)
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
    ];

    return Padding(
      padding: noBottomPadding
          ? renderingPadding
          : renderingPadding.copyWith(
              bottom: 4 + renderingPadding.vertical + renderingPadding.bottom,
            ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 8,
        children: [
          // The compact rail keeps the five primary actions on one calm,
          // predictable row instead of wrapping labels into a second grid.
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth >= 500) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: 8,
                  children: [
                    Container(
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: SizedBox(
                        height: 48,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            for (var i = 0; i < railSlots.length; i++) ...[
                              if (i > 0) Container(width: 1, color: hairline),
                              Expanded(
                                child: Center(
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: railSlots[i],
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    if (contextActions.isNotEmpty)
                      Wrap(spacing: 2, runSpacing: 2, children: contextActions),
                    if (isAuthor && authorActions.isNotEmpty)
                      Align(
                        alignment: Alignment.centerRight,
                        child: Wrap(
                          spacing: 2,
                          runSpacing: 2,
                          children: authorActions,
                        ),
                      ),
                  ],
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 6,
                children: [
                  Container(
                    clipBehavior: Clip.antiAlias,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerLow,
                      border: Border.all(
                        color: theme.colorScheme.outlineVariant.withOpacity(
                          0.45,
                        ),
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(children: compactRailSlots),
                  ),
                  if (contextActions.isNotEmpty)
                    Material(
                      type: MaterialType.transparency,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: Row(spacing: 2, children: contextActions),
                      ),
                    ),
                  if (isAuthor && authorActions.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.only(top: 6),
                      decoration: BoxDecoration(
                        border: Border(top: BorderSide(color: hairline)),
                      ),
                      child: Material(
                        type: MaterialType.transparency,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          child: Row(spacing: 2, children: authorActions),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class PostCollectionNavigation extends HookConsumerWidget {
  final SnPost post;

  const PostCollectionNavigation({super.key, required this.post});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collections = post.publisherCollections;
    final publisherName = post.publisher?.name;
    if (collections.isEmpty || publisherName == null || publisherName.isEmpty) {
      return const SizedBox.shrink();
    }
    void openCollectionBrowser() {
      showPostCollectionBrowserAttentionModal(post);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: openCollectionBrowser,
          child: Text('postCollectionsOfHint').tr().fontSize(12).opacity(0.7),
        ),
        const Gap(8),
        _PostCollectionNeighborGroup(
          post: post,
          collection: collections.first,
          publisherName: publisherName,
        ),
        if (collections.length > 1) ...[
          const Gap(8),
          TextButton.icon(
            onPressed: openCollectionBrowser,
            icon: const Icon(Symbols.collections, size: 18),
            label: Text('Found in +${collections.length - 1} collections'),
          ),
        ],
      ],
    );
  }
}

class _PublicCollectionBrowserSheet extends StatelessWidget {
  final SnPost post;
  final VoidCallback onDismiss;

  const _PublicCollectionBrowserSheet({
    required this.post,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final collections = post.publisherCollections;
    return AttentionModalScaffold(
      titleText: 'postCollections'.tr(),
      onDismiss: onDismiss,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: collections.length,
        separatorBuilder: (_, _) => const Gap(16),
        itemBuilder: (context, index) {
          final collection = collections[index];
          return _PublicCollectionBrowserCard(
            post: post,
            collection: collection,
            onTap: () {
              showPostCollectionAttentionModal(post, collection);
            },
          );
        },
      ),
    );
  }
}

class _PublicCollectionBrowserCard extends StatelessWidget {
  final SnPostCollection collection;
  final SnPost post;
  final VoidCallback onTap;

  const _PublicCollectionBrowserCard({
    required this.collection,
    required this.post,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title = collection.name?.isNotEmpty == true
        ? collection.name!
        : collection.slug;
    final titleStyle = theme.textTheme.titleMedium?.copyWith(
      color: Colors.white,
      shadows: const [
        Shadow(color: Colors.black54, blurRadius: 10, offset: Offset(0, 1)),
      ],
    );
    final descStyle = theme.textTheme.bodySmall?.copyWith(
      color: Colors.white70,
      shadows: const [
        Shadow(color: Colors.black54, blurRadius: 10, offset: Offset(0, 1)),
      ],
    );

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: AspectRatio(
          aspectRatio: 16 / 7,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (collection.background != null)
                CloudFileWidget(item: collection.background!, fit: BoxFit.cover)
              else
                Container(color: theme.colorScheme.surfaceContainerHighest),
              Positioned(
                left: 16,
                bottom: 16,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    ProfilePictureWidget(
                      file: collection.icon,
                      radius: 24,
                      fallbackIcon: Symbols.collections,
                    ),
                    const Gap(12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          onTap: onTap,
                          child: Text(title, style: titleStyle),
                        ),
                        if (collection.description?.isNotEmpty ?? false)
                          Text(
                            collection.description!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: descStyle,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const Positioned(
                right: 12,
                top: 12,
                child: Icon(Symbols.chevron_right, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PostCollectionNeighborGroup extends ConsumerWidget {
  final SnPost post;
  final SnPostCollection collection;
  final String publisherName;

  const _PostCollectionNeighborGroup({
    required this.post,
    required this.collection,
    required this.publisherName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final previousPost = ref.watch(
      collectionNeighborProvider(
        CollectionNeighborArgs(
          publisherName: publisherName,
          slug: collection.slug,
          postId: post.id,
          isNext: true,
        ),
      ),
    );
    final nextPost = ref.watch(
      collectionNeighborProvider(
        CollectionNeighborArgs(
          publisherName: publisherName,
          slug: collection.slug,
          postId: post.id,
          isNext: false,
        ),
      ),
    );

    final title = collection.name?.isNotEmpty == true
        ? collection.name!
        : collection.slug;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          child: Row(
            children: [
              ProfilePictureWidget(
                file: collection.icon,
                radius: 16,
                fallbackIcon: Symbols.collections,
              ),
              const Gap(12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(title, style: theme.textTheme.titleSmall),
                    if (collection.description?.isNotEmpty ?? false)
                      Text(
                        collection.description!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
            ],
          ),
          onTap: () {
            showPostCollectionAttentionModal(post, collection);
          },
        ),
        const Gap(8),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 8,
            children: [
              Expanded(
                child: _PostNeighborCard(
                  label: 'nextPost'.tr(),
                  post: nextPost.value,
                  emptyTitle: 'noPost'.tr(),
                  emptyDescription: 'notPublishedYet'.tr(),
                  alignRight: false,
                ),
              ),
              Expanded(
                child: _PostNeighborCard(
                  label: 'previousPost'.tr(),
                  post: previousPost.value,
                  emptyTitle: 'noPost'.tr(),
                  emptyDescription: 'earliestOne'.tr(),
                  alignRight: true,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PostNeighborCard extends StatelessWidget {
  final String label;
  final SnPost? post;
  final String emptyTitle;
  final String emptyDescription;
  final bool alignRight;

  const _PostNeighborCard({
    required this.label,
    required this.post,
    required this.emptyTitle,
    required this.emptyDescription,
    required this.alignRight,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final postItem = post;
    final title = postItem == null
        ? emptyTitle
        : (postItem.title?.isNotEmpty == true ? postItem.title! : 'Untitled');
    final subtitle = postItem?.description?.trim();
    final publisherName =
        postItem?.publisher?.nick ??
        postItem?.publisher?.name ??
        postItem?.publisherId;
    final publishedAt = postItem?.publishedAt ?? postItem?.createdAt;
    final crossAxisAlignment = alignRight
        ? CrossAxisAlignment.end
        : CrossAxisAlignment.start;
    final textAlign = alignRight ? TextAlign.right : TextAlign.left;

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: postItem == null
            ? null
            : () {
                context.router.replace(PostDetailRoute(id: postItem.id));
              },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: crossAxisAlignment,
            children: [
              Text(
                label,
                textAlign: textAlign,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
              const Gap(4),
              Text(
                title,
                textAlign: textAlign,
                style: theme.textTheme.titleSmall,
              ),
              if (subtitle != null && subtitle.isNotEmpty) ...[
                const Gap(4),
                Text(
                  subtitle,
                  textAlign: textAlign,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ] else if (postItem == null) ...[
                const Gap(4),
                Text(
                  emptyDescription,
                  textAlign: textAlign,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
              const Gap(6),
              if (publisherName != null || publishedAt != null)
                Text(
                  [
                    publisherName,
                    publishedAt?.formatRelative(context),
                  ].whereType<String>().join(' · '),
                  textAlign: textAlign,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class PostThreadCard extends StatelessWidget {
  final SnPost post;

  const PostThreadCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasThread =
        post.repliedPostId != null || post.forwardedPostId != null;
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: hasThread ? () => _showPostThreadSheet(context, post) : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(Symbols.forum, size: 18, color: theme.colorScheme.primary),
              const Gap(12),
              Expanded(
                child: Text(
                  'viewFullThread'.tr(),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Icon(
                Symbols.chevron_right,
                size: 18,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void _showPostThreadSheet(BuildContext context, SnPost post) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useRootNavigator: true,
    builder: (context) => _PostThreadSheet(post: post),
  );
}

Future<void> _sharePostThreadScreenshot(
  BuildContext context,
  WidgetRef ref,
  SnPost post, {
  PostThreadData? thread,
}) {
  return sharePostAsScreenshot(context, ref, post, thread: thread);
}

class _PostThreadSheet extends ConsumerStatefulWidget {
  final SnPost post;

  const _PostThreadSheet({required this.post});

  @override
  ConsumerState<_PostThreadSheet> createState() => _PostThreadSheetState();
}

class _PostThreadSheetState extends ConsumerState<_PostThreadSheet> {
  PostThreadData? _thread;
  Object? _error;
  bool _loading = true;
  bool _loadingMore = false;

  @override
  void initState() {
    super.initState();
    _loadThread();
  }

  Future<PostThreadData?> _fetchThread({
    required bool includeAncestors,
    String? anchorId,
  }) async {
    final client = ref.read(solarNetworkClientProvider);
    final response = await client.dio.get(
      '/sphere/posts/${anchorId ?? widget.post.id}/thread',
      queryParameters: {'ancestors': includeAncestors, 'take': 20},
    );
    return PostThreadData.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> _loadThread() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final thread = await _fetchThread(includeAncestors: true);
      if (!mounted) return;
      setState(() {
        _thread = thread;
      });
    } catch (err) {
      if (!mounted) return;
      setState(() {
        _error = err;
      });
    }

    if (!mounted) return;
    setState(() {
      _loading = false;
    });
  }

  Future<void> _loadMore() async {
    final thread = _thread;
    if (_loadingMore ||
        thread == null ||
        !thread.hasMore ||
        thread.descendants.isEmpty) {
      return;
    }

    setState(() => _loadingMore = true);
    try {
      final lastChild = thread.descendants.last.post.id;
      final next = await _fetchThread(
        includeAncestors: false,
        anchorId: lastChild,
      );
      if (!mounted || next == null) return;
      setState(() {
        _thread = PostThreadData(
          ancestors: thread.ancestors,
          current: thread.current,
          descendants: [...thread.descendants, ...next.descendants],
          hasMore: next.hasMore,
        );
      });
    } catch (err) {
      if (mounted) {
        showErrorAlert(err);
      }
    } finally {
      if (mounted) {
        setState(() => _loadingMore = false);
      }
    }
  }

  Color _depthColor(ThemeData theme, int depth) {
    final base = theme.colorScheme.surfaceContainerLow;
    final tint = theme.colorScheme.primary.withOpacity(
      (0.04 + (depth % 4) * 0.035).clamp(0.04, 0.18),
    );
    return Color.alphaBlend(tint, base);
  }

  Widget _buildThreadNode({
    required ThreadedReplyNode node,
    required Map<String?, List<ThreadedReplyNode>> childrenByParentId,
    required bool isCurrent,
  }) {
    final theme = Theme.of(context);
    final post = node.post;
    final depth = node.depth;
    final cardColor = _depthColor(theme, depth);
    final children = childrenByParentId[post.id] ?? const [];
    final borderRadius = depth == 0
        ? BorderRadius.zero
        : const BorderRadius.only(
            topLeft: Radius.circular(12),
            bottomLeft: Radius.circular(12),
          );

    return Padding(
      padding: EdgeInsets.only(left: depth == 0 ? 0 : 12),
      child: Material(
        color: cardColor,
        borderRadius: borderRadius,
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PostItem(
                    item: post,
                    isFullPost: false,
                    isEmbedReply: false,
                    isCompact: true,
                    hideAttachments: true,
                    isTextSelectable: false,
                    padding: EdgeInsets.zero,
                    onPostTap: (id) =>
                        context.router.push(PostDetailRoute(id: id)),
                  ),
                  if (isCurrent)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        'currentPost'.tr(),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            for (final child in children)
              _buildThreadNode(
                node: child,
                childrenByParentId: childrenByParentId,
                isCurrent: child.post.id == widget.post.id,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildThreadBody(PostThreadData thread) {
    final childrenByParentId = buildThreadChildrenMap(
      thread.allNodes,
      hiddenParentId: widget.post.id,
    );
    final rootNodes = childrenByParentId[null] ?? const [];

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        for (final node in rootNodes)
          _buildThreadNode(
            node: node,
            childrenByParentId: childrenByParentId,
            isCurrent: node.post.id == widget.post.id,
          ),
        if (thread.hasMore) ...[
          const Gap(8),
          FilledButton.tonal(
            onPressed: _loadingMore ? null : _loadMore,
            child: _loadingMore
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text('loadMoreThread'.tr()),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final thread = _thread;

    return SheetScaffold(
      titleText: 'fullThread'.tr(),
      actions: [
        if (thread != null)
          IconButton(
            onPressed: () => _sharePostThreadScreenshot(
              context,
              ref,
              widget.post,
              thread: thread,
            ),
            icon: const Icon(Symbols.share, size: 18),
          ),
      ],
      heightFactor: 0.92,
      child: Builder(
        builder: (context) {
          if (_loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (_error != null) {
            return ResponseErrorWidget(error: _error!, onRetry: _loadThread);
          }

          if (thread == null) {
            return const SizedBox.shrink();
          }

          return _buildThreadBody(thread);
        },
      ),
    );
  }
}

/// Both ways of sharing a post behind one action: the link via the share
/// sheet, or a screenshot of the post itself. On web only the link exists,
/// so the chooser is skipped there.
Future<void> _showPostShareSheet(
  BuildContext context,
  WidgetRef ref,
  SnPost post,
) {
  if (kIsWeb) {
    showShareSheetLink(
      context: context,
      link: 'https://solian.app/posts/${post.id}',
      title: 'sharePost'.tr(),
      toSystem: true,
    );
    return Future.value();
  }
  return showModalBottomSheet(
    context: context,
    useRootNavigator: true,
    builder: (sheetContext) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Symbols.link),
            title: Text('sharePost'.tr()),
            onTap: () {
              Navigator.of(sheetContext).pop();
              showShareSheetLink(
                context: context,
                link: 'https://solian.app/posts/${post.id}',
                title: 'sharePost'.tr(),
                toSystem: true,
              );
            },
          ),
          ListTile(
            leading: const Icon(Symbols.share_reviews),
            title: Text('sharePostPhoto'.tr()),
            onTap: () {
              Navigator.of(sheetContext).pop();
              sharePostAsScreenshot(context, ref, post);
            },
          ),
        ],
      ),
    ),
  );
}

/// Save action for the detail app bars: live bookmark state, toggle on tap.
class _PostBarBookmarkButton extends ConsumerWidget {
  final SnPost post;

  const _PostBarBookmarkButton({required this.post});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isBookmarked = ref
        .watch(bookmarkStatusProvider(post.id))
        .when(
          data: (bookmark) => bookmark != null,
          loading: () => post.isBookmarked,
          error: (_, _) => post.isBookmarked,
        );
    return IconButton(
      tooltip: isBookmarked ? 'unbookmark'.tr() : 'bookmark'.tr(),
      color: Theme.of(context).colorScheme.onPrimary,
      onPressed: () async {
        try {
          await toggleBookmark(
            ref,
            postId: post.id,
            currentlyBookmarked: isBookmarked,
          );
        } catch (err) {
          showErrorAlert(err);
        }
      },
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 150),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        child: Icon(
          isBookmarked ? Symbols.bookmark_added : Symbols.bookmark,
          key: ValueKey(isBookmarked),
          fill: isBookmarked ? 1 : 0,
        ),
      ),
    );
  }
}

/// Share action for the detail app bars: same chooser as the action rail.
class _PostBarShareButton extends ConsumerWidget {
  final SnPost post;

  const _PostBarShareButton({required this.post});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      tooltip: 'share'.tr(),
      color: Theme.of(context).colorScheme.onPrimary,
      onPressed: () => _showPostShareSheet(context, ref, post),
      icon: const Icon(Symbols.share),
    );
  }
}

/// Pinned sliver app bar for the full-screen post detail. It names the post
/// (its title, when it has one) and keeps the save/share/more actions
/// reachable while the conversation scrolls underneath.
SliverAppBar buildPostDetailSliverAppBar({
  required BuildContext context,
  required SnPost post,
  required Widget trailing,
  Widget leading = const AutoLeadingButton(),
}) {
  final theme = Theme.of(context);
  final title = post.title?.trim();
  final hasTitle = title != null && title.isNotEmpty;
  return SliverAppBar(
    pinned: true,
    // Opaque on purpose: this bar stays pinned over scrolling content, so it
    // must not inherit the "transparent app bar" user setting.
    backgroundColor: theme.colorScheme.primary,
    centerTitle: true,
    leading: leading,
    title: hasTitle
        ? Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onPrimary,
              fontWeight: FontWeight.w600,
            ),
          )
        : null,
    actions: [
      _PostBarBookmarkButton(post: post),
      _PostBarShareButton(post: post),
      trailing,
      const Gap(8),
    ],
  );
}

class _PostDetailLargeScreenLayout extends HookConsumerWidget {
  final SnPost post;
  final String postId;
  final Function(SnPost) onUpdate;
  final VoidCallback onRefresh;
  final ValueChanged<String>? onTranslate;
  final String? translatedText;
  final bool isTranslating;

  const _PostDetailLargeScreenLayout({
    required this.post,
    required this.postId,
    required this.onUpdate,
    required this.onRefresh,
    this.onTranslate,
    this.translatedText,
    this.isTranslating = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userInfoProvider);
    final focusedIndex = useState(0);

    Widget buildMenuItem({required String label, required IconData icon}) {
      return Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.onSurfaceVariant),
          const SizedBox(width: 12),
          Text(label),
        ],
      );
    }

    void Function() getMenuAction(String action) {
      switch (action) {
        case 'edit':
          return () async {
            final result = await PostComposeDialog.show(
              context,
              originalPost: post,
            );
            if (result != null) {
              onRefresh.call();
            }
          };
        case 'delete':
          return () {
            showConfirmAlert(
              'deletePostHint'.tr(),
              'deletePost'.tr(),
              isDanger: true,
            ).then((confirm) {
              if (confirm) {
                final client = ref.watch(solarNetworkClientProvider);
                client.sphere
                    .deletePost(post.id)
                    .catchError((err) {
                      showErrorAlert(err);
                      return err;
                    })
                    .then((_) {
                      onRefresh.call();
                    });
              }
            });
          };
        case 'copyLink':
          return () {
            Clipboard.setData(
              ClipboardData(text: 'https://solian.app/posts/${post.id}'),
            );
          };
        case 'reply':
          return () async {
            final result = await PostComposeDialog.show(
              context,
              initialState: PostComposeInitialState(replyingTo: post),
            );
            if (result != null) {
              onRefresh.call();
            }
          };
        case 'forward':
          return () async {
            final result = await PostComposeDialog.show(
              context,
              initialState: PostComposeInitialState(forwardingTo: post),
            );
            if (result != null) {
              onRefresh.call();
            }
          };
        case 'pin':
          return () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (context) => PostPinSheet(post: post),
            ).then((value) {
              if (value is int) {
                onUpdate.call(post.copyWith(pinMode: value));
              }
            });
          };
        case 'unpin':
          return () {
            showConfirmAlert('unpinPostHint'.tr(), 'unpinPost'.tr()).then((
              confirm,
            ) async {
              if (confirm) {
                final client = ref.watch(solarNetworkClientProvider);
                try {
                  if (context.mounted) showLoadingModal(context);
                  await client.sphere.unpinPost(post.id);
                  onUpdate.call(post.copyWith(pinMode: null));
                } catch (err) {
                  showErrorAlert(err);
                } finally {
                  if (context.mounted) hideLoadingModal(context);
                }
              }
            });
          };
        case 'award':
          return () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              useRootNavigator: true,
              builder: (context) => PostAwardSheet(post: post),
            );
          };
        case 'boost':
          return () async {
            final client = ref.read(solarNetworkClientProvider);
            try {
              if (context.mounted) showLoadingModal(context);
              await client.sphere.boostPost(post.id);
              onRefresh.call();
            } catch (err) {
              showErrorAlert(err);
            } finally {
              if (context.mounted) hideLoadingModal(context);
            }
          };
        case 'share':
          return () {
            showShareSheetLink(
              context: context,
              link: 'https://solian.app/posts/${post.id}',
              title: 'sharePost'.tr(),
              toSystem: true,
            );
          };
        case 'sharePhoto':
          return () {
            sharePostAsScreenshot(context, ref, post);
          };
        case 'openBrowser':
          return () {
            launchUrlString(post.fediverseUri!);
          };
        case 'report':
          return () {
            showAbuseReportSheet(
              context,
              resourceIdentifier: 'post:${post.id}',
            );
          };
        case 'bookmark':
          return () async {
            try {
              final bookmarkStatus = ref.read(bookmarkStatusProvider(post.id));
              final isBookmarked = bookmarkStatus.when(
                data: (bookmark) => bookmark != null,
                loading: () => post.isBookmarked,
                error: (_, _) => post.isBookmarked,
              );
              await toggleBookmark(
                ref,
                postId: post.id,
                currentlyBookmarked: isBookmarked,
              );
              onRefresh.call();
            } catch (err) {
              showErrorAlert(err);
            }
          };
        default:
          return () {};
      }
    }

    final isAuthor =
        user.value != null && user.value?.id == post.publisher?.accountId;

    final postMenuItems = <PopupMenuEntry<String>>[
      if (isAuthor)
        PopupMenuItem<String>(
          value: 'edit',
          child: buildMenuItem(label: 'edit'.tr(), icon: Symbols.edit),
        ),
      if (isAuthor)
        PopupMenuItem<String>(
          value: 'delete',
          child: buildMenuItem(label: 'delete'.tr(), icon: Symbols.delete),
        ),
      if (isAuthor) const PopupMenuDivider(),
      PopupMenuItem<String>(
        value: 'copyLink',
        child: buildMenuItem(label: 'copyLink'.tr(), icon: Symbols.link),
      ),
      PopupMenuItem<String>(
        value: 'reply',
        child: buildMenuItem(label: 'reply'.tr(), icon: Symbols.reply),
      ),
      PopupMenuItem<String>(
        value: 'forward',
        child: buildMenuItem(label: 'forward'.tr(), icon: Symbols.forward),
      ),
      if (isAuthor && post.pinMode == null)
        PopupMenuItem<String>(
          value: 'pin',
          child: buildMenuItem(label: 'pinPost'.tr(), icon: Symbols.keep),
        )
      else if (isAuthor && post.pinMode != null)
        PopupMenuItem<String>(
          value: 'unpin',
          child: buildMenuItem(label: 'unpinPost'.tr(), icon: Symbols.keep_off),
        ),
      PopupMenuItem<String>(
        value: 'award',
        child: buildMenuItem(label: 'award'.tr(), icon: Symbols.star),
      ),
      const PopupMenuDivider(),
      PopupMenuItem<String>(
        value: 'boost',
        child: buildMenuItem(label: 'boosts'.tr(), icon: Symbols.repeat),
      ),
      PopupMenuItem<String>(
        value: 'bookmark',
        child: buildMenuItem(
          label: post.isBookmarked ? 'unbookmark'.tr() : 'bookmark'.tr(),
          icon: post.isBookmarked ? Symbols.bookmark_added : Symbols.bookmark,
        ),
      ),
      const PopupMenuDivider(),
      PopupMenuItem<String>(
        value: 'share',
        child: buildMenuItem(label: 'share'.tr(), icon: Symbols.share),
      ),
      if (!kIsWeb)
        PopupMenuItem<String>(
          value: 'sharePhoto',
          child: buildMenuItem(
            label: 'sharePostPhoto'.tr(),
            icon: Symbols.share_reviews,
          ),
        ),
      if (post.fediverseUri != null)
        PopupMenuItem<String>(
          value: 'openBrowser',
          child: buildMenuItem(
            label: 'openInBrowser'.tr(),
            icon: Symbols.open_in_new,
          ),
        ),
      const PopupMenuDivider(),
      PopupMenuItem<String>(
        value: 'report',
        child: buildMenuItem(label: 'abuseReport'.tr(), icon: Symbols.flag),
      ),
    ];

    final trailing = PopupMenuButton<String>(
      icon: const Icon(Symbols.more_horiz, size: 18),
      style: ButtonStyle(
        visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
        padding: const WidgetStatePropertyAll(EdgeInsets.all(4)),
        minimumSize: const WidgetStatePropertyAll(Size(32, 32)),
      ),
      itemBuilder: (context) => postMenuItems,
      onSelected: (action) => getMenuAction(action)(),
    );

    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Stack(
            fit: StackFit.expand,
            children: [
              _DesktopMediaBackground(
                file: post.attachments[focusedIndex.value],
              ),
              CloudFileList(
                files: post.attachments,
                sourcePost: post,
                isFullBleed: true,
                fullBleedFraction: 1.0,
                maxHeight: double.infinity,
                padding: EdgeInsets.zero,
                heroTagPrefix: 'post-detail-media-${post.id}',
                onIndexChanged: (index) => focusedIndex.value = index,
              ),
              if (post.attachments.length > 1)
                Positioned(
                  left: 20,
                  top: 20,
                  child: _DesktopMediaCountBadge(
                    current: focusedIndex.value + 1,
                    total: post.attachments.length,
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          flex: 2,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Material(
                color: Theme.of(context).colorScheme.surfaceContainerLowest,
                elevation: 8,
                child: DefaultTabController(
                  length: 4,
                  child: Column(
                    children: [
                      Expanded(
                        child: CustomScrollView(
                          slivers: [
                            buildPostDetailSliverAppBar(
                              context: context,
                              post: post,
                              trailing: trailing,
                            ),
                            SliverToBoxAdapter(
                              child: Center(
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    maxWidth: _postDetailMaxWidth,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      16,
                                      16,
                                      16,
                                      0,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        PostHeader(
                                          item: post,
                                          isFullPost: true,
                                          isCompact: false,
                                          renderingPadding: EdgeInsets.zero,
                                          trailing: null,
                                        ),
                                        const Gap(8),
                                        PostBody(
                                          item: post,
                                          isFullPost: true,
                                          isTextSelectable: true,
                                          renderingPadding: EdgeInsets.zero,
                                          hideAttachments: true,
                                          textScale: post.type == 1 ? 1.2 : 1.1,
                                        ),
                                        // Blog CTA: open blog URL
                                        if (post.type == 2 &&
                                            post.embedView != null)
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              top: 12,
                                            ),
                                            child: FilledButton.icon(
                                              onPressed: () async {
                                                final uri = Uri.tryParse(
                                                  post.embedView!.uri,
                                                );
                                                if (uri != null &&
                                                    await canLaunchUrl(uri)) {
                                                  await launchUrl(
                                                    uri,
                                                    mode: LaunchMode
                                                        .externalApplication,
                                                  );
                                                }
                                              },
                                              icon: const Icon(
                                                Symbols.open_in_new,
                                              ),
                                              label: Text('openBlog'.tr()),
                                            ),
                                          ),
                                        if (post
                                            .publisherCollections
                                            .isNotEmpty)
                                          const Gap(8),
                                        if (post
                                            .publisherCollections
                                            .isNotEmpty)
                                          PostCollectionNavigation(post: post),
                                        if (post.embedView != null)
                                          EmbedViewRenderer(
                                            embedView: post.embedView!,
                                            maxHeight: 400,
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ).padding(vertical: 8),
                                        if (isTranslating ||
                                            translatedText != null)
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              top: 8,
                                            ),
                                            child: buildPostTranslationSection(
                                              context: context,
                                              item: post,
                                              isTextSelectable: true,
                                              textScale: post.type == 1
                                                  ? 1.2
                                                  : 1.1,
                                              translatedText: translatedText,
                                              isTranslating: isTranslating,
                                              onTranslate: onTranslate == null
                                                  ? null
                                                  : () => onTranslate!(
                                                      post.content!,
                                                    ),
                                              showTranslateButton: false,
                                            ),
                                          ),
                                        PostReactionList(
                                          padding: EdgeInsets.only(top: 8),
                                          item: post,
                                          reactions: post.reactionsCount,
                                          reactionsMade: post.reactionsMade,
                                          onReact: (symbol, attitude, delta) {
                                            final reactionsCount =
                                                Map<String, int>.from(
                                                  post.reactionsCount,
                                                );
                                            reactionsCount[symbol] =
                                                (reactionsCount[symbol] ?? 0) +
                                                delta;
                                            final reactionsMade =
                                                Map<String, bool>.from(
                                                  post.reactionsMade,
                                                );
                                            reactionsMade[symbol] = delta == 1
                                                ? true
                                                : false;
                                            onUpdate.call(
                                              post.copyWith(
                                                reactionsCount: reactionsCount,
                                                reactionsMade: reactionsMade,
                                              ),
                                            );
                                          },
                                        ),
                                        PostActionButtons(
                                          post: post,
                                          noBottomPadding: true,
                                          renderingPadding:
                                              const EdgeInsets.only(top: 8),
                                          onRefresh: onRefresh,
                                          onUpdate: onUpdate,
                                          onTranslate: onTranslate,
                                        ).alignment(Alignment.centerLeft),
                                        if (post.repliedPostId != null ||
                                            post.forwardedPostId != null)
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              top: 8,
                                              bottom: 8,
                                            ),
                                            child: PostThreadCard(post: post),
                                          ),
                                        if (post.realm != null)
                                          PostRealmBadge(
                                            realm: post.realm!,
                                          ).padding(top: 8, bottom: 8),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            DefaultTabController(
                              length: 4,
                              child: PostInteractionsSlivers(
                                postId: postId,
                                maxWidth: _postDetailMaxWidth,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (user.value != null)
                Positioned(
                  bottom: 16 + MediaQuery.of(context).padding.bottom,
                  left: 16,
                  right: 16,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: _postDetailMaxWidth),
                    child: PostQuickReply(
                      parent: post,
                      onPosted: () {
                        ref
                            .read(
                              postRepliesProvider(
                                postRepliesQuery(postId),
                              ).notifier,
                            )
                            .refresh();
                      },
                    ),
                  ).center(),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DesktopMediaBackground extends ConsumerWidget {
  final IDisplayableCloudFile file;

  const _DesktopMediaBackground({required this.file});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final serverUrl = ref.watch(serverUrlProvider);
    final isImage = file.mimeType.startsWith('image');
    final isVideo = file.mimeType.startsWith('video');
    final thumbnailUri =
        file.storageUrl ?? '$serverUrl/drive/files/${file.id}?thumbnail=true';

    Widget child;
    if (isImage && file.blurhash?.isNotEmpty == true) {
      child = BlurHash(hash: file.blurhash!);
    } else if (isImage) {
      child = Stack(
        fit: StackFit.expand,
        children: [
          CloudFileWidget(
            item: file,
            fit: BoxFit.cover,
            noBlurhash: true,
            useInternalGate: false,
          ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
            child: Container(color: Colors.black38),
          ),
        ],
      );
    } else if (isVideo) {
      child = Stack(
        fit: StackFit.expand,
        children: [
          UniversalImage(uri: thumbnailUri, fit: BoxFit.cover),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
            child: Container(color: Colors.black38),
          ),
        ],
      );
    } else {
      child = const ColoredBox(color: Colors.black);
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 320),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      child: ColoredBox(
        key: ValueKey(file.id),
        color: Colors.black,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Positioned.fill(child: child),
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0x22000000), Color(0x66000000)],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DesktopMediaCountBadge extends StatelessWidget {
  final int current;
  final int total;

  const _DesktopMediaCountBadge({required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black45,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Text(
          '$current/$total',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _BlogPostDetailLayout extends HookConsumerWidget {
  final SnPost post;
  final String postId;
  final Widget trailing;
  final String? translatedText;
  final bool isTranslating;
  final Future<void> Function(String) onTranslate;
  final VoidCallback onRefresh;
  final ValueChanged<SnPost> onUpdate;

  const _BlogPostDetailLayout({
    required this.post,
    required this.postId,
    required this.trailing,
    required this.translatedText,
    required this.isTranslating,
    required this.onTranslate,
    required this.onRefresh,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userInfoProvider).value;
    final mediaQuery = MediaQuery.of(context);
    final availableHeight =
        mediaQuery.size.height -
        mediaQuery.padding.top -
        mediaQuery.padding.bottom -
        kToolbarHeight;
    final minPanelHeight = 26.0;
    final initialPanelHeight = (availableHeight * 0.34).clamp(220.0, 360.0);
    final maxPanelHeight = (availableHeight * 0.86).clamp(420.0, 760.0);
    final panelHeight = useState(initialPanelHeight);
    final theme = Theme.of(context);
    const quickReplyRevealHeight = 320.0;
    final showQuickReply =
        user != null && panelHeight.value >= quickReplyRevealHeight;

    return Stack(
      children: [
        DraggableOverlaySheet(
          minHeight: minPanelHeight,
          initialHeight: initialPanelHeight,
          maxHeight: maxPanelHeight,
          onHeightChanged: (value) {
            panelHeight.value = value;
          },
          snapHeights: [
            minPanelHeight,
            (availableHeight * 0.24).clamp(160.0, 240.0),
            initialPanelHeight,
            (availableHeight * 0.52).clamp(320.0, 520.0),
            maxPanelHeight,
          ],
          backgroundColor: theme.colorScheme.surface.withOpacity(0.97),
          body: _BlogPostWebView(url: _getBlogUrl(post)),
          child: Column(
            children: [
              Expanded(
                child: DefaultTabController(
                  length: 4,
                  child: CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(
                              maxWidth: _postDetailMaxWidth,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  PostHeader(
                                    item: post,
                                    isFullPost: true,
                                    isCompact: false,
                                    renderingPadding: EdgeInsets.zero,
                                    trailing: trailing,
                                  ),
                                  const Gap(8),
                                  _BlogPostSummaryCard(post: post),
                                  if (post.repliedPostId != null ||
                                      post.forwardedPostId != null)
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        top: 8,
                                        bottom: 8,
                                      ),
                                      child: PostThreadCard(post: post),
                                    ),
                                  if (post.publisherCollections.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        top: 8,
                                        bottom: 8,
                                      ),
                                      child: PostCollectionNavigation(
                                        post: post,
                                      ),
                                    ),
                                  if (post.realm != null)
                                    PostRealmBadge(
                                      realm: post.realm!,
                                    ).padding(top: 8, bottom: 8),
                                  PostReactionList(
                                    padding: const EdgeInsets.only(top: 8),
                                    item: post,
                                    reactions: post.reactionsCount,
                                    reactionsMade: post.reactionsMade,
                                    onReact: (symbol, attitude, delta) {
                                      final reactionsCount =
                                          Map<String, int>.from(
                                            post.reactionsCount,
                                          );
                                      reactionsCount[symbol] =
                                          (reactionsCount[symbol] ?? 0) + delta;
                                      final reactionsMade =
                                          Map<String, bool>.from(
                                            post.reactionsMade,
                                          );
                                      reactionsMade[symbol] = delta == 1;
                                      onUpdate(
                                        post.copyWith(
                                          reactionsCount: reactionsCount,
                                          reactionsMade: reactionsMade,
                                        ),
                                      );
                                    },
                                  ),
                                  PostActionButtons(
                                    post: post,
                                    renderingPadding: const EdgeInsets.only(
                                      top: 8,
                                    ),
                                    noBottomPadding: true,
                                    onRefresh: onRefresh,
                                    onUpdate: onUpdate,
                                    onTranslate: null,
                                  ).alignment(Alignment.centerLeft),
                                  const Gap(8),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      PostInteractionsSlivers(
                        postId: postId,
                        maxWidth: _postDetailMaxWidth,
                      ),
                      SliverGap(showQuickReply ? 16.0 : 24.0),
                    ],
                  ),
                ),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 160),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeOutCubic,
                child: showQuickReply
                    ? Container(
                        key: const ValueKey('quick-reply'),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface.withOpacity(0.96),
                          border: Border(
                            top: BorderSide(
                              color: theme.colorScheme.outline.withOpacity(
                                0.12,
                              ),
                            ),
                          ),
                        ),
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(
                              maxWidth: _postDetailMaxWidth,
                            ),
                            child: PostQuickReply(
                              parent: post,
                              onPosted: () {
                                ref
                                    .read(
                                      postRepliesProvider(
                                        postRepliesQuery(postId),
                                      ).notifier,
                                    )
                                    .refresh();
                              },
                            ),
                          ),
                        ),
                      )
                    : const SizedBox.shrink(
                        key: ValueKey('quick-reply-hidden'),
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BlogPostWebView extends HookWidget {
  final String? url;

  const _BlogPostWebView({required this.url});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLoading = useState(url != null);

    if (url == null) {
      return ColoredBox(
        color: theme.colorScheme.surfaceContainerLowest,
        child: Center(
          child: Text(
            'Unable to open blog URL',
            style: theme.textTheme.bodyLarge,
          ),
        ),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        InAppWebView(
          initialUrlRequest: URLRequest(url: WebUri(url!)),
          initialSettings: InAppWebViewSettings(
            javaScriptEnabled: true,
            mediaPlaybackRequiresUserGesture: false,
            allowsInlineMediaPlayback: true,
            supportZoom: true,
            useShouldOverrideUrlLoading: true,
            preferredContentMode: UserPreferredContentMode.RECOMMENDED,
          ),
          onLoadStart: (_, _) {
            isLoading.value = true;
          },
          onLoadStop: (_, _) {
            isLoading.value = false;
          },
          onLoadError: (_, _, _, _) {
            isLoading.value = false;
          },
          onLoadHttpError: (_, _, _, _) {
            isLoading.value = false;
          },
          shouldOverrideUrlLoading: (_, navigationAction) async {
            final target = navigationAction.request.url?.toString();
            if (target != null && target != url) {
              final uri = Uri.tryParse(target);
              if (uri != null) {
                launchUrl(uri, mode: LaunchMode.externalApplication);
              }
              return NavigationActionPolicy.CANCEL;
            }
            return NavigationActionPolicy.ALLOW;
          },
        ),
        if (isLoading.value)
          ColoredBox(
            color: theme.colorScheme.surfaceContainerLowest,
            child: const Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }
}

class _BlogPostSummaryCard extends StatelessWidget {
  final SnPost post;

  const _BlogPostSummaryCard({required this.post});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final url = _getBlogUrl(post);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Badge(
                label: const Text('postBlog').tr(),
                backgroundColor: theme.colorScheme.tertiary,
                textColor: theme.colorScheme.onTertiary,
              ),
              const Spacer(),
              if (url != null)
                Tooltip(
                  message: 'openBlog'.tr(),
                  child: InkWell(
                    onTap: () {
                      launchUrl(
                        Uri.parse(url),
                        mode: LaunchMode.externalApplication,
                      );
                    },
                    child: const Icon(Symbols.open_in_new, size: 16),
                  ),
                ),
            ],
          ),
          const Gap(4),
          if (post.title?.isNotEmpty ?? false)
            Text(
              post.title!,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          if (post.description?.isNotEmpty ?? false) ...[
            Text(post.description!, style: theme.textTheme.bodyMedium),
          ],
        ],
      ),
    );
  }
}

class PostDetailAttentionModal extends StatelessWidget {
  static const double _modalMaxWidth = 520;

  final String id;
  final VoidCallback onDismiss;

  const PostDetailAttentionModal({
    super.key,
    required this.id,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return AttentionModalScaffold(
      titleText: 'postDetail'.tr(),
      onDismiss: onDismiss,
      maxWidth: _modalMaxWidth,
      forceCard: true,
      actions: [
        IconButton(
          onPressed: () {
            onDismiss();
            context.router.push(PostDetailRoute(id: id));
          },
          icon: const Icon(Symbols.open_in_new),
          tooltip: 'open'.tr(),
        ),
      ],
      child: _PostDetailBody(id: id, isEmbedded: true),
    );
  }
}

class _PostDetailBody extends HookConsumerWidget {
  final String id;
  final bool isEmbedded;

  const _PostDetailBody({required this.id, this.isEmbedded = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postState = ref.watch(postStateProvider(id));
    final translating = useState(false);
    final translatedText = useState<String?>(null);
    final currentLanguage = context.locale.toString();

    Future<void> translatePost(String text) async {
      if (translatedText.value != null) {
        translatedText.value = null;
        return;
      }
      if (translating.value) return;
      translating.value = true;
      try {
        final result = await ref.read(
          translateStringProvider(
            TranslateQuery(text: text, lang: currentLanguage.substring(0, 2)),
          ).future,
        );
        translatedText.value = result;
      } catch (err) {
        showErrorAlert(err);
      } finally {
        translating.value = false;
      }
    }

    return postState.when(
      data: (post) {
        final postItem = post!;
        final isMediaPostLayout =
            isWideScreen(context) && _isMediaPost(postItem) && !isEmbedded;

        Widget buildMenuItem({required String label, required IconData icon}) {
          return Row(
            children: [
              Icon(icon, color: Theme.of(context).colorScheme.onSurfaceVariant),
              const SizedBox(width: 12),
              Text(label),
            ],
          );
        }

        void refreshPost() {
          ref.invalidate(postProvider(id));
          ref
              .read(postRepliesProvider(postRepliesQuery(id)).notifier)
              .refresh();
        }

        void Function() getMenuAction(String action) {
          switch (action) {
            case 'edit':
              return () async {
                final result = await PostComposeDialog.show(
                  context,
                  originalPost: postItem,
                );
                if (result != null) refreshPost();
              };
            case 'delete':
              return () {
                showConfirmAlert(
                  'deletePostHint'.tr(),
                  'deletePost'.tr(),
                  isDanger: true,
                ).then((confirm) {
                  if (confirm) {
                    final client = ref.watch(solarNetworkClientProvider);
                    client.sphere
                        .deletePost(postItem.id)
                        .catchError((err) {
                          showErrorAlert(err);
                          return err;
                        })
                        .then((_) {
                          refreshPost();
                        });
                  }
                });
              };
            case 'copyLink':
              return () {
                Clipboard.setData(
                  ClipboardData(
                    text: 'https://solian.app/posts/${postItem.id}',
                  ),
                );
              };
            case 'reply':
              return () async {
                final result = await PostComposeDialog.show(
                  context,
                  initialState: PostComposeInitialState(replyingTo: postItem),
                );
                if (result != null) refreshPost();
              };
            case 'forward':
              return () async {
                final result = await PostComposeDialog.show(
                  context,
                  initialState: PostComposeInitialState(forwardingTo: postItem),
                );
                if (result != null) refreshPost();
              };
            case 'pin':
              return () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (context) => PostPinSheet(post: postItem),
                ).then((value) {
                  if (value is int) {
                    ref
                        .read(postStateProvider(id).notifier)
                        .updatePost(postItem.copyWith(pinMode: value));
                  }
                });
              };
            case 'unpin':
              return () {
                showConfirmAlert('unpinPostHint'.tr(), 'unpinPost'.tr()).then((
                  confirm,
                ) async {
                  if (confirm) {
                    final client = ref.watch(solarNetworkClientProvider);
                    try {
                      if (context.mounted) showLoadingModal(context);
                      await client.sphere.unpinPost(postItem.id);
                      ref
                          .read(postStateProvider(id).notifier)
                          .updatePost(postItem.copyWith(pinMode: null));
                    } catch (err) {
                      showErrorAlert(err);
                    } finally {
                      if (context.mounted) hideLoadingModal(context);
                    }
                  }
                });
              };
            case 'award':
              return () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  useRootNavigator: true,
                  builder: (context) => PostAwardSheet(post: postItem),
                );
              };
            case 'boost':
              return () async {
                final client = ref.read(solarNetworkClientProvider);
                try {
                  if (context.mounted) showLoadingModal(context);
                  await client.sphere.boostPost(postItem.id);
                  refreshPost();
                } catch (err) {
                  showErrorAlert(err);
                } finally {
                  if (context.mounted) hideLoadingModal(context);
                }
              };
            case 'share':
              return () {
                showShareSheetLink(
                  context: context,
                  link: 'https://solian.app/posts/${postItem.id}',
                  title: 'sharePost'.tr(),
                  toSystem: true,
                );
              };
            case 'sharePhoto':
              return () {
                sharePostAsScreenshot(context, ref, postItem);
              };
            case 'openBrowser':
              return () {
                launchUrlString(postItem.fediverseUri!);
              };
            case 'report':
              return () {
                showAbuseReportSheet(
                  context,
                  resourceIdentifier: 'post:${postItem.id}',
                );
              };
            case 'bookmark':
              return () async {
                try {
                  await toggleBookmark(
                    ref,
                    postId: postItem.id,
                    currentlyBookmarked: postItem.isBookmarked,
                  );
                  refreshPost();
                } catch (err) {
                  showErrorAlert(err);
                }
              };
            default:
              return () {};
          }
        }

        final user = ref.watch(userInfoProvider);
        final isAuthor =
            user.value != null &&
            user.value?.id == postItem.publisher?.accountId;

        final postMenuItems = <PopupMenuEntry<String>>[
          if (isAuthor)
            PopupMenuItem<String>(
              value: 'edit',
              child: buildMenuItem(label: 'edit'.tr(), icon: Symbols.edit),
            ),
          if (isAuthor)
            PopupMenuItem<String>(
              value: 'delete',
              child: buildMenuItem(label: 'delete'.tr(), icon: Symbols.delete),
            ),
          if (isAuthor) const PopupMenuDivider(),
          PopupMenuItem<String>(
            value: 'copyLink',
            child: buildMenuItem(label: 'copyLink'.tr(), icon: Symbols.link),
          ),
          PopupMenuItem<String>(
            value: 'reply',
            child: buildMenuItem(label: 'reply'.tr(), icon: Symbols.reply),
          ),
          PopupMenuItem<String>(
            value: 'forward',
            child: buildMenuItem(label: 'forward'.tr(), icon: Symbols.forward),
          ),
          if (isAuthor && postItem.pinMode == null)
            PopupMenuItem<String>(
              value: 'pin',
              child: buildMenuItem(label: 'pinPost'.tr(), icon: Symbols.keep),
            )
          else if (isAuthor && postItem.pinMode != null)
            PopupMenuItem<String>(
              value: 'unpin',
              child: buildMenuItem(
                label: 'unpinPost'.tr(),
                icon: Symbols.keep_off,
              ),
            ),
          PopupMenuItem<String>(
            value: 'award',
            child: buildMenuItem(label: 'award'.tr(), icon: Symbols.star),
          ),
          const PopupMenuDivider(),
          PopupMenuItem<String>(
            value: 'boost',
            child: buildMenuItem(label: 'boosts'.tr(), icon: Symbols.repeat),
          ),
          PopupMenuItem<String>(
            value: 'bookmark',
            child: buildMenuItem(
              label: postItem.isBookmarked
                  ? 'unbookmark'.tr()
                  : 'bookmark'.tr(),
              icon: postItem.isBookmarked
                  ? Symbols.bookmark_added
                  : Symbols.bookmark,
            ),
          ),
          const PopupMenuDivider(),
          PopupMenuItem<String>(
            value: 'share',
            child: buildMenuItem(label: 'share'.tr(), icon: Symbols.share),
          ),
          if (!kIsWeb)
            PopupMenuItem<String>(
              value: 'sharePhoto',
              child: buildMenuItem(
                label: 'sharePostPhoto'.tr(),
                icon: Symbols.share_reviews,
              ),
            ),
          if (postItem.fediverseUri != null)
            PopupMenuItem<String>(
              value: 'openBrowser',
              child: buildMenuItem(
                label: 'openInBrowser'.tr(),
                icon: Symbols.open_in_new,
              ),
            ),
          const PopupMenuDivider(),
          PopupMenuItem<String>(
            value: 'report',
            child: buildMenuItem(label: 'abuseReport'.tr(), icon: Symbols.flag),
          ),
        ];

        final trailing = PopupMenuButton<String>(
          icon: const Icon(Symbols.more_horiz),
          style: ButtonStyle(
            visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
            padding: const WidgetStatePropertyAll(EdgeInsets.all(4)),
            minimumSize: const WidgetStatePropertyAll(Size(32, 32)),
          ),
          itemBuilder: (context) => postMenuItems,
          onSelected: (action) => getMenuAction(action)(),
        );

        return Stack(
          fit: StackFit.expand,
          children: [
            if (postItem.type == 2 || isMediaPostLayout)
              ExtendedRefreshIndicator(
                onRefresh: () async {
                  refreshPost();
                },
                child: postItem.type == 2
                    ? _BlogPostDetailLayout(
                        post: postItem,
                        postId: id,
                        trailing: trailing,
                        translatedText: translatedText.value,
                        isTranslating: translating.value,
                        onTranslate: translatePost,
                        onRefresh: refreshPost,
                        onUpdate: (newItem) {
                          ref
                              .read(postStateProvider(id).notifier)
                              .updatePost(newItem);
                        },
                      )
                    : _PostDetailLargeScreenLayout(
                        post: postItem,
                        postId: id,
                        onUpdate: (newItem) {
                          ref
                              .read(postStateProvider(id).notifier)
                              .updatePost(newItem);
                        },
                        onRefresh: refreshPost,
                        onTranslate: translatePost,
                        translatedText: translatedText.value,
                        isTranslating: translating.value,
                      ),
              )
            else
              PostDetailContent(
                postId: id,
                post: postItem,
                trailing: trailing,
                headerSliver: isEmbedded
                    ? null
                    : buildPostDetailSliverAppBar(
                        context: context,
                        post: postItem,
                        trailing: trailing,
                      ),
                onRefresh: () async {
                  refreshPost();
                },
                onUpdate: (newItem) {
                  ref.read(postStateProvider(id).notifier).updatePost(newItem);
                },
                onReplyPosted: refreshPost,
                threadSection:
                    postItem.repliedPostId != null ||
                        postItem.forwardedPostId != null
                    ? PostThreadCard(post: postItem)
                    : null,
                collectionSection: postItem.publisherCollections.isNotEmpty
                    ? PostCollectionNavigation(post: postItem)
                    : null,
                realmSection: postItem.realm != null
                    ? PostRealmBadge(realm: postItem.realm!)
                    : null,
                actionBuilder: (context, onTranslate) => PostActionButtons(
                  post: postItem,
                  renderingPadding: const EdgeInsets.symmetric(horizontal: 16),
                  onRefresh: refreshPost,
                  onUpdate: (newItem) {
                    ref
                        .read(postStateProvider(id).notifier)
                        .updatePost(newItem);
                  },
                  onTranslate: onTranslate,
                ).alignment(Alignment.centerLeft),
                interactionsSection: DefaultTabController(
                  length: 4,
                  child: PostInteractionsSlivers(
                    postId: id,
                    maxWidth: _postDetailMaxWidth,
                  ),
                ),
              ),
          ],
        );
      },
      loading: () => const ResponseLoadingWidget(),
      error: (e, _) => ResponseErrorWidget(
        error: e,
        onRetry: () => ref.invalidate(postProvider(id)),
      ),
    );
  }
}

@RoutePage()
class PostDetailScreen extends HookConsumerWidget {
  final String id;

  const PostDetailScreen({super.key, @PathParam('id') required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final post = ref.watch(postStateProvider(id)).asData?.value;
    final title = post?.title?.trim();
    final hasTitle = title != null && title.isNotEmpty;
    final isBlog = post?.type == 2;
    return AppScaffold(
      isNoBackground: false,
      // Blog posts keep a static bar: their webview sheet needs persistent
      // chrome. Every other layout owns its app bar inside the scroll view.
      appBar: isBlog && post != null
          ? AppBar(
              leading: const AutoLeadingButton(),
              title: Text(
                hasTitle ? title : 'postDetail'.tr(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              actions: [
                _PostBarBookmarkButton(post: post),
                _PostBarShareButton(post: post),
                const Gap(8),
              ],
            )
          : null,
      body: _PostDetailBody(id: id),
    );
  }
}
