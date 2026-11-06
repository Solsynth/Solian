import 'package:island/core/session_cookie.dart';

import 'oidc_pkce.dart';

/// Whether the console sign-in finishes inside this build.
///
/// A browser cannot listen on loopback for the redirect, and the console's
/// `solian` client refuses a web redirect URI, so the web build signs in with
/// the cookie it shares with the console instead.
const bool kWebSignInReturnsToApp = false;

/// Leaves this tab for the console's sign-in page, which hands the person back
/// to the page they came from already signed in.
///
/// Returns null: the token pair is adopted from the shared cookie when this page
/// loads again, so there is nothing to hand back here.
Future<OAuthTokenSet?> signInOverWeb({required String serverUrl}) async {
  openSharedSignIn();
  return null;
}
