import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:material_symbols_icons/symbols.dart';

/// A reusable widget for displaying user handles with Material Design 3 styling.
///
/// Supports both simple handles (@username) and fediverse-style handles
/// with domain information (@username@domain.com).
///
/// Example usage:
/// ```dart
/// // Simple handle
/// HandleChip(handle: 'john_doe')
///
/// // Fediverse handle with domain
/// HandleChip(handle: 'john_doe', domain: 'mastodon.social')
///
/// // With copy functionality
/// HandleChip(handle: 'john_doe', allowCopy: true)
/// ```
class HandleChip extends StatelessWidget {
  /// The username/handle (without the @ prefix)
  final String handle;

  /// Optional domain for fediverse-style handles
  final String? domain;

  /// Whether to show a copy button
  final bool allowCopy;

  /// Custom padding
  final EdgeInsetsGeometry? padding;

  /// Custom border radius
  final double? borderRadius;

  /// Whether this is a remote/fediverse user
  final bool isRemote;

  /// Callback when the chip is tapped
  final VoidCallback? onTap;

  /// Maximum lines for the handle text
  final int maxLines;

  /// Custom text style
  final TextStyle? textStyle;

  /// Custom background color
  final Color? backgroundColor;

  /// Custom foreground color
  final Color? foregroundColor;

  const HandleChip({
    super.key,
    required this.handle,
    this.domain,
    this.allowCopy = false,
    this.padding,
    this.borderRadius,
    this.isRemote = false,
    this.onTap,
    this.maxLines = 1,
    this.textStyle,
    this.backgroundColor,
    this.foregroundColor,
  });

  String get _fullHandle {
    if (domain != null && domain!.isNotEmpty) {
      return '@$handle@$domain';
    }
    return '@$handle';
  }

  String get _displayHandle {
    if (domain != null && domain!.isNotEmpty) {
      return '@$handle@$domain';
    }
    return '@$handle';
  }

  Future<void> _copyToClipboard(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: _fullHandle));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Copied $_fullHandle'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final bgColor =
        backgroundColor ??
        theme.colorScheme.surfaceContainerHighest.withOpacity(0.7);
    final fgColor = foregroundColor ?? theme.colorScheme.onSurfaceVariant;

    final chipContent = Container(
      padding:
          padding ?? const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(borderRadius ?? 12),
        border: isRemote
            ? Border.all(color: theme.colorScheme.secondaryContainer, width: 1)
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isRemote) ...[
            Icon(Symbols.public, size: 12, color: theme.colorScheme.secondary),
            const SizedBox(width: 4),
          ],
          Flexible(
            child: Text(
              _displayHandle,
              style:
                  textStyle ??
                  theme.textTheme.bodySmall?.copyWith(
                    color: fgColor,
                    fontWeight: FontWeight.w500,
                  ),
              maxLines: maxLines,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (allowCopy) ...[
            const SizedBox(width: 4),
            InkWell(
              onTap: () => _copyToClipboard(context),
              borderRadius: BorderRadius.circular(8),
              child: Icon(
                Symbols.content_copy,
                size: 12,
                color: fgColor.withOpacity(0.7),
              ),
            ),
          ],
        ],
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius ?? 12),
        child: chipContent,
      );
    }

    return chipContent;
  }
}

/// Extension to create a HandleChip from an ActivityPub-style handle string
/// that might contain domain information (e.g., "user@domain.com")
extension HandleChipExtension on String {
  /// Parses a handle string and creates a HandleChip
  ///
  /// Supports formats:
  /// - "username" -> HandleChip(handle: 'username')
  /// - "username@domain.com" -> HandleChip(handle: 'username', domain: 'domain.com')
  HandleChip toHandleChip({
    bool allowCopy = false,
    bool isRemote = false,
    VoidCallback? onTap,
  }) {
    final parts = split('@');
    if (parts.length >= 2) {
      return HandleChip(
        handle: parts[0],
        domain: parts.sublist(1).join('@'),
        allowCopy: allowCopy,
        isRemote: isRemote,
        onTap: onTap,
      );
    }
    return HandleChip(
      handle: this,
      allowCopy: allowCopy,
      isRemote: isRemote,
      onTap: onTap,
    );
  }
}
