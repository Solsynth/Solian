import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/models/activitypub.dart';
import 'package:island/services/activitypub_service.dart';
import 'package:island/widgets/activitypub/actor_list_item.dart';
import 'package:island/widgets/alert.dart';
import 'package:island/widgets/app_scaffold.dart';
import 'package:island/widgets/extended_refresh_indicator.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:styled_widget/styled_widget.dart';

class ApSearchScreen extends HookConsumerWidget {
  const ApSearchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchController = useTextEditingController();
    final debounce = useMemoized(() => const Duration(milliseconds: 500));
    final debounceTimer = useRef<Timer?>(null);
    final searchResults = useState<List<SnActivityPubActor>>([]);
    final isSearching = useState(false);
    final followingUris = useState<Set<String>>({});

    useEffect(() {
      return () {
        searchController.dispose();
        debounceTimer.value?.cancel();
      };
    }, []);

    Future<void> performSearch(String query) async {
      if (query.trim().isEmpty) {
        searchResults.value = [];
        return;
      }

      isSearching.value = true;
      try {
        final service = ref.read(activityPubServiceProvider);
        final results = await service.searchUsers(query);
        searchResults.value = results;
      } catch (err) {
        showErrorAlert(err);
      } finally {
        isSearching.value = false;
      }
    }

    void onSearchChanged(String query) {
      if (debounceTimer.value?.isActive ?? false) {
        debounceTimer.value!.cancel();
      }
      debounceTimer.value = Timer(debounce, () {
        performSearch(query);
      });
    }

    Future<void> handleFollow(SnActivityPubActor actor) async {
      try {
        followingUris.value = {...followingUris.value, actor.id};
        final service = ref.read(activityPubServiceProvider);
        await service.followRemoteUser(actor.uri);
        showSnackBar(
          'followedUser'.tr(
            args: [
              '@${actor.username?.isNotEmpty ?? false ? actor.username : actor.displayName}',
            ],
          ),
        );
      } catch (err) {
        showErrorAlert(err);
        followingUris.value = followingUris.value
            .where((uri) => uri != actor.id)
            .toSet();
      }
    }

    Future<void> handleUnfollow(SnActivityPubActor actor) async {
      try {
        followingUris.value = followingUris.value
            .where((uri) => uri != actor.uri)
            .toSet();
        final service = ref.read(activityPubServiceProvider);
        await service.unfollowRemoteUser(actor.uri);
        showSnackBar(
          'unfollowedUser'.tr(
            args: [
              '@${actor.username?.isNotEmpty ?? false ? actor.username : actor.displayName}',
            ],
          ),
        );
      } catch (err) {
        showErrorAlert(err);
        followingUris.value = {...followingUris.value, actor.id};
      }
    }

    return AppScaffold(
      isNoBackground: false,
      appBar: AppBar(title: Text('searchFediverse'.tr()), elevation: 0),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: SearchBar(
              controller: searchController,
              hintText: 'searchFediverseHint'.tr(
                args: ['@username@instance.com'],
              ),
              leading: const Icon(Symbols.search).padding(horizontal: 24),
              onChanged: onSearchChanged,
              onSubmitted: (value) {
                onSearchChanged(value);
                performSearch(value);
              },
            ),
          ),
          Expanded(
            child: isSearching.value
                ? const Center(child: CircularProgressIndicator())
                : searchResults.value.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Symbols.search,
                          size: 64,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: 16),
                        if (searchController.text.isEmpty)
                          Text(
                            'searchFediverseEmpty'.tr(),
                            style: Theme.of(context).textTheme.titleMedium,
                          )
                        else
                          Text(
                            'searchFediverseNoResults'.tr(),
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                      ],
                    ),
                  )
                : ExtendedRefreshIndicator(
                    onRefresh: () => performSearch(searchController.text),
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: searchResults.value.length,
                      separatorBuilder: (context, index) =>
                          const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final actor = searchResults.value[index];
                        final isFollowing = followingUris.value.contains(
                          actor.id,
                        );
                        return Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 560),
                            child: ApActorListItem(
                              actor: actor,
                              isFollowing: isFollowing,
                              isLoading: false,
                              onFollow: () => handleFollow(actor),
                              onUnfollow: () => handleUnfollow(actor),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
