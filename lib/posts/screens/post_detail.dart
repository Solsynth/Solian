import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/network.dart';
import 'package:island/accounts/account_pod.dart';
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
import 'package:island/tickets/widgets/ticket_fire.dart';
import 'package:island/route.gr.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/shared/widgets/app_scaffold.dart' hide PageBackButton;
import 'package:island/core/widgets/content/cloud_file_collection.dart';
import 'package:island/shared/widgets/extended_refresh_indicator.dart';
import 'package:island/shared/widgets/response.dart';
import 'package:island/core/utils/share_utils.dart';
import 'package:island/sharing/share_sheet.dart';
import 'package:island/thoughts/screens/think_sheet.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

part 'post_detail.g.dart';

@riverpod
Future<SnPost?> post(Ref ref, String id) async {
  final client = ref.watch(apiClientProvider);
  final resp = await client.get('/sphere/posts/$id');
  return SnPost.fromJson(resp.data);
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

class PostActionButtons extends HookConsumerWidget {
  final SnPost post;
  final EdgeInsets renderingPadding;
  final VoidCallback? onRefresh;
  final Function(SnPost)? onUpdate;

  const PostActionButtons({
    super.key,
    required this.post,
    this.renderingPadding = EdgeInsets.zero,
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
                  final client = ref.watch(apiClientProvider);
                  client
                      .delete('/sphere/posts/${post.id}')
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
                    final client = ref.watch(apiClientProvider);
                    try {
                      if (context.mounted) showLoadingModal(context);
                      await client.delete('/sphere/posts/${post.id}/pin');
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

    actions.add(
      PopupMenuButton<String>(
        tooltip: 'more'.tr(),
        icon: const Icon(Symbols.more_vert, size: 18),
        onSelected: (value) {
          switch (value) {
            case 'copy':
              Clipboard.setData(
                ClipboardData(text: 'https://solian.app/posts/${post.id}'),
              );
              break;
            case 'report':
              showAbuseReportSheet(
                context,
                resourceIdentifier: 'post/${post.id}',
              );
              break;
          }
        },
        itemBuilder: (context) => [
          PopupMenuItem(
            value: 'copy',
            child: Row(
              children: [
                const Icon(Symbols.link, size: 18),
                const Gap(8),
                Text('copyLink'.tr()),
              ],
            ),
          ),
          PopupMenuItem(
            value: 'report',
            child: Row(
              children: [
                const Icon(Symbols.flag, size: 18),
                const Gap(8),
                Text('abuseReport'.tr()),
              ],
            ),
          ),
        ],
      ),
    );

    return Padding(
      padding: renderingPadding.copyWith(
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
                                          parentId: post.id,
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
                                          renderingPadding:
                                              const EdgeInsets.only(top: 8),
                                          onRefresh: onRefresh,
                                          onUpdate: onUpdate,
                                        ).alignment(Alignment.centerLeft),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SliverFillRemaining(
                              child: PostInteractionsTabs(
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
    final user = ref.watch(userInfoProvider);

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
                        physics: const AlwaysScrollableScrollPhysics(),
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
                                ),
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
                          SliverFillRemaining(
                            child: DefaultTabController(
                              length: 4,
                              child: PostInteractionsTabs(
                                postId: id,
                                maxWidth: _postDetailMaxWidth,
                              ),
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
