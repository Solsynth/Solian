import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:island/core/websocket.dart';
import 'package:island/main.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

final progressionWebSocketProvider =
    NotifierProvider<ProgressionWebSocketNotifier, void>(
      ProgressionWebSocketNotifier.new,
    );

class ProgressionWebSocketNotifier extends Notifier<void> {
  StreamSubscription? _subscription;

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
      _showCompletionSnackBar(completedPacket);
    } catch (e) {
      // Handle parse error silently
    }
  }

  void _showCompletionSnackBar(
    SnProgressionCompletedPacket packet, {
    bool noVibrate = false,
  }) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = globalOverlay.currentState?.context;
      if (context == null) return;
      final theme = Theme.of(context);
      final isAchievement = packet.kind == 'achievement';
      final accentColor = isAchievement ? Colors.amber : Colors.blue;
      final containerColor = Color.alphaBlend(
        accentColor.withValues(alpha: 0.05),
        theme.colorScheme.surfaceContainer,
      );

      showCustomSnackBar(
        duration: const Duration(seconds: 4),
        noVibrate: noVibrate,
        containerColor: containerColor,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        enableStackScale: false,
        builder: (context, dismiss) => _ProgressionCompletionSnackBar(
          kind: packet.kind,
          title: packet.title,
          identifier: packet.identifier,
          reward: packet.reward,
          onDismiss: dismiss,
        ),
      );
    });
  }

  void testShowCompletion({
    required String kind,
    required String title,
    String? identifier,
    SnProgressRewardDefinition? reward,
    bool noVibrate = false,
  }) {
    final packet = SnProgressionCompletedPacket(
      kind: kind,
      title: title,
      identifier: identifier ?? 'test_${DateTime.now().millisecondsSinceEpoch}',
      reward: reward,
    );
    _showCompletionSnackBar(packet, noVibrate: noVibrate);
  }
}

class _ProgressionCompletionSnackBar extends StatelessWidget {
  final String kind;
  final String title;
  final String identifier;
  final SnProgressRewardDefinition? reward;
  final VoidCallback onDismiss;

  const _ProgressionCompletionSnackBar({
    required this.kind,
    required this.title,
    required this.identifier,
    this.reward,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final isAchievement = kind == 'achievement';
    final color = isAchievement ? Colors.amber : Colors.blue;

    return ConstrainedBox(
      constraints: const BoxConstraints(
        maxWidth: 500,
        minWidth: 200,
      ),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onDismiss,
        child: _CompletionPillContent(
          kind: kind,
          title: title,
          identifier: identifier,
          color: color,
          reward: reward,
        ),
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
          DecoratedBox(
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Icon(
                isAchievement ? Symbols.military_tech : Symbols.assignment,
                size: 20,
                color: color,
              ),
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
                style: theme.textTheme.labelMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.1,
                ),
              ),
              const Gap(2),
              Text(
                displayTitle,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          if (reward != null && _hasRewards(reward!)) ...[
            const Gap(12),
            Container(
              width: 1,
              height: 28,
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.7),
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
