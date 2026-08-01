import 'package:dismissible_page/dismissible_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Scratch test: does a GlobalKey'd child subtree survive DismissiblePage's
/// `disabled` branch flip (DecoratedBox <-> SingleAxisDismissiblePage)?
void main() {
  testWidgets(
    'GlobalKey keeps gallery state across the disabled branch flip',
    (tester) async {
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
                  _ProbePage(
                    label: 'page-$i',
                    onInit: () => initCount++,
                  ),
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

      // Flip disabled (simulates zoomed state) and back.
      await tester.tap(find.byKey(const ValueKey('toggle')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('toggle')));
      await tester.pumpAndSettle();

      // The subtree must NOT have been reconstructed: the same Element
      // (State preserved) and no extra initState calls.
      final probeAfter = tester.element(
        find.byKey(const ValueKey('probe-page-2')),
      );
      expect(identical(probeBefore, probeAfter), isTrue,
          reason: 'page State must survive the disabled flip');
      expect(initCount, initCountAfterScroll,
          reason: 'no page may be re-initialized during the flip');
      expect(controller.page, closeTo(2, 0.001),
          reason: 'scroll position must survive the flip');
    },
  );
}

class _ProbePage extends StatefulWidget {
  const _ProbePage({
    required this.label,
    required this.onInit,
  });

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
