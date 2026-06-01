import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/network.dart';
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

final badgesManifestProvider = FutureProvider.autoDispose<List<BadgeManifestEntry>>((
  ref,
) async {
  final client = ref.watch(solarNetworkClientProvider);
  return await client.accounts.getBadgesManifest();
});

final badgeManifestMapProvider = Provider.autoDispose<Map<String, BadgeManifestEntry>>((
  ref,
) {
  final manifest = ref.watch(badgesManifestProvider);
  return manifest.whenOrNull(data: (entries) {
        return {for (final e in entries) e.identifier: e};
      }) ??
      {};
});

Color? _parseHexColor(String? hex) {
  if (hex == null || hex.isEmpty) return null;
  var value = hex.replaceFirst('#', '');
  if (value.length == 6) value = 'ff$value';
  if (value.length != 8) return null;
  return Color(int.parse(value, radix: 16));
}

Color getBadgeColor(
  SnAccountBadge badge, {
  Map<String, BadgeManifestEntry>? manifest,
}) {
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

  if (manifest != null) {
    final entry = manifest[badge.type];
    final manifestColor = _parseHexColor(entry?.color);
    if (manifestColor != null) return manifestColor;
  }

  final template = kBadgeTemplates[badge.type];
  return template?.color ?? Colors.blue;
}

String getBadgeName(
  SnAccountBadge badge, {
  Map<String, BadgeManifestEntry>? manifest,
}) {
  if (manifest != null) {
    final entry = manifest[badge.type];
    if (entry?.label != null && entry!.label!.isNotEmpty) return entry.label!;
  }
  final template = kBadgeTemplates[badge.type];
  return template?.name ?? badge.label ?? 'unknown';
}

String? getBadgeDescription(
  SnAccountBadge badge, {
  Map<String, BadgeManifestEntry>? manifest,
}) {
  final parts = <String>[];
  if (manifest != null) {
    final entry = manifest[badge.type];
    if (entry?.caption != null && entry!.caption!.isNotEmpty) {
      parts.add(entry.caption!);
    }
  }
  if (parts.isEmpty) {
    final template = kBadgeTemplates[badge.type];
    if (template != null) parts.add(template.description);
  }
  if (badge.caption != null && badge.caption!.isNotEmpty) {
    parts.add(badge.caption!);
  }
  return parts.isNotEmpty ? parts.join('\n') : null;
}

String? getBadgeIconUrl(
  SnAccountBadge badge, {
  Map<String, BadgeManifestEntry>? manifest,
}) {
  if (manifest == null) return null;
  return manifest[badge.type]?.iconUrl;
}
