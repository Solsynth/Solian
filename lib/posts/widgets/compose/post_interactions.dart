import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/widgets/account/account_pfc.dart';
import 'package:island/accounts/widgets/activitypub/actor_profile.dart';
import 'package:island/core/network.dart';
import 'package:island/core/services/responsive.dart';
import 'package:island/core/services/time.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:island/posts/widgets/compose/post_item.dart';
import 'package:island/posts/widgets/compose/post_item_skeleton.dart';
import 'package:island/posts/widgets/compose/post_replies.dart';
import 'package:island/shared/widgets/pagination_list.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';
import 'package:skeletonizer/skeletonizer.dart';

const kAvailableStickers = {
  'angry',
  'clap',
  'confuse',
  'pray',
  'thumb_up',
  'party',
  'laugh',
  'sorry',
  'cry',
  'thumb_down',
};

bool _getReactionImageAvailable(String symbol) {
  return kAvailableStickers.contains(symbol);
}

Widget buildReactionIcon(String symbol, double size, {double iconSize = 24}) {
  if (_getReactionImageAvailable(symbol)) {
    return Image.asset(
      'assets/images/stickers/$symbol.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
      alignment: Alignment.bottomCenter,
    );
  } else {
    return SizedBox(
      width: iconSize,
      height: iconSize,
      child: FittedBox(
        fit: BoxFit.contain,
        child: Text(kReactionTemplates[symbol]?.icon ?? ''),
      ),
    );
  }
}

class SnBoost {
  final String id;
  final String postId;
  final String? actorId;
  final SnActivityPubActor? actor;
  final String? accountId;
  final SnAccount? account;
  final DateTime boostedAt;
  final String? activityPubUri;
  final String? webUrl;

  const SnBoost({
    required this.id,
    required this.postId,
    this.actorId,
    this.actor,
    this.accountId,
    this.account,
    required this.boostedAt,
    this.activityPubUri,
    this.webUrl,
  });

  factory SnBoost.fromJson(Map<String, dynamic> json) {
    return SnBoost(
      id: json['id'] as String,
      postId: json['post_id'] as String,
      actorId: json['actor_id'] as String?,
      actor: json['actor'] != null
          ? SnActivityPubActor.fromJson(json['actor'] as Map<String, dynamic>)
          : null,
      accountId: json['account_id'] as String?,
      account: json['account'] != null
          ? SnAccount.fromJson(json['account'] as Map<String, dynamic>)
          : null,
      boostedAt: DateTime.parse(json['boosted_at'] as String),
      activityPubUri: json['activity_pub_uri'] as String?,
      webUrl: json['web_url'] as String?,
    );
  }
}

final postForwardsProvider = AsyncNotifierProvider.autoDispose.family(
  PostForwardsNotifier.new,
);

