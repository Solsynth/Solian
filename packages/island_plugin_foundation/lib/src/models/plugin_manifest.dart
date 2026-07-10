import 'package:freezed_annotation/freezed_annotation.dart';

part 'plugin_manifest.freezed.dart';
part 'plugin_manifest.g.dart';

/// Permissions that plugins can request.
enum PluginPermission {
  /// Listen to app events.
  eventsSubscribe,

  /// Register commands in the command palette.
  commandsRegister,

  /// Return UI descriptors for rendering.
  uiRender,

  /// Make unauthenticated requests to arbitrary internet hosts.
  networkInternet,

  /// Make requests to the configured Solar Network server as the signed-in user.
  solarNetworkApi,

  /// Read posts.
  sdkPostsRead,

  /// Create posts.
  sdkPostsCreate,

  /// Read chat messages.
  sdkChatRead,

  /// Send chat messages.
  sdkChatSend,

  /// Read files from drive.
  sdkDriveRead,

  /// Write files to drive.
  sdkDriveWrite,

  /// Read user profile.
  sdkUserRead,

  /// Show local notifications.
  notify,

  /// Register background tasks.
  tasksSchedule,
}

/// Plugin lifecycle state.
enum PluginState {
  /// Discovered but not loaded.
  discovered,

  /// Loaded and initialized.
  loaded,

  /// Active and running.
  active,

  /// Disabled by user.
  disabled,

  /// Failed to load or errored.
  error,
}

/// Manifest describing a plugin's metadata, entry point, and permissions.
@freezed
sealed class PluginManifest with _$PluginManifest {
  const factory PluginManifest({
    /// Unique reverse-domain identifier, e.g. "com.example.myplugin".
    required String id,

    /// Human-readable plugin name.
    required String name,

    /// Semver version string.
    @Default('1.0.0') String version,

    /// Plugin author.
    @Default('') String author,

    /// Short description.
    @Default('') String description,

    /// Entry point JavaScript file relative to the plugin directory.
    @Default('main.js') String entry,

    /// List of permissions this plugin requires.
    @Default([]) List<PluginPermission> permissions,

    /// Whether this plugin should run as a background task.
    @Default(false) bool background,

    /// Optional icon name (Material Symbols).
    String? icon,

    /// Optional homepage URL.
    String? homepage,
  }) = _PluginManifest;

  factory PluginManifest.fromJson(Map<String, dynamic> json) =>
      _$PluginManifestFromJson(json);
}
