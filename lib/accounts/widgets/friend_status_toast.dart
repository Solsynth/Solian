import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/services/responsive.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

enum FriendStatusChangeType {
  online,
  offline,
  busy,
  doNotDisturb,
  activityStarted,
  activityEnded,
}

const int kFriendStatusVisibleLimit = 5;

class FriendStatusChangeEvent {
  final SnAccount account;
  final SnAccountStatus? status;
  final List<SnPresenceActivity> activities;
  final FriendStatusChangeType changeType;

  const FriendStatusChangeEvent({
    required this.account,
    this.status,
    this.activities = const [],
    required this.changeType,
  });
}

class FriendStatusToast extends HookConsumerWidget {
  final FriendStatusChangeEvent event;
  final VoidCallback? onDismiss;
  final Duration autoDismissDuration;
  final bool embedded;
  final bool showCloseButton;
  final bool showProgress;

  const FriendStatusToast({
    super.key,
    required this.event,
    this.onDismiss,
    this.autoDismissDuration = const Duration(seconds: 5),
    this.embedded = false,
    this.showCloseButton = true,
    this.showProgress = true,
  });

  String _getStatusCaption() {
    return switch (event.changeType) {
      FriendStatusChangeType.online => 'friendStatusCameOnline'.tr(),
      FriendStatusChangeType.offline => 'friendStatusWentOffline'.tr(),
      FriendStatusChangeType.busy => 'friendStatusIsNowBusy'.tr(),
      FriendStatusChangeType.doNotDisturb =>
        'friendStatusEnabledDoNotDisturb'.tr(),
      FriendStatusChangeType.activityStarted =>
        'friendStatusStartedActivity'.tr(),
      FriendStatusChangeType.activityEnded =>
        'friendStatusStoppedActivity'.tr(),
    };
  }

  IconData _getStatusIcon() {
    if (event.changeType == FriendStatusChangeType.activityStarted &&
        event.activities.isNotEmpty) {
      final activity = event.activities.first;
      return switch (activity.type) {
        1 => Symbols.sports_esports,
        2 => Symbols.music_note,
        3 => Symbols.fitness_center,
        _ => Symbols.play_arrow,
      };
    }

    return switch (event.changeType) {
      FriendStatusChangeType.online => Symbols.circle,
      FriendStatusChangeType.offline => Symbols.circle,
      FriendStatusChangeType.busy => Symbols.circle,
      FriendStatusChangeType.doNotDisturb => Symbols.do_not_disturb_on,
      FriendStatusChangeType.activityStarted => Symbols.play_arrow,
      FriendStatusChangeType.activityEnded => Symbols.stop_circle,
    };
  }

  Color _getStatusColor(ThemeData theme) {
    if (event.changeType == FriendStatusChangeType.activityStarted) {
      return theme.colorScheme.primary;
    }

    return switch (event.changeType) {
      FriendStatusChangeType.online => Colors.green,
      FriendStatusChangeType.offline => Colors.grey,
      FriendStatusChangeType.busy => Colors.orange,
      FriendStatusChangeType.doNotDisturb => Colors.deepOrange,
      FriendStatusChangeType.activityStarted => theme.colorScheme.primary,
      FriendStatusChangeType.activityEnded => Colors.grey,
    };
  }

  Color _getStatusContainerColor(ThemeData theme) {
    return Color.alphaBlend(
      _getStatusColor(theme).withOpacity(0.14),
      theme.colorScheme.surfaceContainerHigh,
    );
  }

  String _getHeadline() {
    return event.account.nick.isNotEmpty
        ? event.account.nick
        : event.account.name;
  }