class PostForwardsNotifier extends AsyncNotifier<PaginationState<SnPost>>
    with AsyncPaginationController<SnPost> {
  static const int pageSize = 20;

  final String arg;
  PostForwardsNotifier(this.arg);

  @override
  Future<List<SnPost>> fetch() async {
    final client = ref.read(solarNetworkClientProvider);

    final response = await client.dio.get(
      '/sphere/posts/$arg/forwards',
      queryParameters: {'offset': fetchedCount, 'take': pageSize},
    );

    totalCount = int.parse(response.headers.value('X-Total') ?? '0');
    final List<dynamic> data = response.data;
    return data
        .map((json) => SnPost.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}

final postBoostsProvider = AsyncNotifierProvider.autoDispose.family(
  PostBoostsNotifier.new,
);

class PostBoostsNotifier extends AsyncNotifier<PaginationState<SnBoost>>
    with AsyncPaginationController<SnBoost> {
  static const int pageSize = 20;

  final String arg;
  PostBoostsNotifier(this.arg);

  @override
  Future<List<SnBoost>> fetch() async {
    final client = ref.read(solarNetworkClientProvider);

    final response = await client.dio.get(
      '/sphere/posts/$arg/boosts',
      queryParameters: {'offset': fetchedCount, 'take': pageSize},
    );

    totalCount = int.parse(response.headers.value('X-Total') ?? '0');
    final List<dynamic> data = response.data;
    return data
        .map((json) => SnBoost.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}

final postReactionsProvider = AsyncNotifierProvider.autoDispose.family(
  PostReactionsNotifier.new,
);

class PostReactionsNotifier
    extends AsyncNotifier<PaginationState<SnPostReaction>>
    with AsyncPaginationController<SnPostReaction> {
  static const int pageSize = 20;

  final String arg;
  PostReactionsNotifier(this.arg);

  @override
  Future<List<SnPostReaction>> fetch() async {
    final client = ref.read(solarNetworkClientProvider);

    final response = await client.dio.get(
      '/sphere/posts/$arg/reactions',
      queryParameters: {'offset': fetchedCount, 'take': pageSize},
    );

    totalCount = int.parse(response.headers.value('X-Total') ?? '0');
    final List<dynamic> data = response.data;
    return data
        .map((json) => SnPostReaction.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}

class PostForwardsList extends HookConsumerWidget {
  final String postId;
  final double? maxWidth;
  const PostForwardsList({super.key, required this.postId, this.maxWidth});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = postForwardsProvider(postId);

    final skeletonItem = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: PostItemSkeleton(maxWidth: maxWidth ?? double.infinity),
    );

    return PaginationList(
      provider: provider,
      notifier: provider.notifier,
      isRefreshable: false,
      isSliver: false,
      padding: EdgeInsets.zero,
      footerSkeletonChild: maxWidth == null
          ? skeletonItem
          : Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth!),
                child: skeletonItem,
              ),
            ),
      itemBuilder: (context, index, item) {
        final contentWidget = Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: PostActionableItem(
            borderRadius: 8,
            item: item,
            isShowReference: false,
            isEmbedOpenable: true,
            onUpdate: (newPost) {
              // Forward posts are separate posts, not replies
            },
          ),
        );

        if (maxWidth == null) return contentWidget;

        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth!),
            child: contentWidget,
          ),
        );
      },
    );
  }
}

class PostBoostsList extends HookConsumerWidget {
  final String postId;
  final double? maxWidth;
  const PostBoostsList({super.key, required this.postId, this.maxWidth});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = postBoostsProvider(postId);

    final skeletonItem = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Skeletonizer(
        enabled: true,
        effect: ShimmerEffect(
          baseColor: Theme.of(context).colorScheme.surfaceContainerHigh,
          highlightColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        ),
        containersColor: Theme.of(context).colorScheme.surfaceContainerLow,
        child: const BoostListItemSkeleton(),
      ),
    );

    return PaginationList(
      provider: provider,
      notifier: provider.notifier,
      isRefreshable: false,
      isSliver: false,
      padding: EdgeInsets.zero,
      footerSkeletonChild: maxWidth == null
          ? skeletonItem
          : Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth!),
                child: skeletonItem,
              ),
            ),
      itemBuilder: (context, index, item) {
        final contentWidget = Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: BoostListItem(boost: item),
        );

        if (maxWidth == null) return contentWidget;

        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth!),
            child: contentWidget,
          ),
        );
      },
    );
  }
}

class PostReactionsList extends HookConsumerWidget {
  final String postId;
  final double? maxWidth;
  const PostReactionsList({super.key, required this.postId, this.maxWidth});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = postReactionsProvider(postId);

    final skeletonItem = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Skeletonizer(
        enabled: true,
        effect: ShimmerEffect(
          baseColor: Theme.of(context).colorScheme.surfaceContainerHigh,
          highlightColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        ),
        containersColor: Theme.of(context).colorScheme.surfaceContainerLow,
        child: const ReactionListItemSkeleton(),
      ),
    );

    return PaginationList(
      provider: provider,
      notifier: provider.notifier,
      isRefreshable: false,
      isSliver: false,
      padding: EdgeInsets.zero,
      footerSkeletonChild: maxWidth == null
          ? skeletonItem
          : Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth!),
                child: skeletonItem,
              ),
            ),
      itemBuilder: (context, index, item) {
        final contentWidget = Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: ReactionListItem(reaction: item),
        );

        if (maxWidth == null) return contentWidget;

        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth!),
            child: contentWidget,
          ),
        );
      },
    );
  }
}

