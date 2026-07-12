import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:island_ui_foundation/src/foundation.dart';
import 'package:island_ui_foundation/src/responsive.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:styled_widget/styled_widget.dart';

const double kFloatingSnackBarWidth = 400.0;
const int kSnackBarVisibleLimit = 3;
const Duration _kSnackBarDuration = Duration(milliseconds: 1500);
const Duration _kSnackBarAnimationDuration = Duration(milliseconds: 220);
const double _kMobileBottomNavClearance = 72.0;

typedef SnackBarEntryKey = String;

OverlayEntry? _snackBarOverlay;
final ValueNotifier<List<_OverlaySnackBarItem>> _snackBarItems = ValueNotifier(
  const [],
);

typedef SnackBarOverlayBuilder =
    Widget Function(BuildContext context, VoidCallback dismiss);

SnackBarEntryKey showSnackBar(
  String message, {
  SnackBarEntryKey? entryKey,
  SnackBarAction? action,
  Duration? duration = _kSnackBarDuration,
  bool noVibrate = false,
}) {
  return showStyledSnackBar(
    message: message,
    entryKey: entryKey,
    action: action,
    duration: duration,
    noVibrate: noVibrate,
  );
}

SnackBarEntryKey showStyledSnackBar({
  required String message,
  SnackBarEntryKey? entryKey,
  String? title,
  IconData? icon,
  Color? accentColor,
  Color? containerColor,
  EdgeInsetsGeometry? padding,
  SnackBarAction? action,
  Duration? duration = _kSnackBarDuration,
  bool noVibrate = false,
}) {
  _ensureSnackBarOverlay();
  return _upsertSnackBar(
    noVibrate: noVibrate,
    item: _OverlaySnackBarItem(
      id: entryKey ?? 'snackbar_${DateTime.now().microsecondsSinceEpoch}',
      contentBuilder: (context, dismiss) => _DefaultSnackBarContent(
        message: message,
        title: title,
        icon: icon,
        accentColor: accentColor,
      ),
      containerColor: containerColor,
      padding: padding,
      action: action,
      duration: duration,
    ),
  );
}

SnackBarEntryKey showCustomSnackBar({
  required SnackBarOverlayBuilder builder,
  SnackBarEntryKey? entryKey,
  Color? containerColor,
  EdgeInsetsGeometry? padding,
  bool enableStackScale = true,
  SnackBarAction? action,
  Duration? duration = _kSnackBarDuration,
  bool noVibrate = false,
}) {
  _ensureSnackBarOverlay();
  return _upsertSnackBar(
    noVibrate: noVibrate,
    item: _OverlaySnackBarItem(
      id: entryKey ?? 'snackbar_${DateTime.now().microsecondsSinceEpoch}',
      contentBuilder: builder,
      containerColor: containerColor,
      padding: padding,
      enableStackScale: enableStackScale,
      action: action,
      duration: duration,
    ),
  );
}

SnackBarEntryKey updateCustomSnackBar({
  required SnackBarEntryKey entryKey,
  required SnackBarOverlayBuilder builder,
  Color? containerColor,
  EdgeInsetsGeometry? padding,
  bool enableStackScale = true,
  SnackBarAction? action,
  Duration? duration,
  bool preserveDuration = true,
  bool noVibrate = true,
}) {
  _ensureSnackBarOverlay();
  final existingItems = _snackBarItems.value;
  final existingIndex = existingItems.indexWhere((item) => item.id == entryKey);
  final existing = existingIndex >= 0 ? existingItems[existingIndex] : null;
  return _upsertSnackBar(
    noVibrate: noVibrate,
    item: _OverlaySnackBarItem(
      id: entryKey,
      contentBuilder: builder,
      containerColor: containerColor,
      padding: padding,
      enableStackScale: enableStackScale,
      action: action,
      duration: preserveDuration ? (duration ?? existing?.duration) : duration,
    ),
  );
}

void dismissSnackBar(SnackBarEntryKey entryKey) {
  _dismissSnackBar(entryKey);
}

SnackBarEntryKey _upsertSnackBar({
  required _OverlaySnackBarItem item,
  required bool noVibrate,
}) {
  final items = List<_OverlaySnackBarItem>.from(_snackBarItems.value);
  final index = items.indexWhere((existing) => existing.id == item.id);
  final isNew = index < 0;
  if (isNew) {
    items.add(item);
  } else {
    items[index] = item;
  }
  _snackBarItems.value = items;
  if (isNew) {
    _maybeVibrateOnShow(noVibrate: noVibrate);
  }
  return item.id;
}

