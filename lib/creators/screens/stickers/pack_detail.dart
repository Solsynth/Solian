import 'package:auto_route/auto_route.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/creators/screens/stickers/stickers.dart';
import 'package:island/stickers/models/sticker.dart';
import 'package:island/core/network.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/core/widgets/content/cloud_file_picker.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:island/shared/widgets/layouts/sheet_scaffold.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

part 'pack_detail.g.dart';

part 'pack_detail.freezed.dart';

@riverpod
Future<List<SnSticker>> stickerPackContent(Ref ref, String packId) async {
  final apiClient = ref.watch(apiClientProvider);
  final resp = await apiClient.get('/sphere/stickers/$packId/content');
  return resp.data.map<SnSticker>((e) => SnSticker.fromJson(e)).cast<SnSticker>().toList();
}

const List<String> _stickerSizeOptions = ['auto', 'small', 'medium', 'large'];
const List<String> _stickerModeOptions = ['sticker', 'emote'];

String _stickerSizeLabel(int value) => switch (value) {
  1 => 'stickerSizeSmall'.tr(),
  2 => 'stickerSizeMedium'.tr(),
  3 => 'stickerSizeLarge'.tr(),
  _ => 'stickerSizeAuto'.tr(),
};

String _stickerModeLabel(int value) => switch (value) {
  1 => 'stickerModeEmote'.tr(),
  _ => 'stickerModeSticker'.tr(),
};

String _stickerSizeOption(int value) => switch (value) {
  1 => 'small',
  2 => 'medium',
  3 => 'large',
  _ => 'auto',
};

String _stickerModeOption(int value) => value == 1 ? 'emote' : 'sticker';

int _stickerSizeValue(String value) => switch (value) {
  'small' => 1,
  'medium' => 2,
  'large' => 3,
  _ => 0,
};

int _stickerModeValue(String value) => value == 'emote' ? 1 : 0;

class StickerPackDetailContent extends HookConsumerWidget {
  final String id;
  final String pubName;

  const StickerPackDetailContent({super.key, required this.id, required this.pubName});

