import 'package:cross_file/cross_file.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/models/file.dart';
import 'package:island/pods/file_list.dart';
import 'package:island/services/file_uploader.dart';
import 'package:island/widgets/alert.dart';
import 'package:island/widgets/app_scaffold.dart';
import 'package:island/widgets/content/sheet.dart';
import 'package:island/widgets/file_list_view.dart';
import 'package:island/widgets/usage_overview.dart';
import 'package:material_symbols_icons/symbols.dart';

class FileListScreen extends HookConsumerWidget {
  const FileListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Path navigation state
    final currentPath = useState<String>('/');
    final mode = useState<FileListMode>(FileListMode.normal);

    final usageAsync = ref.watch(billingUsageProvider);
    final quotaAsync = ref.watch(billingQuotaProvider);

    return AppScaffold(
      isNoBackground: false,
      appBar: AppBar(
        title: Text('Files'),
        leading: const PageBackButton(),
        actions: [
          IconButton(
            icon: const Icon(Symbols.bar_chart),
            onPressed:
                () => _showUsageSheet(
                  context,
                  usageAsync.value,
                  quotaAsync.value,
                ),
          ),
          const Gap(8),
        ],
      ),
      body: usageAsync.when(
        data:
            (usage) => quotaAsync.when(
              data:
                  (quota) => FileListView(
                    usage: usage,
                    quota: quota,
                    currentPath: currentPath,
                    onPickAndUpload:
                        () => _pickAndUploadFile(ref, currentPath.value),
                    onShowCreateDirectory: _showCreateDirectoryDialog,
                    mode: mode,
                  ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error loading quota')),
            ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error loading usage')),
      ),
    );
  }

  Future<void> _pickAndUploadFile(WidgetRef ref, String currentPath) async {
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
                    ref.invalidate(cloudFileListNotifierProvider);
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
      builder:
          (context) => AlertDialog(
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
      builder:
          (context) => SheetScaffold(
            titleText: 'Usage Overview',
            child: UsageOverviewWidget(usage: usage, quota: quota),
          ),
    );
  }
}
