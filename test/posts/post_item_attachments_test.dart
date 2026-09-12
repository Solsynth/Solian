import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/config.dart';
import 'package:island/core/network.dart';
import 'package:island/creators/screens/publishers_form.dart';
import 'package:island/posts/widgets/compose/post_item.dart';
import 'package:material_ui/material_ui.dart' as mui;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

/// A post whose only payload is one non-media attachment, so the body renders
/// it as a static file card instead of reaching for the network.
SnPost _postWithAttachment() {
  return SnPost.fromJson({
    'id': 'post-with-attachment',
    'type': 0,
    'content': 'caption',
    'chained_posts': const [],
    'publisher': {'id': 'publisher-1', 'name': 'alice', 'nick': 'Alice'},
    'attachments': [
      {
        'id': 'file-1',
        'name': 'report.pdf',
        'mime_type': 'application/pdf',
        'size': 2048,
      },
    ],
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

  testWidgets('renders the attachment of a post by default', (tester) async {
    await pumpPostItem(
      tester,
      PostItem(item: _postWithAttachment(), isTranslatable: false),
    );

    expect(find.text('caption', findRichText: true), findsOneWidget);
    expect(find.text('report.pdf'), findsOneWidget);
  });

  testWidgets('hideAttachments suppresses the post item attachment block', (
    tester,
  ) async {
    await pumpPostItem(
      tester,
      PostItem(
        item: _postWithAttachment(),
        isTranslatable: false,
        hideAttachments: true,
      ),
    );

    // The post itself still renders; only its attachment block is dropped, so
    // layouts that draw the media elsewhere do not repeat it.
    expect(find.text('caption', findRichText: true), findsOneWidget);
    expect(find.text('report.pdf'), findsNothing);
  });
}
