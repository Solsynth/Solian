import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/pods/paging.dart';
import 'package:island/widgets/extended_refresh_indicator.dart';
import 'package:island/widgets/response.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:skeletonizer/skeletonizer.dart';
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
  final Widget? footerSkeletonChild;
  const PaginationList({
    super.key,
    required this.provider,
    required this.notifier,
    required this.itemBuilder,
    this.isRefreshable = true,
    this.isSliver = false,
    this.showDefaultWidgets = true,
    this.padding,
    this.footerSkeletonChild,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(provider);
    final noti = ref.watch(notifier);

    if ((data.isLoading || noti.isLoading) && data.value?.isEmpty == true) {
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

    final listView = isSliver
        ? SuperSliverList.builder(
            itemCount: (data.value?.length ?? 0) + 1,
            itemBuilder: (context, idx) {
              if (idx == data.value?.length) {
                return PaginationListFooter(
                  noti: noti,
                  data: data,
                  skeletonChild: footerSkeletonChild,
                );
              }
              final entry = data.value?[idx];
              if (entry != null) return itemBuilder(context, idx, entry);
              return null;
            },
          )
        : SuperListView.builder(
            padding: padding,
            itemCount: (data.value?.length ?? 0) + 1,
            itemBuilder: (context, idx) {
              if (idx == data.value?.length) {
                return PaginationListFooter(
                  noti: noti,
                  data: data,
                  skeletonChild: footerSkeletonChild,
                );
              }
              final entry = data.value?[idx];
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
  final Widget? footerSkeletonChild;
  const PaginationWidget({
    super.key,
    required this.provider,
    required this.notifier,
    required this.contentBuilder,
    this.isRefreshable = true,
    this.isSliver = false,
    this.showDefaultWidgets = true,
    this.footerSkeletonChild,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(provider);
    final noti = ref.watch(notifier);

    if ((data.isLoading || noti.isLoading) && data.value?.isEmpty == true) {
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

    final footer = PaginationListFooter(
      noti: noti,
      data: data,
      skeletonChild: footerSkeletonChild,
    );
    final content = contentBuilder(data.value ?? [], footer);

    return isRefreshable
        ? ExtendedRefreshIndicator(onRefresh: noti.refresh, child: content)
        : content;
  }
}

class PaginationListFooter<T> extends HookConsumerWidget {
  final PaginationController<T> noti;
  final AsyncValue<List<T>> data;
  final Widget? skeletonChild;
  final bool isSliver;

  const PaginationListFooter({
    super.key,
    required this.noti,
    required this.data,
    this.skeletonChild,
    this.isSliver = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasBeenVisible = useState(false);

    final placeholder = Skeletonizer(
      enabled: true,
      child:
          skeletonChild ??
          ListTile(
            title: Text('Some data'),
            subtitle: const Text('Subtitle here'),
            trailing: const Icon(Icons.ac_unit),
          ),
    );
    final child = hasBeenVisible.value
        ? data.isLoading
              ? placeholder
              : Row(
                  spacing: 8,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Symbols.close, size: 16),
                    Text('noFurtherData').tr().fontSize(13),
                  ],
                ).opacity(0.9).height(64).center()
        : placeholder;

    return VisibilityDetector(
      key: Key("pagination-list-${noti.hashCode}"),
      onVisibilityChanged: (VisibilityInfo info) {
        hasBeenVisible.value = true;
        if (!noti.fetchedAll && !data.isLoading && !data.hasError) {
          noti.fetchFurther();
        }
      },
      child: isSliver ? SliverToBoxAdapter(child: child) : child,
    );
  }
}
