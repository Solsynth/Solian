import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:island/core/network.dart';
import 'package:island/core/server_capabilities.g.dart';

/// The capabilities required before the app can safely start its core flows.
/// Optional product capabilities are deliberately not listed here.
const kRequiredServerCapabilities = <String>{
  'auth',
  'accounts',
  'chat',
  'posts',
};

/// A single entry from the server's `/meta` `capabilities` map
/// (an `ApiFeature` on the server, e.g. `affiliations`).
class ServerCapability {
  final bool enabled;
  final int? revision;

  const ServerCapability({required this.enabled, this.revision});

  factory ServerCapability.fromJson(Map<String, dynamic> json) =>
      ServerCapability(
        enabled: json['enabled'] == true,
        revision: json['revision'] as int?,
      );
}

/// Capabilities advertised by the server via `/meta`, keyed by feature name.
/// Used to gate optional product sections behind server `ApiFeature` flags.
final serverCapabilitiesProvider =
    FutureProvider<Map<String, ServerCapability>>((ref) async {
      final client = ref.watch(solarNetworkClientProvider);
      final response = await client.dio.get<Map<String, dynamic>>(
        '/meta',
        options: Options(validateStatus: (_) => true),
      );
      final data = response.data;
      if (response.statusCode != 200 || data is! Map) return const {};
      final raw = data?['capabilities'] ?? {};
      if (raw is! Map) return const {};
      return {
        for (final entry in raw.entries)
          if (entry.key is String && entry.value is Map)
            entry.key as String: ServerCapability.fromJson(
              Map<String, dynamic>.from(entry.value as Map),
            ),
      };
    });

/// Whether [feature] is enabled according to the server capabilities.
///
/// While capabilities are still loading (null) the feature is assumed
/// available so gated sections don't flicker during startup.
bool serverFeatureEnabled(
  Map<String, ServerCapability>? capabilities,
  String feature,
) => capabilities == null || capabilities[feature]?.enabled == true;

enum ServerCompatibilityIssue {
  invalidMetadata,
  incomplete,
  serverTooOld,
  clientTooOld,
  missingCapability,
}

class ServerCompatibility {
  final ServerCompatibilityIssue? issue;
  final String? capability;

  const ServerCompatibility._({this.issue, this.capability});

  const ServerCompatibility.compatible() : this._();

  bool get isCompatible => issue == null;

  static ServerCompatibility fromMetadata(Map<String, dynamic> metadata) {
    final apiRevision = _readInt(metadata['api_revision']);
    final minimumRevision = _readInt(metadata['minimum_revision']);
    if (apiRevision == null || minimumRevision == null) {
      return const ServerCompatibility._(
        issue: ServerCompatibilityIssue.invalidMetadata,
      );
    }
    if (metadata['incomplete'] == true) {
      return const ServerCompatibility._(
        issue: ServerCompatibilityIssue.incomplete,
      );
    }
    if (apiRevision < kSupportedServerApiRevision) {
      return const ServerCompatibility._(
        issue: ServerCompatibilityIssue.serverTooOld,
      );
    }
    if (minimumRevision > kSupportedServerApiRevision) {
      return const ServerCompatibility._(
        issue: ServerCompatibilityIssue.clientTooOld,
      );
    }

    final capabilities = metadata['capabilities'];
    if (capabilities is! Map) {
      return const ServerCompatibility._(
        issue: ServerCompatibilityIssue.invalidMetadata,
      );
    }
    for (final capability in kRequiredServerCapabilities) {
      final value = capabilities[capability];
      final enabled = value is Map && value['enabled'] == true;
      final revision = value is Map ? _readInt(value['revision']) : null;
      if (!enabled || revision == null || revision < 1) {
        return ServerCompatibility._(
          issue: ServerCompatibilityIssue.missingCapability,
          capability: capability,
        );
      }
    }

    return const ServerCompatibility.compatible();
  }
}

int? _readInt(Object? value) => switch (value) {
  int value => value,
  num value => value.toInt(),
  _ => null,
};