void _maybeVibrateOnShow({required bool noVibrate}) {
  if (noVibrate) return;
  if (!IslandUIFoundation.hapticEnabled) return;
  HapticFeedback.lightImpact();
}

void _ensureSnackBarOverlay() {
  // Drop stale entries after Overlay rebuild/hot restart so we re-insert.
  if (_snackBarOverlay != null && !_snackBarOverlay!.mounted) {
    _snackBarOverlay = null;
  }
  if (_snackBarOverlay != null) return;

  final overlayKey = IslandUIFoundation.overlayKey;
  if (overlayKey == null) return;

  final overlayState = overlayKey.currentState;
  if (overlayState == null) return;

  _snackBarOverlay = OverlayEntry(
    builder: (context) => ValueListenableBuilder<List<_OverlaySnackBarItem>>(
      valueListenable: _snackBarItems,
      builder: (context, items, child) {
        if (items.isEmpty) {
          return const SizedBox.shrink();
        }
        // Overlay theater acts like a Stack; host uses Positioned.
        return _SnackBarOverlayHost(items: items);
      },
    ),
  );
  overlayState.insert(_snackBarOverlay!);
}

void _dismissSnackBar(String id) {
  final items = _snackBarItems.value;
  final index = items.indexWhere((item) => item.id == id);
  if (index < 0) return;

  final updated = List<_OverlaySnackBarItem>.from(items);
  final item = updated[index];
  if (item.dismissed) return;
  updated[index] = item.copyWith(dismissed: true);
  _snackBarItems.value = updated;
}

void _removeSnackBar(String id) {
  final updated = _snackBarItems.value.where((item) => item.id != id).toList();
  _snackBarItems.value = updated;
  if (updated.isNotEmpty) return;

  final entry = _snackBarOverlay;
  _snackBarOverlay = null;
  if (entry == null) return;
  if (entry.mounted) {
    entry.remove();
  }
}

class _OverlaySnackBarItem {
  const _OverlaySnackBarItem({
    required this.id,
    required this.contentBuilder,
    this.containerColor,
    this.padding,
    this.enableStackScale = true,
    required this.action,
    required this.duration,
    this.dismissed = false,
  });

  final String id;
  final SnackBarOverlayBuilder contentBuilder;
  final Color? containerColor;
  final EdgeInsetsGeometry? padding;
  final bool enableStackScale;
  final SnackBarAction? action;
  final Duration? duration;
  final bool dismissed;

  _OverlaySnackBarItem copyWith({
    String? id,
    SnackBarOverlayBuilder? contentBuilder,
    Color? containerColor,
    EdgeInsetsGeometry? padding,
    bool? enableStackScale,
    SnackBarAction? action,
    Duration? duration,
    bool? dismissed,
  }) {
    return _OverlaySnackBarItem(
      id: id ?? this.id,
      contentBuilder: contentBuilder ?? this.contentBuilder,
      containerColor: containerColor ?? this.containerColor,
      padding: padding ?? this.padding,
      enableStackScale: enableStackScale ?? this.enableStackScale,
      action: action ?? this.action,
      duration: duration ?? this.duration,
      dismissed: dismissed ?? this.dismissed,
    );
  }
}

class _SnackBarOverlayHost extends StatefulWidget {
  const _SnackBarOverlayHost({required this.items});

  final List<_OverlaySnackBarItem> items;

  @override
  State<_SnackBarOverlayHost> createState() => _SnackBarOverlayHostState();
}

class _SnackBarOverlayHostState extends State<_SnackBarOverlayHost> {
  bool _isPaused = false;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final wideScreen = screenWidth > kWideScreenWidth;
    final horizontalPadding = wideScreen ? 16.0 : 12.0;
    final bottomInset = mediaQuery.viewInsets.bottom;
    final safeBottom = mediaQuery.viewPadding.bottom;
    final bottomOffset =
        bottomInset +
        (wideScreen
            ? safeBottom + 16
            : (bottomInset > 0
                  ? safeBottom + 16
                  : safeBottom + _kMobileBottomNavClearance));
    final overlap = wideScreen ? 20.0 : 18.0;

