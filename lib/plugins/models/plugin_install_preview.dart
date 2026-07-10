import 'package:island/plugins/models/marketplace_plugin.dart';
import 'package:island_plugin_foundation/island_plugin_foundation.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

/// How an install relates to an already-installed plugin with the same id.
enum PluginInstallConflict {
  /// No plugin with this id is installed.
  none,

  /// Same id, incoming version is newer → safe to override/update.
  upgrade,

  /// Same id and same version (reinstall).
  sameVersion,

  /// Same id, incoming version is older than installed.
  downgrade,

  /// Same id but versions could not be compared (treat as conflict).
  unknown,
}

/// Snapshot of plugin metadata shown before install / reinstall.
class PluginInstallPreview {
  const PluginInstallPreview({
    required this.id,
    required this.name,
    required this.version,
    this.author = '',
    this.description = '',
    this.homepage,
    this.entry = 'main.js',
    this.background = false,
    this.permissions = const [],
    this.packageSize,
    this.packageSha256,
    this.icon,
    this.slug,
    this.isInstalled = false,
    this.installedVersion,
    this.installedName,
    this.sourceHint,
    this.conflict = PluginInstallConflict.none,
  });

  final String id;
  final String name;
  final String version;
  final String author;
  final String description;
  final String? homepage;
  final String entry;
  final bool background;
  final List<String> permissions;
  final int? packageSize;
  final String? packageSha256;
  final SnCloudFileReference? icon;
  final String? slug;
  final bool isInstalled;
  final String? installedVersion;
  final String? installedName;

  /// Optional secondary line (e.g. local folder path or marketplace slug).
  final String? sourceHint;

  /// Conflict against an existing install with the same [id].
  final PluginInstallConflict conflict;

  bool get hasConflict => conflict != PluginInstallConflict.none;

  /// Newer version of an already-installed plugin — may override directly.
  bool get isUpgrade => conflict == PluginInstallConflict.upgrade;

  /// Same or older / unknown — user must explicitly allow override.
  bool get requiresOverrideAck =>
      conflict == PluginInstallConflict.sameVersion ||
      conflict == PluginInstallConflict.downgrade ||
      conflict == PluginInstallConflict.unknown;

  /// @deprecated Prefer [isUpgrade] / [conflict].
  bool get isUpdate => isUpgrade;

  /// Resolve conflict kind from installed version (if any).
  static PluginInstallConflict resolveConflict({
    required String incomingVersion,
    String? installedVersion,
  }) {
    if (installedVersion == null) return PluginInstallConflict.none;
    final cmp = comparePluginVersions(incomingVersion, installedVersion);
    if (cmp == null) return PluginInstallConflict.unknown;
    if (cmp > 0) return PluginInstallConflict.upgrade;
    if (cmp < 0) return PluginInstallConflict.downgrade;
    return PluginInstallConflict.sameVersion;
  }

  /// Compare two plugin version strings.
  ///
  /// Supports common forms: `1.2.3`, `v1.2.3`, optional pre-release
  /// (`1.2.3-beta.1`) and build metadata (`1.2.3+45`). Returns negative if
  /// [a] < [b], zero if equal, positive if [a] > [b], or `null` if either
  /// side cannot be parsed.
  static int? comparePluginVersions(String a, String b) {
    final pa = _ParsedPluginVersion.tryParse(a);
    final pb = _ParsedPluginVersion.tryParse(b);
    if (pa == null || pb == null) return null;
    return pa.compareTo(pb);
  }

  factory PluginInstallPreview.fromMarketplace(
    MarketplacePlugin plugin, {
    PluginInstance? existing,
  }) {
    final installedVersion = existing?.manifest.version;
    final conflict = resolveConflict(
      incomingVersion: plugin.version,
      installedVersion: installedVersion,
    );
    return PluginInstallPreview(
      id: plugin.pluginId,
      name: plugin.name,
      version: plugin.version,
      author: plugin.displayAuthor,
      description: plugin.description ?? '',
      homepage: plugin.homepage,
      entry: plugin.entry,
      background: plugin.background,
      permissions: plugin.permissions,
      packageSize: plugin.packageSize,
      packageSha256: plugin.packageSha256,
      icon: plugin.icon,
      slug: plugin.slug,
      isInstalled: existing != null,
      installedVersion: installedVersion,
      installedName: existing?.manifest.name,
      sourceHint: plugin.slug.isNotEmpty ? plugin.slug : null,
      conflict: conflict,
    );
  }

  factory PluginInstallPreview.fromManifest(
    PluginManifest manifest, {
    PluginInstance? existing,
    String? sourceHint,
    int? packageSize,
  }) {
    final installedVersion = existing?.manifest.version;
    final conflict = resolveConflict(
      incomingVersion: manifest.version,
      installedVersion: installedVersion,
    );
    return PluginInstallPreview(
      id: manifest.id,
      name: manifest.name,
      version: manifest.version,
      author: manifest.author,
      description: manifest.description,
      homepage: manifest.homepage,
      entry: manifest.entry,
      background: manifest.background,
      permissions: manifest.permissions.map((p) => p.name).toList(),
      packageSize: packageSize,
      isInstalled: existing != null,
      installedVersion: installedVersion,
      installedName: existing?.manifest.name,
      sourceHint: sourceHint,
      conflict: conflict,
    );
  }

