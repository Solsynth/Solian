import 'dart:async';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
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
import 'package:island/drive/widgets/drive_filter_bar.dart';
import 'package:island/shared/widgets/pagination_list.dart';
import 'package:island/shared/widgets/content/image.dart';
import 'package:island/core/services/time.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:super_context_menu/super_context_menu.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

enum FileListMode { normal, unindexed }

enum FileListViewMode { list, columns, waterfall }

/// Payload for dragging indexed drive items between folders.
class _DriveMoveDragData {
  final List<String> fileIds;
  final String primaryName;
  final bool primaryIsFolder;

  const _DriveMoveDragData({
    required this.fileIds,
    required this.primaryName,
    this.primaryIsFolder = false,
  });

  int get count => fileIds.length;
}

/// Sets [notifier]'s value only while it is still being observed.
///
/// Post-frame callbacks scheduled by a file-list view can fire after the
/// owning tab was closed: [closeTab] disposes the tab's `ValueNotifier`s
/// synchronously, but the outgoing view (still animating out, or awaiting a
/// reload triggered by the tab's invalidation) may schedule one more write.
/// A disposed [ChangeNotifier] always reports `hasListeners == false`, so the
/// write is dropped instead of throwing "used after being disposed". Writes to
/// an unobserved notifier are unobservable by definition, so skipping them is
/// always safe.
void _writeIfObserved<T>(ValueNotifier<T>? notifier, T value) {
  if (notifier == null) return;
  // `hasListeners` is @protected, but this is a deliberate read-only use: it
  // is the only public signal distinguishing a live, observed notifier from
  // one whose owning tab was closed (dispose() clears the listener list, so a
  // disposed notifier always reports no listeners).
  // ignore: invalid_use_of_protected_member
  if (!notifier.hasListeners) return;
  notifier.value = value;
}

_DriveMoveDragData _resolveMoveDragData({
  required SnCloudFile file,
  required Set<String> selectedIds,
  required bool isSelectionMode,
}) {
  if (isSelectionMode &&
      selectedIds.contains(file.id) &&
      selectedIds.length > 1) {
    return _DriveMoveDragData(
      fileIds: selectedIds.toList(growable: false),
      primaryName: file.name,
      primaryIsFolder: file.isFolder,
    );
  }
  return _DriveMoveDragData(
    fileIds: [file.id],
    primaryName: file.name,
    primaryIsFolder: file.isFolder,
  );
}

bool _preferLongPressDrag(BuildContext context) {
  final platform = Theme.of(context).platform;
  return platform == TargetPlatform.iOS || platform == TargetPlatform.android;
}

Future<void> _moveDriveItems({
  required BuildContext context,
  required WidgetRef ref,
  required String tabId,
  required List<String> fileIds,
  required String? parentId,
}) async {
  if (fileIds.isEmpty) return;

  showLoadingModal(context);
  try {
    await ref
        .read(driveFileUploaderProvider)
        .moveFiles(fileIds, parentId: parentId, indexed: true);
    invalidateIndexedDriveViews(ref, tabId);
    showSnackBar('fileMoved'.tr());
  } catch (_) {
    showSnackBar('failedToMoveFile'.tr());
  } finally {
    if (context.mounted) {
      hideLoadingModal(context);
    }
  }
}

Future<void> _moveDriveItemsToPath({
  required BuildContext context,
  required WidgetRef ref,
  required String tabId,
  required List<String> fileIds,
  required String path,
}) async {
  if (fileIds.isEmpty) return;
  final uploader = ref.read(driveFileUploaderProvider);
  String? parentId;
  final normalized = path.trim().isEmpty ? '/' : path.trim();
  if (normalized != '/') {
    parentId = await uploader.resolveParentIdFromPath(path: normalized);
  }
  if (!context.mounted) return;
  await _moveDriveItems(
    context: context,
    ref: ref,
    tabId: tabId,
    fileIds: fileIds,
    parentId: parentId,
  );
}

Future<void> _showIndexedMoveSheet({
  required BuildContext context,
  required WidgetRef ref,
  required String tabId,
  required String fileId,
  required String fileName,
}) async {
  final result = await showModalBottomSheet<String>(
    useRootNavigator: true,
    context: context,
    isScrollControlled: true,
    builder: (ctx) => _FolderSelectorSheet(fileName: fileName),
  );
  if (result == null || !context.mounted) return;
  await _moveDriveItemsToPath(
    context: context,
    ref: ref,
    tabId: tabId,
    fileIds: [fileId],
    path: result.isEmpty ? '/' : result,
  );
}

Future<void> _deleteIndexedDriveItem({
  required BuildContext context,
  required WidgetRef ref,
  required String tabId,
  required SnCloudFile file,
}) async {
  final confirmed = await showConfirmAlert(
    'confirmDeleteFile'.tr(),
    file.isFolder ? 'delete'.tr() : 'deleteFile'.tr(),
    isDanger: true,
  );
  if (!confirmed || !context.mounted) return;

  showLoadingModal(context);
  try {
    await ref.read(driveFileUploaderProvider).deleteFile(file.id);
    invalidateIndexedDriveViews(ref, tabId);
  } catch (_) {
    showSnackBar('failedToDeleteFile'.tr());
  } finally {
    if (context.mounted) {
      hideLoadingModal(context);
    }
  }
}

Menu _buildIndexedColumnMenu({
  required BuildContext context,
  required WidgetRef ref,
  required String tabId,
  required SnCloudFile file,
  required void Function(SnCloudFile file) onInspect,
}) {
  if (file.isFolder) {
    return Menu(
      children: [
        MenuAction(
          title: 'Inspect',
          image: MenuImage.icon(Symbols.info),
          callback: () => onInspect(file),
        ),
        MenuSeparator(),
        MenuAction(
          title: 'rename'.tr(),
          image: MenuImage.icon(Symbols.edit),
          callback: () async {
            await CloudFileActionsSheet.showRenameSheet(
              context: context,
              file: file,
              onRenamed: (_) {
                invalidateIndexedDriveViews(ref, tabId);
              },
            );
          },
        ),
        MenuAction(
          title: 'moveToFolder'.tr(),
          image: MenuImage.icon(Symbols.drive_file_move),
          callback: () => _showIndexedMoveSheet(
            context: context,
            ref: ref,
            tabId: tabId,
            fileId: file.id,
            fileName: file.name,
          ),
        ),
        MenuSeparator(),
        MenuAction(
          title: 'delete'.tr(),
          image: MenuImage.icon(Symbols.delete),
          callback: () => _deleteIndexedDriveItem(
            context: context,
            ref: ref,
            tabId: tabId,
            file: file,
          ),
        ),
      ],
    );
  }

  return Menu(
    children: [
      MenuAction(
        title: 'Inspect',
        image: MenuImage.icon(Symbols.info),
        callback: () => onInspect(file),
      ),
      MenuSeparator(),
      MenuAction(
        title: 'rename'.tr(),
        image: MenuImage.icon(Symbols.edit),
        callback: () async {
          await CloudFileActionsSheet.showRenameSheet(
            context: context,
            file: file,
            onRenamed: (_) {
              invalidateIndexedDriveViews(ref, tabId);
            },
          );
        },
      ),
      MenuAction(
        title: 'moveToFolder'.tr(),
        image: MenuImage.icon(Symbols.drive_file_move),
        callback: () => _showIndexedMoveSheet(
          context: context,
          ref: ref,
          tabId: tabId,
          fileId: file.id,
          fileName: file.name,
        ),
      ),
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
          Clipboard.setData(ClipboardData(text: file.storageUrl ?? file.id));
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
      MenuSeparator(),
      MenuAction(
        title: 'delete'.tr(),
        image: MenuImage.icon(Symbols.delete),
        callback: () => _deleteIndexedDriveItem(
          context: context,
          ref: ref,
          tabId: tabId,
          file: file,
        ),
      ),
      MenuSeparator(),
      MenuAction(
        title: 'more'.tr(),
        image: MenuImage.icon(Symbols.menu_open),
        callback: () async {
          await CloudFileActionsSheet.show(
            context: context,
            item: file,
            onRenamed: (_) {
              invalidateIndexedDriveViews(ref, tabId);
            },
          );
        },
      ),
    ],
  );
}

