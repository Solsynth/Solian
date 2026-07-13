import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:material_symbols_icons/symbols.dart';

/// Uniform vertical rhythm for auth multi-step forms.
const double kAuthGap = 16;
const double kAuthGapSm = 8;
const double kAuthGapLg = 24;
const double kAuthFormMaxWidth = 380;

/// Material 3 step header: tonal icon avatar + headline (+ optional subtitle).
///
/// Does **not** include trailing spacing — place [Gap]/kAuthGapLg) after it.
class AuthFormHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;

  const AuthFormHeader({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: scheme.primaryContainer,
          foregroundColor: scheme.onPrimaryContainer,
          child: Icon(icon, size: 28),
        ),
        const Gap(kAuthGap),
        Text(
          title,
          style: textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: scheme.onSurface,
          ),
        ),
        if (subtitle != null) ...[
          const Gap(kAuthGapSm),
          Text(
            subtitle!,
            style: textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}

/// Standard column for auth step bodies: stretch + fixed 16px rhythm.
class AuthFormColumn extends StatelessWidget {
  final List<Widget> children;
  final Key? columnKey;

  const AuthFormColumn({super.key, required this.children, this.columnKey});

  @override
  Widget build(BuildContext context) {
    return Column(
      key: columnKey,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      spacing: kAuthGap,
      children: children,
    );
  }
}

/// Material 3 step actions: optional back [TextButton] + primary [FilledButton].
class AuthFormActions extends StatelessWidget {
  final VoidCallback? onBack;
  final VoidCallback? onNext;
  final String? nextLabel;
  final String? backLabel;
  final bool showBack;
  final bool isBusy;
  final IconData nextIcon;
  final IconAlignment nextIconAlignment;

  const AuthFormActions({
    super.key,
    this.onBack,
    this.onNext,
    this.nextLabel,
    this.backLabel,
    this.showBack = false,
    this.isBusy = false,
    this.nextIcon = Symbols.chevron_right,
    this.nextIconAlignment = IconAlignment.end,
  });

  @override
  Widget build(BuildContext context) {
    final next = FilledButton.icon(
      onPressed: isBusy ? null : onNext,
      icon: Icon(nextIcon),
      label: Text(nextLabel ?? 'next'.tr()),
      iconAlignment: nextIconAlignment,
    );

    if (!showBack) {
      return Align(alignment: Alignment.centerRight, child: next);
    }

    return Row(
      children: [
        TextButton.icon(
          onPressed: isBusy ? null : onBack,
          icon: const Icon(Symbols.chevron_left),
          label: Text(backLabel ?? 'back'.tr()),
        ),
        const Spacer(),
        next,
      ],
    );
  }
}

/// Tertiary / quiet action for secondary paths (forgot password, recovery).
class AuthSecondaryAction extends StatelessWidget {
  final VoidCallback? onPressed;
  final String label;
  final IconData? icon;
  final bool enabled;

  const AuthSecondaryAction({
    super.key,
    required this.onPressed,
    required this.label,
    this.icon,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final style = TextButton.styleFrom(
      foregroundColor: scheme.onSurfaceVariant,
      visualDensity: VisualDensity.compact,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );

    final button = icon != null
        ? TextButton.icon(
            onPressed: enabled ? onPressed : null,
            style: style,
            icon: Icon(icon, size: 18),
            label: Text(label),
            iconAlignment: IconAlignment.end,
          )
        : TextButton(
            onPressed: enabled ? onPressed : null,
            style: style,
            child: Text(label),
          );

    return Align(alignment: Alignment.centerRight, child: button);
  }
}

/// Horizontal "or continue with" row of tonal icon buttons.
class AuthAltMethodsRow extends StatelessWidget {
  final String label;
  final List<Widget> children;

  const AuthAltMethodsRow({
    super.key,
    required this.label,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const Gap(12),
        Expanded(child: Divider(color: theme.colorScheme.outlineVariant)),
        const Gap(12),
        for (var i = 0; i < children.length; i++) ...[
          if (i > 0) const Gap(kAuthGapSm),
          children[i],
        ],
      ],
    );
  }
}

/// Compact circular tonal icon button for OIDC / alternate auth methods.
class AuthMethodIconButton extends StatelessWidget {
  final Widget icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final double size;

  const AuthMethodIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    this.onPressed,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton.filledTonal(
      onPressed: onPressed,
      tooltip: tooltip,
      style: IconButton.styleFrom(
        shape: const CircleBorder(),
        fixedSize: Size(size, size),
        minimumSize: Size(size, size),
        maximumSize: Size(size, size),
        padding: EdgeInsets.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
      ),
      icon: icon,
    );
  }
}

/// Inline error surface using Material 3 error container tokens.
class AuthErrorBanner extends StatelessWidget {
  final String message;

  const AuthErrorBanner({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      color: scheme.errorContainer,
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(Symbols.error, color: scheme.onErrorContainer, size: 20),
            const Gap(12),
            Expanded(
              child: Text(
                message,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: scheme.onErrorContainer,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Filled card wrapping multi-step list content.
class AuthSectionCard extends StatelessWidget {
  final List<Widget> children;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;

  const AuthSectionCard({
    super.key,
    required this.children,
    this.margin,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: margin ?? EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: padding ?? EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: children,
        ),
      ),
    );
  }
}

/// Scrollable, horizontally **and** vertically centered shell for auth steps.
///
/// Place directly inside an [Expanded] (or other bounded parent). Owns the
/// [SingleChildScrollView] so short forms sit in the middle of the viewport
/// while tall forms still scroll.
class AuthFormShell extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry padding;

  const AuthFormShell({
    super.key,
    required this.child,
    this.maxWidth = kAuthFormMaxWidth,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final resolved = padding.resolve(Directionality.of(context));
        final minHeight = (constraints.maxHeight - resolved.vertical).clamp(
          0.0,
          double.infinity,
        );

        return SingleChildScrollView(
          padding: padding,
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: minHeight),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: child,
              ),
            ),
          ),
        );
      },
    );
  }
}
