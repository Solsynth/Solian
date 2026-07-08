import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/config.dart';
import 'package:island/core/network.dart';
import 'package:island/core/svg_helper.dart';
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

final badgesManifestProvider =
    FutureProvider.autoDispose<List<BadgeManifestEntry>>((ref) async {
      final client = ref.watch(solarNetworkClientProvider);
      return await client.accounts.getBadgesManifest();
    });

final badgeManifestMapProvider =
    Provider.autoDispose<Map<String, BadgeManifestEntry>>((ref) {
      final manifest = ref.watch(badgesManifestProvider);
      return manifest.whenOrNull(
            data: (entries) {
              return {for (final e in entries) e.identifier: e};
            },
          ) ??
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
  final primary = manifest?[badge.type]?.caption;
  final fallback = kBadgeTemplates[badge.type]?.description;
  final badgeCaption = badge.caption;

  var desc = (primary != null && primary.isNotEmpty)
      ? primary
      : (fallback != null && fallback.isNotEmpty)
      ? fallback
      : null;
  if (desc?.trExists() ?? false) desc = desc?.tr();

  if (badgeCaption != null && badgeCaption.isNotEmpty && badgeCaption != desc) {
    return desc != null ? '$desc\n$badgeCaption' : badgeCaption;
  }

  return desc;
}

String? getBadgeIconUrl(
  SnAccountBadge badge, {
  Map<String, BadgeManifestEntry>? manifest,
}) {
  if (manifest == null) return null;
  return manifest[badge.type]?.iconUrl;
}

class CachedBadgeIcon extends ConsumerWidget {
  final String? iconUrl;
  final Color color;
  final IconData fallbackIcon;
  final double size;

  const CachedBadgeIcon({
    super.key,
    required this.iconUrl,
    required this.color,
    required this.fallbackIcon,
    this.size = 20,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (iconUrl == null || iconUrl!.isEmpty) {
      return Icon(fallbackIcon, color: color, size: size);
    }

    final serverUrl = ref.watch(serverUrlProvider);
    final fullUrl = iconUrl!.startsWith('http')
        ? iconUrl!
        : '$serverUrl$iconUrl';

    return _CachedSvgIcon(
      url: fullUrl,
      color: color,
      fallbackIcon: fallbackIcon,
      size: size,
    );
  }
}

class _CachedSvgIcon extends StatefulWidget {
  final String url;
  final Color color;
  final IconData fallbackIcon;
  final double size;

  const _CachedSvgIcon({
    required this.url,
    required this.color,
    required this.fallbackIcon,
    required this.size,
  });

  @override
  State<_CachedSvgIcon> createState() => _CachedSvgIconState();
}

class _CachedSvgIconState extends State<_CachedSvgIcon> {
  bool _loading = true;
  String? _cachedSvgContent;

  @override
  void initState() {
    super.initState();
    _loadCachedSvg();
  }

  @override
  void didUpdateWidget(_CachedSvgIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      _loadCachedSvg();
    }
  }

  Future<void> _loadCachedSvg() async {
    try {
      if (kIsWeb) {
        // On web, use network directly since dart:io File is not available
        setState(() {
          _cachedSvgContent = widget.url;
          _loading = false;
        });
      } else {
        // On native, use cache manager
        final fileInfo = await DefaultCacheManager().getFileFromCache(
          widget.url,
        );
        if (!mounted) return;

        if (fileInfo != null) {
          setState(() {
            _cachedSvgContent = fileInfo.file.path;
            _loading = false;
          });
        } else {
          final downloaded = await DefaultCacheManager().downloadFile(
            widget.url,
          );
          if (!mounted) return;
          setState(() {
            _cachedSvgContent = downloaded.file.path;
            _loading = false;
          });
        }
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return SizedBox(
        width: widget.size,
        height: widget.size,
        child: Center(
          child: SizedBox(
            width: widget.size * 0.6,
            height: widget.size * 0.6,
            child: CircularProgressIndicator(
              strokeWidth: 1.5,
              color: widget.color.withOpacity(0.5),
            ),
          ),
        ),
      );
    }

    if (_cachedSvgContent != null) {
      return buildSvgFromFile(
        _cachedSvgContent!,
        width: widget.size,
        height: widget.size,
        colorFilter: ColorFilter.mode(widget.color, BlendMode.srcIn),
        fallbackIcon: widget.fallbackIcon,
        fallbackColor: widget.color,
      );
    }

    return Icon(widget.fallbackIcon, color: widget.color, size: widget.size);
  }
}
