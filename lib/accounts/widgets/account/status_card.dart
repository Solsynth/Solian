import 'package:easy_localization/easy_localization.dart';
import 'package:material_ui/material_ui.dart';
import 'package:gap/gap.dart';
import 'package:island/core/theme.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

/// The compact status line: one indicator glyph, the status text, and its
/// muted detail. This is the row a profile shows when the status has no
/// artwork, so the composer can preview it verbatim.
class AccountStatusInline extends StatelessWidget {
  final IconData indicatorIcon;
  final double indicatorFill;

  /// Tint of the presence glyph.
  final Color? indicatorColor;

  final String title;
  final InlineSpan? titleTooltip;

  /// 0 positive, 1 neutral, 2 negative. Neutral is the default mood, so it
  /// stays silent; a deliberate one earns a face after the label.
  final int? attitude;

  /// Muted trailing detail (activity, device, or when the status clears).
  final String? meta;

  final bool showIdleBadge;
  final EdgeInsets? padding;
  final VoidCallback? onLongPress;

  const AccountStatusInline({
    super.key,
    required this.indicatorIcon,
    this.indicatorFill = 1,
    this.indicatorColor,
    required this.title,
    this.titleTooltip,
    this.attitude,
    this.meta,
    this.showIdleBadge = false,
    this.padding,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final mutedStyle = theme.textTheme.bodySmall?.copyWith(
      color: colorScheme.onSurfaceVariant,
    );

    final mood = switch (attitude) {
      0 => (
        icon: Symbols.sunny_rounded,
        label: 'attitudePositive'.tr(),
      ),
      2 => (
        icon: Symbols.rainy_rounded,
        label: 'attitudeNegative'.tr(),
      ),
      _ => null,
    };

    final isNeutralOrUnset = mood == null;

    Widget content = Text.rich(
      TextSpan(
        style: theme.textTheme.bodyMedium,
        children: [
          TextSpan(text: title),
          if (showIdleBadge)
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: Padding(
                padding: const EdgeInsets.only(left: 6),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'idle'.tr(),
                    style:
                        TextStyle(fontSize: 11, color: Colors.amber.shade700),
                  ),
                ),
              ),
            ),
          if (meta?.isNotEmpty ?? false) ...[
            const TextSpan(text: ' '),
            TextSpan(
              text: meta!,
              style: mutedStyle,
            ),
          ],
        ],
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
    if (onLongPress != null) {
      content = GestureDetector(onLongPress: onLongPress, child: content);
    }
    if (titleTooltip != null) {
      content = Tooltip(richMessage: titleTooltip, child: content);
    }

    return Padding(
      padding:
          padding ?? const EdgeInsets.symmetric(horizontal: 27, vertical: 4),
      child: Row(
        children: [
          // One mark per row: a mood, when there is one, replaces the presence
          // dot rather than riding next to the text.
          Semantics(
            label: mood?.label,
            child: Icon(
              isNeutralOrUnset ? Symbols.circle_rounded : mood.icon,
              fill: 1,
              color: indicatorColor ?? colorScheme.primary,
              // Faces need a touch more room than a dot to stay legible.
              size: mood != null ? 18 : 16,
            ),
          ),
          // Breathing room: the mark frames the line, it does not sit on the text.
          const Gap(SolSpace.md),
          Flexible(child: content),
        ],
      ),
    );
  }
}

