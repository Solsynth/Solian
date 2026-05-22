import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/drive/screens/file_list.dart';
import 'package:island/core/network.dart';
import 'package:island/drive/drive_service.dart';
import 'package:island/core/services/responsive.dart';
import 'package:island/core/utils/file_icon_utils.dart';
import 'package:island/core/utils/format.dart';
import 'package:island/route.gr.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:island/shared/widgets/pagination_list.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

enum FileListMode { normal, unindexed }

enum FileListViewMode { list, waterfall }

class FileListView extends HookConsumerWidget {
  final Map<String, dynamic>? usage;
  final Map<String, dynamic>? quota;
  final ValueNotifier<String> currentPath;
  final ValueNotifier<SnFilePool?> selectedPool;
  final VoidCallback onPickAndUpload;
  final VoidCallback onShowCreateFolder;
  final void Function(SnCloudFile file) onInspectFile;
  final ValueNotifier<FileListMode> mode;
  final ValueNotifier<FileListViewMode> viewMode;
  final ValueNotifier<bool> isSelectionMode;
  final ValueNotifier<String?> query;

  const FileListView({
    required this.usage,
    required this.quota,
    required this.currentPath,
    required this.selectedPool,
    required this.onPickAndUpload,
    required this.onShowCreateFolder,
    required this.onInspectFile,
    required this.mode,
    required this.viewMode,
    required this.isSelectionMode,
    required this.query,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dragging = useState(false);

    useEffect(() {
      if (mode.value == FileListMode.normal) {
        final notifier = ref.read(indexedCloudFileListProvider.notifier);
        notifier.setPath(currentPath.value);
      }
      return null;
    }, [currentPath.value, mode.value]);

    if (usage == null) return const SizedBox.shrink();

    final unindexedNotifier = ref.read(unindexedFileListProvider.notifier);
    final cloudNotifier = ref.read(indexedCloudFileListProvider.notifier);
    final recycled = useState<bool>(false);
    final isSelectionMode = useState<bool>(false);
    final selectedFileIds = useState<Set<String>>({});
    final currentVisibleItems = useState<List<FileListItem>>([]);
    final order = useState<String?>('date');
    final orderDesc = useState<bool>(true);
    final queryDebounceTimer = useRef<Timer?>(null);

    useEffect(() {
      if (mode.value == FileListMode.unindexed) {
        isSelectionMode.value = false;
        selectedFileIds.value.clear();
      }
      return null;
    }, [mode.value]);

    useEffect(() {
      // Sync pool when mode or selectedPool changes
      if (mode.value == FileListMode.unindexed) {
        unindexedNotifier.setPool(selectedPool.value?.id);
      } else {
        cloudNotifier.setPool(selectedPool.value?.id);
      }
      return null;
    }, [selectedPool.value, mode.value]);

    useEffect(() {
      // Sync query, order, and orderDesc filters
      if (mode.value == FileListMode.unindexed) {
        unindexedNotifier.setQuery(query.value);
        unindexedNotifier.setOrder(order.value);
        unindexedNotifier.setOrderDesc(orderDesc.value);
      } else {
        cloudNotifier.setQuery(query.value);
        cloudNotifier.setOrder(order.value);
        cloudNotifier.setOrderDesc(orderDesc.value);
      }
      return null;
    }, [query.value, order.value, orderDesc.value, mode.value]);

    final isRefreshing = ref.watch(
      mode.value == FileListMode.normal
          ? indexedCloudFileListProvider.select((value) => value.isLoading)
          : unindexedFileListProvider.select((value) => value.isLoading),
    );

    final bodyWidget = switch (mode.value) {
      FileListMode.unindexed => PaginationWidget(
        provider: unindexedFileListProvider,
        notifier: unindexedFileListProvider.notifier,
        isRefreshable: false,
        isSliver: true,
        contentBuilder: (data, footer) => data.isEmpty
            ? SliverToBoxAdapter(child: _buildEmptyUnindexedFilesHint(ref))
            : _buildUnindexedFileListContent(
                data,
                ref,
                context,
                viewMode,
                isSelectionMode,
                selectedFileIds,
                currentVisibleItems,
                footer,
              ),
      ),
      _ => PaginationWidget(
        provider: indexedCloudFileListProvider,
        notifier: indexedCloudFileListProvider.notifier,
        isRefreshable: false,
        isSliver: true,
        contentBuilder: (data, footer) => data.isEmpty
            ? SliverToBoxAdapter(
                child: _buildEmptyDirectoryHint(ref, currentPath),
              )
            : _buildFileListContent(
                data,
                ref,
                context,
                currentPath,
                viewMode,
                isSelectionMode,
                selectedFileIds,
                currentVisibleItems,
                footer,
              ),
      ),
    };

    late Widget pathWidget;
    if (mode.value == FileListMode.unindexed) {
      pathWidget = InkWell(
        onTap: () async {
          final result = await showMenu<String>(
            context: context,
            position: const RelativeRect.fromLTRB(50, 100, 50, 100),
            items: [
              PopupMenuItem<String>(
                value: 'root',
                child: Row(
                  children: [
                    Icon(Symbols.folder),
                    const Gap(12),
                    Text('rootDirectory').tr(),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'unindexed',
                child: Row(
                  children: [
                    Icon(Symbols.inventory_2),
                    const Gap(12),
                    Text('unindexedFiles').tr(),
                  ],
                ),
              ),
            ],
          );
          if (result == 'root') {
            mode.value = FileListMode.normal;
            currentPath.value = '/';
          }
          // 'unindexed' does nothing as we're already in unindexed mode
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Symbols.inventory_2, size: 20),
            const Gap(8),
            Text(
              'unindexedFiles',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ).tr(),
          ],
        ),
      );
    } else if (currentPath.value == '/') {
      pathWidget = InkWell(
        onTap: () async {
          final result = await showMenu<String>(
            context: context,
            position: const RelativeRect.fromLTRB(50, 100, 50, 100),
            items: [
              PopupMenuItem<String>(
                value: 'unindexed',
                child: Row(
                  children: [
                    Icon(Symbols.inventory_2),
                    const Gap(12),
                    Text('unindexedFiles').tr(),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'root',
                child: Row(
                  children: [
                    Icon(Symbols.folder),
                    const Gap(12),
                    Text('rootDirectory').tr(),
                  ],
                ),
              ),
            ],
          );
          if (result == 'unindexed') {
            mode.value = FileListMode.unindexed;
          }
          // 'root' does nothing as we're already at root
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Symbols.folder, size: 20),
            const Gap(8),
            Text(
              'rootDirectory',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ).tr(),
          ],
        ),
      );
    } else {
      final pathParts = currentPath.value
          .split('/')
          .where((part) => part.isNotEmpty)
          .toList();
      final breadcrumbs = <Widget>[];

      // Add root
      breadcrumbs.add(
        InkWell(
          onTap: () => currentPath.value = '/',
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Symbols.folder, size: 20),
              const Gap(4),
              const Text(
                'Root',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ],
          ),
        ),
      );

      // Add path parts
      String currentPathBuilder = '';
      for (int i = 0; i < pathParts.length; i++) {
        currentPathBuilder += '/${pathParts[i]}';
        final path = currentPathBuilder;

        breadcrumbs.add(Text('pathSeparator').tr());
        if (i == pathParts.length - 1) {
          // Current directory
          breadcrumbs.add(
            Text(
              pathParts[i],
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          );
        } else {
          // Clickable parent directory
          breadcrumbs.add(
            InkWell(
              onTap: () => currentPath.value = path,
              child: Text(
                pathParts[i],
                style: const TextStyle(color: Colors.blue),
              ),
            ),
          );
        }
      }

      pathWidget = Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        children: breadcrumbs,
      );
    }

