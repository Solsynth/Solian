import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:gap/gap.dart';
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
  final Widget? Function(BuildContext, int, T)? seperatorBuilder;
  final double? spacing;
  final bool isRefreshable;
  final bool isSliver;
  final bool showDefaultWidgets;
  final EdgeInsets? padding;
  final Widget? footerSkeletonChild;
  final double? footerSkeletonMaxWidth;
  const PaginationList({
    super.key,
    required this.provider,
    required this.notifier,
    required this.itemBuilder,
    this.seperatorBuilder,
    this.spacing,
    this.isRefreshable = true,
    this.isSliver = false,
    this.showDefaultWidgets = true,
    this.padding,
    this.footerSkeletonChild,
    this.footerSkeletonMaxWidth,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(provider);
    final noti = ref.watch(notifier);

    // For sliver cases, avoid animation to prevent complex sliver issues
    if (isSliver) {
      if ((data.isLoading || noti.isLoading) && data.value?.isEmpty == true) {
        final content = List<Widget>.generate(
          10,
          (_) => Skeletonizer(
            enabled: true,
            effect: ShimmerEffect(
              baseColor: Theme.of(context).colorScheme.surfaceContainerHigh,
              highlightColor: Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest,
            ),
            containersColor: Theme.of(context).colorScheme.surfaceContainerLow,
            child:
                footerSkeletonChild ??
                _DefaultSkeletonChild(maxWidth: footerSkeletonMaxWidth),
          ),
        );
        return SliverList.list(children: content);
      }

      if (data.hasError) {
        final content = ResponseErrorWidget(
          error: data.error,
          onRetry: noti.refresh,
        );
        return SliverFillRemaining(child: content);
      }

      final listView = SuperSliverList.separated(
        itemCount: (data.value?.length ?? 0) + 1,
        itemBuilder: (context, idx) {
          if (idx == data.value?.length) {
            return PaginationListFooter(
              noti: noti,
              data: data,
              skeletonChild: footerSkeletonChild,
              skeletonMaxWidth: footerSkeletonMaxWidth,
            );
          }
          final entry = data.value?[idx];
          if (entry != null) return itemBuilder(context, idx, entry);
          return null;
        },
        separatorBuilder: (context, index) {
          if (seperatorBuilder != null) {
            final entry = data.value?[index];
            if (entry != null) {
              return seperatorBuilder!(context, index, entry) ??
                  const SizedBox();
            }
            return const SizedBox();
          }
          if (spacing != null && spacing! > 0) {
            return Gap(spacing!);
          }
          return const SizedBox();
        },
      );

      return isRefreshable
          ? ExtendedRefreshIndicator(onRefresh: noti.refresh, child: listView)
          : listView;
    }

    // For non-sliver cases, use AnimatedSwitcher for smooth transitions
    Widget buildContent() {
      if ((data.isLoading || noti.isLoading) && data.value?.isEmpty == true) {
        final content = List<Widget>.generate(
          10,
          (_) => Skeletonizer(
            enabled: true,
            effect: ShimmerEffect(
              baseColor: Theme.of(context).colorScheme.surfaceContainerHigh,
              highlightColor: Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest,
            ),
            containersColor: Theme.of(context).colorScheme.surfaceContainerLow,
            child:
                footerSkeletonChild ??
                _DefaultSkeletonChild(maxWidth: footerSkeletonMaxWidth),
          ),
        );
        return SizedBox(
          key: const ValueKey('loading'),
          child: ListView(padding: padding, children: content),
        );
      }

      if (data.hasError) {
        final content = ResponseErrorWidget(
          error: data.error,
          onRetry: noti.refresh,
        );
        return SizedBox(key: const ValueKey('error'), child: content);
      }

      final listView = SuperListView.separated(
        padding: padding,
        itemCount: (data.value?.length ?? 0) + 1,
        itemBuilder: (context, idx) {
          if (idx == data.value?.length) {
            return PaginationListFooter(
              noti: noti,
              data: data,
              skeletonChild: footerSkeletonChild,
              skeletonMaxWidth: footerSkeletonMaxWidth,
            );
          }
          final entry = data.value?[idx];
          if (entry != null) return itemBuilder(context, idx, entry);
          return null;
        },
        separatorBuilder: (context, index) {
          if (seperatorBuilder != null) {
            final entry = data.value?[index];
            if (entry != null) {
              return seperatorBuilder!(context, index, entry) ??
                  const SizedBox();
            }
            return const SizedBox();
          }
          if (spacing != null && spacing! > 0) {
            return Gap(spacing!);
          }
          return const SizedBox();
        },
      );

      return SizedBox(
        key: const ValueKey('data'),
        child: isRefreshable
            ? ExtendedRefreshIndicator(onRefresh: noti.refresh, child: listView)
            : listView,
      );
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: buildContent(),
    );
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
  final double? footerSkeletonMaxWidth;
  const PaginationWidget({
    super.key,
    required this.provider,
    required this.notifier,
    required this.contentBuilder,
    this.isRefreshable = true,
    this.isSliver = false,
    this.showDefaultWidgets = true,
    this.footerSkeletonChild,
    this.footerSkeletonMaxWidth,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(provider);
    final noti = ref.watch(notifier);

    // For sliver cases, avoid animation to prevent complex sliver issues
    if (isSliver) {
      if ((data.isLoading || noti.isLoading) && data.value?.isEmpty == true) {
        final content = List<Widget>.generate(
          10,
          (_) => Skeletonizer(
            enabled: true,
            effect: ShimmerEffect(
              baseColor: Theme.of(context).colorScheme.surfaceContainerHigh,
              highlightColor: Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest,
            ),
            containersColor: Theme.of(context).colorScheme.surfaceContainerLow,
            child:
                footerSkeletonChild ??
                _DefaultSkeletonChild(maxWidth: footerSkeletonMaxWidth),
          ),
        );
        return SliverList.list(children: content);
      }

      if (data.hasError) {
        final content = ResponseErrorWidget(
          error: data.error,
          onRetry: noti.refresh,
        );
        return SliverFillRemaining(child: content);
      }

      final footer = PaginationListFooter(
        noti: noti,
        data: data,
        skeletonChild: footerSkeletonChild,
        skeletonMaxWidth: footerSkeletonMaxWidth,
      );
      final content = contentBuilder(data.value ?? [], footer);

      return isRefreshable
          ? ExtendedRefreshIndicator(onRefresh: noti.refresh, child: content)
          : content;
    }

    // For non-sliver cases, use AnimatedSwitcher for smooth transitions
    Widget buildContent() {
      if ((data.isLoading || noti.isLoading) && data.value?.isEmpty == true) {
        final content = List<Widget>.generate(
          10,
          (_) => Skeletonizer(
            enabled: true,
            effect: ShimmerEffect(
              baseColor: Theme.of(context).colorScheme.surfaceContainerHigh,
              highlightColor: Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest,
            ),
            containersColor: Theme.of(context).colorScheme.surfaceContainerLow,
            child:
                footerSkeletonChild ??
                _DefaultSkeletonChild(maxWidth: footerSkeletonMaxWidth),
          ),
        );
        return SizedBox(
          key: const ValueKey('loading'),
          child: ListView(children: content),
        );
      }

      if (data.hasError) {
        final content = ResponseErrorWidget(
          error: data.error,
          onRetry: noti.refresh,
        );
        return SizedBox(key: const ValueKey('error'), child: content);
      }

      final footer = PaginationListFooter(
        noti: noti,
        data: data,
        skeletonChild: footerSkeletonChild,
        skeletonMaxWidth: footerSkeletonMaxWidth,
      );
      final content = contentBuilder(data.value ?? [], footer);

      return SizedBox(
        key: const ValueKey('data'),
        child: isRefreshable
            ? ExtendedRefreshIndicator(onRefresh: noti.refresh, child: content)
            : content,
      );
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: buildContent(),
    );
  }
}

class PaginationListFooter<T> extends HookConsumerWidget {
  final PaginationController<T> noti;
  final AsyncValue<List<T>> data;
  final Widget? skeletonChild;
  final double? skeletonMaxWidth;
  final bool isSliver;

  const PaginationListFooter({
    super.key,
    required this.noti,
    required this.data,
    this.skeletonChild,
    this.skeletonMaxWidth,
    this.isSliver = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasBeenVisible = useState(false);

    final placeholder = Skeletonizer(
      enabled: true,
      effect: ShimmerEffect(
        baseColor: Theme.of(context).colorScheme.surfaceContainerHigh,
        highlightColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      containersColor: Theme.of(context).colorScheme.surfaceContainerLow,
      child: skeletonChild ?? _DefaultSkeletonChild(maxWidth: skeletonMaxWidth),
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
          if (context.mounted) noti.fetchFurther();
        }
      },
      child: isSliver ? SliverToBoxAdapter(child: child) : child,
    );
  }
}

class _DefaultSkeletonChild extends StatelessWidget {
  final double? maxWidth;
  const _DefaultSkeletonChild({this.maxWidth});

  @override
  Widget build(BuildContext context) {
    final content = ListTile(
      title: Text('Some data'),
      subtitle: const Text('Subtitle here'),
      trailing: const Icon(Icons.ac_unit),
    );
    if (maxWidth != null) {
      return Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth!),
          child: content,
        ),
      );
    }
    return content;
  }
}
