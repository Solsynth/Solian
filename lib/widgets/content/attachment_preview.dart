import 'dart:convert';
import 'dart:io';

import 'package:cross_file/cross_file.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/models/file.dart';
import 'package:island/pods/network.dart';
import 'package:island/services/file.dart';
import 'package:island/utils/format.dart';
import 'package:island/widgets/alert.dart';
import 'package:island/widgets/content/cloud_files.dart';
import 'package:island/widgets/content/sheet.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:super_context_menu/super_context_menu.dart';

import 'sensitive.dart';

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
    // Build a list of all categories in fixed order as int list indices
    final categories = kSensitiveCategoriesOrdered;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: 8,
          children: [
            for (var i = 0; i < categories.length; i++)
              FilterChip(
                label: Text(categories[i].i18nKey.tr()),
                avatar: Text(categories[i].symbol),
                selected: _selected.contains(i),
                onSelected: (_) => _toggle(i),
              ),
          ],
        ),
      ],
    );
  }
}

class AttachmentPreview extends HookConsumerWidget {
  final UniversalFile item;
  final double? progress;
  final Function(int)? onMove;
  final Function? onDelete;
  final Function? onInsert;
  final Function(UniversalFile)? onUpdate;
  final Function? onRequestUpload;
  final bool isCompact;

  const AttachmentPreview({
    super.key,
    required this.item,
    this.progress,
    this.onRequestUpload,
    this.onMove,
    this.onDelete,
    this.onUpdate,
    this.onInsert,
    this.isCompact = false,
  });

  // GlobalKey for selector
  static final GlobalKey<SensitiveMarksSelectorState> _sensitiveSelectorKey =
      GlobalKey<SensitiveMarksSelectorState>();

