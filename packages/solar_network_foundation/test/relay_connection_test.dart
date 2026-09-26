import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:solar_network_foundation/solar_network_foundation.dart';

/// Reads from [socket] until [needle] shows up or the peer closes.
Future<List<int>> _readUntil(Stream<List<int>> socket, String needle) async {
  final expected = ascii.encode(needle);
  final buffer = <int>[];
  await for (final chunk in socket) {
    buffer.addAll(chunk);
    if (_contains(buffer, expected)) break;
  }
  return buffer;
}

bool _contains(List<int> haystack, List<int> needle) {
  for (var start = 0; start + needle.length <= haystack.length; start++) {
    var matched = true;
    for (var offset = 0; offset < needle.length; offset++) {
      if (haystack[start + offset] != needle[offset]) {
        matched = false;
        break;
      }
    }
    if (matched) return true;
  }
  return false;
}

void main() {
  const relay = RelayRoute(
    id: 'jp-01',
    host: '127.0.0.1',
    port: 7443,
    region: 'jp',
  );

  group('resolveRelayDialTarget', () {
    test('routes TLS traffic for the server host through the relay', () {
      final target = resolveRelayDialTarget(
        uri: Uri.parse('https://api.solian.app/ws'),
        serverHost: 'api.solian.app',
        route: relay,
      );

      expect(target, const RelayDialTarget(host: '127.0.0.1', port: 7443));
    });

    test('matches the server host case-insensitively and trims it', () {
      final target = resolveRelayDialTarget(
        uri: Uri.parse('https://API.Solian.app/'),
        serverHost: '  api.solian.app  ',
        route: relay,
      );

      expect(target?.port, 7443);
    });

    test('never touches plain HTTP', () {
      expect(
        resolveRelayDialTarget(
          uri: Uri.parse('http://api.solian.app/'),
          serverHost: 'api.solian.app',
          route: relay,
        ),
        isNull,
      );
    });

    test('leaves a non-standard port direct', () {
      expect(
        resolveRelayDialTarget(
          uri: Uri.parse('https://api.solian.app:8443/'),
          serverHost: 'api.solian.app',
          route: relay,
        ),
        isNull,
      );
      expect(
        resolveRelayDialTarget(
          uri: Uri.parse('https://api.solian.app:443/'),
          serverHost: 'api.solian.app',
          route: relay,
        )?.port,
        7443,
      );
    });

    test('leaves other hosts and unconfigured routes direct', () {
      expect(
        resolveRelayDialTarget(
          uri: Uri.parse('https://cdn.example.com/'),
          serverHost: 'api.solian.app',
          route: relay,
        ),
        isNull,
      );
      expect(
        resolveRelayDialTarget(
          uri: Uri.parse('https://api.solian.app/'),
          serverHost: 'api.solian.app',
        ),
        isNull,
      );
      expect(
        resolveRelayDialTarget(
          uri: Uri.parse('https://api.solian.app/'),
          serverHost: 'api.solian.app',
          route: const RelayRoute(id: 'broken', host: '', port: 0),
        ),
        isNull,
      );
      expect(
        resolveRelayDialTarget(
          uri: Uri.parse('https://api.solian.app/'),
          serverHost: '   ',
          route: relay,
        ),
        isNull,
      );
    });
  });

  group('createRelayConnectionFactory', () {
    test('dials the relay while keeping the logical server as SNI', () async {
      final relayServer = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
      addTearDown(relayServer.close);
      final received = Completer<List<int>>();
      relayServer.listen((socket) async {
        final bytes = await _readUntil(socket, 'api.solian.app');
        if (!received.isCompleted) received.complete(bytes);
        await socket.close();
      });

      final factory = createRelayConnectionFactory(
        serverHost: 'api.solian.app',
        route: RelayRoute(
          id: 'local',
          host: relayServer.address.address,
          port: relayServer.port,
        ),
      );

      final task = await factory(
        Uri.parse('https://api.solian.app/ws'),
        null,
        null,
      );
      // The relay never answers the handshake in this test; the bytes it got
      // are the proof, so the socket result is discarded.
      task.socket.ignore();

      final clientHello = await received.future.timeout(
        const Duration(seconds: 5),
      );

      // A TLS ClientHello carrying the logical host as the server name.
      expect(clientHello.first, 0x16);
      expect(
        _contains(clientHello, ascii.encode('api.solian.app')),
        isTrue,
        reason: 'ClientHello must request the logical server, not the relay',
      );
    });

    test('delegates every other connection to the fallback', () async {
      final factory = createRelayConnectionFactory(
        serverHost: 'api.solian.app',
        route: relay,
        fallback: (uri, proxyHost, proxyPort) async =>
            throw StateError('fallback handled $uri'),
      );

      await expectLater(
        factory(Uri.parse('https://api.solian.app:8443/'), null, null),
        throwsStateError,
      );
      await expectLater(
        factory(Uri.parse('http://api.solian.app/'), null, null),
        throwsStateError,
      );
      await expectLater(
        factory(Uri.parse('https://other.example/'), null, null),
        throwsStateError,
      );
    });

    test('dials directly when no relay applies', () async {
      final direct = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
      addTearDown(direct.close);
      final accepted = Completer<int>();
      direct.listen((socket) => accepted.complete(socket.remotePort));

      final factory = createRelayConnectionFactory(serverHost: 'api.solian.app');
      final task = await factory(
        Uri.parse('http://127.0.0.1:${direct.port}/'),
        null,
        null,
      );
      final socket = await task.socket;
      addTearDown(socket.destroy);

      expect(await accepted.future, socket.port);
      expect(socket.remotePort, direct.port);
      expect(socket.remoteAddress.address, '127.0.0.1');
    });

    test('keeps a plain HTTP request off the relay', () async {
      final direct = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
      addTearDown(direct.close);
      final accepted = Completer<bool>();
      direct.listen((socket) => accepted.complete(true));

      // The relay port is closed: reaching it would fail the dial.
      final factory = createRelayConnectionFactory(
        serverHost: '127.0.0.1',
        route: const RelayRoute(id: 'closed', host: '127.0.0.1', port: 1),
      );
      final task = await factory(
        Uri.parse('http://127.0.0.1:${direct.port}/'),
        null,
        null,
      );
      final socket = await task.socket;
      addTearDown(socket.destroy);

      expect(await accepted.future, isTrue);
    });
  });

  group('ConnectionFactoryHttpOverrides', () {
    test('makes every client it creates dial through the factory', () async {
      final origin = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
      addTearDown(origin.close);
      origin.listen((socket) async {
        await socket.first;
        socket.write(
          'HTTP/1.1 200 OK\r\nContent-Length: 2\r\nConnection: close\r\n\r\nok',
        );
        await socket.flush();
        await socket.close();
      });

      final dialed = <String>[];
      final overrides = ConnectionFactoryHttpOverrides(
        connectionFactory: (uri, proxyHost, proxyPort) async {
          dialed.add('${uri.host}:${uri.port}');
          final connection = await Socket.connect(uri.host, uri.port);
          return ConnectionTask.fromSocket(Future.value(connection), () {});
        },
      );

      final client = overrides.createHttpClient(null);
      addTearDown(() => client.close(force: true));
      final request = await client.getUrl(
        Uri.parse('http://127.0.0.1:${origin.port}/probe'),
      );
      final response = await request.close();

      expect(dialed, ['127.0.0.1:${origin.port}']);
      expect(response.statusCode, 200);
      expect(await utf8.decodeStream(response), 'ok');
    });
  });
}
