import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:auto_route/auto_route.dart';
import 'package:dio/dio.dart';
import 'package:dismissible_page/dismissible_page.dart';
import 'package:flutter/material.dart';
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
import 'package:island/posts/widgets/compose/post_collections_sheet.dart';
import 'package:island/posts/widgets/compose/post_pin_sheet.dart';
import 'package:island/posts/widgets/compose/post_quick_reply.dart';
import 'package:island/posts/widgets/compose/post_replies.dart';
import 'package:island/posts/widgets/compose/post_interactions.dart';
import 'package:island/posts/widgets/post_detail_content.dart';
import 'package:island/posts/widgets/compose/post_shared.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:island/tickets/widgets/ticket_fire.dart';
import 'package:island/route.gr.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/shared/widgets/attention_modal.dart';
import 'package:island/shared/widgets/app_scaffold.dart' hide PageBackButton;
import 'package:island/core/widgets/content/cloud_file_lightbox.dart';
import 'package:island/shared/widgets/layouts/attention_modal_scaffold.dart';
import 'package:island/shared/widgets/layouts/sheet_scaffold.dart';
import 'package:island/shared/widgets/extended_refresh_indicator.dart';
import 'package:island/shared/widgets/response.dart';
import 'package:island/core/utils/share_utils.dart';
import 'package:island/sharing/share_sheet.dart';
import 'package:island/thoughts/screens/think_sheet.dart';
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

final postCollectionPostsProvider = FutureProvider.autoDispose
    .family<PaginatedResult<SnPost>, (String, String)>((ref, args) async {
      final client = ref.watch(solarNetworkClientProvider);
      return client.sphere.listPublisherCollectionPosts(
        publisherName: args.$1,
        slug: args.$2,
      );
    });

