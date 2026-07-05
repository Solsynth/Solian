import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/network.dart';
import 'package:island/core/utils/file_icon_utils.dart';
import 'package:island/core/utils/format.dart';
import 'package:island/drive/screens/file_list.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:island/shared/widgets/layouts/sheet_scaffold.dart';
import 'package:island/shared/widgets/pagination_list.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

final cloudFileListNotifierProvider = AsyncNotifierProvider.autoDispose(
  CloudFileListNotifier.new,
);

class CloudFileListNotifier extends AsyncNotifier<PaginationState<SnCloudFile>>
    with AsyncPaginationController<SnCloudFile> {
  @override
  Future<List<SnCloudFile>> fetch() async {
    final driveApi = ref.read(solarNetworkClientProvider).drive;
    const take = 20;

    final result = await driveApi.listMyFiles(offset: fetchedCount, take: take);

    totalCount = result.totalCount;
    return result.items;
  }
}

class ComposeLinkAttachment extends HookConsumerWidget {
  final bool allowMultiSelect;

  const ComposeLinkAttachment({super.key, this.allowMultiSelect = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSelectionMode = useState(false);
    final selectedFiles = useState<Map<String, SnCloudFile>>({});

    void toggleSelection(SnCloudFile file) {
      final next = Map<String, SnCloudFile>.from(selectedFiles.value);
      if (next.containsKey(file.id)) {
        next.remove(file.id);
      } else {
        next[file.id] = file;
      }
      selectedFiles.value = next;
    }

    void setSelectionMode(bool value) {
      isSelectionMode.value = value;
      if (!value && selectedFiles.value.isNotEmpty) {
        selectedFiles.value = {};
      }
    }

    void handleSelected(SnCloudFile file) {
      if (isSelectionMode.value) {
        toggleSelection(file);
        return;
      }
      Navigator.pop(context, file);
    }

    return SheetScaffold(
      heightFactor: 0.6,
      titleText: 'linkAttachment'.tr(),
      actions: [
        if (allowMultiSelect && isSelectionMode.value)
          Center(
            child: Text(
              'selectedCount'.tr(args: [selectedFiles.value.length.toString()]),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        if (allowMultiSelect && isSelectionMode.value)
          TextButton(
            onPressed: selectedFiles.value.isEmpty
                ? null
                : () => Navigator.pop(
                    context,
                    selectedFiles.value.values.toList(growable: false),
                  ),
            child: Text('done'.tr()),
          ),
        if (allowMultiSelect)
          IconButton(
            onPressed: () => setSelectionMode(!isSelectionMode.value),
            tooltip: isSelectionMode.value
                ? 'exitSelectionMode'.tr()
                : 'enterSelectionMode'.tr(),
            icon: Icon(
              isSelectionMode.value
                  ? Symbols.check_box_outline_blank
                  : Symbols.select_check_box,
            ),
          ),
      ],
      child: CloudFileLinkPicker(
        onSelected: handleSelected,
        multiSelectEnabled: isSelectionMode.value,
        selectedFileIds: selectedFiles.value.keys.toSet(),
        onToggleSelection: toggleSelection,
      ),
    );
  }
}

class CloudFileLinkPicker extends HookConsumerWidget {
  final ValueChanged<SnCloudFile> onSelected;
  final ValueChanged<SnCloudFile>? onToggleSelection;
  final bool multiSelectEnabled;
  final Set<String> selectedFileIds;
  final EdgeInsetsGeometry padding;
  final List<Widget> recentUploadsSliverHeaders;

  const CloudFileLinkPicker({
    super.key,
    required this.onSelected,
    this.onToggleSelection,
    this.multiSelectEnabled = false,
    this.selectedFileIds = const {},
    this.padding = const EdgeInsets.all(12),
    this.recentUploadsSliverHeaders = const [],
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final idController = useTextEditingController();
    final errorMessage = useState<String?>(null);
    return DefaultTabController(
      length: 3,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TabBar(
            tabs: [
              Tab(text: 'attachmentsRecentUploads'.tr()),
              Tab(text: 'indexedFiles'.tr()),
              Tab(text: 'attachmentsManualInput'.tr()),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _RecentCloudFilesWaterfall(
                  padding: padding,
                  onSelected: onSelected,
                  multiSelectEnabled: multiSelectEnabled,
                  selectedFileIds: selectedFileIds,
                  onToggleSelection: onToggleSelection,
                  sliverHeaders: recentUploadsSliverHeaders,
                ),
                _IndexedCloudFilesBrowser(
                  onSelected: onSelected,
                  multiSelectEnabled: multiSelectEnabled,
                  selectedFileIds: selectedFileIds,
                  onToggleSelection: onToggleSelection,
                ),
                _ManualCloudFileLinkForm(
                  idController: idController,
                  errorMessage: errorMessage,
                  onSelected: onSelected,
                  multiSelectEnabled: multiSelectEnabled,
                  onToggleSelection: onToggleSelection,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _IndexedCloudFilesBrowser extends HookConsumerWidget {
  final ValueChanged<SnCloudFile> onSelected;
  final ValueChanged<SnCloudFile>? onToggleSelection;
  final bool multiSelectEnabled;
  final Set<String> selectedFileIds;

  const _IndexedCloudFilesBrowser({
    required this.onSelected,
    required this.multiSelectEnabled,
    required this.selectedFileIds,
    this.onToggleSelection,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPath = useState('/');

    useEffect(() {
      ref
          .read(indexedCloudFileListProvider.notifier)
          .setPath(currentPath.value);
      return null;
    }, [currentPath.value]);

    List<({String label, String path})> buildBreadcrumbs(String path) {
      final parts = path.split('/').where((part) => part.isNotEmpty).toList();
      final crumbs = <({String label, String path})>[
        (label: 'rootDirectory'.tr(), path: '/'),
      ];

      var current = '';
      for (final part in parts) {
        current = '$current/$part';
        crumbs.add((label: part, path: current));
      }
      return crumbs;
    }

    return PaginationWidget(
      provider: indexedCloudFileListProvider,
      notifier: indexedCloudFileListProvider.notifier,
      isRefreshable: false,
      contentBuilder: (data, footer) {
        final breadcrumbs = buildBreadcrumbs(currentPath.value);
        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 4,
                  runSpacing: 4,
                  children: [
                    for (var i = 0; i < breadcrumbs.length; i++) ...[
                      TextButton(
                        onPressed: breadcrumbs[i].path == currentPath.value
                            ? null
                            : () => currentPath.value = breadcrumbs[i].path,
                        style: TextButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(breadcrumbs[i].label),
                      ),
                      if (i != breadcrumbs.length - 1)
                        const Icon(Symbols.chevron_right, size: 18),
                    ],
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              sliver: SliverList.builder(
                itemCount: data.length + 1,
                itemBuilder: (context, index) {
                  if (index == data.length) return footer;
                  return data[index].map(
                    file: (fileItem) {
                      final isSelected = selectedFileIds.contains(
                        fileItem.file.id,
                      );
                      return ListTile(
                        leading: Icon(
                          isSelected ? Symbols.check_box : Symbols.description,
                        ),
                        selected: isSelected,
                        title: Text(
                          fileItem.file.name.isEmpty
                              ? 'untitled'.tr()
                              : fileItem.file.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(formatFileSize(fileItem.file.size)),
                        onTap: () => multiSelectEnabled
                            ? onToggleSelection?.call(fileItem.file)
                            : onSelected(fileItem.file),
                      );
                    },
                    folder: (folderItem) {
                      final isSelected = selectedFileIds.contains(
                        folderItem.file.id,
                      );
                      return ListTile(
                        leading: Icon(
                          isSelected ? Symbols.check_box : Symbols.folder,
                        ),
                        selected: isSelected,
                        title: Text(
                          folderItem.file.name.isEmpty
                              ? 'untitled'.tr()
                              : folderItem.file.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text('folder'.tr()),
                        trailing: IconButton(
                          icon: Icon(
                            multiSelectEnabled
                                ? (isSelected
                                      ? Symbols.check_box
                                      : Symbols.check_box_outline_blank)
                                : Symbols.add,
                          ),
                          tooltip: multiSelectEnabled
                              ? 'selected'.tr()
                              : 'linkAttachment'.tr(),
                          onPressed: () => multiSelectEnabled
                              ? onToggleSelection?.call(folderItem.file)
                              : onSelected(folderItem.file),
                        ),
                        onTap: () {
                          currentPath.value = currentPath.value == '/'
                              ? '/${folderItem.file.name}'
                              : '${currentPath.value}/${folderItem.file.name}';
                        },
                      );
                    },
                    unindexedFile: (unindexedFileItem) =>
                        const SizedBox.shrink(),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _RecentCloudFilesWaterfall extends StatelessWidget {
  final EdgeInsetsGeometry padding;
  final ValueChanged<SnCloudFile> onSelected;
  final ValueChanged<SnCloudFile>? onToggleSelection;
  final bool multiSelectEnabled;
  final Set<String> selectedFileIds;
  final List<Widget> sliverHeaders;

  const _RecentCloudFilesWaterfall({
    required this.padding,
    required this.onSelected,
    required this.multiSelectEnabled,
    required this.selectedFileIds,
    this.onToggleSelection,
    required this.sliverHeaders,
  });

  @override
  Widget build(BuildContext context) {
    return PaginationWidget(
      provider: cloudFileListNotifierProvider,
      notifier: cloudFileListNotifierProvider.notifier,
      isRefreshable: false,
      contentBuilder: (data, footer) => CustomScrollView(
        slivers: [
          ...sliverHeaders,
          SliverPadding(
            padding: padding,
            sliver: SliverMasonryGrid(
              gridDelegate:
                  const SliverSimpleGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 180,
                  ),
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              delegate: SliverChildBuilderDelegate((context, index) {
                if (index == data.length) return footer;
                return _CloudFileLinkTile(
                  file: data[index],
                  isSelected: selectedFileIds.contains(data[index].id),
                  showSelectionState: multiSelectEnabled,
                  onTap: () => multiSelectEnabled
                      ? onToggleSelection?.call(data[index])
                      : onSelected(data[index]),
                );
              }, childCount: data.length + 1),
            ),
          ),
        ],
      ),
    );
  }
}

class _CloudFileLinkTile extends ConsumerWidget {
  final SnCloudFile file;
  final bool isSelected;
  final bool showSelectionState;
  final VoidCallback onTap;

  const _CloudFileLinkTile({
    required this.file,
    required this.isSelected,
    required this.showSelectionState,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ratio = file.ratio ?? 1.0;
    final itemType = file.mimeType.split('/').first;

    final previewWidget = switch (itemType) {
      'image' => CloudImageWidget(
        file: file,
        aspectRatio: ratio,
        fit: BoxFit.cover,
      ),
      'video' => CloudVideoWidget(item: file),
      _ => getFileIcon(file, size: 48),
    };

    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outline.withOpacity(0.3),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                  child: AspectRatio(
                    aspectRatio: ratio,
                    child: Container(
                      color: Theme.of(context).colorScheme.surfaceContainer,
                      child: previewWidget,
                    ),
                  ),
                ),
                if (showSelectionState)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isSelected
                            ? Symbols.check_circle
                            : Symbols.radio_button_unchecked,
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                        size: 22,
                      ),
                    ),
                  ),
              ],
            ),
            Row(
              children: [
                getFileIcon(file, size: 22, tinyPreview: false),
                const Gap(10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      file.name.isEmpty
                          ? Text('untitled').tr().italic()
                          : Text(
                              file.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                      Text(
                        formatFileSize(file.size),
                        maxLines: 1,
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall!.copyWith(fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ],
            ).padding(horizontal: 10, vertical: 6),
          ],
        ),
      ),
    );
  }
}

class _ManualCloudFileLinkForm extends ConsumerWidget {
  final TextEditingController idController;
  final ValueNotifier<String?> errorMessage;
  final ValueChanged<SnCloudFile> onSelected;
  final ValueChanged<SnCloudFile>? onToggleSelection;
  final bool multiSelectEnabled;

  const _ManualCloudFileLinkForm({
    required this.idController,
    required this.errorMessage,
    required this.onSelected,
    required this.multiSelectEnabled,
    this.onToggleSelection,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: idController,
            decoration: InputDecoration(
              labelText: 'fileId'.tr(),
              helperText: 'fileIdHint'.tr(),
              helperMaxLines: 3,
              errorText: errorMessage.value,
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
            ),
            onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
          ),
          const Gap(16),
          InkWell(
            child: Text('fileIdLinkHint').tr().fontSize(13).opacity(0.85),
            onTap: () {
              launchUrlString('https://fs.solian.app');
            },
          ).padding(horizontal: 14),
          const Gap(16),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              icon: const Icon(Symbols.add),
              label: Text('add'.tr()),
              onPressed: () async {
                final fileId = idController.text.trim();
                if (fileId.isEmpty) {
                  errorMessage.value = 'fileIdCannotBeEmpty'.tr();
                  return;
                }

                try {
                  final client = ref.read(solarNetworkClientProvider);
                  final cloudFile = await client.drive.getFileInfo(fileId);

                  if (context.mounted) {
                    if (multiSelectEnabled) {
                      onToggleSelection?.call(cloudFile);
                    } else {
                      onSelected(cloudFile);
                    }
                  }
                } catch (e) {
                  errorMessage.value = 'failedToFetchFile'.tr(
                    args: [e.toString()],
                  );
                }
              },
            ),
          ),
        ],
      ).padding(horizontal: 24, vertical: 24),
    );
  }
}
