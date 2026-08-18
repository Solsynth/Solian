import 'dart:math' as math;
import 'dart:ui' show PointerDeviceKind;

import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/config.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:island/posts/widgets/compose/filters/post_subscription_filter.dart';
import 'package:island/route.gr.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

/// Horizontal strip of subscribed publishers with new-content / live indicators.
///
/// Visual language mirrors the chat list pinned rooms strip: avatar + label,
/// optional selection ring, and a compact status badge.
///
/// Data comes from `GET /sphere/publishers/subscriptions?order=latest_posted_at`
/// and read markers are updated via the subscription read-status APIs.
class SubscribedPublishersStrip extends HookConsumerWidget {
  final List<String> selectedPublisherNames;
  final ValueChanged<List<String>> onSelectedPublishersChanged;
  final VoidCallback? onSelectionChanged;

  const SubscribedPublishersStrip({
    super.key,
    required this.selectedPublisherNames,
    required this.onSelectedPublishersChanged,
    this.onSelectionChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscriptionsAsync = ref.watch(publishersSubscriptionsLiveProvider);
    final isMarkingAll = useState(false);

    return subscriptionsAsync.when(
      data: (items) {
        if (items.isEmpty) return const SizedBox.shrink();

        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;
        final unreadCount = items.where((i) => i.hasNewContent).length;

        return Material(
          color: colorScheme.surfaceContainerLow.withOpacity(0.65),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Height: 8 top + 48 avatar + 4 gap + ~14 label + 6 bottom
              SizedBox(
                height: 80,
                child: _HoverHorizontalScrollList(
                  padding: const EdgeInsets.fromLTRB(6, 8, 6, 6),
                  itemCount: items.length + (unreadCount > 0 ? 1 : 0),
                  separatorWidth: 2,
                  itemBuilder: (context, index) {
                    // Leading "mark all read" action when any publisher is unread.
                    if (unreadCount > 0 && index == 0) {
                      return Align(
                        alignment: Alignment.topCenter,
                        child: _MarkAllReadTile(
                          unreadCount: unreadCount,
                          isLoading: isMarkingAll.value,
                          onTap: isMarkingAll.value
                              ? null
                              : () async {
                                  isMarkingAll.value = true;
                                  try {
                                    await ref
                                        .read(
                                          publishersSubscriptionsLiveProvider
                                              .notifier,
                                        )
                                        .markAllAsRead();
                                  } catch (_) {
                                    // Best-effort; list reloads on failure.
                                  } finally {
                                    isMarkingAll.value = false;
                                  }
                                },
                        ),
                      );
                    }

                    final item = items[unreadCount > 0 ? index - 1 : index];
                    final publisher = item.subscription.publisher;
                    final isSelected =
                        selectedPublisherNames.length == 1 &&
                        selectedPublisherNames.first == publisher.name;

                    return Align(
                      alignment: Alignment.topCenter,
                      child: _SubscribedPublisherTile(
                        publisher: publisher,
                        isSelected: isSelected,
                        hasNewContent: item.hasNewContent,
                        isLive: item.isLive,
                        onTap: () => _handleTap(
                          ref: ref,
                          item: item,
                          isSelected: isSelected,
                        ),
                        onLongPress: () {
                          context.router.push(
                            PublisherProfileRoute(name: publisher.name),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
              Divider(
                height: 1,
                thickness: 1,
                color: colorScheme.outlineVariant.withOpacity(0.45),
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
    );
  }

  Future<void> _handleTap({
    required WidgetRef ref,
    required PublisherSubscriptionLiveItem item,
    required bool isSelected,
  }) async {
    final publisher = item.subscription.publisher;

    if (isSelected) {
      onSelectedPublishersChanged(const []);
      onSelectionChanged?.call();
      return;
    }

    onSelectedPublishersChanged([publisher.name]);
    onSelectionChanged?.call();

    // Advance last_read_at to the known latest content timestamp so the
    // indicator clears precisely for the content the user is opening.
    try {
      await ref
          .read(publishersSubscriptionsLiveProvider.notifier)
          .markAsRead(publisher.name, lastReadAt: item.latestContentAt);
    } catch (_) {
      // Read-status is best-effort; selection still applies.
    }
  }
}

class _MarkAllReadTile extends StatelessWidget {
  final int unreadCount;
  final bool isLoading;
  final VoidCallback? onTap;

  const _MarkAllReadTile({
    required this.unreadCount,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(
          width: 64,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 48,
                height: 48,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: colorScheme.primaryContainer.withOpacity(0.7),
                      ),
                      child: isLoading
                          ? Padding(
                              padding: const EdgeInsets.all(12),
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: colorScheme.onPrimaryContainer,
                              ),
                            )
                          : Icon(
                              Symbols.done_all,
                              size: 22,
                              color: colorScheme.onPrimaryContainer,
                            ),
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: colorScheme.surface,
                            width: 1.5,
                          ),
                        ),
                        child: Text(
                          unreadCount > 99 ? '99+' : '$unreadCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            height: 1,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Gap(4),
              Text(
                'markAllRead'.tr(),
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.primary,
                  height: 1.1,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SubscribedPublisherTile extends StatelessWidget {
  final SnPublisher publisher;
  final bool isSelected;
  final bool hasNewContent;
  final bool isLive;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _SubscribedPublisherTile({
    required this.publisher,
    required this.isSelected,
    required this.hasNewContent,
    required this.isLive,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final emphasize = hasNewContent || isSelected || isLive;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(
          width: 64,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 48,
                height: 48,
                child: Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    if (isSelected)
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: colorScheme.primary,
                            width: 2,
                          ),
                        ),
                      ),
                    ProfilePictureWidget(
                      file: publisher.picture,
                      fallbackName: publisher.nick,
                      radius: isSelected ? 20 : 22,
                    ),
                    if (hasNewContent)
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          width: 11,
                          height: 11,
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: colorScheme.surface,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                    if (isLive)
                      Positioned(
                        bottom: -2,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.redAccent,
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: colorScheme.surface,
                              width: 1.5,
                            ),
                          ),
                          child: const Text(
                            'LIVE',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 8,
                              height: 1.1,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const Gap(4),
              Text(
                publisher.nick.isNotEmpty ? publisher.nick : publisher.name,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: emphasize ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected
                      ? colorScheme.primary
                      : colorScheme.onSurface.withOpacity(
                          hasNewContent ? 0.95 : 0.78,
                        ),
                  height: 1.1,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Horizontal list with desktop hover chevrons (same idea as chat pinned strip).
class _HoverHorizontalScrollList extends HookWidget {
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final EdgeInsetsGeometry padding;
  final double separatorWidth;

  const _HoverHorizontalScrollList({
    required this.itemCount,
    required this.itemBuilder,
    this.padding = EdgeInsets.zero,
    this.separatorWidth = 2,
  });

  @override
  Widget build(BuildContext context) {
    final controller = useScrollController();
    final isHovered = useState(false);
    final canScrollLeft = useState(false);
    final canScrollRight = useState(false);

    void updateScrollState() {
      if (!controller.hasClients) {
        canScrollLeft.value = false;
        canScrollRight.value = false;
        return;
      }
      final position = controller.position;
      canScrollLeft.value = position.pixels > 0.5;
      canScrollRight.value = position.pixels < position.maxScrollExtent - 0.5;
    }

    useEffect(() {
      void listener() => updateScrollState();
      controller.addListener(listener);
      WidgetsBinding.instance.addPostFrameCallback((_) => updateScrollState());
      return () => controller.removeListener(listener);
    }, [controller, itemCount, padding, separatorWidth]);

    Future<void> scrollBy(double direction) async {
      if (!controller.hasClients) return;
      final position = controller.position;
      final delta = math.max(position.viewportDimension * 0.75, 180.0);
      final target = (position.pixels + delta * direction).clamp(
        0.0,
        position.maxScrollExtent,
      );
      await controller.animateTo(
        target,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
      );
    }

    final scrollBehavior = ScrollConfiguration.of(context).copyWith(
      dragDevices: {PointerDeviceKind.touch, PointerDeviceKind.trackpad},
    );

    return MouseRegion(
      onEnter: (_) => isHovered.value = true,
      onExit: (_) => isHovered.value = false,
      child: Stack(
        children: [
          Positioned.fill(
            child: ScrollConfiguration(
              behavior: scrollBehavior,
              child: ListView.separated(
                controller: controller,
                scrollDirection: Axis.horizontal,
                padding: padding,
                itemCount: itemCount,
                separatorBuilder: (_, _) => SizedBox(width: separatorWidth),
                itemBuilder: itemBuilder,
              ),
            ),
          ),
          Positioned(
            left: 6,
            top: 0,
            bottom: 0,
            child: Center(
              child: _ScrollArrowButton(
                icon: Symbols.chevron_left,
                isVisible: isHovered.value && canScrollLeft.value,
                hiddenOffset: const Offset(-0.4, 0),
                onTap: () => scrollBy(-1),
              ),
            ),
          ),
          Positioned(
            right: 6,
            top: 0,
            bottom: 0,
            child: Center(
              child: _ScrollArrowButton(
                icon: Symbols.chevron_right,
                isVisible: isHovered.value && canScrollRight.value,
                hiddenOffset: const Offset(0.4, 0),
                onTap: () => scrollBy(1),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScrollArrowButton extends StatelessWidget {
  final IconData icon;
  final bool isVisible;
  final Offset hiddenOffset;
  final VoidCallback onTap;

  const _ScrollArrowButton({
    required this.icon,
    required this.isVisible,
    required this.hiddenOffset,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return IgnorePointer(
      ignoring: !isVisible,
      child: AnimatedSlide(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        offset: isVisible ? Offset.zero : hiddenOffset,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          opacity: isVisible ? 1 : 0,
          child: Material(
            color: colorScheme.surface.withOpacity(0.92),
            elevation: 2,
            shadowColor: Colors.black26,
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onTap,
              customBorder: const CircleBorder(),
              child: SizedBox(
                width: 32,
                height: 32,
                child: Icon(icon, size: 20, color: colorScheme.onSurface),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Sliver wrapper for [SubscribedPublishersStrip], placed above the post feed.
class SliverSubscribedPublishersStrip extends HookConsumerWidget {
  final List<String> selectedPublisherNames;
  final ValueChanged<List<String>> onSelectedPublishersChanged;
  final VoidCallback? onSelectionChanged;

  const SliverSubscribedPublishersStrip({
    super.key,
    required this.selectedPublisherNames,
    required this.onSelectedPublishersChanged,
    this.onSelectionChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SliverToBoxAdapter(
      child: SubscribedPublishersStrip(
        selectedPublisherNames: selectedPublisherNames,
        onSelectedPublishersChanged: onSelectedPublishersChanged,
        onSelectionChanged: onSelectionChanged,
      ),
    );
  }
}

/// Helper to persist publisher selection into explore settings and clear
/// category/tag filters (matches subscription filter sheet behavior).
void applyPublisherStripSelection({
  required List<String> names,
  required ValueNotifier<List<String>> selectedPublishers,
  required ValueNotifier<List<String>> selectedCategories,
  required ValueNotifier<List<String>> selectedTags,
  required ExploreSettings exploreSettings,
  required AppSettingsNotifier appSettingsNotifier,
}) {
  selectedPublishers.value = names;
  if (names.isNotEmpty) {
    selectedCategories.value = [];
    selectedTags.value = [];
  }
  appSettingsNotifier.setExploreSettings(
    exploreSettings.copyWith(
      selectedPublisherNames: names,
      selectedCategoryIds: names.isNotEmpty
          ? const <String>[]
          : exploreSettings.selectedCategoryIds,
      selectedTagIds: names.isNotEmpty
          ? const <String>[]
          : exploreSettings.selectedTagIds,
    ),
  );
}
