import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';

/// Public OAuth client this app signs in as.
///
/// Stargate registers it on the identity console, so the social sign-in
/// buttons this app used to carry are no longer needed: the console owns the
/// providers and answers here with a plain authorization code.
const String kSolianOAuthClientId = 'solian';

/// The scope Stargate's `solian` client allows. It is a first-party client, so
/// it asks for everything with `*`; `openid`, `profile` and `email` are refused
/// for it even though the provider advertises them.
const String kSolianOAuthScope = '*';

/// Where the console sends a person to approve this app.
///
/// It is a different origin from the API, so it cannot be derived from the
/// configured server. A self-hosted pair points it elsewhere at build time:
/// `--dart-define=SOLIAN_AUTHORIZATION_ENDPOINT=https://id.example.com/auth/authorize`.
const String kSolianAuthorizationEndpoint = String.fromEnvironment(
  'SOLIAN_AUTHORIZATION_ENDPOINT',
  defaultValue: 'https://id.solian.app/auth/authorize',
);

/// The provider's token endpoint on the configured gateway.
///
/// A configured server may carry a trailing slash; the endpoint is appended, so
/// it is trimmed first rather than producing a doubled separator.
Uri solianTokenEndpoint(String serverUrl) {
  final base = serverUrl.endsWith('/')
      ? serverUrl.substring(0, serverUrl.length - 1)
      : serverUrl;
  return Uri.parse('$base/stargate/auth/open/token');
}

/// An authorization request's PKCE material plus the CSRF `state` that ties a
/// response back to this request.
class PkceChallenge {
  const PkceChallenge({
    required this.verifier,
    required this.challenge,
    required this.state,
  });

  /// The secret kept on this device until the code is exchanged.
  final String verifier;

  /// S256 of [verifier]; the only copy that travels in the browser.
  final String challenge;

  /// Echoed by the provider, so an unsolicited callback is refused.
  final String state;
}

/// A failure of the browser leg: refused launch, wrong state, a provider error,
/// or no callback before the deadline.
class WebSignInException implements Exception {
  const WebSignInException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// A finished browser leg: the code, and the redirect URI it was issued for.
class AuthorizationCodeResult {
  const AuthorizationCodeResult({
    required this.code,
    required this.redirectUri,
    required this.pkce,
  });

  final String code;
  final String redirectUri;
  final PkceChallenge pkce;
}

/// The token pair a code exchange yields.
class OAuthTokenSet {
  const OAuthTokenSet({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
  });

  final String accessToken;
  final String? refreshToken;

  /// Lifetime of [accessToken] in seconds.
  final int? expiresIn;
}

String _randomUrlSafe(int bytes) {
  final random = Random.secure();
  return base64Url
      .encode(List<int>.generate(bytes, (_) => random.nextInt(256)))
      .replaceAll('=', '');
}

/// Builds a fresh verifier/challenge pair and a CSRF `state`.
///
/// The verifier is 64 characters of the unreserved alphabet, inside RFC 7636's
/// 43–128 window; the challenge is its unpadded base64url S256 digest.
PkceChallenge createPkceChallenge({String? verifier, String? state}) {
  final codeVerifier = verifier ?? _randomUrlSafe(48);
  return PkceChallenge(
    verifier: codeVerifier,
    challenge: base64Url
        .encode(sha256.convert(utf8.encode(codeVerifier)).bytes)
        .replaceAll('=', ''),
    state: state ?? _randomUrlSafe(24),
  );
}

/// The address the browser opens.
///
/// Nullable values are omitted rather than sent empty: the provider treats a
/// present-but-empty `redirect_uri` differently from an absent one.
Uri buildAuthorizationUrl({
  required PkceChallenge pkce,
  required String redirectUri,
  String clientId = kSolianOAuthClientId,
  String scope = kSolianOAuthScope,
  Uri? endpoint,
}) {
  return (endpoint ?? Uri.parse(kSolianAuthorizationEndpoint)).replace(
    queryParameters: {
      'response_type': 'code',
      'client_id': clientId,
      'redirect_uri': redirectUri,
      'scope': scope,
      'state': pkce.state,
      'code_challenge': pkce.challenge,
      'code_challenge_method': 'S256',
    },
  );
}

/// Trades an authorization code for a token pair.
///
/// The provider reads this as a form (`c.PostForm`), so the body is
/// form-urlencoded, not JSON. Public clients authenticate with the verifier
/// alone; no client secret is sent.
Future<OAuthTokenSet> exchangeAuthorizationCode({
  required Dio dio,
  required Uri tokenEndpoint,
  required String code,
  required String redirectUri,
  required String verifier,
  String clientId = kSolianOAuthClientId,
}) async {
  final response = await dio.post<dynamic>(
    tokenEndpoint.toString(),
    data: {
      'grant_type': 'authorization_code',
      'client_id': clientId,
      'code': code,
      'redirect_uri': redirectUri,
      'code_verifier': verifier,
    },
    options: Options(
      contentType: Headers.formUrlEncodedContentType,
      responseType: ResponseType.json,
    ),
  );

  final data = response.data;
  if (data is! Map) {
    throw const WebSignInException('The provider returned no token.');
  }
  final accessToken = data['access_token'];
  if (accessToken is! String || accessToken.isEmpty) {
    throw const WebSignInException('The provider returned no token.');
  }
  final refreshToken = data['refresh_token'];
  return OAuthTokenSet(
    accessToken: accessToken,
    refreshToken: refreshToken is String && refreshToken.isNotEmpty
        ? refreshToken
        : null,
    expiresIn: (data['expires_in'] as num?)?.toInt(),
  );
}
