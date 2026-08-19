import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/posts/widgets/compose/post_award_sheet.dart';
import 'package:material_ui/material_ui.dart' as mui;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

SnPost _post() {
  return SnPost.fromJson({
    'id': 'post-1',
    'type': 0,
    'content': 'Preview content',
    'actor': {
      'username': 'tester',
      'avatar_url': 'https://example.com/avatar.png',
    },
    'created_at': '2026-01-01T00:00:00Z',
    'updated_at': '2026-01-01T00:00:00Z',
  });
}

Widget _wrap(Widget child) {
  return EasyLocalization(
    supportedLocales: const [Locale('en', 'US')],
    path: 'assets/i18n',
    saveLocale: false,
    child: Builder(
      builder: (context) => mui.MaterialApp(
        locale: const Locale('en', 'US'),
        supportedLocales: const [Locale('en', 'US')],
        localizationsDelegates: context.localizationDelegates,
        theme: mui.ThemeData(
          colorScheme: mui.ColorScheme.fromSeed(seedColor: Colors.indigo),
        ),
        home: ProviderScope(child: mui.Material(child: child)),
      ),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  testWidgets('post preview paints its content without border assertion', (
    tester,
  ) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(_wrap(PostAwardSheet(post: _post())));
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    await tester.pumpAndSettle();

    expect(find.text('Post Preview'), findsOneWidget);
    expect(find.text('Preview content'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
