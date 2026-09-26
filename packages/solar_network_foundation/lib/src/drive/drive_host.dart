import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

/// Settings the drive reads.
///
/// Field names mirror the hosts' own drive settings so wiring stays one-to-one.
class DriveSettings {
  const DriveSettings({
    this.dataSavingMode = false,
    this.imageCompressionEnabled = true,
    this.imageCompressionQuality = 80,
    this.defaultPoolId,
  });

  final bool dataSavingMode;
  final bool imageCompressionEnabled;
  final int imageCompressionQuality;
  final String? defaultPoolId;
}

/// Storage for E2EE file keys. The host backs this with its own secret store.
abstract class DriveSecretStore {
  Future<void> setSecret(String key, String value);
  Future<String?> getSecret(String key);
}

/// Snapshot of a task the drive previously created via [DriveTaskSink].
class DriveTaskSnapshot {
  const DriveTaskSnapshot({this.progress = 0, this.metadata});

  final double progress;
  final Map<String, dynamic>? metadata;
}

/// Bridge to the host's background task system (overlay, progress, tray).
abstract class DriveTaskSink {
  String addTask({
    required String title,
    required String type,
    required DriveTaskStatus status,
    Map<String, dynamic>? metadata,
  });

  void updateTask(
    String id, {
    DriveTaskStatus? status,
    double? progress,
    String? statusMessage,
    String? errorMessage,
    Map<String, dynamic>? result,
    Map<String, dynamic>? metadata,
  });

  /// Current state of [id], or `null` once the host has dropped the task.
  DriveTaskSnapshot? getTask(String id);
}

/// Surfaces an error to the user (toast/alert). Defaults to a no-op.
typedef DriveErrorReporter = void Function(Object error);

/// Opens the host's "buy more storage" flow, when the host has one.
typedef DriveQuotaUpgradePresenter = void Function(BuildContext context);

/// Authenticated Solar Network client (the host owns auth and construction).
final driveClientProvider = Provider<SolarNetworkClient>(
  (ref) => throw UnimplementedError(
    'driveClientProvider must be overridden by the host app',
  ),
);

/// Base URL used to render drive assets.
final driveServerUrlProvider = Provider<String>(
  (ref) => throw UnimplementedError(
    'driveServerUrlProvider must be overridden by the host app',
  ),
);

/// Drive-related app settings. Hosts override this with their own store.
final driveSettingsProvider = Provider<DriveSettings>(
  (ref) => const DriveSettings(),
);

/// E2EE file-key storage.
final driveSecretStoreProvider = Provider<DriveSecretStore>(
  (ref) => throw UnimplementedError(
    'driveSecretStoreProvider must be overridden by the host app',
  ),
);

/// Background task sink.
final driveTaskSinkProvider = Provider<DriveTaskSink>(
  (ref) => throw UnimplementedError(
    'driveTaskSinkProvider must be overridden by the host app',
  ),
);

/// Navigator key the drive uses to present sheets above the whole app.
final driveNavigatorKeyProvider = Provider<GlobalKey<NavigatorState>>(
  (ref) => throw UnimplementedError(
    'driveNavigatorKeyProvider must be overridden by the host app',
  ),
);

/// Error reporter. Defaults to a no-op so headless hosts can omit it.
final driveErrorReporterProvider = Provider<DriveErrorReporter>(
  (ref) => (error) {},
);

/// Optional quota-upgrade flow. `null` hides the purchase action.
final driveQuotaUpgradePresenterProvider =
    Provider<DriveQuotaUpgradePresenter?>((ref) => null);