  /// Build a preview against the current [PluginController] install set.
  factory PluginInstallPreview.fromMarketplaceWithController(
    MarketplacePlugin plugin,
    PluginController controller,
  ) {
    return PluginInstallPreview.fromMarketplace(
      plugin,
      existing: controller.plugins[plugin.pluginId],
    );
  }

  factory PluginInstallPreview.fromManifestWithController(
    PluginManifest manifest,
    PluginController controller, {
    String? sourceHint,
  }) {
    return PluginInstallPreview.fromManifest(
      manifest,
      existing: controller.plugins[manifest.id],
      sourceHint: sourceHint,
    );
  }
}

class _ParsedPluginVersion implements Comparable<_ParsedPluginVersion> {
  _ParsedPluginVersion({
    required this.parts,
    required this.preRelease,
  });

  final List<int> parts;
  final String? preRelease;

  static _ParsedPluginVersion? tryParse(String raw) {
    var s = raw.trim();
    if (s.isEmpty) return null;
    if (s.startsWith('v') || s.startsWith('V')) {
      s = s.substring(1);
    }
    // Drop build metadata: 1.2.3+45
    final plus = s.indexOf('+');
    if (plus >= 0) s = s.substring(0, plus);

    String? pre;
    final dash = s.indexOf('-');
    if (dash >= 0) {
      pre = s.substring(dash + 1);
      s = s.substring(0, dash);
    }

    final segments = s.split('.');
    if (segments.isEmpty || segments.any((e) => e.isEmpty)) return null;
    final parts = <int>[];
    for (final seg in segments) {
      final n = int.tryParse(seg);
      if (n == null || n < 0) return null;
      parts.add(n);
    }
    while (parts.length < 3) {
      parts.add(0);
    }
    return _ParsedPluginVersion(parts: parts, preRelease: pre);
  }

  @override
  int compareTo(_ParsedPluginVersion other) {
    final len = parts.length > other.parts.length
        ? parts.length
        : other.parts.length;
    for (var i = 0; i < len; i++) {
      final a = i < parts.length ? parts[i] : 0;
      final b = i < other.parts.length ? other.parts[i] : 0;
      if (a != b) return a.compareTo(b);
    }
    // No pre-release > pre-release (1.0.0 > 1.0.0-beta)
    final aPre = preRelease;
    final bPre = other.preRelease;
    if (aPre == null && bPre == null) return 0;
    if (aPre == null) return 1;
    if (bPre == null) return -1;
    return aPre.compareTo(bPre);
  }

  @override
  String toString() =>
      '${parts.join('.')}${preRelease != null ? '-$preRelease' : ''}';
}

/// Human-readable metadata for a plugin permission string.
class PluginPermissionInfo {
  const PluginPermissionInfo({
    required this.key,
    required this.titleKey,
    required this.descriptionKey,
    required this.icon,
  });

  final String key;
  final String titleKey;
  final String descriptionKey;
  final Object icon; // IconData — avoid importing material here for purity

  static const known = <String, (String title, String desc)>{
    'eventsSubscribe': (
      'pluginPermEventsSubscribe',
      'pluginPermEventsSubscribeDesc',
    ),
    'commandsRegister': (
      'pluginPermCommandsRegister',
      'pluginPermCommandsRegisterDesc',
    ),
    'uiRender': ('pluginPermUiRender', 'pluginPermUiRenderDesc'),
    'networkInternet': (
      'pluginPermNetworkInternet',
      'pluginPermNetworkInternetDesc',
    ),
    'solarNetworkApi': (
      'pluginPermSolarNetworkApi',
      'pluginPermSolarNetworkApiDesc',
    ),
    'sdkPostsRead': ('pluginPermSdkPostsRead', 'pluginPermSdkPostsReadDesc'),
    'sdkPostsCreate': (
      'pluginPermSdkPostsCreate',
      'pluginPermSdkPostsCreateDesc',
    ),
    'sdkChatRead': ('pluginPermSdkChatRead', 'pluginPermSdkChatReadDesc'),
    'sdkChatSend': ('pluginPermSdkChatSend', 'pluginPermSdkChatSendDesc'),
    'sdkDriveRead': ('pluginPermSdkDriveRead', 'pluginPermSdkDriveReadDesc'),
    'sdkDriveWrite': (
      'pluginPermSdkDriveWrite',
      'pluginPermSdkDriveWriteDesc',
    ),
    'sdkUserRead': ('pluginPermSdkUserRead', 'pluginPermSdkUserReadDesc'),
    'notify': ('pluginPermNotify', 'pluginPermNotifyDesc'),
    'tasksSchedule': (
      'pluginPermTasksSchedule',
      'pluginPermTasksScheduleDesc',
    ),
  };
}
