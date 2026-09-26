import 'dart:async';
import 'dart:io';

import 'package:logging/logging.dart';

import 'relay_catalog.dart';

/// Signature of `HttpClient.connectionFactory`.
///
/// A factory returns a connected [Socket] — TLS-wrapped for `https` — and the
/// HTTP layer takes it from there, which is what lets a client change the
/// socket it dials without touching the URL, SNI, or `Host` header.
typedef NetworkConnectionFactory =
    Future<ConnectionTask<Socket>> Function(
      Uri url,
      String? proxyHost,
      int? proxyPort,
    );

/// The socket destination a request resolves to.
class RelayDialTarget {
  final String host;
  final int port;

  const RelayDialTarget({required this.host, required this.port});

  @override
  bool operator ==(Object other) =>
      other is RelayDialTarget && other.host == host && other.port == port;

  @override
  int get hashCode => Object.hash(host, port);

  @override
  String toString() => '$host:$port';
}

/// Whether [uri] should be dialed through [route], and where.
///
/// Only TLS requests to [serverHost] are re-routed: everything else (other
/// hosts, plain HTTP, a different server configured by the user) must keep its
/// default path. The relay dials the origin its SNI rule points at, so a
/// request to a non-standard port cannot be preserved and stays direct.
/// Returns null when the request goes direct.
RelayDialTarget? resolveRelayDialTarget({
  required Uri uri,
  required String serverHost,
  RelayRoute? route,
}) {
  if (route == null || !route.isValid) return null;
  if (uri.scheme.toLowerCase() != 'https') return null;
  if (uri.port != 443) return null;
  final host = serverHost.trim().toLowerCase();
  if (host.isEmpty || uri.host.toLowerCase() != host) return null;
  return RelayDialTarget(host: route.host, port: route.port);
}

/// Builds a connection factory that dials [route] for traffic to [serverHost].
///
/// [fallback] handles every other connection — pass the factory already in use
/// (for example an IP-override factory) to compose behaviours; without one,
/// non-relay connections are dialed directly, exactly like the default client.
///
/// TLS is established after dialing with [Uri.host] as the server name, so the
/// relay sees the logical SNI and the certificate is verified against the real
/// server, not against the relay. Pass [allowUntrustedCertificate] only to keep
/// a client's existing "accept any certificate" posture.
NetworkConnectionFactory createRelayConnectionFactory({
  required String serverHost,
  RelayRoute? route,
  NetworkConnectionFactory? fallback,
  bool allowUntrustedCertificate = false,
}) {
  return (uri, proxyHost, proxyPort) async {
    final target = resolveRelayDialTarget(
      uri: uri,
      serverHost: serverHost,
      route: route,
    );
    if (target == null) {
      final next = fallback;
      if (next != null) return next(uri, proxyHost, proxyPort);
      return _openConnection(uri);
    }
    Logger.root.fine(
      '[relay] Routing ${uri.host}${uri.hasPort ? ':${uri.port}' : ''} '
      'through ${target.host}:${target.port}',
    );
    return _openConnection(
      uri,
      targetHost: target.host,
      targetPort: target.port,
      allowUntrustedCertificate: allowUntrustedCertificate,
    );
  };
}

/// Dials (and, for `https`, TLS-wraps) a connection for [uri].
///
/// The proxy arguments of `HttpClient.connectionFactory` are ignored, matching
/// the app-side override factories this is layered with.
Future<ConnectionTask<Socket>> _openConnection(
  Uri uri, {
  String? targetHost,
  int? targetPort,
  bool allowUntrustedCertificate = false,
}) async {
  final isTls = uri.scheme.toLowerCase() == 'https';
  final host = targetHost ?? uri.host;
  final port = targetPort ?? (uri.port != 0 ? uri.port : (isTls ? 443 : 80));

  final socketFuture = () async {
    final socket = await Socket.connect(host, port);
    if (!isTls) return socket;
    // `host: uri.host` keeps SNI and certificate verification on the logical
    // server, which is the whole point of an L4 relay.
    return SecureSocket.secure(
      socket,
      host: uri.host,
      onBadCertificate: allowUntrustedCertificate ? (_) => true : null,
    );
  }();

  return ConnectionTask.fromSocket(socketFuture, () {
    Logger.root.fine('[relay] Cancelled connection to $host:$port');
  });
}

/// [HttpOverrides] that installs a [connectionFactory] on every client.
///
/// Install once per route change:
/// ```dart
/// HttpOverrides.global = ConnectionFactoryHttpOverrides(
///   connectionFactory: createRelayConnectionFactory(
///     serverHost: Uri.parse(serverUrl).host,
///     route: route,
///   ),
/// );
/// ```
class ConnectionFactoryHttpOverrides extends HttpOverrides {
  final NetworkConnectionFactory? connectionFactory;

  ConnectionFactoryHttpOverrides({this.connectionFactory});

  @override
  HttpClient createHttpClient(SecurityContext? context) {
    final client = super.createHttpClient(context);
    final factory = connectionFactory;
    if (factory != null) {
      client.connectionFactory = factory;
    }
    return client;
  }
}