    // Wrap Positioned in an expanding Stack so this host is safe as an
    // OverlayEntry root (theater) *or* under a non-Stack parent.
    if (wideScreen) {
      final visibleItems = widget.items.reversed
          .take(kSnackBarVisibleLimit)
          .toList()
          .reversed
          .toList();
      final heldCount = widget.items.length - visibleItems.length;
      final calculatedHeight = overlap * (visibleItems.length - 1) + 88.0;

      return Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            left: 0,
            right: 0,
            bottom: bottomOffset,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: MouseRegion(
                opaque: false,
                hitTestBehavior: HitTestBehavior.deferToChild,
                onEnter: (_) => setState(() => _isPaused = true),
                onExit: (_) => setState(() => _isPaused = false),
                child: SizedBox(
                  width: kFloatingSnackBarWidth,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Material(
                      color: Colors.transparent,
                      child: SizedBox(
                        height: calculatedHeight + (heldCount > 0 ? 28 : 0),
                        child: Stack(
                          alignment: Alignment.bottomCenter,
                          clipBehavior: Clip.none,
                          children: [
                            ...visibleItems.asMap().entries.map((entry) {
                              final index = entry.key;
                              final item = entry.value;
                              return AnimatedPositioned(
                                key: ValueKey(item.id),
                                duration: _kSnackBarAnimationDuration,
                                curve: Curves.easeOutCubic,
                                left: 0,
                                right: 0,
                                bottom: index * overlap,
                                child: _AnimatedSnackBarItem(
                                  item: item,
                                  stackIndex: index,
                                  showStackSeparation:
                                      index < visibleItems.length - 1,
                                  pauseAutoDismiss: _isPaused,
                                ),
                              );
                            }),
                            Positioned(
                              bottom: 0,
                              child: _AnimatedHeldSnackBarBadge(
                                count: heldCount,
                                onTap: _dismissAllSnackBars,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }

    final visibleItems = widget.items.reversed
        .take(kSnackBarVisibleLimit)
        .toList()
        .reversed
        .toList();
    final heldCount = widget.items.length - visibleItems.length;
    final calculatedHeight = overlap * (visibleItems.length - 1) + 88.0;

    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned(
          left: 0,
          right: 0,
          bottom: bottomOffset,
          child: MouseRegion(
            opaque: false,
            hitTestBehavior: HitTestBehavior.deferToChild,
            onEnter: (_) => setState(() => _isPaused = true),
            onExit: (_) => setState(() => _isPaused = false),
            child: Material(
              color: Colors.transparent,
              child: SizedBox(
                height: calculatedHeight + (heldCount > 0 ? 28 : 0),
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  clipBehavior: Clip.none,
                  children: [
                    ...visibleItems.asMap().entries.map((entry) {
                      final index = entry.key;
                      final item = entry.value;
                      return AnimatedPositioned(
                        key: ValueKey(item.id),
                        duration: _kSnackBarAnimationDuration,
                        curve: Curves.easeOutCubic,
                        left: horizontalPadding,
                        right: horizontalPadding,
                        bottom: index * overlap,
                        child: _AnimatedSnackBarItem(
                          item: item,
                          stackIndex: index,
                          showStackSeparation: index < visibleItems.length - 1,
                          pauseAutoDismiss: _isPaused,
                        ),
                      );
                    }),
                    Positioned(
                      bottom: 0,
                      child: _AnimatedHeldSnackBarBadge(
                        count: heldCount,
                        onTap: _dismissAllSnackBars,
                      ),
                    ),
                  ],
                ),
              ),
            ).alignment(Alignment.bottomCenter),
          ),
        ),
      ],
    );
  }

  void _dismissAllSnackBars() {
    _snackBarItems.value = widget.items
        .map((item) => item.copyWith(dismissed: true))
        .toList();
  }
}

class _AnimatedHeldSnackBarBadge extends StatelessWidget {
  const _AnimatedHeldSnackBarBadge({required this.count, required this.onTap});

  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 240),
      reverseDuration: const Duration(milliseconds: 180),
      switchInCurve: Curves.easeOutBack,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.88, end: 1).animate(animation),
            child: child,
          ),
        );
      },
      child: count > 0
          ? _HeldSnackBarBadge(key: ValueKey(count), count: count, onTap: onTap)
          : const SizedBox.shrink(key: ValueKey('empty-held-badge')),
    );
  }
}

class _AnimatedSnackBarItem extends StatefulWidget {
  const _AnimatedSnackBarItem({
    required this.item,
    this.stackIndex = 0,
    this.showStackSeparation = false,
    this.pauseAutoDismiss = false,
  });

  final _OverlaySnackBarItem item;
  final int stackIndex;
  final bool showStackSeparation;
  final bool pauseAutoDismiss;

  @override
  State<_AnimatedSnackBarItem> createState() => _AnimatedSnackBarItemState();
}

