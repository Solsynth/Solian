import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/pods/paging.dart';

import 'package:island/widgets/extended_refresh_indicator.dart';
import 'package:island/widgets/response.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:super_sliver_list/super_sliver_list.dart';
import 'package:visibility_detector/visibility_detector.dart';

class PaginationList<T> extends HookConsumerWidget {
  final ProviderListenable<AsyncValue<List<T>>> provider;
  final Refreshable<PaginationController<T>> notifier;
  final Widget? Function(BuildContext, int, T) itemBuilder;
  final bool isRefreshable;
  final bool isSliver;
  final bool showDefaultWidgets;
  final EdgeInsets? padding;
  const PaginationList({
    super.key,
    required this.provider,
    required this.notifier,
    required this.itemBuilder,
    this.isRefreshable = true,
    this.isSliver = false,
    this.showDefaultWidgets = true,
    this.padding,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(provider);
    final noti = ref.watch(notifier);

    if (data.isLoading && data.valueOrNull?.isEmpty == true) {
      final content = ResponseLoadingWidget();
      return isSliver ? SliverFillRemaining(child: content) : content;
    }

    if (data.hasError) {
      final content = ResponseErrorWidget(
        error: data.error,
        onRetry: noti.refresh,
      );
      return isSliver ? SliverFillRemaining(child: content) : content;
    }

    final listView =
        isSliver
            ? SuperSliverList.builder(
              itemCount: (data.valueOrNull?.length ?? 0) + 1,
              itemBuilder: (context, idx) {
                if (idx == data.valueOrNull?.length) {
                  return PaginationListFooter(noti: noti, data: data);
                }
                final entry = data.valueOrNull?[idx];
                if (entry != null) return itemBuilder(context, idx, entry);
                return null;
              },
            )
            : SuperListView.builder(
              padding: padding,
              itemCount: (data.valueOrNull?.length ?? 0) + 1,
              itemBuilder: (context, idx) {
                if (idx == data.valueOrNull?.length) {
                  return PaginationListFooter(noti: noti, data: data);
                }
                final entry = data.valueOrNull?[idx];
                if (entry != null) return itemBuilder(context, idx, entry);
                return null;
              },
            );

    return isRefreshable
        ? ExtendedRefreshIndicator(onRefresh: noti.refresh, child: listView)
        : listView;
  }
}

class PaginationWidget<T> extends HookConsumerWidget {
  final ProviderListenable<AsyncValue<List<T>>> provider;
  final Refreshable<PaginationController<T>> notifier;
  final Widget Function(List<T>, Widget) contentBuilder;
  final bool isRefreshable;
  final bool isSliver;
  final bool showDefaultWidgets;
  const PaginationWidget({
    super.key,
    required this.provider,
    required this.notifier,
    required this.contentBuilder,
    this.isRefreshable = true,
    this.isSliver = false,
    this.showDefaultWidgets = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(provider);
    final noti = ref.watch(notifier);

    if (data.isLoading && data.valueOrNull?.isEmpty == true) {
      final content = ResponseLoadingWidget();
      return isSliver ? SliverFillRemaining(child: content) : content;
    }

    if (data.hasError) {
      final content = ResponseErrorWidget(
        error: data.error,
        onRetry: noti.refresh,
      );
      return isSliver ? SliverFillRemaining(child: content) : content;
    }

    final footer = PaginationListFooter(noti: noti, data: data);
    final content = contentBuilder(data.valueOrNull ?? [], footer);

    return isRefreshable
        ? ExtendedRefreshIndicator(onRefresh: noti.refresh, child: content)
        : content;
  }
}

class PaginationListFooter<T> extends StatelessWidget {
  final PaginationController<T> noti;
  final AsyncValue<List<T>> data;
  final bool isSliver;

  const PaginationListFooter({
    super.key,
    required this.noti,
    required this.data,
    this.isSliver = false,
  });

  @override
  Widget build(BuildContext context) {
    final child = SizedBox(
      height: 64,
      child: Center(
        child:
            data.isLoading
                ? CircularProgressIndicator()
                : Row(
                  spacing: 8,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Symbols.close, size: 16),
                    Text('noFurtherData').tr().fontSize(13),
                  ],
                ).opacity(0.9),
      ).padding(all: 8),
    );

    return VisibilityDetector(
      key: Key("pagination-list-${noti.hashCode}"),
      onVisibilityChanged: (VisibilityInfo info) {
        if (!noti.fetchedAll && !data.isLoading && !data.hasError) {
          noti.fetchFurther();
        }
      },
      child: isSliver ? SliverToBoxAdapter(child: child) : child,
    );
  }
}
