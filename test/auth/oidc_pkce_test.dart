import 'package:flutter_test/flutter_test.dart';
import 'package:island/auth/oidc_pkce.dart';

/// The console's `solian` client is a public client, so the only thing binding
/// an authorization code to this device is PKCE. These assertions mirror what
/// Stargate checks: an S256 challenge derived from a fresh verifier, a
/// verifier inside RFC 7636's 43–128 window, and a request the provider will
/// recognise (form-encoded exchange, no client secret).
void main() {
  test('challenge is the unpadded S256 digest of the verifier', () {
    final pkce = createPkceChallenge(
      verifier: 'dBjftJeZ4CVP-mB92K27uhbUJU1p1r_wW1gFWFOEjXk',
      state: 'fixed-state',
    );

    // Known answer from RFC 7636 appendix B.
    expect(pkce.challenge, 'E9Melhoa2OwvFrEMTJguCHaoeK1t8URWbuGJSstw-cM');
    expect(pkce.challenge, isNot(contains('=')));
    expect(pkce.state, 'fixed-state');
  });

  test('a fresh challenge stays inside the RFC 7636 verifier window', () {
    final first = createPkceChallenge();
    final second = createPkceChallenge();

    for (final pkce in [first, second]) {
      expect(pkce.verifier.length, inInclusiveRange(43, 128));
      expect(pkce.verifier, matches(RegExp(r'^[A-Za-z0-9\-._~]+$')));
      expect(pkce.state, isNotEmpty);
    }
    expect(first.verifier, isNot(second.verifier));
    expect(first.state, isNot(second.state));
  });

  test('authorization URL carries PKCE and omits nothing required', () {
    final pkce = createPkceChallenge(verifier: 'verifier', state: 'state-1');
    final url = buildAuthorizationUrl(
      pkce: pkce,
      redirectUri: 'http://127.0.0.1:53682/auth/callback',
      endpoint: Uri.parse('https://id.solian.app/auth/authorize'),
    );

    expect(url.host, 'id.solian.app');
    expect(url.queryParameters, {
      'response_type': 'code',
      'client_id': 'solian',
      'redirect_uri': 'http://127.0.0.1:53682/auth/callback',
      'scope': '*',
      'state': 'state-1',
      'code_challenge': pkce.challenge,
      'code_challenge_method': 'S256',
    });
  });

  test('token endpoint follows the configured gateway', () {
    expect(
      solianTokenEndpoint('https://api.solian.app').toString(),
      'https://api.solian.app/stargate/auth/open/token',
    );
    expect(
      solianTokenEndpoint('https://example.test/').toString(),
      'https://example.test/stargate/auth/open/token',
    );
  });
}
