import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:island/accounts/utils/account_status_utils.dart';
import 'package:island/accounts/widgets/account/account_pfc.dart';
import 'package:island/core/network.dart';
import 'package:island/core/config.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:gap/gap.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

part 'friends_overview.g.dart';

@riverpod
Future<List<SnFriendOverviewItem>> friendsOverview(Ref ref) async {
  final apiClient = ref.watch(apiClientProvider);
  final resp = await apiClient.get('/passport/friends/overview');
  return (resp.data as List<dynamic>)
      .map((e) => SnFriendOverviewItem.fromJson(e))
      .toList();
}

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
    // Set up periodic refresh every minute
    useEffect(() {
      final timer = Timer.periodic(const Duration(minutes: 1), (_) {
        ref.invalidate(friendsOverviewProvider);
      });

      return () => timer.cancel(); // Cleanup when widget is disposed
    }, const []);

    final friendsOverviewAsync = ref.watch(friendsOverviewProvider);

    return friendsOverviewAsync.when(
      data: (friends) {
        // Filter for online friends
        final onlineFriends = friends
            .where((friend) => showsOnlinePresence(friend.status))
            .toList();

        if (onlineFriends.isEmpty && hideWhenEmpty) {
          return const SizedBox.shrink();
        }

        final card = Card(
          margin: EdgeInsets.zero,
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
              if (onlineFriends.isEmpty)
                Container(
                  height: 80,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: const Center(
                    child: Text(
                      'No friends online',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ),
                )
              else
                SizedBox(
                  height: 80,
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(8, 0, 8, 4),
                    scrollDirection: Axis.horizontal,
                    itemCount: onlineFriends.length,
                    itemBuilder: (context, index) {
                      final friend = onlineFriends[index];
                      return AccountPfcRegion(
                        uname: friend.account.name,
                        child: _FriendTile(friend: friend),
                      );
                    },
                  ),
                ),
            ],
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
                height: 80,
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

class SkeletonFriendTile extends StatelessWidget {
  const SkeletonFriendTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Avatar with online indicator
          Stack(
            children: [
              CircleAvatar(
                radius: 24,
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
                  width: 16,
                  height: 16,
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

class _FriendTile extends ConsumerWidget {
  final SnFriendOverviewItem friend;

  const _FriendTile({required this.friend});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final serverUrl = ref.watch(serverUrlProvider);

    String? uri;
    if (friend.account.profile.picture != null) {
      uri = '$serverUrl/drive/files/${friend.account.profile.picture!.id}';
    }

    return Container(
      width: 60,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Avatar with online indicator
          Stack(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundImage: uri != null
                    ? CachedNetworkImageProvider(uri)
                    : null,
                child: uri == null
                    ? Text(
                        friend.account.nick.isNotEmpty
                            ? friend.account.nick[0].toUpperCase()
                            : friend.account.name[0].toUpperCase(),
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onPrimary,
                        ),
                      )
                    : null,
              ),
              // Online indicator - show play arrow if user has activities, otherwise green dot
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: friend.activities.isNotEmpty
                        ? Colors.blue.withOpacity(0.8)
                        : getStatusIndicatorColor(friend.status),
                    shape: friend.activities.isNotEmpty
                        ? BoxShape.rectangle
                        : getStatusIndicatorIcon(friend.status) ==
                              Symbols.circle
                        ? BoxShape.circle
                        : BoxShape.rectangle,
                    borderRadius: friend.activities.isNotEmpty
                        ? BorderRadius.circular(4)
                        : getStatusIndicatorIcon(friend.status) ==
                              Symbols.circle
                        ? null
                        : BorderRadius.circular(4),
                    border: Border.all(
                      color: theme.colorScheme.surface,
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    friend.activities.isNotEmpty
                        ? Symbols.play_arrow
                        : getStatusIndicatorIcon(friend.status),
                    size: 10,
                    color: Colors.white,
                    fill: friend.activities.isNotEmpty
                        ? 1
                        : getStatusIndicatorFill(friend.status),
                  ),
                ),
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
