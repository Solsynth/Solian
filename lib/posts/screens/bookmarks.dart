import 'package:easy_localization/easy_localization.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/account_pod.dart';
import 'package:island/core/services/time.dart';
import 'package:island/posts/pods/bookmarks.dart';
import 'package:island/posts/widgets/compose/post_interactions.dart';
import 'package:island/posts/widgets/compose/post_item.dart';
import 'package:island/posts/widgets/compose/post_item_skeleton.dart';
import 'package:island/shared/widgets/app_scaffold.dart';
import 'package:island/shared/widgets/pagination_list.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

const _maxWidth = 540.0;

@RoutePage()
class BookmarksScreen extends HookConsumerWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: AppScaffold(
        isNoBackground: false,
        appBar: AppBar(
          title: const Text('browseFootprints').tr(),
          bottom: TabBar(
            labelColor: Theme.of(context).appBarTheme.foregroundColor,
            unselectedLabelColor: Theme.of(
              context,
            ).appBarTheme.foregroundColor?.withOpacity(0.6),
            tabs: [
              Tab(
                icon: const Icon(Symbols.bookmark, size: 18),
                text: 'bookmarks'.tr(),
              ),
              Tab(
                icon: const Icon(Symbols.add_reaction, size: 18),
                text: 'reactedPosts'.tr(),
              ),
            ],
          ),
        ),
        body: const TabBarView(children: [_BookmarksTab(), _ReactedPostsTab()]),
      ),
    );
  }
}

class _BookmarksTab extends HookConsumerWidget {
  const _BookmarksTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = bookmarksProvider;

    return PaginationList(
      provider: provider,
      notifier: provider.notifier,
      padding: EdgeInsets.symmetric(vertical: 8),
      footerSkeletonChild: const PostItemSkeleton(),
      footerSkeletonMaxWidth: _maxWidth,
      itemBuilder: (context, index, item) {
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: _maxWidth),
            child: Card(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: PostActionableItem(
                borderRadius: 8,
                item: item,
                isShowReference: false,
                isEmbedOpenable: true,
                onUpdate: (newPost) {
                  if (!newPost.isBookmarked) {
                    ref.read(provider.notifier).refresh();
                  }
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ReactedPostsTab extends HookConsumerWidget {
  const _ReactedPostsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userInfoProvider);
    final username = user.value?.name;

    if (username == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final provider = userReactionsProvider(username);

    return PaginationList(
      provider: provider,
      notifier: provider.notifier,
      padding: EdgeInsets.symmetric(vertical: 8),
      footerSkeletonChild: const PostItemSkeleton(),
      footerSkeletonMaxWidth: _maxWidth,
      itemBuilder: (context, index, item) {
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: _maxWidth),
            child: Card(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                    child: Row(
                      children: [
                        buildReactionIcon(item.reaction.symbol, 24),
                        const SizedBox(width: 8),
                        Text(
                          ReactInfo.getTranslationKey(item.reaction.symbol),
                        ).tr(),
                        const Spacer(),
                        Text(
                          item.reaction.createdAt.formatRelative(context),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  PostActionableItem(
                    borderRadius: 8,
                    item: item.post,
                    isShowReference: false,
                    isEmbedOpenable: true,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