const _postDetailMaxWidth = 640.0;

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
  showAttentionModal(
    id: 'post-collection:${post.id}:${collection.slug}',
    replaceIfExists: true,
    barrierDismissible: true,
    builder: (_, dismiss) => _PublicCollectionSheet(
      post: post,
      collection: collection,
      onDismiss: dismiss,
    ),
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

    Widget buildActionButton({
      required IconData icon,
      required String label,
      required VoidCallback? onPressed,
      VoidCallback? onLongPress,
      bool isSelected = false,
      Color? color,
    }) {
      return Tooltip(
        message: label,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onPressed,
          onLongPress: onLongPress,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: 6,
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: isSelected
                      ? theme.colorScheme.primary
                      : color ?? theme.colorScheme.onSurfaceVariant,
                ),
                Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : color ?? theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final primaryActions = <Widget>[
      buildActionButton(
        icon: Symbols.reply,
        label: 'reply'.tr(),
        onPressed: () {
          PostComposeDialog.show(
            context,
            initialState: PostComposeInitialState(replyingTo: post),
          );
        },
      ),
      buildActionButton(
        icon: Symbols.forward,
        label: 'forward'.tr(),
        onPressed: () {
          PostComposeDialog.show(
            context,
            initialState: PostComposeInitialState(forwardingTo: post),
          );
        },
      ),
      buildActionButton(
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
      buildActionButton(
        icon: Symbols.share,
        label: 'share'.tr(),
        onPressed: () {
          showShareSheetLink(
            context: context,
            link: 'https://solian.app/posts/${post.id}',
            title: 'sharePost'.tr(),
            toSystem: true,
          );
        },
      ),
    ];

    final secondaryActions = <Widget>[
      buildActionButton(
        icon: Symbols.forum,
        label: 'fullThread'.tr(),
        onPressed: () => _showPostThreadSheet(context, post),
      ),
      buildActionButton(
        icon: Symbols.emoji_events,
        label: post.awardedScore > 0
            ? '${formatScore(post.awardedScore)} pts'
            : 'award'.tr(),
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
      buildActionButton(
        icon: Symbols.smart_toy,
        label: 'aiThought'.tr(),
        onPressed: () {
          ThoughtSheet.show(context, attachedPosts: [post.id]);
        },
      ),
      if (isAuthor)
        buildActionButton(
          icon: Symbols.collections,
          label: 'collections'.tr(),
          onPressed: () =>
              showPostCollectionsSheet(context, post, onChanged: onRefresh),
        ),
      if (post.content != null && onTranslate != null)
        buildActionButton(
          icon: Symbols.translate,
          label: 'translate'.tr(),
          onPressed: () => onTranslate!(post.content!),
        ),
      if (!kIsWeb)
        buildActionButton(
          icon: Symbols.share_reviews,
          label: 'sharePostPhoto'.tr(),
          onPressed: () => sharePostAsScreenshot(context, ref, post),
        ),
    ];

    final authorActions = <Widget>[
      buildActionButton(
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
      buildActionButton(
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
      buildActionButton(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: [
          Wrap(
            spacing: 4,
            runSpacing: 4,
            alignment: WrapAlignment.start,
            runAlignment: WrapAlignment.start,
            children: primaryActions,
          ),
          if (secondaryActions.isNotEmpty)
            Wrap(
              spacing: 4,
              runSpacing: 4,
              alignment: WrapAlignment.start,
              runAlignment: WrapAlignment.start,
              children: secondaryActions,
            ),
          if (isAuthor && authorActions.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withOpacity(
                  0.3,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Wrap(
                spacing: 4,
                runSpacing: 4,
                alignment: WrapAlignment.start,
                runAlignment: WrapAlignment.start,
                children: authorActions,
              ),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            showAttentionModal(
              id: 'post-collection-browser:${post.id}',
              replaceIfExists: true,
              barrierDismissible: true,
              builder: (_, dismiss) =>
                  _PublicCollectionBrowserSheet(post: post, onDismiss: dismiss),
            );
          },
          child: Text('postCollectionsOfHint').tr().fontSize(12).opacity(0.7),
        ),
        const Gap(8),
        for (final collection in collections) ...[
          _PostCollectionNeighborGroup(
            post: post,
            collection: collection,
            publisherName: publisherName,
          ),
          if (collection != collections.last) const Gap(12),
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

class _PublicCollectionSheet extends ConsumerWidget {
  final SnPost post;
  final SnPostCollection collection;
  final VoidCallback onDismiss;

  const _PublicCollectionSheet({
    required this.post,
    required this.collection,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final publisherName = post.publisher?.name ?? '';
    final posts = ref.watch(
      postCollectionPostsProvider((publisherName, collection.slug)),
    );
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

    return AttentionModalScaffold(
      titleText: title,
      onDismiss: onDismiss,
      child: ListView(
        padding: const EdgeInsets.only(bottom: 16),
        children: [
          AspectRatio(
            aspectRatio: 16 / 7,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (collection.background != null)
                  CloudFileWidget(
                    item: collection.background!,
                    fit: BoxFit.cover,
                  )
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
                        radius: 28,
                        fallbackIcon: Symbols.collections,
                      ),
                      const Gap(12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: () {
                              showPostCollectionAttentionModal(
                                post,
                                collection,
                              );
                            },
                            child: Text(title, style: titleStyle),
                          ),
                          if (collection.description?.isNotEmpty ?? false)
                            Text(
                              collection.description!,
                              style: descStyle,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Gap(16),
          posts.when(
            data: (result) => Column(
              children: [
                for (final entry in result.items.asMap().entries)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      child: InkWell(
                        onTap: () => context.router.push(
                          PostDetailRoute(id: entry.value.id),
                        ),
                        child: PostItem(
                          item: entry.value,
                          isFullPost: false,
                          isEmbedReply: false,
                          isCompact: true,
                          hideAttachments: true,
                          isTextSelectable: false,
                          padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => ResponseErrorWidget(
              error: error,
              onRetry: () => ref.invalidate(
                postCollectionPostsProvider((publisherName, collection.slug)),
              ),
            ),
          ),
        ],
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
    final pageController = usePageController();
    final focusedIndex = useState(0);
    final imageFiles = useMemoized(
      () => post.attachments.where((file) => file.mimeType.startsWith('image')),
      [post.attachments],
    );

    void openMediaAt(int index) {
      final file = post.attachments[index];
      if (file.mimeType.startsWith('image')) {
        final viewableFiles = imageFiles.toList();
        final viewableIndex = viewableFiles.indexWhere(
          (item) => item.id == file.id,
        );
        if (viewableIndex != -1) {
          context.pushTransparentRoute(
            CloudFileLightbox(
              items: viewableFiles,
              initialIndex: viewableIndex,
              heroTag: 'post-detail-media-${post.id}-${file.id}',
              sourcePost: post,
            ),
            rootNavigator: true,
          );
          return;
        }
      }
      context.router.push(FileDetailRoute(id: file.id, sourcePost: post));
    }

    Widget buildMenuItem({required String label, required IconData icon}) {
      return Row(
        children: [Icon(icon), const SizedBox(width: 12), Text(label)],
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
              PageView.builder(
                controller: pageController,
                itemCount: post.attachments.length,
                onPageChanged: (index) => focusedIndex.value = index,
                itemBuilder: (context, index) {
                  final file = post.attachments[index];
                  return _DesktopMediaPage(
                    file: file,
                    heroTag: 'post-detail-media-${post.id}-${file.id}',
                    sourcePost: post,
                    onTap: () => openMediaAt(index),
                  );
                },
              ),
              if (post.attachments.length > 1) ...[
                Positioned(
                  left: 20,
                  top: 20,
                  child: _DesktopMediaCountBadge(
                    current: focusedIndex.value + 1,
                    total: post.attachments.length,
                  ),
                ),
                Positioned(
                  left: 20,
                  top: 0,
                  bottom: 0,
                  child: _DesktopMediaArrowButton(
                    icon: Symbols.chevron_left,
                    onTap: focusedIndex.value > 0
                        ? () => pageController.previousPage(
                            duration: const Duration(milliseconds: 220),
                            curve: Curves.easeOutCubic,
                          )
                        : null,
                  ),
                ),
                Positioned(
                  right: 20,
                  top: 0,
                  bottom: 0,
                  child: _DesktopMediaArrowButton(
                    icon: Symbols.chevron_right,
                    onTap: focusedIndex.value < post.attachments.length - 1
                        ? () => pageController.nextPage(
                            duration: const Duration(milliseconds: 220),
                            curve: Curves.easeOutCubic,
                          )
                        : null,
                  ),
                ),
                Positioned(
                  left: 24,
                  right: 24,
                  bottom: 20,
                  child: _DesktopMediaStrip(
                    files: post.attachments,
                    currentIndex: focusedIndex.value,
                    onSelect: (index) {
                      pageController.animateToPage(
                        index,
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeOutCubic,
                      );
                    },
                  ),
                ),
              ],
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
                                          trailing: trailing,
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

class _DesktopMediaPage extends StatelessWidget {
  final IDisplayableCloudFile file;
  final String heroTag;
  final SnPost sourcePost;
  final VoidCallback onTap;

  const _DesktopMediaPage({
    required this.file,
    required this.heroTag,
    required this.sourcePost,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final ratio = file.ratio?.toDouble() ?? 1.0;
    final isAudio = file.mimeType.startsWith('audio');

    Widget content = CloudFileWidget(
      item: file,
      heroTag: heroTag,
      fit: BoxFit.contain,
      noBlurhash: true,
      useInternalGate: false,
      sourcePost: sourcePost,
    );

    if (isAudio) {
      content = SizedBox(height: 160, child: content);
    } else {
      content = AspectRatio(
        aspectRatio: ratio <= 0 ? 1.0 : ratio,
        child: content,
      );
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Center(child: content),
      ),
    );
  }
}

class _DesktopMediaArrowButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _DesktopMediaArrowButton({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 180),
        opacity: onTap == null ? 0.35 : 1,
        child: Material(
          color: Colors.black45,
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: SizedBox(
              width: 44,
              height: 44,
              child: Icon(icon, color: Colors.white, size: 22),
            ),
          ),
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

class _DesktopMediaStrip extends ConsumerWidget {
  final List<IDisplayableCloudFile> files;
  final int currentIndex;
  final ValueChanged<int> onSelect;

  const _DesktopMediaStrip({
    required this.files,
    required this.currentIndex,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      height: 76,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.black38,
          borderRadius: BorderRadius.circular(18),
        ),
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.all(10),
          itemCount: files.length,
          separatorBuilder: (_, _) => const Gap(10),
          itemBuilder: (context, index) {
            final file = files[index];
            final isActive = index == currentIndex;
            return GestureDetector(
              onTap: () => onSelect(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 96,
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: isActive ? Colors.white : Colors.white24,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: isActive
                      ? const [
                          BoxShadow(
                            color: Colors.black45,
                            blurRadius: 12,
                            offset: Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: ColoredBox(
                    color: Colors.black,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Positioned.fill(
                          child: file.mimeType.startsWith('video')
                              ? Consumer(
                                  builder: (context, ref, _) {
                                    final serverUrl = ref.watch(
                                      serverUrlProvider,
                                    );
                                    final uri =
                                        file.storageUrl ??
                                        '$serverUrl/drive/files/${file.id}';
                                    return UniversalImage(
                                      uri: '$uri?thumbnail=true',
                                      fit: BoxFit.cover,
                                    );
                                  },
                                )
                              : CloudFileWidget(
                                  item: file,
                                  fit: BoxFit.cover,
                                  noBlurhash: true,
                                  useInternalGate: false,
                                ),
                        ),
                        if (file.mimeType.startsWith('video'))
                          const Center(
                            child: Icon(
                              Symbols.play_arrow,
                              color: Colors.white,
                              size: 24,
                              shadows: [
                                BoxShadow(
                                  color: Colors.black54,
                                  offset: Offset(1, 1),
                                  spreadRadius: 8,
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
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
  final ValueChanged<bool> onAppBarVisibilityChanged;

  const _BlogPostDetailLayout({
    required this.post,
    required this.postId,
    required this.trailing,
    required this.translatedText,
    required this.isTranslating,
    required this.onTranslate,
    required this.onRefresh,
    required this.onUpdate,
    required this.onAppBarVisibilityChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userInfoProvider).value;
    final mediaQuery = MediaQuery.of(context);
    final lastScrollOffset = useRef(0.0);
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

    void handleWebViewScroll(double offsetY) {
      final previous = lastScrollOffset.value;
      lastScrollOffset.value = offsetY;
      if (offsetY <= 8) {
        onAppBarVisibilityChanged(true);
        return;
      }
      if (offsetY - previous > 12) {
        onAppBarVisibilityChanged(false);
      } else if (previous - offsetY > 12) {
        onAppBarVisibilityChanged(true);
      }
    }

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
          body: _BlogPostWebView(
            url: _getBlogUrl(post),
            onScrollChanged: handleWebViewScroll,
          ),
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
  final ValueChanged<double>? onScrollChanged;

  const _BlogPostWebView({required this.url, this.onScrollChanged});

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
          onScrollChanged: (_, _, y) {
            onScrollChanged?.call(y.toDouble());
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
    final isBlogAppBarVisible = useState(true);
    final currentLanguage = context.locale.toString();
    final currentPost = postState.asData?.value;
    final isBlogPost = currentPost?.type == 2;

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

    if (isEmbedded && isBlogPost) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (isBlogAppBarVisible.value) {
          isBlogAppBarVisible.value = false;
        }
      });
    }

    return postState.when(
      data: (post) {
        final postItem = post!;
        final isMediaPostLayout =
            isWideScreen(context) && _isMediaPost(postItem) && !isEmbedded;

        Widget buildMenuItem({required String label, required IconData icon}) {
          return Row(
            children: [
              Icon(icon, size: 18),
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
                        onAppBarVisibilityChanged: (visible) {
                          if (!isEmbedded) {
                            isBlogAppBarVisible.value = visible;
                          }
                        },
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
    return AppScaffold(
      isNoBackground: false,
      appBar: AppBar(
        leading: const AutoLeadingButton(),
        title: Text('postDetail').tr(),
      ),
      body: _PostDetailBody(id: id),
    );
  }
}
