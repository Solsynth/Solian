import 'dart:async';
import 'dart:io';

import 'package:animations/animations.dart';
import 'package:cross_file/cross_file.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/utils/format.dart';
import 'package:island/core/utils/share_utils.dart';
import 'package:island/drive/screens/file_list.dart';
import 'package:island/drive/drive_service.dart';
import 'package:island/core/config.dart';
import 'package:island/core/network.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/shared/widgets/app_scaffold.dart';
import 'package:island/core/widgets/content/cloud_file_actions_sheet.dart';
import 'package:island/core/widgets/content/file_viewer_contents.dart';
import 'package:island/shared/widgets/layouts/sheet_scaffold.dart';
import 'package:island/shared/widgets/responsive_sidebar.dart';
import 'package:island/drive/widgets/file_list_view.dart';
import 'package:island/core/widgets/content/file_info_sheet.dart';
import 'package:island/drive/file_permissions.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:super_context_menu/super_context_menu.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';
import 'package:island/drive/widgets/usage_overview.dart';

class _DriveFileTab {
  final String id;
  final FileListMode mode;
  final SnCloudFile? file;

  const _DriveFileTab({required this.id, required this.mode, this.file});
}

@RoutePage()
class FileListScreen extends HookConsumerWidget {
  const FileListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usageAsync = ref.watch(billingUsageProvider);
    final quotaAsync = ref.watch(billingQuotaProvider);

    final tabs = useState<List<_DriveFileTab>>([]);
    final activeTabId = useState<String?>(null);
    final showSidebar = useState<bool>(false);
    final showFilters = useState(true);
    final dragging = useState(false);
    final searchDebounceTimer = useRef<Timer?>(null);

    final pathStates = useMemoized(() => <String, ValueNotifier<String>>{});
    final modeStates = useMemoized(
      () => <String, ValueNotifier<FileListMode>>{},
    );
    final poolStates = useMemoized(
      () => <String, ValueNotifier<SnFilePool?>>{},
    );
    final viewModeStates = useMemoized(
      () => <String, ValueNotifier<FileListViewMode>>{},
    );
    final selectionModeStates = useMemoized(
      () => <String, ValueNotifier<bool>>{},
    );
    final selectedFileIdsStates = useMemoized(
      () => <String, ValueNotifier<Set<String>>>{},
    );
    final visibleFileIdsStates = useMemoized(
      () => <String, ValueNotifier<Set<String>>>{},
    );
    final recycledStates = useMemoized(() => <String, ValueNotifier<bool>>{});
    final queryStates = useMemoized(() => <String, ValueNotifier<String?>>{});
    final fallbackPath = useMemoized(() => ValueNotifier('/'));
    final fallbackMode = useMemoized(() => ValueNotifier(FileListMode.normal));
    final fallbackPool = useMemoized(() => ValueNotifier<SnFilePool?>(null));
    final fallbackSelectionMode = useMemoized(() => ValueNotifier(false));
    final fallbackSelectedFileIds = useMemoized(
      () => ValueNotifier(<String>{}),
    );
    final fallbackVisibleFileIds = useMemoized(() => ValueNotifier(<String>{}));
    final fallbackRecycled = useMemoized(() => ValueNotifier(false));
    final fallbackQuery = useMemoized(() => ValueNotifier<String?>(null));

    void createTab(FileListMode mode) {
      final id = DateTime.now().microsecondsSinceEpoch.toString();
      tabs.value = [...tabs.value, _DriveFileTab(id: id, mode: mode)];
      activeTabId.value = id;
      pathStates[id] = ValueNotifier('/');
      modeStates[id] = ValueNotifier(mode);
      poolStates[id] = ValueNotifier(null);
      viewModeStates[id] = ValueNotifier(
        mode == FileListMode.normal
            ? FileListViewMode.columns
            : FileListViewMode.list,
      );
      selectionModeStates[id] = ValueNotifier(false);
      selectedFileIdsStates[id] = ValueNotifier(<String>{});
      visibleFileIdsStates[id] = ValueNotifier(<String>{});
      recycledStates[id] = ValueNotifier(false);
      queryStates[id] = ValueNotifier(null);
    }

    void openFileTab(SnCloudFile file) {
      final existing = tabs.value
          .where((tab) => tab.file?.id == file.id)
          .firstOrNull;
      if (existing != null) {
        activeTabId.value = existing.id;
        return;
      }

      final id = DateTime.now().microsecondsSinceEpoch.toString();
      tabs.value = [
        ...tabs.value,
        _DriveFileTab(id: id, mode: FileListMode.normal, file: file),
      ];
      activeTabId.value = id;
    }

    void openFolderTab(String path) {
      final normalizedPath = path.trim().isEmpty ? '/' : path;
      final existing = tabs.value
          .where((tab) => tab.file == null && tab.mode == FileListMode.normal)
          .where((tab) => pathStates[tab.id]?.value == normalizedPath)
          .firstOrNull;
      if (existing != null) {
        activeTabId.value = existing.id;
        return;
      }

      final id = DateTime.now().microsecondsSinceEpoch.toString();
      tabs.value = [
        ...tabs.value,
        _DriveFileTab(id: id, mode: FileListMode.normal),
      ];
      activeTabId.value = id;
      pathStates[id] = ValueNotifier(normalizedPath);
      modeStates[id] = ValueNotifier(FileListMode.normal);
      poolStates[id] = ValueNotifier(null);
      viewModeStates[id] = ValueNotifier(FileListViewMode.columns);
      selectionModeStates[id] = ValueNotifier(false);
      selectedFileIdsStates[id] = ValueNotifier(<String>{});
      visibleFileIdsStates[id] = ValueNotifier(<String>{});
      recycledStates[id] = ValueNotifier(false);
      queryStates[id] = ValueNotifier(null);
    }

    Future<void> revealParentFolder(SnCloudFile file) async {
      String? currentParentId = file.parentId;
      if (currentParentId == null || currentParentId.isEmpty) {
        openFolderTab('/');
        return;
      }

      final segments = <String>[];
      while (currentParentId != null && currentParentId.isNotEmpty) {
        final parent = await ref.read(
          driveFileInfoProvider(currentParentId).future,
        );
        segments.add(parent.name);
        currentParentId = parent.parentId;
      }

      final path = segments.reversed.join('/');
      openFolderTab(path.isEmpty ? '/' : '/$path');
    }

