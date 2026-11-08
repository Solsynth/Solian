import 'dart:io';

import 'package:cross_file/cross_file.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:island/core/services/image.dart';
import 'package:island/core/utils/share_utils.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:solar_network_foundation/solar_network_foundation.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:island/core/widgets/content/sensitive.dart';
import 'package:island/shared/widgets/layouts/sheet_scaffold.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:super_context_menu/super_context_menu.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

class SensitiveMarksSelector extends StatefulWidget {
  final List<int> initial;
  final ValueChanged<List<int>>? onChanged;

  const SensitiveMarksSelector({
    super.key,
    required this.initial,
    this.onChanged,
  });

  @override
  State<SensitiveMarksSelector> createState() => SensitiveMarksSelectorState();
}

class SensitiveMarksSelectorState extends State<SensitiveMarksSelector> {
  late List<int> _selected;

  List<int> get current => _selected;

  @override
  void initState() {
    super.initState();
    _selected = [...widget.initial];
  }

  void _toggle(int value) {
    setState(() {
      if (_selected.contains(value)) {
        _selected.remove(value);
      } else {
        _selected.add(value);
      }
    });
    widget.onChanged?.call([..._selected]);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final categories = kSensitiveCategoriesOrdered;

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      itemCount: categories.length,
      separatorBuilder: (_, _) => const Gap(8),
      itemBuilder: (context, index) {
        final category = categories[index];
        final selected = _selected.contains(category.index);

        return Material(
          color: selected
              ? colorScheme.primaryContainer
              : colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => _toggle(category.index),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: selected
                          ? colorScheme.primary.withValues(alpha: 0.12)
                          : colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      category.symbol,
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                  const Gap(14),
                  Expanded(
                    child: Text(
                      category.i18nKey.tr(),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: selected
                            ? colorScheme.onPrimaryContainer
                            : colorScheme.onSurface,
                        fontWeight:
                            selected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ),
                  Icon(
                    selected
                        ? Symbols.check_circle_rounded
                        : Symbols.radio_button_unchecked_rounded,
                    color: selected
                        ? colorScheme.primary
                        : colorScheme.outlineVariant,
                    fill: selected ? 1 : 0,
                    size: 22,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class AttachmentPreview extends HookConsumerWidget {
  final UniversalFile item;
  final double? progress;
  final bool isUploading;
  final bool isEncryptedUpload;
  final Function(int)? onMove;
  final Function? onDelete;
  final Function? onInsert;
  final Function(UniversalFile)? onUpdate;
  final Function? onRequestUpload;

  /// Cancels the upload that is running for this attachment.
  final VoidCallback? onCancelUpload;
  final bool isCompact;
  final String? thumbnailId;
  final Function(String?)? onSetThumbnail;
  final bool bordered;

  const AttachmentPreview({
    super.key,
    required this.item,
    this.progress,
    this.isUploading = false,
    this.isEncryptedUpload = false,
    this.onRequestUpload,
    this.onCancelUpload,
    this.onMove,
    this.onDelete,
    this.onUpdate,
    this.onInsert,
    this.isCompact = false,
    this.thumbnailId,
    this.onSetThumbnail,
    this.bordered = false,
  });

  String _getDisplayName() {
    return item.displayName ??
        (item.data is XFile
            ? (item.data as XFile).name
            : item.isOnCloud
            ? item.data.name
            : '');
  }

  Future<void> _handleDelete(BuildContext context) async {
    if (onDelete == null) return;
    if (item.isOnCloud && !item.isLink) {
      try {
        showLoadingModal(context);
        await onDelete?.call();
      } catch (err) {
        showErrorAlert(err);
      } finally {
        if (context.mounted) hideLoadingModal(context);
      }
    } else {
      await onDelete?.call();
    }
  }

  Future<void> _performRename(
    BuildContext context,
    WidgetRef ref,
    String newName,
    void Function(String?) setErrorMessage,
  ) async {
    if (newName.isEmpty) {
      setErrorMessage('fieldCannotBeEmpty'.tr());
      return;
    }

    if (item.isOnCloud) {
      try {
        showLoadingModal(context);
        final uploader = ref.read(driveFileUploaderProvider);
        await uploader.renameFile(item.data.id, newName);
        final newData = item.data;
        newData.name = newName;
        onUpdate?.call(
          item.copyWith(data: newData, displayName: newName),
        );
        if (context.mounted) Navigator.pop(context);
      } catch (err) {
        showErrorAlert(err);
      } finally {
        if (context.mounted) hideLoadingModal(context);
      }
    } else {
      // Local file rename
      onUpdate?.call(item.copyWith(displayName: newName));
      if (context.mounted) Navigator.pop(context);
    }
  }

  Future<void> _showRenameSheet(BuildContext context, WidgetRef ref) async {
    final nameController = TextEditingController(text: _getDisplayName());
    String? errorMessage;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => SheetScaffold(
          heightFactor: 0.6,
          titleText: 'rename'.tr(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: TextField(
                  controller: nameController,
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: 'fileName'.tr(),
                    errorText: errorMessage,
                  ),
                  onSubmitted: (text) => _performRename(
                    context,
                    ref,
                    text.trim(),
                    (err) => setSheetState(() => errorMessage = err),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('cancel'.tr()),
                  ),
                  const Gap(8),
                  FilledButton.tonal(
                    onPressed: () => _performRename(
                      context,
                      ref,
                      nameController.text.trim(),
                      (err) => setSheetState(() => errorMessage = err),
                    ),
                    child: Text('rename'.tr()),
                  ),
                ],
              ).padding(horizontal: 16, vertical: 8),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showSensitiveDialog(BuildContext context, WidgetRef ref) async {
    // Attachments may be either SnCloudFile or SnCloudFileReference.
    final cloudFile = item.data as IDisplayableCloudFile;
    var selected = List<int>.from(cloudFile.sensitiveMarks);

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      builder: (context) => SheetScaffold(
        heightFactor: 0.65,
        titleText: 'markContent'.tr(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SensitiveMarksSelector(
                initial: selected,
                onChanged: (marks) => selected = marks,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('cancel'.tr()),
                ),
                const Gap(8),
                FilledButton.tonal(
                  onPressed: () async {
                    try {
                      showLoadingModal(context);
                      final uploader = ref.read(driveFileUploaderProvider);
                      await uploader.updateSensitiveMarks(
                        cloudFile.id,
                        selected,
                      );
                      // API returns empty 200; apply marks locally.
                      final newData = switch (item.data) {
                        final SnCloudFileReference ref => ref.copyWith(
                          sensitiveMarks: selected,
                        ),
                        final SnCloudFile file => file.copyWith(
                          sensitiveMarks: selected,
                        ),
                        _ => item.data,
                      };
                      onUpdate?.call(item.copyWith(data: newData));
                      if (context.mounted) Navigator.pop(context);
                    } catch (err) {
                      showErrorAlert(err);
                    } finally {
                      if (context.mounted) hideLoadingModal(context);
                    }
                  },
                  child: Text('confirm'.tr()),
                ),
              ],
            ).padding(horizontal: 16, vertical: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildActionIconButton({
    required BuildContext context,
    required IconData icon,
    required VoidCallback onTap,
    String? tooltip,
    Color? color,
    Color? hoverColor,
  }) {
    final theme = Theme.of(context);
    final button = Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        hoverColor: hoverColor,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(
            icon,
            size: 16,
            color: color ?? theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );

    if (tooltip != null) {
      return Tooltip(message: tooltip, child: button);
    }
    return button;
  }

  Widget _buildStatusChip(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (isUploading && onCancelUpload != null) {
      return Material(
        color: colorScheme.errorContainer.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(10),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onCancelUpload,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Symbols.close_rounded,
                  size: 15,
                  color: colorScheme.onErrorContainer,
                ),
                if (!isCompact) const Gap(6),
                if (!isCompact)
                  Text(
                    'cancelUpload'.tr(),
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: colorScheme.onErrorContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    }

    if (item.isOnCloud) {
      return Container(
        decoration: BoxDecoration(
          color: colorScheme.secondaryContainer.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Symbols.cloud_done_rounded,
              size: 15,
              color: colorScheme.onSecondaryContainer,
            ),
            if (!isCompact) const Gap(6),
            if (!isCompact)
              Text(
                'attachmentOnCloud'.tr(),
                style: theme.textTheme.labelMedium?.copyWith(
                  color: colorScheme.onSecondaryContainer,
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
      );
    }

    // Attachment is on device
    final isClickable = onRequestUpload != null;
    final chipColor = isClickable
        ? colorScheme.primaryContainer.withValues(alpha: 0.92)
        : colorScheme.surfaceContainerHighest.withValues(alpha: 0.92);
    final contentColor = isClickable
        ? colorScheme.onPrimaryContainer
        : colorScheme.onSurfaceVariant;

    final chipContent = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isClickable
                ? Symbols.cloud_upload_rounded
                : Symbols.cloud_off_rounded,
            size: 15,
            color: contentColor,
          ),
          if (!isCompact) const Gap(6),
          if (!isCompact)
            Text(
              'attachmentOnDevice'.tr(),
              style: theme.textTheme.labelMedium?.copyWith(
                color: contentColor,
                fontWeight: FontWeight.w500,
              ),
            ),
        ],
      ),
    );

    if (isClickable) {
      return Material(
        color: chipColor,
        borderRadius: BorderRadius.circular(10),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () => onRequestUpload?.call(),
          child: chipContent,
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: chipColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: chipContent,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final isEncryptedOnCloud =
        item.isOnCloud &&
        item.data is SnCloudFile &&
        DriveE2eeFileEnvelope.isEncryptedFile(item.data as SnCloudFile);
    final showEncryptedIndicator = isEncryptedUpload || isEncryptedOnCloud;
    final isThumbnail =
        thumbnailId != null &&
        item.isOnCloud &&
        (item.data as IDisplayableCloudFile).id == thumbnailId;

    var ratio = item.isOnCloud ? item.data.ratio : null;

    final innerContentWidget = Stack(
      fit: StackFit.expand,
      children: [
        HookBuilder(
          key: ValueKey(item.hashCode),
          builder: (context) {
            final fallbackIcon = switch (item.type) {
              UniversalFileType.video => Symbols.video_file_rounded,
              UniversalFileType.audio => Symbols.audio_file_rounded,
              UniversalFileType.image => Symbols.image_rounded,
              _ => Symbols.insert_drive_file_rounded,
            };

            final mimeType = FileUploader.getMimeType(item);

            if (item.isOnCloud) {
              return CloudFileWidget(item: item.data);
            } else if (item.data is XFile) {
              final file = item.data as XFile;
              if (file.path.isEmpty) {
                return FutureBuilder<Uint8List>(
                  future: file.readAsBytes(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Image.memory(snapshot.data!);
                    }
                    return const Center(child: CircularProgressIndicator());
                  },
                );
              }

              switch (item.type) {
                case UniversalFileType.image:
                  return kIsWeb
                      ? Image.network(file.path)
                      : Image.file(File(file.path));
                case UniversalFileType.video:
                  if (!kIsWeb) {
                    final thumbnailFuture = useMemoized(
                      () => VideoThumbnail.thumbnailData(
                        video: file.path,
                        imageFormat: ImageFormat.JPEG,
                        maxWidth: 320,
                        quality: 50,
                      ),
                      [file.path],
                    );
                    return FutureBuilder<Uint8List?>(
                      future: thumbnailFuture,
                      builder: (context, snapshot) {
                        if (snapshot.hasData && snapshot.data != null) {
                          return Stack(
                            children: [
                              Image.memory(snapshot.data!),
                              Positioned.fill(
                                child: Center(
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: colorScheme
                                          .surfaceContainerHighest
                                          .withValues(alpha: 0.85),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Symbols.play_arrow_rounded,
                                      color: colorScheme.onSurfaceVariant,
                                      size: 32,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }
                        return const Center(child: CircularProgressIndicator());
                      },
                    );
                  }
                  break;
                default:
                  break;
              }

              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      fallbackIcon,
                      size: 28,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const Gap(10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      _getDisplayName(),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Gap(6),
                  FutureBuilder<int>(
                    future: file.length(),
                    builder: (context, snapshot) {
                      final sizeText =
                          snapshot.hasData ? formatFileSize(snapshot.data!) : null;
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest
                              .withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (mimeType.isNotEmpty)
                              Text(
                                mimeType,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                  fontSize: 10,
                                ),
                              ),
                            if (mimeType.isNotEmpty && sizeText != null) ...[
                              const Gap(6),
                              Container(
                                width: 3,
                                height: 3,
                                decoration: BoxDecoration(
                                  color: colorScheme.outlineVariant,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const Gap(6),
                            ],
                            if (sizeText != null)
                              Text(
                                sizeText,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                  fontSize: 10,
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ).padding(vertical: 28);
            } else if (item is List<int> || item is Uint8List) {
              switch (item.type) {
                case UniversalFileType.image:
                  return Image.memory(item.data);
                default:
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          fallbackIcon,
                          size: 28,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const Gap(10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest
                              .withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (mimeType.isNotEmpty)
                              Text(
                                mimeType,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                  fontSize: 10,
                                ),
                              ),
                            if (mimeType.isNotEmpty) ...[
                              const Gap(6),
                              Container(
                                width: 3,
                                height: 3,
                                decoration: BoxDecoration(
                                  color: colorScheme.outlineVariant,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const Gap(6),
                            ],
                            Text(
                              formatFileSize(item.data.length),
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ).padding(vertical: 24);
              }
            }
            return const Placeholder();
          },
        ),
        if (isUploading)
          Positioned.fill(
            child: Container(
              color: colorScheme.scrim.withValues(alpha: 0.38),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        (progress != null && progress! > 0)
                            ? '${(progress!.clamp(0.0, 1.0) * 100).toStringAsFixed(0)}%'
                            : 'processing'.tr(),
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Gap(8),
                      SizedBox(
                        width: 120,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: progress != null && progress! > 0
                              ? TweenAnimationBuilder<double>(
                                  tween: Tween<double>(
                                    begin: 0.0,
                                    end: progress!.clamp(0.0, 1.0),
                                  ),
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                  builder: (context, value, child) =>
                                      LinearProgressIndicator(
                                    value: value,
                                    backgroundColor:
                                        colorScheme.surfaceContainerHigh,
                                    valueColor: AlwaysStoppedAnimation(
                                      colorScheme.primary,
                                    ),
                                    minHeight: 6,
                                  ),
                                )
                              : LinearProgressIndicator(
                                  value: null,
                                  backgroundColor:
                                      colorScheme.surfaceContainerHigh,
                                  valueColor: AlwaysStoppedAnimation(
                                    colorScheme.primary,
                                  ),
                                  minHeight: 6,
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );

    final hasActionButtons =
        onDelete != null || onMove != null || onInsert != null;
    final containerColor = bordered
        ? colorScheme.surfaceContainerHigh
        : colorScheme.surfaceContainer;

    final contentWidget = Container(
      decoration: BoxDecoration(
        color: containerColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            if (ratio != null)
              AspectRatio(
                aspectRatio: ratio,
                child: innerContentWidget,
              ).center()
            else
              IntrinsicHeight(child: innerContentWidget).center(),
            Positioned(
              top: 8,
              left: 8,
              right: 8,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (hasActionButtons)
                    Container(
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest
                            .withValues(alpha: 0.92),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.all(2),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (onDelete != null)
                            _buildActionIconButton(
                              context: context,
                              icon: item.isLink
                                  ? Symbols.link_off_rounded
                                  : Symbols.delete_rounded,
                              tooltip: 'delete'.tr(),
                              color: colorScheme.error,
                              hoverColor: colorScheme.errorContainer
                                  .withValues(alpha: 0.4),
                              onTap: () => _handleDelete(context),
                            ),
                          if (onMove != null) ...[
                            _buildActionIconButton(
                              context: context,
                              icon: Symbols.keyboard_arrow_up_rounded,
                              tooltip: 'moveUp'.tr(),
                              color: colorScheme.onSurfaceVariant,
                              onTap: () => onMove?.call(-1),
                            ),
                            _buildActionIconButton(
                              context: context,
                              icon: Symbols.keyboard_arrow_down_rounded,
                              tooltip: 'moveDown'.tr(),
                              color: colorScheme.onSurfaceVariant,
                              onTap: () => onMove?.call(1),
                            ),
                          ],
                          if (onInsert != null)
                            _buildActionIconButton(
                              context: context,
                              icon: Symbols.add_rounded,
                              tooltip: 'insert'.tr(),
                              color: colorScheme.onSurfaceVariant,
                              onTap: () => onInsert?.call(),
                            ),
                        ],
                      ),
                    )
                  else
                    const SizedBox.shrink(),
                  _buildStatusChip(context),
                ],
              ),
            ),
            if (showEncryptedIndicator)
              Positioned(
                bottom: 8,
                left: 8,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  decoration: BoxDecoration(
                    color: colorScheme.tertiaryContainer
                        .withValues(alpha: 0.94),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Symbols.lock_rounded,
                        size: 14,
                        color: colorScheme.onTertiaryContainer,
                      ),
                      if (!isCompact) const Gap(4),
                      if (!isCompact)
                        Text(
                          'Encrypted',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colorScheme.onTertiaryContainer,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            if (isThumbnail)
              Positioned(
                bottom: 8,
                right: 8,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer
                        .withValues(alpha: 0.94),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Symbols.star_rounded,
                        size: 14,
                        color: colorScheme.onPrimaryContainer,
                      ),
                      if (!isCompact) const Gap(4),
                      if (!isCompact)
                        Text(
                          'thumbnailSelected'.tr(),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.w600,
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

    return ContextMenuWidget(
      previewBuilder: contextMenuPreviewBuilder,
      menuProvider: (MenuRequest request) => Menu(
        children: [
          if (item.isOnDevice && item.type == UniversalFileType.image)
            MenuAction(
              title: 'edit'.tr(),
              image: MenuImage.icon(Symbols.edit),
              callback: () async {
                final result = await cropImage(
                  context,
                  image: item.data,
                  replacePath: true,
                );
                if (result == null) return;
                onUpdate?.call(
                  item.copyWith(
                    data: result,
                    // `result.name` is empty on io (cross_file drops
                    // fromData's `name:`); fall back to the edited name.
                    displayName: result.name.isNotEmpty
                        ? result.name
                        : editedImageName(item.data.name),
                  ),
                );
              },
            ),
          if (item.isOnDevice)
            MenuAction(
              title: 'rename'.tr(),
              image: MenuImage.icon(Symbols.drive_file_rename),
              callback: () async {
                await _showRenameSheet(context, ref);
              },
            ),
          if (item.isOnCloud)
            MenuAction(
              title: 'rename'.tr(),
              image: MenuImage.icon(Symbols.drive_file_rename),
              callback: () async {
                await _showRenameSheet(context, ref);
              },
            ),
          if (item.isOnCloud)
            MenuAction(
              title: 'markContent'.tr(),
              image: MenuImage.icon(Symbols.label),
              callback: () async {
                await _showSensitiveDialog(context, ref);
              },
            ),
          if (item.isOnCloud &&
              item.type == UniversalFileType.image &&
              onSetThumbnail != null)
            MenuAction(
              title: isThumbnail
                  ? 'unsetAsThumbnail'.tr()
                  : 'setAsThumbnail'.tr(),
              image: MenuImage.icon(Symbols.image),
              callback: () {
                if (isThumbnail) {
                  onSetThumbnail?.call(null);
                } else {
                  onSetThumbnail?.call((item.data as IDisplayableCloudFile).id);
                }
              },
            ),
          if (onDelete != null)
            MenuAction(
              title: 'delete'.tr(),
              image: MenuImage.icon(
                item.isLink ? Symbols.link_off : Symbols.delete,
              ),
              attributes: const MenuActionAttributes(destructive: true),
              callback: () => _handleDelete(context),
            ),
        ],
      ),
      child: contentWidget,
    );
  }
}
