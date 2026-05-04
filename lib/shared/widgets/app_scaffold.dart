import 'dart:io';
import 'dart:ui';
import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:island/command_palette/palette.dart';
import 'package:island/core/config.dart';
import 'package:island/accounts/account_pod.dart';
import 'package:island/core/websocket.dart';
import 'package:island/core/services/event_bus.dart';
import 'package:island/core/services/responsive.dart';
import 'package:island/core/widgets/embeds/livestream_overlay.dart';
import 'package:island/notifications/notification_overlay.dart';
import 'package:island/route.gr.dart';
import 'package:island/shared/widgets/task_overlay.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shake/shake.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:window_manager/window_manager.dart';

class AppScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch, // default
    PointerDeviceKind.trackpad, // default
    PointerDeviceKind.mouse, // add mouse dragging
  };
}

class WindowScaffold extends HookConsumerWidget {
  final Widget child;
  const WindowScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isMaximized = useState(false);
    final showPalette = useState(false);
    final keyboardFocusNode = useFocusNode();

    useEffect(() {
      keyboardFocusNode.requestFocus();
      return null;
    }, []);

    // Add window resize listener for desktop platforms
    useEffect(() {
      if (!kIsWeb &&
          (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
        void saveWindowSize() {
          windowManager.getBounds().then((bounds) {
            final settingsNotifier = ref.read(appSettingsProvider.notifier);
            settingsNotifier.setWindowSize(bounds.size);
          });
        }

        // Save window size when app is about to close
        WidgetsBinding.instance.addObserver(
          _WindowSizeObserver(saveWindowSize),
        );

        final maximizeListener = _WindowMaximizeListener(isMaximized);
        windowManager.addListener(maximizeListener);
        windowManager.isMaximized().then((max) => isMaximized.value = max);

        return () {
          // Cleanup observer when widget is disposed
          WidgetsBinding.instance.removeObserver(
            _WindowSizeObserver(saveWindowSize),
          );
          windowManager.removeListener(maximizeListener);
        };
      }
      return null;
    }, []);

    // Event bus listener for command palette
    final subscription = useMemoized(
      () => eventBus.on<CommandPaletteTriggerEvent>().listen(
        (_) => showPalette.value = true,
      ),
      [],
    );
    useEffect(() => subscription.cancel, [subscription]);

    final cmpHotKey = HotKey(
      identifier: 'open_command_pattle',
      key: PhysicalKeyboardKey.tab,
      modifiers: [HotKeyModifier.shift],
      scope: HotKeyScope.inapp,
    );

    useEffect(() {
      if (kIsWeb) return null;

      hotKeyManager.register(
        cmpHotKey,
        keyDownHandler: (_) {
          showPalette.value = true;
        },
      );

      ShakeDetector? detactor;
      if (!kIsWeb && (Platform.isIOS && Platform.isAndroid)) {
        detactor = ShakeDetector.autoStart(
          onPhoneShake: (_) {
            showPalette.value = true;
          },
        );
      }

      return () {
        hotKeyManager.unregister(cmpHotKey);
        detactor?.stopListening();
      };
    }, []);

    if (!kIsWeb &&
        (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      return Material(
        color: Theme.of(context).colorScheme.surfaceContainer,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Column(
              children: [
                DragToMoveArea(
                  child: Platform.isMacOS
                      ? Stack(
                          alignment: Alignment.center,
                          children: [
                            const SizedBox(height: 32),
                            Text(
                              'Solar Network',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ],
                        )
                      : Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Image.asset(
                                    Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? 'assets/icons/icon-dark.png'
                                        : 'assets/icons/icon.png',
                                    width: 20,
                                    height: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Solar Network',
                                    textAlign: TextAlign.start,
                                  ),
                                ],
                              ).padding(horizontal: 12, vertical: 5),
                            ),
                            IconButton(
                              icon: Icon(Symbols.minimize),
                              onPressed: () => windowManager.minimize(),
                              iconSize: 16,
                              padding: EdgeInsets.all(8),
                              constraints: BoxConstraints(),
                              color: Theme.of(context).iconTheme.color,
                            ),
                            IconButton(
                              icon: Icon(
                                isMaximized.value
                                    ? Symbols.fullscreen_exit
                                    : Symbols.fullscreen,
                              ),
                              onPressed: () async {
                                if (await windowManager.isMaximized()) {
                                  windowManager.restore();
                                } else {
                                  windowManager.maximize();
                                }
                              },
                              iconSize: 16,
                              padding: EdgeInsets.all(8),
                              constraints: BoxConstraints(),
                              color: Theme.of(context).iconTheme.color,
                            ),
                            IconButton(
                              icon: Icon(Symbols.close),
                              onPressed: () => windowManager.hide(),
                              iconSize: 16,
                              padding: EdgeInsets.all(8),
                              constraints: BoxConstraints(),
                              color: Theme.of(context).iconTheme.color,
                            ),
                          ],
                        ),
                ),
                Expanded(child: child),
              ],
            ),
            _WebSocketIndicator(),
            const TaskOverlay(),
            const NotificationOverlay(),
            const LivestreamFloatingOverlay(),
            if (showPalette.value)
              CommandPaletteWidget(onDismiss: () => showPalette.value = false),
          ],
        ),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(child: child),
        _WebSocketIndicator(),
        const TaskOverlay(),
        const NotificationOverlay(),
        const LivestreamFloatingOverlay(),
        if (showPalette.value)
          CommandPaletteWidget(onDismiss: () => showPalette.value = false),
      ],
    );
  }
}