    void updateFileTab(SnCloudFile file) {
      final index = tabs.value.indexWhere((tab) => tab.file?.id == file.id);
      if (index == -1) return;

      final nextTabs = [...tabs.value];
      nextTabs[index] = _DriveFileTab(
        id: nextTabs[index].id,
        mode: nextTabs[index].mode,
        file: file,
      );
      tabs.value = nextTabs;
    }

    void closeTab(String tabId) {
      final currentTabs = tabs.value;
      final closingIndex = currentTabs.indexWhere((tab) => tab.id == tabId);
      if (closingIndex == -1) return;

      tabs.value = currentTabs.where((tab) => tab.id != tabId).toList();
      pathStates.remove(tabId)?.dispose();
      modeStates.remove(tabId)?.dispose();
      poolStates.remove(tabId)?.dispose();
      viewModeStates.remove(tabId)?.dispose();
      selectionModeStates.remove(tabId)?.dispose();
      selectedFileIdsStates.remove(tabId)?.dispose();
      visibleFileIdsStates.remove(tabId)?.dispose();
      recycledStates.remove(tabId)?.dispose();
      queryStates.remove(tabId)?.dispose();
      invalidateIndexedDriveViews(ref, tabId);
      ref.invalidate(unindexedFileListFamilyProvider(tabId));

      if (activeTabId.value != tabId) return;
      final remainingTabs = tabs.value;
      if (remainingTabs.isEmpty) {
        activeTabId.value = null;
        ref.read(driveInspectorFileProvider.notifier).setFile(null);
        return;
      }

      final nextIndex = closingIndex >= remainingTabs.length
          ? remainingTabs.length - 1
          : closingIndex;
      activeTabId.value = remainingTabs[nextIndex].id;
    }

    /// Uses [ReorderableListView.onReorderItem], which already adjusts
    /// [newIndex] for the removed item (no manual `newIndex -= 1`).
    void reorderTab(int oldIndex, int newIndex) {
      final currentTabs = [...tabs.value];
      final tab = currentTabs.removeAt(oldIndex);
      currentTabs.insert(newIndex, tab);
      tabs.value = currentTabs;
    }

    useEffect(() {
      return () {
        for (final notifier in pathStates.values) {
          notifier.dispose();
        }
        for (final notifier in modeStates.values) {
          notifier.dispose();
        }
        for (final notifier in poolStates.values) {
          notifier.dispose();
        }
        for (final notifier in viewModeStates.values) {
          notifier.dispose();
        }
        for (final notifier in selectionModeStates.values) {
          notifier.dispose();
        }
        for (final notifier in selectedFileIdsStates.values) {
          notifier.dispose();
        }
        for (final notifier in visibleFileIdsStates.values) {
          notifier.dispose();
        }
        for (final notifier in recycledStates.values) {
          notifier.dispose();
        }
        for (final notifier in queryStates.values) {
          notifier.dispose();
        }
      };
    }, const []);

    final activeTab = activeTabId.value == null
        ? null
        : tabs.value.where((tab) => tab.id == activeTabId.value).firstOrNull;
    final currentPath = activeTab == null ? null : pathStates[activeTab.id];
    final mode = activeTab == null ? null : modeStates[activeTab.id];
    final selectedPool = activeTab == null ? null : poolStates[activeTab.id];
    final viewMode = activeTab == null ? null : viewModeStates[activeTab.id];
    final isSelectionMode = activeTab == null
        ? null
        : selectionModeStates[activeTab.id];
    final selectedFileIds = activeTab == null
        ? null
        : selectedFileIdsStates[activeTab.id];
    final visibleFileIds = activeTab == null
        ? null
        : visibleFileIdsStates[activeTab.id];
    final recycled = activeTab == null ? null : recycledStates[activeTab.id];
    final query = activeTab == null ? null : queryStates[activeTab.id];
    final currentPathValue = useValueListenable(currentPath ?? fallbackPath);
    final modeValue = useValueListenable(mode ?? fallbackMode);
    final selectedPoolValue = useValueListenable(selectedPool ?? fallbackPool);
    final isSelectionModeValue = useValueListenable(
      isSelectionMode ?? fallbackSelectionMode,
    );
    final selectedFileIdsValue = useValueListenable(
      selectedFileIds ?? fallbackSelectedFileIds,
    );
    final visibleFileIdsValue = useValueListenable(
      visibleFileIds ?? fallbackVisibleFileIds,
    );
    final recycledValue = useValueListenable(recycled ?? fallbackRecycled);
    final queryValue = useValueListenable(query ?? fallbackQuery);
    final searchController = useTextEditingController(text: queryValue ?? '');
    final indexedListState = activeTab == null
        ? null
        : ref.watch(indexedCloudFileListFamilyProvider(activeTab.id));
    final unindexedListState = activeTab == null
        ? null
        : ref.watch(unindexedFileListFamilyProvider(activeTab.id));
    final activeTotalCount = switch (modeValue) {
      FileListMode.normal => indexedListState?.asData?.value.totalCount,
      FileListMode.unindexed => unindexedListState?.asData?.value.totalCount,
    };

    useEffect(() {
      final nextText = queryValue ?? '';
      if (searchController.text == nextText) return null;
      searchController.value = TextEditingValue(
        text: nextText,
        selection: TextSelection.collapsed(offset: nextText.length),
      );
      return null;
    }, [queryValue]);

    useEffect(() {
      return () {
        searchDebounceTimer.value?.cancel();
      };
    }, const []);

    // Notifiers should be read fresh each time to avoid disposal issues

    // Sidebar content widget
    final inspectorFile = ref.watch(driveInspectorFileProvider);

    final sidebarContent = inspectorFile == null
        ? const SizedBox.shrink()
        : FileInfoSheet(
            item: inspectorFile,
            key: ValueKey(inspectorFile.id),
            onClose: () {
              ref.read(driveInspectorFileProvider.notifier).setFile(null);
              showSidebar.value = false;
            },
          );

    // Drawer builder for narrow screens - uses builder to access providers
    Consumer drawerBuilder(BuildContext sheetContext) {
      return Consumer(
        builder: (context, ref, _) {
          final inspector = ref.watch(driveInspectorFileProvider);
          if (inspector != null) {
            return FileInfoSheet(
              item: inspector,
              onClose: () {
                ref.read(driveInspectorFileProvider.notifier).setFile(null);
                Navigator.of(sheetContext).pop();
              },
            );
          }
          return const SizedBox.shrink();
        },
      );
    }

