import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/services/responsive.dart';
import 'package:island/posts/posts_widgets/post/article_sidebar_panel.dart';

class ResponsiveSidebar extends HookConsumerWidget {
  final Widget attachmentsContent;
  final Widget settingsContent;
  final Widget mainContent;
  final double sidebarWidth;
  final ValueNotifier<bool> showSidebar;

  const ResponsiveSidebar({
    super.key,
    required this.attachmentsContent,
    required this.settingsContent,
    required this.mainContent,
    this.sidebarWidth = 480,
    required this.showSidebar,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isWide = isWideScreen(context);
    final animationController = useAnimationController(
      duration: const Duration(milliseconds: 300),
    );
    final animation = useMemoized(
      () => Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: animationController, curve: Curves.easeInOut),
      ),
      [animationController],
    );

    final showDrawer = useState(false);
    final scaffoldKey = useMemoized(() => GlobalKey<ScaffoldState>());

    useEffect(() {
      void listener() {
        final currentIsWide = isWideScreen(context);
        if (currentIsWide) {
          if (showSidebar.value && !showDrawer.value) {
            showDrawer.value = true;
            animationController.forward();
          } else if (!showSidebar.value && showDrawer.value) {
            // Don't set showDrawer.value = false here - let animation complete first
            animationController.reverse();
          }
        } else {
          if (showSidebar.value) {
            scaffoldKey.currentState?.openEndDrawer();
          } else {
            Navigator.of(context).pop();
          }
        }
      }

      showSidebar.addListener(listener);
      // Set initial state after first frame
      WidgetsBinding.instance.addPostFrameCallback((_) => listener());

      return () => showSidebar.removeListener(listener);
    }, []);

    useEffect(() {
      void listener() {
        if (!animationController.isAnimating &&
            animationController.value == 0) {
          showDrawer.value = false;
        }
      }

      animationController.addListener(listener);
      return () => animationController.removeListener(listener);
    }, [animationController]);

    void closeSidebar() {
      showSidebar.value = false;
    }

    if (isWide) {
      return LayoutBuilder(
        builder: (context, constraints) {
          return AnimatedBuilder(
            animation: animation,
            builder: (context, child) {
              return Stack(
                children: [
                  _buildWideScreenContent(
                    context,
                    constraints,
                    animation,
                    mainContent,
                  ),
                  if (showDrawer.value)
                    Positioned(
                      right: 0,
                      top: 0,
                      bottom: 0,
                      width: sidebarWidth,
                      child: _buildWideScreenSidebar(
                        context,
                        animation,
                        attachmentsContent,
                        settingsContent,
                        closeSidebar,
                      ),
                    ),
                ],
              );
            },
          );
        },
      );
    } else {
      return Scaffold(
        key: scaffoldKey,
        endDrawer: Drawer(
          width: sidebarWidth,
          child: ArticleSidebarPanelWidget(
            attachmentsContent: attachmentsContent,
            settingsContent: settingsContent,
            onClose: () {
              showSidebar.value = false;
              Navigator.of(context).pop();
            },
            isWide: false,
            width: sidebarWidth,
          ),
        ),
        body: mainContent,
      );
    }
  }

  Widget _buildWideScreenContent(
    BuildContext context,
    BoxConstraints constraints,
    Animation<double> animation,
    Widget mainContent,
  ) {
    return Positioned(
      left: 0,
      top: 0,
      bottom: 0,
      width: constraints.maxWidth - animation.value * sidebarWidth,
      child: mainContent,
    );
  }

  Widget _buildWideScreenSidebar(
    BuildContext context,
    Animation<double> animation,
    Widget attachmentsContent,
    Widget settingsContent,
    VoidCallback onClose,
  ) {
    return Transform.translate(
      offset: Offset((1 - animation.value) * sidebarWidth, 0),
      child: SizedBox(
        width: sidebarWidth,
        child: Material(
          elevation: 8,
          color: Theme.of(context).colorScheme.surfaceContainer,
          child: ArticleSidebarPanelWidget(
            attachmentsContent: attachmentsContent,
            settingsContent: settingsContent,
            onClose: onClose,
            isWide: true,
            width: sidebarWidth,
          ),
        ),
      ),
    );
  }
}