  Future<void> deleteSticker(BuildContext context, WidgetRef ref, SnSticker sticker) async {
    final confirm = await showConfirmAlert('deleteStickerHint'.tr(), 'deleteSticker'.tr());
    if (!confirm) return;
    if (!context.mounted) return;

    try {
      showLoadingModal(context);
      final apiClient = ref.watch(apiClientProvider);
      await apiClient.delete('/sphere/stickers/$id/content/${sticker.id}');
      ref.invalidate(stickerPackContentProvider(id));
    } catch (err) {
      showErrorAlert(err);
    } finally {
      if (context.mounted) hideLoadingModal(context);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pack = ref.watch(stickerPackProvider(id));
    final packContent = ref.watch(stickerPackContentProvider(id));
    final selectedStickerIds = useState<Set<String>>({});
    final pendingOrder = useState<List<String>?>(null);

    void updatePendingOrder(int fromIdx, int toIdx) {
      final current = pendingOrder.value ?? packContent.value?.map((s) => s.id).toList() ?? [];
      final list = [...current];
      final item = list.removeAt(fromIdx);
      list.insert(toIdx, item);
      pendingOrder.value = list;
    }

    Future<void> savePendingOrder() async {
      if (pendingOrder.value == null) return;
      showLoadingModal(context);
      try {
        final apiClient = ref.read(apiClientProvider);
        final items = pendingOrder.value!.asMap().entries.map((e) => {'id': e.value, 'order': e.key}).toList();
        await apiClient.patch('/sphere/stickers/$id/content/order', data: {'items': items});
        pendingOrder.value = null;
        ref.invalidate(stickerPackContentProvider(id));
      } catch (err) {
        showErrorAlert(err);
      } finally {
        if (context.mounted) hideLoadingModal(context);
      }
    }

    Future<void> openBatchEditSheet() async {
      if (selectedStickerIds.value.isEmpty) return;

      final result = await showModalBottomSheet<bool>(
        context: context,
        isScrollControlled: true,
        builder: (context) => SheetScaffold(
          titleText: 'Batch edit stickers',
          child: StickerBatchEditForm(packId: id, stickerIds: selectedStickerIds.value.toList()),
        ),
      );

      if (result == true) {
        selectedStickerIds.value = {};
        ref.invalidate(stickerPackContentProvider(id));
      }
    }

    return pack.when(
      data: (pack) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(pack!.description),
              Row(
                spacing: 4,
                children: [
                  const Icon(Symbols.folder, size: 16),
                  Text('${packContent.value?.length ?? 0}/24', style: GoogleFonts.robotoMono()),
                ],
              ).opacity(0.85),
              Row(
                spacing: 4,
                children: [
                  const Icon(Symbols.sell, size: 16),
                  Text(pack.prefix, style: GoogleFonts.robotoMono()),
                ],
              ).opacity(0.85),
              Row(
                spacing: 4,
                children: [
                  const Icon(Symbols.tag, size: 16),
                  Flexible(child: SelectableText(pack.id, maxLines: 1, style: GoogleFonts.robotoMono())),
                ],
              ).opacity(0.85),
            ],
          ).padding(horizontal: 24, vertical: 24),
          const Divider(height: 1),
          Expanded(
            child: packContent.when(
              data: (stickers) => RefreshIndicator(
                onRefresh: () => ref.refresh(stickerPackContentProvider(id).future),
                child: _buildStickersTable(
                  context,
                  ref,
                  stickers,
                  pack.prefix,
                  selectedStickerIds,
                  pendingOrder,
                  updatePendingOrder,
                ),
              ),
              error: (err, _) => Text('Error: $err').textAlignment(TextAlign.center).center(),
              loading: () => const CircularProgressIndicator().center(),
            ),
          ),
          if (pendingOrder.value != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHigh,
                border: Border(top: BorderSide(color: Theme.of(context).colorScheme.outlineVariant)),
              ),
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    Text(
                      '${pendingOrder.value!.length} stickers reordered',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const Spacer(),
                    TextButton(onPressed: () => pendingOrder.value = null, child: const Text('Reset')),
                    const Gap(8),
                    FilledButton.icon(
                      onPressed: savePendingOrder,
                      icon: const Icon(Symbols.save, size: 18),
                      label: const Text('Save Order'),
                    ),
                  ],
                ),
              ),
            ),
          if (selectedStickerIds.value.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHigh,
                border: Border(top: BorderSide(color: Theme.of(context).colorScheme.outlineVariant)),
              ),
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    Text(
                      '${selectedStickerIds.value.length} selected',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const Spacer(),
                    TextButton(onPressed: () => selectedStickerIds.value = {}, child: const Text('Clear')),
                    const Gap(8),
                    FilledButton.icon(
                      onPressed: openBatchEditSheet,
                      icon: const Icon(Symbols.tune, size: 18),
                      label: const Text('Batch edit'),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      error: (err, _) => Text('Error: $err').textAlignment(TextAlign.center).center(),
      loading: () => const CircularProgressIndicator().center(),
    );
  }

  Widget _buildStickersTable(
    BuildContext context,
    WidgetRef ref,
    List<SnSticker> stickers,
    String prefix,
    ValueNotifier<Set<String>> selectedStickerIds,
    ValueNotifier<List<String>?> pendingOrder,
    void Function(int from, int to) updatePendingOrder,
  ) {
    final scrollController = useCallback(() {
      final controller = ScrollController();
      return controller;
    }, []);

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          controller: scrollController(),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: constraints.maxWidth),
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(Theme.of(context).colorScheme.surfaceContainerHigh),
                dataRowMinHeight: 48,
                dataRowMaxHeight: 56,
                columnSpacing: 20,
                horizontalMargin: 16,
                headingRowHeight: 40,
                columns: const [
                  DataColumn(
                    label: _TableHeaderIcon(icon: Symbols.image, label: 'Preview'),
                  ),
                  DataColumn(
                    label: _TableHeaderIcon(icon: Symbols.title, label: 'Name'),
                  ),
                  DataColumn(
                    label: _TableHeaderIcon(icon: Symbols.tag, label: 'Slug'),
                  ),
                  DataColumn(
                    label: _TableHeaderIcon(icon: Icons.tag, label: 'Code'),
                  ),
                  DataColumn(
                    label: _TableHeaderIcon(icon: Symbols.zoom_out_map, label: 'Size'),
                  ),
                  DataColumn(
                    label: _TableHeaderIcon(icon: Symbols.mood, label: 'Mode'),
                  ),
                  DataColumn(label: SizedBox.shrink()),
                ],
                rows: (() {
                  final orderedIds = pendingOrder.value;
                  final displayList = orderedIds != null
                      ? orderedIds.map((id) => stickers.firstWhere((s) => s.id == id)).toList()
                      : stickers;
                  return displayList.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final sticker = entry.value;
                    final isSelected = selectedStickerIds.value.contains(sticker.id);
                    return DataRow(
                      selected: isSelected,
                      onSelectChanged: (value) {
                        final next = {...selectedStickerIds.value};
                        if (value ?? false) {
                          next.add(sticker.id);
                        } else {
                          next.remove(sticker.id);
                        }
                        selectedStickerIds.value = next;
                      },
                      cells: [
                        DataCell(
                          SizedBox(
                            width: 40,
                            height: 40,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.surfaceContainer,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: CloudImageWidget(file: sticker.image, fit: BoxFit.contain, noBlurhash: true),
                              ),
                            ),
                          ),
                        ),
                        DataCell(
                          SizedBox(
                            width: 140,
                            child: Text(
                              sticker.name?.trim().isNotEmpty == true ? sticker.name! : '-',
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ),
                        DataCell(
                          SizedBox(
                            width: 100,
                            child: Text(
                              sticker.slug,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: GoogleFonts.robotoMono(fontSize: 11),
                            ),
                          ),
                        ),
                        DataCell(Text(':$prefix+${sticker.slug}:', style: GoogleFonts.robotoMono(fontSize: 11))),
                        DataCell(Text(_stickerSizeLabel(sticker.size), style: GoogleFonts.robotoMono(fontSize: 11))),
                        DataCell(Text(_stickerModeLabel(sticker.mode), style: GoogleFonts.robotoMono(fontSize: 11))),
                        DataCell(
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (idx > 0)
                                IconButton(
                                  icon: const Icon(Symbols.arrow_upward, size: 16),
                                  onPressed: () => updatePendingOrder(idx, idx - 1),
                                  tooltip: 'Move up',
                                  visualDensity: VisualDensity.compact,
                                ),
                              if (idx < displayList.length - 1)
                                IconButton(
                                  icon: const Icon(Symbols.arrow_downward, size: 16),
                                  onPressed: () => updatePendingOrder(idx, idx + 1),
                                  tooltip: 'Move down',
                                  visualDensity: VisualDensity.compact,
                                ),
                              IconButton(
                                icon: const Icon(Icons.copy, size: 16),
                                onPressed: () {
                                  Clipboard.setData(ClipboardData(text: ':$prefix+${sticker.slug}:'));
                                },
                                tooltip: 'copy'.tr(),
                                visualDensity: VisualDensity.compact,
                              ),
                              IconButton(
                                icon: const Icon(Symbols.edit, size: 16),
                                onPressed: () {
                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    builder: (context) => SheetScaffold(
                                      titleText: 'editSticker'.tr(),
                                      child: StickerForm(packId: id, id: sticker.id),
                                    ),
                                  ).then((value) {
                                    if (value != null) {
                                      ref.invalidate(stickerPackContentProvider(id));
                                    }
                                  });
                                },
                                tooltip: 'edit'.tr(),
                                visualDensity: VisualDensity.compact,
                              ),
                              IconButton(
                                icon: const Icon(Symbols.delete, size: 16, color: Colors.red),
                                onPressed: () => deleteSticker(context, ref, sticker),
                                tooltip: 'delete'.tr(),
                                visualDensity: VisualDensity.compact,
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  });
                }()).toList(),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _TableHeaderIcon extends StatelessWidget {
  final IconData icon;
  final String label;

  const _TableHeaderIcon({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Theme.of(context).colorScheme.secondary),
        const Gap(4),
        Text(label, style: Theme.of(context).textTheme.labelMedium),
      ],
    );
  }
}

