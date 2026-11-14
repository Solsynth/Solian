import 'dart:io';
import 'dart:ui';
import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/config.dart';
import 'package:island/plugins/widgets/plugin_pane_layer.dart';
import 'package:island/accounts/account_pod.dart';
import 'package:island/core/websocket.dart';
import 'package:island/core/services/responsive.dart';
import 'package:island/notifications/notification_overlay.dart';
import 'package:island/route.gr.dart';
import 'package:island/shared/widgets/task_overlay.dart';
import 'package:island/shared/widgets/content/media_playback.dart';
import 'package:island/shared/widgets/window_state.dart';
import 'package:island_ui_foundation/island_ui_foundation.dart'
    hide isWideScreen, isWiderScreen, isWidestScreen;
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:path_provider/path_provider.dart';
import 'package:window_manager/window_manager.dart';

class AppScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch, // default
    PointerDeviceKind.trackpad, // default
  };
}

class WindowScaffold extends HookConsumerWidget {
  final Widget child;
  const WindowScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDesktop = DesktopWindowFrame.isPlatformDesktop;
    final useNativeFrame = ref.watch(desktopNativeWindowFrameProvider);

    useEffect(() {
      if (!isDesktop) return null;

      // The window-state listener keeps geometry persisted during the session
      // on native resize/move events. Keep a lifecycle observer too: it
      // catches pauses/hides (e.g. closing to tray) without waiting for a
      // native event, and flushes the full bounds + maximized state.
      final observer = _WindowGeometryObserver(ref);
      WidgetsBinding.instance.addObserver(observer);

      return () {
        WidgetsBinding.instance.removeObserver(observer);
      };
    }, []);

    final overlays = <Widget>[
      const WebSocketIndicator(),
      const SnNotificationOverlay(),
      const PluginPaneLayer(),
    ];

    return DesktopWindowFrame(
      isDesktopPlatform: isDesktop && !useNativeFrame,
      title: isDesktop && !useNativeFrame
          ? Platform.isMacOS
                ? Text(
                    'Solar Network',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  )
                : Row(
                    children: [
                      Image.asset(
                        Theme.of(context).brightness == Brightness.dark
                            ? 'assets/icons/icon-dark.webp'
                            : 'assets/icons/icon.webp',
                        width: 20,
                        height: 20,
                      ),
                      const SizedBox(width: 8),
                      Text('Solar Network'),
                    ],
                  )
          : null,
      overlays: overlays,
      onClose: () => windowManager.hide(),
      child: Stack(
        children: [
          Column(
            children: [
              Expanded(child: child),
              const MediaPlaybackDock(),
            ],
          ),
          // The task pill floats over the bottom edge like a Live
          // Activity. An overlay, so a running task never resizes the
          // page below it; only the transparent parts of its lane let
          // taps through to what's underneath.
          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: TaskOverlayHost(),
          ),
          // Video keeps playing in a floating picture-in-picture overlay;
          // the audio dock stays in the column above.
          const FloatingVideoDock(),
        ],
      ),
    );
  }
}

class _WindowGeometryObserver extends WidgetsBindingObserver {
  _WindowGeometryObserver(this._ref);

  final WidgetRef _ref;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // Save window geometry when app is paused, detached, or hidden
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached ||
        state == AppLifecycleState.hidden) {
      if (!kIsWeb &&
          (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
        saveWindowStateNow(_ref);
      }
    }
  }
}

final rootScaffoldKey = GlobalKey<ScaffoldState>();

class AppScaffold extends HookConsumerWidget {
  final Widget? body;
  final PreferredSizeWidget? bottomNavigationBar;
  final PreferredSizeWidget? bottomSheet;
  final Drawer? drawer;
  final Widget? endDrawer;
  final FloatingActionButtonAnimator? floatingActionButtonAnimator;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Widget? floatingActionButton;
  final PreferredSizeWidget? appBar;
  final DrawerCallback? onDrawerChanged;
  final DrawerCallback? onEndDrawerChanged;
  final bool? isNoBackground;
  final bool? extendBody;

  /// Let the body extend behind [appBar] instead of being pushed below it.
  ///
  /// With this off (the default) the scaffold reserves the bar's whole band, so
  /// nothing ever slides underneath it. With it on the content starts at the
  /// top of the viewport and scrolls under the bar — which is what a
  /// transparent, blur-backed bar like [PillAppBar] samples, and why those
  /// pages add their own `statusTop + kPillAppBarHeight` gap to their first
  /// sliver so their content still starts below the pill.
  ///
  /// Only the scrollable case makes sense: a page whose body does not scroll
  /// has nothing to slide under the bar and would just paint beneath it.
  final bool appBarOverContent;

