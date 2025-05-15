import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:island/models/activity.dart';
import 'package:island/pods/userinfo.dart';
import 'package:island/route.gr.dart';
import 'package:island/widgets/account/status.dart';
import 'package:island/widgets/app_scaffold.dart';
import 'package:island/models/post.dart';
import 'package:island/widgets/check_in.dart';
import 'package:island/widgets/post/post_item.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:riverpod_paging_utils/riverpod_paging_utils.dart';
import 'package:island/pods/network.dart';

part 'explore.g.dart';

@RoutePage()
class ExploreScreen extends ConsumerWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userInfoProvider);
    final activitiesNotifier = ref.watch(activityListNotifierProvider.notifier);

    return AppScaffold(
      appBar: AppBar(title: const Text('explore').tr()),
      floatingActionButton: FloatingActionButton(
        heroTag: Key("explore-page-fab"),
        onPressed: () {
          context.router.push(PostComposeRoute()).then((value) {
            if (value != null) {
              activitiesNotifier.forceRefresh();
            }
          });
        },
        child: const Icon(Symbols.edit),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: RefreshIndicator(
        onRefresh: () => Future.sync(activitiesNotifier.forceRefresh),
        child: PagingHelperView(
          provider: activityListNotifierProvider,
          futureRefreshable: activityListNotifierProvider.future,
          notifierRefreshable: activityListNotifierProvider.notifier,
          contentBuilder:
              (data, widgetCount, endItemView) => CustomScrollView(
                slivers: [
                  if (user.hasValue) SliverToBoxAdapter(child: CheckInWidget()),
                  SliverList.builder(
                    itemCount: widgetCount,
                    itemBuilder: (context, index) {
                      if (index == widgetCount - 1) {
                        return endItemView;
                      }

                      final item = data.items[index];
                      Widget itemWidget;

                      switch (item.type) {
                        case 'posts.new':
                          itemWidget = PostItem(
                            item: SnPost.fromJson(item.data),
                            onRefresh: (_) {
                              activitiesNotifier.forceRefresh();
                            },
                            onUpdate: (post) {
                              activitiesNotifier.updateOne(
                                index,
                                item.copyWith(data: post.toJson()),
                              );
                            },
                          );
                          break;
                        case 'accounts.check-in':
                          itemWidget = CheckInActivityWidget(item: item);
                          break;
                        case 'accounts.status':
                          itemWidget = StatusActivityWidget(item: item);
                          break;
                        default:
                          itemWidget = const Placeholder();
                      }

                      return Column(
                        children: [itemWidget, const Divider(height: 1)],
                      );
                    },
                  ),
                  SliverGap(MediaQuery.of(context).padding.bottom + 16),
                ],
              ),
        ),
      ),
    );
  }
}

@riverpod
class ActivityListNotifier extends _$ActivityListNotifier
    with CursorPagingNotifierMixin<SnActivity> {
  @override
  Future<CursorPagingData<SnActivity>> build() => fetch(cursor: null);

  @override
  Future<CursorPagingData<SnActivity>> fetch({required String? cursor}) async {
    final client = ref.read(apiClientProvider);
    final offset = cursor == null ? 0 : int.parse(cursor);
    final take = 20;

    final response = await client.get(
      '/activities',
      queryParameters: {'offset': offset, 'take': take},
    );

    final List<SnActivity> items =
        (response.data as List)
            .map((e) => SnActivity.fromJson(e as Map<String, dynamic>))
            .toList();

    final total = int.tryParse(response.headers['x-total']?.first ?? '') ?? 0;
    final hasMore = offset + items.length < total;
    final nextCursor = hasMore ? (offset + items.length).toString() : null;

    return CursorPagingData(
      items: items,
      hasMore: hasMore,
      nextCursor: nextCursor,
    );
  }

  void updateOne(int index, SnActivity activity) {
    final currentState = state.valueOrNull;
    if (currentState == null) return;

    final updatedItems = [...currentState.items];
    updatedItems[index] = activity;

    state = AsyncData(
      CursorPagingData(
        items: updatedItems,
        hasMore: currentState.hasMore,
        nextCursor: currentState.nextCursor,
      ),
    );
  }
}
