import 'package:material_ui/material_ui.dart';

enum FileActionType { save, info, more, close, custom }

class FileActionButton extends StatelessWidget {
  final FileActionType type;
  final IconData? icon;
  final VoidCallback onPressed;
  final Color? color;
  final List<Shadow>? shadows;
  final String? tooltip;

  const FileActionButton({
    super.key,
    required this.type,
    required this.onPressed,
    this.icon,
    this.color,
    this.shadows,
    this.tooltip,
  });

  factory FileActionButton.save({
    Key? key,
    required VoidCallback onPressed,
    Color? color,
    List<Shadow>? shadows,
  }) {
    return FileActionButton(
      key: key,
      type: FileActionType.save,
      icon: Icons.save_alt,
      onPressed: onPressed,
      color: color ?? Colors.white,
      shadows: shadows,
    );
  }

  factory FileActionButton.info({
    Key? key,
    required VoidCallback onPressed,
    Color? color,
    List<Shadow>? shadows,
  }) {
    return FileActionButton(
      key: key,
      type: FileActionType.info,
      icon: Icons.info_outline,
      onPressed: onPressed,
      color: color ?? Colors.white,
      shadows: shadows,
    );
  }

  factory FileActionButton.more({
    Key? key,
    required VoidCallback onPressed,
    Color? color,
    List<Shadow>? shadows,
  }) {
    return FileActionButton(
      key: key,
      type: FileActionType.more,
      icon: Icons.more_horiz,
      onPressed: onPressed,
      color: color ?? Colors.white,
      shadows: shadows,
    );
  }

  factory FileActionButton.close({
    Key? key,
    required VoidCallback onPressed,
    Color? color,
    List<Shadow>? shadows,
  }) {
    return FileActionButton(
      key: key,
      type: FileActionType.close,
      icon: Icons.close,
      onPressed: onPressed,
      color: color ?? Colors.white,
      shadows: shadows,
    );
  }

  @override
  Widget build(BuildContext context) {
    final buttonIcon = icon ?? Icons.circle;

    final button = IconButton(
      icon: Icon(buttonIcon, color: color, shadows: shadows),
      onPressed: onPressed,
    );

    if (tooltip != null) {
      return Tooltip(message: tooltip!, child: button);
    }

    return button;
  }
}

class WhiteShadows {
  static List<Shadow> get standard => [
    Shadow(color: Colors.black54, blurRadius: 5.0, offset: Offset(1.0, 1.0)),
  ];
}

/// Compact dark surface used for media viewer chrome (controls, badges).
class MediaChromeSurface extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final BorderRadius? borderRadius;
  final Color? color;
  final bool showBorder;

  const MediaChromeSurface({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
    this.borderRadius,
    this.color,
    this.showBorder = true,
  });

  /// Fully rounded control pill with no border.
  factory MediaChromeSurface.pill({
    Key? key,
    required Widget child,
    EdgeInsetsGeometry padding = const EdgeInsets.symmetric(
      horizontal: 6,
      vertical: 2,
    ),
    Color? color,
  }) {
    return MediaChromeSurface(
      key: key,
      padding: padding,
      borderRadius: BorderRadius.circular(999),
      color: color ?? Colors.black.withValues(alpha: 0.55),
      showBorder: false,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color ?? Colors.black.withValues(alpha: 0.55),
        borderRadius: borderRadius ?? BorderRadius.circular(12),
        border: showBorder
            ? Border.all(color: Colors.white.withValues(alpha: 0.08))
            : null,
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}

/// Circular media action button with a solid dark background.
class MediaIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final double size;
  final double iconSize;
  final bool selected;

  const MediaIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.tooltip,
    this.size = 40,
    this.iconSize = 22,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    final button = Material(
      color: selected
          ? Colors.white.withValues(alpha: 0.18)
          : Colors.black.withValues(alpha: 0.55),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(icon, color: Colors.white, size: iconSize),
        ),
      ),
    );

    if (tooltip != null) {
      return Tooltip(message: tooltip!, child: button);
    }
    return button;
  }
}
