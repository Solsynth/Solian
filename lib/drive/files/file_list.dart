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

class _DriveAdvancedSearchSummary {
  final String? usage;
  final String? applicationType;

  const _DriveAdvancedSearchSummary({
    required this.usage,
    required this.applicationType,
  });
}

_DriveAdvancedSearchSummary _parseDriveAdvancedSearchSummary(String? input) {
  if (input == null || input.trim().isEmpty) {
    return const _DriveAdvancedSearchSummary(
      usage: null,
      applicationType: null,
    );
  }

  String? usage;
  String? applicationType;
  for (final term in input.trim().split(RegExp(r'\s+'))) {
    final separatorIndex = term.indexOf(':');
    if (separatorIndex <= 0 || separatorIndex == term.length - 1) continue;

    final key = term.substring(0, separatorIndex);
    final value = term.substring(separatorIndex + 1);
    switch (key) {
      case 'usage':
        usage = value;
        break;
      case 'applicationType':
      case 'application_type':
        applicationType = value;
        break;
    }
  }

  return _DriveAdvancedSearchSummary(
    usage: usage,
    applicationType: applicationType,
  );
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
      viewModeStates[id] = ValueNotifier(FileListViewMode.list);
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
      viewModeStates[id] = ValueNotifier(FileListViewMode.list);
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
      ref.invalidate(indexedCloudFileListFamilyProvider(tabId));
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

    void reorderTab(int oldIndex, int newIndex) {
      final currentTabs = [...tabs.value];
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }
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
    final parsedSearch = _parseDriveAdvancedSearchSummary(queryValue);
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
                              onOpenFolderInNewTab: openFolderTab,
                              onPickAndUpload: () => _pickAndUploadFile(
                                ref,
                                activeTab.id,
                                currentPathValue,
                                selectedPoolValue?.id,
                              ),
                              onDropFiles: (files) => _uploadDroppedFiles(
                                ref,
                                activeTab.id,
                                currentPathValue,
                                selectedPoolValue?.id,
                                files,
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
                      if (visibleFileIdsValue
                          .difference(selectedFileIdsValue)
                          .isEmpty) {
                        selectedFileIds.value = Set<String>.from(
                          selectedFileIds.value,
                        )..removeAll(visibleFileIdsValue);
                      } else {
                        selectedFileIds.value = Set<String>.from(
                          selectedFileIds.value,
                        )..addAll(visibleFileIdsValue);
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
                              ref.invalidate(
                                modeValue == FileListMode.normal
                                    ? indexedCloudFileListFamilyProvider(
                                        activeTab!.id,
                                      )
                                    : unindexedFileListFamilyProvider(
                                        activeTab!.id,
                                      ),
                              );
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
                    advancedSearch: parsedSearch,
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

    final droppableBody = activeTab != null && activeTab.file == null
        ? DropTarget(
            onDragEntered: (_) => dragging.value = true,
            onDragExited: (_) => dragging.value = false,
            onDragDone: (details) async {
              dragging.value = false;
              if (modeValue != FileListMode.normal || details.files.isEmpty) {
                return;
              }
              await _uploadDroppedFiles(
                ref,
                activeTab.id,
                currentPathValue,
                selectedPoolValue?.id,
                details.files,
              );
            },
            child: Stack(
              fit: StackFit.expand,
              children: [
                bodyContent,
                if (dragging.value)
                  IgnorePointer(
                    child: Container(
                      margin: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.primaryContainer.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.primary,
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Symbols.upload,
                              size: 40,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const Gap(12),
                            Text(
                              'dropFilesHere'.tr(),
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const Gap(4),
                            Text(
                              'dragAndDropToAttach'.tr(),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
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

    ref.invalidate(indexedCloudFileListFamilyProvider(tabId));
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
              ref.invalidate(indexedCloudFileListFamilyProvider(tabId));
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
                    ref.invalidate(indexedCloudFileListFamilyProvider(tabId));
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
                        ref.invalidate(
                          indexedCloudFileListFamilyProvider(tabId),
                        );
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
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: colorScheme.surfaceContainerLow.withOpacity(0.8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        child: Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 40,
                child: ReorderableListView.builder(
                  buildDefaultDragHandles: false,
                  scrollDirection: Axis.horizontal,
                  itemCount: tabs.length,
                  onReorder: onReorderTab,
                  itemBuilder: (context, index) {
                    final tab = tabs[index];
                    return ReorderableDragStartListener(
                      key: ValueKey(tab.id),
                      index: index,
                      child: Row(
                        key: ValueKey(tab.id),
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _DriveTabChip(
                            title: getTabTitle(tab),
                            icon: tab.mode == FileListMode.normal
                                ? Symbols.cloud
                                : Symbols.inventory_2,
                            file: tab.file,
                            onRenameFile: onRenameFile,
                            onRevealParentFolder: onRevealParentFolder,
                            isSelected: tab.id == activeTabId,
                            onTap: () => onSelectTab(tab.id),
                            onClose: () => onCloseTab(tab.id),
                          ),
                          const Gap(8),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            const Gap(8),
            PopupMenuButton<String>(
              tooltip: 'add'.tr(),
              onSelected: (value) {
                switch (value) {
                  case 'indexed':
                    onAddIndexedTab();
                    break;
                  case 'unindexed':
                    onAddUnindexedTab();
                    break;
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'indexed',
                  child: Row(
                    children: [
                      const Icon(Symbols.cloud),
                      const Gap(12),
                      Text('driveIndexedEntryLabel'.tr()),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'unindexed',
                  child: Row(
                    children: [
                      const Icon(Symbols.inventory_2),
                      const Gap(12),
                      Text('driveUnindexedEntryLabel'.tr()),
                    ],
                  ),
                ),
              ],
              child: const Padding(
                padding: EdgeInsets.all(8),
                child: Icon(Symbols.add),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DriveTabChip extends StatelessWidget {
  final String title;
  final IconData icon;
  final SnCloudFile? file;
  final ValueChanged<SnCloudFile> onRenameFile;
  final Future<void> Function(SnCloudFile file) onRevealParentFolder;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onClose;

  const _DriveTabChip({
    required this.title,
    required this.icon,
    required this.file,
    required this.onRenameFile,
    required this.onRevealParentFolder,
    required this.isSelected,
    required this.onTap,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ContextMenuWidget(
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
                callback: () {
                  // Download is handled by the dedicated button
                },
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
      child: Material(
        color: isSelected
            ? colorScheme.primaryContainer
            : colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        child: Listener(
          onPointerDown: (event) {
            if (event.kind == PointerDeviceKind.mouse &&
                event.buttons == kMiddleMouseButton) {
              onClose();
            }
          },
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 2, 8, 2),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 18),
                  const Gap(8),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 120),
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Gap(4),
                  if (file != null) ...[
                    Consumer(
                      builder: (context, ref, _) => IconButton(
                        visualDensity: VisualDensity.compact,
                        iconSize: 18,
                        splashRadius: 16,
                        tooltip: 'download'.tr(),
                        onPressed: () => ref
                            .read(driveFileDownloaderProvider)
                            .downloadFile(
                              file!,
                              useDownloadsFolder:
                                  HardwareKeyboard.instance.isShiftPressed,
                            ),
                        icon: const Icon(Symbols.download),
                      ),
                    ),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      iconSize: 18,
                      splashRadius: 16,
                      tooltip: 'close'.tr(),
                      onPressed: onClose,
                      icon: const Icon(Symbols.close),
                    ),
                  ] else
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      iconSize: 18,
                      splashRadius: 16,
                      onPressed: onClose,
                      icon: const Icon(Symbols.close),
                    ),
                ],
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
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: Card(
          margin: const EdgeInsets.all(24),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Symbols.tabs, size: 56, color: colorScheme.primary),
                const Gap(16),
                Text(
                  'driveWorkspaceEmptyTitle'.tr(),
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const Gap(8),
                Text(
                  'driveWorkspaceEmptyDescription'.tr(),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const Gap(24),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    SizedBox(
                      width: 180,
                      height: 80,
                      child: InkWell(
                        borderRadius: const BorderRadius.all(
                          Radius.circular(12),
                        ),
                        onTap: onOpenIndexed,
                        child: Card(
                          margin: EdgeInsets.zero,
                          color: colorScheme.surfaceContainer,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Symbols.cloud,
                                  size: 24,
                                  color: colorScheme.primary,
                                ),
                                const Gap(8),
                                Text(
                                  'driveIndexedEntryLabel'.tr(),
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 180,
                      height: 80,
                      child: InkWell(
                        borderRadius: const BorderRadius.all(
                          Radius.circular(12),
                        ),
                        onTap: onOpenUnindexed,
                        child: Card(
                          margin: EdgeInsets.zero,
                          color: colorScheme.surfaceContainer,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Symbols.inventory_2,
                                  size: 24,
                                  color: colorScheme.primary,
                                ),
                                const Gap(8),
                                Text(
                                  'driveUnindexedEntryLabel'.tr(),
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
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
  final _DriveAdvancedSearchSummary advancedSearch;
  final VoidCallback onTapDetails;

  const _DriveStorageStatusBar({
    required this.usage,
    required this.quota,
    required this.totalMatches,
    required this.advancedSearch,
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
    final hasAdvancedSearch =
        advancedSearch.usage != null || advancedSearch.applicationType != null;

    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      child: Container(
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
                Icon(
                  Symbols.storage,
                  size: 18,
                  color: Theme.of(context).colorScheme.primary,
                ),
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
                if (!isCompact && totalMatches != null) ...[
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$totalMatches ${'matches'.tr()}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        if (hasAdvancedSearch) ...[
                          const Gap(4),
                          Tooltip(
                            message: [
                              if (advancedSearch.usage != null)
                                'usage: ${advancedSearch.usage}',
                              if (advancedSearch.applicationType != null)
                                'applicationType: ${advancedSearch.applicationType}',
                            ].join('\n'),
                            child: Icon(
                              Symbols.info,
                              size: 16,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ] else
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
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      child: Container(
        padding: EdgeInsets.fromLTRB(
          16,
          2,
          8,
          2 + MediaQuery.paddingOf(context).bottom,
        ),
        child: Row(
          children: [
            Icon(
              Symbols.select_check_box,
              size: 18,
              color: Theme.of(context).colorScheme.primary,
            ),
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
