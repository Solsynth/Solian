import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:island/core/navigation/navigation_rail_scope.dart';
import 'package:island/core/theme.dart';
import 'package:island/shared/widgets/app_scaffold.dart';
import 'package:island/shared/widgets/pill_surface.dart';

/// The navigation toggle shared by the root tabs.
///
/// The drawer is no longer reachable from a floating button or the bottom
/// navigation bar, so every root tab's leading slot uses this exact button.
///
/// On the wide layout the rail replaces the drawer, so the same button expands
/// and collapses the rail over every destination instead. In landscape the
/// shell moves that toggle to the rail's bottom-left corner and page app bars
/// drop their copy, leaving a single entry point.
class SolDrawerButton extends StatelessWidget {
  final Color? color;

  /// Set when the shell renders this button in the rail's bottom slot.
  final bool pinnedToRail;

  const SolDrawerButton({super.key, this.color, this.pinnedToRail = false});

  /// Whether a page-level (non-rail) copy of this button would be visible.
  ///
  /// In landscape the rail owns the toggle, so page headers drop theirs.
  static bool isShownIn(BuildContext context) {
    final rail = NavigationRailScope.maybeOf(context);
    return rail == null ||
        !rail.available ||
        MediaQuery.orientationOf(context) == Orientation.portrait;
  }

  @override
  Widget build(BuildContext context) {
    // An explicit [color] wins in both layouts: callers pass it when the
    // button sits on a custom backdrop (e.g. the account header image) where
    // the theme's app bar foreground would be unreadable.
    final foreground =
        color ??
        Theme.of(context).appBarTheme.foregroundColor ??
        Theme.of(context).colorScheme.onSurface;
    final rail = NavigationRailScope.maybeOf(context);
    if (rail != null && rail.available) {
      if (!pinnedToRail &&
          MediaQuery.orientationOf(context) == Orientation.landscape) {
        return const SizedBox.shrink();
      }
      return IconButton(
        icon: const Icon(Symbols.menu_rounded),
        color: foreground,
        tooltip: (rail.expanded ? 'collapse' : 'expand').tr(),
        onPressed: rail.toggle,
      );
    }
    return IconButton(
      icon: const Icon(Symbols.menu_rounded),
      color: foreground,
      tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
      onPressed: () => rootScaffoldKey.currentState?.openDrawer(),
    );
  }
}

/// Diameter of the standalone glass navigation control.
///
/// The control is pinned to the height every split pill header uses, so the
/// hamburger and the capsule beside it read as one row.
const double kGlassNavigationButtonSize = 48;

/// Height of a split pill header's control row, excluding the status-bar inset.
///
/// The row is the navigation circle's own height, plus the pill's top gutter
/// and [SolSpace.xs] underneath, so the band matches the single capsule's.
const double kPillSplitBarBand =
    kPillSideGutter + kGlassNavigationButtonSize + SolSpace.xs;

/// A single glass-circle navigation toggle.
///
/// Pages without a header pill (the dashboard) and split headers use it as a
/// standalone control: the same [SolDrawerButton] behaviour wrapped in the
/// app's liquid-glass surface. [t] fades that surface the way a pill header
/// fades its capsule.
class GlassNavigationButton extends StatelessWidget {
  final Color? color;

  /// Surface fade, 0..1.
  final double t;

  const GlassNavigationButton({super.key, this.color, this.t = 1});

  @override
  Widget build(BuildContext context) {
    return PillSurface(
      t: t,
      margin: EdgeInsets.zero,
      radius: SolRadius.pillRadius,
      contentPadding: EdgeInsets.zero,
      child: SizedBox.square(
        dimension: kGlassNavigationButtonSize,
        child: Material(
          color: Colors.transparent,
          child: SolDrawerButton(color: color),
        ),
      ),
    );
  }
}

/// App bar used by the root tabs.
///
/// The title is left aligned, and the leading slot always shows something the
/// user can act on: a back button when the page has something to pop, and the
/// drawer toggle otherwise. The drawer no longer floats over the content or
/// lives inside the bottom navigation bar — this leading slot is its single
/// entry point.
class PageAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget? title;
  final String? titleText;
  final List<Widget> actions;
  final PreferredSizeWidget? bottom;
  final bool automaticallyImplyLeading;

  const PageAppBar({
    super.key,
    this.title,
    this.titleText,
    this.actions = const <Widget>[],
    this.bottom,
    this.automaticallyImplyLeading = true,
  });

  @override
  Size get preferredSize => Size.fromHeight(
    SolSpace.control + 12 + (bottom?.preferredSize.height ?? 0),
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final foreground =
        theme.appBarTheme.foregroundColor ?? colorScheme.onSurface;

    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: theme.appBarTheme.backgroundColor,
      surfaceTintColor: Colors.transparent,
      scrolledUnderElevation: 0,
      foregroundColor: foreground,
      actionsPadding: const EdgeInsets.only(right: SolSpace.sm),
      leading: automaticallyImplyLeading
          ? _PageLeadingButton(foreground: foreground)
          : null,
      title:
          title ??
          (titleText == null
              ? null
              : Text(titleText!, maxLines: 1, overflow: TextOverflow.ellipsis)),
      actions: actions,
      bottom: bottom,
    );
  }
}

/// Back button when the router can pop, drawer toggle otherwise.
///
/// The page below the tab shell builds inside its own [Scaffold] (from
/// [AppScaffold]), so `Scaffold.maybeOf` cannot see the shell's drawer. The
/// drawer availability therefore comes from the shell's global scaffold key.
class _PageLeadingButton extends StatelessWidget {
  final Color foreground;

  const _PageLeadingButton({required this.foreground});

  @override
  Widget build(BuildContext context) {
    if (context.router.canPop()) {
      final useIosArrow = defaultTargetPlatform == TargetPlatform.iOS;
      return IconButton(
        icon: Icon(
          useIosArrow ? Symbols.arrow_back_ios_new : Symbols.arrow_back,
        ),
        color: foreground,
        tooltip: MaterialLocalizations.of(context).backButtonTooltip,
        onPressed: () => context.router.maybePop(),
      );
    }
    if (rootScaffoldKey.currentState?.hasDrawer == true) {
      return const SolDrawerButton();
    }
    return const SizedBox.shrink();
  }
}
