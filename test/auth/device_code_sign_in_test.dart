import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:island/auth/device_code_sign_in.dart';

/// The grant the web build signs in with. These assertions mirror what Stargate
/// checks: the request posts form data, the code is approved out of band, the
/// two "not yet" answers are part of the flow rather than failures, and the
/// token pair is read from `access_token`.
void main() {
  /// Answers a scripted sequence of token responses and records the bodies.
  final requests = <Map<String, dynamic>>[];

  HttpClientAdapter scripted(List<(int, Object)> responses) {
    var index = 0;
    return _ScriptedAdapter((options) {
      requests.add(Map<String, dynamic>.from(options.data as Map));
      final (status, body) = responses[index.clamp(0, responses.length - 1)];
      index++;
      return ResponseBody.fromString(
        jsonEncode(body),
        status,
        headers: {
          Headers.contentTypeHeader: ['application/json'],
        },
      );
    });
  }

  setUp(requests.clear);

  test('an approved code yields the token pair', () async {
    final dio = Dio()
      ..httpClientAdapter = scripted([
        (
          200,
          {
            'access_token': 'access-1',
            'refresh_token': 'refresh-1',
            'expires_in': 3600,
          },
        ),
      ]);

    final tokens = await awaitDeviceApproval(
      dio: dio,
      tokenEndpoint: Uri.parse('https://api.test/stargate/auth/open/token'),
      request: DeviceAuthorization(
        deviceCode: 'device-code-1',
        userCode: 'ABCD-EFGH',
        verificationUri: Uri.parse('https://id.test/auth/device'),
        verificationUriComplete: Uri.parse(
          'https://id.test/auth/device?code=ABCD-EFGH',
        ),
        expiresAt: DateTime.now().add(const Duration(minutes: 5)),
        interval: Duration.zero,
      ),
    );

    expect(tokens.accessToken, 'access-1');
    expect(tokens.refreshToken, 'refresh-1');
    expect(tokens.expiresIn, 3600);
    expect(requests.single, {
      'grant_type': kDeviceCodeGrantType,
      'device_code': 'device-code-1',
      'client_id': 'solian',
    });
  });

  test('pending and slow_down poll again instead of failing', () async {
    final dio = Dio()
      ..httpClientAdapter = scripted([
        (400, {'error': 'authorization_pending'}),
        (400, {'error': 'slow_down'}),
        (200, {'access_token': 'access-2'}),
      ]);

    final tokens = await awaitDeviceApproval(
      dio: dio,
      tokenEndpoint: Uri.parse('https://api.test/stargate/auth/open/token'),
      request: DeviceAuthorization(
        deviceCode: 'device-code-2',
        userCode: 'CODE',
        verificationUri: Uri.parse('https://id.test/auth/device'),
        verificationUriComplete: Uri.parse('https://id.test/auth/device'),
        expiresAt: DateTime.now().add(const Duration(minutes: 5)),
        interval: Duration.zero,
      ),
      timeout: const Duration(seconds: 2),
    );

    expect(tokens.accessToken, 'access-2');
    expect(requests, hasLength(3));
  });

  test('a declined code reports the refusal', () async {
    final dio = Dio()
      ..httpClientAdapter = scripted([
        (400, {'error': 'access_denied'}),
      ]);

    await expectLater(
      awaitDeviceApproval(
        dio: dio,
        tokenEndpoint: Uri.parse('https://api.test/stargate/auth/open/token'),
        request: DeviceAuthorization(
          deviceCode: 'device-code-3',
          userCode: 'CODE',
          verificationUri: Uri.parse('https://id.test/auth/device'),
          verificationUriComplete: Uri.parse('https://id.test/auth/device'),
          expiresAt: DateTime.now().add(const Duration(minutes: 5)),
          interval: Duration.zero,
        ),
      ),
      throwsA(anything),
    );
  });

  test('a device-code request keeps its form fields', () async {
    final dio = Dio()
      ..httpClientAdapter = scripted([
        (
          200,
          {
            'device_code': 'dc',
            'user_code': 'USER-CODE',
            'verification_uri': 'https://id.test/auth/device',
            'verification_uri_complete':
                'https://id.test/auth/device?code=USER-CODE',
            'expires_in': 600,
            'interval': 5,
          },
        ),
      ]);

    final request = await requestDeviceAuthorization(
      dio: dio,
      endpoint: Uri.parse('https://api.test/stargate/auth/open/device/code'),
      deviceId: 'device-1',
      deviceName: 'Browser',
    );

    expect(request.userCode, 'USER-CODE');
    expect(request.deviceCode, 'dc');
    expect(request.interval, const Duration(seconds: 5));
    expect(
      request.verificationUriComplete.queryParameters['code'],
      'USER-CODE',
    );
    expect(requests.single, {
      'client_id': 'solian',
      'scope': '*',
      'device_id': 'device-1',
      'device_name': 'Browser',
    });
  });
}

class _ScriptedAdapter implements HttpClientAdapter {
  _ScriptedAdapter(this.respond);

  final ResponseBody Function(RequestOptions options) respond;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return respond(options);
  }
}
