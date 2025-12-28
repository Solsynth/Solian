import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/models/activitypub.dart';
import 'package:island/services/activitypub_service.dart';
import 'package:island/widgets/activitypub/user_list_item.dart';
import 'package:island/widgets/alert.dart';
import 'package:island/widgets/app_scaffold.dart';
import 'package:island/widgets/extended_refresh_indicator.dart';
import 'package:material_symbols_icons/symbols.dart';

enum ActivityPubListType { following, followers }

class ApListScreen extends HookConsumerWidget {
  final ActivityPubListType type;

  const ApListScreen({super.key, required this.type});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final users = useState<List<SnActivityPubUser>>([]);
    final isLoading = useState(true);
    final followingUris = useState<Set<String>>({});
    final isLoadingAction = useState<String?>(null);

    Future<void> loadUsers() async {
      isLoading.value = true;
      try {
        final service = ref.read(activityPubServiceProvider);
        final result = type == ActivityPubListType.following
            ? await service.getFollowing()
            : await service.getFollowers();
        users.value = result;
        followingUris.value = result.map((user) => user.actorUri).toSet();
      } catch (err) {
        showErrorAlert(err);
      } finally {
        isLoading.value = false;
      }
    }

    Future<void> handleFollow(SnActivityPubUser user) async {
      isLoadingAction.value = user.actorUri;
      try {
        final service = ref.read(activityPubServiceProvider);
        await service.followRemoteUser(user.actorUri);
        followingUris.value = {...followingUris.value, user.actorUri};
        showSnackBar('followedUser'.tr(args: ['@${user.username}']));
      } catch (err) {
        showErrorAlert(err);
      } finally {
        isLoadingAction.value = null;
      }
    }

    Future<void> handleUnfollow(SnActivityPubUser user) async {
      isLoadingAction.value = user.actorUri;
      try {
        final service = ref.read(activityPubServiceProvider);
        await service.unfollowRemoteUser(user.actorUri);
        followingUris.value = followingUris.value
            .where((uri) => uri != user.actorUri)
            .toSet();
        if (type == ActivityPubListType.following) {
          users.value = users.value
              .where((u) => u.actorUri != user.actorUri)
              .toList();
        }
        showSnackBar('unfollowedUser'.tr(args: ['@${user.username}']));
      } catch (err) {
        showErrorAlert(err);
      } finally {
        isLoadingAction.value = null;
      }
    }

    final title = type == ActivityPubListType.following
        ? 'following'.tr()
        : 'followers'.tr();

    return AppScaffold(
      appBar: AppBar(
        title: Text(title),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: loadUsers,
            tooltip: 'refresh'.tr(),
          ),
        ],
      ),
      body: isLoading.value
          ? const Center(child: CircularProgressIndicator())
          : users.value.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Symbols.group,
                    size: 64,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    type == ActivityPubListType.following
                        ? 'followingEmpty'.tr()
                        : 'followersEmpty'.tr(),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'followingEmptyHint'.tr(),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            )
          : ExtendedRefreshIndicator(
              onRefresh: loadUsers,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: users.value.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final user = users.value[index];
                  final isFollowing = followingUris.value.contains(
                    user.actorUri,
                  );
                  final isLoadingUser = isLoadingAction.value == user.actorUri;
                  return ActivityPubUserListItem(
                    user: user,
                    isFollowing: isFollowing,
                    isLoading: isLoadingUser,
                    onFollow: type == ActivityPubListType.followers
                        ? () => handleFollow(user)
                        : null,
                    onUnfollow: type == ActivityPubListType.following
                        ? () => handleUnfollow(user)
                        : null,
                  );
                },
              ),
            ),
    );
  }
}
