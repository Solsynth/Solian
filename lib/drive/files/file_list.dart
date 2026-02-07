import 'package:cross_file/cross_file.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/drive/drive_models/file.dart';
import 'package:island/drive/drive_models/file_pool.dart';
import 'package:island/drive/drive/file_list.dart';
import 'package:island/drive/drive_service.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/shared/widgets/app_scaffold.dart';
import 'package:island/core/widgets/content/sheet_scaffold.dart';
import 'package:island/drive/drive_widgets/file_list_view.dart';
import 'package:island/accounts/usage_overview.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:styled_widget/styled_widget.dart';

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

    final viewMode = useState(FileListViewMode.list);
    final isSelectionMode = useState<bool>(false);
    final recycled = useState<bool>(false);
    final query = useState<String?>(null);

    final unindexedNotifier = ref.read(unindexedFileListProvider.notifier);

    return AppScaffold(
      isNoBackground: false,
      appBar: AppBar(
        title: SearchBar(
          constraints: const BoxConstraints(maxWidth: 400, minHeight: 32),
          hintText: 'searchFiles'.tr(),
          hintStyle: WidgetStatePropertyAll(TextStyle(fontSize: 14)),
          textStyle: WidgetStatePropertyAll(TextStyle(fontSize: 14)),
          onChanged: (value) {
            // Update the query state that will be passed to FileListView
            query.value = value.isEmpty ? null : value;
          },
          leading: Icon(
            Symbols.search,
            size: 20,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        leading: const PageBackButton(backTo: '/account'),
        actions: [
          // Selection mode toggle
          IconButton(
            icon: Icon(
              isSelectionMode.value ? Symbols.close : Symbols.select_check_box,
            ),
            onPressed: () => isSelectionMode.value = !isSelectionMode.value,
            tooltip: isSelectionMode.value
                ? 'Exit Selection Mode'
                : 'Enter Selection Mode',
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
                unindexedNotifier.setRecycled(recycled.value);
              },
              tooltip: recycled.value
                  ? 'Show Active Files'
                  : 'Show Recycle Bin',
            ),

          IconButton(
            icon: const Icon(Symbols.bar_chart),
            onPressed: () =>
                _showUsageSheet(context, usageAsync.value, quotaAsync.value),
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
              tooltip: 'Add files or create directory',
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
            onShowCreateDirectory: _showCreateDirectoryDialog,
            mode: mode,
            viewMode: viewMode,
            isSelectionMode: isSelectionMode,
            query: query,
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error loading quota')),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error loading usage')),
      ),
    );
  }

  Future<void> _pickAndUploadFile(
    WidgetRef ref,
    String currentPath,
    String? poolId,
  ) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        withData: false,
      );

      if (result != null && result.files.isNotEmpty) {
        for (final file in result.files) {
          if (file.path != null) {
            // Create UniversalFile from the picked file
            final universalFile = UniversalFile(
              data: XFile(file.path!),
              type: UniversalFileType.file,
              displayName: file.name,
            );

            // Upload the file with the current path
            final completer = FileUploader.createCloudFile(
              fileData: universalFile,
              ref: ref,
              path: currentPath,
              poolId: poolId,
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
        }
      }
    } catch (e) {
      showSnackBar('Error picking file: $e');
    }
  }

  Future<void> _showCreateDirectoryDialog(
    BuildContext context,
    ValueNotifier<String> currentPath,
  ) async {
    final controller = TextEditingController(text: currentPath.value);
    String? newPath;

    void handleChangeDirectory(BuildContext context) {
      newPath = controller.text.trim();
      if (newPath!.isNotEmpty) {
        // Normalize the path
        String fullPath = newPath!;

        // Ensure it starts with /
        if (!fullPath.startsWith('/')) {
          fullPath = '/$fullPath';
        }

        // Remove double slashes and normalize
        fullPath = fullPath.replaceAll(RegExp(r'/+'), '/');

        currentPath.value = fullPath;
        Navigator.of(context).pop();
      }
    }

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Navigate to Directory'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Gap(8),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Directory path',
                hintText: 'e.g., documents, projects/my-app',
                helperText:
                    'Enter a directory path. The directory will be created when you upload files to it.',
                helperMaxLines: 3,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
              ),
              onSubmitted: (_) {
                handleChangeDirectory(context);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton.icon(
            onPressed: () => handleChangeDirectory(context),
            label: const Text('Go to Directory'),
            icon: const Icon(Symbols.arrow_right_alt),
          ),
        ],
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
        titleText: 'Usage Overview',
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
              title: const Text('Create Directory'),
              onTap: () {
                Navigator.of(context).pop();
                _showCreateDirectoryDialog(context, currentPath);
              },
            ),
            ListTile(
              leading: const Icon(Symbols.upload_file),
              title: const Text('Upload File'),
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
