import 'package:material_ui/material_ui.dart';

class DraggableOverlaySheet extends StatefulWidget {
  final Widget body;
  final Widget child;
  final double minHeight;
  final double initialHeight;
  final double maxHeight;
  final List<double>? snapHeights;
  final bool useBottomSafeAreaWhenExpanded;
  final bool useBottomSafeAreaWhenCollapsed;
  /// When true, [body] is inset from the bottom by the sheet's visible height
  /// so content lays out above the overlay instead of under it.
  final bool padBody;
  final Duration animationDuration;
  final Curve animationCurve;
  final Color? backgroundColor;
  final Border? border;
  final BorderRadiusGeometry borderRadius;
  final Widget? handle;
  /// Reports the logical sheet height (without safe-area inset).
  final ValueChanged<double>? onHeightChanged;

  const DraggableOverlaySheet({
    super.key,
    required this.body,
    required this.child,
    required this.minHeight,
    required this.initialHeight,
    required this.maxHeight,
    this.snapHeights,
    this.useBottomSafeAreaWhenExpanded = true,
    this.useBottomSafeAreaWhenCollapsed = false,
    this.padBody = false,
    this.animationDuration = const Duration(milliseconds: 180),
    this.animationCurve = Curves.easeOutCubic,
    this.backgroundColor,
    this.border,
    this.borderRadius = const BorderRadius.vertical(top: Radius.circular(24)),
    this.handle,
    this.onHeightChanged,
  });

  @override
  State<DraggableOverlaySheet> createState() => _DraggableOverlaySheetState();
}

class _DraggableOverlaySheetState extends State<DraggableOverlaySheet> {
  late double _height;

  @override
  void initState() {
    super.initState();
    _height = _clamp(widget.initialHeight);
  }

  @override
  void didUpdateWidget(covariant DraggableOverlaySheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    final clamped = _clamp(_height);
    if (clamped != _height) {
      _height = clamped;
    }
  }

  double _clamp(double value) {
    return value.clamp(widget.minHeight, widget.maxHeight);
  }

  bool get _isCollapsed => _height <= widget.minHeight + 4;

  List<double> get _snapHeights {
    final configured = widget.snapHeights ??
        <double>[
          widget.minHeight,
          widget.initialHeight,
          widget.maxHeight,
        ];
    final points = configured.map(_clamp).toSet().toList()..sort();
    return points;
  }

  bool _applyBottomSafeArea(double height) {
    final collapsed = height <= widget.minHeight + 4;
    return !collapsed
        ? widget.useBottomSafeAreaWhenExpanded
        : widget.useBottomSafeAreaWhenCollapsed;
  }

  double _sheetExtent(double height, double bottomInset) {
    return height + (_applyBottomSafeArea(height) ? bottomInset : 0);
  }

  void _setHeight(double value) {
    final next = _clamp(value);
    if (next == _height) return;
    setState(() {
      _height = next;
    });
    widget.onHeightChanged?.call(next);
  }

  void _snapToNearest() {
    final points = _snapHeights;
    if (points.isEmpty) return;
    final nearest = points.reduce(
      (best, point) =>
          (point - _height).abs() < (best - _height).abs() ? point : best,
    );
    _setHeight(nearest);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final applyBottomSafeArea = _applyBottomSafeArea(_height);
    final sheetExtent = _sheetExtent(_height, bottomInset);

    Widget body = widget.body;
    if (widget.padBody) {
      // Content lays out above the sheet; strip bottom safe padding so
      // children don't double-count home-indicator space already in the sheet.
      body = AnimatedPadding(
        duration: widget.animationDuration,
        curve: widget.animationCurve,
        padding: EdgeInsets.only(bottom: sheetExtent),
        child: MediaQuery.removePadding(
          context: context,
          removeBottom: true,
          child: body,
        ),
      );
    }

    return Stack(
      children: [
        Positioned.fill(child: body),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: AnimatedContainer(
            duration: widget.animationDuration,
            curve: widget.animationCurve,
            height: sheetExtent,
            decoration: BoxDecoration(
              color: widget.backgroundColor ?? theme.colorScheme.surface,
              borderRadius: widget.borderRadius,
              border:
                  widget.border ??
                  Border(
                    top: BorderSide(
                      color: theme.colorScheme.outline.withOpacity(0.2),
                    ),
                  ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onVerticalDragUpdate: (details) {
                    _setHeight(_height - details.delta.dy);
                  },
                  onVerticalDragEnd: (_) => _snapToNearest(),
                  onTap: () {
                    final points = _snapHeights;
                    if (_isCollapsed && points.length > 1) {
                      _setHeight(points[1]);
                    } else {
                      _setHeight(widget.minHeight);
                    }
                  },
                  child:
                      widget.handle ??
                      Padding(
                        padding: const EdgeInsets.only(top: 10, bottom: 8),
                        child: Center(
                          child: Container(
                            width: 44,
                            height: 5,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.onSurfaceVariant
                                  .withOpacity(0.35),
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                        ),
                      ),
                ),
                if (!_isCollapsed)
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        bottom: applyBottomSafeArea ? bottomInset : 0,
                      ),
                      child: widget.child,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