class FileListView extends HookConsumerWidget {
  final String tabId;
  final Map<String, dynamic>? usage;
  final Map<String, dynamic>? quota;
  final ValueNotifier<String> currentPath;
  final ValueNotifier<SnFilePool?> selectedPool;
  final bool showFilters;
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

  const FileListView({
    required this.tabId,
    required this.usage,
    required this.quota,
    required this.currentPath,
    required this.selectedPool,
    this.showFilters = false,
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
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPathValue = useValueListenable(currentPath);
    final modeValue = useValueListenable(mode);
    final viewModeValue = useValueListenable(viewMode);
    final queryValue = useValueListenable(query);
    final workspaceId = ref.watch(driveWorkspaceIdProvider(tabId));

    // Defer provider mutations — useEffect runs during HookWidget build here,
    // and invalidateSelf() during build triggers markNeedsBuild assertions.
    useEffect(() {
      if (modeValue != FileListMode.normal) return null;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(indexedCloudFileListFamilyProvider(tabId).notifier)
            .setPath(currentPathValue);
      });
      return null;
    }, [currentPathValue, modeValue]);

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (modeValue == FileListMode.normal) {
          ref
              .read(indexedCloudFileListFamilyProvider(tabId).notifier)
              .setWorkspaceId(workspaceId);
        } else {
          ref
              .read(unindexedFileListFamilyProvider(tabId).notifier)
              .setWorkspaceId(workspaceId);
        }
      });
      return null;
    }, [modeValue, workspaceId]);

    if (usage == null) return const SizedBox.shrink();

    final recycled = useState<bool>(false);
    final localSelectedFileIds = useState<Set<String>>({});
    final currentVisibleItems = useState<List<FileListItem>>([]);
    final expandedFileIds = useState<Set<String>>({});
    final treeChildrenCache = useState<Map<String, List<SnCloudFile>>>({});
    final loadingTreeChildren = useState<Set<String>>({});
    final filters = useState(const DriveFileFilters());
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
          workspaceId: workspaceId,
        );
        if (result.items.isNotEmpty) {
          treeChildrenCache.value = {
            ...treeChildrenCache.value,
            file.id: result.items,
          };
          syncLoadedChildrenSelection(selectedIdsNotifier, file, result.items);
          if (currentVisibleFileIds != null) {
            final visible = currentVisibleFileIds!;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _writeIfObserved(visible, {
                ...visible.value,
                ...result.items.map((item) => item.id),
              });
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
          _writeIfObserved(isSelectionMode, false);
          _writeIfObserved(selectedIdsNotifier, <String>{});
        });
      }
      return null;
    }, [modeValue]);

    useEffect(() {
      // Sync pool when mode or selectedPool changes
      final poolId = selectedPool.value?.id;
      final modeSnapshot = modeValue;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (modeSnapshot == FileListMode.unindexed) {
          ref
              .read(unindexedFileListFamilyProvider(tabId).notifier)
              .setPool(poolId);
        } else {
          ref
              .read(indexedCloudFileListFamilyProvider(tabId).notifier)
              .setPool(poolId);
        }
      });
      return null;
    }, [selectedPool.value, modeValue]);

    useEffect(() {
      // Sync free-text query + structured filters (never key:value advanced search).
      final modeSnapshot = modeValue;
      final querySnapshot = queryValue;
      final filtersSnapshot = filters.value;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (modeSnapshot == FileListMode.unindexed) {
          final notifier = ref.read(
            unindexedFileListFamilyProvider(tabId).notifier,
          );
          notifier.setQuery(querySnapshot);
          notifier.setStructuredFilters(
            isFolder: filtersSnapshot.isFolder,
            contentType: filtersSnapshot.contentTypeParam,
            extension: filtersSnapshot.extensionParam,
            createdAfter: filtersSnapshot.createdAfterParam,
            createdBefore: filtersSnapshot.createdBeforeParam,
            order: filtersSnapshot.order,
            orderDesc: filtersSnapshot.orderDesc,
          );
        } else {
          final notifier = ref.read(
            indexedCloudFileListFamilyProvider(tabId).notifier,
          );
          notifier.setQuery(querySnapshot);
          notifier.setStructuredFilters(
            isFolder: filtersSnapshot.isFolder,
            contentType: filtersSnapshot.contentTypeParam,
            extension: filtersSnapshot.extensionParam,
            createdAfter: filtersSnapshot.createdAfterParam,
            createdBefore: filtersSnapshot.createdBeforeParam,
            order: filtersSnapshot.order,
            orderDesc: filtersSnapshot.orderDesc,
          );
        }
      });
      return null;
    }, [queryValue, filters.value, modeValue]);

    final indexedListState = ref.watch(
      indexedCloudFileListFamilyProvider(tabId),
    );
    final unindexedListState = ref.watch(
      unindexedFileListFamilyProvider(tabId),
    );
    // Include PaginationState.isReloading — refresh() keeps AsyncData and only
    // flips the nested flag, so AsyncValue.isReloading alone misses it.
    final isRefreshing = modeValue == FileListMode.normal
        ? (indexedListState.isLoading ||
              indexedListState.isReloading ||
              (indexedListState.asData?.value.isLoading ?? false) ||
              (indexedListState.asData?.value.isReloading ?? false))
        : (unindexedListState.isLoading ||
              unindexedListState.isReloading ||
              (unindexedListState.asData?.value.isLoading ?? false) ||
              (unindexedListState.asData?.value.isReloading ?? false));

    // Drop expanded-tree caches whenever the list reloads (refresh/delete/move)
    // so children rows never show stale server state.
    useEffect(() {
      if (!isRefreshing) return null;
      if (treeChildrenCache.value.isNotEmpty ||
          expandedFileIds.value.isNotEmpty ||
          loadingTreeChildren.value.isNotEmpty) {
        treeChildrenCache.value = {};
        expandedFileIds.value = {};
        loadingTreeChildren.value = {};
      }
      return null;
    }, [isRefreshing]);

    final useColumnBrowser =
        modeValue == FileListMode.normal &&
        viewModeValue == FileListViewMode.columns;

    final listSkeleton = const _DriveListTileSkeleton();

    final bodyWidget = switch (modeValue) {
      FileListMode.unindexed => PaginationWidget(
        provider: unindexedFileListFamilyProvider(tabId),
        notifier: unindexedFileListFamilyProvider(tabId).notifier,
        isRefreshable: false,
        isSliver: true,
        footerSkeletonChild: listSkeleton,
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
      _ when useColumnBrowser => null,
      _ => PaginationWidget(
        provider: indexedCloudFileListFamilyProvider(tabId),
        notifier: indexedCloudFileListFamilyProvider(tabId).notifier,
        isRefreshable: false,
        isSliver: true,
        footerSkeletonChild: listSkeleton,
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
      pathWidget = _wrapPathDropTarget(
        context: context,
        ref: ref,
        path: '/',
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
      final pathParts = currentPathValue
          .split('/')
          .where((part) => part.isNotEmpty)
          .toList();
      final breadcrumbs = <Widget>[];

      // Add root (drop target to move items back to root)
      breadcrumbs.add(
        _wrapPathDropTarget(
          context: context,
          ref: ref,
          path: '/',
          child: InkWell(
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
          // Clickable parent directory (also accepts drops)
          breadcrumbs.add(
            _wrapPathDropTarget(
              context: context,
              ref: ref,
              path: path,
              child: InkWell(
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
            ),
          );
        }
      }

      pathWidget = Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        children: breadcrumbs,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Gap(10),

        // Breadcrumbs and view switch at the top
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 16, 10),
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
                    icon: const Icon(Symbols.list),
                    tooltip: 'listView'.tr(),
                  ),
                  if (modeValue == FileListMode.normal)
                    ButtonSegment<FileListViewMode>(
                      value: FileListViewMode.columns,
                      icon: const Icon(Symbols.view_column),
                      tooltip: 'columnView'.tr(),
                    ),
                  ButtonSegment<FileListViewMode>(
                    value: FileListViewMode.waterfall,
                    icon: const Icon(Symbols.view_module),
                    tooltip: 'waterfallView'.tr(),
                  ),
                ],
                selected: {
                  modeValue == FileListMode.unindexed &&
                          viewModeValue == FileListViewMode.columns
                      ? FileListViewMode.list
                      : viewModeValue,
                },
                onSelectionChanged: (Set<FileListViewMode> newSelection) {
                  viewMode.value = newSelection.first;
                },
                style: const ButtonStyle(
                  visualDensity: VisualDensity.compact,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
        ),

        AnimatedCrossFade(
          duration: const Duration(milliseconds: 220),
          sizeCurve: Curves.easeInOutCubic,
          firstCurve: Curves.easeOut,
          secondCurve: Curves.easeIn,
          crossFadeState: showFilters
              ? CrossFadeState.showFirst
              : CrossFadeState.showSecond,
          alignment: Alignment.topCenter,
          firstChild: Column(
            key: const ValueKey('drive-filters-visible'),
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DriveFilterBar(
                filters: filters.value,
                enabled: !isRefreshing,
                onChanged: (next) => filters.value = next,
                onRefresh: () async {
                  // Drop in-memory tree expand caches so reloads reflect
                  // server state after deletes/moves.
                  treeChildrenCache.value = {};
                  loadingTreeChildren.value = {};
                  expandedFileIds.value = {};
                  if (modeValue == FileListMode.unindexed) {
                    await ref
                        .read(unindexedFileListFamilyProvider(tabId).notifier)
                        .refresh();
                  } else {
                    await ref
                        .read(
                          indexedCloudFileListFamilyProvider(tabId).notifier,
                        )
                        .refresh();
                    bumpDriveBrowserEpoch(ref, tabId);
                  }
                },
              ),
              const Gap(10),
            ],
          ),
          secondChild: const SizedBox(
            key: ValueKey('drive-filters-hidden'),
            width: double.infinity,
          ),
        ),

        if (modeValue == FileListMode.unindexed && recycled.value)
          _buildClearRecycledButton(ref).padding(horizontal: 8),

        // Divider below filters / path chrome — list, columns, waterfall.
        Divider(
          height: 1,
          thickness: 1,
          color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.55),
        ),

        // Reserved 2px slot — no layout jump when refresh starts/stops.
        SizedBox(
          height: 2,
          child: AnimatedOpacity(
            opacity: isRefreshing ? 1 : 0,
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            child: LinearProgressIndicator(
              minHeight: 2,
              backgroundColor: Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest.withOpacity(0.35),
            ),
          ),
        ),
        Expanded(
          child: useColumnBrowser
              ? _DriveColumnBrowser(
                  tabId: tabId,
                  currentPath: currentPath,
                  selectedPool: selectedPool,
                  filters: filters.value,
                  query: queryValue,
                  isSelectionMode: isSelectionMode,
                  selectedFileIds: selectedIdsNotifier,
                  currentVisibleFileIds: currentVisibleFileIds,
                  onOpenFolderInNewTab: onOpenFolderInNewTab,
                  onInspectFile: onInspectFile,
                  onOpenFile: onOpenFile,
                  onPickAndUpload: onPickAndUpload,
                  onShowCreateFolder: onShowCreateFolder,
                  toggleSelection: toggleSelectionWithLoadedChildren,
                )
              : CustomScrollView(
                  slivers: [
                    const SliverGap(20),
                    bodyWidget!,
                    const SliverGap(20),
                  ],
                ).padding(
                  horizontal: viewModeValue == FileListViewMode.waterfall
                      ? 20
                      : null,
                ),
        ),
      ],
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
        // Include folders so Select All works for mixed / folder-only listings.
        _writeIfObserved(
          currentVisibleFileIds,
          items
              .expand(
                (item) => item.maybeMap(
                  file: (fileItem) => [fileItem.file.id],
                  folder: (folderItem) => [folderItem.file.id],
                  unindexedFile: (fileItem) => [fileItem.file.id],
                  orElse: () => <String>[],
                ),
              )
              .toSet(),
        );
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
          maxCrossAxisExtent: isWideScreen(context) ? 360 : 260,
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
            file: (fileItem) => _buildWaterfallFileTile(
              fileItem,
              ref,
              context,
              isSelectionMode.value,
              selectedFileIds.value,
              () {
                toggleSelection(selectedFileIds, fileItem.file);
              },
            ),
            folder: (folderItem) => _buildWaterfallFolderTile(
              folderItem,
              ref,
              currentPath,
              context,
              isSelectionMode: isSelectionMode.value,
              selectedIds: selectedFileIds.value,
              onToggleSelection: () =>
                  toggleSelection(selectedFileIds, folderItem.file),
              onEnterSelection: () {
                if (!isSelectionMode.value) {
                  isSelectionMode.value = true;
                }
                toggleSelection(selectedFileIds, folderItem.file);
              },
            ),
            unindexedFile: (unindexedFileItem) {
              // Should not happen
              return const SizedBox.shrink();
            },
          );
        }, childCount: items.length + 1),
      ),
      // List / columns fallback (columns use a dedicated browser widget)
      FileListViewMode.list || FileListViewMode.columns => SliverList.builder(
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
              final file = folderItem.file;
              final isSelected = selectedFileIds.value.contains(file.id);
              final selectionMode = isSelectionMode.value;
              final metaStyle = theme.textTheme.bodySmall?.copyWith(
                height: 1.15,
                color: theme.colorScheme.onSurfaceVariant,
              );
              return _wrapFolderDropTarget(
                context: context,
                ref: ref,
                folder: file,
                child: _wrapIndexedDraggable(
                  context: context,
                  file: file,
                  selectedIds: selectedFileIds.value,
                  isSelectionMode: selectionMode,
                  child: ContextMenuWidget(
                    previewBuilder: contextMenuPreviewBuilder,
                    menuProvider: (_) => _buildFolderMenu(context, ref, file),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 3,
                      ),
                      child: Material(
                        color: selectionMode && isSelected
                            ? theme.colorScheme.primaryContainer.withOpacity(
                                0.45,
                              )
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            if (selectionMode) {
                              toggleSelection(selectedFileIds, file);
                              return;
                            }
                            final newPath = currentPath.value == '/'
                                ? '/${file.name}'
                                : '${currentPath.value}/${file.name}';
                            if (HardwareKeyboard.instance.isShiftPressed) {
                              onOpenFolderInNewTab(newPath);
                            } else {
                              currentPath.value = newPath;
                            }
                          },
                          onLongPress: () {
                            if (!selectionMode) {
                              isSelectionMode.value = true;
                            }
                            toggleSelection(selectedFileIds, file);
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            child: Row(
                              children: [
                                if (showTreeExpansionAffordance)
                                  const SizedBox(width: 32),
                                if (selectionMode) ...[
                                  SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: Checkbox(
                                      value: isSelected,
                                      materialTapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                      visualDensity: VisualDensity.compact,
                                      onChanged: (_) => toggleSelection(
                                        selectedFileIds,
                                        file,
                                      ),
                                    ),
                                  ),
                                  const Gap(10),
                                ],
                                const _DriveFolderLeading(),
                                const Gap(14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        file.name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: theme.textTheme.bodyLarge
                                            ?.copyWith(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 15,
                                            ),
                                      ),
                                      const Gap(4),
                                      Text(
                                        [
                                          'folder'.tr(),
                                          if (file.childrenCount > 0)
                                            '${file.childrenCount}',
                                        ].join(' · '),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: metaStyle?.copyWith(
                                          height: 1.25,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (!selectionMode) ...[
                                  const Gap(8),
                                  _buildFolderActions(context, ref, file),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
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
    Set<String> selectedIds,
    VoidCallback? toggleSelection,
  ) {
    final isSelected = selectedIds.contains(fileItem.file.id);
    return _wrapIndexedDraggable(
      context: context,
      file: fileItem.file,
      selectedIds: selectedIds,
      isSelectionMode: isSelectionMode,
      child: ContextMenuWidget(
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
                      invalidateIndexedDriveViews(ref, tabId);
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
                    invalidateIndexedDriveViews(ref, tabId);
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
                      invalidateIndexedDriveViews(ref, tabId);
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
        invalidateIndexedDriveViews(ref, tabId);
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
      invalidateIndexedDriveViews(ref, tabId);
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
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
      onSelected: (value) => _handleFolderAction(context, ref, folder, value),
      itemBuilder: (context) => [
        PopupMenuItem(value: 'inspect', child: Text('inspect'.tr())),
        PopupMenuItem(value: 'rename', child: Text('rename'.tr())),
        PopupMenuItem(value: 'move', child: Text('moveToFolder'.tr())),
        PopupMenuItem(value: 'delete', child: Text('delete'.tr())),
      ],
      child: const Padding(
        padding: EdgeInsets.all(8),
        child: Icon(Symbols.more_vert, size: 22),
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
              invalidateIndexedDriveViews(ref, tabId);
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
              invalidateIndexedDriveViews(ref, tabId);
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
              invalidateIndexedDriveViews(ref, tabId);
            },
          );
          break;
      }
    }

    return [
      _CompactIconButton(
        tooltip: 'download'.tr(),
        icon: Symbols.download,
        onPressed: () => handleAction('download'),
      ),
      if (isMobile)
        _CompactIconButton(
          tooltip: 'more'.tr(),
          icon: Symbols.more_vert,
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
        )
      else
        PopupMenuButton<String>(
          tooltip: 'more'.tr(),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          onSelected: handleAction,
          itemBuilder: (context) => [
            PopupMenuItem(value: 'inspect', child: Text('inspect'.tr())),
            PopupMenuItem(value: 'rename', child: Text('rename'.tr())),
            PopupMenuItem(
              value: 'moveToFolder',
              child: Text('moveToFolder'.tr()),
            ),
            PopupMenuItem(value: 'share', child: Text('share'.tr())),
            PopupMenuItem(value: 'copyLink', child: Text('copyLink'.tr())),
            PopupMenuItem(value: 'fileInfo', child: Text('fileInfoTitle'.tr())),
            const PopupMenuDivider(),
            PopupMenuItem(value: 'delete', child: Text('delete'.tr())),
            PopupMenuItem(value: 'more', child: Text('more'.tr())),
          ],
          child: const Padding(
            padding: EdgeInsets.all(8),
            child: Icon(Symbols.more_vert, size: 22),
          ),
        ),
    ];
  }

  String _fileMetaLine(SnCloudFile file) {
    final parts = <String>[
      formatFileSize(file.size),
      file.createdAt.formatSystem(),
      if (file.usage != null && file.usage!.isNotEmpty) file.usage!,
      if (file.applicationType != null && file.applicationType!.isNotEmpty)
        file.applicationType!,
    ];
    return parts.join(' · ');
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final ratio = (file.ratio == null || file.ratio == 0) ? 1.0 : file.ratio!;
    final safeRatio = ratio.clamp(0.55, 1.8);
    final itemType = file.mimeType.split('/').first;
    final uri =
        '${ref.read(solarNetworkClientProvider).dio.options.baseUrl}/drive/files/${file.id}';

    Widget previewWidget;
    switch (itemType) {
      case 'image':
        previewWidget = CloudImageWidget(
          file: file,
          aspectRatio: safeRatio,
          fit: BoxFit.cover,
        );
        break;
      case 'video':
        previewWidget = CloudVideoWidget(item: file);
        break;
      case 'audio':
        previewWidget = ColoredBox(
          color: colorScheme.surfaceContainerHighest,
          child: Center(child: getFileIcon(file, size: 48)),
        );
        break;
      case 'text':
        previewWidget = ColoredBox(
          color: colorScheme.surfaceContainerHighest,
          child: FutureBuilder<String>(
            future: ref
                .read(solarNetworkClientProvider)
                .dio
                .get(uri)
                .then((response) => response.data as String),
            builder: (context, snapshot) => snapshot.hasData
                ? SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      snapshot.data!,
                      style: TextStyle(
                        fontSize: 10,
                        fontFamily: 'monospace',
                        color: colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 16,
                      overflow: TextOverflow.ellipsis,
                    ),
                  )
                : const Center(
                    child: SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
          ),
        );
        break;
      default:
        previewWidget = ColoredBox(
          color: colorScheme.surfaceContainerHighest,
          child: Center(child: getFileIcon(file, size: 48)),
        );
        break;
    }

    return Material(
      color: isSelectionMode && isSelected
          ? colorScheme.primaryContainer.withOpacity(0.35)
          : colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: isSelectionMode && isSelected
              ? colorScheme.primary.withOpacity(0.45)
              : colorScheme.outlineVariant.withOpacity(0.55),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          if (isSelectionMode && toggleSelection != null) {
            toggleSelection();
          } else {
            onOpen();
          }
        },
        onLongPress: toggleSelection,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: safeRatio,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  previewWidget,
                  if (isSelectionMode)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Material(
                        color: colorScheme.surface.withOpacity(0.88),
                        borderRadius: BorderRadius.circular(8),
                        child: SizedBox(
                          width: 28,
                          height: 28,
                          child: Checkbox(
                            value: isSelected,
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            visualDensity: VisualDensity.compact,
                            onChanged: (_) => toggleSelection?.call(),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 8, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 36,
                    height: 36,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: _FileListLeadingPreview(file: file),
                    ),
                  ),
                  const Gap(10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          file.name.isEmpty ? 'untitled'.tr() : file.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            fontStyle: file.name.isEmpty
                                ? FontStyle.italic
                                : FontStyle.normal,
                          ),
                        ),
                        const Gap(4),
                        Text(
                          _fileMetaLine(file),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            height: 1.25,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!isSelectionMode && actions != null) ...[
                    const Gap(4),
                    ...actions,
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWaterfallFolderTile(
    FolderItem folderItem,
    WidgetRef ref,
    ValueNotifier<String> currentPath,
    BuildContext context, {
    bool isSelectionMode = false,
    Set<String> selectedIds = const {},
    VoidCallback? onToggleSelection,
    VoidCallback? onEnterSelection,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final file = folderItem.file;
    final isSelected = selectedIds.contains(file.id);

    return _wrapFolderDropTarget(
      context: context,
      ref: ref,
      folder: file,
      child: _wrapIndexedDraggable(
        context: context,
        file: file,
        selectedIds: selectedIds,
        isSelectionMode: isSelectionMode,
        child: ContextMenuWidget(
          previewBuilder: contextMenuPreviewBuilder,
          menuProvider: (_) => _buildFolderMenu(context, ref, file),
          child: Material(
            color: isSelectionMode && isSelected
                ? colorScheme.primaryContainer.withOpacity(0.35)
                : colorScheme.surfaceContainerLow,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(
                color: isSelectionMode && isSelected
                    ? colorScheme.primary.withOpacity(0.45)
                    : colorScheme.outlineVariant.withOpacity(0.55),
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () {
                if (isSelectionMode) {
                  onToggleSelection?.call();
                  return;
                }
                final newPath = currentPath.value == '/'
                    ? '/${file.name}'
                    : '${currentPath.value}/${file.name}';
                if (HardwareKeyboard.instance.isShiftPressed) {
                  onOpenFolderInNewTab(newPath);
                } else {
                  currentPath.value = newPath;
                }
              },
              onLongPress: onEnterSelection,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 16, 10, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        if (isSelectionMode) ...[
                          SizedBox(
                            width: 24,
                            height: 24,
                            child: Checkbox(
                              value: isSelected,
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              visualDensity: VisualDensity.compact,
                              onChanged: (_) => onToggleSelection?.call(),
                            ),
                          ),
                          const Gap(10),
                        ],
                        const _DriveFolderLeading(),
                        const Spacer(),
                        if (!isSelectionMode)
                          _buildFolderActions(context, ref, file),
                      ],
                    ),
                    const Gap(14),
                    Text(
                      file.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Gap(4),
                    Text(
                      [
                        'folder'.tr(),
                        if (file.childrenCount > 0) '${file.childrenCount}',
                      ].join(' · '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
            ),
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
        _writeIfObserved(
          currentVisibleFileIds,
          items
              .expand(
                (item) => item.maybeMap(
                  file: (fileItem) => [fileItem.file.id],
                  folder: (folderItem) => [folderItem.file.id],
                  unindexedFile: (fileItem) => [fileItem.file.id],
                  orElse: () => <String>[],
                ),
              )
              .toSet(),
        );
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
          maxCrossAxisExtent: isWideScreen(context) ? 360 : 260,
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
      // List / columns (columns only apply to indexed files)
      FileListViewMode.list || FileListViewMode.columns => SliverList.builder(
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
                            invalidateIndexedDriveViews(ref, tabId);
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
                        if (isUnindexed) {
                          ref.invalidate(
                            unindexedFileListFamilyProvider(tabId),
                          );
                        } else {
                          invalidateIndexedDriveViews(ref, tabId);
                        }
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
                            invalidateIndexedDriveViews(ref, tabId);
                          },
                        );
                      },
                    ),
                  ],
                ],
              ],
            );
          },
          child: isUnindexed
              ? Padding(
                  padding: EdgeInsets.only(
                    left: 12 + depth * 18.0,
                    right: 12,
                    top: 3,
                    bottom: 3,
                  ),
                  child: Material(
                    color: isSelectionMode && isSelected
                        ? theme.colorScheme.primaryContainer.withOpacity(0.45)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        if (isSelectionMode) {
                          toggleSelection(selectedFileIds, file);
                        } else {
                          onOpen();
                        }
                      },
                      child: _buildTreeFileTileRow(
                        context: context,
                        theme: theme,
                        file: file,
                        hasTreeChildren: hasTreeChildren,
                        isExpanded: isExpanded,
                        showTreeExpansionAffordance:
                            showTreeExpansionAffordance,
                        isSelectionMode: isSelectionMode,
                        isSelected: isSelected,
                        selectedFileIds: selectedFileIds,
                        expandedFileIds: expandedFileIds,
                        ensureTreeChildrenLoaded: ensureTreeChildrenLoaded,
                        toggleSelection: toggleSelection,
                        ref: ref,
                      ),
                    ),
                  ),
                )
              : _wrapIndexedDraggable(
                  context: context,
                  file: file,
                  selectedIds: selectedFileIds.value,
                  isSelectionMode: isSelectionMode,
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: 12 + depth * 18.0,
                      right: 12,
                      top: 3,
                      bottom: 3,
                    ),
                    child: Material(
                      color: isSelectionMode && isSelected
                          ? theme.colorScheme.primaryContainer.withOpacity(0.45)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          if (isSelectionMode) {
                            toggleSelection(selectedFileIds, file);
                          } else {
                            onOpen();
                          }
                        },
                        child: _buildTreeFileTileRow(
                          context: context,
                          theme: theme,
                          file: file,
                          hasTreeChildren: hasTreeChildren,
                          isExpanded: isExpanded,
                          showTreeExpansionAffordance:
                              showTreeExpansionAffordance,
                          isSelectionMode: isSelectionMode,
                          isSelected: isSelected,
                          selectedFileIds: selectedFileIds,
                          expandedFileIds: expandedFileIds,
                          ensureTreeChildrenLoaded: ensureTreeChildrenLoaded,
                          toggleSelection: toggleSelection,
                          ref: ref,
                        ),
                      ),
                    ),
                  ),
                ),
        ),
        if (hasTreeChildren && isExpanded)
          if (isLoadingChildren && children.isEmpty)
            Padding(
              padding: EdgeInsets.only(left: 8 + depth * 16.0 + 48, right: 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(1),
                child: LinearProgressIndicator(
                  minHeight: 2,
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                ),
              ),
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

  Widget _buildTreeFileTileRow({
    required BuildContext context,
    required ThemeData theme,
    required SnCloudFile file,
    required bool hasTreeChildren,
    required bool isExpanded,
    required bool showTreeExpansionAffordance,
    required bool isSelectionMode,
    required bool isSelected,
    required ValueNotifier<Set<String>> selectedFileIds,
    required ValueNotifier<Set<String>> expandedFileIds,
    required Future<void> Function(SnCloudFile file) ensureTreeChildrenLoaded,
    required void Function(ValueNotifier<Set<String>> ids, SnCloudFile file)
    toggleSelection,
    required WidgetRef ref,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
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
                iconSize: 20,
                icon: Icon(
                  isExpanded ? Symbols.expand_more : Symbols.chevron_right,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                onPressed: () async {
                  if (!isExpanded) {
                    await ensureTreeChildrenLoaded(file);
                  }
                  _toggleId(expandedFileIds, file.id);
                },
              ),
            )
          else if (showTreeExpansionAffordance)
            const SizedBox(width: 32, height: 32),
          if (hasTreeChildren || showTreeExpansionAffordance) const Gap(4),
          if (isSelectionMode) ...[
            SizedBox(
              width: 24,
              height: 24,
              child: Checkbox(
                value: isSelected,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
                onChanged: (_) => toggleSelection(selectedFileIds, file),
              ),
            ),
            const Gap(10),
          ],
          SizedBox(
            width: 44,
            height: 44,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: _FileListLeadingPreview(file: file),
            ),
          ),
          const Gap(14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                file.name.isEmpty
                    ? Text(
                        'untitled',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                        ),
                      ).tr()
                    : Text(
                        file.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                        ),
                      ),
                const Gap(4),
                Text(
                  _fileMetaLine(file),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    height: 1.25,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const Gap(8),
          ..._buildIndexedFileActions(file, ref, context),
        ],
      ),
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
    return Padding(
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
      invalidateIndexedDriveViews(ref, tabId);

      showSnackBar('fileMoved'.tr());
    } catch (e) {
      showSnackBar('failedToMoveFile'.tr());
    } finally {
      if (context.mounted) {
        hideLoadingModal(context);
      }
    }
  }

  Widget _wrapIndexedDraggable({
    required BuildContext context,
    required SnCloudFile file,
    required Set<String> selectedIds,
    required bool isSelectionMode,
    required Widget child,
  }) {
    return _DriveDraggableTile(
      data: _resolveMoveDragData(
        file: file,
        selectedIds: selectedIds,
        isSelectionMode: isSelectionMode,
      ),
      child: child,
    );
  }

  Widget _wrapFolderDropTarget({
    required BuildContext context,
    required WidgetRef ref,
    required SnCloudFile folder,
    required Widget child,
  }) {
    return _DriveFolderDropTarget(
      folderId: folder.id,
      onAccept: (data) => _moveDriveItems(
        context: context,
        ref: ref,
        tabId: tabId,
        fileIds: data.fileIds,
        parentId: folder.id,
      ),
      child: child,
    );
  }

  Widget _wrapPathDropTarget({
    required BuildContext context,
    required WidgetRef ref,
    required String path,
    required Widget child,
  }) {
    return _DrivePathDropTarget(
      onAccept: (data) => _moveDriveItemsToPath(
        context: context,
        ref: ref,
        tabId: tabId,
        fileIds: data.fileIds,
        path: path,
      ),
      child: child,
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
}

/// Miller-column (Finder-style) browser for indexed drive folders.
class _DriveColumnBrowser extends HookConsumerWidget {
  final String tabId;
  final ValueNotifier<String> currentPath;
  final ValueNotifier<SnFilePool?> selectedPool;
  final DriveFileFilters filters;
  final String? query;
  final ValueNotifier<bool> isSelectionMode;
  final ValueNotifier<Set<String>> selectedFileIds;
  final ValueNotifier<Set<String>>? currentVisibleFileIds;
  final void Function(String path) onOpenFolderInNewTab;
  final void Function(SnCloudFile file) onInspectFile;
  final void Function(SnCloudFile file) onOpenFile;
  final VoidCallback onPickAndUpload;
  final VoidCallback onShowCreateFolder;
  final void Function(ValueNotifier<Set<String>> ids, SnCloudFile file)
  toggleSelection;

  const _DriveColumnBrowser({
    required this.tabId,
    required this.currentPath,
    required this.selectedPool,
    required this.filters,
    required this.query,
    required this.isSelectionMode,
    required this.selectedFileIds,
    required this.currentVisibleFileIds,
    required this.onOpenFolderInNewTab,
    required this.onInspectFile,
    required this.onOpenFile,
    required this.onPickAndUpload,
    required this.onShowCreateFolder,
    required this.toggleSelection,
  });

  static List<String> _columnPaths(String path) {
    final parts = path.split('/').where((p) => p.isNotEmpty).toList();
    final paths = <String>['/'];
    var built = '';
    for (final part in parts) {
      built += '/$part';
      paths.add(built);
    }
    return paths;
  }

  static String _joinPath(String parent, String name) {
    if (parent == '/' || parent.isEmpty) return '/$name';
    return '$parent/$name';
  }

  static String? _selectedNameAtDepth(String path, int columnIndex) {
    final parts = path.split('/').where((p) => p.isNotEmpty).toList();
    if (columnIndex >= parts.length) return null;
    return parts[columnIndex];
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final path = useValueListenable(currentPath);
    final pool = useValueListenable(selectedPool);
    final selectionMode = useValueListenable(isSelectionMode);
    final selectedIds = useValueListenable(selectedFileIds);
    final epoch = ref.watch(driveBrowserEpochProvider(tabId));
    final workspaceId = ref.watch(driveWorkspaceIdProvider(tabId));
    final focusedFileId = useState<String?>(null);
    final scrollController = useScrollController();

    final paths = _columnPaths(path);
    final columnWidth = isWideScreen(context) ? 280.0 : 240.0;

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!scrollController.hasClients) return;
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
        );
      });
      return null;
    }, [path, paths.length]);

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = columnWidth.clamp(200.0, constraints.maxWidth * 0.9);
        return ListView.separated(
          controller: scrollController,
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.only(left: 8, right: 8),
          itemCount: paths.length,
          separatorBuilder: (_, _) => VerticalDivider(
            width: 1,
            thickness: 1,
            color: theme.colorScheme.outlineVariant.withOpacity(0.55),
          ),
          itemBuilder: (context, columnIndex) {
            final columnPath = paths[columnIndex];
            final selectedName = _selectedNameAtDepth(path, columnIndex);
            final isLastColumn = columnIndex == paths.length - 1;
            return SizedBox(
              width: width,
              child: _DriveColumnPane(
                query: DriveBrowserPathKey(
                  path: columnPath,
                  poolId: pool?.id,
                  workspaceId: workspaceId,
                  order: filters.order,
                  orderDesc: filters.orderDesc,
                  isFolder: filters.isFolder,
                  contentType: filters.contentTypeParam,
                  extension: filters.extensionParam,
                  createdAfter: filters.createdAfterParam,
                  createdBefore: filters.createdBeforeParam,
                  query: query,
                  epoch: epoch,
                ),
                tabId: tabId,
                selectedName: selectedName,
                isLastColumn: isLastColumn,
                focusedFileId: focusedFileId.value,
                selectionMode: selectionMode,
                selectedIds: selectedIds,
                currentVisibleFileIds: currentVisibleFileIds,
                onPickAndUpload: onPickAndUpload,
                onShowCreateFolder: onShowCreateFolder,
                onMoveToFolder: (data, folder) => _moveDriveItems(
                  context: context,
                  ref: ref,
                  tabId: tabId,
                  fileIds: data.fileIds,
                  parentId: folder.id,
                ),
                onMoveToColumnPath: (data) => _moveDriveItemsToPath(
                  context: context,
                  ref: ref,
                  tabId: tabId,
                  fileIds: data.fileIds,
                  path: columnPath,
                ),
                onEntryTap: (file) {
                  if (selectionMode) {
                    toggleSelection(selectedFileIds, file);
                    return;
                  }
                  if (file.isFolder) {
                    focusedFileId.value = null;
                    final next = _joinPath(columnPath, file.name);
                    if (HardwareKeyboard.instance.isShiftPressed) {
                      onOpenFolderInNewTab(next);
                    } else {
                      currentPath.value = next;
                    }
                  } else {
                    focusedFileId.value = file.id;
                    currentPath.value = columnPath;
                    onOpenFile(file);
                  }
                },
                onEntryLongPress: (file) {
                  if (!selectionMode) {
                    isSelectionMode.value = true;
                  }
                  toggleSelection(selectedFileIds, file);
                },
                onInspect: onInspectFile,
              ),
            );
          },
        );
      },
    );
  }
}

