import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:island/models/account.dart';
import 'package:island/pods/network.dart';
import 'package:island/pods/config.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:gap/gap.dart';

part 'friends_overview.g.dart';

@riverpod
Future<List<SnFriendOverviewItem>> friendsOverview(Ref ref) async {
  final apiClient = ref.watch(apiClientProvider);
  final resp = await apiClient.get('/pass/friends/overview');
  return (resp.data as List<dynamic>)
      .map((e) => SnFriendOverviewItem.fromJson(e))
      .toList();
}

class FriendsOverviewWidget extends ConsumerWidget {
  const FriendsOverviewWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final friendsOverviewAsync = ref.watch(friendsOverviewProvider);

    return friendsOverviewAsync.when(
      data: (friends) {
        // Filter for online friends
        final onlineFriends =
            friends.where((friend) => friend.status.isOnline).toList();

        if (onlineFriends.isEmpty) {
          return const SizedBox.shrink(); // Hide if no online friends
        }

        return Card(
          margin: EdgeInsets.zero,
          child: Column(
            children: [
              Row(
                spacing: 8,
                children: [const Icon(Symbols.group), Text('Friends Online')],
              ).padding(horizontal: 16).height(48),
              SizedBox(
                height: 80,
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(8, 0, 8, 4),
                  scrollDirection: Axis.horizontal,
                  itemCount: onlineFriends.length,
                  itemBuilder: (context, index) {
                    final friend = onlineFriends[index];
                    return _FriendTile(friend: friend);
                  },
                ),
              ),
            ],
          ),
        );
      },
      loading:
          () => const SizedBox(
            height: 80,
            child: Center(child: CircularProgressIndicator()),
          ),
      error: (error, stack) => const SizedBox.shrink(), // Hide on error
    );
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
                backgroundImage:
                    uri != null ? CachedNetworkImageProvider(uri) : null,
                child:
                    uri == null
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
              // Online indicator
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: theme.colorScheme.surface,
                      width: 2,
                    ),
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
