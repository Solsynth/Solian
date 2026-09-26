import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:logging/logging.dart';

/// Gateway path listing the relays announced by the master node.
///
/// `GET <server>/relays` → `{"relays":[{"id","endpoint","port","region","weight","healthy"}]}`.
/// Blade serves it from its Redis-backed service registry; any gateway that
/// exposes the same contract works.
const kRelayCatalogPath = '/relays';

/// A relay PoP announced by the master, as returned by [kRelayCatalogPath].
///
/// A relay copies TCP bytes to an origin and never terminates TLS, so a client
/// keeps its SNI, `Host` header, and certificate identity and only changes the
/// socket it dials. See `relay_connection.dart` for the dial side.
class RelayEntry {
  /// Instance id, unique per service in the master's registry.
  final String id;

  /// Host clients dial to reach the relay.
  final String endpoint;

  /// TCP port the relay listens on (443 in production).
  final int port;

  /// Region label used to group relays in a picker. May be empty.
  final String region;

  /// Relative preference among relays of the same service.
  final int weight;

  /// Whether the master's health probe currently reaches the relay.
  final bool healthy;

  const RelayEntry({
    required this.id,
    required this.endpoint,
    required this.port,
    this.region = '',
    this.weight = 1,
    this.healthy = false,
  });

  factory RelayEntry.fromJson(Map<String, dynamic> json) => RelayEntry(
    id: (json['id'] as String?)?.trim() ?? '',
    endpoint: (json['endpoint'] as String?)?.trim() ?? '',
    port: (json['port'] as num?)?.toInt() ?? 0,
    region: (json['region'] as String?)?.trim() ?? '',
    weight: (json['weight'] as num?)?.toInt() ?? 1,
    healthy: json['healthy'] as bool? ?? false,
  );

  /// Whether the entry carries enough information to dial it.
  bool get isDialable =>
      id.isNotEmpty && endpoint.isNotEmpty && port > 0 && port <= 65535;

  /// Region label with a placeholder so a picker never renders a blank row.
  String get regionLabel => region.isEmpty ? '—' : region;

  /// `endpoint:port`, with the port elided for the well-known TLS port.
  String get displayEndpoint => port == 443 ? endpoint : '$endpoint:$port';

  @override
  String toString() =>
      'RelayEntry($id, $displayEndpoint, region: $regionLabel, '
      'weight: $weight, healthy: $healthy)';
}

/// The relay a client routes its traffic through.
///
/// Only the dial target is stored: the logical server host — and therefore the
/// SNI, `Host` header, and certificate verification — is untouched.
class RelayRoute {
  /// Id of the [RelayEntry] this route was created from.
  final String id;

  /// Host to dial instead of the server host.
  final String host;

  /// Port to dial instead of the server port.
  final int port;

  /// Region label of the relay, kept for display. May be empty.
  final String region;

  const RelayRoute({
    required this.id,
    required this.host,
    required this.port,
    this.region = '',
  });

  factory RelayRoute.fromEntry(RelayEntry entry) => RelayRoute(
    id: entry.id,
    host: entry.endpoint,
    port: entry.port,
    region: entry.region,
  );

  factory RelayRoute.fromJson(Map<String, dynamic> json) => RelayRoute(
    id: (json['id'] as String?)?.trim() ?? '',
    host: (json['host'] as String?)?.trim() ?? '',
    port: (json['port'] as num?)?.toInt() ?? 0,
    region: (json['region'] as String?)?.trim() ?? '',
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'host': host,
    'port': port,
    'region': region,
  };

  /// Whether the route can be dialed.
  bool get isValid => id.isNotEmpty && host.isNotEmpty && port > 0;

  /// Region label with a placeholder so a picker never renders a blank row.
  String get regionLabel => region.isEmpty ? '—' : region;

  /// `host:port`, with the port elided for the well-known TLS port.
  String get displayHost => port == 443 ? host : '$host:$port';

  @override
  bool operator ==(Object other) =>
      other is RelayRoute &&
      other.id == id &&
      other.host == host &&
      other.port == port;

  @override
  int get hashCode => Object.hash(id, host, port);

  @override
  String toString() => 'RelayRoute($id, $displayHost)';
}

/// Raised when the relay catalog cannot be read. [message] is safe to show.
class RelayCatalogException implements Exception {
  final String message;
  final int? statusCode;

  RelayCatalogException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

/// Parses a [kRelayCatalogPath] body, dropping entries that cannot be dialed.
///
/// Accepts either the envelope (`{"relays": [...]}`) or a bare list. Entries are
/// sorted healthy-first, then by descending weight, then by id, so a picker
/// shows the most useful relays first.
List<RelayEntry> parseRelayCatalog(Object? decoded) {
  final raw = decoded is Map ? decoded['relays'] : decoded;
  if (raw is! List) {
    throw RelayCatalogException('Unexpected relay catalog payload');
  }
  final entries = <RelayEntry>[];
  for (final item in raw) {
    if (item is! Map) continue;
    final entry = RelayEntry.fromJson(Map<String, dynamic>.from(item));
    if (entry.isDialable) {
      entries.add(entry);
    } else {
      Logger.root.fine('[relay] Skipping undialable catalog entry: $item');
    }
  }
  entries.sort((a, b) {
    if (a.healthy != b.healthy) return a.healthy ? -1 : 1;
    final byWeight = b.weight.compareTo(a.weight);
    return byWeight != 0 ? byWeight : a.id.compareTo(b.id);
  });
  return entries;
}

/// Reads the relay catalog from [serverUrl].
///
/// The request deliberately bypasses [HttpOverrides] so a selected relay can
/// never make its own picker unreachable — the catalog also has to load while a
/// relay is down, to let the user switch away from it.
///
/// Throws [RelayCatalogException] with a message safe to display.
Future<List<RelayEntry>> fetchRelayCatalog(String serverUrl) async {
  final normalized = serverUrl.trim();
  if (normalized.isEmpty) {
    throw RelayCatalogException('Server address is not configured');
  }
  Logger.root.fine('[relay] Fetching relay catalog from $normalized');

  final response = await HttpOverrides.runWithHttpOverrides(
    () => Dio(
      BaseOptions(
        baseUrl: normalized,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {'Accept': 'application/json'},
        validateStatus: (_) => true,
      ),
    ).get<dynamic>(kRelayCatalogPath),
    _DirectHttpOverrides(),
  );

  final status = response.statusCode ?? 0;
  if (status == 404) {
    throw RelayCatalogException(
      'This server does not announce relays',
      statusCode: status,
    );
  }
  if (status == 502 || status == 503) {
    throw RelayCatalogException(
      _serverError(response.data) ?? 'The relay catalog is unavailable',
      statusCode: status,
    );
  }
  if (status < 200 || status >= 300) {
    throw RelayCatalogException(
      'The relay catalog request failed (HTTP $status)',
      statusCode: status,
    );
  }

  final entries = parseRelayCatalog(response.data);
  Logger.root.info('[relay] Relay catalog holds ${entries.length} entry(ies)');
  return entries;
}

/// [HttpOverrides] that keeps [HttpClient]s out of any connection factory.
class _DirectHttpOverrides extends HttpOverrides {}

String? _serverError(Object? body) {
  if (body is Map) {
    final error = body['error'];
    if (error is String && error.trim().isNotEmpty) return error.trim();
  }
  if (body is String) {
    try {
      return _serverError(jsonDecode(body));
    } catch (_) {
      return null;
    }
  }
  return null;
}
