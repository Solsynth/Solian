import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/account_pod.dart';
import 'package:island/posts/widgets/compose/post_replies.dart';
import 'package:island/posts/widgets/compose/post_replies_sheet.dart';
import 'package:island/posts/widgets/compose/post_shared.dart';
import 'package:island/shared/widgets/layouts/sidebar_panel_host.dart';
import 'package:material_ui/material_ui.dart' as mui;
import 'package:material_symbols_icons/symbols.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

class _GuestUserInfo extends UserInfoNotifier {
  @override
  Future<SnAccount?> build() async => null;
}

/// Keeps the threaded-replies provider off the network.
class _NoopReplies extends RepliesNotifier {
  @override
  Future<void> fetchMore(int pageSize) async {}
}

/// Paginated replies list returns nothing without touching the network.
class _EmptyPostReplies extends PostRepliesNotifier {
  _EmptyPostReplies(super.arg);

  @override
  Future<List<SnPost>> fetch() async => [];

  @override
  Future<PaginationState<SnPost>> build() async => const PaginationState(
    items: <SnPost>[],
    isLoading: false,
    isReloading: false,
    totalCount: 0,
    hasMore: false,
    cursor: null,
  );
}

SnPost _post({int repliesCount = 3}) {
  return SnPost.fromJson({
    'id': 'post-1',
    'type': 0,
    'content': 'hello',
    'replies_count': repliesCount,
    'created_at': '2026-01-01T00:00:00Z',
    'updated_at': '2026-01-01T00:00:00Z',
  });
}

List<Object?> _overrides() => [
  userInfoProvider.overrideWith(() => _GuestUserInfo()),
  repliesProvider.overrideWith(() => _NoopReplies()),
  postRepliesPreviewProvider.overrideWith((ref, id) async => const <SnPost>[]),
  postRepliesProvider.overrideWith(
    () => _EmptyPostReplies(postRepliesQuery('post-1')),
  ),
];

