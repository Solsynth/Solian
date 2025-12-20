import 'dart:io';
import 'dart:ui';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:island/pods/config.dart';
import 'package:island/route.dart';
import 'package:island/pods/userinfo.dart';
import 'package:island/pods/websocket.dart';
import 'package:island/services/event_bus.dart';
import 'package:island/services/responsive.dart';
import 'package:island/widgets/alert.dart';
import 'package:island/widgets/cmp/pattle.dart';
import 'package:island/widgets/upload_overlay.dart';
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

    final router = ref.watch(routerProvider);

    final pageActionsButton = [
      if (router.canPop())
        IconButton(
          icon: Icon(Symbols.close),
          onPressed: router.canPop() ? () => router.pop() : null,
          iconSize: 16,
          padding: EdgeInsets.all(8),
          constraints: BoxConstraints(),
          color: Theme.of(context).iconTheme.color,
        )
      else
        IconButton(
          icon: Icon(Symbols.home),
          onPressed: () => router.go('/'),
          iconSize: 16,
          padding: EdgeInsets.all(8),
          constraints: BoxConstraints(),
          color: Theme.of(context).iconTheme.color,
        ),
      const Gap(8),
    ];

    final popHotKey = HotKey(
      identifier: 'return_previous_page',
      key: PhysicalKeyboardKey.escape,
      scope: HotKeyScope.inapp,
    );
    final cmpHotKey = HotKey(
      identifier: 'open_command_pattle',
      key: PhysicalKeyboardKey.tab,
      modifiers: [HotKeyModifier.shift],
      scope: HotKeyScope.inapp,
    );

    useEffect(() {
      hotKeyManager.register(
        popHotKey,
        keyDownHandler: (_) {
          if (closeTopmostOverlayDialog()) {
            return;
          }

          // If no overlay to close, pop the route
          if (ref.watch(routerProvider).canPop()) {
            ref.read(routerProvider).pop();
          }
        },
      );

      hotKeyManager.register(
        cmpHotKey,
        keyDownHandler: (_) {
          showPalette.value = true;
        },
      );

      ShakeDetector detector = ShakeDetector.autoStart(
        onPhoneShake: (_) {
          showPalette.value = true;
        },
      );

      return () {
        hotKeyManager.unregister(popHotKey);
        hotKeyManager.unregister(cmpHotKey);
        detector.stopListening();
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
                            if (isWideScreen(context))
                              Row(
                                children: [
                                  const Spacer(),
                                  ...pageActionsButton,
                                ],
                              )
                            else
                              SizedBox(height: 32),
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
            const UploadOverlay(),
            if (showPalette.value)
              CommandPattleWidget(onDismiss: () => showPalette.value = false),
          ],
        ),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(child: child),
        _WebSocketIndicator(),
        const UploadOverlay(),
        if (showPalette.value)
          CommandPattleWidget(onDismiss: () => showPalette.value = false),
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
    final focusNode = useFocusNode();

    useEffect(() {
      focusNode.requestFocus();
      return null;
    }, []);

    final appBarHeight = appBar?.preferredSize.height ?? 0;
    final safeTop = MediaQuery.of(context).padding.top;

    final noBackground = isNoBackground ?? isWideScreen(context);

    final builtWidget = Focus(
      focusNode: focusNode,
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
  const PageBackButton({
    super.key,
    this.shadows,
    this.onWillPop,
    this.color,
    this.backTo,
  });

  @override
  Widget build(BuildContext context) {
    final hasPageAction = !kIsWeb && Platform.isMacOS;

    if (hasPageAction && isWideScreen(context)) return const SizedBox.shrink();

    return IconButton(
      onPressed: () {
        onWillPop?.call();
        if (context.canPop()) {
          context.pop();
        } else {
          context.go(backTo ?? '/');
        }
      },
      icon: Icon(
        color: color,
        context.canPop()
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

class AppBackground extends ConsumerWidget {
  final Widget child;
  final bool isRoot;

  const AppBackground({super.key, required this.child, this.isRoot = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imageFileAsync = ref.watch(backgroundImageFileProvider);
    final settings = ref.watch(appSettingsProvider);

    if (isRoot || !isWideScreen(context)) {
      return imageFileAsync.when(
        data: (file) {
          if (file != null && settings.showBackgroundImage) {
            return Container(
              color: Theme.of(context).colorScheme.surface,
              child: Container(
                decoration: BoxDecoration(
                  backgroundBlendMode: BlendMode.darken,
                  color: Theme.of(context).colorScheme.surface,
                  image: DecorationImage(
                    opacity: 0.2,
                    image: FileImage(file),
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
        },
        loading: () => const SizedBox(),
        error: (_, _) => Material(
          color: Theme.of(context).colorScheme.surface,
          child: child,
        ),
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

    final user = ref.watch(userInfoProvider);
    final websocketState = ref.watch(websocketStateProvider);
    final indicatorHeight =
        MediaQuery.of(context).padding.top + (isDesktop ? 27.5 : 25);

    Color indicatorColor;
    String indicatorText;

    if (websocketState == WebSocketState.connected()) {
      indicatorColor = Colors.green;
      indicatorText = 'connectionConnected';
    } else if (websocketState == WebSocketState.connecting()) {
      indicatorColor = Colors.teal;
      indicatorText = 'connectionReconnecting';
    } else {
      indicatorColor = Colors.red;
      indicatorText = 'connectionDisconnected';
    }

    return AnimatedPositioned(
      duration: Duration(milliseconds: 1850),
      top:
          user.value == null ||
              user.value == null ||
              websocketState == WebSocketState.connected()
          ? -indicatorHeight
          : 0,
      curve: Curves.fastLinearToSlowEaseIn,
      left: 0,
      right: 0,
      height: indicatorHeight,
      child: IgnorePointer(
        child: Material(
          elevation:
              user.value == null || websocketState == WebSocketState.connected()
              ? 0
              : 4,
          child: AnimatedContainer(
            duration: Duration(milliseconds: 300),
            color: indicatorColor,
            child: Center(
              child: Text(
                indicatorText,
                style: TextStyle(color: Colors.white, fontSize: 16),
              ).tr(),
            ).padding(top: MediaQuery.of(context).padding.top),
          ),
        ),
      ),
    );
  }
}
