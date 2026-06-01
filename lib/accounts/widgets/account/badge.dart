import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/badge.dart';
import 'package:island/core/config.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

class BadgeList extends ConsumerWidget {
  final List<SnAccountBadge> badges;
  const BadgeList({super.key, required this.badges});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final manifest = ref.watch(badgeManifestMapProvider);
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: badges
          .map((badge) => BadgeItem(badge: badge, manifest: manifest))
          .toList(),
    );
  }
}

class BadgeItem extends ConsumerWidget {
  final SnAccountBadge badge;
  final Map<String, BadgeManifestEntry> manifest;

  const BadgeItem({super.key, required this.badge, this.manifest = const {}});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final name = getBadgeName(badge, manifest: manifest);
    final description = getBadgeDescription(badge, manifest: manifest);
    final badgeColor = getBadgeColor(badge, manifest: manifest);
    final iconUrl = getBadgeIconUrl(badge, manifest: manifest);

    return Tooltip(
      message: description != null ? '$name\n$description' : name,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: badgeColor.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: _BadgeIcon(
          iconUrl: iconUrl,
          color: badgeColor,
          fallbackIcon: kBadgeTemplates[badge.type]?.icon ?? Icons.stars,
          size: 20,
        ),
      ),
    );
  }
}

class _BadgeIcon extends ConsumerWidget {
  final String? iconUrl;
  final Color color;
  final IconData fallbackIcon;
  final double size;

  const _BadgeIcon({
    required this.iconUrl,
    required this.color,
    required this.fallbackIcon,
    required this.size,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (iconUrl != null && iconUrl!.isNotEmpty) {
      final serverUrl = ref.watch(serverUrlProvider);
      final fullUrl = iconUrl!.startsWith('http')
          ? iconUrl!
          : '$serverUrl$iconUrl';

      return SvgPicture.network(
        fullUrl,
        width: size,
        height: size,
        colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
        placeholderBuilder: (_) =>
            Icon(fallbackIcon, size: size, color: color),
      );
    }

    return Icon(fallbackIcon, color: color, size: size);
  }
}