  Future<void> _showRenameDialog(BuildContext context, WidgetRef ref) async {
    final nameController = TextEditingController(text: item.data.name);
    String? errorMessage;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder:
          (context) => SheetScaffold(
            heightFactor: 0.6,
            titleText: 'rename'.tr(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 24,
                  ),
                  child: TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'fileName'.tr(),
                      border: const OutlineInputBorder(),
                      errorText: errorMessage,
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
                    TextButton(
                      onPressed: () async {
                        final newName = nameController.text.trim();
                        if (newName.isEmpty) {
                          errorMessage = 'fieldCannotBeEmpty'.tr();
                          return;
                        }

                        try {
                          showLoadingModal(context);
                          final apiClient = ref.watch(apiClientProvider);
                          await apiClient.patch(
                            '/drive/files/${item.data.id}/name',
                            data: jsonEncode(newName),
                          );
                          final newData = item.data;
                          newData.name = newName;
                          final updatedFile = item.copyWith(data: newData);
                          onUpdate?.call(item.copyWith(data: updatedFile));
                          if (context.mounted) Navigator.pop(context);
                        } catch (err) {
                          showErrorAlert(err);
                        } finally {
                          if (context.mounted) hideLoadingModal(context);
                        }
                      },
                      child: Text('rename'.tr()),
                    ),
                  ],
                ).padding(horizontal: 16, vertical: 8),
              ],
            ),
          ),
    );
  }

  Future<void> _showSensitiveDialog(BuildContext context, WidgetRef ref) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder:
          (context) => SheetScaffold(
            heightFactor: 0.6,
            titleText: 'markAsSensitive'.tr(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 24,
                  ),
                  child: Column(
                    children: [
                      // Sensitive categories checklist
                      SensitiveMarksSelector(
                        key: _sensitiveSelectorKey,
                        initial:
                            (item.data.sensitiveMarks ?? [])
                                .map((e) => e as int)
                                .cast<int>()
                                .toList(),
                        onChanged: (marks) {
                          // Update local data immediately (optimistic)
                          final newData = item.data;
                          newData.sensitiveMarks = marks;
                          final updatedFile = item.copyWith(data: newData);
                          onUpdate?.call(item.copyWith(data: updatedFile));
                        },
                      ),
                    ],
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
                    TextButton(
                      onPressed: () async {
                        try {
                          showLoadingModal(context);
                          final apiClient = ref.watch(apiClientProvider);
                          // Use the current selections from stateful selector via GlobalKey
                          final selectorState =
                              _sensitiveSelectorKey.currentState;
                          final marks = selectorState?.current ?? <int>[];
                          await apiClient.put(
                            '/drive/files/${item.data.id}/marks',
                            data: jsonEncode({'sensitive_marks': marks}),
                          );
                          final newData = item.data as SnCloudFile;
                          final updatedFile = item.copyWith(
                            data: newData.copyWith(sensitiveMarks: marks),
                          );
                          onUpdate?.call(updatedFile);
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var ratio =
        item.isOnCloud
            ? (item.data.fileMeta?['ratio'] is num
                ? item.data.fileMeta!['ratio'].toDouble()
                : 1.0)
            : 1.0;
    if (ratio == 0) ratio = 1.0;

    final contentWidget = ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        color: Theme.of(context).colorScheme.surfaceContainer,
        child: Stack(
          children: [
            AspectRatio(
              aspectRatio: ratio,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Builder(
                    key: ValueKey(item.hashCode),
                    builder: (context) {
                      final fallbackIcon = switch (item.type) {
                        UniversalFileType.video => Symbols.video_file,
                        UniversalFileType.audio => Symbols.audio_file,
                        UniversalFileType.image => Symbols.image,
                        _ => Symbols.insert_drive_file,
                      };

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
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            },
                          );
                        }

                        switch (item.type) {
                          case UniversalFileType.image:
                            return kIsWeb
                                ? Image.network(file.path)
                                : Image.file(File(file.path));
                          default:
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(fallbackIcon),
                                const Gap(6),
                                Text(file.name, textAlign: TextAlign.center),
                                FutureBuilder(
                                  future: file.length(),
                                  builder: (context, snapshot) {
                                    if (snapshot.hasData) {
                                      final size = snapshot.data as int;
                                      return Text(
                                        formatFileSize(size),
                                      ).fontSize(11);
                                    }
                                    return const SizedBox.shrink();
                                  },
                                ),
                              ],
                            );
                        }
                      } else if (item is List<int> || item is Uint8List) {
                        switch (item.type) {
                          case UniversalFileType.image:
                            return Image.memory(item.data);
                          default:
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(fallbackIcon),
                                const Gap(6),
                                Text(
                                  formatFileSize(item.data.length),
                                ).fontSize(11),
                              ],
                            );
                        }
                      }
                      return Placeholder();
                    },
                  ),
                  if (progress != null)
                    Positioned.fill(
                      child: Container(
                        color: Colors.black.withOpacity(0.3),
                        padding: EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 16,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            if (progress != null)
                              Text(
                                '${progress!.toStringAsFixed(2)}%',
                                style: TextStyle(color: Colors.white),
                              )
                            else
                              Text(
                                'uploading'.tr(),
                                style: TextStyle(color: Colors.white),
                              ),
                            Gap(6),
                            Center(
                              child: LinearProgressIndicator(
                                value:
                                    progress != null ? progress! / 100.0 : null,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ).center(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    color: Colors.black.withOpacity(0.5),
                    child: Material(
                      color: Colors.transparent,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (onDelete != null)
                            InkWell(
                              borderRadius: BorderRadius.circular(8),
                              child: Icon(
                                item.isLink ? Symbols.link_off : Symbols.delete,
                                size: 14,
                                color: Colors.white,
                              ).padding(horizontal: 8, vertical: 6),
                              onTap: () {
                                onDelete?.call();
                              },
                            ),
                          if (onDelete != null && onMove != null)
                            SizedBox(
                              height: 26,
                              child: const VerticalDivider(
                                width: 0.3,
                                color: Colors.white,
                                thickness: 0.3,
                              ),
                            ).padding(horizontal: 2),
                          if (onMove != null)
                            InkWell(
                              borderRadius: BorderRadius.circular(8),
                              child: const Icon(
                                Symbols.keyboard_arrow_up,
                                size: 14,
                                color: Colors.white,
                              ).padding(horizontal: 8, vertical: 6),
                              onTap: () {
                                onMove?.call(-1);
                              },
                            ),
                          if (onMove != null)
                            InkWell(
                              borderRadius: BorderRadius.circular(8),
                              child: const Icon(
                                Symbols.keyboard_arrow_down,
                                size: 14,
                                color: Colors.white,
                              ).padding(horizontal: 8, vertical: 6),
                              onTap: () {
                                onMove?.call(1);
                              },
                            ),
                          if (onInsert != null)
                            InkWell(
                              borderRadius: BorderRadius.circular(8),
                              child: const Icon(
                                Symbols.add,
                                size: 14,
                                color: Colors.white,
                              ).padding(horizontal: 8, vertical: 6),
                              onTap: () {
                                onInsert?.call();
                              },
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (onRequestUpload != null)
                  InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () => onRequestUpload?.call(),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        color: Colors.black.withOpacity(0.5),
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        child:
                            (item.isOnCloud)
                                ? Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Symbols.cloud,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                    if (!isCompact) const Gap(8),
                                    if (!isCompact)
                                      Text(
                                        'attachmentOnCloud'.tr(),
                                        style: TextStyle(color: Colors.white),
                                      ),
                                  ],
                                )
                                : Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Symbols.cloud_off,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                    if (!isCompact) const Gap(8),
                                    if (!isCompact)
                                      Text(
                                        'attachmentOnDevice'.tr(),
                                        style: TextStyle(color: Colors.white),
                                      ),
                                  ],
                                ),
                      ),
                    ),
                  ),
              ],
            ).padding(horizontal: 12, vertical: 8),
          ],
        ),
      ),
    );

    return ContextMenuWidget(
      menuProvider:
          (MenuRequest request) => Menu(
            children: [
              if (item.isOnDevice && item.type == UniversalFileType.image)
                MenuAction(
                  title: 'crop'.tr(),
                  image: MenuImage.icon(Symbols.crop),
                  callback: () async {
                    final result = await cropImage(
                      context,
                      image: item.data,
                      replacePath: true,
                    );
                    if (result == null) return;
                    onUpdate?.call(item.copyWith(data: result));
                  },
                ),
              if (item.isOnCloud)
                MenuAction(
                  title: 'rename'.tr(),
                  image: MenuImage.icon(Symbols.edit),
                  callback: () async {
                    await _showRenameDialog(context, ref);
                  },
                ),
              if (item.isOnCloud)
                MenuAction(
                  title: 'markAsSensitive'.tr(),
                  image: MenuImage.icon(Symbols.no_adult_content),
                  callback: () async {
                    await _showSensitiveDialog(context, ref);
                  },
                ),
            ],
          ),
      child: contentWidget,
    );
  }
}
