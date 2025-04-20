import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:styled_widget/styled_widget.dart';

class WindowScaffold extends StatelessWidget {
  final Widget child;
  const WindowScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
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
        child: Column(
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
      );
    }
    return child;
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
  final bool noBackground;

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
    this.noBackground = false,
  });

  @override
  Widget build(BuildContext context) {
    final appBarHeight = appBar?.preferredSize.height ?? 0;
    final safeTop = MediaQuery.of(context).padding.top;

    final content = Column(
      children: [
        IgnorePointer(
          child: SizedBox(height: appBar != null ? appBarHeight + safeTop : 0),
        ),
        if (body != null) Expanded(child: body!),
      ],
    );

    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      backgroundColor:
          noBackground
              ? Colors.transparent
              : Theme.of(context).scaffoldBackgroundColor,
      body: SizedBox.expand(
        child:
            noBackground
                ? content
                : AppBackground(isRoot: true, child: content),
      ),
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
  const PageBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BackButton(
      onPressed: () {
        context.router.maybePop();
      },
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

    if (isRoot || ResponsiveBreakpoints.of(context).smallerOrEqualTo(MOBILE)) {
      return imageFileAsync.when(
        data: (file) {
          if (file != null) {
            final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;

            final size = MediaQuery.of(context).size;
            return Container(
              color: Theme.of(context).colorScheme.surface,
              child: Container(
                decoration: BoxDecoration(
                  backgroundBlendMode: BlendMode.darken,
                  color: Theme.of(context).colorScheme.surface,
                  image: DecorationImage(
                    opacity: 0.2,
                    image: ResizeImage(
                      FileImage(file),
                      width: (size.width * devicePixelRatio).round(),
                      height: (size.height * devicePixelRatio).round(),
                      policy: ResizeImagePolicy.fit,
                    ),
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
            (_, __) => Material(
              color: Theme.of(context).colorScheme.surface,
              child: child,
            ),
      );
    }

    return Material(color: Colors.transparent, child: child);
  }
}