class _DriveColumnPane extends HookConsumerWidget {
  final DriveBrowserPathKey query;
  final String tabId;
  final String? selectedName;
  final bool isLastColumn;
  final String? focusedFileId;
  final bool selectionMode;
  final Set<String> selectedIds;
  final ValueNotifier<Set<String>>? currentVisibleFileIds;
  final VoidCallback onPickAndUpload;
  final VoidCallback onShowCreateFolder;
  final Future<void> Function(_DriveMoveDragData data, SnCloudFile folder)
  onMoveToFolder;
  final Future<void> Function(_DriveMoveDragData data) onMoveToColumnPath;
  final void Function(SnCloudFile file) onEntryTap;
  final void Function(SnCloudFile file) onEntryLongPress;
  final void Function(SnCloudFile file) onInspect;

  const _DriveColumnPane({
    required this.query,
    required this.tabId,
    required this.selectedName,
    required this.isLastColumn,
    required this.focusedFileId,
    required this.selectionMode,
    required this.selectedIds,
    required this.currentVisibleFileIds,
    required this.onPickAndUpload,
    required this.onShowCreateFolder,
    required this.onMoveToFolder,
    required this.onMoveToColumnPath,
    required this.onEntryTap,
    required this.onEntryLongPress,
    required this.onInspect,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final asyncItems = ref.watch(driveBrowserPathProvider(query));

    // Publish visible ids after the frame so we never mutate during build.
    useEffect(() {
      if (!isLastColumn || currentVisibleFileIds == null) return null;
      final items = asyncItems.asData?.value;
      if (items == null) return null;
      final nextIds = items.map((f) => f.id).toSet();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final notifier = currentVisibleFileIds;
        if (notifier == null) return;
        if (!_setEquals(notifier.value, nextIds)) {
          _writeIfObserved(notifier, nextIds);
        }
      });
      return null;
    }, [isLastColumn, asyncItems, query.path, query.epoch]);

