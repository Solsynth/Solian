import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:island/accounts/badge.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

class BadgeList extends StatelessWidget {
  final List<SnAccountBadge> badges;
  const BadgeList({super.key, required this.badges});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: badges.map((badge) => BadgeItem(badge: badge)).toList(),
    );
  }
}

Color _getSponsorColor(int level) {
  // Level 0 = red, level 36+ = golden
  // Interpolate from red to golden based on level
  final clampedLevel = level.clamp(0, 36);
  final t = clampedLevel / 36.0;

  // Red to Golden (goldenrod - more orange-gold, less yellow)
  const redColor = Colors.red;
  const goldenColor = Color(0xFFDAA520); // Goldenrod

  return Color.lerp(redColor, goldenColor, t)!;
}

class BadgeItem extends StatelessWidget {
  final SnAccountBadge badge;
  const BadgeItem({super.key, required this.badge});

  @override
  Widget build(BuildContext context) {
    final template = kBadgeTemplates[badge.type];
    final name = template?.name.tr() ?? badge.label ?? 'unknown'.tr();
    final templateDesc = template?.description.tr();
    final badgeCaption = badge.caption;
    final description = [
      if (templateDesc != null && templateDesc.isNotEmpty) templateDesc,
      if (badgeCaption != null && badgeCaption.isNotEmpty) badgeCaption,
    ].join('\n');

    // Determine badge color - special handling for sponsor badges
    Color badgeColor;
    if (badge.type == 'sponsor') {
      final level = (badge.meta['level'] as num?)?.toInt() ?? 0;
      badgeColor = _getSponsorColor(level);
    } else {
      badgeColor = template?.color ?? Colors.blue;
    }

    return Tooltip(
      message: '$name\n$description',
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: badgeColor.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: Icon(template?.icon ?? Icons.stars, color: badgeColor, size: 20),
      ),
    );
  }
}
