import 'package:dismissible_page/dismissible_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/config.dart';
import 'package:island/core/widgets/content/cloud_file_lightbox.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

/// Guards CloudFileLightbox against reconstructing the dismissible page.
///
/// [CloudFileLightbox] keys its whole content subtree so that
/// [DismissiblePage]'s `disabled` branch flip (zoomed image <-> normal, driven
/// by the internal `isZoomed` state) reparents instead of rebuilding the
/// gallery from scratch.
void main() {
  group('CloudFileLightbox', () {
    testWidgets('chrome-only changes do not reconstruct the gallery', (
      tester,
    ) async {
      final items = <IDisplayableCloudFile>[
        SnCloudFileReference(
          id: 'file-1',
          name: 'a.bin',
          mimeType: 'application/octet-stream',
        ),
        SnCloudFileReference(
          id: 'file-2',
          name: 'b.bin',
          mimeType: 'application/octet-stream',
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            serverUrlProvider.overrideWithValue('https://example.com'),
          ],
          child: MaterialApp(
            home: CloudFileLightbox(items: items, initialIndex: 0),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final galleryElement = find.byType(PhotoViewGallery);
      expect(galleryElement, findsOneWidget);
      final galleryBefore = tester.element(galleryElement);

      // Page navigation rebuilds the gallery in place (State survives) and
      // updates the chrome counter.
      await tester.tap(find.byTooltip('Next'));
      await tester.pumpAndSettle();
      expect(find.text('2 / 2'), findsOneWidget);
      expect(
        identical(galleryBefore, tester.element(galleryElement)),
        isTrue,
        reason: 'page change must rebuild, not reconstruct, the gallery',
      );

      // The 3-second controls auto-hide timer fires: chrome hides, but the
      // gallery must not be reconstructed.
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();
      final chrome = tester.widget<AnimatedOpacity>(
        find
            .ancestor(
              of: find.byTooltip('Close'),
              matching: find.byType(AnimatedOpacity),
            )
            .first,
      );
      expect(chrome.opacity, 0.0, reason: 'controls must auto-hide');
      expect(
        identical(galleryBefore, tester.element(galleryElement)),
        isTrue,
        reason: 'chrome auto-hide must not reconstruct the gallery',
      );
    });

    testWidgets('hides quality toggle when compression is unavailable', (
      tester,
    ) async {
      final items = <IDisplayableCloudFile>[
        SnCloudFileReference(
          id: 'original-only',
          name: 'original.jpg',
          mimeType: 'image/jpeg',
          width: 1,
          height: 1,
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            serverUrlProvider.overrideWithValue('https://example.com'),
          ],
          child: MaterialApp(home: CloudFileLightbox(items: items)),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byTooltip('Compressed quality (SD)'), findsNothing);
    });
  });

  group('DismissiblePage zoom flip', () {
    testWidgets('GlobalKey keeps the page subtree across the disabled flip', (
      tester,
    ) async {
      final key = GlobalKey();
      final controller = PageController();
      addTearDown(controller.dispose);
      var initCount = 0;

      Widget child() => KeyedSubtree(
        key: key,
        child: PageView(
          controller: controller,
          children: [
            for (var i = 0; i < 5; i++)
              _ProbePage(label: 'page-$i', onInit: () => initCount++),
          ],
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: _ToggleHost(
            enabledBuilder: (enabled) => DismissiblePage(
              disabled: enabled,
              onDismissed: () {},
              child: child(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Move to page 2 and record that page's probe element identity.
      controller.jumpToPage(2);
      await tester.pumpAndSettle();
      final probeBefore = tester.element(
        find.byKey(const ValueKey('probe-page-2')),
      );
      final initCountAfterScroll = initCount;

      // Flip disabled (simulates a zoomed image) and back.
      await tester.tap(find.byKey(const ValueKey('toggle')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('toggle')));
      await tester.pumpAndSettle();

      // The subtree must NOT have been reconstructed: the same Element
      // (State preserved) and no extra initState calls.
      final probeAfter = tester.element(
        find.byKey(const ValueKey('probe-page-2')),
      );
      expect(
        identical(probeBefore, probeAfter),
        isTrue,
        reason: 'page State must survive the disabled flip',
      );
      expect(
        initCount,
        initCountAfterScroll,
        reason: 'no page may be re-initialized during the flip',
      );
      expect(
        controller.page,
        closeTo(2, 0.001),
        reason: 'scroll position must survive the flip',
      );
    });
  });
}

class _ProbePage extends StatefulWidget {
  const _ProbePage({required this.label, required this.onInit});

  final String label;
  final VoidCallback onInit;

  @override
  State<_ProbePage> createState() => _ProbePageState();
}

class _ProbePageState extends State<_ProbePage> {
  @override
  void initState() {
    super.initState();
    widget.onInit();
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      key: ValueKey('probe-${widget.label}'),
      color: Colors.black,
      child: Center(child: Text(widget.label)),
    );
  }
}

class _ToggleHost extends StatefulWidget {
  const _ToggleHost({required this.enabledBuilder});

  final Widget Function(bool enabled) enabledBuilder;

  @override
  State<_ToggleHost> createState() => _ToggleHostState();
}

class _ToggleHostState extends State<_ToggleHost> {
  bool enabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          widget.enabledBuilder(enabled),
          Positioned(
            top: 8,
            right: 8,
            child: TextButton(
              key: const ValueKey('toggle'),
              onPressed: () => setState(() => enabled = !enabled),
              child: const Text('toggle'),
            ),
          ),
        ],
      ),
    );
  }
}
