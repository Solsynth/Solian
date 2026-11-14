import 'dart:async';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:material_ui/material_ui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/theme.dart';
import 'package:island/activity/pulsar_activity.dart';
import 'package:island/accounts/utils/account_status_utils.dart';
import 'package:island/accounts/widgets/account/account_pfc.dart';
import 'package:island/core/network.dart';
import 'package:island/core/services/time.dart';
import 'package:island/core/utils/activity_utils.dart';
import 'package:island/core/websocket.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:island/shared/widgets/extended_refresh_indicator.dart';
import 'package:island/shared/widgets/layouts/sheet_scaffold.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:gap/gap.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

part 'friends_overview.g.dart';

/// Replaces the activities embedded in Stargate's friend overview with the
/// caller's current Pulsar sessions. The friend/status part still comes from
/// Stargate because Pulsar has no social graph; presence itself is read from
/// its canonical owner.
Future<List<SnFriendOverviewItem>> _withPulsarActivities(
  Dio apiClient,
  List<SnFriendOverviewItem> friends,
) async {
  if (friends.isEmpty) return friends;

  final accountIds = <String>{
    for (final friend in friends)
      if (friend.account.id.isNotEmpty) friend.account.id,
  }.toList();
  if (accountIds.isEmpty) return friends;

  try {
    final byAccount = <String, List<SnPresenceActivity>>{};
    for (var start = 0; start < accountIds.length; start += 100) {
      final end = start + 100 > accountIds.length
          ? accountIds.length
          : start + 100;
      final response = await apiClient.get(
        '/pulsar/presence/activities',
        queryParameters: {
          'account_ids': accountIds.sublist(start, end).join(','),
        },
      );
      byAccount.addAll(pulsarActivitiesByAccount(response.data));
    }
    return [
      for (final friend in friends)
        friend.copyWith(activities: byAccount[friend.account.id] ?? const []),
    ];
  } catch (_) {
    // Older deployments have no Pulsar route; keep the Stargate snapshot.
    return friends;
  }
}

@riverpod
Future<List<SnFriendOverviewItem>> friendsOverview(Ref ref) async {
  final client = ref.watch(solarNetworkClientProvider);
  final apiClient = ref.watch(apiClientProvider);
  final websocket = ref.watch(websocketProvider);
  final subscription = websocket.dataStream.listen((packet) {
    if (packet.type == 'account.status.updated' ||
        packet.type == 'account.presence.activities.updated') {
      ref.invalidateSelf();
    }
  });
  ref.onDispose(subscription.cancel);

  final friends = await client.accounts.getFriendsOverview();
  return _withPulsarActivities(apiClient, friends);
}

final friendsOverviewExpandedProvider =
    FutureProvider<List<SnFriendOverviewItem>>((ref) async {
      final apiClient = ref.watch(apiClientProvider);
      final websocket = ref.watch(websocketProvider);
      final subscription = websocket.dataStream.listen((packet) {
        if (packet.type == 'account.status.updated' ||
            packet.type == 'account.presence.activities.updated') {
          ref.invalidateSelf();
        }
      });
      ref.onDispose(subscription.cancel);

      final response = await apiClient.get(
        '/stargate/friends/overview',
        queryParameters: {'includeOffline': true},
      );

      final friends = (response.data as List<dynamic>)
          .map(
            (json) =>
                SnFriendOverviewItem.fromJson(json as Map<String, dynamic>),
          )
          .toList();
      return _withPulsarActivities(apiClient, friends);
    });

class FriendsOverviewWidget extends HookConsumerWidget {
  final bool hideWhenEmpty;
  final EdgeInsetsGeometry? padding;

