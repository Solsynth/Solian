import 'dart:async';

import 'package:dio/browser.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web/web.dart' as web;

import 'package:island/core/network.dart';
import 'package:island/core/services/udid.dart';
import 'package:island/core/shared_sign_in_url.dart';

/// Opts a Dio client into the browser's cookie jar.
///
/// The browser only attaches cookies to a cross-origin request when the
/// request itself asks for credentials, and Dio's browser adapter defaults to
/// not asking. The API shares the registrable domain with the console but not
/// the origin, so every request that relies on the cookie — and only those —
/// needs this.
void enableSharedCookieCredentials(Dio dio) {
  dio.httpClientAdapter = BrowserHttpClientAdapter(withCredentials: true);
}

/// Adopts a session the console already signed in in this browser.
///
/// Runs before the app is built, so a person arriving from the shared login
/// page starts signed in instead of being asked for the credentials they just
/// typed. It is skipped while the stored pair still authenticates: that session
/// is this app's own, and adopting on every load would mint a new child session
/// each time.
Future<void> adoptSharedSession({
  required SharedPreferences prefs,
  required String serverUrl,
}) async {
  if (hasUsableStoredSession(prefs)) return;

  final client = Dio(
    BaseOptions(
      baseUrl: serverUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ),
  );
  enableSharedCookieCredentials(client);
  try {
    final response = await client.post<dynamic>(
      '/stargate/auth/login/session',
      data: {
        'device_id': await getUdid(),
        'device_name': await getDeviceName(),
        // model.ClientPlatformWeb, so the console's device list names it plainly.
        'platform': 1,
      },
    );
    final data = response.data;
    if (data is! Map) return;
    final token = data['token'];
    if (token is! String || token.isEmpty) return;
    await setToken(
      prefs,
      token,
      refreshToken: data['refresh_token'] as String?,
      expiresIn: (data['expires_in'] as num?)?.toInt(),
      refreshExpiresIn: (data['refresh_expires_in'] as num?)?.toInt(),
    );
  } on DioException {
    // 401 means no cookie, or one the server no longer honours: there is no
    // shared session to adopt and the login screen is correct. Any other
    // failure is equally harmless — the app keeps whatever it already has.
  } finally {
    client.close();
  }
}

/// Ends the shared session, not just this app's copy of it.
///
/// Stargate answers by revoking the session and clearing both cookies for the
/// whole cookie domain. Best-effort: the caller clears local state anyway, and
/// an unreachable server must not leave the person signed in on screen.
Future<void> clearSharedSession({
  required String serverUrl,
  String? token,
}) async {
  final client = Dio(
    BaseOptions(
      baseUrl: serverUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );
  enableSharedCookieCredentials(client);
  try {
    await client.post<dynamic>(
      '/stargate/auth/logout',
      options: Options(
        headers: {
          if (token != null && token.isNotEmpty)
            'Authorization': 'Bearer $token',
        },
      ),
    );
  } on DioException {
    // Ignored: see above.
  } finally {
    client.close();
  }
}

/// The shared sign-in page, pointed back at the page the person is on.
String sharedSignInUrl() => buildSharedSignInUrl(kSharedSignInPage, Uri.base);

/// Leaves this tab for the shared sign-in page.
///
/// The console hands the finished sign-in back to the address it was given, so
/// this page has to be the one that navigates away: a new tab would sign in
/// and have nowhere to return to.
void openSharedSignIn() {
  web.window.location.href = sharedSignInUrl();
}
