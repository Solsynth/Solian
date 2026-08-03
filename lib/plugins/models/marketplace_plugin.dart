import 'package:island/developers/models/developer.dart';
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
    this.downloadCount,
    this.icon,
    this.developer,
    this.developerId,
    this.publisher,
    this.publisherId,
    this.projectName,
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

  /// Manifest / denormalized author string (fallback only).
  final String? author;
  final String? description;
  final String? homepage;

  /// Public URL of the installable ZIP package.
  final String? packageUrl;

  /// Lowercase SHA-256 of the exact ZIP bytes (optional but preferred).
  final String? packageSha256;
  final int? packageSize;

  /// Total installs reported by the marketplace (`download_count`).
  final int? downloadCount;

  final SnCloudFileReference? icon;

  /// Full developer record (`developer`) with the hydrated publisher —
  /// avatar (`picture`), `verification` and optional full `account`.
  final SnDeveloper? developer;

  /// Developer record id (`developer_id`, same as [SnDeveloper.id]).
  final String? developerId;

  /// Hydrated publisher from `developer.publisher` (preferred attribution).
  final SnPublisher? publisher;
  final String? publisherId;

  /// Optional project name when publisher is missing.
  final String? projectName;

  /// Permission keys from the stored manifest (e.g. `notify`, `commandsRegister`).
  final List<String> permissions;
  final bool background;
  final String entry;

  bool get hasInstallablePackage =>
      packageUrl != null && packageUrl!.trim().isNotEmpty;

  bool get hasPublisher => publisher != null;

  /// Developer avatar file — publisher `picture`, falling back to the
  /// hydrated account profile picture.
  SnCloudFileReference? get developerPicture =>
      publisher?.picture ?? publisher?.account?.profile.picture;

  /// Developer as an [SnAccount] for [AccountName] rendering: prefers the
  /// hydrated `publisher.account`; otherwise synthesizes a minimal account
  /// from the publisher record so the nick, avatar and verification mark
  /// still render.
  SnAccount? get developerAccount {
    final pub = publisher;
    if (pub == null) return null;
    final account = pub.account;
    if (account != null) return account;

    final id = pub.accountId ?? pub.id;
    final now = DateTime.now();
    return SnAccount(
      id: id,
      name: pub.name,
      nick: pub.nick,
      language: '',
      isSuperuser: false,
      automatedId: null,
      profile: SnAccountProfile(
        id: id,
        bio: pub.bio,
        experience: 0,
        level: 0,
        levelingProgress: 0,
        picture: pub.picture,
        background: pub.background,
        verification: pub.verification,
        createdAt: pub.createdAt ?? now,
        updatedAt: pub.updatedAt ?? now,
        deletedAt: pub.deletedAt,
      ),
      perkSubscription: null,
      activatedAt: null,
      createdAt: pub.createdAt ?? now,
      updatedAt: pub.updatedAt ?? now,
      deletedAt: pub.deletedAt,
    );
  }

  /// Author shown in plain-text fallback contexts (e.g. no hydrated
  /// developer) — prefers the manifest / denormalized author field, then
  /// the hydrated publisher record.
  String get displayAuthor {
    final a = author?.trim();
    if (a != null && a.isNotEmpty) return a;
    final pub = publisher;
    if (pub != null) {
      final nick = pub.nick.trim();
      if (nick.isNotEmpty) return nick;
      final name = pub.name.trim();
      if (name.isNotEmpty) return name;
    }
    final project = projectName?.trim();
    if (project != null && project.isNotEmpty) return project;
    return '';
  }

  /// Publisher display name when hydrated (secondary / optional).
  String get displayPublisher {
    final pub = publisher;
    if (pub == null) return '';
    final nick = pub.nick.trim();
    if (nick.isNotEmpty) return nick;
    return pub.name.trim();
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
    } else if (iconRaw is Map) {
      try {
        icon = SnCloudFileReference.fromJson(Map<String, dynamic>.from(iconRaw));
      } catch (_) {
        icon = null;
      }
    }

    final developerMap = _asStringKeyMap(json['developer']);
    final projectMap = _asStringKeyMap(json['project']);
    final projectDeveloperMap = _asStringKeyMap(projectMap?['developer']);

    // Prefer the top-level developer, then project.developer.
    final developer =
        _parseDeveloper(developerMap) ?? _parseDeveloper(projectDeveloperMap);

    final publisher =
        developer?.publisher ??
        _parsePublisher(projectDeveloperMap?['publisher']);

    final publisherId =
        developer?.publisherId ??
        (developerMap?['publisher_id'] ??
                projectDeveloperMap?['publisher_id'] ??
                publisher?.id)
            .toString();

    final projectName = projectMap?['name']?.toString();

    // Prefer denormalized columns; fill gaps from the nested manifest JSON.
    final manifest = _asStringKeyMap(json['manifest']);

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
      packageUrl:
          json['package_url'] as String? ?? json['packageUrl'] as String?,
      packageSha256:
          json['package_sha256'] as String? ?? json['packageSha256'] as String?,
      packageSize: (json['package_size'] as num?)?.toInt() ??
          (json['packageSize'] as num?)?.toInt(),
      downloadCount: (json['download_count'] as num?)?.toInt() ??
          (json['downloadCount'] as num?)?.toInt(),
      icon: icon,
      developer: developer,
      developerId: (json['developer_id'] ?? developer?.id)?.toString(),
      publisher: publisher,
      publisherId: publisherId,
      projectName: projectName,
      permissions: permissions,
      background: manifest?['background'] as bool? ?? false,
      entry: (manifest?['entry'] ?? 'main.js').toString(),
    );
  }

  static Map<String, dynamic>? _asStringKeyMap(dynamic raw) {
    if (raw is Map<String, dynamic>) return raw;
    if (raw is Map) return Map<String, dynamic>.from(raw);
    return null;
  }

  static SnDeveloper? _parseDeveloper(dynamic raw) {
    final map = _asStringKeyMap(raw);
    if (map == null) return null;
    try {
      return SnDeveloper.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  static SnPublisher? _parsePublisher(dynamic raw) {
    final map = _asStringKeyMap(raw);
    if (map == null) return null;
    try {
      return SnPublisher.fromJson(map);
    } catch (_) {
      return null;
    }
  }
}