    // Main content widget
    final bodyContent = usageAsync.when(
      data: (usage) => quotaAsync.when(
        data: (quota) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _DriveTabStrip(
                    tabs: tabs.value,
                    activeTabId: activeTabId.value,
                    getTabTitle: (tab) {
                      if (tab.file != null) {
                        return tab.file!.name;
                      }
                      if (tab.mode == FileListMode.unindexed) {
                        return 'driveUnindexedTabTitle'.tr();
                      }
                      final path = pathStates[tab.id]?.value ?? '/';
                      if (path == '/') return 'driveIndexedTabTitle'.tr();
                      return path
                          .split('/')
                          .where((part) => part.isNotEmpty)
                          .last;
                    },
                    onRenameFile: updateFileTab,
                    onRevealParentFolder: revealParentFolder,
                    onSelectTab: (tabId) => activeTabId.value = tabId,
                    onCloseTab: closeTab,
                    onReorderTab: reorderTab,
                    onAddIndexedTab: () => createTab(FileListMode.normal),
                    onAddUnindexedTab: () => createTab(FileListMode.unindexed),
                    onRefresh: activeTab == null || activeTab.file != null
                        ? null
                        : () async {
                            if (modeValue == FileListMode.unindexed) {
                              await ref
                                  .read(
                                    unindexedFileListFamilyProvider(
                                      activeTab.id,
                                    ).notifier,
                                  )
                                  .refresh();
                            } else {
                              await ref
                                  .read(
                                    indexedCloudFileListFamilyProvider(
                                      activeTab.id,
                                    ).notifier,
                                  )
                                  .refresh();
                              bumpDriveBrowserEpoch(ref, activeTab.id);
                            }
                          },
                    onNewFolder:
                        activeTab == null ||
                            activeTab.file != null ||
                            modeValue != FileListMode.normal ||
                            currentPath == null ||
                            selectedPool == null
                        ? null
                        : () => _showCreateFolderDialog(
                            context,
                            ref,
                            activeTab.id,
                            currentPathValue,
                            selectedPoolValue?.id,
                          ),
                    onUpload:
                        activeTab == null ||
                            activeTab.file != null ||
                            modeValue != FileListMode.normal ||
                            currentPath == null ||
                            selectedPool == null
                        ? null
                        : () => _pickAndUploadFile(
                            ref,
                            activeTab.id,
                            currentPathValue,
                            selectedPoolValue?.id,
                          ),
                    uploadIsAsset: modeValue == FileListMode.unindexed,
                  ),
                  Expanded(
                    child: PageTransitionSwitcher(
                      reverse: false,
                      transitionBuilder:
                          (
                            Widget child,
                            Animation<double> primaryAnimation,
                            Animation<double> secondaryAnimation,
                          ) {
                            return SharedAxisTransition(
                              animation: primaryAnimation,
                              secondaryAnimation: secondaryAnimation,
                              transitionType:
                                  SharedAxisTransitionType.horizontal,
                              child: child,
                            );
                          },
                      child: activeTab == null
                          ? _DriveWorkspaceEmptyState(
                              key: const ValueKey('empty'),
                              onOpenIndexed: () =>
                                  createTab(FileListMode.normal),
                              onOpenUnindexed: () =>
                                  createTab(FileListMode.unindexed),
                            )
                          : activeTab.file != null
                          ? _DriveFileContentTab(
                              key: ValueKey(activeTab.id),
                              file: activeTab.file!,
                              onInspectFile: (file) {
                                ref
                                    .read(driveInspectorFileProvider.notifier)
                                    .setFile(file);
                                showSidebar.value = true;
                              },
                            )
                          : currentPath == null ||
                                selectedPool == null ||
                                mode == null ||
                                viewMode == null ||
                                isSelectionMode == null ||
                                query == null
                          ? _DriveWorkspaceEmptyState(
                              key: const ValueKey('empty'),
                              onOpenIndexed: () =>
                                  createTab(FileListMode.normal),
                              onOpenUnindexed: () =>
                                  createTab(FileListMode.unindexed),
                            )
                          : FileListView(
                              key: ValueKey(activeTab.id),
                              tabId: activeTab.id,
                              usage: usage,
                              quota: quota,
                              currentPath: currentPath,
                              selectedPool: selectedPool,
                              showFilters: showFilters.value,
                              onOpenFolderInNewTab: openFolderTab,
                              onPickAndUpload: () => _pickAndUploadFile(
                                ref,
                                activeTab.id,
                                currentPathValue,
                                selectedPoolValue?.id,
                              ),
                              onShowCreateFolder: () => _showCreateFolderDialog(
                                context,
                                ref,
                                activeTab.id,
                                currentPathValue,
                                selectedPoolValue?.id,
                              ),
                              onInspectFile: (file) {
                                ref
                                    .read(driveInspectorFileProvider.notifier)
                                    .setFile(file);
                                showSidebar.value = true;
                              },
                              onOpenFile: openFileTab,
                              selectedFileIds: selectedFileIds,
                              currentVisibleFileIds: visibleFileIds,
                              mode: mode,
                              viewMode: viewMode,
                              isSelectionMode: isSelectionMode,
                              query: query,
                            ),
                    ),
                  ),
                ],
              ),
            ),
            isSelectionModeValue
                ? _DriveSelectionStatusBar(
                    selectionCount: selectedFileIdsValue.length,
                    allVisibleSelected:
                        visibleFileIdsValue.isNotEmpty &&
                        visibleFileIdsValue
                            .difference(selectedFileIdsValue)
                            .isEmpty,
                    onCancel: () {
                      selectedFileIds?.value = <String>{};
                      isSelectionMode?.value = false;
                    },
                    onToggleSelectAll: () {
                      if (visibleFileIds == null || selectedFileIds == null) {
                        return;
                      }
                      if (visibleFileIdsValue.isEmpty) return;
                      final allSelected = visibleFileIdsValue
                          .difference(selectedFileIdsValue)
                          .isEmpty;
                      if (allSelected) {
                        selectedFileIds.value = selectedFileIdsValue.difference(
                          visibleFileIdsValue,
                        );
                      } else {
                        selectedFileIds.value = {
                          ...selectedFileIdsValue,
                          ...visibleFileIdsValue,
                        };
                      }
                    },
                    onDownload: selectedFileIdsValue.isEmpty
                        ? null
                        : () async {
                            final files = await _resolveSelectedFiles(
                              ref,
                              selectedFileIdsValue,
                            );
                            if (files.isEmpty) return;
                            await ref
                                .read(driveFileDownloaderProvider)
                                .downloadFiles(
                                  files,
                                  useDownloadsFolder:
                                      HardwareKeyboard.instance.isShiftPressed,
                                );
                          },
                    onDelete: selectedFileIdsValue.isEmpty
                        ? null
                        : () async {
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
                                selectedFileIdsValue.toList(),
                              );
                              selectedFileIds?.value = <String>{};
                              visibleFileIds?.value = <String>{};
                              isSelectionMode?.value = false;
                              if (modeValue == FileListMode.normal) {
                                invalidateIndexedDriveViews(ref, activeTab!.id);
                              } else {
                                ref.invalidate(
                                  unindexedFileListFamilyProvider(
                                    activeTab!.id,
                                  ),
                                );
                              }
                              showSnackBar(
                                'deletedFilesCount'.tr(
                                  args: [count.toString()],
                                ),
                              );
                            } catch (e) {
                              showSnackBar('failedToDeleteSelectedFiles'.tr());
                            } finally {
                              if (context.mounted) {
                                hideLoadingModal(context);
                              }
                            }
                          },
                  )
                : _DriveStorageStatusBar(
                    usage: usage,
                    quota: quota,
                    totalMatches: activeTab?.file == null
                        ? activeTotalCount
                        : null,
                    onTapDetails: () => _showUsageSheet(context, usage, quota),
                  ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('errorLoadingQuota'.tr())),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('errorLoadingUsage'.tr())),
    );

    // Accept desktop file/folder drops on folder browser tabs (not file preview).
    final canAcceptDrops =
        activeTab != null &&
        activeTab.file == null &&
        modeValue == FileListMode.normal;

    final droppableBody = canAcceptDrops
        ? DropTarget(
            onDragEntered: (_) => dragging.value = true,
            onDragExited: (_) => dragging.value = false,
            onDragDone: (details) async {
              dragging.value = false;
              if (details.files.isEmpty ||
                  currentPath == null ||
                  selectedPool == null) {
                return;
              }
              await _uploadDroppedFiles(
                ref,
                activeTab.id,
                currentPath.value,
                selectedPool.value?.id,
                details.files,
              );
            },
            child: Stack(
              fit: StackFit.expand,
              children: [
                bodyContent,
                if (dragging.value)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: Container(
                        color: Theme.of(
                          context,
                        ).colorScheme.primaryContainer.withOpacity(0.9),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Symbols.upload_file,
                                size: 64,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const Gap(16),
                              Text(
                                'dropFilesHere'.tr(),
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const Gap(8),
                              Text(
                                'dragAndDropToAttach'.tr(),
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          )
        : bodyContent;

    final mainContent = AppScaffold(
      isNoBackground: false,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Symbols.menu),
          onPressed: () {
            rootScaffoldKey.currentState?.openDrawer();
          },
        ),
        title: SearchBar(
          controller: searchController,
          constraints: const BoxConstraints(maxWidth: 400, minHeight: 32),
          hintText: 'searchFiles'.tr(),
          hintStyle: const WidgetStatePropertyAll(TextStyle(fontSize: 14)),
          textStyle: const WidgetStatePropertyAll(TextStyle(fontSize: 14)),
          enabled: query != null,
          onChanged: (value) {
            if (query == null) return;
            searchDebounceTimer.value?.cancel();
            searchDebounceTimer.value = Timer(
              const Duration(milliseconds: 300),
              () {
                query.value = value.isEmpty ? null : value;
              },
            );
          },
          leading: Icon(
            Symbols.search,
            size: 20,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        actions: [
          // Filter panel toggle (file browser tabs only)
          IconButton(
            icon: Icon(
              showFilters.value ? Symbols.filter_list_off : Symbols.filter_list,
            ),
            onPressed: activeTab == null || activeTab.file != null
                ? null
                : () => showFilters.value = !showFilters.value,
            tooltip: showFilters.value
                ? 'hideFilters'.tr()
                : 'showFilters'.tr(),
          ),

          // Selection mode toggle
          IconButton(
            icon: Icon(
              isSelectionModeValue ? Symbols.close : Symbols.select_check_box,
            ),
            onPressed: isSelectionMode == null
                ? null
                : () => isSelectionMode.value = !isSelectionMode.value,
            tooltip: isSelectionModeValue
                ? 'exitSelectionMode'.tr()
                : 'enterSelectionMode'.tr(),
          ),

          // Recycle toggle (only in unindexed mode)
          if (modeValue == FileListMode.unindexed)
            IconButton(
              icon: Icon(
                recycledValue
                    ? Symbols.delete_forever
                    : Symbols.restore_from_trash,
              ),
              onPressed: () {
                if (recycled == null || activeTab == null) return;
                recycled.value = !recycled.value;
                ref
                    .read(
                      unindexedFileListFamilyProvider(activeTab.id).notifier,
                    )
                    .setRecycled(recycled.value);
              },
              tooltip: recycledValue
                  ? 'showActiveFiles'.tr()
                  : 'showRecycleBin'.tr(),
            ),

          const Gap(8),
        ],
      ),
      floatingActionButton:
          modeValue == FileListMode.normal &&
              activeTab != null &&
              currentPath != null &&
              selectedPool != null
          ? FloatingActionButton(
              onPressed: () => _showActionBottomSheet(
                context,
                ref,
                activeTab.id,
                currentPath,
                selectedPool,
              ),
              tooltip: 'addFilesOrCreateDirectory'.tr(),
              child: const Icon(Symbols.add),
            ).padding(bottom: 56 + MediaQuery.paddingOf(context).bottom)
          : null,
      body: droppableBody,
    );

    return ResponsiveSidebar(
      showSidebar: showSidebar,
      sidebarWidth: 320,
      minWideSidebarWidth: 280,
      maxWideSidebarWidth: 400,
      sidebarContent: sidebarContent,
      drawerBuilder: drawerBuilder,
      mainContent: mainContent,
    );
  }

  Future<void> _pickAndUploadFile(
    WidgetRef ref,
    String tabId,
    String currentPath,
    String? poolId,
  ) async {
    try {
      final result = await FilePicker.pickFiles(
        allowMultiple: true,
        withData: false,
      );

      if (result != null && result.files.isNotEmpty) {
        await _uploadDroppedFiles(
          ref,
          tabId,
          currentPath,
          poolId,
          result.files
              .where((file) => file.path != null)
              .map((file) => XFile(file.path!, name: file.name))
              .toList(),
        );
      }
    } catch (e) {
      showSnackBar('errorPickingFile'.tr(args: [e.toString()]));
    }
  }

  Future<void> _pickAndUploadFolder(
    WidgetRef ref,
    String tabId,
    String currentPath,
    String? poolId,
  ) async {
    try {
      final folderPath = await FilePicker.getDirectoryPath(
        dialogTitle: 'uploadFolder'.tr(),
      );
      if (folderPath == null || folderPath.isEmpty) return;
      await _uploadLocalDirectory(ref, tabId, currentPath, poolId, folderPath);
    } catch (e) {
      showSnackBar('failedToUploadFolder'.tr(args: [e.toString()]));
    }
  }

  Future<void> _ensureDriveDirectoryPath(
    WidgetRef ref,
    String drivePath,
    String? poolId,
  ) async {
    final normalizedPath = drivePath.trim();
    if (normalizedPath.isEmpty || normalizedPath == '/') return;

    final uploader = ref.read(driveFileUploaderProvider);
    final driveApi = ref.read(solarNetworkClientProvider).drive;
    final segments = normalizedPath
        .split('/')
        .where((segment) => segment.isNotEmpty)
        .toList();

    var currentPath = '';
    for (final segment in segments) {
      final nextPath = '$currentPath/$segment';
      try {
        await uploader.resolveParentIdFromPath(path: nextPath, poolId: poolId);
      } catch (_) {
        final parentId = currentPath.isEmpty
            ? null
            : await uploader.resolveParentIdFromPath(
                path: currentPath,
                poolId: poolId,
              );
        await driveApi.createFolder(name: segment, parentId: parentId);
      }
      currentPath = nextPath;
    }
  }

  Future<void> _uploadLocalDirectory(
    WidgetRef ref,
    String tabId,
    String currentPath,
    String? poolId,
    String rootDirectoryPath,
  ) async {
    final rootDirectory = Directory(rootDirectoryPath);
    if (!await rootDirectory.exists()) return;

    final entities = await rootDirectory
        .list(recursive: true, followLinks: false)
        .toList();
    final files = entities.whereType<File>().toList();
    if (files.isEmpty) return;

    final rootName = rootDirectory.uri.pathSegments
        .where((segment) => segment.isNotEmpty)
        .lastOrNull;
    final baseDrivePath = rootName == null || rootName.isEmpty
        ? currentPath
        : (currentPath == '/' ? '/$rootName' : '$currentPath/$rootName');

    await _ensureDriveDirectoryPath(ref, baseDrivePath, poolId);

    for (final file in files) {
      final relativePath = file.path.substring(rootDirectory.path.length);
      final normalizedRelative = relativePath
          .replaceAll('\\', '/')
          .replaceFirst(RegExp(r'^/+'), '');
      final parts = normalizedRelative
          .split('/')
          .where((part) => part.isNotEmpty)
          .toList();
      if (parts.isEmpty) continue;

      final fileName = parts.last;
      final nestedFolders = parts.take(parts.length - 1).toList();
      final targetPath = nestedFolders.isEmpty
          ? baseDrivePath
          : '$baseDrivePath/${nestedFolders.join('/')}';

      await _ensureDriveDirectoryPath(ref, targetPath, poolId);

      final completer = ref
          .read(driveFileUploaderProvider)
          .createCloudFile(
            fileData: UniversalFile(
              data: XFile(file.path, name: fileName),
              type: UniversalFileType.file,
              displayName: fileName,
            ),
            path: targetPath,
            poolId: poolId,
            onProgress: (progress, _) {
              if (progress != null) {
                debugPrint('Upload progress: ${(progress * 100).toInt()}%');
              }
            },
          );

      completer.future.catchError((error) {
        showSnackBar('failedToUploadFile'.tr(args: [error.toString()]));
        return null;
      });
    }

    invalidateIndexedDriveViews(ref, tabId);
  }

  Future<void> _uploadDroppedFiles(
    WidgetRef ref,
    String tabId,
    String currentPath,
    String? poolId,
    List<XFile> files,
  ) async {
    if (files.isEmpty) return;

    for (final file in files) {
      if (!kIsWeb && file.path.isNotEmpty) {
        final stat = await FileSystemEntity.type(file.path);
        if (stat == FileSystemEntityType.directory) {
          await _uploadLocalDirectory(
            ref,
            tabId,
            currentPath,
            poolId,
            file.path,
          );
          continue;
        }
      }

      final displayName = file.name.isNotEmpty ? file.name : null;
      final universalFile = UniversalFile(
        data: file,
        type: UniversalFileType.file,
        displayName: displayName,
      );

      final completer = ref
          .read(driveFileUploaderProvider)
          .createCloudFile(
            fileData: universalFile,
            path: currentPath,
            poolId: poolId,
            onProgress: (progress, _) {
              if (progress != null) {
                debugPrint('Upload progress: ${(progress * 100).toInt()}%');
              }
            },
          );

      completer.future
          .then((uploadedFile) {
            if (uploadedFile != null) {
              invalidateIndexedDriveViews(ref, tabId);
            }
          })
          .catchError((error) {
            showSnackBar('failedToUploadFile'.tr(args: [error.toString()]));
          });
    }
  }

  Future<List<SnCloudFile>> _resolveSelectedFiles(
    WidgetRef ref,
    Set<String> selectedIds,
  ) async {
    final files = <SnCloudFile>[];
    for (final id in selectedIds) {
      try {
        files.add(await ref.read(driveFileInfoProvider(id).future));
      } catch (_) {
        // Skip files that can no longer be resolved.
      }
    }
    return files;
  }

  Future<void> _showCreateFolderDialog(
    BuildContext context,
    WidgetRef ref,
    String tabId,
    String currentPath,
    String? poolId,
  ) async {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    bool isCreating = false;

    await showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('createNewFolder').tr(),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'folderName'.tr(),
                hintText: 'folderNameHint'.tr(),
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
              ),
              autofocus: true,
              enabled: !isCreating,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'folderNameRequired'.tr();
                }
                if (value.contains(RegExp(r'[/\\:*?"<>|]'))) {
                  return 'folderNameInvalid'.tr();
                }
                if (value.length > 255) {
                  return 'folderNameTooLong'.tr();
                }
                return null;
              },
              onFieldSubmitted: (_) async {
                if (formKey.currentState!.validate()) {
                  setState(() => isCreating = true);
                  try {
                    final driveApi = ref.read(solarNetworkClientProvider).drive;
                    final uploader = ref.read(driveFileUploaderProvider);
                    final parentId = await uploader.resolveParentIdFromPath(
                      path: currentPath,
                      poolId: poolId,
                    );
                    await driveApi.createFolder(
                      name: nameController.text.trim(),
                      parentId: parentId,
                    );
                    if (dialogContext.mounted) {
                      Navigator.of(dialogContext).pop();
                    }
                    invalidateIndexedDriveViews(ref, tabId);
                    showSnackBar('folderCreated'.tr());
                  } catch (e) {
                    if (context.mounted) {
                      setState(() => isCreating = false);
                      showSnackBar(
                        'folderCreationFailed'.tr(args: [e.toString()]),
                      );
                    }
                  }
                }
              },
              onTapOutside: (_) =>
                  FocusManager.instance.primaryFocus?.unfocus(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: isCreating ? null : () => Navigator.of(context).pop(),
              child: Text('cancel').tr(),
            ),
            TextButton.icon(
              onPressed: isCreating
                  ? null
                  : () async {
                      if (!formKey.currentState!.validate()) return;
                      setState(() => isCreating = true);
                      try {
                        final driveApi = ref
                            .read(solarNetworkClientProvider)
                            .drive;
                        final uploader = ref.read(driveFileUploaderProvider);
                        final parentId = await uploader.resolveParentIdFromPath(
                          path: currentPath,
                          poolId: poolId,
                        );
                        await driveApi.createFolder(
                          name: nameController.text.trim(),
                          parentId: parentId,
                        );
                        if (dialogContext.mounted) {
                          Navigator.of(dialogContext).pop();
                        }
                        invalidateIndexedDriveViews(ref, tabId);
                        showSnackBar('folderCreated'.tr());
                      } catch (e) {
                        if (context.mounted) {
                          setState(() => isCreating = false);
                          showSnackBar(
                            'folderCreationFailed'.tr(args: [e.toString()]),
                          );
                        }
                      }
                    },
              label: isCreating
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text('createDirectory').tr(),
              icon: const Icon(Symbols.create_new_folder),
            ),
          ],
        ),
      ),
    );
  }

  void _showUsageSheet(
    BuildContext context,
    Map<String, dynamic>? usage,
    Map<String, dynamic>? quota,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => SheetScaffold(
        titleText: 'usageOverview'.tr(),
        child: UsageOverviewWidget(
          usage: usage,
          quota: quota,
        ).padding(horizontal: 8, vertical: 16),
      ),
    );
  }

  void _showActionBottomSheet(
    BuildContext context,
    WidgetRef ref,
    String tabId,
    ValueNotifier<String> currentPath,
    ValueNotifier<SnFilePool?> selectedPool,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Symbols.create_new_folder),
              title: Text('createDirectory').tr(),
              onTap: () {
                Navigator.of(context).pop();
                _showCreateFolderDialog(
                  context,
                  ref,
                  tabId,
                  currentPath.value,
                  selectedPool.value?.id,
                );
              },
            ),
            ListTile(
              leading: const Icon(Symbols.upload_file),
              title: Text('uploadFile').tr(),
              onTap: () {
                Navigator.of(context).pop();
                _pickAndUploadFile(
                  ref,
                  tabId,
                  currentPath.value,
                  selectedPool.value?.id,
                );
              },
            ),
            ListTile(
              leading: const Icon(Symbols.drive_folder_upload),
              title: Text('uploadFolder').tr(),
              onTap: () {
                Navigator.of(context).pop();
                _pickAndUploadFolder(
                  ref,
                  tabId,
                  currentPath.value,
                  selectedPool.value?.id,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ── Browser-style tab strip (SolWatt-inspired flat chrome) ──────────────────

class _DriveTabStrip extends StatelessWidget {
  final List<_DriveFileTab> tabs;
  final String? activeTabId;
  final String Function(_DriveFileTab tab) getTabTitle;
  final ValueChanged<SnCloudFile> onRenameFile;
  final Future<void> Function(SnCloudFile file) onRevealParentFolder;
  final ValueChanged<String> onSelectTab;
  final ValueChanged<String> onCloseTab;
  final void Function(int oldIndex, int newIndex) onReorderTab;
  final VoidCallback onAddIndexedTab;
  final VoidCallback onAddUnindexedTab;
  final VoidCallback? onRefresh;
  final VoidCallback? onNewFolder;
  final VoidCallback? onUpload;
  final bool uploadIsAsset;

  const _DriveTabStrip({
    required this.tabs,
    required this.activeTabId,
    required this.getTabTitle,
    required this.onRenameFile,
    required this.onRevealParentFolder,
    required this.onSelectTab,
    required this.onCloseTab,
    required this.onReorderTab,
    required this.onAddIndexedTab,
    required this.onAddUnindexedTab,
    this.onRefresh,
    this.onNewFolder,
    this.onUpload,
    this.uploadIsAsset = false,
  });

  IconData _tabIcon(_DriveFileTab tab) {
    if (tab.file != null) return Symbols.draft;
    if (tab.mode == FileListMode.unindexed) return Symbols.inventory_2;
    return Symbols.folder;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final border = scheme.outlineVariant.withValues(alpha: 0.55);

    Widget toolButton({
      required String tooltip,
      required IconData icon,
      required VoidCallback? onPressed,
    }) {
      return SizedBox(
        width: 36,
        height: 40,
        child: IconButton(
          tooltip: tooltip,
          onPressed: onPressed,
          padding: EdgeInsets.zero,
          visualDensity: VisualDensity.compact,
          iconSize: 18,
          style: IconButton.styleFrom(
            foregroundColor: scheme.onSurfaceVariant,
            disabledForegroundColor: scheme.onSurface.withValues(alpha: 0.28),
          ),
          icon: Icon(icon),
        ),
      );
    }

    return Material(
      color: scheme.surfaceContainerLow,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: border)),
        ),
        child: SizedBox(
          height: 40,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: tabs.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'driveNoOpenTabs'.tr(),
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: scheme.onSurfaceVariant),
                          ),
                        ),
                      )
                    : ReorderableListView.builder(
                        buildDefaultDragHandles: false,
                        scrollDirection: Axis.horizontal,
                        itemCount: tabs.length,
                        onReorderItem: onReorderTab,
                        proxyDecorator: (child, index, animation) {
                          return AnimatedBuilder(
                            animation: animation,
                            builder: (context, child) {
                              return Material(
                                elevation: 3,
                                color: scheme.surface,
                                shadowColor: scheme.shadow.withValues(
                                  alpha: 0.25,
                                ),
                                child: child,
                              );
                            },
                            child: child,
                          );
                        },
                        itemBuilder: (context, index) {
                          final tab = tabs[index];
                          final selected = tab.id == activeTabId;
                          return ReorderableDragStartListener(
                            key: ValueKey(tab.id),
                            index: index,
                            child: _DriveTabItem(
                              title: getTabTitle(tab),
                              icon: _tabIcon(tab),
                              file: tab.file,
                              isSelected: selected,
                              showDivider:
                                  index > 0 &&
                                  tabs[index - 1].id != activeTabId &&
                                  !selected,
                              onRenameFile: onRenameFile,
                              onRevealParentFolder: onRevealParentFolder,
                              onTap: () => onSelectTab(tab.id),
                              onClose: () => onCloseTab(tab.id),
                            ),
                          );
                        },
                      ),
              ),
              VerticalDivider(width: 1, thickness: 1, color: border),
              PopupMenuButton<String>(
                tooltip: 'add'.tr(),
                padding: EdgeInsets.zero,
                onSelected: (value) {
                  switch (value) {
                    case 'indexed':
                      onAddIndexedTab();
                    case 'unindexed':
                      onAddUnindexedTab();
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'indexed',
                    child: ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Symbols.folder, size: 20),
                      title: Text('driveIndexedEntryLabel'.tr()),
                      subtitle: Text('driveIndexedEntryDescription'.tr()),
                    ),
                  ),
                  PopupMenuItem(
                    value: 'unindexed',
                    child: ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Symbols.inventory_2, size: 20),
                      title: Text('driveUnindexedEntryLabel'.tr()),
                      subtitle: Text('driveUnindexedEntryDescription'.tr()),
                    ),
                  ),
                ],
                child: SizedBox(
                  width: 36,
                  height: 40,
                  child: Icon(
                    Symbols.add,
                    size: 20,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
              VerticalDivider(width: 1, thickness: 1, color: border),
              toolButton(
                tooltip: 'refresh'.tr(),
                icon: Symbols.refresh,
                onPressed: onRefresh,
              ),
              toolButton(
                tooltip: 'createDirectory'.tr(),
                icon: Symbols.create_new_folder,
                onPressed: onNewFolder,
              ),
              toolButton(
                tooltip: uploadIsAsset
                    ? 'driveUploadAsset'.tr()
                    : 'uploadFile'.tr(),
                icon: Symbols.upload,
                onPressed: onUpload,
              ),
              const SizedBox(width: 4),
            ],
          ),
        ),
      ),
    );
  }
}

