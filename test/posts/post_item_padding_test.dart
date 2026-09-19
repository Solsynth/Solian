import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/config.dart';
import 'package:island/core/network.dart';
import 'package:island/creators/screens/publishers_form.dart';
import 'package:island/posts/widgets/compose/post_item.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart' as mui;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

/// Posts with chained children indent the body column by the chain rail; every
/// other row of the card (reaction row, reply footer, embeddings) has to share
/// that column instead of drifting left of it.
SnPost _post({bool chained = false}) {
  return SnPost.fromJson({
    'id': chained ? 'chain-head' : 'plain',
    'type': 0,
    'content': 'head body',
    'publisher': {'id': 'publisher-1', 'name': 'alice', 'nick': 'Alice'},
    'reactions_count': {'heart': 2},
    'reactions_made': <String, dynamic>{},
    'chained_posts': chained
        ? [
            {
              'id': 'chain-child',
              'type': 0,
              'content': 'chained body',
              'publisher': {
                'id': 'publisher-1',
                'name': 'alice',
                'nick': 'Alice',
              },
              'created_at': '2026-01-01T00:00:00Z',
              'updated_at': '2026-01-01T00:00:00Z',
            },
          ]
        : const <dynamic>[],
    'created_at': '2026-01-01T00:00:00Z',
    'updated_at': '2026-01-01T00:00:00Z',
  });
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  Future<void> pumpPostItem(WidgetTester tester, Widget item) async {
    final prefs = await SharedPreferences.getInstance();
    await tester.runAsync(() async {
      await tester.pumpWidget(
        EasyLocalization(
          supportedLocales: const [Locale('en', 'US')],
          path: 'assets/i18n',
          saveLocale: false,
          child: Builder(
            builder: (context) => mui.MaterialApp(
              locale: const Locale('en', 'US'),
              supportedLocales: const [Locale('en', 'US')],
              home: mui.Material(
                child: ProviderScope(
                  overrides: [
                    sharedPreferencesProvider.overrideWithValue(prefs),
                    publishersManagedProvider.overrideWith(
                      (ref) async => <SnPublisher>[],
                    ),
                    apiClientProvider.overrideWith((ref) => Dio()),
                  ],
                  child: item,
                ),
              ),
              localizationsDelegates: context.localizationDelegates,
            ),
          ),
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    await tester.pumpAndSettle();
  }

  testWidgets('reaction row sits on the post body column', (tester) async {
    await pumpPostItem(
      tester,
      PostItem(item: _post(), isTranslatable: false),
    );

    final bodyLeft = tester
        .getTopLeft(find.text('head body', findRichText: true))
        .dx;
    final reactChipLeft = tester
        .getTopLeft(
          find
              .ancestor(
                of: find.byIcon(Symbols.add_reaction),
                matching: find.byType(mui.ActionChip),
              )
              .first,
        )
        .dx;

    // The open-reaction chip must not overhang the body column to the left.
    expect(reactChipLeft, greaterThanOrEqualTo(bodyLeft));
    // It trails the body by its own inner padding only.
    expect(reactChipLeft - bodyLeft, lessThanOrEqualTo(8));
  });

  testWidgets('chained post: reaction row shares the chain column', (
    tester,
  ) async {
    // Chained rows build context menus that probe device info over a platform
    // channel; a non-Android target keeps the probe out of the test.
    debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
    try {
      await pumpPostItem(
        tester,
        PostItem(item: _post(chained: true), isTranslatable: false),
      );

      final bodyLeft = tester
          .getTopLeft(find.text('head body', findRichText: true))
          .dx;
      final childLeft = tester
          .getTopLeft(find.text('chained body', findRichText: true))
          .dx;
      final reactChipLeft = tester
          .getTopLeft(
            find
                .ancestor(
                  of: find.byIcon(Symbols.add_reaction),
                  matching: find.byType(mui.ActionChip),
                )
                .first,
          )
          .dx;

      // The chain rail moves the head body onto the child column...
      expect(childLeft, bodyLeft);
      // ...and the reaction row has to follow it instead of staying behind.
      expect(reactChipLeft, greaterThanOrEqualTo(bodyLeft));
      expect(reactChipLeft - bodyLeft, lessThanOrEqualTo(8));
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });
}