  const FriendsOverviewWidget({
    super.key,
    this.hideWhenEmpty = false,
    this.padding,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final friendsOverviewAsync = ref.watch(friendsOverviewExpandedProvider);

    return friendsOverviewAsync.when(
      data: (friends) {
        final onlineFriends = friends
            .where((friend) => showsOnlinePresence(friend.status))
            .toList();
        final offlineFriends =
            friends
                .where((friend) => !showsOnlinePresence(friend.status))
                .toList()
              ..sort((a, b) {
                final aLastOnline =
                    a.account.profile.lastSeenAt ?? a.status.updatedAt;
                final bLastOnline =
                    b.account.profile.lastSeenAt ?? b.status.updatedAt;
                return bLastOnline.compareTo(aLastOnline);
              });
        final displayFriends = onlineFriends.isNotEmpty
            ? onlineFriends
            : offlineFriends;

        if (displayFriends.isEmpty && hideWhenEmpty) {
          return const SizedBox.shrink();
        }

        final card = Card(
          margin: EdgeInsets.zero,
          color: Theme.of(context).colorScheme.surfaceContainerLow,
          elevation: 0,
          shadowColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          shape: const RoundedRectangleBorder(borderRadius: SolRadius.cardRadius),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => showFriendsOverviewSheet(context),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      Symbols.group,
                      size: 20,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'friendsOnline'.tr(),
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Text(
                      '${friends.length}',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Symbols.chevron_right,
                      size: 18,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ],
                ).padding(horizontal: 16, vertical: 12),
                if (displayFriends.isEmpty)
                  Container(
                    height: 88,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Center(
                      child: Text(
                        'friendsNoOnline',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ).tr(),
                    ),
                  )
                else
                  SizedBox(
                    height: 88,
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(8, 0, 8, 4),
                      scrollDirection: Axis.horizontal,
                      itemCount: displayFriends.length,
                      itemBuilder: (context, index) {
                        final friend = displayFriends[index];
                        return AccountPfcRegion(
                          uname: friend.account.name,
                          child: _FriendTile(friend: friend),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        );

        Widget result = card;
        if (padding != null) {
          result = Padding(padding: padding!, child: result);
        }
        return result;
      },
      loading: () {
        final card = Card(
          margin: EdgeInsets.zero,
          color: Theme.of(context).colorScheme.surfaceContainerLow,
          elevation: 0,
          shadowColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          shape: const RoundedRectangleBorder(borderRadius: SolRadius.cardRadius),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              Row(
                children: [
                  Icon(
                    Symbols.group,
                    size: 20,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'friendsOnline'.tr(),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ).padding(horizontal: 16, vertical: 12),
              SizedBox(
                height: 88,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(8, 0, 8, 4),
                  scrollDirection: Axis.horizontal,
                  children: List.generate(
                    4,
                    (index) => const SkeletonFriendTile(),
                  ),
                ),
              ),
            ],
          ),
        );

        Widget result = Skeletonizer(child: card);
        if (padding != null) {
          result = Padding(padding: padding!, child: result);
        }
        return result;
      },
      error: (error, stack) => const SizedBox.shrink(), // Hide on error
    );
  }
}

/// Opens the full friends list sheet (online / active / total counts).
void showFriendsOverviewSheet(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useRootNavigator: true,
    builder: (context) => const _FriendsOverviewSheet(),
  );
}

class SkeletonFriendTile extends StatelessWidget {
  const SkeletonFriendTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Avatar with online indicator
          Stack(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: Text(
                  'A',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
              // Online indicator - green dot for skeleton
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Theme.of(context).colorScheme.surface,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const Gap(4),
          // Name placeholder
          Text(
            'Friend',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    ).center();
  }
}

class _FriendsOverviewSheet extends HookConsumerWidget {
  const _FriendsOverviewSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final friendsAsync = ref.watch(friendsOverviewExpandedProvider);

    Future<void> refresh() async {
      ref.invalidate(friendsOverviewExpandedProvider);
      await ref.read(friendsOverviewExpandedProvider.future);
    }