    return asyncItems.when(
      loading: () => Skeletonizer(
        enabled: true,
        effect: ShimmerEffect(
          baseColor: theme.colorScheme.surfaceContainerHigh,
          highlightColor: theme.colorScheme.surfaceContainerHighest,
        ),
        containersColor: theme.colorScheme.surfaceContainerLow,
        child: ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(vertical: 6),
          itemCount: 8,
          itemBuilder: (_, _) => const _ColumnSkeletonRow(),
        ),
      ),
      error: (e, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'failedToLoad'.tr(),
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
        ),
      ),
      data: (items) {
        if (items.isEmpty) {
          return _DrivePathDropTarget(
            onAccept: onMoveToColumnPath,
            child: _ColumnEmptyState(
              isRoot: query.path == '/',
              onPickAndUpload: onPickAndUpload,
              onShowCreateFolder: onShowCreateFolder,
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 6),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final file = items[index];
            final isFolder = file.isFolder;
            final isPathSelected = isFolder && selectedName == file.name;
            final isFileFocused = !isFolder && focusedFileId == file.id;
            final isMultiSelected = selectedIds.contains(file.id);
            final isHighlighted =
                isPathSelected ||
                isFileFocused ||
                (selectionMode && isMultiSelected);

            final tile = _ColumnEntryTile(
              file: file,
              isHighlighted: isHighlighted,
              isSelectionMode: selectionMode,
              isMultiSelected: isMultiSelected,
              onTap: () => onEntryTap(file),
              onLongPress: () => onEntryLongPress(file),
            );

            // Context menu outside Draggable so right-click is not eaten by drag.
            final withMenu = ContextMenuWidget(
              previewBuilder: contextMenuPreviewBuilder,
              menuProvider: (_) => _buildIndexedColumnMenu(
                context: context,
                ref: ref,
                tabId: tabId,
                file: file,
                onInspect: onInspect,
              ),
              child: _DriveDraggableTile(
                data: _resolveMoveDragData(
                  file: file,
                  selectedIds: selectedIds,
                  isSelectionMode: selectionMode,
                ),
                child: tile,
              ),
            );

            if (!isFolder) return withMenu;

            return _DriveFolderDropTarget(
              folderId: file.id,
              onAccept: (data) => onMoveToFolder(data, file),
              child: withMenu,
            );
          },
        );
      },
    );
  }
}

