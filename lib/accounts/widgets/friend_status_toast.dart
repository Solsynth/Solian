import 'dart:async';
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
      FriendStatusChangeType.online => 'came online',
      FriendStatusChangeType.offline => 'went offline',
      FriendStatusChangeType.busy => 'is now busy',
      FriendStatusChangeType.doNotDisturb => 'enabled do not disturb',
      FriendStatusChangeType.activityStarted => 'started playing',
      FriendStatusChangeType.activityEnded => 'stopped playing',
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final statusColor = _getStatusColor(theme);

    return Material(
      color: Colors.transparent,
      child: Container(
        width: 240,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.colorScheme.outlineVariant.withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: InkWell(
          onTap: onDismiss,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              children: [
                Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: statusColor, width: 2),
                      ),
                      child: ProfilePictureWidget(
                        file: event.account.profile.picture,
                        radius: 16,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: statusColor,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: theme.colorScheme.surfaceContainerHigh,
                            width: 1.5,
                          ),
                        ),
                        child: Icon(
                          _getStatusIcon(),
                          size: 8,
                          color: Colors.white,
                          fill:
                              event.changeType == FriendStatusChangeType.online
                              ? 1
                              : 0,
                        ),
                      ),
                    ),
                  ],
                ),
                const Gap(8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        event.account.nick.isNotEmpty
                            ? event.account.nick
                            : event.account.name,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Gap(1),
                      Text(
                        _getStatusCaption(),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
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
  static const Duration animationDuration = Duration(milliseconds: 250);

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

    final curve = useMemoized(
      () => CurvedAnimation(
        parent: controller,
        curve: Curves.easeOutCubic,
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
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 8),
      child: Center(
        child: AnimatedBuilder(
          animation: curve,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, -80 * (1 - curve.value)),
              child: Opacity(opacity: curve.value, child: child),
            );
          },
          child: FriendStatusToast(
            event: toastData.event,
            onDismiss: onDismiss,
          ),
        ),
      ),
    );
  }
}
