import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
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

  const FriendStatusToast({
    super.key,
    required this.event,
    this.onDismiss,
    this.autoDismissDuration = const Duration(seconds: 5),
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
      borderRadius: BorderRadius.circular(isActivityToast ? 20 : 24),
      side: BorderSide(
        color: theme.colorScheme.outlineVariant.withOpacity(0.5),
      ),
    );

    return Material(
      color: theme.colorScheme.surfaceContainerHigh,
      elevation: 3,
      shadowColor: theme.colorScheme.shadow.withOpacity(0.18),
      surfaceTintColor: theme.colorScheme.surfaceTint,
      shape: shape,
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: isActivityToast ? 280 : 360,
          minWidth: isActivityToast ? 220 : 300,
        ),
        child: InkWell(
          onTap: onDismiss,
          customBorder: shape,
          child: Stack(
            children: [
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
                  isActivityToast ? 8 : 10,
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
                          if (!isActivityToast) ...[
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
                                    style: theme.textTheme.labelMedium
                                        ?.copyWith(
                                          color: theme
                                              .colorScheme
                                              .onSurfaceVariant,
                                        ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ] else ...[
                            const SizedBox.shrink(),
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
      ),
    );
  }
}

class FriendStatusToastData {
  final String id;
  final FriendStatusChangeEvent event;
  final DateTime createdAt;
  final bool isExiting;

  const FriendStatusToastData({
    required this.id,
    required this.event,
    required this.createdAt,
    this.isExiting = false,
  });

  FriendStatusToastData copyWith({
    String? id,
    FriendStatusChangeEvent? event,
    DateTime? createdAt,
    bool? isExiting,
  }) {
    return FriendStatusToastData(
      id: id ?? this.id,
      event: event ?? this.event,
      createdAt: createdAt ?? this.createdAt,
      isExiting: isExiting ?? this.isExiting,
    );
  }
}

class _FriendStatusToastState {
  final FriendStatusToastData? currentToast;
  final Map<String, Timer> dismissTimers;

  const _FriendStatusToastState({
    this.currentToast,
    this.dismissTimers = const {},
  });

  _FriendStatusToastState copyWith({
    FriendStatusToastData? currentToast,
    Map<String, Timer>? dismissTimers,
    bool clearToast = false,
  }) {
    return _FriendStatusToastState(
      currentToast: clearToast ? null : (currentToast ?? this.currentToast),
      dismissTimers: dismissTimers ?? this.dismissTimers,
    );
  }
}

class _FriendStatusToastNotifier extends Notifier<_FriendStatusToastState> {
  static const Duration toastDuration = Duration(seconds: 5);
  static const Duration animationDuration = Duration(milliseconds: 420);

  @override
  _FriendStatusToastState build() => const _FriendStatusToastState();

  void showEvent(FriendStatusChangeEvent event) {
    final toastId = event.account.id;

    state.dismissTimers[toastId]?.cancel();
    for (final timer in state.dismissTimers.values) {
      timer.cancel();
    }

    final toastData = FriendStatusToastData(
      id: toastId,
      event: event,
      createdAt: DateTime.now(),
    );

    final timer = Timer(toastDuration, () {
      _startExitAnimation(toastId);
    });

    final newTimers = <String, Timer>{toastId: timer};

    state = _FriendStatusToastState(
      currentToast: toastData,
      dismissTimers: newTimers,
    );
  }

  void _startExitAnimation(String toastId) {
    if (state.currentToast?.id != toastId) return;

    state = state.copyWith(
      currentToast: state.currentToast?.copyWith(isExiting: true),
    );

    Timer(animationDuration, () {
      _removeToast(toastId);
    });
  }

  void _removeToast(String toastId) {
    if (state.currentToast?.id != toastId) return;

    state.dismissTimers[toastId]?.cancel();

    state = _FriendStatusToastState(dismissTimers: {});
  }

  void dismissToast(String toastId) {
    _startExitAnimation(toastId);
  }

  void dismissAll() {
    if (state.currentToast != null) {
      _startExitAnimation(state.currentToast!.id);
    }
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
    final toastState = ref.watch(friendStatusToastProvider);
    final toastManager = ref.read(friendStatusToastProvider.notifier);

    final currentToast = toastState.currentToast;
    if (currentToast == null) {
      return const SizedBox.shrink();
    }

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: _AnimatedToast(
        key: ValueKey(currentToast.id),
        toastData: currentToast,
        onDismiss: () => toastManager.dismissToast(currentToast.id),
      ),
    );
  }
}

class _AnimatedToast extends HookConsumerWidget {
  final FriendStatusToastData toastData;
  final VoidCallback onDismiss;

  const _AnimatedToast({
    super.key,
    required this.toastData,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = useAnimationController(
      duration: _FriendStatusToastNotifier.animationDuration,
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

    final isExiting = toastData.isExiting;

    useEffect(() {
      if (isExiting) {
        controller.reverse();
      } else {
        controller.forward();
      }
      return null;
    }, [isExiting]);

    return Padding(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 12),
      child: Center(
        child: AnimatedBuilder(
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
          child: FriendStatusToast(
            event: toastData.event,
            onDismiss: onDismiss,
            autoDismissDuration: _FriendStatusToastNotifier.toastDuration,
          ),
        ),
      ),
    );
  }
}
