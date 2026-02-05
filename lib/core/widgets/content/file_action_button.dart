import 'package:flutter/material.dart';

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