class _ColumnSkeletonRow extends StatelessWidget {
  const _ColumnSkeletonRow();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          const Gap(10),
          Expanded(
            child: Container(
              height: 12,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const Gap(12),
          Container(
            width: 36,
            height: 10,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }
}

bool _setEquals(Set<String> a, Set<String> b) {
  if (identical(a, b)) return true;
  if (a.length != b.length) return false;
  return a.containsAll(b);
}

class _ColumnEmptyState extends StatelessWidget {
  final bool isRoot;
  final VoidCallback onPickAndUpload;
  final VoidCallback onShowCreateFolder;

  const _ColumnEmptyState({
    required this.isRoot,
    required this.onPickAndUpload,
    required this.onShowCreateFolder,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Symbols.folder_off,
              size: 40,
              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.55),
            ),
            const Gap(12),
            Text(
              'thisDirectoryIsEmpty'.tr(),
              textAlign: TextAlign.center,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const Gap(6),
            Text(
              'emptyDirectoryHint'.tr(),
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (isRoot) ...[
              const Gap(16),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilledButton.tonalIcon(
                    onPressed: onPickAndUpload,
                    icon: const Icon(Symbols.upload_file, size: 18),
                    label: Text('uploadFiles'.tr()),
                  ),
                  OutlinedButton.icon(
                    onPressed: onShowCreateFolder,
                    icon: const Icon(Symbols.create_new_folder, size: 18),
                    label: Text('createDirectory'.tr()),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ColumnEntryTile extends ConsumerWidget {
  final SnCloudFile file;
  final bool isHighlighted;
  final bool isSelectionMode;
  final bool isMultiSelected;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _ColumnEntryTile({
    required this.file,
    required this.isHighlighted,
    required this.isSelectionMode,
    required this.isMultiSelected,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isFolder = file.isFolder;
    final highlightColor = theme.colorScheme.primary.withOpacity(
      theme.brightness == Brightness.dark ? 0.28 : 0.16,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      child: Material(
        color: isHighlighted ? highlightColor : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          onLongPress: onLongPress,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
            child: Row(
              children: [
                if (isSelectionMode) ...[
                  SizedBox(
                    width: 22,
                    height: 22,
                    child: Checkbox(
                      value: isMultiSelected,
                      onChanged: (_) => onTap(),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                  const Gap(6),
                ],
                SizedBox(
                  width: 28,
                  height: 28,
                  child: isFolder
                      ? Icon(
                          Symbols.folder,
                          fill: 1,
                          size: 22,
                          color: theme.colorScheme.primary,
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: _FileListLeadingPreview(file: file),
                        ),
                ),
                const Gap(10),
                Expanded(
                  child: Text(
                    file.name.isEmpty ? 'untitled'.tr() : file.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: isFolder ? FontWeight.w600 : FontWeight.w500,
                      fontStyle: file.name.isEmpty
                          ? FontStyle.italic
                          : FontStyle.normal,
                    ),
                  ),
                ),
                if (isFolder)
                  Icon(
                    Symbols.chevron_right,
                    size: 18,
                    color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
                  )
                else
                  Text(
                    formatFileSize(file.size),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DriveListTileSkeleton extends StatelessWidget {
  const _DriveListTileSkeleton();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const Gap(14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 14,
                    width: double.infinity,
                    margin: const EdgeInsets.only(right: 72),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const Gap(8),
                  Container(
                    height: 11,
                    width: 160,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
            const Gap(8),
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DriveFolderLeading extends StatelessWidget {
  const _DriveFolderLeading();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: 44,
      height: 44,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer.withOpacity(0.55),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          Symbols.folder,
          fill: 1,
          size: 24,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }
}

class _CompactIconButton extends StatelessWidget {
  final String tooltip;
  final IconData icon;
  final VoidCallback? onPressed;

  const _CompactIconButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      icon: Icon(icon, size: 22),
      visualDensity: VisualDensity.standard,
      padding: const EdgeInsets.all(8),
      constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
      onPressed: onPressed,
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
    final serverUrl = ref.watch(serverUrlProvider);
    final uri = file.storageUrl ?? '$serverUrl/drive/files/${file.id}';

    Widget preview = Container(
      color: colorScheme.surfaceContainerHighest,
      child: Center(child: getFileIcon(file, size: 18, tinyPreview: false)),
    );

    if (kind == 'image') {
      preview = UniversalImage(
        uri: uri,
        blurHash: file.blurhash,
        fit: BoxFit.cover,
      );
    } else if (kind == 'video') {
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
      final path = currentPath.value;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(_folderSelectorListProvider.notifier).setPath(path);
      });
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

class _DriveDraggableTile extends StatelessWidget {
  final _DriveMoveDragData data;
  final Widget child;

  const _DriveDraggableTile({required this.data, required this.child});

  Widget _feedback(BuildContext context) {
    final theme = Theme.of(context);
    final name = data.primaryName.isEmpty ? 'untitled'.tr() : data.primaryName;
    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(10),
      color: theme.colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              data.primaryIsFolder ? Symbols.folder : Symbols.draft,
              size: 20,
              color: theme.colorScheme.primary,
              fill: data.primaryIsFolder ? 1 : 0,
            ),
            const Gap(8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 200),
              child: Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (data.count > 1) ...[
              const Gap(8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '+${data.count - 1}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final feedback = _feedback(context);
    if (_preferLongPressDrag(context)) {
      return LongPressDraggable<_DriveMoveDragData>(
        data: data,
        feedback: feedback,
        childWhenDragging: Opacity(opacity: 0.35, child: child),
        child: child,
      );
    }
    return Draggable<_DriveMoveDragData>(
      data: data,
      feedback: feedback,
      childWhenDragging: Opacity(opacity: 0.35, child: child),
      child: child,
    );
  }
}

class _DriveFolderDropTarget extends StatelessWidget {
  final String folderId;
  final Future<void> Function(_DriveMoveDragData data) onAccept;
  final Widget child;

  const _DriveFolderDropTarget({
    required this.folderId,
    required this.onAccept,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DragTarget<_DriveMoveDragData>(
      onWillAcceptWithDetails: (details) {
        final ids = details.data.fileIds;
        if (ids.isEmpty) return false;
        // Don't drop a folder onto itself or include the target in a multi-move.
        return !ids.contains(folderId);
      },
      onAcceptWithDetails: (details) {
        onAccept(details.data);
      },
      builder: (context, candidateData, rejectedData) {
        final hovering = candidateData.isNotEmpty;
        if (!hovering) return child;
        return DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.colorScheme.primary, width: 2),
            color: theme.colorScheme.primaryContainer.withOpacity(0.35),
          ),
          child: child,
        );
      },
    );
  }
}

class _DrivePathDropTarget extends StatelessWidget {
  final Future<void> Function(_DriveMoveDragData data) onAccept;
  final Widget child;

  const _DrivePathDropTarget({required this.onAccept, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DragTarget<_DriveMoveDragData>(
      onWillAcceptWithDetails: (details) => details.data.fileIds.isNotEmpty,
      onAcceptWithDetails: (details) {
        onAccept(details.data);
      },
      builder: (context, candidateData, rejectedData) {
        final hovering = candidateData.isNotEmpty;
        if (!hovering) return child;
        return DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: theme.colorScheme.primary, width: 1.5),
            color: theme.colorScheme.primaryContainer.withOpacity(0.4),
          ),
          child: child,
        );
      },
    );
  }
}
