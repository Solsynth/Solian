import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';

import 'oidc_pkce.dart';

/// What a device-code sign-in is waiting on: the code to approve in the
/// console, and the pages that take it.
///
/// [verificationUriComplete] already carries the code, so opening it saves
/// typing it; [verificationUri] is the bare page for anyone who has to enter
/// the code by hand.
class DeviceAuthorization {
  const DeviceAuthorization({
    required this.deviceCode,
    required this.userCode,
    required this.verificationUri,
    required this.verificationUriComplete,
    required this.expiresAt,
    required this.interval,
  });

  /// The opaque code the token endpoint redeems. Never shown to the user.
  final String deviceCode;

  /// The short code the user types into the console.
  final String userCode;

  final Uri verificationUri;
  final Uri verificationUriComplete;
  final DateTime expiresAt;

  /// How often the provider wants the token endpoint polled.
  final Duration interval;

  Duration get remaining {
    final left = expiresAt.difference(DateTime.now());
    return left.isNegative ? Duration.zero : left;
  }
}

/// Runs while the user approves the code, and completes with the token pair
/// once they do.
///
/// The callback fires once with the code. It may run after the caller stopped
/// showing it — approval runs to its own end — so it must tolerate a dismissed
/// dialog.
typedef DeviceAuthorizationCallback =
    void Function(DeviceAuthorization request);

/// How long the provider is given to approve a device code.
///
/// The provider issues a 10-minute code; this only bounds the local wait so a
/// stalled approval cannot hold the caller forever.
const Duration kDeviceSignInTimeout = Duration(minutes: 10);

/// RFC 8628's grant type for redeeming a device code.
const String kDeviceCodeGrantType =
    'urn:ietf:params:oauth:grant-type:device_code';

/// Signs in with RFC 8628's device grant: ask the provider for a code, hand it
/// to [onDeviceCode] for the user to approve in any browser, then poll the
/// token endpoint until they have.
///
/// This is the browser build's flow. A page cannot receive an OAuth redirect
/// into itself — neither a custom scheme nor a loopback listener is reachable
/// from one — and the console's `solian` client registers no web redirect URI.
/// The device grant needs no redirect at all, so it is the flow that finishes
/// there; it also works behind any proxy, being plain form posts.
Future<OAuthTokenSet> signInWithDeviceCode({
  required String serverUrl,
  DeviceAuthorizationCallback? onDeviceCode,
  String? deviceId,
  String? deviceName,
  int? platform,
}) async {
  final dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
    ),
  );
  try {
    final request = await requestDeviceAuthorization(
      dio: dio,
      endpoint: solianDeviceAuthorizationEndpoint(serverUrl),
      deviceId: deviceId,
      deviceName: deviceName,
      platform: platform,
    );
    onDeviceCode?.call(request);
    return await awaitDeviceApproval(
      dio: dio,
      tokenEndpoint: solianTokenEndpoint(serverUrl),
      request: request,
    );
  } finally {
    dio.close();
  }
}

/// Asks the provider for a device code.
Future<DeviceAuthorization> requestDeviceAuthorization({
  required Dio dio,
  required Uri endpoint,
  String clientId = kSolianOAuthClientId,
  String scope = kSolianOAuthScope,
  String? deviceId,
  String? deviceName,
  int? platform,
}) async {
  final response = await dio.post<dynamic>(
    endpoint.toString(),
    data: {
      'client_id': clientId,
      'scope': scope,
      if (deviceId != null && deviceId.isNotEmpty) 'device_id': deviceId,
      if (deviceName != null && deviceName.isNotEmpty)
        'device_name': deviceName,
      if (platform != null) 'platform': platform.toString(),
    },
    options: Options(
      contentType: Headers.formUrlEncodedContentType,
      responseType: ResponseType.json,
    ),
  );

  final data = response.data;
  if (data is! Map) {
    throw WebSignInException('signInOverWebDeviceCodeFailed'.tr());
  }
  final deviceCode = data['device_code'] as String?;
  final userCode = data['user_code'] as String?;
  final verificationUri = Uri.tryParse(
    data['verification_uri']?.toString() ?? '',
  );
  if (deviceCode == null ||
      deviceCode.isEmpty ||
      userCode == null ||
      userCode.isEmpty ||
      verificationUri == null ||
      !verificationUri.hasScheme) {
    throw WebSignInException('signInOverWebDeviceCodeFailed'.tr());
  }

  final complete = Uri.tryParse(
    data['verification_uri_complete']?.toString() ?? '',
  );
  return DeviceAuthorization(
    deviceCode: deviceCode,
    userCode: userCode,
    verificationUri: verificationUri,
    verificationUriComplete: complete != null && complete.hasScheme
        ? complete
        : verificationUri,
    expiresAt: DateTime.now().add(
      Duration(seconds: (data['expires_in'] as num?)?.toInt() ?? 600),
    ),
    interval: Duration(seconds: (data['interval'] as num?)?.toInt() ?? 5),
  );
}

/// Polls the token endpoint until the code is approved, declined or expired.
///
/// `slow_down` means the provider wants the next poll further out, so the wait
/// grows; the other answers are final. `authorization_pending` is the normal
/// "not approved yet" and simply loops.
Future<OAuthTokenSet> awaitDeviceApproval({
  required Dio dio,
  required Uri tokenEndpoint,
  required DeviceAuthorization request,
  Duration timeout = kDeviceSignInTimeout,
  String clientId = kSolianOAuthClientId,
}) async {
  var wait = request.interval;
  final deadline = DateTime.now().add(timeout);

  while (DateTime.now().isBefore(deadline)) {
    final left = request.remaining;
    final pause = wait < left ? wait : left;
    if (pause > Duration.zero) await Future<void>.delayed(pause);

    final response = await dio.post<dynamic>(
      tokenEndpoint.toString(),
      data: {
        'grant_type': kDeviceCodeGrantType,
        'device_code': request.deviceCode,
        'client_id': clientId,
      },
      options: Options(
        contentType: Headers.formUrlEncodedContentType,
        responseType: ResponseType.json,
        // The "not yet" answers arrive as 400 and are part of the flow.
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    final status = response.statusCode ?? 0;
    final body = response.data;
    if (status >= 200 && status < 300) {
      return oauthTokenSetFromJson(body);
    }

    final error = body is Map ? body['error']?.toString() : null;
    switch (error) {
      case 'authorization_pending':
        continue;
      case 'slow_down':
        wait += const Duration(seconds: 5);
        continue;
      case 'expired_token':
        throw WebSignInException('signInOverWebDeviceCodeExpired'.tr());
      case 'access_denied':
        throw WebSignInException('signInOverWebDeviceCodeDeclined'.tr());
      default:
        throw WebSignInException(_deviceFlowFailure(body, status));
    }
  }

  throw WebSignInException('signInOverWebDeviceCodeExpired'.tr());
}

String _deviceFlowFailure(Object? body, int status) {
  if (body is Map) {
    final detail =
        body['error_description'] ?? body['detail'] ?? body['message'];
    if (detail != null && detail.toString().isNotEmpty) {
      return detail.toString();
    }
  }
  return 'signInOverWebDeviceCodeFailed'.tr(args: ['$status']);
}
