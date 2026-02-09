import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:styled_widget/styled_widget.dart';

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

  @override
  Widget build(BuildContext context) {
    // Calculate level stage (1-12, each stage covers 10 levels)
    int stage = ((level - 1) ~/ 10) + 1;
    stage = stage.clamp(1, 12); // Ensure stage is within 1-12

    // Define colors for each stage
    const List<Color> stageColors = [
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

    Color stageColor = stageColors[stage - 1];

    // Compact mode adjustments
    final double levelFontSize = isCompact ? 14 : 18;
    final double stageFontSize = isCompact ? 13 : 14;
    final double experienceFontSize = isCompact ? 12 : 14;
    final double progressHeight = isCompact ? 6 : 10;
    final double horizontalPadding = isCompact ? 16 : 20;
    final double verticalPadding = isCompact ? 12 : 16;
    final double gapSize = isCompact ? 4 : 8;
    final double rowSpacing = 12;

    final cardContent = Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: [
                stageColor.withOpacity(0.1),
                Theme.of(context).colorScheme.surface,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                spacing: rowSpacing,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Expanded(
                    child: Text(
                      'levelingProgressLevel'.tr(args: [level.toString()]),
                      style: TextStyle(
                        color: stageColor,
                        fontWeight: FontWeight.bold,
                        fontSize: levelFontSize,
                      ),
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'levelingStage$stage'.tr(),
                        style: TextStyle(
                          color: stageColor.withOpacity(0.7),
                          fontWeight: FontWeight.w500,
                          fontSize: stageFontSize,
                        ),
                      ),
                      if (onTap != null) ...[
                        const Gap(4),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: isCompact ? 10 : 12,
                          color: stageColor.withOpacity(0.7),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
              Gap(gapSize),
              Row(
                spacing: rowSpacing,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Tooltip(
                      message: '${(progress * 100).toStringAsFixed(1)}%',
                      child: LinearProgressIndicator(
                        minHeight: progressHeight,
                        value: progress,
                        borderRadius: BorderRadius.circular(32),
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerLow.withOpacity(0.75),
                        color: stageColor,
                        stopIndicatorRadius: 0,
                        trackGap: 0,
                      ),
                    ),
                  ),
                  Text(
                    'levelingProgressExperience'.tr(
                      args: [experience.toString()],
                    ),
                    style: TextStyle(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.8),
                      fontSize: experienceFontSize,
                    ),
                  ),
                ],
              ),
            ],
          ).padding(horizontal: horizontalPadding, vertical: verticalPadding),
        ),
      ),
    );

    return cardContent;
  }
}
