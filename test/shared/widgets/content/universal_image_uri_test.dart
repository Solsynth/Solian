import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/config.dart';
import 'package:island/shared/widgets/content/image.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _serverUrl = 'https://api.example.com';

Future<void> _pumpImage(WidgetTester tester, String uri) async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        serverUrlProvider.overrideWithValue(_serverUrl),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 120,
              height: 120,
              child: UniversalImage(uri: uri, blurHash: null),
            ),
          ),
        ),
      ),
    ),
  );
}

void main() {
  group('UniversalImage uri validation', () {
    testWidgets('shows the error presentation for a blank uri', (tester) async {
      // A blank address used to reach the network layer and surface as
      // "Invalid argument: No host specified in URI", far from the widget that
      // produced it. The fallback renders immediately instead.
      await _pumpImage(tester, '');
      await tester.pump();

      expect(find.byType(CachedImageErrorWidget), findsOneWidget);
    });

    testWidgets('shows the error presentation for a relative uri', (
      tester,
    ) async {
      await _pumpImage(tester, '/drive/files/file-1');
      await tester.pump();

      expect(find.byType(CachedImageErrorWidget), findsOneWidget);
    });

    testWidgets('proceeds to the loader for an absolute uri', (tester) async {
      await _pumpImage(tester, '$_serverUrl/drive/files/file-1');
      await tester.pump();

      expect(find.byType(CachedImageErrorWidget), findsNothing);
    });
  });
}