class StickerPackActionMenu extends HookConsumerWidget {
  final String pubName;
  final String packId;
  final Shadow iconShadow;

  const StickerPackActionMenu({super.key, required this.pubName, required this.packId, required this.iconShadow});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopupMenuButton(
      icon: Icon(Icons.more_vert, shadows: [iconShadow]),
      itemBuilder: (context) => [
        PopupMenuItem(
          onTap: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (context) => SheetScaffold(
                titleText: 'editStickerPack'.tr(),
                child: StickerPackForm(pubName: pubName, packId: packId),
              ),
            ).then((value) {
              if (value != null) {
                ref.invalidate(stickerPackProvider(packId));
              }
            });
          },
          child: Row(
            children: [
              Icon(Icons.edit, color: Theme.of(context).colorScheme.onSecondaryContainer),
              const Gap(12),
              const Text('editStickerPack').tr(),
            ],
          ),
        ),
        PopupMenuItem(
          child: Row(
            children: [
              const Icon(Icons.delete, color: Colors.red),
              const Gap(12),
              const Text('deleteStickerPack', style: TextStyle(color: Colors.red)).tr(),
            ],
          ),
          onTap: () {
            showConfirmAlert('deleteStickerPackHint'.tr(), 'deleteStickerPack'.tr(), isDanger: true).then((confirm) {
              if (confirm) {
                final client = ref.watch(apiClientProvider);
                client.delete('/sphere/stickers/$packId');
                ref.invalidate(stickerPacksProvider);
                if (context.mounted) context.router.pop(true);
              }
            });
          },
        ),
      ],
    );
  }
}

