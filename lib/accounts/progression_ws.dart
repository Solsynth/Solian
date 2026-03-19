import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/websocket.dart';
import 'package:island/main.dart';
import 'package:island/route.dart';
import 'package:island/route.gr.dart';
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

    final reward = packet.reward;

    OverlayEntry? entry;

    entry = OverlayEntry(
      builder: (context) => _ProgressionCompletionOverlay(
        kind: packet.kind,
        title: packet.title,
        reward: reward,
        onDismiss: () {
          entry?.remove();
          _isShowing = false;
          _showNextCompletion();
        },
        onViewDetails: () {
          entry?.remove();
          _isShowing = false;
          _showNextCompletion();
          _navigateToProgress();
        },
      ),
    );

    globalOverlay.currentState?.insert(entry);
  }

  void _navigateToProgress() {
    try {
      final router = ref.read(routerProvider);
      router.push(const ProgressRoute());
    } catch (e) {
      // Router not available
    }
  }

  void testShowCompletion({
    required String kind,
    required String title,
    SnProgressRewardDefinition? reward,
  }) {
    final packet = SnProgressionCompletedPacket(
      kind: kind,
      identifier: 'test_${DateTime.now().millisecondsSinceEpoch}',
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
  final SnProgressRewardDefinition? reward;
  final VoidCallback onDismiss;
  final VoidCallback onViewDetails;

  const _ProgressionCompletionOverlay({
    required this.kind,
    required this.title,
    this.reward,
    required this.onDismiss,
    required this.onViewDetails,
  });

  @override
  State<_ProgressionCompletionOverlay> createState() =>
      _ProgressionCompletionOverlayState();
}

class _ProgressionCompletionOverlayState
    extends State<_ProgressionCompletionOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

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

    return Material(
      color: Colors.transparent,
      child: FadeTransition(
        opacity: _opacityAnimation,
        child: Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                onTap: _dismiss,
                child: Container(color: Colors.transparent),
              ),
            ),
            Center(
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Card(
                    elevation: 8,
                    child: InkWell(
                      onTap: widget.onViewDetails,
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 72,
                              height: 72,
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isAchievement
                                    ? Symbols.military_tech
                                    : Symbols.assignment,
                                size: 36,
                                color: color,
                              ),
                            ),
                            const Gap(16),
                            Text(
                              isAchievement
                                  ? 'achievementUnlocked'.tr()
                                  : 'questCompleted'.tr(),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: color,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Gap(8),
                            Text(
                              widget.title,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            if (widget.reward != null &&
                                _hasRewards(widget.reward!)) ...[
                              const Gap(16),
                              const Divider(),
                              const Gap(12),
                              _RewardPreview(reward: widget.reward!),
                            ],
                            const Gap(16),
                            Text(
                              'tapToViewProgress'.tr(),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
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
          ],
        ),
      ),
    );
  }

  bool _hasRewards(SnProgressRewardDefinition reward) {
    return reward.experience > 0 ||
        reward.sourcePoints > 0 ||
        reward.badge != null;
  }
}

class _RewardPreview extends StatelessWidget {
  final SnProgressRewardDefinition reward;

  const _RewardPreview({required this.reward});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      alignment: WrapAlignment.center,
      children: [
        if (reward.experience > 0)
          _RewardChip(icon: Symbols.star, label: '+${reward.experience} EXP'),
        if (reward.sourcePoints > 0)
          _RewardChip(icon: Symbols.toll, label: '+${reward.sourcePoints}'),
        if (reward.badge != null)
          _RewardChip(
            icon: Symbols.military_tech,
            label: reward.badge!.label ?? 'badge'.tr(),
          ),
      ],
    );
  }
}

class _RewardChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _RewardChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: theme.colorScheme.primary),
          const Gap(4),
          Text(label, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}