Widget _wrap(Widget child) {
  return EasyLocalization(
    supportedLocales: const [Locale('en', 'US')],
    path: 'assets/i18n',
    saveLocale: false,
    child: ProviderScope(
      overrides: _overrides().cast(),
      child: Builder(
        builder: (context) => mui.MaterialApp(
          locale: const Locale('en', 'US'),
          supportedLocales: const [Locale('en', 'US')],
          localizationsDelegates: context.localizationDelegates,
          theme: mui.ThemeData(
            colorScheme: mui.ColorScheme.fromSeed(seedColor: Colors.indigo),
          ),
          home: mui.Material(child: child),
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
  await tester.pump(const Duration(milliseconds: 100));
}

/// Fires the zero-duration autoload timer `PostReplyPreview` schedules and
/// drains the visibility-detector debounce cycles the replies footer runs
/// (each 500ms fire can trigger one rebuild, rescheduling once more).
Future<void> _flushTimers(WidgetTester tester) async {
  for (var i = 0; i < 3; i++) {
    await tester.pump(const Duration(seconds: 1));
  }
}

/// A minimal sidebar that renders whatever panel the host requests.
class _TestSidebar extends StatelessWidget {
  const _TestSidebar({required this.controller, required this.child});

  final ValueNotifier<Widget?> controller;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SidebarPanelHost(
      controller: controller,
      child: Column(
        children: [
          child,
          Expanded(
            child: ValueListenableBuilder<Widget?>(
              valueListenable: controller,
              builder: (context, panel, _) =>
                  panel ?? const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }
}

/// Mirrors the explore wide body's tunable sidebar: a switcher animating the
/// whole section between default content and the requested panel.
class _SwitcherSidebar extends StatelessWidget {
  const _SwitcherSidebar({required this.controller, required this.child});

  final ValueNotifier<Widget?> controller;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SidebarPanelHost(
      controller: controller,
      child: Column(
        children: [
          child,
          Expanded(
            child: ValueListenableBuilder<Widget?>(
              valueListenable: controller,
              builder: (context, panel, _) {
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  reverseDuration: const Duration(milliseconds: 200),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  layoutBuilder: (currentChild, previousChildren) {
                    return Stack(
                      fit: StackFit.expand,
                      children: [...previousChildren, ?currentChild],
                    );
                  },
                  transitionBuilder: (child, animation) {
                    final isLeaving =
                        animation.status == AnimationStatus.reverse;
                    final curved = animation.drive(
                      CurveTween(curve: Curves.easeOutCubic),
                    );
                    final offset = isLeaving
                        ? curved.drive(
                            Tween(
                              begin: Offset.zero,
                              end: const Offset(0.06, 0),
                            ),
                          )
                        : curved.drive(
                            Tween(
                              begin: const Offset(0.06, 0),
                              end: Offset.zero,
                            ),
                          );
                    final opacity = isLeaving
                        ? animation.drive(
                            CurveTween(curve: Curves.easeInCubic),
                          )
                        : CurvedAnimation(
                            parent: animation,
                            curve: const Interval(
                              0.25,
                              1.0,
                              curve: Curves.easeOutCubic,
                            ),
                          );
                    return FadeTransition(
                      opacity: opacity,
                      child: SlideTransition(
                        position: offset,
                        child: child,
                      ),
                    );
                  },
                  child: panel == null
                      ? const KeyedSubtree(
                          key: ValueKey('explore-sidebar-default'),
                          child: SizedBox.expand(),
                        )
                      : KeyedSubtree(
                          key:
                              panel.key ??
                              const ValueKey('explore-sidebar-panel'),
                          child: panel,
                        ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  testWidgets('without a host, replies preview still opens the modal sheet', (
    tester,
  ) async {
    await _pump(tester, PostReplyPreview(parent: _post()));

    await tester.tap(find.byType(PostReplyPreview));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(PostRepliesSheet), findsOneWidget);
    // Close the modal so the replies footer's visibility timer is disposed.
    tester.state<NavigatorState>(find.byType(Navigator).first).pop();
    await tester.pump(const Duration(milliseconds: 400));
    await _flushTimers(tester);
  });

  testWidgets('with a host, replies preview routes to the sidebar panel', (
    tester,
  ) async {
    final controller = ValueNotifier<Widget?>(null);
    await _pump(
      tester,
      SidebarPanelHost(controller: controller, child: PostReplyPreview(
        parent: _post(),
      )),
    );

    await tester.tap(find.byType(PostReplyPreview));
    await tester.pump();

    expect(controller.value, isA<PostRepliesSheet>());
    // No modal route was pushed: the panel is only held, not mounted here.
    expect(find.byType(PostRepliesSheet), findsNothing);
    await _flushTimers(tester);
  });

  testWidgets('panel renders in the sidebar and close restores default', (
    tester,
  ) async {
    final controller = ValueNotifier<Widget?>(null);
    await _pump(
      tester,
      _TestSidebar(controller: controller, child: PostReplyPreview(
        parent: _post(),
      )),
    );

    await tester.tap(find.byType(PostReplyPreview));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(controller.value, isA<PostRepliesSheet>());
    expect(find.byType(PostRepliesSheet), findsOneWidget);

    await tester.tap(find.byIcon(Symbols.close));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(controller.value, isNull);
    expect(find.byType(PostRepliesSheet), findsNothing);
    await _flushTimers(tester);
  });

  testWidgets('panel exit is animated: outgoing panel stays mounted mid-leave', (
    tester,
  ) async {
    final controller = ValueNotifier<Widget?>(null);
    await _pump(
      tester,
      _SwitcherSidebar(controller: controller, child: PostReplyPreview(
        parent: _post(),
      )),
    );

    await tester.tap(find.byType(PostReplyPreview));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(PostRepliesSheet), findsOneWidget);

    await tester.tap(find.byIcon(Symbols.close));
    await tester.pump();
    // 100ms into the 250ms reverse transition the panel must still be
    // mounted; an instant teardown means the exit is not animated.
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byType(PostRepliesSheet), findsOneWidget);
    // And it must actually be leaving: fading out fast and sliding toward
    // the right edge, not parked at full opacity.
    final fade = tester.widget<FadeTransition>(
      find
          .ancestor(
            of: find.byType(PostRepliesSheet),
            matching: find.byType(FadeTransition),
          )
          .first,
    );
    expect(fade.opacity.value, lessThan(0.5));
    final slide = tester.widget<SlideTransition>(
      find
          .ancestor(
            of: find.byType(PostRepliesSheet),
            matching: find.byType(SlideTransition),
          )
          .first,
    );
    expect(slide.position.value.dx, greaterThan(0.001));

    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(PostRepliesSheet), findsNothing);
    await _flushTimers(tester);
  });
}