class StickerForm extends HookConsumerWidget {
  final String packId;
  final String? id;

  const StickerForm({super.key, required this.packId, this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sticker = ref.watch(
      stickerPackStickerProvider(id == null ? null : StickerWithPackQuery(packId: packId, id: id!)),
    );

    final formKey = useMemoized(() => GlobalKey<FormState>(), []);

    final image = useState<String?>(id == null ? '' : sticker.value?.image.id);
    final nameController = useTextEditingController(text: id == null ? '' : sticker.value?.name);
    final slugController = useTextEditingController(text: id == null ? '' : sticker.value?.slug);
    final size = useState<int>(0);
    final mode = useState<int>(0);

    useEffect(() {
      if (sticker.value != null) {
        image.value = sticker.value!.image.id;
        nameController.text = sticker.value!.name ?? '';
        slugController.text = sticker.value!.slug;
        size.value = sticker.value!.size;
        mode.value = sticker.value!.mode;
      }
      return null;
    }, [sticker]);

    final submitting = useState(false);

    Future<void> submit() async {
      if (!(formKey.currentState?.validate() ?? false)) return;
      final apiClient = ref.watch(apiClientProvider);
      submitting.value = true;
      try {
        final data = <String, dynamic>{};
        final normalizedName = nameController.text.trim();
        if (id == null || slugController.text != sticker.value?.slug) {
          data['slug'] = slugController.text;
        }
        if (id == null || normalizedName != (sticker.value?.name ?? '')) {
          data['name'] = normalizedName.isEmpty ? null : normalizedName;
        }
        if (id == null || image.value != sticker.value?.image.id) {
          data['image_id'] = image.value;
        }
        if (id == null || size.value != sticker.value?.size) {
          data['size'] = size.value;
        }
        if (id == null || mode.value != sticker.value?.mode) {
          data['mode'] = mode.value;
        }

        final resp = await apiClient.request(
          id == null ? '/sphere/stickers/$packId/content' : '/sphere/stickers/$packId/content/$id',
          data: data,
          options: Options(method: id == null ? 'POST' : 'PATCH'),
        );
        if (context.mounted) {
          Navigator.pop(context, SnSticker.fromJson(resp.data));
        }
      } catch (err) {
        showErrorAlert(err);
      } finally {
        submitting.value = false;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          spacing: 8,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            SizedBox(
              height: 80,
              width: 80,
              child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(8)),
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainer,
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                  child: (image.value?.isEmpty ?? true)
                      ? const SizedBox.shrink()
                      : CloudImageWidget(fileId: image.value!),
                ),
              ),
            ),
            IconButton.filledTonal(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder: (context) => CloudFilePicker(
                    allowedTypes: {UniversalFileType.image},
                    usage: 'sticker',
                    skipCrop: true,
                  ),
                ).then((value) {
                  if (value == null) return;
                  final files = value is List ? value.cast<SnCloudFile>() : [value];
                  image.value = files[0].id;
                });
              },
              icon: const Icon(Symbols.cloud_upload),
            ),
          ],
        ),
        const Gap(16),
        Form(
          key: formKey,
          child: Column(
            spacing: 12,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  helperText: 'Optional descriptive name for autocomplete.',
                ),
                onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
              ),
              TextFormField(
                controller: slugController,
                decoration: InputDecoration(labelText: 'stickerSlug'.tr(), helperText: 'stickerSlugHint'.tr()),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'fieldCannotBeEmpty'.tr();
                  }
                  return null;
                },
                onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
              ),
              DropdownButtonFormField<String>(
                initialValue: _stickerSizeOption(size.value),
                decoration: const InputDecoration(labelText: 'Size'),
                items: _stickerSizeOptions.map((value) => DropdownMenuItem(value: value, child: Text(value))).toList(),
                onChanged: submitting.value
                    ? null
                    : (value) {
                        if (value != null) {
                          size.value = _stickerSizeValue(value);
                        }
                      },
              ),
              DropdownButtonFormField<String>(
                initialValue: _stickerModeOption(mode.value),
                decoration: const InputDecoration(labelText: 'Mode'),
                items: _stickerModeOptions.map((value) => DropdownMenuItem(value: value, child: Text(value))).toList(),
                onChanged: submitting.value
                    ? null
                    : (value) {
                        if (value != null) {
                          mode.value = _stickerModeValue(value);
                        }
                      },
              ),
            ],
          ),
        ),
        const Gap(12),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: submitting.value ? null : submit,
            icon: const Icon(Symbols.save),
            label: Text(id == null ? 'create' : 'saveChanges').tr(),
          ),
        ),
      ],
    ).padding(horizontal: 24, vertical: 16);
  }
}

