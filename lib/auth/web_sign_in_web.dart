import 'device_code_sign_in.dart';
import 'oidc_pkce.dart';

/// Whether the console sign-in finishes inside this build.
///

/// Signs in through the console with RFC 8628's device grant.
///
/// A page cannot receive an OAuth redirect into itself — neither a custom
/// scheme nor a loopback listener is reachable from one — and the console's
/// `solian` client registers no web redirect URI. The device grant needs no
/// redirect at all, so it is the flow that works here: the code is approved in
/// any browser tab, and this page polls the token endpoint for the pair.
Future<OAuthTokenSet?> signInOverWeb({
  required String serverUrl,
  DeviceAuthorizationCallback? onDeviceCode,
  String? deviceId,
  String? deviceName,
}) async {
  return signInWithDeviceCode(
    serverUrl: serverUrl,
    onDeviceCode: onDeviceCode,
    deviceId: deviceId,
    deviceName: deviceName,
  );
}
