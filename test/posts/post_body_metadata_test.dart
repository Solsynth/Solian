import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/posts/widgets/compose/post_shared.dart';
import 'package:material_ui/material_ui.dart' as mui;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

SnPost _post({int viewsTotal = 0, int awardedScore = 0}) {
  return SnPost.fromJson({
    'id': 'post-1',
    'type': 0,
    'content': 'hello world, this is a post',
    'views_total': viewsTotal,
    'awarded_score': awardedScore,
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
        home: ProviderScope(
          child: mui.Material(child: SingleChildScrollView(child: child)),
        ),
      ),
    ),
  );
}

Future<void> _pump(WidgetTester tester, Widget child) async {
  await tester.runAsync(() async {
    await tester.pumpWidget(_wrap(child));
    await Future<void>.delayed(const Duration(milliseconds: 100));
  });
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  testWidgets('detail view shows views in the metadata section', (
    tester,
  ) async {
    await _pump(
      tester,
      PostBody(item: _post(viewsTotal: 1234), isFullPost: true),
    );

    expect(find.text('1234 views'), findsOneWidget);
  });

  testWidgets('feed view hides the views metadata', (tester) async {
    await _pump(
      tester,
      PostBody(item: _post(viewsTotal: 1234), isFullPost: false),
    );

    expect(find.text('1234 views'), findsNothing);
  });

  testWidgets('detail view hides views metadata at zero', (tester) async {
    await _pump(tester, PostBody(item: _post(), isFullPost: true));

    expect(find.text('0 views'), findsNothing);
  });

  testWidgets('award points still render alongside views', (tester) async {
    await _pump(
      tester,
      PostBody(
        item: _post(viewsTotal: 1234, awardedScore: 240),
        isFullPost: true,
      ),
    );

    expect(find.text('1234 views'), findsOneWidget);
    expect(find.text('Awarded 240 points'), findsOneWidget);
  });
}
