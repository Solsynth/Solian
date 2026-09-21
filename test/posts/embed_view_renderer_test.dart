import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:material_ui/material_ui.dart' as mui;
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/posts/widgets/compose/embed_view_renderer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  Future<void> pumpEmbed(
    WidgetTester tester,
    double aspectRatio, {
    double width = 374,
    double maxHeight = 400,
  }) async {
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
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: SizedBox(
                      width: width,
                      child: EmbedViewRenderer(
                        embedView: SnPostEmbedView(
                          uri: 'https://example.com/video',
                          aspectRatio: aspectRatio,
                        ),
                        maxHeight: maxHeight,
                      ),
                    ),
                  ),
                ),
              ),
              localizationsDelegates: context.localizationDelegates,
            ),
          ),
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 50));
    });
    await tester.pumpAndSettle();
  }

  for (final aspectRatio in <double>[1, 0.5, 0.3]) {
    testWidgets(
      'clamps a ${aspectRatio.toStringAsFixed(1)}-ratio embed to maxHeight '
      'instead of overflowing it',
      (tester) async {
        tester.view.physicalSize = const Size(420, 2400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        // A pre-fix overflow here painted the webview and the striped overflow
        // band past the card, over the post below.
        final errors = <FlutterErrorDetails>[];
        final oldHandler = FlutterError.onError;
        FlutterError.onError = (details) => errors.add(details);
        try {
          await pumpEmbed(tester, aspectRatio);
        } finally {
          FlutterError.onError = oldHandler;
        }

        expect(
          errors.where((e) => e.exception.toString().contains('overflowed')),
          isEmpty,
          reason: 'aspect $aspectRatio: the embed must fit inside maxHeight',
        );

        final renderer = tester.getRect(find.byType(EmbedViewRenderer));
        expect(renderer.height, lessThanOrEqualTo(400.0 + 0.5));
      },
    );
  }

  testWidgets(
    'keeps a wide embed at its aspect ratio instead of stretching it',
    (tester) async {
      tester.view.physicalSize = const Size(420, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await pumpEmbed(tester, 2.0);

      final renderer = tester.getRect(find.byType(EmbedViewRenderer));
      // width 374 at a 2:1 ratio gives ~187 of webview plus the header chrome;
      // a stretched fill would reach the full 400 cap instead.
      expect(renderer.height, lessThan(400.0 - 100.0));
    },
  );
}
