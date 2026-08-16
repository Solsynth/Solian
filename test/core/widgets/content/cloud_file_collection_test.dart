import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/config.dart';
import 'package:island/core/widgets/content/cloud_file_collection.dart';
import 'package:material_ui/material_ui.dart' as mui;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

/// Guards the multi-image carousel layout: the configured padding must live on
/// the attachment scrollable itself (CarouselView.padding) so items snap in
/// order with consistent margins — not on an outer wrapper that shrinks the
/// scroll viewport and dead-ends the swipe edges.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> pumpCarousel(
    WidgetTester tester, {
    bool isFullBleed = false,
    double fullBleedFraction = 0.9,
    ValueChanged<int>? onIndexChanged,
  }) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    final files = <IDisplayableCloudFile>[
      for (var i = 0; i < 3; i++)
        SnCloudFileReference(
          id: 'file-$i',
          name: 'image-$i.jpg',
          mimeType: 'image/jpeg',
          width: 100,
          height: 100,
        ),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          serverUrlProvider.overrideWithValue('https://example.com'),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: CloudFileList(
              files: files,
              padding: const EdgeInsets.all(8),
              isFullBleed: isFullBleed,
              fullBleedFraction: fullBleedFraction,
              onIndexChanged: onIndexChanged,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('carousel padding is applied on the scrollable, not a wrapper', (
    tester,
  ) async {
    await pumpCarousel(tester);

    final carouselFinder = find.byType(mui.CarouselView);
    expect(carouselFinder, findsOneWidget);

    final carousel = tester.widget<mui.CarouselView>(carouselFinder);
    expect(
      carousel.padding,
      const EdgeInsets.all(8),
      reason: 'padding must be owned by the attachment scrollable itself',
    );

    // No outer Padding wrapper may sit between the scrollable and its
    // LayoutBuilder: the viewport must measure the full container width.
    var foundPadding = false;
    tester.element(carouselFinder).visitAncestorElements((ancestor) {
      if (ancestor.widget is Padding) {
        foundPadding = true;
        return false;
      }
      if (ancestor.widget is LayoutBuilder) return false;
      return true;
    });
    expect(
      foundPadding,
      isFalse,
      reason: 'padding must not wrap the scrollable from the outside',
    );
  });

  testWidgets('post-item multi-attachment carousel peeks next item, sharp', (
    tester,
  ) async {
    await pumpCarousel(tester, isFullBleed: true);

    final carouselFinder = find.byType(mui.CarouselView);
    expect(carouselFinder, findsOneWidget);

    final carousel = tester.widget<mui.CarouselView>(carouselFinder);
    final viewportWidth = tester.getSize(carouselFinder).width;

    expect(
      carousel.itemExtent,
      closeTo(viewportWidth * 0.9, 0.001),
      reason: 'each item takes 90% of the width so the next one peeks',
    );
    final shape = carousel.shape as RoundedRectangleBorder;
    expect(
      shape.borderRadius,
      BorderRadius.zero,
      reason: 'multi-attachment items must have sharp borders',
    );
    expect(
      carousel.padding,
      const EdgeInsets.symmetric(vertical: 8),
      reason: 'gap must not come from uniform CarouselView padding, or the '
          'last page would carry a trailing inset',
    );
    final children = carousel.children;
    expect(children.length, 3);
    for (final child in children.take(children.length - 1)) {
      final padding = child as Padding;
      expect(
        padding.padding,
        const EdgeInsets.only(right: 8),
        reason: 'inter-item gap lives on each card',
      );
    }
    expect(
      children.last,
      isNot(isA<Padding>()),
      reason: 'last card is ungapped so the final page snaps flush to the '
          'right border',
    );
  });

  testWidgets('full-width carousel (post detail) is flush and reports index', (
    tester,
  ) async {
    final changed = <int>[];
    await pumpCarousel(
      tester,
      isFullBleed: true,
      fullBleedFraction: 1.0,
      onIndexChanged: changed.add,
    );

    final carouselFinder = find.byType(mui.CarouselView);
    expect(carouselFinder, findsOneWidget);

    final carousel = tester.widget<mui.CarouselView>(carouselFinder);
    final viewportWidth = tester.getSize(carouselFinder).width;

    expect(
      carousel.itemExtent,
      viewportWidth,
      reason: 'full-width pages — no peek in the dedicated viewer',
    );
    for (final child in carousel.children) {
      expect(
        child,
        isNot(isA<Padding>()),
        reason: 'full-width pages must be flush on both edges',
      );
    }

    await tester.drag(carouselFinder, Offset(-viewportWidth * 0.8, 0));
    await tester.pumpAndSettle();
    expect(
      changed,
      contains(1),
      reason: 'the viewer must learn the current page index',
    );
  });
}
