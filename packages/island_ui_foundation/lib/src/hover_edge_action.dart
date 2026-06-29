import 'package:flutter/material.dart';

class HoverEdgeAction extends StatelessWidget {
  const HoverEdgeAction({
    super.key,
    required this.axis,
    required this.leading,
    required this.isVisible,
    required this.onTap,
    required this.child,
    this.size = 40,
    this.hiddenDistance = 0.4,
    this.duration = const Duration(milliseconds: 180),
    this.curve = Curves.easeOutCubic,
    this.backgroundColor = Colors.black45,
    this.shape = const CircleBorder(),
    this.padding = EdgeInsets.zero,
    this.constraints,
  });

  final Axis axis;
  final bool leading;
  final bool isVisible;
  final VoidCallback? onTap;
  final Widget child;
  final double size;
  final double hiddenDistance;
  final Duration duration;
  final Curve curve;
  final Color backgroundColor;
  final ShapeBorder shape;
  final EdgeInsetsGeometry padding;
  final BoxConstraints? constraints;

  Offset get _hiddenOffset {
    if (axis == Axis.vertical) {
      return Offset(0, leading ? -hiddenDistance : hiddenDistance);
    }

    return Offset(leading ? -hiddenDistance : hiddenDistance, 0);
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: !isVisible || onTap == null,
      child: AnimatedSlide(
        duration: duration,
        curve: curve,
        offset: isVisible ? Offset.zero : _hiddenOffset,
        child: AnimatedOpacity(
          duration: duration,
          curve: curve,
          opacity: isVisible ? 1 : 0,
          child: Center(
            child: Material(
              color: backgroundColor,
              shape: shape,
              clipBehavior: Clip.antiAlias,
              child: ConstrainedBox(
                constraints:
                    constraints ??
                    BoxConstraints.tightFor(width: size, height: size),
                child: InkWell(
                  onTap: onTap,
                  child: Padding(padding: padding, child: child),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
