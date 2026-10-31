import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';
import 'package:material_ui/material_ui.dart';
import 'package:island/core/theme.dart';
import 'package:island/shared/widgets/glass_effects.dart';

/// Alpha of the pill's shadow once it is fully surfaced.
const double _kPillShadowOpacity = 0.12;

/// Alpha of the solid chrome's hairline once it is fully surfaced.
const double _kPillBorderOpacity = 0.5;

/// Stroke of the ring a loading pill paints along its own edge.
const double _kPillRingStroke = 2.0;

/// Share of the capsule's perimeter the indeterminate ring sweeps.
const double _kPillRingSweep = 0.26;

/// One full lap of the indeterminate ring.
const Duration _kPillRingPeriod = Duration(milliseconds: 1100);

/// How long the loading border takes to fade in or out.
///
/// Long enough for the ring and the glass to hand over to each other without
/// a blink, short enough that the bar still reads as reacting at once.
const Duration _kPillRingFade = Duration(milliseconds: 220);

/// The painted chrome of a floating pill.
///
/// Geometry is fixed: the capsule keeps the same [margin], radius and height
/// at every scroll offset, so its controls never move under the user's thumb.
/// Only the surface fades in with [t] (0..1): invisible at rest, glass over
/// the content beneath once the page moves.
///
/// The glass is the iOS 27 regular material from `liquid_glass_renderer`: a
/// [LiquidGlassLayer] samples the page behind the capsule and refracts it
/// through a [LiquidRoundedSuperellipse], drawing the contour, glint and inner
/// shadow from Apple's measured profile rather than from a flat blur + tint.
/// The fade rides the material's own visibility, so the refraction, frost and
/// lighting all dissolve together and the controls on top stay fully opaque.
/// A soft shadow comes with the fill and is scaled by [t], so a pill over an
/// empty page stays completely flat.
///
/// When [GlassEffects] is off — or the platform cannot run the shader — the
/// capsule is painted as a flat fill plus a hairline instead. Same geometry,
/// same fade, no backdrop sample: the setting exists so a user can trade the
/// material for the frames it costs.
///
/// The layer is skipped while [t] is 0: there is nothing under the bar, and
/// an idle layer would still copy the backdrop.
///
/// A loading pill laps its own outline instead of sitting still: see
/// [loading].
class PillSurface extends StatelessWidget {
  /// Fade position, 0..1. Drives the glass and shadow together.
  final double t;

  /// Outer margin of the capsule, painted against the container it floats in.
  final EdgeInsets margin;

  final BorderRadius radius;

  /// Inset of [child] inside the capsule. The capsule's end caps bite into the
  /// bar, so the controls keep a full spacing step of inset from the edge.
  final EdgeInsets contentPadding;

  final Widget child;

  /// Draw the capsule's outline as a spinner: an arc laps the edge.
  ///
  /// The ring deliberately ignores [t]. The glass only exists once content has
  /// slid under the bar, but a loader has to be legible while the page is
  /// still sitting at its top, so it paints over a fully transparent pill.
  final bool loading;

