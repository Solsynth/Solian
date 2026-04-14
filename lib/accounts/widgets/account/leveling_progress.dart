import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class LevelingProgressCard extends StatelessWidget {
  final int level;
  final int experience;
  final double progress;
  final VoidCallback? onTap;
  final bool isCompact;

  const LevelingProgressCard({
    super.key,
    required this.level,
    required this.experience,
    required this.progress,
    this.onTap,
    this.isCompact = false,
  });

  static const _stageColors = [
    Colors.green,
    Colors.blue,
    Colors.teal,
    Colors.cyan,
    Colors.indigo,
    Colors.lime,
    Colors.yellow,
    Colors.amber,
    Colors.orange,
    Colors.deepOrange,
    Colors.pink,
    Colors.red,
  ];

  int get _stage => ((level - 1) ~/ 10 + 1).clamp(1, 12);
  Color get _stageColor => _stageColors[_stage - 1];

  String _formatExperience(int exp) {
    if (exp >= 1000000) {
      return '${(exp / 1000000).toStringAsFixed(1)}M';
    } else if (exp >= 1000) {
      return '${(exp / 1000).toStringAsFixed(1)}K';
    }
    return exp.toString();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final stageColor = _stageColor;

    final compactValues = isCompact
        ? (levelFontSize: 14.0, stageFontSize: 13.0, expFontSize: 12.0)
        : (levelFontSize: 18.0, stageFontSize: 14.0, expFontSize: 14.0);

    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isCompact ? 16 : 20,
            vertical: isCompact ? 12 : 16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'levelingProgressLevel'.tr(args: [level.toString()]),
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: stageColor,
                      fontWeight: FontWeight.bold,
                      fontSize: compactValues.levelFontSize,
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'levelingStage$_stage'.tr(),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: stageColor.withAlpha(180),
                          fontWeight: FontWeight.w500,
                          fontSize: compactValues.stageFontSize,
                        ),
                      ),
                      if (onTap != null) ...[
                        const SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: isCompact ? 10 : 12,
                          color: stageColor.withAlpha(180),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Tooltip(
                      message: '${(progress * 100).toStringAsFixed(1)}%',
                      child: LinearProgressIndicator(
                        minHeight: isCompact ? 6 : 10,
                        value: progress,
                        borderRadius: BorderRadius.circular(32),
                        backgroundColor: colorScheme.surfaceContainerHighest,
                        color: stageColor,
                        stopIndicatorColor: stageColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    isCompact
                        ? _formatExperience(experience)
                        : 'levelingProgressExperience'.tr(
                            args: [experience.toString()],
                          ),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withAlpha(200),
                      fontSize: compactValues.expFontSize,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