/// Single document tab — flat browser chrome, not a floating chip.
class _DriveTabItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final SnCloudFile? file;
  final bool isSelected;
  final bool showDivider;
  final ValueChanged<SnCloudFile> onRenameFile;
  final Future<void> Function(SnCloudFile file) onRevealParentFolder;
  final VoidCallback onTap;
  final VoidCallback onClose;

  const _DriveTabItem({
    required this.title,
    required this.icon,
    required this.file,
    required this.isSelected,
    required this.showDivider,
    required this.onRenameFile,
    required this.onRevealParentFolder,
    required this.onTap,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final border = scheme.outlineVariant.withValues(alpha: 0.55);

    return ContextMenuWidget(
      previewBuilder: contextMenuPreviewBuilder,
      menuProvider: (_) {
        return Menu(
          children: [
            if (file != null) ...[
              MenuAction(
                title: 'Inspect',
                image: MenuImage.icon(Symbols.info),
                callback: () {
                  CloudFileActionsSheet.show(
                    context: context,
                    item: file!,
                    onRenamed: onRenameFile,
                    onRevealParentFolder: () => onRevealParentFolder(file!),
                  );
                },
              ),
              MenuSeparator(),
              MenuAction(
                title: 'download'.tr(),
                image: MenuImage.icon(Symbols.download),
                callback: () {},
              ),
            ],
            MenuAction(
              title: 'close'.tr(),
              image: MenuImage.icon(Symbols.close),
              callback: onClose,
            ),
          ],
        );
      },
      child: Listener(
        onPointerDown: (event) {
          if (event.kind == PointerDeviceKind.mouse &&
              event.buttons == kMiddleMouseButton) {
            onClose();
          }
        },
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 120, maxWidth: 220),
          child: Material(
            color: isSelected ? scheme.surface : Colors.transparent,
            child: InkWell(
              onTap: onTap,
              hoverColor: scheme.onSurface.withValues(alpha: 0.04),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border(
                    left: showDivider
                        ? BorderSide(color: border)
                        : BorderSide.none,
                    // Selected tab sits on the content surface: hide bar bottom
                    // edge and draw a thin top accent.
                    top: isSelected
                        ? BorderSide(color: scheme.tertiary, width: 2)
                        : BorderSide.none,
                    right: isSelected
                        ? BorderSide(color: border)
                        : BorderSide.none,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 4, 0),
                  child: Row(
                    children: [
                      Icon(
                        icon,
                        size: 16,
                        color: isSelected
                            ? scheme.primary
                            : scheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(
                                color: isSelected
                                    ? scheme.onSurface
                                    : scheme.onSurfaceVariant,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                                fontSize: 13,
                              ),
                        ),
                      ),
                      if (file != null)
                        SizedBox(
                          width: 28,
                          height: 28,
                          child: Consumer(
                            builder: (context, ref, _) => IconButton(
                              padding: EdgeInsets.zero,
                              visualDensity: VisualDensity.compact,
                              iconSize: 15,
                              tooltip: 'download'.tr(),
                              onPressed: () => ref
                                  .read(driveFileDownloaderProvider)
                                  .downloadFile(
                                    file!,
                                    useDownloadsFolder: HardwareKeyboard
                                        .instance
                                        .isShiftPressed,
                                  ),
                              style: IconButton.styleFrom(
                                foregroundColor: scheme.onSurfaceVariant,
                                hoverColor: scheme.onSurface.withValues(
                                  alpha: 0.08,
                                ),
                              ),
                              icon: const Icon(Symbols.download),
                            ),
                          ),
                        ),
                      SizedBox(
                        width: 28,
                        height: 28,
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          visualDensity: VisualDensity.compact,
                          iconSize: 15,
                          tooltip: 'close'.tr(),
                          onPressed: onClose,
                          style: IconButton.styleFrom(
                            foregroundColor: scheme.onSurfaceVariant,
                            hoverColor: scheme.onSurface.withValues(
                              alpha: 0.08,
                            ),
                          ),
                          icon: const Icon(Symbols.close),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DriveWorkspaceEmptyState extends StatelessWidget {
  final VoidCallback onOpenIndexed;
  final VoidCallback onOpenUnindexed;

  const _DriveWorkspaceEmptyState({
    super.key,
    required this.onOpenIndexed,
    required this.onOpenUnindexed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 560;
        return Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer.withOpacity(0.55),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Icon(
                      Symbols.cloud_done,
                      size: 36,
                      color: colorScheme.primary,
                    ),
                  ),
                  const Gap(20),
                  Text(
                    'driveWorkspaceEmptyTitle'.tr(),
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const Gap(8),
                  Text(
                    'driveWorkspaceEmptyDescription'.tr(),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      height: 1.45,
                    ),
                  ),
                  const Gap(28),
                  if (isCompact) ...[
                    _DriveEntryCard(
                      icon: Symbols.folder,
                      title: 'driveIndexedEntryLabel'.tr(),
                      description: 'driveIndexedEntryDescription'.tr(),
                      onTap: onOpenIndexed,
                    ),
                    const Gap(12),
                    _DriveEntryCard(
                      icon: Symbols.inventory_2,
                      title: 'driveUnindexedEntryLabel'.tr(),
                      description: 'driveUnindexedEntryDescription'.tr(),
                      onTap: onOpenUnindexed,
                    ),
                  ] else
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _DriveEntryCard(
                            icon: Symbols.folder,
                            title: 'driveIndexedEntryLabel'.tr(),
                            description: 'driveIndexedEntryDescription'.tr(),
                            onTap: onOpenIndexed,
                          ),
                        ),
                        const Gap(16),
                        Expanded(
                          child: _DriveEntryCard(
                            icon: Symbols.inventory_2,
                            title: 'driveUnindexedEntryLabel'.tr(),
                            description: 'driveUnindexedEntryDescription'.tr(),
                            onTap: onOpenUnindexed,
                          ),
                        ),
                      ],
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

class _DriveEntryCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  const _DriveEntryCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outlineVariant.withOpacity(0.55)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 12, 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withOpacity(0.55),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 22, color: colorScheme.primary),
              ),
              const Gap(14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Gap(4),
                    Text(
                      description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const Gap(8),
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Icon(
                  Symbols.chevron_right,
                  size: 20,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DriveStorageStatusBar extends StatelessWidget {
  final Map<String, dynamic>? usage;
  final Map<String, dynamic>? quota;
  final int? totalMatches;
  final VoidCallback onTapDetails;

  const _DriveStorageStatusBar({
    required this.usage,
    required this.quota,
    required this.totalMatches,
    required this.onTapDetails,
  });

  @override
  Widget build(BuildContext context) {
    if (usage == null) return const SizedBox.shrink();

    final nonNullUsage = usage!;
    final totalQuotaMb = nonNullUsage['total_quota'] as int? ?? 0;
    final usedQuotaMb = nonNullUsage['used_quota'] as num? ?? 0;
    final usedBytes = (usedQuotaMb * 1024 * 1024).round();
    final totalBytes = totalQuotaMb * 1024 * 1024;
    final ratio = totalBytes > 0
        ? (usedBytes / totalBytes).clamp(0.0, 1.0)
        : 0.0;

    final scheme = Theme.of(context).colorScheme;
    final border = scheme.outlineVariant.withValues(alpha: 0.55);

    return Material(
      color: scheme.surfaceContainerLow,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: border)),
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            16,
            2,
            8,
            2 + MediaQuery.paddingOf(context).bottom,
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isCompact = constraints.maxWidth < 520;
              return Row(
                mainAxisSize: MainAxisSize.max,
                spacing: 12,
                children: [
                  Icon(Symbols.storage, size: 18, color: scheme.primary),
                  if (!isCompact)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: SizedBox(
                        width: 120,
                        child: LinearProgressIndicator(
                          value: ratio,
                          minHeight: 8,
                        ),
                      ),
                    ),
                  if (!isCompact && totalMatches != null)
                    Expanded(
                      child: Text(
                        'matches'.plural(totalMatches ?? 0),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    )
                  else
                    const Spacer(),
                  Text(
                    '${formatFileSize(usedBytes)} / ${formatFileSize(totalBytes)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (!isCompact)
                    Text(
                      '${(ratio * 100).toStringAsFixed(1)}%',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  IconButton(
                    onPressed: onTapDetails,
                    tooltip: 'viewDetails'.tr(),
                    icon: const Icon(Symbols.bar_chart),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _DriveSelectionStatusBar extends StatelessWidget {
  final int selectionCount;
  final bool allVisibleSelected;
  final VoidCallback onCancel;
  final VoidCallback onToggleSelectAll;
  final VoidCallback? onDownload;
  final VoidCallback? onDelete;

  const _DriveSelectionStatusBar({
    required this.selectionCount,
    required this.allVisibleSelected,
    required this.onCancel,
    required this.onToggleSelectAll,
    required this.onDownload,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final border = scheme.outlineVariant.withValues(alpha: 0.55);

    return Material(
      color: scheme.surfaceContainerLow,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: border)),
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            16,
            2,
            8,
            2 + MediaQuery.paddingOf(context).bottom,
          ),
          child: Row(
            children: [
              Icon(Symbols.select_check_box, size: 18, color: scheme.primary),
              const Gap(12),
              Expanded(
                child: Text(
                  selectionCount == 1
                      ? 'fileSelected'.tr(args: [selectionCount.toString()])
                      : 'filesSelected'.tr(args: [selectionCount.toString()]),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              TextButton(
                onPressed: onToggleSelectAll,
                child: Text(
                  allVisibleSelected ? 'deselectAll'.tr() : 'selectAll'.tr(),
                ),
              ),
              IconButton(
                onPressed: onDownload,
                tooltip: 'download'.tr(),
                icon: const Icon(Symbols.download),
              ),
              IconButton(
                onPressed: onDelete,
                tooltip: 'delete'.tr(),
                icon: const Icon(Symbols.delete),
              ),
              IconButton(
                onPressed: onCancel,
                tooltip: 'cancel'.tr(),
                icon: const Icon(Symbols.close),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DriveFileContentTab extends ConsumerWidget {
  final SnCloudFile file;
  final void Function(SnCloudFile file) onInspectFile;

  const _DriveFileContentTab({
    super.key,
    required this.file,
    required this.onInspectFile,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final serverUrl = ref.watch(serverUrlProvider);
    final uri = '$serverUrl/drive/files/${file.id}';

    return SizedBox.expand(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onLongPress: () => onInspectFile(file),
        onSecondaryTap: () => onInspectFile(file),
        child: ClipRect(
          child: switch (file.mimeType.split('/').firstOrNull) {
            'image' => ImageFileContent(item: file, uri: uri),
            'video' => VideoFileContent(item: file, uri: uri),
            'audio' => AudioFileContent(item: file, uri: uri),
            _ when file.mimeType.startsWith('text/') => TextFileContent(
              uri: uri,
            ),
            _ => GenericFileContent(item: file),
          },
        ),
      ),
    );
  }
}