class _WindowSizeObserver extends WidgetsBindingObserver {
  final VoidCallback onSaveWindowSize;

  _WindowSizeObserver(this.onSaveWindowSize);

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // Save window size when app is paused, detached, or hidden
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached ||
        state == AppLifecycleState.hidden) {
      if (!kIsWeb &&
          (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
        onSaveWindowSize();
      }
    }
  }

  @override
  bool operator ==(Object other) {
    return other is _WindowSizeObserver &&
        other.onSaveWindowSize == onSaveWindowSize;
  }

  @override
  int get hashCode => onSaveWindowSize.hashCode;
}

class _WindowMaximizeListener with WindowListener {
  final ValueNotifier<bool> isMaximized;
  _WindowMaximizeListener(this.isMaximized);

  @override
  void onWindowMaximize() {
    isMaximized.value = true;
  }

  @override
  void onWindowUnmaximize() {
    isMaximized.value = false;
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
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appBarHeight = appBar?.preferredSize.height ?? 0;
    final safeTop = MediaQuery.of(context).padding.top;
    final keyboardFocusNode = useFocusNode();

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
              child: SizedBox(
                height: appBar != null ? appBarHeight + safeTop : 0,
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

class _WebSocketIndicator extends HookConsumerWidget {
  const _WebSocketIndicator();

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
      indicatorIcon = Icon(
        Symbols.power,
        color: Colors.white,
        size: 16,
      );
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
    } else if (websocketState == WebSocketState.serverDown()) {
      indicatorColor = Colors.red;
      indicatorText = 'connectionServerDown';
      isInteractive = true;
      indicatorIcon = Icon(
        Symbols.power_off,
        color: Colors.white,
        size: 16,
      );
      opacity = 1.0;
    } else {
      indicatorColor = Colors.red;
      indicatorText = 'connectionDisconnected';
      indicatorIcon = Icon(
        Symbols.power_off,
        color: Colors.white,
        size: 16,
      );
      opacity = 1.0;
      isInteractive = false;
    }

    if (user.value == null) {
      opacity = 0.0;
    }

    return Positioned(
      top: devicePadding.top + (isDesktop ? 27.5 : 25),
      left: 0,
      right: 0,
      child: IgnorePointer(
        ignoring: !isInteractive,
        child: Align(
          alignment: Alignment.topCenter,
          child: AnimatedOpacity(
            duration: Duration(milliseconds: 300),
            opacity: opacity,
            child: Material(
              elevation:
                  user.value == null ||
                      websocketState == WebSocketState.connected()
                  ? 0
                  : 4,
              borderRadius: BorderRadius.circular(999),
              child: GestureDetector(
                onTap: () {
                  ref.read(websocketStateProvider.notifier).manualReconnect();
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
    );
  }
}
