import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/websocket.dart';
import 'package:island/main.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

final progressionWebSocketProvider =
    NotifierProvider<ProgressionWebSocketNotifier, void>(
      ProgressionWebSocketNotifier.new,
    );

class ProgressionWebSocketNotifier extends Notifier<void> {
  StreamSubscription? _subscription;
  final List<SnProgressionCompletedPacket> _pendingPackets = [];
  bool _isShowing = false;

  @override
  void build() {
    ref.onDispose(() {
      _subscription?.cancel();
    });
    _setupListener();
  }

  void _setupListener() {
    final service = ref.read(websocketProvider);
    _subscription = service.dataStream.listen((packet) {
      if (packet.type == 'progression.completed') {
        _handleProgressionCompleted(packet);
      }
    });
  }

  void _handleProgressionCompleted(WebSocketPacket packet) {
    if (packet.data == null) return;

    try {
      final completedPacket = SnProgressionCompletedPacket.fromJson(
        packet.data!,
      );
      _pendingPackets.add(completedPacket);
      _showNextCompletion();
    } catch (e) {
      // Handle parse error silently
    }
  }

  void _showNextCompletion() {
    if (_isShowing || _pendingPackets.isEmpty) return;

    _isShowing = true;
    final packet = _pendingPackets.removeAt(0);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showCompletionOverlay(packet);
    });
  }

  void _showCompletionOverlay(SnProgressionCompletedPacket packet) {
    final context = globalOverlay.currentState?.context;
    if (context == null) {
      _isShowing = false;
      _showNextCompletion();
      return;
    }

    OverlayEntry? entry;

    entry = OverlayEntry(
      builder: (context) => _ProgressionCompletionOverlay(
        kind: packet.kind,
        title: packet.title,
        identifier: packet.identifier,
        reward: packet.reward,
        onDismiss: () {
          entry?.remove();
          _isShowing = false;
          _showNextCompletion();
        },
      ),
    );

    globalOverlay.currentState?.insert(entry);
  }

  void testShowCompletion({
    required String kind,
    required String title,
    String? identifier,
    SnProgressRewardDefinition? reward,
  }) {
    final packet = SnProgressionCompletedPacket(
      kind: kind,
      identifier: identifier ?? 'test_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      reward: reward,
    );
    _pendingPackets.add(packet);
    _showNextCompletion();
  }
}

class _ProgressionCompletionOverlay extends StatefulWidget {
  final String kind;
  final String title;
  final String identifier;
  final SnProgressRewardDefinition? reward;
  final VoidCallback onDismiss;

  const _ProgressionCompletionOverlay({
    required this.kind,
    required this.title,
    required this.identifier,
    this.reward,
    required this.onDismiss,
  });

  @override
  State<_ProgressionCompletionOverlay> createState() =>
      _ProgressionCompletionOverlayState();
}

class _ProgressionCompletionOverlayState
    extends State<_ProgressionCompletionOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      reverseDuration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: 80.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.3,
          end: 1.1,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.1,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 60,
      ),
    ]).animate(_controller);

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();

    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        _dismiss();
      }
    });
  }

  void _dismiss() async {
    await _controller.reverse();
    widget.onDismiss();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isAchievement = widget.kind == 'achievement';
    final color = isAchievement ? Colors.amber : Colors.blue;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            bottom: bottomPadding + 16,
            child: FadeTransition(
              opacity: _opacityAnimation,
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, _slideAnimation.value),
                    child: Transform.scale(
                      scale: _scaleAnimation.value,
                      alignment: Alignment.bottomCenter,
                      child: child,
                    ),
                  );
                },
                child: Center(
                  child: GestureDetector(
                    onTap: _dismiss,
                    child: Container(
                      constraints: const BoxConstraints(
                        maxWidth: 500,
                        minWidth: 200,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                          BoxShadow(
                            color: color.withOpacity(0.3),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(32),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 14,
                          ),
                          child: _CompletionPillContent(
                            kind: widget.kind,
                            title: widget.title,
                            identifier: widget.identifier,
                            color: color,
                            reward: widget.reward,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CompletionPillContent extends StatelessWidget {
  final String kind;
  final String title;
  final String identifier;
  final Color color;
  final SnProgressRewardDefinition? reward;

  const _CompletionPillContent({
    required this.kind,
    required this.title,
    required this.identifier,
    required this.color,
    this.reward,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isAchievement = kind == 'achievement';
    final displayTitle = _getLocalizedTitle(identifier, title);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isAchievement ? Symbols.military_tech : Symbols.assignment,
              size: 22,
              color: color,
            ),
          ),
          const Gap(12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isAchievement
                    ? 'achievementUnlocked'.tr()
                    : 'questCompleted'.tr(),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
              Text(
                displayTitle,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          if (reward != null && _hasRewards(reward!)) ...[
            const Gap(12),
            Container(
              width: 1,
              height: 32,
              color: theme.colorScheme.outlineVariant,
            ),
            const Gap(12),
            _RewardRowCompact(reward: reward!),
          ],
        ],
      ),
    );
  }

  String _getLocalizedTitle(String identifier, String defaultTitle) {
    final isAchievement = kind == 'achievement';
    final key = isAchievement
        ? 'achievementTitle${_toCamelCase(identifier)}'
        : 'questTitle${_toCamelCase(identifier)}';
    final translated = key.tr();
    return translated == key ? defaultTitle : translated;
  }

  String _toCamelCase(String input) {
    if (input.isEmpty) return input;
    return input
        .split('-')
        .map(
          (word) => word.isNotEmpty
              ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}'
              : '',
        )
        .join();
  }

  bool _hasRewards(SnProgressRewardDefinition reward) {
    return reward.experience > 0 ||
        reward.sourcePoints > 0 ||
        reward.badge != null;
  }
}

class _RewardRowCompact extends StatelessWidget {
  final SnProgressRewardDefinition reward;

  const _RewardRowCompact({required this.reward});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (reward.experience > 0) ...[
          Icon(Symbols.star, size: 14, color: theme.colorScheme.primary),
          const Gap(2),
          Text(
            '+${reward.experience}',
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
        if (reward.sourcePoints > 0) ...[
          if (reward.experience > 0) const Gap(8),
          Icon(Symbols.toll, size: 14, color: theme.colorScheme.secondary),
          const Gap(2),
          Text(
            '+${reward.sourcePoints}',
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
        if (reward.badge != null) ...[
          if (reward.experience > 0 || reward.sourcePoints > 0) const Gap(8),
          Icon(Symbols.military_tech, size: 14, color: Colors.amber),
          const Gap(2),
          Text(
            reward.badge!.label ?? 'badge'.tr(),
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ],
    );
  }
}
