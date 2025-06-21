import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/pods/userinfo.dart';
import 'package:island/pods/websocket.dart';
import 'package:island/route.dart';
import 'package:island/services/responsive.dart';
import 'package:island/widgets/app_notification.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:path_provider/path_provider.dart';
import 'package:styled_widget/styled_widget.dart';

class WindowScaffold extends HookConsumerWidget {
  final Widget child;
  final AppRouter router;
  const WindowScaffold({super.key, required this.child, required this.router});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!kIsWeb &&
        (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
      final windowButtonColor = WindowButtonColors(
        iconNormal: Theme.of(context).colorScheme.primary,
        mouseOver: Theme.of(context).colorScheme.primaryContainer,
        mouseDown: Theme.of(context).colorScheme.onPrimaryContainer,
        iconMouseOver: Theme.of(context).colorScheme.primary,
        iconMouseDown: Theme.of(context).colorScheme.primary,
      );

      return Material(
        child: Stack(
          fit: StackFit.expand,
          children: [
            Column(
              children: [
                WindowTitleBarBox(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Theme.of(context).dividerColor,
                          width: 1 / devicePixelRatio,
                        ),
                      ),
                    ),
                    child: MoveWindow(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment:
                            Platform.isMacOS
                                ? MainAxisAlignment.center
                                : MainAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              'Solar Network',
                              textAlign:
                                  Platform.isMacOS
                                      ? TextAlign.center
                                      : TextAlign.start,
                            ).padding(horizontal: 12, vertical: 5),
                          ),
                          if (!Platform.isMacOS)
                            MinimizeWindowButton(colors: windowButtonColor),
                          if (!Platform.isMacOS)
                            MaximizeWindowButton(colors: windowButtonColor),
                          if (!Platform.isMacOS)
                            CloseWindowButton(
                              colors: windowButtonColor,
                              onPressed: () => appWindow.hide(),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(child: child),
              ],
            ),
            _WebSocketIndicator(),
            AppNotificationToast(),
          ],
        ),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(child: child),
        _WebSocketIndicator(),
        AppNotificationToast(),
      ],
    );
  }
}

final rootScaffoldKey = GlobalKey<ScaffoldState>();

class AppScaffold extends StatelessWidget {
  final Widget? body;
  final PreferredSizeWidget? bottomNavigationBar;
  final PreferredSizeWidget? bottomSheet;
  final Drawer? drawer;
  final Widget? endDrawer;
  final FloatingActionButtonAnimator? floatingActionButtonAnimator;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Widget? floatingActionButton;
  final AppBar? appBar;
  final DrawerCallback? onDrawerChanged;
  final DrawerCallback? onEndDrawerChanged;
  final bool? noBackground;
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
    this.noBackground,
    this.extendBody,
  });

  @override
  Widget build(BuildContext context) {
    final appBarHeight = appBar?.preferredSize.height ?? 0;
    final safeTop = MediaQuery.of(context).padding.top;

    final noBackground = this.noBackground ?? isWideScreen(context);

    final content = Column(
      children: [
        IgnorePointer(
          child: SizedBox(height: appBar != null ? appBarHeight + safeTop : 0),
        ),
        if (body != null) Expanded(child: body!),
      ],
    );

    return Scaffold(
      extendBody: extendBody ?? true,
      extendBodyBehindAppBar: true,
      backgroundColor:
          noBackground
              ? Colors.transparent
              : Theme.of(context).scaffoldBackgroundColor,
      body:
          noBackground ? content : AppBackground(isRoot: true, child: content),
      appBar: appBar,
      bottomNavigationBar: bottomNavigationBar,
      bottomSheet: bottomSheet,
      drawer: drawer,
      endDrawer: endDrawer,
      floatingActionButton: floatingActionButton,
      floatingActionButtonAnimator: floatingActionButtonAnimator,
      floatingActionButtonLocation: floatingActionButtonLocation,
      onDrawerChanged: onDrawerChanged,
      onEndDrawerChanged: onEndDrawerChanged,
    );
  }
}

class PageBackButton extends StatelessWidget {
  final Color? color;
  final List<Shadow>? shadows;
  final VoidCallback? onWillPop;
  const PageBackButton({super.key, this.shadows, this.onWillPop, this.color});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        onWillPop?.call();
        context.router.maybePop();
      },
      icon: Icon(
        color: color,
        (!kIsWeb && (Platform.isMacOS || Platform.isIOS))
            ? Symbols.arrow_back_ios_new
            : Symbols.arrow_back,
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

    if (isRoot || !isWideScreen(context)) {
      return imageFileAsync.when(
        data: (file) {
          if (file != null) {
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
        error:
            (_, _) => Material(
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
    final hasBackground =
        ref.watch(backgroundImageFileProvider).valueOrNull != null;
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
        MediaQuery.of(context).padding.top + (isDesktop ? 27.5 : 60);

    Color indicatorColor;
    String indicatorText;

    if (websocketState == WebSocketState.connected()) {
      indicatorColor = Colors.green;
      indicatorText = 'connectionConnected';
    } else if (websocketState == WebSocketState.connecting()) {
      indicatorColor = Colors.teal;
      indicatorText = 'connectionReconnecting';
    } else {
      indicatorColor = Colors.orange;
      indicatorText = 'connectionDisconnected';
    }

    return AnimatedPositioned(
      duration: Duration(milliseconds: 1850),
      top:
          !user.hasValue ||
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
              !user.hasValue || websocketState == WebSocketState.connected()
                  ? 0
                  : 4,
          child: AnimatedContainer(
            duration: Duration(milliseconds: 300),
            color: indicatorColor,
            child: Center(
              child:
                  Text(
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