class BoostListItem extends HookConsumerWidget {
  final SnBoost boost;
  const BoostListItem({super.key, required this.boost});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final actor = boost.actor;
    final account = boost.account;
    final displayName = actor?.displayName ?? account?.nick ?? 'unknown';
    final username = actor?.username ?? (account?.name ?? '');
    final avatarUrl = actor?.avatarUrl ?? account?.profile.picture?.url;

    return ListTile(
      leading: avatarUrl != null
          ? CircleAvatar(backgroundImage: NetworkImage(avatarUrl))
          : const CircleAvatar(child: Icon(Icons.person)),
      title: Text(displayName),
      subtitle: Text('@$username'),
      trailing: Text(
        _formatDate(boost.boostedAt),
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays > 0) {
      return '${diff.inDays}d';
    } else if (diff.inHours > 0) {
      return '${diff.inHours}h';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes}m';
    } else {
      return 'now';
    }
  }
}

class ReactionListItem extends HookConsumerWidget {
  final SnPostReaction reaction;
  const ReactionListItem({super.key, required this.reaction});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: AccountPfcRegion(
        uname: reaction.account?.name,
        child: reaction.actor != null
            ? ActorPictureWidget(actor: reaction.actor!, radius: 20)
            : ProfilePictureWidget(file: reaction.account?.profile.picture),
      ),
      title: Text(
        reaction.actor?.displayName ?? reaction.account?.nick ?? 'unknown'.tr(),
      ),
      subtitle: Text(
        '${reaction.createdAt.formatRelative(context)} · ${reaction.createdAt.formatSystem()}',
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 8,
        children: [
          Text(ReactInfo.getTranslationKey(reaction.symbol)).tr(),
          buildReactionIcon(reaction.symbol, 32),
        ],
      ),
    );
  }
}

class BoostListItemSkeleton extends StatelessWidget {
  const BoostListItemSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 120,
                    height: 14,
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: 80,
                    height: 10,
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ReactionListItemSkeleton extends StatelessWidget {
  const ReactionListItemSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 100,
                        height: 14,
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: 80,
                    height: 10,
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Non-sliver replies list for use with PaginationList
class PostRepliesListNonSliver extends HookConsumerWidget {
  final String postId;
  final double? maxWidth;
  const PostRepliesListNonSliver({
    super.key,
    required this.postId,
    this.maxWidth,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = postRepliesProvider(postId);
    final notifier = ref.read(provider.notifier);

    final skeletonItem = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: PostItemSkeleton(maxWidth: maxWidth ?? double.infinity),
    );

    return PaginationList(
      provider: provider,
      notifier: provider.notifier,
      isRefreshable: false,
      isSliver: false,
      padding: EdgeInsets.zero,
      footerSkeletonChild: maxWidth == null
          ? skeletonItem
          : Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth!),
                child: skeletonItem,
              ),
            ),
      itemBuilder: (context, index, item) {
        final contentWidget = Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: PostActionableItem(
            borderRadius: 8,
            item: item,
            isShowReference: false,
            isEmbedOpenable: true,
            onUpdate: (newPost) {
              notifier.updatePost(newPost);
            },
          ),
        );

        if (maxWidth == null) return contentWidget;

        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth!),
            child: contentWidget,
          ),
        );
      },
    );
  }
}

/// Widget for use in SliverFillRemaining - uses TabBarView with regular lists.
/// Suitable for large screen layout where tabs have independent scroll.
class PostInteractionsTabs extends StatelessWidget {
  final String postId;
  final double? maxWidth;

