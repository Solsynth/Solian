import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:island/models/account.dart';
import 'package:island/pods/network.dart';
import 'package:island/pods/config.dart';
import 'package:island/widgets/account/account_pfc.dart';
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
        final onlineFriends =
            friends.where((friend) => friend.status.isOnline).toList();

        if (onlineFriends.isEmpty && hideWhenEmpty) {
          return const SizedBox.shrink();
        }

        final card = Card(
          margin: EdgeInsets.zero,
          child: Column(
            children: [
              Row(
                spacing: 8,
                children: [const Icon(Symbols.group), Text('Friends Online')],
              ).padding(horizontal: 16).height(48),
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
                      return AccountPfcGestureDetector(
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
              // Online indicator - show play arrow if user has activities, otherwise green dot
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color:
                        friend.activities.isNotEmpty
                            ? Colors.blue.withOpacity(0.8)
                            : Colors.green,
                    shape:
                        friend.activities.isNotEmpty
                            ? BoxShape.rectangle
                            : BoxShape.circle,
                    borderRadius:
                        friend.activities.isNotEmpty
                            ? BorderRadius.circular(4)
                            : null,
                    border: Border.all(
                      color: theme.colorScheme.surface,
                      width: 2,
                    ),
                  ),
                  child:
                      friend.activities.isNotEmpty
                          ? Icon(
                            Symbols.play_arrow,
                            size: 10,
                            color: Colors.white,
                          )
                          : null,
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