    return DropTarget(
      onDragDone: (details) async {
        dragging.value = false;
        // Handle file upload
        for (final file in details.files) {
          final universalFile = UniversalFile(
            data: file,
            type: UniversalFileType.file,
            displayName: file.name,
          );

          final completer = ref
              .read(driveFileUploaderProvider)
              .createCloudFile(
                fileData: universalFile,
                path: mode.value == FileListMode.normal
                    ? currentPath.value
                    : null,
                poolId: selectedPool.value?.id,
                onProgress: (progress, _) {
                  // Progress is handled by the upload tasks system
                  if (progress != null) {
                    debugPrint('Upload progress: ${(progress * 100).toInt()}%');
                  }
                },
              );

          completer.future
              .then((uploadedFile) {
                if (uploadedFile != null) {
                  ref.invalidate(indexedCloudFileListProvider);
                }
              })
              .catchError((error) {
                showSnackBar('failedToUploadFile'.tr(args: [error]));
              });
        }
      },
      onDragEntered: (details) {
        dragging.value = true;
      },
      onDragExited: (details) {
        dragging.value = false;
      },
      child: Container(
        color: dragging.value
            ? Theme.of(context).primaryColor.withOpacity(0.1)
            : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Gap(12),

            // Breadcrumbs and view switch at the top
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 16, 0),
              child: Row(
                children: [
                  Expanded(
                    child: AbsorbPointer(
                      absorbing: isRefreshing,
                      child: pathWidget,
                    ),
                  ),
                  const Gap(12),
                  SegmentedButton<FileListViewMode>(
                    segments: [
                      ButtonSegment<FileListViewMode>(
                        value: FileListViewMode.list,
                        icon: Icon(Symbols.list),
                        tooltip: 'listView'.tr(),
                      ),
                      ButtonSegment<FileListViewMode>(
                        value: FileListViewMode.waterfall,
                        icon: Icon(Symbols.view_module),
                        tooltip: 'waterfallView'.tr(),
                      ),
                    ],
                    selected: {viewMode.value},
                    onSelectionChanged: (Set<FileListViewMode> newSelection) {
                      viewMode.value = newSelection.first;
                    },
                  ),
                ],
              ),
            ),