  const PostInteractionsTabs({super.key, required this.postId, this.maxWidth});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _TabBarWidget(maxWidth: maxWidth),
        const Gap(4),
        Expanded(
          child: _TabViews(postId: postId, maxWidth: maxWidth),
        ),
      ],
    );
  }
}

class _TabBarWidget extends StatelessWidget {
  final double? maxWidth;
  const _TabBarWidget({this.maxWidth});

  @override
  Widget build(BuildContext context) {
    final isWideMode = maxWidth != null && isWideScreen(context);

    final tabBarWidget = Container(
      margin: isWideMode
          ? const EdgeInsets.symmetric(horizontal: 16, vertical: 8)
          : EdgeInsets.zero,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: isWideMode
            ? BorderRadius.circular(24)
            : BorderRadius.zero,
      ),
      child: TabBar(
        dividerColor: Colors.transparent,
        indicatorSize: TabBarIndicatorSize.tab,
        splashBorderRadius: BorderRadius.circular(20),
        indicator: isWideMode
            ? BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(20),
              )
            : BoxDecoration(),
        labelColor: isWideMode ? Colors.white : null,
        unselectedLabelColor: isWideMode
            ? Theme.of(context).colorScheme.onSurfaceVariant
            : null,
        tabs: [
          Tab(text: 'replies'.tr()),
          Tab(text: 'forwards'.tr()),
          Tab(text: 'boosts'.tr()),
          Tab(text: 'reactions'.plural(0)),
        ],
      ),
    );

    if (isWideMode) {
      return Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth!),
          child: tabBarWidget,
        ),
      );
    }

    return tabBarWidget;
  }
}

class _TabViews extends HookConsumerWidget {
  final String postId;
  final double? maxWidth;
  const _TabViews({required this.postId, this.maxWidth});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TabBarView(
      children: [
        PostRepliesListNonSliver(postId: postId, maxWidth: maxWidth),
        PostForwardsList(postId: postId, maxWidth: maxWidth),
        PostBoostsList(postId: postId, maxWidth: maxWidth),
        PostReactionsList(postId: postId, maxWidth: maxWidth),
      ],
    );
  }
}

/// Sliver-based interactions for unified scrolling.
/// The TabBar is a SliverToBoxAdapter and the tab content integrates
/// with the parent CustomScrollView directly.
class PostInteractionsSlivers extends HookConsumerWidget {
  final String postId;
  final double? maxWidth;
  final TabController tabController;

  const PostInteractionsSlivers({
    super.key,
    required this.postId,
    this.maxWidth,
    required this.tabController,
  });

  Widget _buildTabBar(BuildContext context) {
    final isWideMode = maxWidth != null;

    final tabBarWidget = Container(
      margin: isWideMode
          ? const EdgeInsets.symmetric(horizontal: 16, vertical: 8)
          : EdgeInsets.zero,
      decoration: isWideMode
          ? BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(24),
            )
          : null,
      child: TabBar(
        controller: tabController,
        dividerColor: Colors.transparent,
        indicatorSize: TabBarIndicatorSize.tab,
        splashBorderRadius: BorderRadius.circular(20),
        indicator: isWideMode
            ? BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(20),
              )
            : null,
        labelColor: isWideMode ? Colors.white : null,
        unselectedLabelColor: isWideMode
            ? Theme.of(context).colorScheme.onSurfaceVariant
            : null,
        tabs: [
          Tab(text: 'replies'.tr()),
          Tab(text: 'forwards'.tr()),
          Tab(text: 'boosts'.tr()),
          Tab(text: 'reactions'.plural(0)),
        ],
      ),
    );

    if (isWideMode) {
      return Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth!),
          child: tabBarWidget,
        ),
      );
    }

    return tabBarWidget;
  }

  Widget _buildTabContent(BuildContext context) {
    final tabIndex = tabController.index;

    switch (tabIndex) {
      case 0:
        return PostRepliesListSliver(postId: postId, maxWidth: maxWidth);
      case 1:
        return PostForwardsListSliver(postId: postId, maxWidth: maxWidth);
      case 2:
        return PostBoostsListSliver(postId: postId, maxWidth: maxWidth);
      case 3:
        return PostReactionsListSliver(postId: postId, maxWidth: maxWidth);
      default:
        return PostRepliesListSliver(postId: postId, maxWidth: maxWidth);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _PostInteractionsSliverGroup(
      tabBar: _buildTabBar(context),
      tabContent: _buildTabContent(context),
    );
  }
}

