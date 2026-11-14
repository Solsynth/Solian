import 'package:material_ui/material_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:island/core/theme.dart';
import 'package:island/shared/widgets/pill_surface.dart';
import 'package:island/shared/widgets/page_app_bar.dart';

export 'package:island/shared/widgets/pill_surface.dart'
    show kPillBarContentHeight;

/// Scroll distance over which a pill header finishes fading its surface in.
///
/// Tied to roughly one header height: by the time the content has meaningfully
/// slid under the bar, the pill is fully surfaced and can carry its controls.
const double kPillFadeDistance = 96.0;

/// Total height of a pill bar, excluding the status-bar inset.
///
/// A bar reserves `statusTop + kPillAppBarHeight`: the capsule's top margin
/// plus [kPillBarContentHeight]. Anything that has to clear a pill header — a
/// body gap, a scaffold slot, a test assertion — should be computed from this
/// so every pill lands on the same band.
const double kPillAppBarHeight = kPillBarContentHeight + SolSpace.md;

/// Feeds a pill's fade ramp (0..1) from a scroll notification.
///
/// The ramp is read off the scroll offset itself so the surface tracks the
/// drag instead of snapping at the first pixel. [threshold] keeps the pill
/// hidden until the page has scrolled that far, which lets a page open on its
/// artwork before the bar appears. Only the outermost scrollable counts:
/// inside a [NestedScrollView] the inner list reports `depth` 1 and restarts
/// at offset 0 whenever the header re-expands, which would slam the pill back
/// to invisible while content is still under it.
///
/// Returns false so the notification keeps bubbling to other listeners.
bool updatePillFade(
  ScrollNotification notification,
  ValueNotifier<double> fade, {
  double threshold = 0,
}) {
  final metrics = notification.metrics;
  if (notification.depth != 0 || metrics.axis != Axis.vertical) return false;
  final ramp = ((metrics.pixels - threshold) / kPillFadeDistance).clamp(
    0.0,
    1.0,
  );
  if (fade.value != ramp) fade.value = ramp;
  return false;
}

/// Evaluates [builder] with the current fade value (1.0 when [fade] is null),
/// passing [child] through untouched so scroll ticks do not rebuild the bar's
/// inner controls.
Widget _buildWithFade({
  required ValueListenable<double>? fade,
  required Widget child,
  required Widget Function(BuildContext context, double t, Widget child) builder,
}) {
  if (fade == null) {
    return Builder(builder: (context) => builder(context, 1.0, child));
  }
  return ValueListenableBuilder<double>(
    valueListenable: fade,
    child: child,
    builder: (context, t, builtChild) => builder(context, t, builtChild!),
  );
}

/// [PillSurface] for a header: the capsule sits 12px in from each side and
/// 12px below the status bar, and carries [SolSpace.lg] of inner inset — one
/// step wider than the side gutter, so the first control clears the end cap's
/// curve instead of crowding it.
///
/// Wide pages give the bar the window's full width, so the pill spans the
/// viewport rather than hugging the feed column.
///
/// [loading] is forwarded to the [PillSurface], which laps the capsule's own
/// outline as a spinner while it is set.
class PillBarSurface extends StatelessWidget {
  /// Fade position, 0..1. Drives the glass and shadow together.
  final double t;

  /// Status-bar inset, reserved inside the bar's own box.
  final double statusTop;

  /// Lap the capsule's outline as a spinner.
  final bool loading;

  final Widget child;

  const PillBarSurface({
    super.key,
    required this.t,
    required this.statusTop,
    required this.child,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return PillSurface(
      t: t,
      loading: loading,
      margin: EdgeInsets.fromLTRB(
        kPillSideGutter,
        statusTop + kPillSideGutter,
        kPillSideGutter,
        0,
      ),
      radius: SolRadius.pillRadius,
      contentPadding: const EdgeInsets.symmetric(horizontal: SolSpace.lg),
      // The capsule is always exactly `kPillBarContentHeight` tall — a control
      // row plus the composer's vertical padding, so the header is no longer
      // cramped. `PillSurface` sizes the glass to its child, so leaving it to
      // the row would let any child that fills its constraints — an `Expanded`,
      // an `Align`, a `Center` — stretch the pill to whatever height the slot
      // happens to offer, and the glass would then hang over the content the
      // page reserved space for. Pinning it keeps every pill the same shape and
      // makes the bar's `preferredSize` the whole truth.
      child: SizedBox(height: kPillBarContentHeight, child: child),
    );
  }
}

/// A header split into two independent glass surfaces.
///
/// The navigation toggle keeps its own glass circle at the leading edge and
/// the page's controls sit in a capsule beside it, instead of one full-width
/// capsule carrying an empty stretch between them. [fade] drives both
/// surfaces the way [PillBarSurface] does for a single bar; null keeps them
/// surfaced.
///
/// [showNavigation] defaults to [SolDrawerButton.isShownIn], so a page whose
/// rail already owns the toggle simply drops the circle. [trailing] sits in a
/// capsule of its own at the far edge, for a single persistent action.
class PillSplitBar extends StatelessWidget implements PreferredSizeWidget {
  /// Fade position, 0..1. Null keeps every surface surfaced.
  final ValueListenable<double>? fade;

  /// Status-bar inset, reserved inside the bar's own box.
  final double statusTop;

  /// Lap the capsule's outline as a spinner.
  final bool loading;

  /// Draw the navigation circle; null asks the layout.
  final bool? showNavigation;

  /// The content capsule's controls.
  final Widget child;

  /// An action pinned to the trailing edge in its own capsule.
  final Widget? trailing;

