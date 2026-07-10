import 'dart:async';
import 'dart:io';

import 'package:desktop_drop/desktop_drop.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/config.dart';
import 'package:island/core/utils/share_utils.dart';
import 'package:share_plus/share_plus.dart';
import 'package:island/core/widgets/content/cloud_file_actions_sheet.dart';
import 'package:island/core/widgets/content/file_info_sheet.dart';
import 'package:island/drive/screens/file_list.dart';
import 'package:island/core/network.dart';
import 'package:island/drive/drive_service.dart';
import 'package:island/core/services/responsive.dart';
import 'package:island/core/utils/file_icon_utils.dart';
import 'package:island/core/utils/format.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/shared/widgets/layouts/sheet_scaffold.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:island/shared/widgets/pagination_list.dart';
import 'package:island/shared/widgets/content/image.dart';
import 'package:island/core/services/time.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:super_context_menu/super_context_menu.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

enum FileListMode { normal, unindexed }

enum FileListViewMode { list, waterfall }

class FileListView extends HookConsumerWidget {
  final String tabId;
  final Map<String, dynamic>? usage;
  final Map<String, dynamic>? quota;
  final ValueNotifier<String> currentPath;
  final ValueNotifier<SnFilePool?> selectedPool;
  final VoidCallback onPickAndUpload;
  final VoidCallback onShowCreateFolder;
  final void Function(String path) onOpenFolderInNewTab;
  final void Function(SnCloudFile file) onInspectFile;
  final void Function(SnCloudFile file) onOpenFile;
  final ValueNotifier<Set<String>>? selectedFileIds;
  final ValueNotifier<Set<String>>? currentVisibleFileIds;
  final ValueNotifier<FileListMode> mode;
  final ValueNotifier<FileListViewMode> viewMode;
  final ValueNotifier<bool> isSelectionMode;
  final ValueNotifier<String?> query;
  final Future<void> Function(List<XFile> files)? onDropFiles;

  const FileListView({
    required this.tabId,
    required this.usage,
    required this.quota,
    required this.currentPath,
    required this.selectedPool,
    required this.onPickAndUpload,
    required this.onShowCreateFolder,
    required this.onOpenFolderInNewTab,
    required this.onInspectFile,
    required this.onOpenFile,
    required this.selectedFileIds,
    required this.currentVisibleFileIds,
    required this.mode,
    required this.viewMode,
    required this.isSelectionMode,
    required this.query,
    required this.onDropFiles,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dragging = useState(false);
    final currentPathValue = useValueListenable(currentPath);
    final modeValue = useValueListenable(mode);
    final viewModeValue = useValueListenable(viewMode);
    final queryValue = useValueListenable(query);

    useEffect(() {
      if (modeValue == FileListMode.normal) {
        final notifier = ref.read(
          indexedCloudFileListFamilyProvider(tabId).notifier,
        );
        notifier.setPath(currentPathValue);
      }
      return null;
    }, [currentPathValue, modeValue]);

    if (usage == null) return const SizedBox.shrink();

    final recycled = useState<bool>(false);
    final localSelectedFileIds = useState<Set<String>>({});
    final currentVisibleItems = useState<List<FileListItem>>([]);
    final expandedFileIds = useState<Set<String>>({});
    final treeChildrenCache = useState<Map<String, List<SnCloudFile>>>({});
    final loadingTreeChildren = useState<Set<String>>({});
    final order = useState<String?>('date');
    final orderDesc = useState<bool>(true);
    final queryDebounceTimer = useRef<Timer?>(null);
    final selectedIdsNotifier = selectedFileIds ?? localSelectedFileIds;

    void syncLoadedChildrenSelection(
      ValueNotifier<Set<String>> ids,
      SnCloudFile parent,
      List<SnCloudFile> children,
    ) {
      if (!ids.value.contains(parent.id) || children.isEmpty) return;

      final next = Set<String>.from(ids.value);
      void addDescendants(Iterable<SnCloudFile> files) {
        for (final child in files) {
          next.add(child.id);
          final nestedChildren =
              treeChildrenCache.value[child.id] ?? child.children;
          if (nestedChildren.isNotEmpty) {
            addDescendants(nestedChildren);
          }
        }
      }

      addDescendants(children);
      if (next.length != ids.value.length) {
        ids.value = next;
      }
    }

    void toggleSelectionWithLoadedChildren(
      ValueNotifier<Set<String>> ids,
      SnCloudFile file,
    ) {
      final next = Set<String>.from(ids.value);
      final shouldSelect = !next.contains(file.id);

      void updateDescendants(Iterable<SnCloudFile> files) {
        for (final child in files) {
          if (shouldSelect) {
            next.add(child.id);
          } else {
            next.remove(child.id);
          }
          final nestedChildren =
              treeChildrenCache.value[child.id] ?? child.children;
          if (nestedChildren.isNotEmpty) {
            updateDescendants(nestedChildren);
          }
        }
      }

      if (shouldSelect) {
        next.add(file.id);
      } else {
        next.remove(file.id);
      }

      updateDescendants(treeChildrenCache.value[file.id] ?? file.children);
      ids.value = next;
    }

    Future<void> ensureTreeChildrenLoaded(SnCloudFile file) async {
      if (file.isFolder || file.childrenCount <= 0) return;
      if (treeChildrenCache.value.containsKey(file.id)) return;
      if (loadingTreeChildren.value.contains(file.id)) return;
      if (file.children.isNotEmpty) {
        treeChildrenCache.value = {
          ...treeChildrenCache.value,
          file.id: file.children,
        };
        return;
      }

      loadingTreeChildren.value = Set<String>.from(loadingTreeChildren.value)
        ..add(file.id);
      try {
        final driveApi = ref.read(solarNetworkClientProvider).drive;
        final result = await driveApi.listFolderChildren(
          file.id,
          poolId: selectedPool.value?.id,
        );
        if (result.items.isNotEmpty) {
          treeChildrenCache.value = {
            ...treeChildrenCache.value,
            file.id: result.items,
          };
          syncLoadedChildrenSelection(selectedIdsNotifier, file, result.items);
          if (currentVisibleFileIds != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              currentVisibleFileIds!.value = {
                ...currentVisibleFileIds!.value,
                ...result.items.map((item) => item.id),
              };
            });
          }
        }
      } catch (_) {
        // Keep the node visible even if hydration fails.
      } finally {
        loadingTreeChildren.value = Set<String>.from(loadingTreeChildren.value)
          ..remove(file.id);
      }
    }