/// Internal widget to group tabBar and tab content slivers together
class _PostInteractionsSliverGroup extends StatelessWidget {
  final Widget tabBar;
  final Widget tabContent;

  const _PostInteractionsSliverGroup({
    required this.tabBar,
    required this.tabContent,
  });

  @override
  Widget build(BuildContext context) {
    // This widget returns a list of slivers that should be added to the parent scroll view
    // We use a custom sliver grouping approach
    return tabContent;
  }
}

/// Provides the TabBar as a sliver for use in CustomScrollView
class PostInteractionsSliverTabBar extends StatelessWidget {
  final double? maxWidth;
  final TabController tabController;

  const PostInteractionsSliverTabBar({
    super.key,
    this.maxWidth,
    required this.tabController,
  });

  @override
  Widget build(BuildContext context) {
    final isWideMode = maxWidth != null;

    final tabBarWidget = Container(
      margin: isWideMode
          ? const EdgeInsets.symmetric(horizontal: 16, vertical: 8)
          : EdgeInsets.zero,
      decoration: isWideMode
          ? BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(24),
            )
          : null,
      child: TabBar(
        controller: tabController,
        dividerColor: Colors.transparent,
        indicatorSize: TabBarIndicatorSize.tab,
        splashBorderRadius: BorderRadius.circular(20),
        indicator: isWideMode
            ? BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(20),
              )
            : null,
        labelColor: isWideMode ? Colors.white : null,
        unselectedLabelColor: isWideMode
            ? Theme.of(context).colorScheme.onSurfaceVariant
            : null,
        tabs: [
          Tab(text: 'replies'.tr()),
          Tab(text: 'forwards'.tr()),
          Tab(text: 'boosts'.tr()),
          Tab(text: 'reactions'.plural(0)),
        ],
      ),
    );

    if (isWideMode) {
      return Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth!),
          child: tabBarWidget,
        ),
      );
    }

    return tabBarWidget;
  }
}

/// Provides the tab content as a sliver for use in CustomScrollView
class PostInteractionsSliverContent extends HookConsumerWidget {
  final String postId;
  final double? maxWidth;
  final TabController tabController;

  const PostInteractionsSliverContent({
    super.key,
    required this.postId,
    this.maxWidth,
    required this.tabController,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabIndex = tabController.index;

    switch (tabIndex) {
      case 0:
        return PostRepliesListSliver(postId: postId, maxWidth: maxWidth);
      case 1:
        return PostForwardsListSliver(postId: postId, maxWidth: maxWidth);
      case 2:
        return PostBoostsListSliver(postId: postId, maxWidth: maxWidth);
      case 3:
        return PostReactionsListSliver(postId: postId, maxWidth: maxWidth);
      default:
        return PostRepliesListSliver(postId: postId, maxWidth: maxWidth);
    }
  }
}

/// Sliver version of replies list
class PostRepliesListSliver extends HookConsumerWidget {
  final String postId;
  final double? maxWidth;
  const PostRepliesListSliver({super.key, required this.postId, this.maxWidth});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = postRepliesProvider(postId);
    final notifier = ref.read(provider.notifier);

    final skeletonItem = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: PostItemSkeleton(maxWidth: maxWidth ?? double.infinity),
    );

