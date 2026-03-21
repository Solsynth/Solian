import 'package:flutter/material.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

class BadgeInfo {
  final String type;
  final String name;
  final String description;
  final IconData icon;
  final Color color;

  const BadgeInfo({
    required this.type,
    required this.name,
    required this.description,
    this.icon = Icons.star,
    this.color = Colors.blue,
  });
}

const Map<String, BadgeInfo> kBadgeTemplates = {
  'sponsor': BadgeInfo(
    type: 'sponsor',
    name: 'sponsorBadgeName',
    description: 'sponsorBadgeDescription',
    icon: Icons.favorite,
    color: Colors.red,
  ),
  'special.contributor': BadgeInfo(
    type: 'ranks.contributor',
    name: 'contributorBadgeName',
    description: 'contributorBadgeDescription',
    icon: Icons.stars,
    color: Colors.purple,
  ),
  'special.founder': BadgeInfo(
    type: 'event.founder',
    name: 'founderBadgeName',
    description: 'founderBadgeDescription',
    icon: Icons.foundation,
    color: Colors.deepPurple,
  ),
  'special.developer': BadgeInfo(
    type: 'special.developer',
    name: 'developerBadgeName',
    description: 'developerBadgeDescription',
    icon: Icons.code,
    color: Colors.indigo,
  ),
  'special.translator': BadgeInfo(
    type: 'special.translator',
    name: 'translatorBadgeName',
    description: 'translatorBadgeDescription',
    icon: Icons.code,
    color: Colors.grey,
  ),
};

Color getBadgeColor(SnAccountBadge badge) {
  if (badge.type == 'sponsor') {
    final level =
        int.tryParse(
          (badge.meta['level'] as String?)?.replaceAll('"', '') ?? '0',
        ) ??
        0;
    final clampedLevel = level.clamp(0, 36);
    final t = clampedLevel / 36.0;
    const redColor = Colors.red;
    const goldenColor = Color(0xFFDAA520);
    return Color.lerp(redColor, goldenColor, t)!;
  }
  final template = kBadgeTemplates[badge.type];
  return template?.color ?? Colors.blue;
}
