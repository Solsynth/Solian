import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/models/post.dart';
import 'package:island/pods/network.dart';
import 'package:island/pods/userinfo.dart';
import 'package:island/screens/posts/compose.dart';
import 'package:island/widgets/alert.dart';
import 'package:island/widgets/app_scaffold.dart';
import 'package:island/widgets/extended_refresh_indicator.dart';
import 'package:island/widgets/post/post_item.dart';
import 'package:island/widgets/post/post_pin_sheet.dart';
import 'package:island/widgets/post/post_quick_reply.dart';
import 'package:island/widgets/post/post_replies.dart';
import 'package:island/widgets/response.dart';
import 'package:island/utils/share_utils.dart';
import 'package:island/widgets/safety/abuse_report_helper.dart';
import 'package:island/widgets/share/share_sheet.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:styled_widget/styled_widget.dart';

part 'post_detail.g.dart';

@riverpod
Future<SnPost?> post(Ref ref, String id) async {
  final client = ref.watch(apiClientProvider);
  final resp = await client.get('/sphere/posts/$id');
  return SnPost.fromJson(resp.data);
}

final postStateProvider =
    StateNotifierProvider.family<PostState, AsyncValue<SnPost?>, String>(
      (ref, id) => PostState(ref, id),
    );

class PostState extends StateNotifier<AsyncValue<SnPost?>> {
  final Ref _ref;
  final String _id;

  PostState(this._ref, this._id) : super(const AsyncValue.loading()) {
    // Initialize with the initial post data
    _ref.listen<AsyncValue<SnPost?>>(
      postProvider(_id),
      (_, next) => state = next,
    );
  }

  void updatePost(SnPost? newPost) {
    if (newPost != null) {
      state = AsyncData(newPost);
    }
  }
}

class PostActionButtons extends HookConsumerWidget {
  final SnPost post;
  final VoidCallback? onRefresh;
  final Function(SnPost)? onUpdate;

  const PostActionButtons({
    super.key,
    required this.post,
    this.onRefresh,
    this.onUpdate,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userInfoProvider);
    final isAuthor =
        user.value != null && user.value?.id == post.publisher.accountId;

    final actions = <Widget>[];

    const kButtonHeight = 40.0;
    const kButtonRadius = 20.0;

    // 1. Author-only actions first
    if (isAuthor) {
      // Combined edit/delete actions using custom segmented-style buttons
      final editButtons = <Widget>[
        FilledButton.tonal(
          onPressed: () {
            context.pushNamed('postEdit', pathParameters: {'id': post.id}).then(
              (value) {
                if (value != null) {
                  onRefresh?.call();
                }
              },
            );
          },
          style: FilledButton.styleFrom(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(kButtonRadius),
                bottomLeft: Radius.circular(kButtonRadius),
              ),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Symbols.edit, size: 18),
              const Gap(4),
              Text('edit'.tr()),
            ],
          ),
        ),
        Tooltip(
          message: 'delete'.tr(),
          child: FilledButton.tonal(
            onPressed: () {
              showConfirmAlert('deletePostHint'.tr(), 'deletePost'.tr()).then((
                confirm,
              ) {
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
            style: FilledButton.styleFrom(
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(kButtonRadius),
                  bottomRight: Radius.circular(kButtonRadius),
                ),
              ),
            ),
            child: const Icon(Symbols.delete, size: 18),
          ),
        ),
      ];

      actions.add(
        Row(
          mainAxisSize: MainAxisSize.min,
          children:
              editButtons
                  .map((e) => SizedBox(height: kButtonHeight, child: e))
                  .toList(),
        ),
      );

