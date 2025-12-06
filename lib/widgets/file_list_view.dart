import 'dart:async';

import 'package:desktop_drop/desktop_drop.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/models/file_list_item.dart';
import 'package:island/models/file.dart';
import 'package:island/models/file_pool.dart';
import 'package:island/pods/drive/file_list.dart';
import 'package:island/pods/drive/file_pool.dart';
import 'package:island/pods/network.dart';
import 'package:island/services/file_uploader.dart';
import 'package:island/services/responsive.dart';
import 'package:island/utils/file_icon_utils.dart';
import 'package:island/utils/format.dart';
import 'package:island/utils/text.dart';
import 'package:island/widgets/alert.dart';
import 'package:island/widgets/content/cloud_files.dart';
import 'package:island/widgets/paging/pagination_list.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:styled_widget/styled_widget.dart';

enum FileListMode { normal, unindexed }

enum FileListViewMode { list, waterfall }

class FileListView extends HookConsumerWidget {
  final Map<String, dynamic>? usage;
  final Map<String, dynamic>? quota;
  final ValueNotifier<String> currentPath;
  final ValueNotifier<SnFilePool?> selectedPool;
  final VoidCallback onPickAndUpload;
  final Function(BuildContext, ValueNotifier<String>) onShowCreateDirectory;
  final ValueNotifier<FileListMode> mode;
  final ValueNotifier<FileListViewMode> viewMode;