/// The status card, rendered once and reused everywhere a status is shown:
/// profiles, chat and realm member rows, and the composer's live preview.
///
/// Sharing the renderer is what keeps the composer honest — the sheet previews
/// the exact widget peers get, so the two can never drift apart.
class AccountStatusCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? trailingText;

  /// Optional glyph shown before [trailingText] (e.g. a clock or a mood).
  final IconData? trailingIcon;

  final IDisplayableCloudFile? icon;
  final IDisplayableCloudFile? background;

  final IconData indicatorIcon;
  final double indicatorFill;

  /// Tint of the presence indicator when there is no custom [icon].
  final Color? indicatorColor;

  /// 0 positive, 1 neutral, 2 negative. Neutral is the default, so it stays
  /// silent; only a deliberate mood earns a glyph.
  final int? attitude;

  final bool showIdleBadge;

  /// Margin used when there is no [background]; a background card is always
  /// edge-to-edge because it carries its own visual weight.
  final EdgeInsets margin;

  final VoidCallback? onLongPress;

  const AccountStatusCard({
    super.key,
    required this.title,
    this.subtitle,
    this.trailingText,
    this.trailingIcon,
    this.icon,
    this.background,
    this.indicatorIcon = Symbols.circle_rounded,
    this.indicatorFill = 1,
    this.indicatorColor,
    this.attitude,
    this.showIdleBadge = false,
    this.margin = EdgeInsets.zero,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final hasBackground = background != null;
    final textShadow = hasBackground
        ? const [
            Shadow(color: Colors.black54, blurRadius: 8, offset: Offset(0, 2)),
          ]
        : null;
    final moodIcon = switch (attitude) {
      0 => Symbols.sunny_rounded,
      2 => Symbols.rainy_rounded,
      _ => null,
    };
    final isNeutralOrUnset = moodIcon == null;
    final displayIcon = isNeutralOrUnset ? Symbols.circle_rounded : moodIcon;
    const displayFill = 1.0;

    // A status without a custom label falls back to its presence name for the
    // title; repeating it on the line below would say the same thing twice.
    final resolvedSubtitle = subtitle == title ? null : subtitle;

    final leading = icon != null
        ? ProfilePictureWidget(
            file: icon,
            radius: hasBackground ? 24 : 20,
            borderRadius: hasBackground ? 14 : 12,
            fallbackIcon: displayIcon,
            fallbackColor: hasBackground ? Colors.white : indicatorColor,
          )
        : Container(
            width: hasBackground ? 48 : 40,
            height: hasBackground ? 48 : 40,
            decoration: BoxDecoration(
              color: hasBackground
                  ? Colors.white24
                  : colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(hasBackground ? 14 : 12),
            ),
            child: Icon(
              displayIcon,
              fill: displayFill,
              size: isNeutralOrUnset ? (hasBackground ? 20 : 16) : null,
              color: hasBackground
                  ? Colors.white
                  : (indicatorColor ?? colorScheme.onPrimaryContainer),
            ),
          );

    Widget card = Container(
      margin: hasBackground ? EdgeInsets.zero : margin,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            if (hasBackground)
              Positioned.fill(
                child: CloudImageWidget(
                  file: background,
                  aspectRatio: 16 / 9,
                  noBlurhash: true,
                ),
              ),
            if (hasBackground)
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.08),
                        Colors.black.withValues(alpha: 0.38),
                      ],
                    ),
                  ),
                ),
              ),
            Align(
              alignment: hasBackground
                  ? Alignment.bottomLeft
                  : Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    leading,
                    const Gap(12),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            maxLines: hasBackground ? 2 : 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: hasBackground ? Colors.white : null,
                              shadows: textShadow,
                            ),
                          ),
                          if (resolvedSubtitle?.isNotEmpty ?? false)
                            Text(
                              resolvedSubtitle!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: hasBackground
                                    ? Colors.white.withValues(alpha: 0.92)
                                    : colorScheme.onSurfaceVariant,
                                shadows: textShadow,
                              ),
                            ),
                          if ((trailingText?.isNotEmpty ?? false) ||
                              trailingIcon != null)
                            Row(
                              children: [
                                if (trailingIcon != null)
                                  Padding(
                                    padding: const EdgeInsets.only(right: 4),
                                    child: Icon(
                                      trailingIcon,
                                      size: 13,
                                      fill: 1,
                                      color: hasBackground
                                          ? Colors.white.withValues(alpha: 0.82)
                                          : colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                if (trailingText?.isNotEmpty ?? false)
                                  Flexible(
                                    child: Text(
                                      trailingText!,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            color: hasBackground
                                                ? Colors.white.withValues(
                                                    alpha: 0.82,
                                                  )
                                                : colorScheme.onSurfaceVariant,
                                            shadows: textShadow,
                                          ),
                                    ),
                                  ),
                              ],
                            ),
                        ],
                      ),
                    ),
                    if (showIdleBadge)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: hasBackground
                              ? Colors.white24
                              : Colors.amber.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          'idle'.tr(),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: hasBackground
                                ? Colors.white
                                : Colors.amber.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (onLongPress != null) {
      card = GestureDetector(onLongPress: onLongPress, child: card);
    }

    if (hasBackground) {
      return AspectRatio(aspectRatio: 16 / 9, child: card);
    }

    return card;
  }
}
