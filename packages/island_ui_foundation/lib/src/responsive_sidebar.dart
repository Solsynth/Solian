import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island_ui_foundation/island_ui_foundation.dart';

/// A general-purpose responsive sidebar widget that adapts to screen size.
///
/// On wide screens: Shows the sidebar as a sliding panel beside the main content
/// On narrow screens: Shows the sidebar in a bottom sheet
class ResponsiveSidebar extends HookConsumerWidget {
  /// The content to display in the sidebar
  final Widget sidebarContent;

  /// The main content widget
  final Widget mainContent;

  /// The width of the sidebar when displayed on wide screens
  final double sidebarWidth;

  /// Controls whether the sidebar is visible
  final ValueNotifier<bool> showSidebar;

  /// Whether the sidebar appears on the left side (default: false = right side)
  final bool isLeft;

  /// Optional custom drawer widget for narrow screens.
  final Widget? drawerWidget;

  /// Optional builder function for drawer widget for narrow screens.
  final WidgetBuilder? drawerBuilder;

  /// Background color for the sidebar on wide screens.
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
    this.isLeft = false,
    this.drawerWidget,
    this.drawerBuilder,
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
    final sheetContextRef = useRef<BuildContext?>(null);
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

    useEffect(() {
      void listener() {
        final currentIsWide = isWideScreen(context);
        if (currentIsWide) {
          if (showSidebar.value && !showDrawer.value) {
            showDrawer.value = true;
            animationController.forward();
          } else if (!showSidebar.value && showDrawer.value) {
            animationController.reverse();
          }
        } else {
          if (showSidebar.value && !showDrawer.value) {
            showDrawer.value = true;
            _openSheet(context, sheetContextRef);
          } else if (!showSidebar.value && showDrawer.value) {
            showDrawer.value = false;
            final sheetContext = sheetContextRef.value;
            if (sheetContext != null && Navigator.of(sheetContext).canPop()) {
              Navigator.of(sheetContext).pop();
            }
          }
        }
      }

      showSidebar.addListener(listener);
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
              if (isLeft) {
                return _buildLeftLayout(
                  context,
                  constraints,
                  animation,
                  constrainedSidebarWidth,
                  showDrawer.value,
                  wideSidebarWidth,
                );
              }
              return _buildRightLayout(
                context,
                constraints,
                animation,
                constrainedSidebarWidth,
                showDrawer.value,
                wideSidebarWidth,
              );
            },
          );
        },
      );
    } else {
      return mainContent;
    }
  }

  Widget _buildRightLayout(
    BuildContext context,
    BoxConstraints constraints,
    Animation<double> animation,
    double constrainedSidebarWidth,
    bool showSidebarPanel,
    ValueNotifier<double> wideSidebarWidth,
  ) {
    return Stack(
      children: [
        Positioned(
          left: 0,
          top: 0,
          bottom: 0,
          width: constraints.maxWidth - animation.value * constrainedSidebarWidth,
          child: mainContent,
        ),
        if (showSidebarPanel)
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            width: constrainedSidebarWidth,
            child: _buildSidebarPanel(
              context,
              animation,
              constrainedSidebarWidth,
              isLeft: false,
              wideSidebarWidth: wideSidebarWidth,
            ),
          ),
      ],
    );
  }

  Widget _buildLeftLayout(
    BuildContext context,
    BoxConstraints constraints,
    Animation<double> animation,
    double constrainedSidebarWidth,
    bool showSidebarPanel,
    ValueNotifier<double> wideSidebarWidth,
  ) {
    return Stack(
      children: [
        Positioned(
          right: 0,
          top: 0,
          bottom: 0,
          width: constraints.maxWidth - animation.value * constrainedSidebarWidth,
          child: mainContent,
        ),
        if (showSidebarPanel)
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            width: constrainedSidebarWidth,
            child: _buildSidebarPanel(
              context,
              animation,
              constrainedSidebarWidth,
              isLeft: true,
              wideSidebarWidth: wideSidebarWidth,
            ),
          ),
      ],
    );
  }

  Widget _buildSidebarPanel(
    BuildContext context,
    Animation<double> animation,
    double constrainedSidebarWidth, {
    required bool isLeft,
    required ValueNotifier<double> wideSidebarWidth,
  }) {
    final bgColor =
        sidebarBackgroundColor ??
        Theme.of(context).colorScheme.surfaceContainer;

    final slideOffset = isLeft
        ? Offset(-(1 - animation.value) * constrainedSidebarWidth, 0)
        : Offset((1 - animation.value) * constrainedSidebarWidth, 0);

    return Transform.translate(
      offset: slideOffset,
      child: SizedBox.expand(
        child: Stack(
          children: [
            Positioned.fill(
              child: Material(
                elevation: sidebarElevation,
                color: bgColor,
                child: sidebarContent,
              ),
            ),
            if (enableWideResize)
              Positioned(
                right: isLeft ? 0 : null,
                left: isLeft ? null : 0,
                top: 0,
                bottom: 0,
                child: MouseRegion(
                  cursor: SystemMouseCursors.resizeColumn,
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onHorizontalDragUpdate: (details) {
                      final deltaX = isLeft ? -details.delta.dx : details.delta.dx;
                      final nextWidth = (wideSidebarWidth.value - deltaX)
                          .clamp(
                            minWideSidebarWidth,
                            (MediaQuery.of(context).size.width - minMainContentWidth)
                                .clamp(minWideSidebarWidth, maxWideSidebarWidth)
                                .toDouble(),
                          )
                          .toDouble();
                      wideSidebarWidth.value = nextWidth;
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

  void _openSheet(BuildContext context, ObjectRef<BuildContext?> sheetContextRef) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetContext) {
        sheetContextRef.value = sheetContext;
        if (drawerBuilder != null) {
          return drawerBuilder!(sheetContext);
        }
        return drawerWidget ??
            SheetScaffold(showHeader: false, child: sidebarContent);
      },
    ).then((_) {
      sheetContextRef.value = null;
      showSidebar.value = false;
    });
  }
}
