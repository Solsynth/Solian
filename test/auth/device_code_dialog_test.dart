import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:island/auth/device_code_sign_in.dart';
import 'package:island/auth/oidc_pkce.dart';
import 'package:island/auth/widgets/device_code_dialog.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets('shows the code and finishes the sign-in when approved', (
    tester,
  ) async {
    final approved = Completer<OAuthTokenSet>();
    late DeviceAuthorizationCallback started;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () {
                  withDeviceCodeSignIn(context, (onDeviceCode) {
                    started = onDeviceCode;
                    return approved.future;
                  }).ignore();
                },
                child: const Text('go'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('go'));
    await tester.pump();

    started(
      DeviceAuthorization(
        deviceCode: 'dc',
        userCode: 'CODE-1234',
        verificationUri: Uri.parse('https://id.test/auth/device'),
        verificationUriComplete: Uri.parse(
          'https://id.test/auth/device?code=CODE-1234',
        ),
        expiresAt: DateTime.now().add(const Duration(minutes: 5)),
        interval: const Duration(seconds: 5),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('CODE-1234'), findsOneWidget);
    expect(find.text('signInOverWebDeviceCodeOpen'), findsOneWidget);

    approved.complete(
      const OAuthTokenSet(accessToken: 'a', refreshToken: null, expiresIn: 1),
    );
    await tester.pumpAndSettle();
    expect(find.text('CODE-1234'), findsNothing);
  });
}