  const PillSurface({
    super.key,
    required this.t,
    required this.margin,
    required this.radius,
    required this.contentPadding,
    required this.child,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final brightness = theme.brightness;
    final glass = GlassEffects.of(context);
    return Container(
      margin: margin,
      // `passthrough` so the pill's height comes from its controls: the glass
      // layer is positioned and contributes no size of its own.
      child: Stack(
        fit: StackFit.passthrough,
        children: [
          // The surface, painted under everything else the bar draws.
          if (t > 0)
            Positioned.fill(
              child: glass
                  ? LiquidGlassLayer(
                      settings: LiquidGlassSettings.ios27Regular(
                        brightness: brightness,
                      ),
                      // `defaultAppearance` rather than a per-shape appearance:
                      // the pill holds a single shape, and the layer-level
                      // appearance is the cheaper shader path.
                      defaultAppearance: LiquidGlassAppearance.ios27Regular(
                        brightness: brightness,
                      ).copyWith(visibility: t),
                      // The layer sizes itself from this box; the shape takes
                      // the capsule's whole area and paints no content of its
                      // own.
                      child: LiquidGlass(
                        shape: LiquidRoundedSuperellipse(
                          borderRadius: radius.topLeft.x,
                        ),
                        child: const SizedBox.expand(),
                      ),
                    )
                  // Solid fallback: the same capsule, filled from the theme
                  // and edged with a hairline, faded by the same [t]. No
                  // backdrop copy, no shader pass.
                  : DecoratedBox(
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHigh.withValues(
                          alpha: t,
                        ),
                        borderRadius: radius,
                        border: Border.all(
                          color: colorScheme.outlineVariant.withValues(
                            alpha: _kPillBorderOpacity * t,
                          ),
                        ),
                      ),
                    ),
            ),
          // The shadow lives outside the glass layer: the layer's backdrop
          // pass is bounded by the capsule, while a box shadow has to spill
          // past it. Animated rather than a bare [DecoratedBox] so entering
          // and leaving the loading state dissolves the edge with the ring.
          AnimatedContainer(
            duration: _kPillRingFade,
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              borderRadius: radius,
              boxShadow: t == 0
                  ? null
                  : [
                      BoxShadow(
                        color: colorScheme.shadow.withValues(
                          alpha: _kPillShadowOpacity * t,
                        ),
                        blurRadius: 12 * t,
                        offset: Offset(0, 4 * t),
                      ),
                    ],
            ),
            child: Padding(padding: contentPadding, child: child),
          ),
          // The ring keeps a slot while it fades out, so leaving the loading
          // state dissolves the arc instead of clipping it off mid-lap.
          Positioned.fill(
            child: AnimatedSwitcher(
              duration: _kPillRingFade,
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, animation) =>
                  FadeTransition(opacity: animation, child: child),
              child: loading
                  ? _PillRing(
                      key: const ValueKey('pill-ring'),
                      radius: radius,
                      color: colorScheme.primary,
                    )
                  : const SizedBox.shrink(key: ValueKey('pill-ring-idle')),
            ),
          ),
        ],
      ),
    );
  }
}

/// The capsule's own edge as a spinner.
///
/// The arc is extracted from a rounded rect of the caller's [radius] and
/// swept clockwise, so it reads as the pill's border lapping rather than as
/// a separate widget laid over it.
class _PillRing extends StatefulWidget {
  final BorderRadius radius;
  final Color color;

  const _PillRing({super.key, required this.radius, required this.color});

  @override
  State<_PillRing> createState() => _PillRingState();
}

class _PillRingState extends State<_PillRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: _kPillRingPeriod,
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: IgnorePointer(
        // A childless [CustomPaint] takes its size from its child, and inside
        // the switcher's stack there is none — it would collapse to zero and
        // paint nothing. `SizedBox.expand` gives the painter the bar's box.
        child: SizedBox.expand(
          child: CustomPaint(
            painter: _PillRingPainter(
              radius: widget.radius,
              color: widget.color,
              sweep: _controller,
            ),
          ),
        ),
      ),
    );
  }
}

class _PillRingPainter extends CustomPainter {
  final BorderRadius radius;
  final Color color;
  final Animation<double> sweep;

  _PillRingPainter({
    required this.radius,
    required this.color,
    required this.sweep,
  }) : super(repaint: sweep);

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;

    // Inset by half the stroke so the ring's outer edge lands on the capsule
    // outline the glass contour follows, not half a stroke outside it.
    final outline = radius
        .toRRect(Offset.zero & size)
        .deflate(_kPillRingStroke / 2);
    // A capsule is a single contour, so one metric covers the whole edge.
    final metric = (Path()..addRRect(outline)).computeMetrics().first;
    final total = metric.length;
    if (total <= 0) return;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = _kPillRingStroke
      ..strokeCap = StrokeCap.round
      ..color = color;

    // The rounded rect's contour starts at the middle of its top edge, which
    // is exactly where a lap should begin. This offsets the *extraction*
    // only, never the canvas: rotating the canvas would turn the capsule
    // itself and paint the arc down the page.
    final start = (sweep.value * total) % total;
    final extent = total * _kPillRingSweep;

    void draw(double from, double to) {
      if (to - from < 0.5) return;
      canvas.drawPath(
        metric.extractPath(from.clamp(0.0, total), to.clamp(0.0, total)),
        paint,
      );
    }

    if (start + extent <= total) {
      draw(start, start + extent);
    } else {
      // The lap straddles the seam: paint the tail and the head separately.
      draw(start, total);
      draw(0, start + extent - total);
    }
  }

  @override
  bool shouldRepaint(covariant _PillRingPainter oldDelegate) {
    return oldDelegate.radius != radius || oldDelegate.color != color;
  }
}

/// Side gutter of a pill: the capsule sits [SolSpace.md] in from each edge of
/// its container so the end caps clear it.
const double kPillSideGutter = SolSpace.md;

/// Inner height of a pill bar's capsule — the glass box itself, before the
/// status-bar inset and the top gutter are added on top.
const double kPillBarContentHeight = SolSpace.control + SolSpace.md;
