import 'package:solar_network_sdk/solar_network_sdk.dart';

/// A production plugin listing from the public marketplace
/// (`GET /develop/miniapps`).
///
/// Maps the Develop service [SnMiniApp] JSON shape (snake_case). Host-only —
/// not part of the plugin foundation.
class MarketplacePlugin {
  const MarketplacePlugin({
    required this.id,
    required this.slug,
    required this.pluginId,
    required this.name,
    required this.version,
    this.author,
    this.description,
    this.homepage,
    this.packageUrl,
    this.packageSha256,
    this.packageSize,
    this.icon,
    this.publisherName,
    this.publisherNick,
    this.permissions = const [],
    this.background = false,
    this.entry = 'main.js',
  });

  final String id;
  final String slug;

  /// Reverse-domain plugin id from the package manifest (`plugin_id`).
  final String pluginId;
  final String name;
  final String version;
  final String? author;
  final String? description;
  final String? homepage;

  /// Public URL of the installable ZIP package.
  final String? packageUrl;

  /// Lowercase SHA-256 of the exact ZIP bytes (optional but preferred).
  final String? packageSha256;
  final int? packageSize;
  final SnCloudFileReference? icon;

  /// Hydrated publisher name from the developer record, if present.
  final String? publisherName;
  final String? publisherNick;

  /// Permission keys from the stored manifest (e.g. `notify`, `commandsRegister`).
  final List<String> permissions;
  final bool background;
  final String entry;

  bool get hasInstallablePackage =>
      packageUrl != null && packageUrl!.trim().isNotEmpty;

  String get displayAuthor {
    final nick = publisherNick?.trim();
    if (nick != null && nick.isNotEmpty) return nick;
    final pub = publisherName?.trim();
    if (pub != null && pub.isNotEmpty) return pub;
    final a = author?.trim();
    if (a != null && a.isNotEmpty) return a;
    return '';
  }

  factory MarketplacePlugin.fromJson(Map<String, dynamic> json) {
    SnCloudFileReference? icon;
    final iconRaw = json['icon'];
    if (iconRaw is Map<String, dynamic>) {
      try {
        icon = SnCloudFileReference.fromJson(iconRaw);
      } catch (_) {
        icon = null;
      }
    }

    String? publisherName;
    String? publisherNick;
    final developer = json['developer'];
    if (developer is Map<String, dynamic>) {
      final publisher = developer['publisher'];
      if (publisher is Map<String, dynamic>) {
        publisherName = publisher['name'] as String?;
        publisherNick = publisher['nick'] as String?;
      }
    }

    // Prefer denormalized columns; fill gaps from the nested manifest JSON.
    Map<String, dynamic>? manifest;
    final manifestRaw = json['manifest'];
    if (manifestRaw is Map<String, dynamic>) {
      manifest = manifestRaw;
    } else if (manifestRaw is Map) {
      manifest = Map<String, dynamic>.from(manifestRaw);
    }

    final permissions = <String>[];
    final permsRaw = manifest?['permissions'] ?? json['permissions'];
    if (permsRaw is List) {
      for (final p in permsRaw) {
        if (p == null) continue;
        final s = p.toString().trim();
        if (s.isNotEmpty) permissions.add(s);
      }
    }

    return MarketplacePlugin(
      id: (json['id'] ?? '').toString(),
      slug: (json['slug'] ?? '').toString(),
      pluginId: (json['plugin_id'] ??
              json['pluginId'] ??
              manifest?['id'] ??
              '')
          .toString(),
      name: (json['name'] ?? manifest?['name'] ?? '').toString(),
      version: (json['version'] ?? manifest?['version'] ?? '1.0.0').toString(),
      author: json['author'] as String? ?? manifest?['author'] as String?,
      description: json['description'] as String? ??
          manifest?['description'] as String?,
      homepage:
          json['homepage'] as String? ?? manifest?['homepage'] as String?,
      packageUrl: json['package_url'] as String? ?? json['packageUrl'] as String?,
      packageSha256:
          json['package_sha256'] as String? ?? json['packageSha256'] as String?,
      packageSize: (json['package_size'] as num?)?.toInt() ??
          (json['packageSize'] as num?)?.toInt(),
      icon: icon,
      publisherName: publisherName,
      publisherNick: publisherNick,
      permissions: permissions,
      background: manifest?['background'] as bool? ?? false,
      entry: (manifest?['entry'] ?? 'main.js').toString(),
    );
  }
}