    useEffect(() {
      if (modeValue == FileListMode.unindexed) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          isSelectionMode.value = false;
          selectedIdsNotifier.value = <String>{};
        });
      }
      return null;
    }, [modeValue]);

    useEffect(() {
      // Sync pool when mode or selectedPool changes
      if (modeValue == FileListMode.unindexed) {
        ref
            .read(unindexedFileListFamilyProvider(tabId).notifier)
            .setPool(selectedPool.value?.id);
      } else {
        ref
            .read(indexedCloudFileListFamilyProvider(tabId).notifier)
            .setPool(selectedPool.value?.id);
      }
      return null;
    }, [selectedPool.value, modeValue]);

    useEffect(() {
      // Sync query, order, and orderDesc filters
      if (modeValue == FileListMode.unindexed) {
        final notifier = ref.read(
          unindexedFileListFamilyProvider(tabId).notifier,
        );
        notifier.setQuery(queryValue);
        notifier.setOrder(order.value);
        notifier.setOrderDesc(orderDesc.value);
      } else {
        final notifier = ref.read(
          indexedCloudFileListFamilyProvider(tabId).notifier,
        );
        notifier.setQuery(queryValue);
        notifier.setOrder(order.value);
        notifier.setOrderDesc(orderDesc.value);
      }
      return null;
    }, [queryValue, order.value, orderDesc.value, modeValue]);

    final indexedListState = ref.watch(
      indexedCloudFileListFamilyProvider(tabId),
    );
    final unindexedListState = ref.watch(
      unindexedFileListFamilyProvider(tabId),
    );
    final isRefreshing = modeValue == FileListMode.normal
        ? (indexedListState.isLoading || indexedListState.isReloading)
        : (unindexedListState.isLoading || unindexedListState.isReloading);

    final bodyWidget = switch (modeValue) {
      FileListMode.unindexed => PaginationWidget(
        provider: unindexedFileListFamilyProvider(tabId),
        notifier: unindexedFileListFamilyProvider(tabId).notifier,
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
                selectedIdsNotifier,
                expandedFileIds,
                treeChildrenCache.value,
                loadingTreeChildren.value,
                ensureTreeChildrenLoaded,
                currentVisibleItems,
                footer,
                toggleSelectionWithLoadedChildren,
              ),
      ),
      _ => PaginationWidget(
        provider: indexedCloudFileListFamilyProvider(tabId),
        notifier: indexedCloudFileListFamilyProvider(tabId).notifier,
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
                selectedIdsNotifier,
                expandedFileIds,
                treeChildrenCache.value,
                loadingTreeChildren.value,
                ensureTreeChildrenLoaded,
                currentVisibleItems,
                footer,
                toggleSelectionWithLoadedChildren,
              ),
      ),
    };

    late Widget pathWidget;
    if (modeValue == FileListMode.unindexed) {
      pathWidget = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Symbols.inventory_2, size: 20),
          const Gap(8),
          Text(
            'unindexedFiles',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ).tr(),
        ],
      );
    } else if (currentPathValue == '/') {
      pathWidget = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Symbols.folder, size: 20),
          const Gap(8),
          Text(
            'rootDirectory',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ).tr(),
        ],
      );
    } else {
      final pathParts = currentPathValue
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
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
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
        if (details.files.isNotEmpty) {
          await onDropFiles?.call(details.files);
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
                    selected: {viewModeValue},
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
              query,
              order,
              orderDesc,
              queryDebounceTimer,
            ),
            const Gap(8),

            if (modeValue == FileListMode.unindexed && recycled.value)
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
                    horizontal: viewModeValue == FileListViewMode.waterfall
                        ? 20
                        : null,
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
    ValueNotifier<Set<String>> expandedFileIds,
    Map<String, List<SnCloudFile>> treeChildrenCache,
    Set<String> loadingTreeChildren,
    Future<void> Function(SnCloudFile file) ensureTreeChildrenLoaded,
    ValueNotifier<List<FileListItem>> currentVisibleItems,
    Widget footer,
    void Function(ValueNotifier<Set<String>> ids, SnCloudFile file)
    toggleSelection,
  ) {
    if (currentVisibleItems.value != items) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        currentVisibleItems.value = items;
        currentVisibleFileIds?.value = items
            .expand(
              (item) => item.maybeMap(
                file: (fileItem) => [fileItem.file.id],
                unindexedFile: (fileItem) => [fileItem.file.id],
                orElse: () => <String>[],
              ),
            )
            .toSet();
      });
    }
    final showTreeExpansionAffordance = items.any(
      (item) => item.maybeMap(
        file: (fileItem) => fileItem.file.childrenCount > 0,
        orElse: () => false,
      ),
    );
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
                toggleSelection(selectedFileIds, fileItem.file);
              },
            ),
            folder: (folderItem) => _buildWaterfallFolderTile(
              folderItem,
              ref,
              currentPath,
              context,
            ),
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
              selectedFileIds,
              expandedFileIds,
              treeChildrenCache,
              loadingTreeChildren,
              ensureTreeChildrenLoaded,
              showTreeExpansionAffordance,
              toggleSelection,
            ),
            folder: (folderItem) {
              final theme = Theme.of(context);
              return ContextMenuWidget(
                previewBuilder: contextMenuPreviewBuilder,
                menuProvider: (_) =>
                    _buildFolderMenu(context, ref, folderItem.file),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    final newPath = currentPath.value == '/'
                        ? '/${folderItem.file.name}'
                        : '${currentPath.value}/${folderItem.file.name}';
                    if (HardwareKeyboard.instance.isShiftPressed) {
                      onOpenFolderInNewTab(newPath);
                    } else {
                      currentPath.value = newPath;
                    }
                  },
                  child: ListTile(
                    dense: true,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 4,
                    ),
                    leading: SizedBox(
                      width: 40,
                      height: 40,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer.withOpacity(
                            0.5,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Symbols.folder,
                          fill: 1,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                    title: Text(
                      folderItem.file.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    subtitle: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Symbols.folder, size: 12),
                        const Gap(4),
                        Text(
                          'folder'.tr(),
                          style: theme.textTheme.bodySmall?.copyWith(height: 1),
                        ),
                        const Gap(8),
                        const Icon(Symbols.folder_copy, size: 12),
                        const Gap(4),
                        Text(
                          folderItem.file.childrenCount.toString(),
                          style: theme.textTheme.bodySmall?.copyWith(height: 1),
                        ),
                      ],
                    ).opacity(0.85).padding(top: 2, bottom: 4),
                    trailing: _buildFolderActions(
                      context,
                      ref,
                      folderItem.file,
                    ),
                  ),
                ),
              );
            },
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
    return ContextMenuWidget(
      previewBuilder: contextMenuPreviewBuilder,
      menuProvider: (_) {
        return Menu(
          children: [
            MenuAction(
              title: 'Inspect',
              image: MenuImage.icon(Symbols.info),
              callback: () => onInspectFile(fileItem.file),
            ),
            MenuSeparator(),
            MenuAction(
              title: 'rename'.tr(),
              image: MenuImage.icon(Symbols.edit),
              callback: () async {
                await CloudFileActionsSheet.showRenameSheet(
                  context: context,
                  file: fileItem.file,
                  onRenamed: (_) {
                    ref.invalidate(indexedCloudFileListFamilyProvider(tabId));
                  },
                );
              },
            ),
            MenuAction(
              title: 'moveToFolder'.tr(),
              image: MenuImage.icon(Symbols.drive_file_move),
              callback: () async {
                await _showMoveToFolderSheet(
                  context: ref.context,
                  ref: ref,
                  fileId: fileItem.file.id,
                  fileName: fileItem.file.name,
                  isUnindexed: false,
                );
              },
            ),
            MenuAction(
              title: 'share'.tr(),
              image: MenuImage.icon(Symbols.share),
              callback: () async {
                final url = fileItem.file.storageUrl ?? fileItem.file.id;
                await Share.share(url);
              },
            ),
            MenuAction(
              title: 'copyLink'.tr(),
              image: MenuImage.icon(Symbols.content_copy),
              callback: () {
                Clipboard.setData(
                  ClipboardData(
                    text: fileItem.file.storageUrl ?? fileItem.file.id,
                  ),
                );
                showSnackBar('linkCopied'.tr());
              },
            ),
            MenuAction(
              title: 'fileInfoTitle'.tr(),
              image: MenuImage.icon(Symbols.info),
              callback: () {
                showModalBottomSheet(
                  useRootNavigator: true,
                  context: context,
                  isScrollControlled: true,
                  builder: (context) => FileInfoSheet(item: fileItem.file),
                );
              },
            ),
            MenuSeparator(),
            MenuAction(
              title: 'delete'.tr(),
              image: MenuImage.icon(Symbols.delete),
              callback: () async {
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
                  await ref
                      .read(driveFileUploaderProvider)
                      .deleteFile(fileItem.file.id);
                  ref.invalidate(indexedCloudFileListFamilyProvider(tabId));
                } catch (e) {
                  showSnackBar('failedToDeleteFile'.tr());
                } finally {
                  if (context.mounted) {
                    hideLoadingModal(context);
                  }
                }
              },
            ),
            MenuSeparator(),
            MenuAction(
              title: 'more'.tr(),
              image: MenuImage.icon(Symbols.menu_open),
              callback: () async {
                await CloudFileActionsSheet.show(
                  context: context,
                  item: fileItem.file,
                  onRenamed: (_) {
                    ref.invalidate(indexedCloudFileListFamilyProvider(tabId));
                  },
                );
              },
            ),
          ],
        );
      },
      child: _buildWaterfallFileTileBase(
        fileItem.file,
        ref,
        context,
        _buildIndexedFileActions(fileItem.file, ref, context),
        isSelectionMode,
        isSelected,
        toggleSelection,
        onOpen: () => onOpenFile(fileItem.file),
      ),
    );
  }

  Future<void> _renameFolder(
    BuildContext context,
    WidgetRef ref,
    SnCloudFile folder,
  ) async {
    await CloudFileActionsSheet.showRenameSheet(
      context: context,
      file: folder,
      onRenamed: (_) {
        ref.invalidate(indexedCloudFileListFamilyProvider(tabId));
      },
    );
  }

  Future<void> _deleteFolder(
    BuildContext context,
    WidgetRef ref,
    SnCloudFile folder,
  ) async {
    final confirmed = await showConfirmAlert(
      'confirmDeleteFile'.tr(),
      'delete'.tr(),
      isDanger: true,
    );
    if (!confirmed || !context.mounted) return;

    showLoadingModal(context);
    try {
      await ref.read(driveFileUploaderProvider).deleteFile(folder.id);
      ref.invalidate(indexedCloudFileListFamilyProvider(tabId));
    } catch (_) {
      showSnackBar('failedToDeleteFile'.tr());
    } finally {
      if (context.mounted) {
        hideLoadingModal(context);
      }
    }
  }

  Future<void> _handleFolderAction(
    BuildContext context,
    WidgetRef ref,
    SnCloudFile folder,
    String action,
  ) async {
    switch (action) {
      case 'inspect':
        onInspectFile(folder);
        break;
      case 'rename':
        await _renameFolder(context, ref, folder);
        break;
      case 'move':
        await _showMoveToFolderSheet(
          context: context,
          ref: ref,
          fileId: folder.id,
          fileName: folder.name,
          isUnindexed: false,
        );
        break;
      case 'delete':
        await _deleteFolder(context, ref, folder);
        break;
    }
  }

  Menu _buildFolderMenu(
    BuildContext context,
    WidgetRef ref,
    SnCloudFile folder,
  ) {
    return Menu(
      children: [
        MenuAction(
          title: 'Inspect',
          image: MenuImage.icon(Symbols.info),
          callback: () => _handleFolderAction(context, ref, folder, 'inspect'),
        ),
        MenuSeparator(),
        MenuAction(
          title: 'rename'.tr(),
          image: MenuImage.icon(Symbols.edit),
          callback: () => _handleFolderAction(context, ref, folder, 'rename'),
        ),
        MenuAction(
          title: 'moveToFolder'.tr(),
          image: MenuImage.icon(Symbols.drive_file_move),
          callback: () => _handleFolderAction(context, ref, folder, 'move'),
        ),
        MenuSeparator(),
        MenuAction(
          title: 'delete'.tr(),
          image: MenuImage.icon(Symbols.delete),
          callback: () => _handleFolderAction(context, ref, folder, 'delete'),
        ),
      ],
    );
  }

  Widget _buildFolderActions(
    BuildContext context,
    WidgetRef ref,
    SnCloudFile folder,
  ) {
    return PopupMenuButton<String>(
      tooltip: 'more'.tr(),
      onSelected: (value) => _handleFolderAction(context, ref, folder, value),
      itemBuilder: (context) => [
        PopupMenuItem<String>(
          value: 'inspect',
          child: Row(
            children: [
              const Icon(Symbols.info),
              const Gap(12),
              Text('Inspect'),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'rename',
          child: Row(
            children: [
              const Icon(Symbols.edit),
              const Gap(12),
              Text('rename').tr(),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'move',
          child: Row(
            children: [
              const Icon(Symbols.drive_file_move),
              const Gap(12),
              Text('moveToFolder').tr(),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'delete',
          child: Row(
            children: [
              const Icon(Symbols.delete),
              const Gap(12),
              Text('delete').tr(),
            ],
          ),
        ),
      ],
      child: const Padding(
        padding: EdgeInsets.all(8),
        child: Icon(Symbols.more_vert),
      ),
    );
  }

  List<Widget> _buildIndexedFileActions(
    SnCloudFile file,
    WidgetRef ref,
    BuildContext context,
  ) {
    final isMobile = !kIsWeb && (Platform.isAndroid || Platform.isIOS);

    void handleAction(String action) {
      switch (action) {
        case 'inspect':
          onInspectFile(file);
          break;
        case 'download':
          ref
              .read(driveFileDownloaderProvider)
              .downloadFile(
                file,
                useDownloadsFolder: HardwareKeyboard.instance.isShiftPressed,
              );
          break;
        case 'rename':
          CloudFileActionsSheet.showRenameSheet(
            context: context,
            file: file,
            onRenamed: (_) {
              ref.invalidate(indexedCloudFileListFamilyProvider(tabId));
            },
          );
          break;
        case 'moveToFolder':
          _showMoveToFolderSheet(
            context: context,
            ref: ref,
            fileId: file.id,
            fileName: file.name,
            isUnindexed: false,
          );
          break;
        case 'share':
          final url = file.storageUrl ?? file.id;
          Share.share(url);
          break;
        case 'copyLink':
          Clipboard.setData(ClipboardData(text: file.storageUrl ?? file.id));
          showSnackBar('linkCopied'.tr());
          break;
        case 'fileInfo':
          showModalBottomSheet(
            useRootNavigator: true,
            context: context,
            isScrollControlled: true,
            builder: (context) => FileInfoSheet(item: file),
          );
          break;
        case 'delete':
          showConfirmAlert(
            'confirmDeleteFile'.tr(),
            'deleteFile'.tr(),
            isDanger: true,
          ).then((confirmed) async {
            if (!confirmed) return;

            if (context.mounted) {
              showLoadingModal(context);
            }
            try {
              await ref.read(driveFileUploaderProvider).deleteFile(file.id);
              ref.invalidate(indexedCloudFileListFamilyProvider(tabId));
            } catch (e) {
              showSnackBar('failedToDeleteFile'.tr());
            } finally {
              if (context.mounted) {
                hideLoadingModal(context);
              }
            }
          });
          break;
        case 'more':
          CloudFileActionsSheet.show(
            context: context,
            item: file,
            onRenamed: (_) {
              ref.invalidate(indexedCloudFileListFamilyProvider(tabId));
            },
          );
          break;
      }
    }

    return [
      IconButton(
        tooltip: 'download'.tr(),
        icon: const Icon(Symbols.download),
        onPressed: () => handleAction('download'),
      ),
      if (isMobile)
        IconButton(
          tooltip: 'more'.tr(),
          icon: const Icon(Symbols.more_vert),
          onPressed: () {
            showModalBottomSheet(
              context: context,
              useRootNavigator: true,
              builder: (context) => FileActionSheet(
                file: file,
                isUnindexed: false,
                onAction: (action) {
                  Navigator.pop(context);
                  handleAction(action);
                },
              ),
            );
          },
        ),
    ];
  }

  Widget _buildWaterfallFileTileBase(
    SnCloudFile file,
    WidgetRef ref,
    BuildContext context,
    List<Widget>? actions,
    bool isSelectionMode,
    bool isSelected,
    VoidCallback? toggleSelection, {
    required VoidCallback onOpen,
  }) {
    final ratio = file.ratio ?? 1.0;
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
          onOpen();
        }
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: isSelectionMode && isSelected
              ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5)
              : null,
          border: Border.all(
            color: isSelectionMode && isSelected
                ? Theme.of(context).colorScheme.primary.withOpacity(0.45)
                : Theme.of(context).colorScheme.outline.withOpacity(0.3),
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
    WidgetRef ref,
    ValueNotifier<String> currentPath,
    BuildContext context,
  ) {
    return ContextMenuWidget(
      previewBuilder: contextMenuPreviewBuilder,
      menuProvider: (_) => _buildFolderMenu(context, ref, folderItem.file),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {
          final newPath = currentPath.value == '/'
              ? '/${folderItem.file.name}'
              : '${currentPath.value}/${folderItem.file.name}';
          if (HardwareKeyboard.instance.isShiftPressed) {
            onOpenFolderInNewTab(newPath);
          } else {
            currentPath.value = newPath;
          }
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
              Expanded(
                child: Text(
                  folderItem.file.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
                ),
              ),
              _buildFolderActions(context, ref, folderItem.file),
            ],
          ),
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
    ValueNotifier<Set<String>> expandedFileIds,
    Map<String, List<SnCloudFile>> treeChildrenCache,
    Set<String> loadingTreeChildren,
    Future<void> Function(SnCloudFile file) ensureTreeChildrenLoaded,
    ValueNotifier<List<FileListItem>> currentVisibleItems,
    Widget footer,
    void Function(ValueNotifier<Set<String>> ids, SnCloudFile file)
    toggleSelection,
  ) {
    if (currentVisibleItems.value != items) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        currentVisibleItems.value = items;
        currentVisibleFileIds?.value = items
            .expand(
              (item) => item.maybeMap(
                file: (fileItem) => [fileItem.file.id],
                unindexedFile: (fileItem) => [fileItem.file.id],
                orElse: () => <String>[],
              ),
            )
            .toSet();
      });
    }
    final showTreeExpansionAffordance = items.any(
      (item) => item.maybeMap(
        unindexedFile: (fileItem) => fileItem.file.childrenCount > 0,
        orElse: () => false,
      ),
    );
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
                    toggleSelection(selectedFileIds, unindexedFileItem.file);
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
              selectedFileIds,
              expandedFileIds,
              treeChildrenCache,
              loadingTreeChildren,
              ensureTreeChildrenLoaded,
              showTreeExpansionAffordance,
              toggleSelection,
            ),
          );
        },
      ),
    };
  }

  void _toggleId(ValueNotifier<Set<String>> ids, String id) {
    final next = Set<String>.from(ids.value);
    if (next.contains(id)) {
      next.remove(id);
    } else {
      next.add(id);
    }
    ids.value = next;
  }

  Widget _buildTreeFileTile({
    required SnCloudFile file,
    required WidgetRef ref,
    required BuildContext context,
    required bool isSelectionMode,
    required ValueNotifier<Set<String>> selectedFileIds,
    required ValueNotifier<Set<String>> expandedFileIds,
    required Map<String, List<SnCloudFile>> treeChildrenCache,
    required Set<String> loadingTreeChildren,
    required Future<void> Function(SnCloudFile file) ensureTreeChildrenLoaded,
    required int depth,
    required VoidCallback onOpen,
    required bool showTreeExpansionAffordance,
    required void Function(ValueNotifier<Set<String>> ids, SnCloudFile file)
    toggleSelection,
    bool isUnindexed = false,
  }) {
    final theme = Theme.of(context);
    final isSelected = selectedFileIds.value.contains(file.id);
    final children = treeChildrenCache[file.id] ?? file.children;
    final hasTreeChildren =
        !file.isFolder && (file.childrenCount > 0 || children.isNotEmpty);
    final isExpanded = expandedFileIds.value.contains(file.id);
    final isLoadingChildren = loadingTreeChildren.contains(file.id);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ContextMenuWidget(
          previewBuilder: contextMenuPreviewBuilder,
          menuProvider: (_) {
            return Menu(
              children: [
                MenuAction(
                  title: 'Inspect',
                  image: MenuImage.icon(Symbols.info),
                  callback: () => onInspectFile(file),
                ),
                if (!file.isFolder) ...[
                  MenuSeparator(),
                  if (!isUnindexed)
                    MenuAction(
                      title: 'rename'.tr(),
                      image: MenuImage.icon(Symbols.edit),
                      callback: () async {
                        await CloudFileActionsSheet.showRenameSheet(
                          context: context,
                          file: file,
                          onRenamed: (_) {
                            ref.invalidate(
                              indexedCloudFileListFamilyProvider(tabId),
                            );
                          },
                        );
                      },
                    ),
                  MenuAction(
                    title: 'moveToFolder'.tr(),
                    image: MenuImage.icon(Symbols.drive_file_move),
                    callback: () async {
                      await _showMoveToFolderSheet(
                        context: ref.context,
                        ref: ref,
                        fileId: file.id,
                        fileName: file.name,
                        isUnindexed: isUnindexed,
                      );
                    },
                  ),
                  if (!isUnindexed) ...[
                    MenuAction(
                      title: 'share'.tr(),
                      image: MenuImage.icon(Symbols.share),
                      callback: () async {
                        final url = file.storageUrl ?? file.id;
                        await Share.share(url);
                      },
                    ),
                    MenuAction(
                      title: 'copyLink'.tr(),
                      image: MenuImage.icon(Symbols.content_copy),
                      callback: () {
                        Clipboard.setData(
                          ClipboardData(text: file.storageUrl ?? file.id),
                        );
                        showSnackBar('linkCopied'.tr());
                      },
                    ),
                    MenuAction(
                      title: 'fileInfoTitle'.tr(),
                      image: MenuImage.icon(Symbols.info),
                      callback: () {
                        showModalBottomSheet(
                          useRootNavigator: true,
                          context: context,
                          isScrollControlled: true,
                          builder: (context) => FileInfoSheet(item: file),
                        );
                      },
                    ),
                  ],
                  MenuSeparator(),
                  MenuAction(
                    title: 'delete'.tr(),
                    image: MenuImage.icon(Symbols.delete),
                    callback: () async {
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
                        await ref
                            .read(driveFileUploaderProvider)
                            .deleteFile(file.id);
                        ref.invalidate(
                          isUnindexed
                              ? unindexedFileListFamilyProvider(tabId)
                              : indexedCloudFileListFamilyProvider(tabId),
                        );
                      } catch (e) {
                        showSnackBar('failedToDeleteFile'.tr());
                      } finally {
                        if (context.mounted) {
                          hideLoadingModal(context);
                        }
                      }
                    },
                  ),
                  if (!isUnindexed) ...[
                    MenuSeparator(),
                    MenuAction(
                      title: 'more'.tr(),
                      image: MenuImage.icon(Symbols.menu_open),
                      callback: () async {
                        await CloudFileActionsSheet.show(
                          context: context,
                          item: file,
                          onRenamed: (_) {
                            ref.invalidate(
                              indexedCloudFileListFamilyProvider(tabId),
                            );
                          },
                        );
                      },
                    ),
                  ],
                ],
              ],
            );
          },
          child: InkWell(
            onTap: () {
              if (isSelectionMode) {
                toggleSelection(selectedFileIds, file);
              } else {
                onOpen();
              }
            },
            child: Padding(
              padding: EdgeInsets.only(left: depth * 18.0),
              child: ListTile(
                dense: true,
                tileColor: isSelectionMode && isSelected
                    ? theme.colorScheme.primaryContainer.withOpacity(0.5)
                    : null,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: isSelectionMode && isSelected
                        ? theme.colorScheme.primary.withOpacity(0.45)
                        : Colors.transparent,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 4,
                ),
                leading: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (hasTreeChildren)
                      SizedBox(
                        width: 32,
                        height: 32,
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints.tightFor(
                            width: 32,
                            height: 32,
                          ),
                          visualDensity: VisualDensity.compact,
                          iconSize: 18,
                          icon: Icon(
                            isExpanded
                                ? Symbols.expand_more
                                : Symbols.chevron_right,
                          ),
                          onPressed: () async {
                            if (!isExpanded) {
                              await ensureTreeChildrenLoaded(file);
                            }
                            _toggleId(expandedFileIds, file.id);
                          },
                        ),
                      ).padding(right: 4),
                    if (!hasTreeChildren && showTreeExpansionAffordance)
                      const SizedBox(width: 32 + 4, height: 32),
                    SizedBox(
                      width: 40,
                      height: 40,
                      child: _FileListLeadingPreview(file: file),
                    ),
                  ],
                ),
                title: file.name.isEmpty
                    ? Text('untitled').tr().italic()
                    : Text(
                        file.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                subtitle: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Symbols.insert_drive_file, size: 12),
                    const Gap(4),
                    Text(
                      formatFileSize(file.size),
                      style: theme.textTheme.bodySmall?.copyWith(height: 1),
                    ),
                    const Gap(8),
                    const Icon(Symbols.calendar_today, size: 12),
                    const Gap(4),
                    Flexible(
                      child: Text(
                        file.createdAt.formatSystem(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(height: 1),
                      ),
                    ),
                    if (file.usage != null) ...[
                      const Gap(8),
                      const Icon(Symbols.category, size: 12),
                      const Gap(4),
                      Flexible(
                        child: Text(
                          file.usage!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(height: 1),
                        ),
                      ),
                    ],
                    if (file.applicationType != null) ...[
                      const Gap(8),
                      const Icon(Symbols.shape_line, size: 12),
                      const Gap(4),
                      Flexible(
                        child: Text(
                          file.applicationType!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(height: 1),
                        ),
                      ),
                    ],
                  ],
                ).opacity(0.85).padding(top: 2, bottom: 4),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: _buildIndexedFileActions(file, ref, context),
                ),
              ),
            ),
          ),
        ),
        if (hasTreeChildren && isExpanded)
          if (isLoadingChildren && children.isEmpty)
            Padding(
              padding: EdgeInsets.only(left: depth * 18.0 + 46),
              child: const LinearProgressIndicator(minHeight: 2),
            )
          else
            ...children.map(
              (child) => _buildTreeFileTile(
                file: child,
                ref: ref,
                context: context,
                isSelectionMode: isSelectionMode,
                selectedFileIds: selectedFileIds,
                expandedFileIds: expandedFileIds,
                treeChildrenCache: treeChildrenCache,
                loadingTreeChildren: loadingTreeChildren,
                ensureTreeChildrenLoaded: ensureTreeChildrenLoaded,
                depth: depth + 1,
                onOpen: onOpen,
                showTreeExpansionAffordance: showTreeExpansionAffordance,
                toggleSelection: toggleSelection,
                isUnindexed: isUnindexed,
              ),
            ),
      ],
    );
  }

  Widget _buildIndexedListTile(
    FileItem fileItem,
    WidgetRef ref,
    BuildContext context,
    bool isSelectionMode,
    ValueNotifier<Set<String>> selectedFileIds,
    ValueNotifier<Set<String>> expandedFileIds,
    Map<String, List<SnCloudFile>> treeChildrenCache,
    Set<String> loadingTreeChildren,
    Future<void> Function(SnCloudFile file) ensureTreeChildrenLoaded,
    bool showTreeExpansionAffordance,
    void Function(ValueNotifier<Set<String>> ids, SnCloudFile file)
    toggleSelection,
  ) {
    final file = fileItem.file;
    return _buildTreeFileTile(
      file: file,
      ref: ref,
      context: context,
      isSelectionMode: isSelectionMode,
      selectedFileIds: selectedFileIds,
      expandedFileIds: expandedFileIds,
      treeChildrenCache: treeChildrenCache,
      loadingTreeChildren: loadingTreeChildren,
      ensureTreeChildrenLoaded: ensureTreeChildrenLoaded,
      depth: 0,
      onOpen: () => onOpenFile(file),
      showTreeExpansionAffordance: showTreeExpansionAffordance,
      toggleSelection: toggleSelection,
    );
  }

  Widget _buildUnindexedListTile(
    UnindexedFileItem unindexedFileItem,
    WidgetRef ref,
    BuildContext context,
    bool isSelectionMode,
    ValueNotifier<Set<String>> selectedFileIds,
    ValueNotifier<Set<String>> expandedFileIds,
    Map<String, List<SnCloudFile>> treeChildrenCache,
    Set<String> loadingTreeChildren,
    Future<void> Function(SnCloudFile file) ensureTreeChildrenLoaded,
    bool showTreeExpansionAffordance,
    void Function(ValueNotifier<Set<String>> ids, SnCloudFile file)
    toggleSelection,
  ) {
    final file = unindexedFileItem.file;
    return _buildTreeFileTile(
      file: file,
      ref: ref,
      context: context,
      isSelectionMode: isSelectionMode,
      selectedFileIds: selectedFileIds,
      expandedFileIds: expandedFileIds,
      treeChildrenCache: treeChildrenCache,
      loadingTreeChildren: loadingTreeChildren,
      ensureTreeChildrenLoaded: ensureTreeChildrenLoaded,
      depth: 0,
      onOpen: () => onOpenFile(file),
      showTreeExpansionAffordance: showTreeExpansionAffordance,
      toggleSelection: toggleSelection,
      isUnindexed: true,
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
    return ContextMenuWidget(
      previewBuilder: contextMenuPreviewBuilder,
      menuProvider: (_) {
        return Menu(
          children: [
            MenuAction(
              title: 'Inspect',
              image: MenuImage.icon(Symbols.info),
              callback: () => onInspectFile(unindexedFileItem.file),
            ),
            MenuSeparator(),
            MenuAction(
              title: 'moveToFolder'.tr(),
              image: MenuImage.icon(Symbols.drive_file_move),
              callback: () async {
                await _showMoveToFolderSheet(
                  context: context,
                  ref: ref,
                  fileId: unindexedFileItem.file.id,
                  fileName: unindexedFileItem.file.name,
                  isUnindexed: true,
                );
              },
            ),
            MenuAction(
              title: 'delete'.tr(),
              image: MenuImage.icon(Symbols.delete),
              callback: () async {
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
                  ref.invalidate(unindexedFileListFamilyProvider(tabId));
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
        );
      },
      child: _buildWaterfallFileTileBase(
        unindexedFileItem.file,
        ref,
        context,
        [
          IconButton(
            tooltip: 'moveToFolder'.tr(),
            icon: const Icon(Symbols.drive_file_move),
            onPressed: () => _showMoveToFolderSheet(
              context: context,
              ref: ref,
              fileId: unindexedFileItem.file.id,
              fileName: unindexedFileItem.file.name,
              isUnindexed: true,
            ),
          ),
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
                ref.invalidate(unindexedFileListFamilyProvider(tabId));
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
        onOpen: () => onOpenFile(unindexedFileItem.file),
      ),
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

  Future<void> _showMoveToFolderSheet({
    required BuildContext context,
    required WidgetRef ref,
    required String fileId,
    required String fileName,
    required bool isUnindexed,
  }) async {
    final result = await showModalBottomSheet<String>(
      useRootNavigator: true,
      context: context,
      isScrollControlled: true,
      builder: (ctx) => _FolderSelectorSheet(fileName: fileName),
    );

    if (result == null || !context.mounted) return;

    showLoadingModal(context);
    try {
      final uploader = ref.read(driveFileUploaderProvider);

      // result is the target path, resolve to parent ID
      String? parentId;
      if (result.isNotEmpty) {
        parentId = await uploader.resolveParentIdFromPath(path: result);
      }

      await uploader.moveFile(fileId, parentId: parentId, indexed: true);

      if (isUnindexed) {
        ref.invalidate(unindexedFileListFamilyProvider(tabId));
      }
      ref.invalidate(indexedCloudFileListFamilyProvider(tabId));

      showSnackBar('fileMoved'.tr());
    } catch (e) {
      showSnackBar('failedToMoveFile'.tr());
    } finally {
      if (context.mounted) {
        hideLoadingModal(context);
      }
    }
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
                  ref.invalidate(unindexedFileListFamilyProvider(tabId));
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
    ValueNotifier<String?> query,
    ValueNotifier<String?> order,
    ValueNotifier<bool> orderDesc,
    ObjectRef<Timer?> queryDebounceTimer,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
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
                      ref
                          .read(unindexedFileListFamilyProvider(tabId).notifier)
                          .setOrderDesc(newValue);
                    } else {
                      ref
                          .read(
                            indexedCloudFileListFamilyProvider(tabId).notifier,
                          )
                          .setOrderDesc(newValue);
                    }
                  } else {
                    // Change sort option
                    order.value = value;
                    if (mode.value == FileListMode.unindexed) {
                      ref
                          .read(unindexedFileListFamilyProvider(tabId).notifier)
                          .setOrder(value);
                    } else {
                      ref
                          .read(
                            indexedCloudFileListFamilyProvider(tabId).notifier,
                          )
                          .setOrder(value);
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
            onSelected: (selected) async {
              if (selected) {
                if (mode.value == FileListMode.unindexed) {
                  await ref
                      .read(unindexedFileListFamilyProvider(tabId).notifier)
                      .refresh();
                } else {
                  await ref
                      .read(indexedCloudFileListFamilyProvider(tabId).notifier)
                      .refresh();
                }
              }
            },
          ),
        ],
      ),
    );
  }
}

class _FileListLeadingPreview extends HookConsumerWidget {
  final SnCloudFile file;

  const _FileListLeadingPreview({required this.file});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final kind = file.mimeType.split('/').firstOrNull;

    Widget preview = Container(
      color: colorScheme.surfaceContainerHighest,
      child: Center(child: getFileIcon(file, size: 20, tinyPreview: false)),
    );

    if (kind == 'image') {
      preview = CloudImageWidget(file: file, fit: BoxFit.cover, aspectRatio: 1);
    } else if (kind == 'video') {
      final serverUrl = ref.watch(serverUrlProvider);
      final uri = file.storageUrl ?? '$serverUrl/drive/files/${file.id}';
      preview = Stack(
        fit: StackFit.expand,
        children: [
          UniversalImage(
            uri: '$uri?thumbnail=true',
            fit: BoxFit.cover,
            width: 52,
            height: 52,
          ),
          Container(color: Colors.black12),
          const Center(
            child: Icon(
              Symbols.play_arrow,
              size: 18,
              color: Colors.white,
              shadows: [
                Shadow(
                  color: Colors.black54,
                  blurRadius: 8,
                  offset: Offset(0, 1),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.7)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: ClipRRect(borderRadius: BorderRadius.circular(10), child: preview),
    );
  }
}

class _FolderSelectorSheet extends HookConsumerWidget {
  final String fileName;

  const _FolderSelectorSheet({required this.fileName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPath = useState('/');

    useEffect(() {
      ref.read(_folderSelectorListProvider.notifier).setPath(currentPath.value);
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

    return SheetScaffold(
      titleText: 'moveToFolder'.tr(),
      heightFactor: 0.7,
      child: Column(
        children: [
          Container(
            color: Theme.of(context).colorScheme.surfaceContainerHigh,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Row(
              children: [
                Icon(
                  Symbols.drive_file_move,
                  size: 18,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const Gap(8),
                Expanded(
                  child: Text(
                    fileName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: PaginationWidget(
              provider: _folderSelectorListProvider,
              notifier: _folderSelectorListProvider.notifier,
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
                                onPressed:
                                    breadcrumbs[i].path == currentPath.value
                                    ? null
                                    : () => currentPath.value =
                                          breadcrumbs[i].path,
                                style: TextButton.styleFrom(
                                  visualDensity: VisualDensity.compact,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
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
                    SliverToBoxAdapter(
                      child: ListTile(
                        leading: Icon(
                          Symbols.create_new_folder,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        title: Text('moveHere'.tr()),
                        subtitle: currentPath.value == '/'
                            ? Text('rootDirectory'.tr())
                            : Text(currentPath.value),
                        trailing: const Icon(Symbols.check_circle),
                        onTap: () {
                          Navigator.pop(context, currentPath.value);
                        },
                      ),
                    ),
                    if (currentPath.value != '/') ...[
                      SliverToBoxAdapter(
                        child: ListTile(
                          leading: const Icon(Symbols.arrow_upward),
                          title: Text('parentFolder'.tr()),
                          onTap: () {
                            final parts = currentPath.value
                                .split('/')
                                .where((p) => p.isNotEmpty)
                                .toList();
                            if (parts.length <= 1) {
                              currentPath.value = '/';
                            } else {
                              currentPath.value =
                                  '/${parts.sublist(0, parts.length - 1).join('/')}';
                            }
                          },
                        ),
                      ),
                      const SliverToBoxAdapter(child: Divider(height: 1)),
                    ],
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                      sliver: SliverList.builder(
                        itemCount: data.length + 1,
                        itemBuilder: (context, index) {
                          if (index == data.length) return footer;
                          return data[index].map(
                            file: (fileItem) => const SizedBox.shrink(),
                            folder: (folderItem) => ListTile(
                              leading: Icon(
                                Symbols.folder,
                                color: Theme.of(
                                  context,
                                ).colorScheme.primaryFixedDim,
                              ),
                              title: Text(
                                folderItem.file.name.isEmpty
                                    ? 'untitled'.tr()
                                    : folderItem.file.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Text('folder'.tr()),
                              trailing: const Icon(
                                Symbols.chevron_right,
                                size: 20,
                              ),
                              onTap: () {
                                final newPath = currentPath.value == '/'
                                    ? '/${folderItem.file.name}'
                                    : '${currentPath.value}/${folderItem.file.name}';
                                currentPath.value = newPath;
                              },
                            ),
                            unindexedFile: (unindexedFileItem) =>
                                const SizedBox.shrink(),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

final _folderSelectorListProvider = AsyncNotifierProvider.autoDispose(
  _FolderSelectorListNotifier.new,
);

class _FolderSelectorListNotifier
    extends AsyncNotifier<PaginationState<FileListItem>>
    with AsyncPaginationController<FileListItem> {
  String _currentPath = '/';

  void setPath(String path) {
    if (_currentPath == path) return;
    _currentPath = path;
    ref.invalidateSelf();
  }

  @override
  FutureOr<PaginationState<FileListItem>> build() async {
    final items = await fetch();
    return PaginationState(
      items: items,
      isLoading: false,
      isReloading: false,
      totalCount: totalCount,
      hasMore: false,
      cursor: null,
    );
  }

  @override
  Future<List<FileListItem>> fetch() async {
    final driveApi = ref.read(solarNetworkClientProvider).drive;

    final resolution = await _resolveParentIdForPath(driveApi);
    if (!resolution.found) return const [];

    final PaginatedResult<SnCloudFile> result;
    if (resolution.parentId == null) {
      result = await driveApi.listRootChildren(isFolder: true);
    } else {
      result = await driveApi.listFolderChildren(
        resolution.parentId!,
        isFolder: true,
      );
    }

    totalCount = result.totalCount;
    return result.items.map((file) {
      if (file.isFolder) return FileListItem.folder(file);
      return FileListItem.file(file);
    }).toList();
  }

  Future<({bool found, String? parentId})> _resolveParentIdForPath(
    DriveApi driveApi,
  ) async {
    final parts = _currentPath
        .split('/')
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) {
      return (found: true, parentId: null);
    }

    String? parentId;
    for (final part in parts) {
      final PaginatedResult<SnCloudFile> result;
      if (parentId == null) {
        result = await driveApi.listRootChildren();
      } else {
        result = await driveApi.listFolderChildren(parentId);
      }

      final matchedFolder = result.items
          .where((item) => item.isFolder && item.name == part)
          .firstOrNull;

      if (matchedFolder == null) {
        return (found: false, parentId: null);
      }

      parentId = matchedFolder.id;
      if (parentId.isEmpty) {
        return (found: false, parentId: null);
      }
    }

    return (found: true, parentId: parentId);
  }
}

class FileActionSheet extends StatelessWidget {
  final SnCloudFile file;
  final bool isUnindexed;
  final Function(String) onAction;

  const FileActionSheet({
    super.key,
    required this.file,
    required this.isUnindexed,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final primaryActions = <Widget>[
      _FileActionListTile(
        leading: Icon(Symbols.info),
        title: Text('inspect'.tr()),
        onTap: () => onAction('inspect'),
      ),
      if (!file.isFolder) ...[
        _FileActionListTile(
          leading: Icon(Symbols.download),
          title: Text('download'.tr()),
          onTap: () => onAction('download'),
        ),
        if (!isUnindexed) ...[
          _FileActionListTile(
            leading: Icon(Symbols.edit),
            title: Text('rename'.tr()),
            onTap: () => onAction('rename'),
          ),
          _FileActionListTile(
            leading: Icon(Symbols.drive_file_move),
            title: Text('moveToFolder'.tr()),
            onTap: () => onAction('moveToFolder'),
          ),
          _FileActionListTile(
            leading: Icon(Symbols.share),
            title: Text('share'.tr()),
            onTap: () => onAction('share'),
          ),
          _FileActionListTile(
            leading: Icon(Symbols.content_copy),
            title: Text('copyLink'.tr()),
            onTap: () => onAction('copyLink'),
          ),
          _FileActionListTile(
            leading: Icon(Symbols.info),
            title: Text('fileInfoTitle'.tr()),
            onTap: () => onAction('fileInfo'),
          ),
        ],
      ],
    ];

    final dangerActions = <Widget>[
      if (!file.isFolder)
        _FileActionListTile(
          leading: Icon(Symbols.delete),
          title: Text('delete'.tr()),
          onTap: () => onAction('delete'),
          isDanger: true,
        ),
    ];

    final moreActions = <Widget>[
      if (!file.isFolder && !isUnindexed)
        _FileActionListTile(
          leading: Icon(Symbols.menu_open),
          title: Text('more'.tr()),
          onTap: () => onAction('more'),
        ),
    ];

    return SheetScaffold(
      titleText: 'fileActions'.tr(),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (primaryActions.isNotEmpty)
              _FileActionSection(children: primaryActions),
            if (dangerActions.isNotEmpty)
              _FileActionSection(children: dangerActions),
            if (moreActions.isNotEmpty)
              _FileActionSection(children: moreActions),
            Gap(MediaQuery.of(context).padding.bottom + 32),
          ],
        ),
      ),
    );
  }
}

class _FileActionSection extends StatelessWidget {
  final List<Widget> children;

  const _FileActionSection({required this.children});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
      child: Material(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(20),
        clipBehavior: Clip.antiAlias,
        child: Column(mainAxisSize: MainAxisSize.min, children: children),
      ),
    );
  }
}

class _FileActionListTile extends StatelessWidget {
  final Widget leading;
  final Widget title;
  final VoidCallback onTap;
  final bool isDanger;

  const _FileActionListTile({
    required this.leading,
    required this.title,
    required this.onTap,
    this.isDanger = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final foreground = isDanger
        ? theme.colorScheme.error
        : theme.colorScheme.onSurface;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: DefaultTextStyle.merge(
          style: TextStyle(color: foreground),
          child: IconTheme.merge(
            data: IconThemeData(color: foreground),
            child: Row(
              children: [
                SizedBox(width: 24, height: 24, child: leading),
                const Gap(12),
                Expanded(child: title),
                Icon(
                  Symbols.chevron_right,
                  size: 16,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