  const AppScaffold({
    super.key,
    this.appBar,
    this.body,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.floatingActionButtonAnimator,
    this.bottomNavigationBar,
    this.bottomSheet,
    this.drawer,
    this.endDrawer,
    this.onDrawerChanged,
    this.onEndDrawerChanged,
    this.isNoBackground,
    this.extendBody,
    this.appBarOverContent = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appBarHeight = appBar?.preferredSize.height ?? 0;
    final safeTop = MediaQuery.of(context).padding.top;
    final keyboardFocusNode = useFocusNode();
    final topReservedHeight = appBar != null && !appBarOverContent
        ? appBarHeight + safeTop
        : 0.0;

    // Request focus to capture keyboard events
    useEffect(() {
      keyboardFocusNode.requestFocus();
      return null;
    }, []);

    final noBackground = isNoBackground ?? isWideScreen(context);

    final builtWidget = Focus(
      focusNode: keyboardFocusNode,
      onKeyEvent: (node, event) {
        // Check for escape key press
        if (event is KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.escape) {
          final router = context.router;
          // Only pop if there are pages to pop
          if (router.canPop()) {
            router.pop();
          }
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: Scaffold(
        extendBody: extendBody ?? true,
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.transparent,
        body: Column(
          children: [
            IgnorePointer(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                height: topReservedHeight,
              ),
            ),
            if (body != null) Expanded(child: body!),
          ],
        ),
        appBar: appBar,
        bottomNavigationBar: bottomNavigationBar,
        bottomSheet: bottomSheet,
        drawer: drawer,
        endDrawer: endDrawer,
        floatingActionButton: floatingActionButton,
        floatingActionButtonAnimator: floatingActionButtonAnimator,
        onDrawerChanged: onDrawerChanged,
        onEndDrawerChanged: onEndDrawerChanged,
      ),
    );

    return noBackground
        ? builtWidget
        : AppBackground(isRoot: true, child: builtWidget);
  }
}

class PageBackButton extends StatelessWidget {
  final Color? color;
  final List<Shadow>? shadows;
  final VoidCallback? onWillPop;
  final String? backTo;
  final bool forcePop;
  const PageBackButton({
    super.key,
    this.shadows,
    this.onWillPop,
    this.color,
    this.backTo,
    this.forcePop = false,
  });

  static bool isDesktop() =>
      (!kIsWeb && (Platform.isMacOS || Platform.isLinux || Platform.isWindows));

  @override
  Widget build(BuildContext context) {
    // On desktop, hide the back button (escape key handles navigation)
    if (isDesktop() && backTo != null && !forcePop) {
      return const SizedBox.shrink();
    }

    // On narrow screens (mobile), always show the back button
    // Check if we can pop from the current router
    final canPop = context.router.canPop();

    return IconButton(
      onPressed: () {
        onWillPop?.call();
        if (canPop || forcePop) {
          context.router.pop();
        } else {
          context.router.navigate(const DashboardRoute());
        }
      },
      icon: Icon(
        color: color,
        canPop
            ? (!kIsWeb && (Platform.isMacOS || Platform.isIOS))
                  ? Symbols.arrow_back_ios_new
                  : Symbols.arrow_back
            : Symbols.home,
        shadows: shadows,
      ),
    );
  }
}

const kAppBackgroundImagePath = 'island_app_background';

final backgroundImageFileProvider = FutureProvider<File?>((ref) async {
  if (kIsWeb) return null;
  final dir = await getApplicationSupportDirectory();
  final path = '${dir.path}/$kAppBackgroundImagePath';
  final file = File(path);
  return file.existsSync() ? file : null;
});

final backgroundImageProvider = Provider<File?>((ref) {
  final asyncValue = ref.watch(backgroundImageFileProvider);
  if (asyncValue.hasValue) {
    return asyncValue.value;
  }
  return null;
});

final backgroundMemoryImageProvider = FutureProvider<MemoryImage?>((ref) async {
  if (kIsWeb) return null;

  final file = ref.watch(backgroundImageProvider);
  if (file == null) return null;

  try {
    final bytes = await file.readAsBytes();
    return MemoryImage(bytes);
  } catch (e) {
    return null;
  }
});

class AppBackground extends ConsumerWidget {
  final Widget child;
  final bool isRoot;

  const AppBackground({super.key, required this.child, this.isRoot = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final backgroundMemoryImage = ref.watch(backgroundMemoryImageProvider);
    final showBackground = ref.watch(
      appSettingsProvider.select((s) => s.showBackgroundImage),
    );

    if (isRoot || !isWideScreen(context)) {
      if (backgroundMemoryImage.hasValue &&
          backgroundMemoryImage.value != null &&
          showBackground) {
        return Material(
          color: Theme.of(context).colorScheme.surface,
          child: Container(
            decoration: BoxDecoration(
              backgroundBlendMode: BlendMode.darken,
              color: Theme.of(context).colorScheme.surface,
              image: DecorationImage(
                opacity: 0.2,
                image: backgroundMemoryImage.value!,
                fit: BoxFit.cover,
              ),
            ),
            child: child,
          ),
        );
      }
      return Material(
        color: Theme.of(context).colorScheme.surface,
        child: child,
      );
    }

    return Material(color: Colors.transparent, child: child);
  }
}

class EmptyPageHolder extends HookConsumerWidget {
  const EmptyPageHolder({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasBackground = ref.watch(backgroundImageFileProvider).value != null;
    if (hasBackground) {
      return const SizedBox.shrink();
    }
    return Container(color: Theme.of(context).scaffoldBackgroundColor);
  }
}

class WebSocketIndicator extends HookConsumerWidget {
  const WebSocketIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDesktop =
        !kIsWeb && (Platform.isMacOS || Platform.isWindows || Platform.isLinux);

    final devicePadding = MediaQuery.of(context).padding;

    final user = ref.watch(userInfoProvider);
    final websocketState = ref.watch(websocketStateProvider);

    Color indicatorColor;
    String indicatorText;
    Widget indicatorIcon;
    bool isInteractive = true;
    double opacity = 0.0;

    if (websocketState == WebSocketState.connected()) {
      indicatorColor = Colors.green;
      indicatorText = 'connectionConnected';
      indicatorIcon = Icon(Symbols.power, color: Colors.white, size: 16);
      opacity = 0.0;
      isInteractive = false;
    } else if (websocketState == WebSocketState.connecting()) {
      indicatorColor = Colors.teal;
      indicatorText = 'connectionReconnecting';
      indicatorIcon = SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          strokeWidth: 2,
          padding: EdgeInsets.zero,
        ),
      );
      opacity = 1.0;
      isInteractive = false;
    } else if (websocketState == WebSocketState.internetChanged()) {
      indicatorColor = Colors.amber;
      indicatorText = 'connectionInternetChanged';
      indicatorIcon = Icon(Symbols.wifi, color: Colors.white, size: 16);
      opacity = 1.0;
      isInteractive = false;
    } else if (websocketState == WebSocketState.serverDown()) {
      indicatorColor = Colors.red;
      indicatorText = 'connectionServerDown';
      isInteractive = true;
      indicatorIcon = Icon(Symbols.power_off, color: Colors.white, size: 16);
      opacity = 1.0;
    } else {
      indicatorColor = Colors.red;
      indicatorText = 'connectionDisconnected';
      indicatorIcon = Icon(Symbols.power_off, color: Colors.white, size: 16);
      opacity = 1.0;
      isInteractive = false;
    }

    if (user.value == null) {
      opacity = 0.0;
    }

    const animationDuration = Duration(milliseconds: 320);
    final visible = opacity > 0;
    final anchorTop = devicePadding.top + (isDesktop ? 27.5 : 25);

    final animationController = useAnimationController(
      duration: animationDuration,
      initialValue: visible ? 1 : 0,
    );
    useEffect(() {
      if (visible) {
        animationController.forward();
      } else {
        animationController.reverse();
      }
      return null;
    }, [visible, animationController]);
    final animation = CurvedAnimation(
      parent: animationController,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );

    // Park the pill above the viewport edge when hidden; the Stack clips it,
    // so it genuinely slides in from beyond the top of the screen rather than
    // fading in place. The offset clears the tallest status-bar inset plus the
    // pill's own height.
    const hiddenTop = -100.0;

    return AnimatedPositioned(
      duration: animationDuration,
      curve: Curves.easeOutCubic,
      top: visible ? anchorTop : hiddenTop,
      left: 0,
      right: 0,
      child: IgnorePointer(
        ignoring: !isInteractive || !visible,
        child: Align(
          alignment: Alignment.topCenter,
          // Uniform scale, not a clip or a horizontal stretch: those cut or
          // smear the elevation shadow into a hard edge mid-flight. Growing
          // from a smaller pill keeps the shadow's rounded silhouette.
          child: FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.6, end: 1.0).animate(animation),
              alignment: Alignment.topCenter,
              child: AnimatedSize(
                duration: animationDuration,
                curve: Curves.easeOutCubic,
                alignment: Alignment.topCenter,
                child: Material(
                  elevation: 4,
                  borderRadius: BorderRadius.circular(999),
                  clipBehavior: Clip.antiAlias,
                  child: GestureDetector(
                    onTap: () {
                      ref
                          .read(websocketStateProvider.notifier)
                          .manualReconnect();
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: indicatorColor,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        spacing: 8,
                        children: [
                          AnimatedSwitcher(
                            duration: Duration(milliseconds: 300),
                            child: indicatorIcon,
                          ),
                          Text(
                            indicatorText,
                            style: TextStyle(color: Colors.white, fontSize: 13),
                          ).tr(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
