import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// No-op: a native client has no browser cookie jar to opt into.
void enableSharedCookieCredentials(Dio dio) {}

/// No-op: there is no shared session to adopt outside the browser.
Future<void> adoptSharedSession({
  required SharedPreferences prefs,
  required String serverUrl,
}) async {}

/// No-op: logout on a native build clears its own store only.
Future<void> clearSharedSession({
  required String serverUrl,
  String? token,
}) async {}

/// No-op: there is no shared sign-in page outside the browser.
String sharedSignInUrl() => '';

/// No-op: the browser is the only thing that can be sent there.
void openSharedSignIn() {}
