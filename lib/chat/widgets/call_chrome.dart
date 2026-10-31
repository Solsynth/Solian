import 'package:easy_localization/easy_localization.dart';
import 'package:gap/gap.dart';
import 'package:island/core/theme.dart';
import 'package:island/shared/widgets/pill_surface.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_symbols_icons/symbols.dart';

/// Side of a call control's touch target.
const double kCallControlSize = 52;

/// Side of a call control once the row cannot hold the full size.
const double kCallControlCompactSize = 44;

/// Height the call's controls band occupies, excluding the bottom safe area.
///
/// There is no capsule around the controls: they sit directly on the stage,
/// one [SolSpace.md] below the content and one [SolSpace.lg] above the bottom
/// inset. The bottom gap is the wider of the two — the row is the last thing
/// on the page, and without it the buttons read as sliding off the edge.
const double kCallControlsHeight = kCallControlSize + SolSpace.md + SolSpace.lg;

/// Side gutter shared by the call's chrome: the header capsule and the
/// controls row both start and end this far from the viewport edge, so the two
/// bands line up as one column rather than drifting a few pixels apart.
const double kCallChromeGutter = SolSpace.lg;

/// Height of the call's header band below the status bar: the header gutter
/// plus the capsule itself. Pages use it to clear the floating header exactly.
const double kCallHeaderBandHeight = kCallChromeGutter + kPillBarContentHeight;

/// The call's identity bar: what the session is, how it is doing, and the
/// actions that belong to the call as a whole.
///
/// Shares the app's liquid glass surface ([PillSurface]) and geometry
/// ([kPillBarContentHeight]) so the floating header matches the appearance
/// and height of the pill app bars across the rest of the app.
class CallHeaderPill extends StatelessWidget {
  final String title;
  final String status;

  /// Trailing actions, already sized for a [kPillBarContentHeight] row.
  final List<Widget> actions;

  /// Status-bar inset the capsule clears.
  final double statusTop;

  /// Leave action. Null omits the button.
  final VoidCallback? onBack;

  final IconData backIcon;

  const CallHeaderPill({
    super.key,
    required this.title,
    required this.status,
    required this.statusTop,
    this.actions = const [],
    this.onBack,
    this.backIcon = Symbols.arrow_back,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return PillSurface(
      t: 1.0,
      margin: EdgeInsets.fromLTRB(
        kCallChromeGutter,
        statusTop + kCallChromeGutter,
        kCallChromeGutter,
        0,
      ),
      radius: SolRadius.pillRadius,
      contentPadding: EdgeInsets.zero,
      child: SizedBox(
        height: kPillBarContentHeight,
        child: Material(
          color: Colors.transparent,
          child: Row(
            children: [
              if (onBack != null) ...[
                const SizedBox(width: SolSpace.xs),
                IconButton(
                  onPressed: onBack,
                  tooltip: 'close'.tr(),
                  icon: Icon(backIcon, color: colorScheme.onSurface),
                  visualDensity: VisualDensity.compact,
                ),
              ] else
                // Without a back button the title still starts on the capsule's
                // inner gutter, not against the end cap: a stadium's curve eats
                // the first few pixels of any glyph placed at its edge.
                const SizedBox(width: SolSpace.xl),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: SolSpace.sm),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        status,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              ...actions,
              // One [SolSpace.sm] of trailing air, mirroring the title's
              // leading inset: the row ends on a compact `IconButton`, whose
              // own padding alone does not clear the capsule's end curve.
              const SizedBox(width: SolSpace.sm),
            ],
          ),
        ),
      ),
    );
  }
}

/// The call's transient status line — reconnecting, renegotiating — as a
/// compact capsule.
///
/// It sits below the header capsule instead of replacing it: the header keeps
/// describing the session while the banner reports what is being retried.
class CallStatusPill extends StatelessWidget {
  final String message;
  final bool loading;
  final IconData? icon;

  const CallStatusPill({
    super.key,
    required this.message,
    this.loading = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: colorScheme.surfaceContainerHigh,
      elevation: 0,
      shape: StadiumBorder(side: BorderSide(color: colorScheme.outlineVariant)),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: SolSpace.md,
          vertical: SolSpace.sm,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (loading)
              SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: colorScheme.primary,
                ),
              )
            else if (icon != null)
              Icon(icon, size: 14, color: colorScheme.error),
            const Gap(SolSpace.sm),
            Flexible(
              child: Text(
                message,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
