import 'dart:async';
import 'dart:typed_data';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/config.dart';
import 'package:island/core/widgets/content/attachment_preview.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart' as mui;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    EasyLocalization.logger.enableLevels = [];
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  Future<void> pumpAttachmentPreview(
    WidgetTester tester,
    Widget child,
  ) async {
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
                  ],
                  child: Center(
                    child: SizedBox(
                      width: 320,
                      height: 240,
                      child: child,
                    ),
                  ),
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

  SnCloudFileReference makeTestCloudFile({
    String id = 'file-123',
    String name = 'sample.png',
  }) {
    return SnCloudFileReference(
      id: id,
      name: name,
      mimeType: 'image/png',
    );
  }

  testWidgets('renders cloud attachment with Island UI elements and no dividers', (
    tester,
  ) async {
    final cloudFile = makeTestCloudFile();
    final item = UniversalFile.fromAttachment(cloudFile);

    await pumpAttachmentPreview(
      tester,
      AttachmentPreview(
        item: item,
        onDelete: () {},
        onMove: (_) {},
      ),
    );

    // Should not contain any VerticalDivider
    expect(find.byType(VerticalDivider), findsNothing);

    // Should show delete and move buttons
    expect(find.byIcon(Symbols.delete_rounded), findsOneWidget);
    expect(find.byIcon(Symbols.keyboard_arrow_up_rounded), findsOneWidget);
    expect(find.byIcon(Symbols.keyboard_arrow_down_rounded), findsOneWidget);

    // Should show attachment on cloud status
    expect(find.byIcon(Symbols.cloud_done_rounded), findsOneWidget);
  });

  testWidgets('shows loading modal when deleting attachment on cloud', (
    tester,
  ) async {
    final cloudFile = makeTestCloudFile();
    final item = UniversalFile.fromAttachment(cloudFile);

    final completer = Completer<void>();
    var deleteCalled = false;

    await pumpAttachmentPreview(
      tester,
      AttachmentPreview(
        item: item,
        onDelete: () async {
          deleteCalled = true;
          await completer.future;
        },
      ),
    );

    // Tap delete button
    final deleteButton = find.byIcon(Symbols.delete_rounded);
    expect(deleteButton, findsOneWidget);
    await tester.tap(deleteButton);
    await tester.pump(const Duration(milliseconds: 250));

    // Verify delete was initiated and loading modal is visible
    expect(deleteCalled, isTrue);
    expect(find.text('loading'.tr()), findsOneWidget);

    // Complete the deletion
    completer.complete();
    await tester.pumpAndSettle();

    // Verify loading modal is gone
    expect(find.text('loading'.tr()), findsNothing);
  });

  testWidgets('deleting local file calls onDelete directly without loading modal', (
    tester,
  ) async {
    final item = UniversalFile(
      type: UniversalFileType.image,
      data: Uint8List.fromList([1, 2, 3]),
      displayName: 'local.png',
    );

    var deleteCalled = false;

    await pumpAttachmentPreview(
      tester,
      AttachmentPreview(
        item: item,
        onDelete: () {
          deleteCalled = true;
        },
      ),
    );

    final deleteButton = find.byIcon(Symbols.delete_rounded);
    expect(deleteButton, findsOneWidget);
    await tester.tap(deleteButton);
    await tester.pumpAndSettle();

    expect(deleteCalled, isTrue);
    expect(find.text('loading'.tr()), findsNothing);
  });

  testWidgets('renders thumbnail selected badge without borders', (
    tester,
  ) async {
    final cloudFile = makeTestCloudFile(id: 'thumb-1');
    final item = UniversalFile.fromAttachment(cloudFile);

    await pumpAttachmentPreview(
      tester,
      AttachmentPreview(
        item: item,
        thumbnailId: 'thumb-1',
      ),
    );

    // Badge with star icon should be present
    expect(find.byIcon(Symbols.star_rounded), findsOneWidget);
  });
}
