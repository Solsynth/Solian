import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/services/responsive.dart';

/// A general-purpose responsive sidebar widget that adapts to screen size.
///
/// On wide screens: Shows the sidebar as a sliding panel next to the main content
/// On narrow screens: Shows the sidebar in an end drawer
class ResponsiveSidebar extends HookConsumerWidget {
  /// The content to display in the sidebar
  final Widget sidebarContent;

  /// The main content widget
  final Widget mainContent;

  /// The width of the sidebar when displayed on wide screens
  final double sidebarWidth;

  /// Controls whether the sidebar is visible
  final ValueNotifier<bool> showSidebar;

  /// Optional custom drawer widget for narrow screens.
  /// If not provided, [sidebarContent] will be used inside a default [Drawer].
  final Widget? drawerWidget;

  /// Background color for the sidebar on wide screens.
  /// If not provided, uses [Theme.of(context).colorScheme.surfaceContainer].
  final Color? sidebarBackgroundColor;

  /// Elevation for the sidebar on wide screens
  final double sidebarElevation;

  /// Duration for the sidebar slide animation
  final Duration animationDuration;

  /// Curve for the sidebar slide animation
  final Curve animationCurve;

  /// Whether wide-screen sidebar width can be resized by dragging its edge.
  final bool enableWideResize;

  /// Minimum width for wide-screen sidebar when resizing.
  final double minWideSidebarWidth;

  /// Maximum width for wide-screen sidebar when resizing.
  final double maxWideSidebarWidth;

  /// Minimum width reserved for main content on wide screens.
  final double minMainContentWidth;

  const ResponsiveSidebar({
    super.key,
    required this.sidebarContent,
    required this.mainContent,
    required this.showSidebar,
    this.sidebarWidth = 480,
    this.drawerWidget,
    this.sidebarBackgroundColor,
    this.sidebarElevation = 8,
    this.animationDuration = const Duration(milliseconds: 300),
    this.animationCurve = Curves.easeInOut,
    this.enableWideResize = true,
    this.minWideSidebarWidth = 320,
    this.maxWideSidebarWidth = 720,
    this.minMainContentWidth = 320,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isWide = isWideScreen(context);
    final wideSidebarWidth = useState(sidebarWidth);
    final animationController = useAnimationController(
      duration: animationDuration,
    );
    final animation = useMemoized(
      () => Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: animationController, curve: animationCurve),
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
            scaffoldKey.currentState?.openDrawer();
          } else if (scaffoldKey.currentState?.isEndDrawerOpen ?? false) {
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

    if (isWide) {
      return LayoutBuilder(
        builder: (context, constraints) {
          final constrainedMaxSidebarWidth =
              (constraints.maxWidth - minMainContentWidth)
                  .clamp(minWideSidebarWidth, maxWideSidebarWidth)
                  .toDouble();
          final constrainedSidebarWidth = wideSidebarWidth.value
              .clamp(minWideSidebarWidth, constrainedMaxSidebarWidth)
              .toDouble();
          if (constrainedSidebarWidth != wideSidebarWidth.value) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (wideSidebarWidth.value != constrainedSidebarWidth) {
                wideSidebarWidth.value = constrainedSidebarWidth;
              }
            });
          }

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
                    constrainedSidebarWidth,
                  ),
                  if (showDrawer.value)
                    Positioned(
                      right: 0,
                      top: 0,
                      bottom: 0,
                      width: constrainedSidebarWidth,
                      child: _buildWideScreenSidebar(
                        context,
                        animation,
                        sidebarContent,
                        constrainedSidebarWidth,
                        enableWideResize: enableWideResize,
                        onResize: (deltaX) {
                          final nextWidth = (wideSidebarWidth.value - deltaX)
                              .clamp(
                                minWideSidebarWidth,
                                constrainedMaxSidebarWidth,
                              )
                              .toDouble();
                          wideSidebarWidth.value = nextWidth;
                        },
                      ),
                    ),
                ],
              );
            },
          );
        },
      );
    } else {
      final effectiveDrawer =
          drawerWidget ?? Drawer(width: sidebarWidth, child: sidebarContent);

      return Scaffold(
        key: scaffoldKey,
        endDrawer: effectiveDrawer,
        onEndDrawerChanged: (isOpen) {
          if (!isOpen) {
            showSidebar.value = false;
          }
        },
        body: mainContent,
      );
    }
  }

  Widget _buildWideScreenContent(
    BuildContext context,
    BoxConstraints constraints,
    Animation<double> animation,
    Widget mainContent,
    double currentSidebarWidth,
  ) {
    return Positioned(
      left: 0,
      top: 0,
      bottom: 0,
      width: constraints.maxWidth - animation.value * currentSidebarWidth,
      child: mainContent,
    );
  }

  Widget _buildWideScreenSidebar(
    BuildContext context,
    Animation<double> animation,
    Widget sidebarContent,
    double currentSidebarWidth, {
    required bool enableWideResize,
    required ValueChanged<double> onResize,
  }) {
    final bgColor =
        sidebarBackgroundColor ??
        Theme.of(context).colorScheme.surfaceContainer;

    return Transform.translate(
      offset: Offset((1 - animation.value) * currentSidebarWidth, 0),
      child: SizedBox(
        width: currentSidebarWidth,
        child: Stack(
          children: [
            Material(
              elevation: sidebarElevation,
              color: bgColor,
              child: sidebarContent,
            ),
            if (enableWideResize)
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: MouseRegion(
                  cursor: SystemMouseCursors.resizeColumn,
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onHorizontalDragUpdate: (details) {
                      onResize(details.delta.dx);
                    },
                    child: const SizedBox(width: 12),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
