import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:island/auth/web_sign_in_native.dart';

/// Drives the loopback leg of the console sign-in without a browser: the test
/// plays the console's redirect, so the parts that could silently break — which
/// path and state are accepted, that a forged callback cannot finish the
/// sign-in, and that the page is readable — are exercised for real.
void main() {
  Future<HttpClientResponse> send(int port, String pathAndQuery) async {
    final client = HttpClient();
    try {
      final request = await client.getUrl(
        Uri.parse('http://127.0.0.1:$port$pathAndQuery'),
      );
      return await request.close();
    } finally {
      client.close(force: false);
    }
  }

  Future<String> bodyOf(HttpClientResponse response) =>
      response.transform(const SystemEncoding().decoder).join();

  test('a matching state completes with the code', () async {
    final server = await bindLoopbackServer();
    addTearDown(() => server.close(force: true));

    final code = awaitLoopbackCallback(server, 'expected-state');
    final response = await send(
      server.port,
      '$kWebSignInCallbackPath?code=auth-code-1&state=expected-state',
    );
    final body = await bodyOf(response);

    expect(response.statusCode, HttpStatus.ok);
    expect(body, contains('close this window'));
    await expectLater(code, completion('auth-code-1'));
  });

  test('a forged state is refused and does not finish the sign-in', () async {
    final server = await bindLoopbackServer();
    addTearDown(() => server.close(force: true));

    var completed = false;
    final code = awaitLoopbackCallback(server, 'expected-state')
      ..then((_) => completed = true, onError: (_) => completed = true);

    final forged = await send(
      server.port,
      '$kWebSignInCallbackPath?code=attacker&state=wrong-state',
    );
    expect(await bodyOf(forged), contains('did not belong'));

    final accepted = await send(
      server.port,
      '$kWebSignInCallbackPath?code=real-code&state=expected-state',
    );
    expect(await bodyOf(accepted), contains('close this window'));

    await expectLater(code, completion('real-code'));
    expect(completed, isTrue);
  });

  test('a provider error ends the attempt with its description', () async {
    final server = await bindLoopbackServer();
    addTearDown(() => server.close(force: true));

    final failure = expectLater(
      awaitLoopbackCallback(server, 'expected-state'),
      throwsA(isA<Exception>()),
    );
    final response = await send(
      server.port,
      '$kWebSignInCallbackPath'
      '?error=access_denied&error_description=Refused&state=expected-state',
    );
    expect(await bodyOf(response), contains('Refused'));
    await failure;
  });

  test('an unrelated path is a 404, not a sign-in', () async {
    final server = await bindLoopbackServer();
    addTearDown(() => server.close(force: true));

    // The listener is what answers, so it has to be installed even though this
    // request must not complete a sign-in.
    unawaited(awaitLoopbackCallback(server, 'expected-state'));

    final response = await send(server.port, '/favicon.ico');
    expect(response.statusCode, HttpStatus.notFound);
  });

  test('the flow binds a real loopback port it can name', () async {
    final server = await bindLoopbackServer();
    addTearDown(() => server.close(force: true));

    expect(server.address.address, '127.0.0.1');
    expect(server.port, greaterThan(1024));
    expect(kWebSignInCallbackPath, '/auth/callback');
    expect(kWebSignInReturnsToApp, isTrue);
  });
}