    return PaginationList(
      provider: provider,
      notifier: provider.notifier,
      isRefreshable: false,
      isSliver: true,
      padding: EdgeInsets.zero,
      footerSkeletonChild: maxWidth == null
          ? skeletonItem
          : Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth!),
                child: skeletonItem,
              ),
            ),
      itemBuilder: (context, index, item) {
        final contentWidget = Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: PostActionableItem(
            borderRadius: 8,
            item: item,
            isShowReference: false,
            isEmbedOpenable: true,
            onUpdate: (newPost) {
              notifier.updatePost(newPost);
            },
          ),
        );

        if (maxWidth == null) return contentWidget;

        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth!),
            child: contentWidget,
          ),
        );
      },
    );
  }
}

/// Sliver version of forwards list
class PostForwardsListSliver extends HookConsumerWidget {
  final String postId;
  final double? maxWidth;
  const PostForwardsListSliver({
    super.key,
    required this.postId,
    this.maxWidth,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = postForwardsProvider(postId);

    final skeletonItem = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: PostItemSkeleton(maxWidth: maxWidth ?? double.infinity),
    );

    return PaginationList(
      provider: provider,
      notifier: provider.notifier,
      isRefreshable: false,
      isSliver: true,
      padding: EdgeInsets.zero,
      footerSkeletonChild: maxWidth == null
          ? skeletonItem
          : Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth!),
                child: skeletonItem,
              ),
            ),
      itemBuilder: (context, index, item) {
        final contentWidget = Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: PostActionableItem(
            borderRadius: 8,
            item: item,
            isShowReference: false,
            isEmbedOpenable: true,
            onUpdate: (newPost) {
              // Forward posts are separate posts, not replies
            },
          ),
        );

        if (maxWidth == null) return contentWidget;

        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth!),
            child: contentWidget,
          ),
        );
      },
    );
  }
}

/// Sliver version of boosts list
class PostBoostsListSliver extends HookConsumerWidget {
  final String postId;
  final double? maxWidth;
  const PostBoostsListSliver({super.key, required this.postId, this.maxWidth});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = postBoostsProvider(postId);

    final skeletonItem = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Skeletonizer(
        enabled: true,
        effect: ShimmerEffect(
          baseColor: Theme.of(context).colorScheme.surfaceContainerHigh,
          highlightColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        ),
        containersColor: Theme.of(context).colorScheme.surfaceContainerLow,
        child: const BoostListItemSkeleton(),
      ),
    );

    return PaginationList(
      provider: provider,
      notifier: provider.notifier,
      isRefreshable: false,
      isSliver: true,
      padding: EdgeInsets.zero,
      footerSkeletonChild: maxWidth == null
          ? skeletonItem
          : Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth!),
                child: skeletonItem,
              ),
            ),
      itemBuilder: (context, index, item) {
        final contentWidget = Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: BoostListItem(boost: item),
        );

        if (maxWidth == null) return contentWidget;

        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth!),
            child: contentWidget,
          ),
        );
      },
    );
  }
}

/// Sliver version of reactions list
class PostReactionsListSliver extends HookConsumerWidget {
  final String postId;
  final double? maxWidth;
  const PostReactionsListSliver({
    super.key,
    required this.postId,
    this.maxWidth,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = postReactionsProvider(postId);

    final skeletonItem = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Skeletonizer(
        enabled: true,
        effect: ShimmerEffect(
          baseColor: Theme.of(context).colorScheme.surfaceContainerHigh,
          highlightColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        ),
        containersColor: Theme.of(context).colorScheme.surfaceContainerLow,
        child: const ReactionListItemSkeleton(),
      ),
    );

    return PaginationList(
      provider: provider,
      notifier: provider.notifier,
      isRefreshable: false,
      isSliver: true,
      padding: EdgeInsets.zero,
      footerSkeletonChild: maxWidth == null
          ? skeletonItem
          : Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth!),
                child: skeletonItem,
              ),
            ),
      itemBuilder: (context, index, item) {
        final contentWidget = Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: ReactionListItem(reaction: item),
        );

        if (maxWidth == null) return contentWidget;

        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth!),
            child: contentWidget,
          ),
        );
      },
    );
  }
}
