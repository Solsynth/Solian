import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:auto_route/auto_route.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/network.dart';
import 'package:island/accounts/account_pod.dart';
import 'package:island/posts/pods/bookmarks.dart';
import 'package:island/core/services/time.dart';
import 'package:island/posts/compose.dart';
import 'package:island/core/services/responsive.dart';
import 'package:island/posts/widgets/compose/compose_dialog.dart';
import 'package:island/posts/widgets/compose/embed_view_renderer.dart';
import 'package:island/posts/widgets/compose/post_award_history_sheet.dart';
import 'package:island/posts/widgets/compose/post_award_sheet.dart';
import 'package:island/posts/widgets/compose/post_item.dart';
import 'package:island/posts/widgets/compose/post_pin_sheet.dart';
import 'package:island/posts/widgets/compose/post_quick_reply.dart';
import 'package:island/posts/widgets/compose/post_replies.dart';
import 'package:island/posts/widgets/compose/post_interactions.dart';
import 'package:island/posts/widgets/compose/post_shared.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:island/tickets/widgets/ticket_fire.dart';
import 'package:island/route.gr.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/shared/widgets/app_scaffold.dart' hide PageBackButton;
import 'package:island/core/widgets/content/cloud_file_collection.dart';
import 'package:island/shared/widgets/layouts/sheet_scaffold.dart';
import 'package:island/shared/widgets/extended_refresh_indicator.dart';
import 'package:island/shared/widgets/response.dart';
import 'package:island/core/utils/share_utils.dart';
import 'package:island/sharing/share_sheet.dart';
import 'package:island/thoughts/screens/think_sheet.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
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

SnCloudFile? _getPostThumbnail(SnPost post) {
  final thumbnailId = post.meta?['thumbnail'] as String?;
  if (thumbnailId == null) return null;
  try {
    return post.attachments.firstWhere((a) => a.id == thumbnailId);
  } catch (_) {
    return null;
  }
}

class _PostRealmBadge extends ConsumerWidget {
  final SnRealm realm;

