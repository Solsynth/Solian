import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/pods/paging.dart';
import 'package:island/widgets/extended_refresh_indicator.dart';
import 'package:super_sliver_list/super_sliver_list.dart';

class PaginationList<T> extends HookConsumerWidget {
  final ProviderListenable<AsyncValue<List<T>>> provider;
  final Refreshable<PaginationController<T>> notifier;
  final Widget? Function(BuildContext, int, T) itemBuilder;
  final bool isRefreshable;
  const PaginationList({
    super.key,
    required this.provider,
    required this.notifier,
    required this.itemBuilder,
    this.isRefreshable = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(provider);
    final noti = ref.watch(notifier);
    final listView = SuperListView.builder(
      itemBuilder: (context, idx) {
        final entry = data.valueOrNull?[idx];
        if (entry != null) return itemBuilder(context, idx, entry);
        return null;
      },
    );

    final child = NotificationListener(
      onNotification: (ScrollNotification scrollInfo) {
        if (scrollInfo is ScrollEndNotification &&
            scrollInfo.metrics.axisDirection == AxisDirection.down &&
            scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent) {
          if (!noti.fetchedAll) {
            noti.fetchFurther();
          }
        }
        return true;
      },
      child: listView,
    );

    return isRefreshable
        ? ExtendedRefreshIndicator(onRefresh: noti.refresh, child: child)
        : child;
  }
}

class PaginationWidget<T> extends HookConsumerWidget {
  final ProviderListenable<AsyncValue<List<T>>> provider;
  final Refreshable<PaginationController<T>> notifier;
  final Widget Function(List<T>) contentBuilder;
  final bool isRefreshable;
  const PaginationWidget({
    super.key,
    required this.provider,
    required this.notifier,
    required this.contentBuilder,
    this.isRefreshable = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(provider);
    final noti = ref.watch(notifier);
    final content = NotificationListener(
      onNotification: (ScrollNotification scrollInfo) {
        if (scrollInfo is ScrollEndNotification &&
            scrollInfo.metrics.axisDirection == AxisDirection.down &&
            scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent) {
          if (!noti.fetchedAll) {
            noti.fetchFurther();
          }
        }
        return true;
      },
      child: contentBuilder(data.valueOrNull ?? []),
    );

    return isRefreshable
        ? ExtendedRefreshIndicator(onRefresh: noti.refresh, child: content)
        : content;
  }
}
