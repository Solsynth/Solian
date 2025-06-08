import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/models/activity.dart';
import 'package:island/pods/userinfo.dart';
import 'package:island/route.gr.dart';
import 'package:island/services/responsive.dart';
import 'package:island/widgets/account/status.dart';
import 'package:island/widgets/app_scaffold.dart';
import 'package:island/models/post.dart';
import 'package:island/widgets/check_in.dart';
import 'package:island/widgets/post/post_item.dart';
import 'package:island/widgets/tour/tour.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:riverpod_paging_utils/riverpod_paging_utils.dart';
import 'package:island/pods/network.dart';
import 'package:styled_widget/styled_widget.dart';

part 'explore.g.dart';

@RoutePage()
class ExploreShellScreen extends ConsumerWidget {
  const ExploreShellScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isWide = isWideScreen(context);

    if (isWide) {
      return AppBackground(
        isRoot: true,
        child: Row(
          children: [
            Flexible(flex: 2, child: ExploreScreen(isAside: true)),
            VerticalDivider(width: 1),
            Flexible(flex: 3, child: AutoRouter()),
          ],
        ),
      );
    }

    return AppBackground(isRoot: true, child: AutoRouter());
  }
}

@RoutePage()
class ExploreScreen extends ConsumerWidget {
  final bool isAside;
  const ExploreScreen({super.key, this.isAside = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isWide = isWideScreen(context);
    if (isWide && !isAside) {
      return const EmptyPageHolder();
    }

    final activitiesNotifier = ref.watch(activityListNotifierProvider.notifier);

    return TourTriggerWidget(
      child: AppScaffold(
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
                (data, widgetCount, endItemView) => Center(
                  child: _ActivityListView(
                    data: data,
                    widgetCount: widgetCount,
                    endItemView: endItemView,
                    activitiesNotifier: activitiesNotifier,
                  ),
                ),
          ),
        ),
      ),
    );
  }
}

class _ActivityListView extends HookConsumerWidget {
  final CursorPagingData<SnActivity> data;
  final int widgetCount;
  final Widget endItemView;
  final ActivityListNotifier activitiesNotifier;

  const _ActivityListView({
    required this.data,
    required this.widgetCount,
    required this.endItemView,
    required this.activitiesNotifier,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userInfoProvider);

    return CustomScrollView(
      slivers: [
        if (user.hasValue) SliverToBoxAdapter(child: CheckInWidget()),
        SliverList.builder(
          itemCount: widgetCount,
          itemBuilder: (context, index) {
            if (index == widgetCount - 1) {
              return endItemView;
            }

            final item = data.items[index];
            if (item.data == null) {
              return const SizedBox.shrink();
            }
            Widget itemWidget;

            switch (item.type) {
              case 'posts.new':
              case 'posts.new.replies':
                final isReply = item.type == 'posts.new.replies';
                itemWidget = PostItem(
                  backgroundColor:
                      isWideScreen(context) ? Colors.transparent : null,
                  item: SnPost.fromJson(item.data),
                  padding:
                      isReply
                          ? EdgeInsets.only(left: 16, right: 16, bottom: 16)
                          : null,
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
                if (isReply) {
                  itemWidget = Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          const Icon(Symbols.reply),
                          const Gap(8),
                          Text('Replying your post'),
                        ],
                      ).padding(horizontal: 20, vertical: 8),
                      itemWidget,
                    ],
                  );
                }
                break;
              default:
                itemWidget = const Placeholder();
            }

            return Column(children: [itemWidget, const Divider(height: 1)]);
          },
        ),
        SliverGap(MediaQuery.of(context).padding.bottom + 16),
      ],
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
    final take = 20;

    final response = await client.get(
      '/activities',
      queryParameters: {
        if (cursor != null) 'reading_cursor': cursor,
        'take': take,
      },
    );

    final List<SnActivity> items =
        (response.data as List)
            .map((e) => SnActivity.fromJson(e as Map<String, dynamic>))
            .toList();

    final hasMore = (items.firstOrNull?.type ?? 'empty') != 'empty';
    final nextCursor =
        items.map((x) => x.createdAt).lastOrNull?.toIso8601String().toString();

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
