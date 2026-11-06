import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'oidc_pkce.dart';

/// Whether the console sign-in finishes inside this build.
///
/// A native build holds the PKCE verifier and receives the authorization code
/// itself, so it comes back with a token pair. A browser cannot listen for a
/// redirect on loopback, so the web build leaves for the console instead.
const bool kWebSignInReturnsToApp = true;

/// First loopback port tried for the callback.
///
/// Loopback redirects are port-agnostic per RFC 8252 §7.3, so any free port is
/// acceptable; a stable default only makes the address recognisable in logs.
const int kWebSignInDefaultPort = 53682;

/// Path the loopback listener answers on.
const String kWebSignInCallbackPath = '/auth/callback';

/// How long the browser is given to come back before the attempt is abandoned.
const Duration kWebSignInTimeout = Duration(minutes: 5);

/// Signs in through the console in the system browser.
///
/// The console owns every identity provider now, so this app asks it for one
/// authorization code instead of rendering each provider itself. The code is
/// bound to this device by PKCE: only the challenge travels in the browser, and
/// the verifier never leaves this process.
///
/// The code arrives on a loopback listener rather than a `solian://` custom
/// scheme — the console's `solian` client answers native apps on
/// `http://127.0.0.1:<port>/auth/callback` and refuses a custom scheme.
Future<OAuthTokenSet?> signInOverWeb({required String serverUrl}) async {
  final server = await bindLoopbackServer();
  final redirectUri =
      'http://${server.address.address}:${server.port}$kWebSignInCallbackPath';
  final pkce = createPkceChallenge();

  try {
    final code = awaitLoopbackCallback(server, pkce.state);

    final launched = await launchUrlString(
      buildAuthorizationUrl(pkce: pkce, redirectUri: redirectUri).toString(),
      mode: LaunchMode.externalApplication,
    );
    if (!launched) {
      // Nothing will ever answer on this listener now, so the pending callback
      // is abandoned explicitly: an unawaited future that later timed out would
      // surface as an uncaught error long after this attempt ended.
      code.ignore();
      throw WebSignInException('failedToLaunchBrowser'.tr());
    }

    final authorizationCode = await code;
    final dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {'Accept': 'application/json'},
      ),
    );
    try {
      return await exchangeAuthorizationCode(
        dio: dio,
        tokenEndpoint: solianTokenEndpoint(serverUrl),
        code: authorizationCode,
        redirectUri: redirectUri,
        verifier: pkce.verifier,
      );
    } finally {
      dio.close();
    }
  } on TimeoutException {
    throw WebSignInException('signInOverWebTimedOut'.tr());
  } finally {
    // A finished callback, a refusal or a timeout all end the attempt: the
    // listener never outlives the request that opened it.
    await server.close(force: true);
  }
}

/// Binds the first free port in [kWebSignInDefaultPort]'s neighbourhood.
///
/// Public so the loopback leg can be driven without a browser.
Future<HttpServer> bindLoopbackServer() async {
  Object? lastError;
  for (var offset = 0; offset < 10; offset++) {
    final port = kWebSignInDefaultPort + offset;
    try {
      return await HttpServer.bind(InternetAddress.loopbackIPv4, port);
    } on SocketException catch (err) {
      lastError = err;
    }
  }
  throw WebSignInException(
    'signInOverWebUnavailable'.tr(args: ['$lastError']),
  );
}

/// Answers the browser's redirect and completes with the authorization code.
///
/// Only a request carrying the matching `state` is accepted: anything else — a
/// stray favicon request, a replayed link, a response for another attempt — is
/// answered and ignored, so a forged callback cannot finish the sign-in.
Future<String> awaitLoopbackCallback(HttpServer server, String state) {
  final completer = Completer<String>();
  server.listen((request) {
    if (request.uri.path != kWebSignInCallbackPath) {
      _respond(request, 'Not found', status: HttpStatus.notFound);
      return;
    }

    final query = request.uri.queryParameters;
    final error = query['error'];
    final code = query['code'];

    if (query['state'] != state) {
      _respond(request, 'The response did not belong to this sign-in.');
      return;
    }
    if (error != null) {
      final description = query['error_description'] ?? error;
      _respond(request, description);
      if (!completer.isCompleted) {
        completer.completeError(WebSignInException(description));
      }
      return;
    }
    if (code == null || code.isEmpty) {
      _respond(request, 'The console returned no authorization code.');
      return;
    }

    _respond(request, 'You can close this window and return to Solian.');
    if (!completer.isCompleted) completer.complete(code);
  });
  return completer.future.timeout(kWebSignInTimeout);
}

/// Escapes text before it is written into the callback page. The message can
/// carry the provider's `error_description`, which is remote input.
String _escapeHtml(String value) => value
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;');

void _respond(HttpRequest request, String message, {int status = 200}) {
  final response = request.response
    ..statusCode = status
    ..headers.contentType = ContentType.html
    ..write(
      '<!doctype html><meta charset="utf-8">'
      '<title>Solian</title>'
      '<body style="font-family: system-ui, sans-serif; margin: 3rem;">'
      '<p>${_escapeHtml(message)}</p></body>',
    );
  unawaited(response.close());
}