  const PillSplitBar({
    super.key,
    this.fade,
    required this.statusTop,
    required this.child,
    this.loading = false,
    this.showNavigation,
    this.trailing,
  });

  @override
  Size get preferredSize => Size.fromHeight(statusTop + kPillSplitBarBand);

  @override
  Widget build(BuildContext context) {
    final pinnedChild = SizedBox(
      height: kGlassNavigationButtonSize,
      child: child,
    );
    final trailing = this.trailing;
    final pinnedTrailing = trailing == null
        ? null
        : SizedBox.square(
            dimension: kGlassNavigationButtonSize,
            child: trailing,
          );

    return _buildWithFade(
      fade: fade,
      child: pinnedChild,
      builder: (context, t, content) {
        final showNav = showNavigation ?? SolDrawerButton.isShownIn(context);
        return SizedBox(
          height: preferredSize.height,
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              kPillSideGutter,
              statusTop + kPillSideGutter,
              kPillSideGutter,
              SolSpace.xs,
            ),
            child: Row(
              children: [
                if (showNav) ...[
                  GlassNavigationButton(t: t),
                  const SizedBox(width: SolSpace.xs),
                ],
                Flexible(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: PillSurface(
                      t: t,
                      loading: loading,
                      margin: EdgeInsets.zero,
                      radius: SolRadius.pillRadius,
                      // Roomier than the old `SolSpace.xs`: the capsule's end
                      // caps curve inwards, so the picker's icon needs a full
                      // spacing step before it clears the contour.
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: SolSpace.md,
                      ),
                      // Pinned to the navigation circle's height so the two
                      // surfaces read as one row instead of a tall capsule
                      // beside a small circle.
                      child: content,
                    ),
                  ),
                ),
                if (pinnedTrailing != null) ...[
                  const SizedBox(width: SolSpace.sm),
                  PillSurface(
                    t: t,
                    margin: EdgeInsets.zero,
                    radius: SolRadius.pillRadius,
                    contentPadding: EdgeInsets.zero,
                    child: pinnedTrailing,
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Pinned header sliver for [PillSplitBar].
///
/// The sliver's geometry never changes and because it is pinned nothing moves
/// the bar: the feed slides underneath while only the surfaces' fill animates.
class PillSplitSliverAppBar extends StatelessWidget {
  final ValueListenable<double>? fade;

  /// Status-bar inset, measured by the caller so the sliver's height matches.
  final double statusTop;

  /// Lap the capsule's outline as a spinner.
  final bool loading;

  /// Draw the navigation circle; null asks the layout.
  final bool? showNavigation;

  /// The content capsule's controls.
  final Widget child;

  /// An action pinned to the trailing edge in its own capsule.
  final Widget? trailing;

  const PillSplitSliverAppBar({
    super.key,
    this.fade,
    required this.statusTop,
    required this.child,
    this.loading = false,
    this.showNavigation,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      primary: false,
      automaticallyImplyLeading: false,
      toolbarHeight: statusTop + kPillSplitBarBand,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      scrolledUnderElevation: 0,
      elevation: 0,
      pinned: true,
      flexibleSpace: PillSplitBar(
        fade: fade,
        statusTop: statusTop,
        loading: loading,
        showNavigation: showNavigation,
        trailing: trailing,
        child: child,
      ),
    );
  }
}

/// Pinned header sliver that keeps a pill in place and fades its surface in
/// with the scroll offset.
///
/// [fade] is driven by [updatePillFade] from the enclosing scroll view. The
/// sliver's own geometry never changes, and because it is pinned nothing moves
/// the bar either: the feed slides underneath it while only the fill animates.
class PillSliverAppBar extends StatelessWidget {
  final ValueListenable<double>? fade;

  /// Status-bar inset, measured by the caller so the sliver's height matches.
  final double statusTop;

  /// Lap the capsule's outline as a spinner.
  final bool loading;

  /// The bar's single row of controls.
  final Widget child;

  const PillSliverAppBar({
    super.key,
    this.fade,
    required this.statusTop,
    required this.child,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      primary: false,
      automaticallyImplyLeading: false,
      // Status bar + the pill's own height.
      toolbarHeight: statusTop + kPillAppBarHeight,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      scrolledUnderElevation: 0,
      elevation: 0,
      pinned: true,
      flexibleSpace: _buildWithFade(
        fade: fade,
        child: child,
        builder: (context, t, content) => PillBarSurface(
          t: t,
          statusTop: statusTop,
          loading: loading,
          child: content,
        ),
      ),
    );
  }
}

/// [PillBarSurface] for a `Scaffold`'s `appBar` slot.
///
/// The same chrome as [PillSliverAppBar] for pages whose content is not one
/// sliver list. The scaffold reserves the bar's height, so the pill floats
/// over whatever the body paints underneath instead of being part of it.
class PillAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// Surface fade, 0..1. Null keeps the capsule surfaced: a persistent
  /// control whose page never slides content under it has no fade to track,
  /// and hiding its fill would leave bare controls floating on the page.
  final ValueListenable<double>? fade;

  /// Status-bar inset, measured by the caller so the bar's height matches.
  final double statusTop;

  /// Lap the capsule's outline as a spinner.
  final bool loading;

  final Widget child;

  const PillAppBar({
    super.key,
    this.fade,
    required this.statusTop,
    required this.child,
    this.loading = false,
  });

  @override
  Size get preferredSize => Size.fromHeight(statusTop + kPillAppBarHeight);

  @override
  Widget build(BuildContext context) {
    return _buildWithFade(
      fade: fade,
      child: child,
      builder: (context, t, content) => PillBarSurface(
        t: t,
        statusTop: statusTop,
        loading: loading,
        child: content,
      ),
    );
  }
}
