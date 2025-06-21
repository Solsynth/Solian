import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/pods/userinfo.dart';
import 'package:island/services/responsive.dart';
import 'package:island/widgets/app_scaffold.dart';
import 'package:island/widgets/account/leveling_progress.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';

@RoutePage()
class LevelingScreen extends HookConsumerWidget {
  const LevelingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userInfoProvider);

    if (user.value == null) {
      return AppScaffold(
        appBar: AppBar(title: Text('levelingProgress'.tr())),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final currentLevel = user.value!.profile.level;
    final currentExp = user.value!.profile.experience;
    final progress = user.value!.profile.levelingProgress;

    return AppScaffold(
      appBar: AppBar(title: Text('levelingProgress'.tr())),
      body: SingleChildScrollView(
        padding: getTabbedPadding(context, horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Current Progress Card
            LevelingProgressCard(
              level: currentLevel,
              experience: currentExp,
              progress: progress,
            ),
            const Gap(24),

            // Level Stairs Graph
            Text(
              'Level Progress',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const Gap(16),

            // Stairs visualization with fixed height and horizontal scroll
            _buildLevelStairs(context, currentLevel),

            const Gap(24),

            // Placeholder for unlocked content
            Text(
              'Unlocked Features',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const Gap(16),
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                ),
              ),
              child: Center(
                child: Text(
                  'Unlocked features will be shown here',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelStairs(BuildContext context, int currentLevel) {
    const totalLevels = 14;
    const stairHeight = 20.0;
    const stairWidth = 50.0;
    const containerHeight = 280.0;

    return Container(
      height: containerHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: SizedBox(
          width: (totalLevels * (stairWidth + 8)) + 40,
          height: containerHeight,
          child: CustomPaint(
            painter: LevelStairsPainter(
              currentLevel: currentLevel,
              totalLevels: totalLevels,
              primaryColor: Theme.of(context).colorScheme.primary,
              surfaceColor: Theme.of(context).colorScheme.surfaceContainerHigh,
              onSurfaceColor: Theme.of(context).colorScheme.onSurface,
              stairHeight: stairHeight,
              stairWidth: stairWidth,
            ),
            child: Stack(
              children: List.generate(totalLevels, (index) {
                final level = index + 1;
                final isCompleted = level <= currentLevel;
                final isCurrent = level == currentLevel;

                // Calculate position from bottom
                final bottomPosition = 0.0;
                final leftPosition = 20.0 + (index * (stairWidth + 8));

                // Make higher levels progressively taller
                final progressiveHeight =
                    40.0 + (index * 15.0); // Base height + progressive increase

                return Positioned(
                  left: leftPosition,
                  bottom: bottomPosition,
                  child: Container(
                    width: stairWidth,
                    height: progressiveHeight,
                    decoration: BoxDecoration(
                      color:
                          isCompleted
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(
                                context,
                              ).colorScheme.surfaceContainerHigh,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(6),
                        topRight: Radius.circular(6),
                      ),
                      border:
                          isCurrent
                              ? Border.all(
                                color: Theme.of(context).colorScheme.primary,
                                width: 2,
                              )
                              : null,
                      boxShadow:
                          isCurrent
                              ? [
                                BoxShadow(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.primary.withOpacity(0.3),
                                  blurRadius: 6,
                                  spreadRadius: 1,
                                ),
                              ]
                              : null,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Column(
                        children: [
                          Text(
                            level.toString(),
                            style: GoogleFonts.robotoMono(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color:
                                  isCompleted
                                      ? Theme.of(context).colorScheme.onPrimary
                                      : Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          if (isCurrent) ...[
                            const Gap(4),
                            Container(
                              width: 4,
                              height: 4,
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.onPrimary,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class LevelStairsPainter extends CustomPainter {
  final int currentLevel;
  final int totalLevels;
  final Color primaryColor;
  final Color surfaceColor;
  final Color onSurfaceColor;
  final double stairHeight;
  final double stairWidth;

  LevelStairsPainter({
    required this.currentLevel,
    required this.totalLevels,
    required this.primaryColor,
    required this.surfaceColor,
    required this.onSurfaceColor,
    required this.stairHeight,
    required this.stairWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = surfaceColor.withOpacity(0.2)
          ..strokeWidth = 1.5
          ..style = PaintingStyle.stroke;

    // Draw connecting lines between stairs
    for (int i = 0; i < totalLevels - 1; i++) {
      final startX = 20.0 + (i * (stairWidth + 8)) + stairWidth;
      final startHeight =
          40.0 + (i * 15.0); // Progressive height for current stair
      final startY = size.height - (20.0 + startHeight);

      final endX = 20.0 + ((i + 1) * (stairWidth + 8));
      final endHeight =
          40.0 + ((i + 1) * 15.0); // Progressive height for next stair
      final endY = size.height - (20.0 + endHeight);

      canvas.drawLine(Offset(startX, startY), Offset(endX, endY), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