class StickerBatchEditForm extends HookConsumerWidget {
  final String packId;
  final List<String> stickerIds;

  const StickerBatchEditForm({super.key, required this.packId, required this.stickerIds});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final applySize = useState(false);
    final applyMode = useState(false);
    final size = useState<int>(0);
    final mode = useState<int>(0);
    final submitting = useState(false);

    Future<void> submit() async {
      if (!applySize.value && !applyMode.value) {
        showErrorAlert('Select at least one setting to update.');
        return;
      }

      final apiClient = ref.watch(apiClientProvider);
      submitting.value = true;
      try {
        final data = <String, dynamic>{'sticker_ids': stickerIds};
        if (applySize.value) data['size'] = size.value;
        if (applyMode.value) data['mode'] = mode.value;

        await apiClient.patch('/sphere/stickers/$packId/content/batch/rendering-settings', data: data);

        if (!context.mounted) return;
        showSnackBar('Batch sticker settings updated.');
        Navigator.pop(context, true);
      } catch (err) {
        showErrorAlert(err);
      } finally {
        submitting.value = false;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('${stickerIds.length} stickers selected'),
        const Gap(12),
        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          value: applySize.value,
          onChanged: submitting.value ? null : (value) => applySize.value = value ?? false,
          title: const Text('Update size'),
        ),
        DropdownButtonFormField<String>(
          initialValue: _stickerSizeOption(size.value),
          decoration: const InputDecoration(labelText: 'Size'),
          items: _stickerSizeOptions.map((value) => DropdownMenuItem(value: value, child: Text(value))).toList(),
          onChanged: !applySize.value || submitting.value
              ? null
              : (value) {
                  if (value != null) size.value = _stickerSizeValue(value);
                },
        ),
        const Gap(12),
        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          value: applyMode.value,
          onChanged: submitting.value ? null : (value) => applyMode.value = value ?? false,
          title: const Text('Update mode'),
        ),
        DropdownButtonFormField<String>(
          initialValue: _stickerModeOption(mode.value),
          decoration: const InputDecoration(labelText: 'Mode'),
          items: _stickerModeOptions.map((value) => DropdownMenuItem(value: value, child: Text(value))).toList(),
          onChanged: !applyMode.value || submitting.value
              ? null
              : (value) {
                  if (value != null) mode.value = _stickerModeValue(value);
                },
        ),
        const Gap(12),
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton.icon(
            onPressed: submitting.value ? null : submit,
            icon: const Icon(Symbols.save),
            label: const Text('Apply'),
          ),
        ),
      ],
    ).padding(horizontal: 24, vertical: 16);
  }
}

@freezed
sealed class StickerWithPackQuery with _$StickerWithPackQuery {
  const factory StickerWithPackQuery({required String packId, required String id}) = _StickerWithPackQuery;
}

@riverpod
Future<SnSticker?> stickerPackSticker(Ref ref, StickerWithPackQuery? query) async {
  if (query == null) return null;
  final apiClient = ref.watch(apiClientProvider);
  final resp = await apiClient.get('/sphere/stickers/${query.packId}/content/${query.id}');
  if (resp.data == null) return null;
  return SnSticker.fromJson(resp.data);
}
