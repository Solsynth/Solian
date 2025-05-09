import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:island/models/activity.dart';
import 'package:island/pods/userinfo.dart';
import 'package:island/route.gr.dart';
import 'package:island/widgets/app_scaffold.dart';
import 'package:island/models/post.dart';
import 'package:island/widgets/check_in.dart';
import 'package:island/widgets/post/post_item.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:very_good_infinite_list/very_good_infinite_list.dart';
import 'package:dio/dio.dart';
import 'package:island/pods/network.dart';

@RoutePage()
class ExploreScreen extends ConsumerWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userInfoProvider);
    final posts = ref.watch(activityListProvider);
    final postsNotifier = ref.watch(activityListProvider.notifier);

    return AppScaffold(
      appBar: AppBar(title: const Text('Explore')),
      floatingActionButton: FloatingActionButton(
        heroTag: Key("explore-page-fab"),
        onPressed: () {
          context.router.push(PostComposeRoute()).then((value) {
            if (value != null) {
              ref.invalidate(activityListProvider);
            }
          });
        },
        child: const Icon(Symbols.edit),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: RefreshIndicator(
        onRefresh: () => postsNotifier.refresh(),
        child: CustomScrollView(
          slivers: [
            if (user.hasValue) SliverToBoxAdapter(child: CheckInWidget()),
            SliverInfiniteList(
              itemCount: posts.length,
              isLoading: postsNotifier.isLoading,
              hasReachedMax: postsNotifier.hasReachedMax,
              onFetchData: postsNotifier.fetchMore,
              itemBuilder: (context, index) {
                final item = posts[index];
                switch (item.type) {
                  case 'posts.new':
                    return PostItem(
                      item: SnPost.fromJson(item.data),
                      onRefresh: (_) {
                        ref.invalidate(activityListProvider);
                      },
                      onUpdate: (post) {
                        postsNotifier.updateOne(
                          index,
                          item.copyWith(data: post.toJson()),
                        );
                      },
                    );
                  case 'accounts.check-in':
                    return CheckInActivityWidget(item: item);
                  default:
                    return Placeholder();
                }
              },
              separatorBuilder: (_, __) => const Divider(height: 1),
            ),
            SliverGap(MediaQuery.of(context).padding.bottom + 16),
          ],
        ),
      ),
    );
  }
}

final activityListProvider =
    StateNotifierProvider<_ActivityListController, List<SnActivity>>((ref) {
      final client = ref.watch(apiClientProvider);
      return _ActivityListController(client);
    });

class _ActivityListController extends StateNotifier<List<SnActivity>> {
  _ActivityListController(this._dio) : super([]);

  final Dio _dio;
  bool isLoading = false;
  bool hasReachedMax = false;
  int offset = 0;
  final int take = 20;
  int total = 0;

  Future<void> fetchMore() async {
    if (isLoading || hasReachedMax) return;
    isLoading = true;

    try {
      final response = await _dio.get(
        '/activities',
        queryParameters: {'offset': offset, 'take': take},
      );

      final List<SnActivity> fetched =
          (response.data as List)
              .map((e) => SnActivity.fromJson(e as Map<String, dynamic>))
              .toList();

      final headerTotal = int.tryParse(
        response.headers['x-total']?.first ?? '',
      );
      if (headerTotal != null) total = headerTotal;

      if (!mounted) return; // Check if the notifier is still mounted

      state = [...state, ...fetched];
      offset += fetched.length;
      if (state.length >= total) hasReachedMax = true;
    } finally {
      if (mounted) {
        isLoading = false;
      }
    }
  }

  Future<void> refresh() async {
    offset = 0;
    state = [];
    hasReachedMax = false;
    await fetchMore();
  }

  void updateOne(int index, SnActivity post) {
    if (!mounted) return; // Check if the notifier is still mounted
    final updatedPosts = [...state];
    updatedPosts[index] = post;
    state = updatedPosts;
  }
}
