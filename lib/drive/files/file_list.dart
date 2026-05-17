import 'package:cross_file/cross_file.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/drive/screens/file_list.dart';
import 'package:island/drive/screens/file_pool.dart';
import 'package:island/drive/drive_service.dart';
import 'package:island/core/network.dart';
import 'package:island/drive/widgets/quota_sidebar.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/shared/widgets/app_scaffold.dart';
import 'package:island/shared/widgets/layouts/sheet_scaffold.dart';
import 'package:island/shared/widgets/responsive_sidebar.dart';
import 'package:island/drive/widgets/file_list_view.dart';
import 'package:island/accounts/usage_overview.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

@RoutePage()
class FileListScreen extends HookConsumerWidget {
  const FileListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Path navigation state
    final currentPath = useState<String>('/');
    final mode = useState<FileListMode>(FileListMode.normal);
    final selectedPool = useState<SnFilePool?>(null);

    final usageAsync = ref.watch(billingUsageProvider);
    final quotaAsync = ref.watch(billingQuotaProvider);
    final poolsAsync = ref.watch(poolsProvider);

    final viewMode = useState(FileListViewMode.list);
    final isSelectionMode = useState<bool>(false);
    final recycled = useState<bool>(false);
    final query = useState<String?>(null);
    final showSidebar = useState<bool>(false);

    // Notifiers should be read fresh each time to avoid disposal issues

    // Sidebar content widget
    final sidebarContent = poolsAsync.when(
      data: (pools) => usageAsync.when(
        data: (usage) => quotaAsync.when(
          data: (quota) => QuotaSidebarWidget(
            usage: usage,
            quota: quota,
            pools: pools,
            selectedPool: selectedPool.value,
            onPoolSelected: (pool) {
              selectedPool.value = pool;
              if (mode.value == FileListMode.unindexed) {
                ref.read(unindexedFileListProvider.notifier).setPool(pool?.id);
              } else {
                ref
                    .read(indexedCloudFileListProvider.notifier)
                    .setPool(pool?.id);
              }
            },
            onViewDetails: () => _showUsageSheet(context, usage, quota),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => Center(child: Text('errorLoadingQuota'.tr())),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(child: Text('errorLoadingUsage'.tr())),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => Center(child: Text('errorLoadingPools'.tr())),
    );

    // Drawer builder for narrow screens - uses builder to access providers
    Consumer drawerBuilder(BuildContext sheetContext) {
      return Consumer(
        builder: (context, ref, _) {
          final usage = ref.watch(billingUsageProvider);
          final quota = ref.watch(billingQuotaProvider);
          final pools = ref.watch(poolsProvider);

          return pools.when(
            data: (poolsData) => usage.when(
              data: (usageData) => quota.when(
                data: (quotaData) => DriveQuotaSidebar(
                  usage: usageData,
                  quota: quotaData,
                  pools: poolsData,
                  selectedPool: selectedPool.value,
                  onPoolSelected: (pool) {
                    selectedPool.value = pool;
                    if (mode.value == FileListMode.unindexed) {
                      ref
                          .read(unindexedFileListProvider.notifier)
                          .setPool(pool?.id);
                    } else {
                      ref
                          .read(indexedCloudFileListProvider.notifier)
                          .setPool(pool?.id);
                    }
                  },
                  onViewDetails: () {
                    Navigator.of(sheetContext).pop();
                    _showUsageSheet(context, usageData, quotaData);
                  },
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, _) => Center(child: Text('errorLoadingQuota'.tr())),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, _) => Center(child: Text('errorLoadingUsage'.tr())),
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, _) => Center(child: Text('errorLoadingPools'.tr())),
          );
        },
      );
    }

    // Main content widget
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
          constraints: const BoxConstraints(maxWidth: 400, minHeight: 32),
          hintText: 'searchFiles'.tr(),
          hintStyle: const WidgetStatePropertyAll(TextStyle(fontSize: 14)),
          textStyle: const WidgetStatePropertyAll(TextStyle(fontSize: 14)),
          onChanged: (value) {
            query.value = value.isEmpty ? null : value;
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
              isSelectionMode.value ? Symbols.close : Symbols.select_check_box,
            ),
            onPressed: () => isSelectionMode.value = !isSelectionMode.value,
            tooltip: isSelectionMode.value
                ? 'exitSelectionMode'.tr()
                : 'enterSelectionMode'.tr(),
          ),

          // Recycle toggle (only in unindexed mode)
          if (mode.value == FileListMode.unindexed)
            IconButton(
              icon: Icon(
                recycled.value
                    ? Symbols.delete_forever
                    : Symbols.restore_from_trash,
              ),
              onPressed: () {
                recycled.value = !recycled.value;
                ref
                    .read(unindexedFileListProvider.notifier)
                    .setRecycled(recycled.value);
              },
              tooltip: recycled.value ? 'showActiveFiles' : 'showRecycleBin',
            ),

          // Storage sidebar toggle
          IconButton(
            icon: const Icon(Symbols.storage),
            onPressed: () => showSidebar.value = !showSidebar.value,
            tooltip: 'storageOverview'.tr(),
          ),
          const Gap(8),
        ],
      ),
      floatingActionButton: mode.value == FileListMode.normal
          ? FloatingActionButton(
              onPressed: () => _showActionBottomSheet(
                context,
                ref,
                currentPath,
                selectedPool,
              ),
              tooltip: 'addFilesOrCreateDirectory'.tr(),
              child: const Icon(Symbols.add),
            )
          : null,
      body: usageAsync.when(
        data: (usage) => quotaAsync.when(
          data: (quota) => FileListView(
            usage: usage,
            quota: quota,
            currentPath: currentPath,
            selectedPool: selectedPool,
            onPickAndUpload: () => _pickAndUploadFile(
              ref,
              currentPath.value,
              selectedPool.value?.id,
            ),
            onShowCreateFolder: () => _showCreateFolderDialog(
              context,
              ref,
              currentPath.value,
              selectedPool.value?.id,
            ),
            mode: mode,
            viewMode: viewMode,
            isSelectionMode: isSelectionMode,
            query: query,
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('errorLoadingQuota'.tr())),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('errorLoadingUsage'.tr())),
      ),
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
    String currentPath,
    String? poolId,
  ) async {
    try {
      final result = await FilePicker.pickFiles(
        allowMultiple: true,
        withData: false,
      );

      if (result != null && result.files.isNotEmpty) {
        for (final file in result.files) {
          if (file.path != null) {
            final universalFile = UniversalFile(
              data: XFile(file.path!),
              type: UniversalFileType.file,
              displayName: file.name,
            );

            final completer = ref
                .read(driveFileUploaderProvider)
                .createCloudFile(
                  fileData: universalFile,
                  path: currentPath,
                  poolId: poolId,
                  onProgress: (progress, _) {
                    if (progress != null) {
                      debugPrint(
                        'Upload progress: ${(progress * 100).toInt()}%',
                      );
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
                  showSnackBar(
                    'failedToUploadFile'.tr(args: [error.toString()]),
                  );
                });
          }
        }
      }
    } catch (e) {
      showSnackBar('errorPickingFile'.tr(args: [e.toString()]));
    }
  }

  Future<void> _showCreateFolderDialog(
    BuildContext context,
    WidgetRef ref,
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
                    ref.invalidate(indexedCloudFileListProvider);
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
              onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
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
                        ref.invalidate(indexedCloudFileListProvider);
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