            const Gap(12),

            // Chip-based filters
            _buildChipFilters(
              ref,
              selectedPool,
              mode,
              currentPath,
              isRefreshing,
              unindexedNotifier,
              cloudNotifier,
              query,
              order,
              orderDesc,
              queryDebounceTimer,
            ),
            const Gap(8),

            if (mode.value == FileListMode.unindexed && recycled.value)
              _buildClearRecycledButton(ref).padding(horizontal: 8),
            if (isRefreshing)
              const LinearProgressIndicator(
                minHeight: 4,
              ).padding(horizontal: 16, top: 6, bottom: 4),
            const Gap(8),
            Expanded(
              child:
                  CustomScrollView(
                    slivers: [bodyWidget, const SliverGap(12)],
                  ).padding(
                    horizontal: viewMode.value == FileListViewMode.waterfall
                        ? 12
                        : null,
                  ),
            ),
            if (isSelectionMode.value)
              Material(
                color: Theme.of(context).colorScheme.surfaceContainer,
                elevation: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      TextButton(
                        onPressed: () {
                          isSelectionMode.value = false;
                          selectedFileIds.value.clear();
                        },
                        child: Text('cancel').tr(),
                      ),
                      const Gap(12),
                      OutlinedButton(
                        onPressed: () {
                          final allIds = currentVisibleItems.value
                              .expand(
                                (item) => item.maybeMap(
                                  file: (f) => [f.file.id],
                                  unindexedFile: (u) => [u.file.id],
                                  orElse: () => <String>[],
                                ),
                              )
                              .toSet();

                          if (allIds
                              .difference(selectedFileIds.value)
                              .isEmpty) {
                            // All items are selected, deselect all
                            selectedFileIds.value.clear();
                          } else {
                            // Select all visible items
                            selectedFileIds.value = allIds;
                          }
                        },
                        child: Text(
                          currentVisibleItems.value.isEmpty
                              ? 'selectAll'.tr()
                              : currentVisibleItems.value
                                    .expand(
                                      (item) => item.maybeMap(
                                        file: (f) => [f.file.id],
                                        unindexedFile: (u) => [u.file.id],
                                        orElse: () => <String>[],
                                      ),
                                    )
                                    .toSet()
                                    .difference(selectedFileIds.value)
                                    .isEmpty
                              ? 'deselectAll'.tr()
                              : 'selectAll'.tr(),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        selectedFileIds.value.length == 1
                            ? 'fileSelected'.tr(
                                args: [selectedFileIds.value.length.toString()],
                              )
                            : 'filesSelected'.tr(
                                args: [selectedFileIds.value.length.toString()],
                              ),
                      ),
                      const Spacer(),
                      ElevatedButton.icon(
                        icon: const Icon(Symbols.delete),
                        label: Text('delete').tr(),
                        onPressed: selectedFileIds.value.isNotEmpty
                            ? () async {
                                final confirmed = await showConfirmAlert(
                                  'confirmDeleteSelectedFiles'.tr(),
                                  'deleteSelectedFiles'.tr(),
                                  isDanger: true,
                                );
                                if (!confirmed) return;
                                if (context.mounted) {
                                  showLoadingModal(context);
                                }
                                try {
                                  final uploader = ref.read(
                                    driveFileUploaderProvider,
                                  );
                                  final count = await uploader.batchDeleteFiles(
                                    selectedFileIds.value.toList(),
                                  );
                                  selectedFileIds.value.clear();
                                  isSelectionMode.value = false;
                                  ref.invalidate(
                                    mode.value == FileListMode.normal
                                        ? indexedCloudFileListProvider
                                        : unindexedFileListProvider,
                                  );
                                  showSnackBar(
                                    'deletedFilesCount'.tr(
                                      args: [count.toString()],
                                    ),
                                  );
                                } catch (e) {
                                  showSnackBar(
                                    'failedToDeleteSelectedFiles'.tr(),
                                  );
                                } finally {
                                  if (context.mounted) {
                                    hideLoadingModal(context);
                                  }
                                }
                              }
                            : null,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFileListContent(
    List<FileListItem> items,
    WidgetRef ref,
    BuildContext context,
    ValueNotifier<String> currentPath,
    ValueNotifier<FileListViewMode> currentViewMode,
    ValueNotifier<bool> isSelectionMode,
    ValueNotifier<Set<String>> selectedFileIds,
    ValueNotifier<List<FileListItem>> currentVisibleItems,
    Widget footer,
  ) {
    if (currentVisibleItems.value != items) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        currentVisibleItems.value = items;
      });
    }
    return switch (currentViewMode.value) {
      // Waterfall mode
      FileListViewMode.waterfall => SliverMasonryGrid(
        gridDelegate: SliverSimpleGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: isWideScreen(context) ? 340 : 240,
        ),
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        delegate: SliverChildBuilderDelegate((context, index) {
          if (index == items.length) {
            return footer;
          }
          if (index > items.length) {
            return const SizedBox.shrink();
          }

          final item = items[index];
          return item.map(
            file: (fileItem) => _buildWaterfallFileTile(
              fileItem,
              ref,
              context,
              isSelectionMode.value,
              selectedFileIds.value.contains(fileItem.file.id),
              () {
                if (selectedFileIds.value.contains(fileItem.file.id)) {
                  selectedFileIds.value = Set.from(selectedFileIds.value)
                    ..remove(fileItem.file.id);
                } else {
                  selectedFileIds.value = Set.from(selectedFileIds.value)
                    ..add(fileItem.file.id);
                }
              },
            ),
            folder: (folderItem) =>
                _buildWaterfallFolderTile(folderItem, currentPath, context),
            unindexedFile: (unindexedFileItem) {
              // Should not happen
              return const SizedBox.shrink();
            },
          );
        }, childCount: items.length + 1),
      ),
      // ListView mode
      _ => SliverList.builder(
        itemCount: items.length + 1,
        itemBuilder: (context, index) {
          if (index == items.length) {
            return footer;
          }
          final item = items[index];
          return item.map(
            file: (fileItem) => _buildIndexedListTile(
              fileItem,
              ref,
              context,
              isSelectionMode.value,
              selectedFileIds.value.contains(fileItem.file.id),
              () {
                if (selectedFileIds.value.contains(fileItem.file.id)) {
                  selectedFileIds.value = Set.from(selectedFileIds.value)
                    ..remove(fileItem.file.id);
                } else {
                  selectedFileIds.value = Set.from(selectedFileIds.value)
                    ..add(fileItem.file.id);
                }
              },
            ),
            folder: (folderItem) => InkWell(
              onTap: () {
                final newPath = currentPath.value == '/'
                    ? '/${folderItem.file.name}'
                    : '${currentPath.value}/${folderItem.file.name}';
                currentPath.value = newPath;
              },
              onLongPress: () => onInspectFile(folderItem.file),
              onSecondaryTap: () => onInspectFile(folderItem.file),
              child: ListTile(
                leading: ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                  child: SizedBox(
                    height: 48,
                    width: 48,
                    child: const Icon(Symbols.folder, fill: 1).center(),
                  ),
                ),
                title: Text(
                  folderItem.file.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text('folder').tr(),
              ),
            ),
            unindexedFile: (unindexedFileItem) {
              // Should not happen in normal mode
              return const SizedBox.shrink();
            },
          );
        },
      ),
    };
  }

  Widget _buildEmptyDirectoryHint(
    WidgetRef ref,
    ValueNotifier<String> currentPath,
  ) {
    return Card(
      margin: viewMode.value == FileListViewMode.waterfall
          ? const EdgeInsets.fromLTRB(0, 0, 0, 16)
          : const EdgeInsets.fromLTRB(12, 0, 12, 16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Symbols.folder_off, size: 64, color: Colors.grey),
            const Gap(16),
            Text(
              'thisDirectoryIsEmpty',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(ref.context).textTheme.bodyLarge?.color,
              ),
            ).tr(),
            const Gap(8),
            Text(
              'emptyDirectoryHint',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(
                  ref.context,
                ).textTheme.bodyMedium?.color?.withOpacity(0.7),
              ),
            ).tr(),
            const Gap(16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: onPickAndUpload,
                    icon: const Icon(Symbols.upload_file),
                    label: Text('uploadFiles').tr(),
                  ),
                  const Gap(12),
                  OutlinedButton.icon(
                    onPressed: onShowCreateFolder,
                    icon: const Icon(Symbols.create_new_folder),
                    label: Text('createDirectory').tr(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWaterfallFileTile(
    FileItem fileItem,
    WidgetRef ref,
    BuildContext context,
    bool isSelectionMode,
    bool isSelected,
    VoidCallback? toggleSelection,
  ) {
    return _buildWaterfallFileTileBase(
      fileItem.file,
      () => '/files/${fileItem.file.id}',
      ref,
      context,
      [
        IconButton(
          icon: const Icon(Symbols.delete),
          onPressed: () async {
            final confirmed = await showConfirmAlert(
              'confirmDeleteFile'.tr(),
              'deleteFile'.tr(),
              isDanger: true,
            );
            if (!confirmed) return;

            if (context.mounted) {
              showLoadingModal(context);
            }
            try {
              final uploader = ref.read(driveFileUploaderProvider);
              await uploader.deleteFile(fileItem.file.id);
              ref.invalidate(indexedCloudFileListProvider);
            } catch (e) {
              showSnackBar('failedToDeleteFile'.tr());
            } finally {
              if (context.mounted) {
                hideLoadingModal(context);
              }
            }
          },
        ),
      ],
      isSelectionMode,
      isSelected,
      toggleSelection,
    );
  }

  Widget _buildWaterfallFileTileBase(
    SnCloudFile file,
    String Function() getRoutePath,
    WidgetRef ref,
    BuildContext context,
    List<Widget>? actions,
    bool isSelectionMode,
    bool isSelected,
    VoidCallback? toggleSelection,
  ) {
    final meta = file.fileMeta;
    final ratio = meta['ratio'] is num
        ? (meta['ratio'] as num).toDouble()
        : 1.0;
    final itemType = file.mimeType.split('/').first;
    final uri =
        '${ref.read(solarNetworkClientProvider).dio.options.baseUrl}/drive/files/${file.id}';

    Widget previewWidget;
    switch (itemType) {
      case 'image':
        previewWidget = CloudImageWidget(
          file: file,
          aspectRatio: ratio,
          fit: BoxFit.cover,
        );
        break;
      case 'video':
        previewWidget = CloudVideoWidget(item: file);
        break;
      case 'audio':
        previewWidget = getFileIcon(file, size: 48);
        break;
      case 'text':
        previewWidget = Container(
          color: Theme.of(context).colorScheme.surfaceContainer,
          child: FutureBuilder<String>(
            future: ref
                .read(solarNetworkClientProvider)
                .dio
                .get(uri)
                .then((response) => response.data as String),
            builder: (context, snapshot) => snapshot.hasData
                ? SingleChildScrollView(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      snapshot.data!,
                      style: const TextStyle(
                        fontSize: 9,
                        fontFamily: 'monospace',
                      ),
                      maxLines: 20,
                      overflow: TextOverflow.ellipsis,
                    ),
                  )
                : const Center(child: CircularProgressIndicator()),
          ),
        );
        break;
      default:
        previewWidget = getFileIcon(file, size: 48);
        break;
    }

    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () {
        if (isSelectionMode && toggleSelection != null) {
          toggleSelection();
        } else {
          context.router.pushPath(getRoutePath());
        }
      },
      onLongPress: () => onInspectFile(file),
      onSecondaryTap: () => onInspectFile(file),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
          ),
        ),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
              child: AspectRatio(
                aspectRatio: ratio,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Container(color: Colors.white, child: previewWidget),
                ),
              ),
            ),
            Row(
              children: [
                if (isSelectionMode)
                  Checkbox(
                    value: isSelected,
                    onChanged: (value) => toggleSelection?.call(),
                  )
                else
                  getFileIcon(file, size: 24, tinyPreview: false),
                const Gap(16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
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
                ...?actions,
              ],
            ).padding(horizontal: 16, vertical: 4),
          ],
        ),
      ),
    );
  }

  Widget _buildWaterfallFolderTile(
    FolderItem folderItem,
    ValueNotifier<String> currentPath,
    BuildContext context,
  ) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () {
        final newPath = currentPath.value == '/'
            ? '/${folderItem.file.name}'
            : '${currentPath.value}/${folderItem.file.name}';
        currentPath.value = newPath;
      },
      onLongPress: () => onInspectFile(folderItem.file),
      onSecondaryTap: () => onInspectFile(folderItem.file),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Symbols.folder,
              fill: 1,
              size: 24,
              color: Theme.of(context).colorScheme.primaryFixedDim,
            ),
            const Gap(16),
            Text(
              folderItem.file.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnindexedFileListContent(
    List<FileListItem> items,
    WidgetRef ref,
    BuildContext context,
    ValueNotifier<FileListViewMode> currentViewMode,
    ValueNotifier<bool> isSelectionMode,
    ValueNotifier<Set<String>> selectedFileIds,
    ValueNotifier<List<FileListItem>> currentVisibleItems,
    Widget footer,
  ) {
    if (currentVisibleItems.value != items) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        currentVisibleItems.value = items;
      });
    }
    return switch (currentViewMode.value) {
      // Waterfall mode
      FileListViewMode.waterfall => SliverMasonryGrid(
        gridDelegate: SliverSimpleGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: isWideScreen(context) ? 340 : 240,
        ),
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        delegate: SliverChildBuilderDelegate((context, index) {
          if (index == items.length) {
            return footer;
          }
          if (index > items.length) {
            return const SizedBox.shrink();
          }

          final item = items[index];
          return item.map(
            file: (fileItem) {
              // Should not happen in unindexed mode
              return const SizedBox.shrink();
            },
            folder: (folderItem) {
              // Should not happen in unindexed mode
              return const SizedBox.shrink();
            },
            unindexedFile: (unindexedFileItem) =>
                _buildWaterfallUnindexedFileTile(
                  unindexedFileItem,
                  ref,
                  context,
                  isSelectionMode.value,
                  selectedFileIds.value.contains(unindexedFileItem.file.id),
                  () {
                    if (selectedFileIds.value.contains(
                      unindexedFileItem.file.id,
                    )) {
                      selectedFileIds.value = Set.from(selectedFileIds.value)
                        ..remove(unindexedFileItem.file.id);
                    } else {
                      selectedFileIds.value = Set.from(selectedFileIds.value)
                        ..add(unindexedFileItem.file.id);
                    }
                  },
                ),
          );
        }, childCount: items.length + 1),
      ),
      // ListView mode
      _ => SliverList.builder(
        itemCount: items.length + 1,
        itemBuilder: (context, index) {
          if (index == items.length) {
            return footer;
          }
          final item = items[index];
          return item.map(
            file: (fileItem) {
              // Should not happen in unindexed mode
              return const SizedBox.shrink();
            },
            folder: (folderItem) {
              // Should not happen in unindexed mode
              return const SizedBox.shrink();
            },
            unindexedFile: (unindexedFileItem) => _buildUnindexedListTile(
              unindexedFileItem,
              ref,
              context,
              isSelectionMode.value,
              selectedFileIds.value.contains(unindexedFileItem.file.id),
              () {
                if (selectedFileIds.value.contains(unindexedFileItem.file.id)) {
                  selectedFileIds.value = Set.from(selectedFileIds.value)
                    ..remove(unindexedFileItem.file.id);
                } else {
                  selectedFileIds.value = Set.from(selectedFileIds.value)
                    ..add(unindexedFileItem.file.id);
                }
              },
            ),
          );
        },
      ),
    };
  }

  Widget _buildIndexedListTile(
    FileItem fileItem,
    WidgetRef ref,
    BuildContext context,
    bool isSelectionMode,
    bool isSelected,
    VoidCallback toggleSelection,
  ) {
    final file = fileItem.file;
    return ListTile(
      leading: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isSelectionMode)
            Checkbox(
              value: isSelected,
              onChanged: (value) => toggleSelection(),
            ),
          ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(8)),
            child: SizedBox(
              height: 48,
              width: 48,
              child: getFileIcon(file, size: 24),
            ),
          ),
        ],
      ),
      title: file.name.isEmpty
          ? Text('untitled').tr().italic()
          : Text(file.name, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(formatFileSize(file.size)),
      onTap: () {
        if (isSelectionMode) {
          toggleSelection();
        } else {
          context.router.push(FileDetailRoute(id: file.id));
        }
      },
      trailing: IconButton(
        icon: const Icon(Symbols.delete),
        onPressed: () async {
          final confirmed = await showConfirmAlert(
            'confirmDeleteFile'.tr(),
            'deleteFile'.tr(),
            isDanger: true,
          );
          if (!confirmed) return;

          if (context.mounted) {
            showLoadingModal(context);
          }
          try {
            final uploader = ref.read(driveFileUploaderProvider);
            await uploader.deleteFile(fileItem.file.id);
            ref.invalidate(indexedCloudFileListProvider);
          } catch (e) {
            showSnackBar('failedToDeleteFile'.tr());
          } finally {
            if (context.mounted) {
              hideLoadingModal(context);
            }
          }
        },
      ),
    );
  }

  Widget _buildUnindexedListTile(
    UnindexedFileItem unindexedFileItem,
    WidgetRef ref,
    BuildContext context,
    bool isSelectionMode,
    bool isSelected,
    VoidCallback toggleSelection,
  ) {
    final file = unindexedFileItem.file;
    return ListTile(
      leading: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isSelectionMode)
            Checkbox(
              value: isSelected,
              onChanged: (value) => toggleSelection(),
            ),
          ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(8)),
            child: SizedBox(
              height: 48,
              width: 48,
              child: getFileIcon(file, size: 24),
            ),
          ),
        ],
      ),
      title: file.name.isEmpty
          ? Text('untitled').tr().italic()
          : Text(file.name, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(formatFileSize(file.size)),
      onTap: () {
        if (isSelectionMode) {
          toggleSelection();
        } else {
          context.router.push(FileDetailRoute(id: file.id));
        }
      },
      trailing: IconButton(
        icon: const Icon(Symbols.delete),
        onPressed: () async {
          final confirmed = await showConfirmAlert(
            'confirmDeleteFile'.tr(),
            'deleteFile'.tr(),
            isDanger: true,
          );
          if (!confirmed) return;

          if (context.mounted) {
            showLoadingModal(context);
          }
          try {
            final uploader = ref.read(driveFileUploaderProvider);
            await uploader.deleteFile(file.id);
            ref.invalidate(unindexedFileListProvider);
          } catch (e) {
            showSnackBar('failedToDeleteFile'.tr());
          } finally {
            if (context.mounted) {
              hideLoadingModal(context);
            }
          }
        },
      ),
    );
  }

  Widget _buildWaterfallUnindexedFileTile(
    UnindexedFileItem unindexedFileItem,
    WidgetRef ref,
    BuildContext context,
    bool isSelectionMode,
    bool isSelected,
    VoidCallback? toggleSelection,
  ) {
    return _buildWaterfallFileTileBase(
      unindexedFileItem.file,
      () => '/files/${unindexedFileItem.file.id}',
      ref,
      context,
      [
        IconButton(
          icon: const Icon(Symbols.delete),
          onPressed: () async {
            final confirmed = await showConfirmAlert(
              'confirmDeleteFile'.tr(),
              'deleteFile'.tr(),
              isDanger: true,
            );
            if (!confirmed) return;

            if (context.mounted) {
              showLoadingModal(context);
            }
            try {
              final uploader = ref.read(driveFileUploaderProvider);
              await uploader.deleteFile(unindexedFileItem.file.id);
              ref.invalidate(unindexedFileListProvider);
            } catch (e) {
              showSnackBar('failedToDeleteFile'.tr());
            } finally {
              if (context.mounted) {
                hideLoadingModal(context);
              }
            }
          },
        ),
      ],
      isSelectionMode,
      isSelected,
      toggleSelection,
    );
  }

  Widget _buildEmptyUnindexedFilesHint(WidgetRef ref) {
    return Card(
      margin: viewMode.value == FileListViewMode.waterfall
          ? EdgeInsets.zero
          : const EdgeInsets.fromLTRB(12, 0, 12, 0),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Symbols.inventory_2, size: 64, color: Colors.grey),
            const Gap(16),
            Text(
              'thisDirectoryIsEmpty',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(ref.context).textTheme.bodyLarge?.color,
              ),
            ).tr(),
            const Gap(8),
            Text(
              'emptyDirectoryHint',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(
                  ref.context,
                ).textTheme.bodyMedium?.color?.withOpacity(0.7),
              ),
            ).tr(),
          ],
        ),
      ),
    );
  }

  Widget _buildClearRecycledButton(WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          spacing: 16,
          children: [
            const Icon(Symbols.recycling).padding(horizontal: 2),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('clearAllRecycledFiles').tr().bold(),
                  Text('clearRecycledFilesDescription').tr().fontSize(13),
                ],
              ),
            ),
            ElevatedButton.icon(
              icon: const Icon(Symbols.delete_forever),
              label: Text('clear').tr(),
              onPressed: () async {
                final confirmed = await showConfirmAlert(
                  'confirmClearRecycledFiles'.tr(),
                  'clearRecycledFiles'.tr(),
                );
                if (!confirmed) return;

                if (ref.context.mounted) {
                  showLoadingModal(ref.context);
                }
                try {
                  final uploader = ref.read(driveFileUploaderProvider);
                  final count = await uploader.deleteRecycledFiles();
                  showSnackBar(
                    'clearedRecycledFilesCount'.tr(args: [count.toString()]),
                  );
                  ref.invalidate(unindexedFileListProvider);
                } catch (e) {
                  showSnackBar('failedToClearRecycledFiles'.tr());
                } finally {
                  if (ref.context.mounted) {
                    hideLoadingModal(ref.context);
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChipFilters(
    WidgetRef ref,
    ValueNotifier<SnFilePool?> selectedPool,
    ValueNotifier<FileListMode> mode,
    ValueNotifier<String> currentPath,
    bool isRefreshing,
    dynamic unindexedNotifier,
    dynamic cloudNotifier,
    ValueNotifier<String?> query,
    ValueNotifier<String?> order,
    ValueNotifier<bool> orderDesc,
    ObjectRef<Timer?> queryDebounceTimer,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          // Order filter dropdown
          Container(
            height: 32,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(
                  ref.context,
                ).colorScheme.outline.withOpacity(0.5),
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: order.value ?? 'date',
                items: [
                  DropdownMenuItem<String>(
                    value: 'date',
                    child: Row(
                      spacing: 6,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Symbols.schedule, size: 16),
                        Text('date', style: const TextStyle(fontSize: 12)).tr(),
                        if (order.value == 'date')
                          Icon(
                            orderDesc.value
                                ? Symbols.arrow_downward
                                : Symbols.arrow_upward,
                            size: 14,
                          ),
                      ],
                    ),
                  ),
                  DropdownMenuItem<String>(
                    value: 'size',
                    child: Row(
                      spacing: 6,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Symbols.data_usage, size: 16),
                        Text(
                          'fileSize'.tr(),
                          style: const TextStyle(fontSize: 12),
                        ),
                        if (order.value == 'size')
                          Icon(
                            orderDesc.value
                                ? Symbols.arrow_downward
                                : Symbols.arrow_upward,
                            size: 16,
                          ),
                      ],
                    ),
                  ),
                  DropdownMenuItem<String>(
                    value: 'name',
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      spacing: 6,
                      children: [
                        Icon(Symbols.sort_by_alpha, size: 16),
                        Text(
                          'fileName'.tr(),
                          style: const TextStyle(fontSize: 12),
                        ),
                        if (order.value == 'name')
                          Icon(
                            orderDesc.value
                                ? Symbols.arrow_downward
                                : Symbols.arrow_upward,
                            size: 16,
                          ),
                      ],
                    ),
                  ),
                ],
                onChanged: (value) {
                  if (value == order.value) {
                    // Toggle direction if same option selected
                    final newValue = !orderDesc.value;
                    orderDesc.value = newValue;
                    if (mode.value == FileListMode.unindexed) {
                      unindexedNotifier.setOrderDesc(newValue);
                    } else {
                      cloudNotifier.setOrderDesc(newValue);
                    }
                  } else {
                    // Change sort option
                    order.value = value;
                    if (mode.value == FileListMode.unindexed) {
                      unindexedNotifier.setOrder(value);
                    } else {
                      cloudNotifier.setOrder(value);
                    }
                  }
                },
                icon: const SizedBox.shrink(),
                isDense: true,
              ),
            ),
          ),

          const Gap(8),

          // Refresh chip
          FilterChip(
            label: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: 6,
              children: [
                Icon(Symbols.refresh, size: 16),
                Text('refresh', style: TextStyle(fontSize: 12)).tr(),
              ],
            ),
            selected: false,
            onSelected: (selected) {
              if (selected) {
                if (mode.value == FileListMode.unindexed) {
                  ref.invalidate(unindexedFileListProvider);
                } else {
                  cloudNotifier.setPath(currentPath.value);
                }
              }
            },
          ),
        ],
      ),
    );
  }
}