  const _PostRealmBadge({required this.realm});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        context.router.push(RealmDetailRoute(slug: realm.slug));
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: theme.colorScheme.tertiaryContainer.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 8,
          children: [
            Icon(
              Symbols.public,
              size: 18,
              color: theme.colorScheme.onTertiaryContainer,
              fill: 1,
            ),
            Text(
              'publisherBelongsToRealm'.tr(args: [realm.name]),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const Spacer(),
            Icon(
              Symbols.chevron_right,
              size: 18,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ],
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

  const PostActionButtons({
    super.key,
    required this.post,
    this.renderingPadding = EdgeInsets.zero,
    this.noBottomPadding = false,
    this.onRefresh,
    this.onUpdate,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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

    final actions = <Widget>[];

    if (isAuthor) {
      actions.add(
        Tooltip(
          message: 'edit'.tr(),
          child: IconButton(
            onPressed: () {
              if (post.type == 1) {
                context.router.push(ArticleEditRoute(id: post.id)).then((
                  value,
                ) {
                  if (value != null) {
                    onRefresh?.call();
                  }
                });
              } else {
                PostComposeDialog.show(context, originalPost: post).then((
                  value,
                ) {
                  if (value == true) {
                    onRefresh?.call();
                  }
                });
              }
            },
            icon: const Icon(Symbols.edit, size: 18),
          ),
        ),
      );

      actions.add(
        Tooltip(
          message: 'delete'.tr(),
          child: IconButton(
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
            icon: const Icon(Symbols.delete, size: 18),
          ),
        ),
      );

      actions.add(
        Tooltip(
          message: post.pinMode == null ? 'pinPost'.tr() : 'unpinPost'.tr(),
          child: IconButton(
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
            icon: Icon(
              post.pinMode == null ? Symbols.keep : Symbols.keep_off,
              size: 18,
            ),
          ),
        ),
      );
    }

    actions.add(
      Tooltip(
        message: 'reply'.tr(),
        child: IconButton(
          onPressed: () {
            PostComposeDialog.show(
              context,
              initialState: PostComposeInitialState(replyingTo: post),
            );
          },
          icon: const Icon(Symbols.reply, size: 18),
        ),
      ),
    );

    actions.add(
      Tooltip(
        message: 'fullThread'.tr(),
        child: IconButton(
          onPressed: () => _showPostThreadSheet(context, post),
          icon: const Icon(Symbols.forum, size: 18),
        ),
      ),
    );

    actions.add(
      Tooltip(
        message: 'forward'.tr(),
        child: IconButton(
          onPressed: () {
            PostComposeDialog.show(
              context,
              initialState: PostComposeInitialState(forwardingTo: post),
            );
          },
          icon: const Icon(Symbols.forward, size: 18),
        ),
      ),
    );

    actions.add(
      Tooltip(
        message: post.awardedScore > 0
            ? '${formatScore(post.awardedScore)} pts'
            : 'award'.tr(),
        child: IconButton(
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
              builder: (context) => PostAwardHistorySheet(postId: post.id),
            );
          },
          icon: const Icon(Symbols.emoji_events, size: 18),
        ),
      ),
    );

    actions.add(
      Tooltip(
        message: 'aiThought'.tr(),
        child: IconButton(
          onPressed: () {
            ThoughtSheet.show(context, attachedPosts: [post.id]);
          },
          icon: const Icon(Symbols.smart_toy, size: 18),
        ),
      ),
    );

    actions.add(
      Tooltip(
        message: 'share'.tr(),
        child: IconButton(
          onPressed: () {
            showShareSheetLink(
              context: context,
              link: 'https://solian.app/posts/${post.id}',
              title: 'sharePost'.tr(),
              toSystem: true,
            );
          },
          icon: const Icon(Symbols.share, size: 18),
        ),
      ),
    );

    final bookmarkStatus = ref.watch(bookmarkStatusProvider(post.id));
    final isBookmarked = bookmarkStatus.when(
      data: (bookmark) => bookmark != null,
      loading: () => false,
      error: (_, _) => false,
    );

    actions.add(
      Tooltip(
        message: isBookmarked ? 'unbookmark'.tr() : 'bookmark'.tr(),
        child: IconButton(
          onPressed: () async {
            final client = ref.read(solarNetworkClientProvider);
            try {
              if (isBookmarked) {
                await client.sphere.unbookmarkPost(post.id);
              } else {
                await client.sphere.bookmarkPost(post.id);
              }
              ref.invalidate(bookmarkStatusProvider(post.id));
            } catch (err) {
              showErrorAlert(err);
            }
          },
          icon: Icon(
            isBookmarked ? Symbols.bookmark_added : Symbols.bookmark,
            size: 18,
          ),
        ),
      ),
    );

    if (!kIsWeb) {
      actions.add(
        Tooltip(
          message: 'sharePostPhoto'.tr(),
          child: IconButton(
            onPressed: () => sharePostAsScreenshot(context, ref, post),
            icon: const Icon(Symbols.share_reviews, size: 18),
          ),
        ),
      );
    }

    return Padding(
      padding: noBottomPadding
          ? renderingPadding
          : renderingPadding.copyWith(
              bottom: 4 + renderingPadding.vertical + renderingPadding.bottom,
            ),
      child: Wrap(
        spacing: 2,
        runSpacing: 2,
        alignment: WrapAlignment.start,
        runAlignment: WrapAlignment.start,
        children: actions,
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
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              useRootNavigator: true,
              builder: (context) => _PublicCollectionBrowserSheet(post: post),
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

  const _PublicCollectionBrowserSheet({required this.post});

  @override
  Widget build(BuildContext context) {
    final collections = post.publisherCollections;
    return SheetScaffold(
      titleText: 'postCollections'.tr(),
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
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                useRootNavigator: true,
                builder: (context) =>
                    _PublicCollectionSheet(post: post, collection: collection),
              );
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

  const _PublicCollectionSheet({required this.post, required this.collection});

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

    return SheetScaffold(
      titleText: title,
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
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                useRootNavigator: true,
                                builder: (context) => _PublicCollectionSheet(
                                  post: post,
                                  collection: collection,
                                ),
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
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              useRootNavigator: true,
              builder: (context) =>
                  _PublicCollectionSheet(post: post, collection: collection),
            );
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

class _PostThreadCard extends StatelessWidget {
  final SnPost post;

  const _PostThreadCard({required this.post});

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
                    onPostTap: (id) => context.router.push(PostDetailRoute(id: id)),
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
    final childrenByParentId = buildThreadChildrenMap(thread.allNodes, hiddenParentId: widget.post.id);
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

  const _PostDetailLargeScreenLayout({
    required this.post,
    required this.postId,
    required this.onUpdate,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userInfoProvider);

    Widget buildMenuItem({required String label, required IconData icon}) {
      return Row(
        children: [
          Icon(icon, size: 18),
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
            final client = ref.read(solarNetworkClientProvider);
            try {
              if (post.isBookmarked) {
                await client.sphere.unbookmarkPost(post.id);
                onRefresh.call();
              } else {
                await client.sphere.bookmarkPost(post.id);
                onRefresh.call();
              }
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
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: CloudFileList(
                files: post.attachments,
                disableConstraint: true,
                padding: EdgeInsets.zero,
              ),
            ),
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
                                        ).alignment(Alignment.centerLeft),
                                        if (post.repliedPostId != null ||
                                            post.forwardedPostId != null)
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              top: 8,
                                            ),
                                            child: _PostThreadCard(post: post),
                                          ),
                                        if (post.realm != null)
                                          _PostRealmBadge(
                                            realm: post.realm!,
                                          ).padding(top: 8),
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
                            .read(postRepliesProvider(postId).notifier)
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

@RoutePage()
class PostDetailScreen extends HookConsumerWidget {
  final String id;

  const PostDetailScreen({super.key, @PathParam('id') required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postState = ref.watch(postStateProvider(id));

    return AppScaffold(
      isNoBackground: false,
      appBar: AppBar(
        leading: const AutoLeadingButton(),
        title: Text('postDetail').tr(),
      ),
      body: postState.when(
        data: (post) {
          final postItem = post!;
          final thumbnail = _getPostThumbnail(postItem);
          final isMediaPostLayout =
              isWideScreen(context) && _isMediaPost(postItem);

          Widget buildMenuItem({
            required String label,
            required IconData icon,
          }) {
            return Row(
              children: [
                Icon(icon, size: 18),
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
                    originalPost: postItem,
                  );
                  if (result != null) {
                    ref.invalidate(postProvider(id));
                    ref.read(postRepliesProvider(id).notifier).refresh();
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
                          .deletePost(postItem.id)
                          .catchError((err) {
                            showErrorAlert(err);
                            return err;
                          })
                          .then((_) {
                            ref.invalidate(postProvider(id));
                            ref
                                .read(postRepliesProvider(id).notifier)
                                .refresh();
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
                  if (result != null) {
                    ref.invalidate(postProvider(id));
                    ref.read(postRepliesProvider(id).notifier).refresh();
                  }
                };
              case 'forward':
                return () async {
                  final result = await PostComposeDialog.show(
                    context,
                    initialState: PostComposeInitialState(
                      forwardingTo: postItem,
                    ),
                  );
                  if (result != null) {
                    ref.invalidate(postProvider(id));
                    ref.read(postRepliesProvider(id).notifier).refresh();
                  }
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
                  showConfirmAlert('unpinPostHint'.tr(), 'unpinPost'.tr()).then(
                    (confirm) async {
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
                    },
                  );
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
                    ref.invalidate(postProvider(id));
                    ref.read(postRepliesProvider(id).notifier).refresh();
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
                  final client = ref.read(solarNetworkClientProvider);
                  try {
                    if (postItem.isBookmarked) {
                      await client.sphere.unbookmarkPost(postItem.id);
                      ref.invalidate(postProvider(id));
                      ref.read(postRepliesProvider(id).notifier).refresh();
                    } else {
                      await client.sphere.bookmarkPost(postItem.id);
                      ref.invalidate(postProvider(id));
                      ref.read(postRepliesProvider(id).notifier).refresh();
                    }
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
                child: buildMenuItem(
                  label: 'delete'.tr(),
                  icon: Symbols.delete,
                ),
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
              child: buildMenuItem(
                label: 'forward'.tr(),
                icon: Symbols.forward,
              ),
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
                label: postItem.isBookmarked ? 'unbookmark'.tr() : 'bookmark'.tr(),
                icon: postItem.isBookmarked ? Symbols.bookmark_added : Symbols.bookmark,
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
              child: buildMenuItem(
                label: 'abuseReport'.tr(),
                icon: Symbols.flag,
              ),
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

          return Stack(
            fit: StackFit.expand,
            children: [
              ExtendedRefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(postProvider(id));
                  ref.read(postRepliesProvider(id).notifier).refresh();
                },
                child: isMediaPostLayout
                    ? _PostDetailLargeScreenLayout(
                        post: postItem,
                        postId: id,
                        onUpdate: (newItem) {
                          ref
                              .read(postStateProvider(id).notifier)
                              .updatePost(newItem);
                        },
                        onRefresh: () {
                          ref.invalidate(postProvider(id));
                          ref.read(postRepliesProvider(id).notifier).refresh();
                        },
                      )
                    : CustomScrollView(
                        slivers: [
                          if (postItem.type == 1 && thumbnail != null)
                            SliverToBoxAdapter(
                              child: Center(
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    maxWidth: _postDetailMaxWidth,
                                  ),
                                  child: ClipRRect(
                                    borderRadius: const BorderRadius.all(
                                      Radius.circular(12),
                                    ),
                                    child: CloudFileList(
                                      files: [thumbnail],
                                      padding: EdgeInsets.zero,
                                      disableConstraint: true,
                                    ),
                                  ).padding(left: 8, right: 8, top: 16),
                                ),
                              ),
                            ),
                          SliverToBoxAdapter(
                            child: Center(
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxWidth: _postDetailMaxWidth,
                                ),
                                child: PostItem(
                                  item: postItem,
                                  isFullPost: true,
                                  isEmbedReply: false,
                                  textScale: postItem.type == 1 ? 1.2 : 1.1,
                                  padding: const EdgeInsets.fromLTRB(
                                    8,
                                    8,
                                    8,
                                    0,
                                  ),
                                  onUpdate: (newItem) {
                                    ref
                                        .read(postStateProvider(id).notifier)
                                        .updatePost(newItem);
                                  },
                                  trailing: trailing,
                                ),
                              ),
                            ),
                          ),
                          if (postItem.repliedPostId != null ||
                              postItem.forwardedPostId != null)
                            SliverToBoxAdapter(
                              child: Center(
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    maxWidth: _postDetailMaxWidth,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      16,
                                      8,
                                      16,
                                      0,
                                    ),
                                    child: _PostThreadCard(post: postItem),
                                  ),
                                ),
                              ),
                            ),
                          if (postItem.publisherCollections.isNotEmpty)
                            SliverToBoxAdapter(
                              child: Center(
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    maxWidth: _postDetailMaxWidth,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      16,
                                      8,
                                      16,
                                      0,
                                    ),
                                    child: PostCollectionNavigation(
                                      post: postItem,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          if (postItem.realm != null)
                            SliverToBoxAdapter(
                              child: Center(
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    maxWidth: _postDetailMaxWidth,
                                  ),
                                  child: _PostRealmBadge(
                                    realm: postItem.realm!,
                                  ).padding(horizontal: 16, top: 8),
                                ),
                              ),
                            ),
                          SliverToBoxAdapter(
                            child: Center(
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxWidth: _postDetailMaxWidth,
                                ),
                                child: PostActionButtons(
                                  post: postItem,
                                  renderingPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  onRefresh: () {
                                    ref.invalidate(postProvider(id));
                                    ref
                                        .read(postRepliesProvider(id).notifier)
                                        .refresh();
                                  },
                                  onUpdate: (newItem) {
                                    ref
                                        .read(postStateProvider(id).notifier)
                                        .updatePost(newItem);
                                  },
                                ).alignment(Alignment.centerLeft),
                              ),
                            ),
                          ),
                          DefaultTabController(
                            length: 4,
                            child: PostInteractionsSlivers(
                              postId: id,
                              maxWidth: _postDetailMaxWidth,
                            ),
                          ),
                          SliverGap(MediaQuery.of(context).padding.bottom + 80),
                        ],
                      ),
              ),
              if (user.value != null && !isMediaPostLayout)
                Positioned(
                  bottom: 16 + MediaQuery.of(context).padding.bottom,
                  left: 16,
                  right: 16,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: _postDetailMaxWidth,
                    ),
                    child: postState.when(
                      data: (post) => PostQuickReply(
                        parent: post!,
                        onPosted: () {
                          ref.read(postRepliesProvider(id).notifier).refresh();
                        },
                      ),
                      loading: () => const SizedBox.shrink(),
                      error: (_, _) => const SizedBox.shrink(),
                    ),
                  ).center(),
                ),
            ],
          );
        },
        loading: () => ResponseLoadingWidget(),
        error: (e, _) => ResponseErrorWidget(
          error: e,
          onRetry: () => ref.invalidate(postProvider(id)),
        ),
      ),
    );
  }
}