      // Pin/Unpin actions (also author-only)
      if (post.pinMode == null) {
        actions.add(
          FilledButton.tonalIcon(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (context) => PostPinSheet(post: post),
              ).then((value) {
                if (value is int) {
                  onUpdate?.call(post.copyWith(pinMode: value));
                }
              });
            },
            icon: const Icon(Symbols.keep),
            label: Text('pinPost'.tr()),
          ),
        );
      } else {
        actions.add(
          FilledButton.tonalIcon(
            onPressed: () {
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
            },
            icon: const Icon(Symbols.keep_off),
            label: Text('unpinPost'.tr()),
          ),
        );
      }
    }

    // 2. Replies and forwards
    final replyButtons = <Widget>[
      FilledButton.tonal(
        onPressed: () {
          context.pushNamed(
            'postCompose',
            extra: PostComposeInitialState(replyingTo: post),
          );
        },
        style: FilledButton.styleFrom(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(kButtonRadius),
              bottomLeft: Radius.circular(kButtonRadius),
            ),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Symbols.reply, size: 18),
            const Gap(4),
            Text('reply'.tr()),
          ],
        ),
      ),
      Tooltip(
        message: 'forward'.tr(),
        child: FilledButton.tonal(
          onPressed: () {
            context.pushNamed(
              'postCompose',
              extra: PostComposeInitialState(forwardingTo: post),
            );
          },
          style: FilledButton.styleFrom(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(kButtonRadius),
                bottomRight: Radius.circular(kButtonRadius),
              ),
            ),
          ),
          child: const Icon(Symbols.forward, size: 18),
        ),
      ),
    ];

    actions.add(
      Row(
        mainAxisSize: MainAxisSize.min,
        children:
            replyButtons
                .map((e) => SizedBox(height: kButtonHeight, child: e))
                .toList(),
      ),
    );

    // 3. Share, copy link, and report
    final shareButtons = <Widget>[
      FilledButton.tonal(
        onPressed: () {
          showShareSheetLink(
            context: context,
            link: 'https://solian.app/posts/${post.id}',
            title: 'sharePost'.tr(),
            toSystem: true,
          );
        },
        style: FilledButton.styleFrom(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(kButtonRadius),
              bottomLeft: Radius.circular(kButtonRadius),
            ),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Symbols.share, size: 18),
            const Gap(4),
            Text('share'.tr()),
          ],
        ),
      ),
    ];

    if (!kIsWeb) {
      shareButtons.add(
        Tooltip(
          message: 'sharePostPhoto'.tr(),
          child: FilledButton.tonal(
            onPressed: () => sharePostAsScreenshot(context, ref, post),
            style: FilledButton.styleFrom(
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(kButtonRadius),
                  bottomRight: Radius.circular(kButtonRadius),
                ),
              ),
            ),
            child: const Icon(Symbols.share_reviews, size: 18),
          ),
        ),
      );
    }

    actions.add(
      Row(
        mainAxisSize: MainAxisSize.min,
        children:
            shareButtons
                .map((e) => SizedBox(height: kButtonHeight, child: e))
                .toList(),
      ),
    );

    actions.add(
      FilledButton.tonalIcon(
        onPressed: () {
          Clipboard.setData(
            ClipboardData(text: 'https://solian.app/posts/${post.id}'),
          );
        },
        icon: const Icon(Symbols.link),
        label: Text('copyLink'.tr()),
      ),
    );

    actions.add(
      FilledButton.tonalIcon(
        onPressed: () {
          showAbuseReportSheet(context, resourceIdentifier: 'post/${post.id}');
        },
        icon: const Icon(Symbols.flag),
        label: Text('abuseReport'.tr()),
      ),
    );

    // Add gaps between actions (excluding first one) using FP style
    final children =
        actions.asMap().entries.expand((entry) {
          final index = entry.key;
          final action = entry.value;
          if (index == 0) {
            return [action];
          } else {
            return [const Gap(8), action];
          }
        }).toList();

    return Container(
      height: kButtonHeight,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        children: children,
      ),
    );
  }
}

class PostDetailScreen extends HookConsumerWidget {
  final String id;
  const PostDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postState = ref.watch(postStateProvider(id));
    final user = ref.watch(userInfoProvider);

    return AppScaffold(
      isNoBackground: false,
      appBar: AppBar(
        leading: const PageBackButton(),
        title: Text('postDetail').tr(),
      ),
      body: postState.when(
        data: (post) {
          return Stack(
            fit: StackFit.expand,
            children: [
              ExtendedRefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(postProvider(id));
                  ref.invalidate(postRepliesNotifierProvider(id));
                },
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                      child: Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: 600),
                          child: PostItem(
                            item: post!,
                            isFullPost: true,
                            isEmbedReply: false,
                            onUpdate: (newItem) {
                              // Update the local state with the new post data
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
                          constraints: BoxConstraints(maxWidth: 600),
                          child: PostActionButtons(
                            post: post,
                            onRefresh: () {
                              ref.invalidate(postProvider(id));
                              ref.invalidate(postRepliesNotifierProvider(id));
                            },
                            onUpdate: (newItem) {
                              ref
                                  .read(postStateProvider(id).notifier)
                                  .updatePost(newItem);
                            },
                          ),
                        ),
                      ),
                    ),
                    PostRepliesList(postId: id, maxWidth: 600),
                    SliverGap(MediaQuery.of(context).padding.bottom + 80),
                  ],
                ),
              ),
              if (user.value != null)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Material(
                    elevation: 2,
                    color: Theme.of(context).colorScheme.surfaceContainer,
                    child: postState
                        .when(
                          data:
                              (post) => PostQuickReply(
                                parent: post!,
                                onPosted: () {
                                  ref.invalidate(
                                    postRepliesNotifierProvider(id),
                                  );
                                },
                              ),
                          loading: () => const SizedBox.shrink(),
                          error: (_, _) => const SizedBox.shrink(),
                        )
                        .padding(
                          bottom: MediaQuery.of(context).padding.bottom + 8,
                          top: 8,
                          horizontal: 16,
                        ),
                  ),
                ),
            ],
          );
        },
        loading: () => ResponseLoadingWidget(),
        error:
            (e, _) => ResponseErrorWidget(
              error: e,
              onRetry: () => ref.invalidate(postProvider(id)),
            ),
      ),
    );
  }
}