  String _getEyebrow() {
    return switch (event.changeType) {
      FriendStatusChangeType.online => 'friendStatusEyebrowOnline'.tr(),
      FriendStatusChangeType.offline => 'friendStatusEyebrowOffline'.tr(),
      FriendStatusChangeType.busy => 'friendStatusEyebrowStatusUpdate'.tr(),
      FriendStatusChangeType.doNotDisturb =>
        'friendStatusEyebrowStatusUpdate'.tr(),
      FriendStatusChangeType.activityStarted =>
        'friendStatusEyebrowActivityStarted'.tr(),
      FriendStatusChangeType.activityEnded =>
        'friendStatusEyebrowActivityEnded'.tr(),
    };
  }

  String? _getSupportingText() {
    if (event.changeType == FriendStatusChangeType.activityStarted &&
        event.activities.isNotEmpty) {
      final activity = event.activities.first;
      if (activity.subtitle?.isNotEmpty == true &&
          activity.subtitle != activity.title) {
        return activity.subtitle;
      }
      return null;
    }

    final statusLabel = event.status?.label;
    if (statusLabel?.isNotEmpty == true) {
      return statusLabel;
    }

    return null;
  }

  bool get _isActivityToast =>
      event.changeType == FriendStatusChangeType.activityStarted &&
      event.activities.isNotEmpty;

  String _getPrimaryMessage() {
    if (_isActivityToast) {
      final activity = event.activities.first;
      if (activity.title?.isNotEmpty == true) {
        return 'friendStatusStartedSpecificActivity'.tr(
          args: [activity.title!],
        );
      }
      if (activity.subtitle?.isNotEmpty == true) {
        return 'friendStatusStartedSpecificActivity'.tr(
          args: [activity.subtitle!],
        );
      }
    }

    return _getStatusCaption();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final statusColor = _getStatusColor(theme);
    final statusContainerColor = _getStatusContainerColor(theme);
    final supportingText = _getSupportingText();
    final isActivityToast = _isActivityToast;
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
      side: BorderSide(
        color: theme.colorScheme.outlineVariant.withOpacity(0.5),
      ),
    );

