import 'package:flutter_test/flutter_test.dart';
import 'package:island/core/network.dart';

void main() {
  test('parses the server social-login token pair metadata', () {
    final data = parseAuthCallbackTokenData(
      Uri.parse(
        'solian://auth/callback?token=atk&refreshToken=rtk&expiresIn=259200&refreshExpiresIn=2592000',
      ),
    );

    expect(data.refreshToken, 'rtk');
    expect(data.expiresIn, 259200);
    expect(data.refreshExpiresIn, 2592000);
  });

  test('accepts snake-case callback metadata for compatibility', () {
    final data = parseAuthCallbackTokenData(
      Uri.parse(
        'solian://auth/callback?refresh_token=rtk&expires_in=10&refresh_expires_in=20',
      ),
    );

    expect(data.refreshToken, 'rtk');
    expect(data.expiresIn, 10);
    expect(data.refreshExpiresIn, 20);
  });
}
