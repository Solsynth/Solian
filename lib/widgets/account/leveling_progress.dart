import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:styled_widget/styled_widget.dart';

class LevelingProgressCard extends StatelessWidget {
  final int level;
  final int experience;
  final double progress;

  const LevelingProgressCard({
    super.key,
    required this.level,
    required this.experience,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            spacing: 8,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                'levelingProgressLevel'.tr(args: [level.toString()]),
                style: GoogleFonts.robotoMono(),
              ).fontSize(13).bold(),
              Text(
                'levelingProgressExperience'.tr(args: [experience.toString()]),
                style: GoogleFonts.robotoMono(),
              ).fontSize(13),
            ],
          ),
          const Gap(8),
          Tooltip(
            message: '${(progress).toStringAsFixed(1)}%',
            child: LinearProgressIndicator(
              minHeight: 4,
              value: progress / 100,
              color: Theme.of(context).colorScheme.primary,
              backgroundColor:
                  Theme.of(context).colorScheme.surfaceContainerHigh,
            ),
          ),
        ],
      ).padding(horizontal: 16, vertical: 12),
    );
  }
}