class _AnimatedSnackBarItemState extends State<_AnimatedSnackBarItem>
    with TickerProviderStateMixin {
  late final AnimationController _animationController;
  AnimationController? _dismissController;
  late final CurvedAnimation _curvedAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      reverseDuration: const Duration(milliseconds: 250),
    )..forward();
    _curvedAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );
    _configureDismissController();
  }

  @override
  void didUpdateWidget(covariant _AnimatedSnackBarItem oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.item.duration != widget.item.duration) {
      _configureDismissController();
    }

    if (oldWidget.pauseAutoDismiss != widget.pauseAutoDismiss &&
        !widget.item.dismissed) {
      if (widget.pauseAutoDismiss) {
        _dismissController?.stop(canceled: false);
      } else if (_dismissController?.status != AnimationStatus.completed) {
        _dismissController?.forward();
      }
    }

    if (!oldWidget.item.dismissed && widget.item.dismissed) {
      _reverseAndRemove();
    }
  }

  void _handleProgressStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed && !widget.item.dismissed) {
      _dismissSnackBar(widget.item.id);
    }
  }

  void _configureDismissController() {
    _dismissController
      ?..removeStatusListener(_handleProgressStatus)
      ..dispose();
    final duration = widget.item.duration;
    if (duration == null) {
      _dismissController = null;
      return;
    }
    _dismissController = AnimationController(vsync: this, duration: duration)
      ..addStatusListener(_handleProgressStatus);
    if (!widget.pauseAutoDismiss && !widget.item.dismissed) {
      _dismissController?.forward();
    }
  }

  Future<void> _reverseAndRemove() async {
    await _animationController.reverse();
    _removeSnackBar(widget.item.id);
  }

  @override
  void dispose() {
    _dismissController?.removeStatusListener(_handleProgressStatus);
    _dismissController?.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final slideTween = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    );
    final stackedScale = widget.item.enableStackScale
        ? (0.94 + widget.stackIndex * 0.03).clamp(0.94, 1.0)
        : 1.0;

    return SlideTransition(
      position: slideTween.animate(_curvedAnimation),
      child: FadeTransition(
        opacity: _curvedAnimation,
        child: Transform.scale(
          scale: stackedScale,
          alignment: Alignment.bottomCenter,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              if (widget.showStackSeparation)
                Positioned(
                  top: 10,
                  left: 10,
                  right: 10,
                  height: 16,
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black87,
                            blurRadius: 14,
                            offset: const Offset(0, -6),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              _FloatingSnackBarCard(
                item: widget.item,
                onDismiss: () => _dismissSnackBar(widget.item.id),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FloatingSnackBarCard extends StatelessWidget {
  const _FloatingSnackBarCard({required this.item, required this.onDismiss});

  final _OverlaySnackBarItem item;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final action = item.action;
    final containerColor =
        item.containerColor ??
        Color.alphaBlend(
          colorScheme.surfaceTint.withValues(alpha: 0.06),
          colorScheme.surfaceContainerHigh,
        );

    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if ((details.primaryVelocity ?? 0) > 100) {
          onDismiss();
        }
      },
      onVerticalDragEnd: (details) {
        if ((details.primaryVelocity ?? 0) > 100) {
          onDismiss();
        }
      },
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: containerColor,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black54,
              blurRadius: 14,
              offset: const Offset(0, 7),
            ),
            BoxShadow(
              color: colorScheme.surfaceTint.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding:
              item.padding ??
              const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: item.contentBuilder(context, onDismiss)),
              if (action != null) ...[
                const Gap(14),
                TextButton(
                  onPressed: () {
                    action.onPressed();
                    onDismiss();
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: colorScheme.primary,
                    textStyle: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    minimumSize: Size.zero,
                  ),
                  child: Text(action.label),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _DefaultSnackBarContent extends StatelessWidget {
  const _DefaultSnackBarContent({
    required this.message,
    this.title,
    this.icon,
    this.accentColor,
  });

  final String message;
  final String? title;
  final IconData? icon;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final resolvedAccent = accentColor ?? colorScheme.primary;
    final hasIcon = icon != null;
    final hasTitle = title != null && title!.trim().isNotEmpty;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hasIcon)
          DecoratedBox(
            decoration: BoxDecoration(
              color: resolvedAccent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon ?? Symbols.info_rounded,
              size: 18,
              color: resolvedAccent,
            ).padding(all: 8),
          ).padding(right: 12),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (hasTitle)
                Text(
                  title!,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.1,
                  ),
                ),
              if (hasTitle) const Gap(4),
              Text(
                message,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.25,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HeldSnackBarBadge extends StatelessWidget {
  const _HeldSnackBarBadge({super.key, required this.count, this.onTap});

  final int count;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.secondaryContainer,
      elevation: 2,
      shadowColor: theme.colorScheme.shadow.withOpacity(0.12),
      surfaceTintColor: theme.colorScheme.surfaceTint,
      shape: StadiumBorder(
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withOpacity(0.35),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        customBorder: const StadiumBorder(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          child: Text(
            '+$count',
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.onSecondaryContainer,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