    final content = ConstrainedBox(
      constraints: embedded
          ? const BoxConstraints(
              minWidth: double.infinity,
              maxWidth: double.infinity,
            )
          : BoxConstraints(
              maxWidth: isActivityToast ? 280 : 360,
              minWidth: isActivityToast ? 220 : 280,
            ),
      child: InkWell(
        onTap: onDismiss,
        customBorder: shape,
        child: Stack(
          children: [
            if (showProgress)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: TweenAnimationBuilder<double>(
                  duration: autoDismissDuration,
                  curve: Curves.linear,
                  tween: Tween(begin: 1, end: 0),
                  builder: (context, value, child) {
                    return Align(
                      alignment: Alignment.centerLeft,
                      child: FractionallySizedBox(
                        widthFactor: value,
                        child: child,
                      ),
                    );
                  },
                  child: Container(
                    height: 3,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [statusColor, statusColor.withOpacity(0.5)],
                      ),
                    ),
                  ),
                ),
              ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                isActivityToast ? 12 : 16,
                isActivityToast ? 12 : 16,
                12,
                isActivityToast ? 12 : 16,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              statusContainerColor,
                              theme.colorScheme.surfaceContainerHighest,
                            ],
                          ),
                        ),
                        child: ProfilePictureWidget(
                          file: event.account.profile.picture,
                          radius: isActivityToast ? 17 : 22,
                        ),
                      ),
                      Positioned(
                        right: -3,
                        bottom: -3,
                        child: Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            color: statusColor,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: theme.colorScheme.surfaceContainerHigh,
                              width: 2.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: statusColor.withOpacity(0.35),
                                blurRadius: 12,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: Icon(
                            _getStatusIcon(),
                            size: 12,
                            color: theme.colorScheme.onPrimary,
                            fill:
                                event.changeType ==
                                    FriendStatusChangeType.online
                                ? 1
                                : 0,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Gap(isActivityToast ? 10 : 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (!isActivityToast) ...[
                                    Text(
                                      _getEyebrow(),
                                      style: theme.textTheme.labelMedium
                                          ?.copyWith(
                                            color: statusColor,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 0.2,
                                          ),
                                    ),
                                    const Gap(2),
                                  ],
                                  Text(
                                    _getHeadline(),
                                    style:
                                        (isActivityToast
                                                ? theme.textTheme.titleSmall
                                                : theme.textTheme.titleMedium)
                                            ?.copyWith(
                                              fontWeight: FontWeight.w700,
                                              color:
                                                  theme.colorScheme.onSurface,
                                            ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            if (showCloseButton)
                              IconButton(
                                onPressed: onDismiss,
                                visualDensity: VisualDensity.compact,
                                style: IconButton.styleFrom(
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  minimumSize: Size(
                                    isActivityToast ? 24 : 32,
                                    isActivityToast ? 24 : 32,
                                  ),
                                  foregroundColor:
                                      theme.colorScheme.onSurfaceVariant,
                                ),
                                icon: const Icon(
                                  Symbols.close_rounded,
                                  size: 18,
                                ),
                              ),
                          ],
                        ),
                        Gap(isActivityToast ? 2 : 8),
                        Text(
                          _getPrimaryMessage(),
                          style:
                              (isActivityToast
                                      ? theme.textTheme.labelLarge
                                      : theme.textTheme.bodyMedium)
                                  ?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                    fontWeight: FontWeight.w600,
                                  ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (supportingText != null) ...[
                          Gap(isActivityToast ? 2 : 8),
                          if (isActivityToast)
                            Text(
                              supportingText,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            )
                          else
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: statusContainerColor,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                supportingText,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                  height: 1.35,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                        ],
                        if (!embedded && !isActivityToast) ...[
                          const Gap(10),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: statusContainerColor,
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: statusColor,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const Gap(6),
                                    Text(
                                      'friendStatusLiveUpdate'.tr(),
                                      style: theme.textTheme.labelMedium
                                          ?.copyWith(
                                            color: statusColor,
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              const Gap(10),
                              Expanded(
                                child: Text(
                                  'friendStatusTapAnywhereToDismiss'.tr(),
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    if (embedded) {
      return content;
    }

    return Material(
      color: theme.colorScheme.surfaceContainerHigh,
      elevation: 3,
      shadowColor: theme.colorScheme.shadow.withOpacity(0.18),
      surfaceTintColor: theme.colorScheme.surfaceTint,
      shape: shape,
      clipBehavior: Clip.antiAlias,
      child: content,
    );
  }
}

class FriendStatusToastData {
  final String id;
  final FriendStatusChangeEvent event;
  final DateTime createdAt;
  final bool isExiting;
  final Duration duration;

  const FriendStatusToastData({
    required this.id,
    required this.event,
    required this.createdAt,
    this.isExiting = false,
    this.duration = const Duration(seconds: 5),
  });

  FriendStatusToastData copyWith({
    String? id,
    FriendStatusChangeEvent? event,
    DateTime? createdAt,
    bool? isExiting,
    Duration? duration,
  }) {
    return FriendStatusToastData(
      id: id ?? this.id,
      event: event ?? this.event,
      createdAt: createdAt ?? this.createdAt,
      isExiting: isExiting ?? this.isExiting,
      duration: duration ?? this.duration,
    );
  }
}

class _FriendStatusToastState {
  final List<FriendStatusToastData> toasts;

  const _FriendStatusToastState({this.toasts = const []});

  _FriendStatusToastState copyWith({List<FriendStatusToastData>? toasts}) {
    return _FriendStatusToastState(toasts: toasts ?? this.toasts);
  }
}

class _FriendStatusToastNotifier extends Notifier<_FriendStatusToastState> {
  static const Duration toastDuration = Duration(seconds: 5);
  static const Duration animationDuration = Duration(milliseconds: 420);

  @override
  _FriendStatusToastState build() => const _FriendStatusToastState();

  void showEvent(FriendStatusChangeEvent event) {
    final toastData = FriendStatusToastData(
      id: '${event.account.id}-${DateTime.now().microsecondsSinceEpoch}',
      event: event,
      createdAt: DateTime.now(),
      duration: toastDuration,
    );
    state = state.copyWith(toasts: [...state.toasts, toastData]);
  }

  void _startExitAnimation(String toastId) {
    state = state.copyWith(
      toasts: [
        for (final toast in state.toasts)
          toast.id == toastId ? toast.copyWith(isExiting: true) : toast,
      ],
    );
  }

  void _removeToast(String toastId) {
    state = state.copyWith(
      toasts: state.toasts.where((toast) => toast.id != toastId).toList(),
    );
  }

  void dismissToast(String toastId) {
    _startExitAnimation(toastId);
  }

  void dismissAll() {
    state = state.copyWith(
      toasts: [
        for (final toast in state.toasts) toast.copyWith(isExiting: true),
      ],
    );
  }
}

final friendStatusToastProvider =
    NotifierProvider<_FriendStatusToastNotifier, _FriendStatusToastState>(
      _FriendStatusToastNotifier.new,
    );

class FriendStatusToastOverlay extends HookConsumerWidget {
  const FriendStatusToastOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPaused = useState(false);
    final toastState = ref.watch(friendStatusToastProvider);
    final toastManager = ref.read(friendStatusToastProvider.notifier);
    final toasts = toastState.toasts;
    if (toasts.isEmpty) {
      return const SizedBox.shrink();
    }
    final isDesktop = isWideScreen(context);
    final devicePadding = MediaQuery.paddingOf(context);
    final topOffset =
        devicePadding.top +
        ((!kIsWeb &&
                (Platform.isMacOS || Platform.isLinux || Platform.isWindows))
            ? 40
            : 16);
    final itemWidth = isDesktop ? 360.0 : MediaQuery.sizeOf(context).width;

    if (isDesktop) {
      return Positioned(
        top: topOffset,
        left: 0,
        right: 0,
        child: MouseRegion(
          onEnter: (_) => isPaused.value = true,
          onExit: (_) => isPaused.value = false,
          child: Align(
            alignment: Alignment.topRight,
            child: SizedBox(
              width: itemWidth,
              child: Material(
                color: Colors.transparent,
                child: Column(
                  spacing: 8,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: toasts.map((toast) {
                    return _AnimatedToast(
                      key: ValueKey(toast.id),
                      toastData: toast,
                      isDesktop: true,
                      pauseAutoDismiss: isPaused.value,
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      onDismiss: () => toastManager.dismissToast(toast.id),
                      onRemove: () => toastManager._removeToast(toast.id),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ),
      );
    }

    final visibleToasts = toasts.take(kFriendStatusVisibleLimit).toList();
    final heldCount = toasts.length - visibleToasts.length;
    const overlap = 20.0;
    final calculatedHeight = overlap * (visibleToasts.length - 1) + 120.0;

    return Positioned(
      top: topOffset,
      left: 0,
      right: 0,
      child: MouseRegion(
        onEnter: (_) => isPaused.value = true,
        onExit: (_) => isPaused.value = false,
        child: Align(
          alignment: Alignment.topCenter,
          child: SizedBox(
            width: itemWidth,
            child: Material(
              color: Colors.transparent,
              child: SizedBox(
                height: calculatedHeight + (heldCount > 0 ? 28 : 0),
                child: Stack(
                  alignment: Alignment.topCenter,
                  clipBehavior: Clip.none,
                  children: [
                    ...visibleToasts.asMap().entries.map((entry) {
                      final index = entry.key;
                      final toast = entry.value;
                      return AnimatedPositioned(
                        key: ValueKey(toast.id),
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeOutCubic,
                        top: index * overlap + (heldCount > 0 ? 14 : 0),
                        left: 16,
                        right: 16,
                        child: _AnimatedToast(
                          toastData: toast,
                          isDesktop: false,
                          pauseAutoDismiss: isPaused.value,
                          showStackSeparation: index > 0,
                          onDismiss: () => toastManager.dismissToast(toast.id),
                          onRemove: () => toastManager._removeToast(toast.id),
                        ),
                      );
                    }),
                    Positioned(
                      top: 0,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 240),
                        reverseDuration: const Duration(milliseconds: 180),
                        switchInCurve: Curves.easeOutBack,
                        switchOutCurve: Curves.easeInCubic,
                        transitionBuilder: (child, animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: ScaleTransition(
                              scale: Tween<double>(
                                begin: 0.88,
                                end: 1,
                              ).animate(animation),
                              child: SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(0, -0.2),
                                  end: Offset.zero,
                                ).animate(animation),
                                child: child,
                              ),
                            ),
                          );
                        },
                        child: heldCount > 0
                            ? _FriendHeldBadge(
                                key: ValueKey(heldCount),
                                count: heldCount,
                                onTap: toastManager.dismissAll,
                              )
                            : const SizedBox.shrink(
                                key: ValueKey('empty-badge'),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AnimatedToast extends HookConsumerWidget {
  final FriendStatusToastData toastData;
  final VoidCallback onDismiss;
  final VoidCallback onRemove;
  final bool isDesktop;
  final EdgeInsets? margin;
  final bool showStackSeparation;
  final bool pauseAutoDismiss;

  const _AnimatedToast({
    super.key,
    required this.toastData,
    required this.onDismiss,
    required this.onRemove,
    required this.isDesktop,
    this.margin,
    this.showStackSeparation = false,
    this.pauseAutoDismiss = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = useAnimationController(
      duration: _FriendStatusToastNotifier.animationDuration,
    );
    final progressController = useAnimationController(
      duration: toastData.duration,
    );

    final fadeCurve = useMemoized(
      () => CurvedAnimation(
        parent: controller,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      ),
      [controller],
    );
    final slideCurve = useMemoized(
      () => CurvedAnimation(
        parent: controller,
        curve: Curves.easeOutBack,
        reverseCurve: Curves.easeInCubic,
      ),
      [controller],
    );
    final scaleCurve = useMemoized(
      () => CurvedAnimation(
        parent: controller,
        curve: Curves.easeOutExpo,
        reverseCurve: Curves.easeInCubic,
      ),
      [controller],
    );

    useEffect(() {
      controller.forward();
      void listener(AnimationStatus status) {
        if (status == AnimationStatus.completed && !toastData.isExiting) {
          onDismiss();
        }
      }

      progressController.addStatusListener(listener);
      return () => progressController.removeStatusListener(listener);
    }, []);

    useEffect(() {
      if (toastData.isExiting) {
        controller.reverse().then((_) => onRemove());
      }
      return null;
    }, [toastData.isExiting]);

    useEffect(() {
      if (toastData.isExiting) return null;
      if (pauseAutoDismiss) {
        progressController.stop(canceled: false);
      } else if (progressController.status != AnimationStatus.completed) {
        progressController.forward();
      }
      return null;
    }, [pauseAutoDismiss, toastData.isExiting]);

    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, -72 * (1 - slideCurve.value)),
          child: Transform.scale(
            scale: 0.92 + (0.08 * scaleCurve.value),
            alignment: Alignment.topCenter,
            child: Opacity(opacity: fadeCurve.value, child: child),
          ),
        );
      },
      child: Padding(
        padding: margin ?? EdgeInsets.zero,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            if (!isDesktop && showStackSeparation)
              Positioned(
                top: -10,
                left: 10,
                right: 10,
                height: 16,
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(
                            context,
                          ).colorScheme.shadow.withOpacity(0.14),
                          blurRadius: 14,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            FriendStatusToast(
              event: toastData.event,
              onDismiss: onDismiss,
              autoDismissDuration: toastData.duration,
            ),
          ],
        ),
      ),
    );
  }
}

class _FriendHeldBadge extends StatelessWidget {
  final int count;
  final VoidCallback? onTap;

  const _FriendHeldBadge({super.key, required this.count, this.onTap});

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
