import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/creators/publication_site.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/core/widgets/content/sheet.dart';
import 'package:island/sites/site_files.dart';
import 'package:material_symbols_icons/symbols.dart';

class FileUploadDialog extends HookConsumerWidget {
  final List<File> selectedFiles;
  final SnPublicationSite site;
  final VoidCallback onUploadComplete;
  final List<String>? relativePaths;

  const FileUploadDialog({
    super.key,
    required this.selectedFiles,
    required this.site,
    required this.onUploadComplete,
    this.relativePaths,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final pathController = useTextEditingController(text: '/');
    final isUploading = useState(false);
    final progressStates = useState<List<Map<String, dynamic>>>(
      selectedFiles
          .map(
            (file) => {
              'fileName':
                  relativePaths?[selectedFiles.indexOf(file)] ??
                  file.path.split('/').last,
              'progress': 0.0,
              'status':
                  'pending', // 'pending', 'uploading', 'completed', 'error'
              'error': null,
            },
          )
          .toList(),
    );

    // Calculate overall progress
    final overallProgress = progressStates.value.isNotEmpty
        ? progressStates.value
                  .map((e) => e['progress'] as double)
                  .reduce((a, b) => a + b) /
              progressStates.value.length
        : 0.0;

    final overallStatus = progressStates.value.isEmpty
        ? 'pending'
        : progressStates.value.every((e) => e['status'] == 'completed')
        ? 'completed'
        : progressStates.value.any((e) => e['status'] == 'error')
        ? 'error'
        : progressStates.value.any((e) => e['status'] == 'uploading')
        ? 'uploading'
        : 'pending';

    final uploadFile = useCallback((
      String basePath,
      File file,
      int index,
    ) async {
      try {
        progressStates.value[index]['status'] = 'uploading';
        progressStates.value = [...progressStates.value];

        final siteFilesNotifier = ref.read(
          siteFilesNotifierProvider((siteId: site.id, path: null)).notifier,
        );

        final fileName = relativePaths?[index] ?? file.path.split('/').last;
        final uploadPath = basePath.endsWith('/')
            ? '$basePath$fileName'
            : '$basePath/$fileName';

        await siteFilesNotifier.uploadFile(file, uploadPath);

        progressStates.value[index]['status'] = 'completed';
        progressStates.value[index]['progress'] = 1.0;
        progressStates.value = [...progressStates.value];
      } catch (e) {
        progressStates.value[index]['status'] = 'error';
        progressStates.value[index]['error'] = e.toString();
        progressStates.value = [...progressStates.value];
      }
    }, [ref, site.id, progressStates]);

    final uploadAllFiles = useCallback(
      () async {
        if (!formKey.currentState!.validate()) return;

        isUploading.value = true;

        // Reset all progress states
        for (int i = 0; i < progressStates.value.length; i++) {
          progressStates.value[i]['status'] = 'pending';
          progressStates.value[i]['progress'] = 0.0;
          progressStates.value[i]['error'] = null;
        }
        progressStates.value = [...progressStates.value];

        // Upload files sequentially (could be made parallel if needed)
        for (int i = 0; i < selectedFiles.length; i++) {
          final file = selectedFiles[i];
          await uploadFile(pathController.text, file, i);
        }

        isUploading.value = false;

        // Close dialog if all uploads completed successfully
        if (progressStates.value.every(
          (state) => state['status'] == 'completed',
        )) {
          if (context.mounted) {
            showSnackBar('All files uploaded successfully');
            onUploadComplete();
            Navigator.of(context).pop();
          }
        }
      },
      [
        uploadFile,
        isUploading,
        progressStates,
        selectedFiles,
        onUploadComplete,
        context,
        formKey,
        pathController,
      ],
    );

    return SheetScaffold(
      titleText: 'Upload Files',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Upload path field
              TextFormField(
                controller: pathController,
                decoration: const InputDecoration(
                  labelText: 'Upload Path',
                  hintText: '/ (root) or /assets/images/',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an upload path';
                  }
                  if (!value.startsWith('/') && value != '/') {
                    return 'Path must start with /';
                  }
                  if (value.contains(' ')) {
                    return 'Path cannot contain spaces';
                  }
                  if (value.contains('//')) {
                    return 'Path cannot have consecutive slashes';
                  }
                  return null;
                },
                onTapOutside: (_) =>
                    FocusManager.instance.primaryFocus?.unfocus(),
              ),
              const Gap(16),
              Card(
                child: Column(
                  children: [
                    // Overall progress
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${(overallProgress * 100).toStringAsFixed(0)}% completed',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          const Gap(8),
                          LinearProgressIndicator(value: overallProgress),
                          const Gap(8),
                          Text(
                            _getOverallStatusText(overallStatus),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    // Divider
                    const Divider(height: 0),
                    // File list in expansion
                    ExpansionTile(
                      title: Text('${selectedFiles.length} files to upload'),
                      initiallyExpanded: selectedFiles.length <= 10,
                      children: selectedFiles.map((file) {
                        final index = selectedFiles.indexOf(file);
                        final progressState = progressStates.value[index];
                        final displayName = progressState['fileName'] as String;
                        return ListTile(
                          leading: _getStatusIcon(
                            progressState['status'] as String,
                          ),
                          title: Text(displayName),
                          subtitle: Text(
                            'Size: ${(file.lengthSync() / 1024).toStringAsFixed(1)} KB',
                          ),
                          dense: true,
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const Gap(24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: isUploading.value
                          ? null
                          : () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const Gap(12),
                  Expanded(
                    child: FilledButton(
                      onPressed: isUploading.value ? null : uploadAllFiles,
                      child: Text(
                        isUploading.value
                            ? 'Uploading...'
                            : 'Upload ${selectedFiles.length} File${selectedFiles.length == 1 ? '' : 's'}',
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Icon _getStatusIcon(String status) {
    switch (status) {
      case 'completed':
        return const Icon(Symbols.check_circle, color: Colors.green);
      case 'uploading':
        return const Icon(Symbols.sync);
      case 'error':
        return const Icon(Symbols.error, color: Colors.red);
      default:
        return const Icon(Symbols.pending);
    }
  }

  String _getOverallStatusText(String status) {
    switch (status) {
      case 'completed':
        return 'All uploads completed';
      case 'error':
        return 'Some uploads failed';
      case 'uploading':
        return 'Uploading in progress';
      default:
        return 'Ready to upload';
    }
  }
}