    return SheetScaffold(
      titleText: 'friends'.tr(),
      heightFactor: 0.85,
      child: friendsAsync.when(
        data: (friends) {
          final onlineCount = friends
              .where((friend) => showsOnlinePresence(friend.status))
              .length;
          final activeCount = friends
              .where((friend) => friend.activities.isNotEmpty)
              .length;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Row(
                  children: [
                    Text(
                      'friendsOnlineCount'.tr(args: [onlineCount.toString()]),
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'friendsActiveCount'.tr(args: [activeCount.toString()]),
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'friendsTotalCount'.tr(args: [friends.length.toString()]),
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ExtendedRefreshIndicator(
                  onRefresh: refresh,
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(8, 0, 8, 24),
                    itemCount: friends.length,
                    itemBuilder: (context, index) {
                      final friend = friends[index];
                      return _FriendOverviewListTile(friend: friend);
                    },
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('Error: $error', textAlign: TextAlign.center),
          ),
        ),
      ),
    );
  }
}

class _FriendOverviewListTile extends StatelessWidget {
  final SnFriendOverviewItem friend;

  const _FriendOverviewListTile({required this.friend});

  @override
  Widget build(BuildContext context) {
    final activity = friend.activities.isNotEmpty
        ? friend.activities.first
        : null;
    final activityTitle = activity == null
        ? null
        : getActivityTitle(activity.title, activity.meta) ?? activity.title;
    final activitySubtitle = activity == null
        ? null
        : getActivitySubtitle(activity.meta);
    final statusLabel = getStatusDisplayLabel(context, friend.status);
    final displayName = friend.account.nick.isNotEmpty
        ? friend.account.nick
        : friend.account.name;
    final isOffline = !showsOnlinePresence(friend.status);
    final lastOnlineAt =
        friend.account.profile.lastSeenAt ?? friend.status.updatedAt;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      leading: AccountPfcRegion(
        uname: friend.account.name,
        child: Stack(
          children: [
            ProfilePictureWidget(
              file: friend.account.profile.picture,
              fallbackName: friend.account.nick,
              radius: 24,
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: FriendPresenceBadge(friend: friend, size: 18),
            ),
          ],
        ),
      ),
      title: Text(displayName, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '@${friend.account.name} · $statusLabel',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (activityTitle != null && activityTitle.isNotEmpty)
            Text(
              activitySubtitle?.isNotEmpty == true
                  ? '$activityTitle · $activitySubtitle'
                  : activityTitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          if (isOffline)
            Text(
              'friendsLastOnlineAt'.tr(
                args: [lastOnlineAt.formatRelative(context)],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
    );
  }
}

/// Presence badge overlaid on a friend avatar: blue play arrow while the friend
/// has an activity, otherwise the account status indicator.
class FriendPresenceBadge extends StatelessWidget {
  final SnFriendOverviewItem friend;
  final double size;

  const FriendPresenceBadge({super.key, required this.friend, this.size = 16});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasActivities = friend.activities.isNotEmpty;
    final statusIcon = hasActivities
        ? Symbols.play_arrow
        : getStatusIndicatorIcon(friend.status);
    final statusColor = hasActivities
        ? Colors.blue.withOpacity(0.8)
        : getStatusIndicatorColor(friend.status);
    // Activities get a rounded square; presence is always a dot.
    final squared = hasActivities;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: statusColor,
        shape: squared ? BoxShape.rectangle : BoxShape.circle,
        borderRadius: squared ? BorderRadius.circular(4) : null,
        border: Border.all(color: theme.colorScheme.surface, width: 2),
      ),
      child: Icon(
        statusIcon,
        size: size * 0.625,
        color: hasActivities ? Colors.white : statusColor,
        fill: hasActivities ? 1 : getStatusIndicatorFill(friend.status),
      ),
    );
  }
}

class _FriendTile extends ConsumerWidget {
  final SnFriendOverviewItem friend;

  const _FriendTile({required this.friend});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Container(
      width: 72,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Avatar with online indicator
          Stack(
            children: [
              ProfilePictureWidget(
                file: friend.account.profile.picture,
                fallbackName: friend.account.nick,
                radius: 30,
              ),
              // Play arrow while the friend has an activity, else status dot.
              Positioned(
                bottom: 0,
                right: 0,
                child: FriendPresenceBadge(friend: friend, size: 18),
              ),
            ],
          ),
          const Gap(4),
          // Name (truncated if too long)
          Text(
            friend.account.nick.isNotEmpty
                ? friend.account.nick
                : friend.account.name,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    ).center();
  }
}
