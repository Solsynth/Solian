import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'cloud_files.dart';

/// The presentation fields a foundation cloud-file widget needs.
///
/// Applications adapt their SDK-specific file model at the package boundary.
class CloudFileDescriptor {
  const CloudFileDescriptor({
    required this.id,
    required this.name,
    required this.mimeType,
    this.storageUrl,
  });

  final String id;
  final String name;
  final String mimeType;
  final String? storageUrl;
}

/// A compact image preview, with an icon fallback, for a Drive file.
///
/// Supply [workspaceId] when the file belongs to a workspace so its preview
/// URL retains the required `workspace_id` context.
class CloudFileAvatar extends StatelessWidget {
  const CloudFileAvatar({
    super.key,
    required this.serverUrl,
    this.file,
    this.workspaceId,
    this.fallbackIcon = Symbols.image,
    this.size = 40,
    this.selected = false,
    this.borderRadius,
  });

  final String serverUrl;
  final CloudFileDescriptor? file;
  final String? workspaceId;
  final IconData fallbackIcon;
  final double size;
  final bool selected;
  final BorderRadius? borderRadius;

  static const _selectedBorderWidth = 1.5;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final outerRadius = borderRadius ?? BorderRadius.circular(size * .28);
    final borderWidth = selected ? _selectedBorderWidth : 0.0;
    final iconColor = selected ? scheme.onPrimaryContainer : scheme.primary;
    final isImage =
        (file?.mimeType ?? '').isEmpty || file!.mimeType.startsWith('image/');
    final url = file == null
        ? null
        : cloudFileUrl(
            serverUrl: serverUrl,
            id: file!.id,
            storageUrl: file!.storageUrl,
            workspaceId: workspaceId,
          );

    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(borderWidth),
      decoration: BoxDecoration(
        borderRadius: outerRadius,
        border: selected
            ? Border.all(
                color: scheme.primary.withValues(alpha: .55),
                width: _selectedBorderWidth,
              )
            : null,
      ),
      child: ClipRRect(
        borderRadius: _deflateBorderRadius(outerRadius, borderWidth),
        child: ColoredBox(
          color: selected
              ? scheme.primaryContainer
              : scheme.surfaceContainerHighest,
          child: url != null && isImage
              ? Image.network(
                  url,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => _fallback(iconColor),
                )
              : _fallback(iconColor),
        ),
      ),
    );
  }

  Widget _fallback(Color color) => Center(
    child: Icon(fallbackIcon, size: size * .45, color: color),
  );
}

/// A compact, optional-removable representation of a Drive attachment.
class CloudFileChip extends StatelessWidget {
  const CloudFileChip({
    super.key,
    required this.file,
    required this.serverUrl,
    this.workspaceId,
    this.displayUrl,
    this.onPressed,
    this.onRemove,
  });

  final CloudFileDescriptor file;
  final String serverUrl;
  final String? workspaceId;
  final String? displayUrl;
  final VoidCallback? onPressed;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final isImage = file.mimeType.startsWith('image/');
    final url =
        displayUrl ??
        cloudFileUrl(
          serverUrl: serverUrl,
          id: file.id,
          storageUrl: file.storageUrl,
          workspaceId: workspaceId,
        );
    return InputChip(
      avatar: isImage
          ? ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                url,
                width: 24,
                height: 24,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) =>
                    const Icon(Symbols.attach_file, size: 16),
              ),
            )
          : const Icon(Symbols.attach_file, size: 16),
      label: Text(
        file.name.isEmpty ? file.id : file.name,
        overflow: TextOverflow.ellipsis,
      ),
      onPressed: onPressed,
      onDeleted: onRemove,
      deleteIconColor: Theme.of(context).colorScheme.onSurfaceVariant,
    );
  }
}

BorderRadius _deflateBorderRadius(BorderRadius radius, double delta) {
  if (delta <= 0) return radius;
  Radius deflate(Radius corner) => Radius.elliptical(
    (corner.x - delta).clamp(0.0, double.infinity),
    (corner.y - delta).clamp(0.0, double.infinity),
  );
  return BorderRadius.only(
    topLeft: deflate(radius.topLeft),
    topRight: deflate(radius.topRight),
    bottomLeft: deflate(radius.bottomLeft),
    bottomRight: deflate(radius.bottomRight),
  );
}
