import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:solar_network_foundation/solar_network_foundation.dart';

/// Serves `body` with `status` on a fresh loopback port.
Future<HttpServer> _mockGateway(Object? body, int status) async {
  final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
  server.listen((request) async {
    request.response.statusCode = status;
    request.response.headers.contentType = ContentType.json;
    request.response.write(body is String ? body : jsonEncode(body));
    await request.response.close();
  });
  return server;
}

void main() {
  group('parseRelayCatalog', () {
    test('reads the gateway envelope and keeps field values', () {
      final entries = parseRelayCatalog({
        'relays': [
          {
            'id': 'jp-01',
            'endpoint': 'relay-jp.solian.app',
            'port': 443,
            'region': 'jp',
            'weight': 2,
            'healthy': true,
          },
        ],
      });

      expect(entries, hasLength(1));
      final entry = entries.single;
      expect(entry.id, 'jp-01');
      expect(entry.endpoint, 'relay-jp.solian.app');
      expect(entry.port, 443);
      expect(entry.region, 'jp');
      expect(entry.weight, 2);
      expect(entry.healthy, isTrue);
      expect(entry.displayEndpoint, 'relay-jp.solian.app');
    });

    test('orders healthy relays first, then by weight and id', () {
      final entries = parseRelayCatalog({
        'relays': [
          {'id': 'b', 'endpoint': 'b.example', 'port': 443, 'weight': 5, 'healthy': false},
          {'id': 'a', 'endpoint': 'a.example', 'port': 443, 'weight': 1, 'healthy': true},
          {'id': 'c', 'endpoint': 'c.example', 'port': 443, 'weight': 1, 'healthy': true},
          {'id': 'd', 'endpoint': 'd.example', 'port': 443, 'weight': 9, 'healthy': true},
        ],
      });

      expect(entries.map((entry) => entry.id), ['d', 'a', 'c', 'b']);
    });

    test('drops entries that cannot be dialed', () {
      final entries = parseRelayCatalog({
        'relays': [
          {'id': '', 'endpoint': 'x.example', 'port': 443, 'healthy': true},
          {'id': 'no-host', 'endpoint': '', 'port': 443, 'healthy': true},
          {'id': 'no-port', 'endpoint': 'y.example', 'port': 0, 'healthy': true},
          {'id': 'huge-port', 'endpoint': 'z.example', 'port': 70000, 'healthy': true},
          'not an object',
          {'id': 'ok', 'endpoint': 'ok.example', 'port': 8443, 'healthy': true},
        ],
      });

      expect(entries.map((entry) => entry.id), ['ok']);
      expect(entries.single.displayEndpoint, 'ok.example:8443');
    });

    test('accepts a bare list and rejects a payload without relays', () {
      expect(
        parseRelayCatalog([
          {'id': 'solo', 'endpoint': 'solo.example', 'port': 443},
        ]).single.id,
        'solo',
      );
      expect(() => parseRelayCatalog({'unexpected': true}), throwsA(isA<RelayCatalogException>()));
      expect(() => parseRelayCatalog(null), throwsA(isA<RelayCatalogException>()));
    });

    test('falls back for missing fields', () {
      final entry = parseRelayCatalog([
        {'id': 'bare', 'endpoint': 'bare.example', 'port': 443},
      ]).single;
      expect(entry.region, '');
      expect(entry.regionLabel, '—');
      expect(entry.weight, 1);
      expect(entry.healthy, isFalse);
    });
  });

  group('RelayRoute', () {
    test('round-trips through JSON and compares by dial target', () {
      const route = RelayRoute(id: 'jp-01', host: 'relay-jp.solian.app', port: 8443, region: 'jp');
      final decoded = RelayRoute.fromJson(jsonDecode(jsonEncode(route.toJson())) as Map<String, dynamic>);

      expect(decoded, route);
      expect(decoded.hashCode, route.hashCode);
      expect(decoded.isValid, isTrue);
      expect(decoded.displayHost, 'relay-jp.solian.app:8443');
      expect(
        const RelayRoute(id: 'jp-01', host: 'relay-jp.solian.app', port: 443).displayHost,
        'relay-jp.solian.app',
      );
    });

    test('flags unusable routes', () {
      expect(const RelayRoute(id: '', host: 'a.example', port: 443).isValid, isFalse);
      expect(const RelayRoute(id: 'a', host: '', port: 443).isValid, isFalse);
      expect(const RelayRoute(id: 'a', host: 'a.example', port: 0).isValid, isFalse);
      expect(RelayRoute.fromEntry(
        const RelayEntry(id: 'a', endpoint: 'a.example', port: 443, region: 'eu'),
      ).region, 'eu');
    });
  });

  group('fetchRelayCatalog', () {
    test('parses a live gateway response', () async {
      final server = await _mockGateway({
        'relays': [
          {'id': 'eu-01', 'endpoint': 'relay-eu.solian.app', 'port': 443, 'region': 'eu', 'healthy': true},
        ],
      }, 200);
      addTearDown(server.close);

      final entries = await fetchRelayCatalog('http://127.0.0.1:${server.port}');

      expect(entries.single.id, 'eu-01');
      expect(entries.single.region, 'eu');
    });

    test('surfaces gateway errors with the server message', () async {
      final server = await _mockGateway(
        {'error': 'service discovery is disabled'},
        503,
      );
      addTearDown(server.close);

      await expectLater(
        fetchRelayCatalog('http://127.0.0.1:${server.port}'),
        throwsA(
          isA<RelayCatalogException>()
              .having((error) => error.statusCode, 'statusCode', 503)
              .having((error) => error.message, 'message', 'service discovery is disabled'),
        ),
      );
    });

    test('distinguishes a gateway without a relay catalog', () async {
      final server = await _mockGateway({'error': 'not found'}, 404);
      addTearDown(server.close);

      await expectLater(
        fetchRelayCatalog('http://127.0.0.1:${server.port}'),
        throwsA(
          isA<RelayCatalogException>().having(
            (error) => error.statusCode,
            'statusCode',
            404,
          ),
        ),
      );
    });

    test('rejects an unconfigured server address', () async {
      await expectLater(
        fetchRelayCatalog('  '),
        throwsA(isA<RelayCatalogException>()),
      );
    });

    test('stays reachable while a connection factory is installed', () async {
      final server = await _mockGateway({
        'relays': [
          {'id': 'jp-01', 'endpoint': 'relay-jp.solian.app', 'port': 443, 'healthy': true},
        ],
      }, 200);
      addTearDown(server.close);

      HttpOverrides.global = ConnectionFactoryHttpOverrides(
        connectionFactory: (uri, proxyHost, proxyPort) async =>
            throw StateError('relay route must not carry the catalog'),
      );
      addTearDown(() => HttpOverrides.global = null);

      final entries = await fetchRelayCatalog('http://127.0.0.1:${server.port}');
      expect(entries.single.id, 'jp-01');
    });
  });
}