  const FileListView({
    required this.usage,
    required this.quota,
    required this.currentPath,
    required this.selectedPool,
    required this.onPickAndUpload,
    required this.onShowCreateDirectory,
    required this.mode,
    required this.viewMode,
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
    final poolsAsync = ref.watch(poolsProvider);
    final isSelectionMode = useState<bool>(false);
    final selectedFileIds = useState<Set<String>>({});
    final currentVisibleItems = useState<List<FileListItem>>([]);
    final query = useState<String?>(null);
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

    late Widget pathContent;
    if (mode.value == FileListMode.unindexed) {
      pathContent = const Text(
        'Unindexed Files',
        style: TextStyle(fontWeight: FontWeight.bold),
      );
    } else if (currentPath.value == '/') {
      pathContent = const Text(
        'Root Directory',
        style: TextStyle(fontWeight: FontWeight.bold),
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
          child: const Text('Root'),
        ),
      );

      // Add path parts
      String currentPathBuilder = '';
      for (int i = 0; i < pathParts.length; i++) {
        currentPathBuilder += '/${pathParts[i]}';
        final path = currentPathBuilder;

        breadcrumbs.add(const Text(' / '));
        if (i == pathParts.length - 1) {
          // Current directory
          breadcrumbs.add(
            Text(
              pathParts[i],
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          );
        } else {
          // Clickable parent directory
          breadcrumbs.add(
            InkWell(
              onTap: () => currentPath.value = path,
              child: Text(pathParts[i]),
            ),
          );
        }
      }

      pathContent = Wrap(
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

          final completer = FileUploader.createCloudFile(
            fileData: universalFile,
            ref: ref,
            path: mode.value == FileListMode.normal ? currentPath.value : null,
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
                showSnackBar('Failed to upload file: $error');
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Gap(12),
            _buildGlobalFilters(
              ref,
              poolsAsync,
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
            const Gap(6),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        mode.value == FileListMode.unindexed
                            ? Symbols.inventory_2
                            : currentPath.value != '/'
                            ? Symbols.arrow_back
                            : Symbols.folder,
                      ),
                      onPressed: isRefreshing
                          ? null
                          : () {
                              if (mode.value == FileListMode.unindexed) {
                                mode.value = FileListMode.normal;
                                currentPath.value = '/';
                              } else {
                                final pathParts = currentPath.value
                                    .split('/')
                                    .where((part) => part.isNotEmpty)
                                    .toList();
                                if (pathParts.isNotEmpty) {
                                  pathParts.removeLast();
                                  currentPath.value = pathParts.isEmpty
                                      ? '/'
                                      : '/${pathParts.join('/')}';
                                }
                              }
                            },
                      visualDensity: const VisualDensity(
                        horizontal: -4,
                        vertical: -4,
                      ),
                    ),
                    const Gap(8),
                    Expanded(
                      child: AbsorbPointer(
                        absorbing: isRefreshing,
                        child: pathContent,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        viewMode.value == FileListViewMode.list
                            ? Symbols.view_module
                            : Symbols.list,
                      ),
                      onPressed: () => viewMode.value =
                          viewMode.value == FileListViewMode.list
                          ? FileListViewMode.waterfall
                          : FileListViewMode.list,
                      tooltip: viewMode.value == FileListViewMode.list
                          ? 'Switch to Waterfall View'
                          : 'Switch to List View',
                      visualDensity: const VisualDensity(
                        horizontal: -4,
                        vertical: -4,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        isSelectionMode.value
                            ? Symbols.close
                            : Symbols.select_check_box,
                      ),
                      onPressed: () =>
                          isSelectionMode.value = !isSelectionMode.value,
                      tooltip: isSelectionMode.value
                          ? 'Exit Selection Mode'
                          : 'Enter Selection Mode',
                      visualDensity: const VisualDensity(
                        horizontal: -4,
                        vertical: -4,
                      ),
                    ),
                    if (mode.value == FileListMode.normal)
                      IconButton(
                        icon: const Icon(Symbols.create_new_folder),
                        onPressed: () =>
                            onShowCreateDirectory(ref.context, currentPath),
                        tooltip: 'Create Directory',
                        visualDensity: const VisualDensity(
                          horizontal: -4,
                          vertical: -4,
                        ),
                      ),
                    if (mode.value == FileListMode.unindexed)
                      IconButton(
                        icon: Icon(
                          recycled.value
                              ? Symbols.delete_forever
                              : Symbols.restore_from_trash,
                        ),
                        onPressed: () {
                          recycled.value = !recycled.value;
                          unindexedNotifier.setRecycled(recycled.value);
                        },
                        tooltip: recycled.value
                            ? 'Show Active Files'
                            : 'Show Recycle Bin',
                        visualDensity: const VisualDensity(
                          horizontal: -4,
                          vertical: -4,
                        ),
                      ),
                    IconButton(
                      icon: const Icon(Symbols.upload_file),
                      onPressed: onPickAndUpload,
                      tooltip: 'Upload File',
                      visualDensity: const VisualDensity(
                        horizontal: -4,
                        vertical: -4,
                      ),
                    ),
                  ],
                ),
              ),
            ).padding(horizontal: 8),
            if (mode.value == FileListMode.unindexed && recycled.value)
              _buildClearRecycledButton(ref).padding(horizontal: 8),
            if (isRefreshing)
              const LinearProgressIndicator(
                minHeight: 4,
              ).padding(horizontal: 16, top: 6, bottom: 4),
            const Gap(8),
            if (mode.value == FileListMode.normal && currentPath.value == '/')
              _buildUnindexedFilesEntry(ref).padding(bottom: 12),
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
                        child: const Text('Cancel'),
                      ),
                      const Gap(12),
                      OutlinedButton(
                        onPressed: () {
                          final allIds = currentVisibleItems.value
                              .expand(
                                (item) => item.maybeMap(
                                  file: (f) => [f.fileIndex.id],
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
                              ? 'Select All'
                              : currentVisibleItems.value
                                    .expand(
                                      (item) => item.maybeMap(
                                        file: (f) => [f.fileIndex.id],
                                        unindexedFile: (u) => [u.file.id],
                                        orElse: () => <String>[],
                                      ),
                                    )
                                    .toSet()
                                    .difference(selectedFileIds.value)
                                    .isEmpty
                              ? 'Deselect All'
                              : 'Select All',
                        ),
                      ),
                      const Spacer(),
                      Text('${selectedFileIds.value.length} selected'),
                      const Spacer(),
                      ElevatedButton.icon(
                        icon: const Icon(Symbols.delete),
                        label: const Text('Delete'),
                        onPressed: selectedFileIds.value.isNotEmpty
                            ? () async {
                                final confirmed = await showConfirmAlert(
                                  'Are you sure you want to delete the selected files?',
                                  'Delete Selected Files',
                                  isDanger: true,
                                );
                                if (!confirmed) return;
                                if (context.mounted) {
                                  showLoadingModal(context);
                                }
                                try {
                                  final client = ref.read(apiClientProvider);
                                  final resp = await client.post(
                                    '/drive/files/batches/delete',
                                    data: {
                                      'file_ids': selectedFileIds.value
                                          .toList(),
                                    },
                                  );
                                  final count = resp.data['count'] as int;
                                  selectedFileIds.value.clear();
                                  isSelectionMode.value = false;
                                  ref.invalidate(
                                    mode.value == FileListMode.normal
                                        ? indexedCloudFileListProvider
                                        : unindexedFileListProvider,
                                  );
                                  showSnackBar('Deleted $count files.');
                                } catch (e) {
                                  showSnackBar(
                                    'Failed to delete selected files.',
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
    currentVisibleItems.value = items;
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
              selectedFileIds.value.contains(fileItem.fileIndex.id),
              () {
                if (selectedFileIds.value.contains(fileItem.fileIndex.id)) {
                  selectedFileIds.value = Set.from(selectedFileIds.value)
                    ..remove(fileItem.fileIndex.id);
                } else {
                  selectedFileIds.value = Set.from(selectedFileIds.value)
                    ..add(fileItem.fileIndex.id);
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
              selectedFileIds.value.contains(fileItem.fileIndex.id),
              () {
                if (selectedFileIds.value.contains(fileItem.fileIndex.id)) {
                  selectedFileIds.value = Set.from(selectedFileIds.value)
                    ..remove(fileItem.fileIndex.id);
                } else {
                  selectedFileIds.value = Set.from(selectedFileIds.value)
                    ..add(fileItem.fileIndex.id);
                }
              },
            ),
            folder: (folderItem) => ListTile(
              leading: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(8)),
                child: SizedBox(
                  height: 48,
                  width: 48,
                  child: const Icon(Symbols.folder, fill: 1).center(),
                ),
              ),
              title: Text(
                folderItem.folderName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: const Text('folder').tr(),
              onTap: () {
                final newPath = currentPath.value == '/'
                    ? '/${folderItem.folderName}'
                    : '${currentPath.value}/${folderItem.folderName}';
                currentPath.value = newPath;
              },
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

  Widget _buildUnindexedFilesEntry(WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(ref.context).colorScheme.outline),
        borderRadius: const BorderRadius.all(Radius.circular(8)),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 12),
      child: InkWell(
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              const Icon(Symbols.inventory_2).padding(horizontal: 8),
              const Gap(8),
              const Text('Unindexed Files').bold(),
              const Spacer(),
              const Icon(Symbols.chevron_right).padding(horizontal: 8),
            ],
          ),
        ),
        onTap: () {
          mode.value = FileListMode.unindexed;
          currentPath.value = '/';
        },
      ),
    );
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
              'This directory is empty',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(ref.context).textTheme.bodyLarge?.color,
              ),
            ),
            const Gap(8),
            Text(
              'Upload files or create subdirectories to populate this path.\n'
              'Directories are created implicitly when you upload files to them.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(
                  ref.context,
                ).textTheme.bodyMedium?.color?.withOpacity(0.7),
              ),
            ),
            const Gap(16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: onPickAndUpload,
                    icon: const Icon(Symbols.upload_file),
                    label: const Text('Upload Files'),
                  ),
                  const Gap(12),
                  OutlinedButton.icon(
                    onPressed: () =>
                        onShowCreateDirectory(ref.context, currentPath),
                    icon: const Icon(Symbols.create_new_folder),
                    label: const Text('Create Directory'),
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
      fileItem.fileIndex.file,
      () => '/files/${fileItem.fileIndex.id}',
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
              final client = ref.read(apiClientProvider);
              await client.delete(
                '/drive/index/remove/${fileItem.fileIndex.id}',
              );
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
    final meta = file.fileMeta is Map ? (file.fileMeta as Map) : const {};
    final ratio = meta['ratio'] is num
        ? (meta['ratio'] as num).toDouble()
        : 1.0;
    final itemType = file.mimeType?.split('/').first;
    final uri =
        '${ref.read(apiClientProvider).options.baseUrl}/drive/files/${file.id}';

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
                .read(apiClientProvider)
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
      case 'application' when file.mimeType == 'application/pdf':
        previewWidget = SfPdfViewer.network(
          uri,
          canShowScrollStatus: false,
          canShowScrollHead: false,
          enableDoubleTapZooming: false,
          pageSpacing: 0,
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
          context.push(getRoutePath(), extra: file);
        }
      },
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
                if (actions != null) ...actions,
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
            ? '/${folderItem.folderName}'
            : '${currentPath.value}/${folderItem.folderName}';
        currentPath.value = newPath;
      },
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
              folderItem.folderName,
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
    currentVisibleItems.value = items;
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
    final file = fileItem.fileIndex.file;
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
          context.push('/files/${fileItem.fileIndex.id}', extra: file);
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
            final client = ref.read(apiClientProvider);
            await client.delete('/drive/index/remove/${fileItem.fileIndex.id}');
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
          context.push('/files/${file.id}', extra: file);
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
            final client = ref.read(apiClientProvider);
            await client.delete('/drive/files/${file.id}');
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
              final client = ref.read(apiClientProvider);
              await client.delete('/drive/files/${unindexedFileItem.file.id}');
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
              'No unindexed files',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(ref.context).textTheme.bodyLarge?.color,
              ),
            ),
            const Gap(8),
            Text(
              'All files have been assigned to paths.\n'
              'Files without paths will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(
                  ref.context,
                ).textTheme.bodyMedium?.color?.withOpacity(0.7),
              ),
            ),
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
                  const Text('Clear All Recycled Files').bold(),
                  const Text(
                    'Permanently delete all marked recycled files to free up space.',
                  ).fontSize(13),
                ],
              ),
            ),
            ElevatedButton.icon(
              icon: const Icon(Symbols.delete_forever),
              label: const Text('Clear'),
              onPressed: () async {
                final confirmed = await showConfirmAlert(
                  'Are you sure you want to clear all recycled files?',
                  'Clear Recycled Files',
                );
                if (!confirmed) return;

                if (ref.context.mounted) {
                  showLoadingModal(ref.context);
                }
                try {
                  final client = ref.read(apiClientProvider);
                  final response = await client.delete(
                    '/drive/files/me/recycle',
                  );
                  final count = response.data['count'] as int? ?? 0;
                  showSnackBar('Cleared $count recycled files.');
                  ref.invalidate(unindexedFileListProvider);
                } catch (e) {
                  showSnackBar('Failed to clear recycled files.');
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

  Widget _buildGlobalFilters(
    WidgetRef ref,
    AsyncValue<List<SnFilePool>> poolsAsync,
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
    final poolDropdownItems = poolsAsync.when(
      data: (pools) => [
        const DropdownMenuItem<SnFilePool>(
          value: null,
          child: Text('All Pools', style: TextStyle(fontSize: 14)),
        ),
        ...pools.map(
          (p) => DropdownMenuItem<SnFilePool>(
            value: p,
            child: Text(p.name, style: const TextStyle(fontSize: 14)),
          ),
        ),
      ],
      loading: () => const <DropdownMenuItem<SnFilePool>>[],
      error: (err, stack) => const <DropdownMenuItem<SnFilePool>>[],
    );

    final poolDropdown = DropdownButtonHideUnderline(
      child: DropdownButton2<SnFilePool>(
        value: selectedPool.value,
        items: poolDropdownItems,
        onChanged: isRefreshing
            ? null
            : (value) {
                selectedPool.value = value;
                if (mode.value == FileListMode.unindexed) {
                  unindexedNotifier.setPool(value?.id);
                } else {
                  cloudNotifier.setPool(value?.id);
                }
              },
        customButton: Container(
          height: 28,
          width: 200,
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(ref.context).colorScheme.outline,
            ),
            borderRadius: const BorderRadius.all(Radius.circular(8)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            spacing: 6,
            children: [
              const Icon(Symbols.pool, size: 16),
              Flexible(
                child: Text(
                  selectedPool.value?.name ?? 'All files',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ).fontSize(12),
              ),
            ],
          ).height(24),
        ),
        buttonStyleData: const ButtonStyleData(
          padding: EdgeInsets.zero,
          height: 28,
          width: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
        ),
        dropdownStyleData: const DropdownStyleData(maxHeight: 200),
      ),
    );

    final queryField = SizedBox(
      width: 200,
      height: 28,
      child: TextField(
        decoration: InputDecoration(
          hintText: 'fileName'.tr(),
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 12,
            horizontal: 6,
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        style: const TextStyle(fontSize: 13, height: 1),
        onChanged: (value) {
          queryDebounceTimer.value?.cancel();
          queryDebounceTimer.value = Timer(
            const Duration(milliseconds: 300),
            () {
              query.value = value.isEmpty ? null : value;
            },
          );
        },
      ),
    );

    final orderDropdown = DropdownButtonHideUnderline(
      child: DropdownButton2<String>(
        value: order.value,
        items: ['date', 'size', 'name']
            .map(
              (e) => DropdownMenuItem(
                value: e,
                child: Text(
                  e == 'date' ? e : 'file${e.capitalizeEachWord()}',
                  style: const TextStyle(fontSize: 14),
                ).tr(),
              ),
            )
            .toList(),
        onChanged: (value) => order.value = value,
        customButton: Container(
          height: 28,
          width: 80,
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(ref.context).colorScheme.outline,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              (order.value ?? 'date') == 'date'
                  ? (order.value ?? 'date')
                  : 'file${order.value?.capitalizeEachWord()}',
              style: const TextStyle(fontSize: 12),
            ).tr(),
          ),
        ),
        buttonStyleData: const ButtonStyleData(
          height: 28,
          width: 80,
          padding: EdgeInsets.zero,
        ),
        dropdownStyleData: const DropdownStyleData(maxHeight: 200),
      ),
    );

    final orderDescToggle = IconButton(
      icon: Icon(
        orderDesc.value ? Symbols.arrow_upward : Symbols.arrow_downward,
      ),
      onPressed: () {
        final newValue = !orderDesc.value;
        orderDesc.value = newValue;
        if (mode.value == FileListMode.unindexed) {
          unindexedNotifier.setOrderDesc(newValue);
        } else {
          cloudNotifier.setOrderDesc(newValue);
        }
      },
      tooltip: orderDesc.value ? 'descendingOrder'.tr() : 'ascendingOrder'.tr(),
      visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
    );

    final refreshButton = IconButton(
      icon: const Icon(Symbols.refresh),
      onPressed: () {
        if (mode.value == FileListMode.unindexed) {
          ref.invalidate(unindexedFileListProvider);
        } else {
          cloudNotifier.setPath(currentPath.value);
        }
      },
      tooltip: 'Refresh',
      visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
    );

    return Card(
      margin: EdgeInsets.zero,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          spacing: 12,
          children: [
            poolDropdown,
            queryField,
            orderDropdown,
            orderDescToggle,
            refreshButton,
          ],
        ).padding(horizontal: 20, vertical: 8),
      ),
    ).padding(horizontal: 12);
  }
}
