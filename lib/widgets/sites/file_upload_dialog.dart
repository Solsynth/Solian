import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/models/publication_site.dart';
import 'package:island/pods/site_files.dart';
import 'package:island/widgets/content/sheet.dart';
import 'package:material_symbols_icons/symbols.dart';

class FileUploadDialog extends HookConsumerWidget {
  final List<File> selectedFiles;
  final SnPublicationSite site;
  final VoidCallback onUploadComplete;

  const FileUploadDialog({
    super.key,
    required this.selectedFiles,
    required this.site,
    required this.onUploadComplete,
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
              'fileName': file.path.split('/').last,
              'progress': 0.0,
              'status':
                  'pending', // 'pending', 'uploading', 'completed', 'error'
              'error': null,
            },
          )
          .toList(),
    );

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

        final fileName = file.path.split('/').last;
        final uploadPath =
            basePath.endsWith('/')
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
        onUploadComplete();

        // Close dialog if all uploads completed successfully
        if (progressStates.value.every(
          (state) => state['status'] == 'completed',
        )) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('All files uploaded successfully')),
            );
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
                onTapOutside:
                    (_) => FocusManager.instance.primaryFocus?.unfocus(),
              ),
              const Gap(20),
              Text(
                'Ready to upload ${selectedFiles.length} file${selectedFiles.length == 1 ? '' : 's'}:',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Gap(16),
              ...selectedFiles.map((file) {
                final index = selectedFiles.indexOf(file);
                final progressState = progressStates.value[index];
                final fileName = file.path.split('/').last;
                final fileSize = file.lengthSync();
                final fileSizeText =
                    fileSize < 1024 * 1024
                        ? '${(fileSize / 1024).toStringAsFixed(1)} KB'
                        : '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';

                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Symbols.description,
                              size: 20,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const Gap(8),
                            Expanded(
                              child: Text(
                                fileName,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(fontWeight: FontWeight.w500),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              fileSizeText,
                              style: Theme.of(
                                context,
                              ).textTheme.bodySmall?.copyWith(
                                color:
                                    Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                        if (progressState['status'] == 'uploading') ...[
                          const Gap(8),
                          LinearProgressIndicator(
                            value: progressState['progress'],
                            backgroundColor:
                                Theme.of(context).colorScheme.surfaceVariant,
                          ),
                          const Gap(4),
                          Text(
                            'Uploading... ${(progressState['progress'] * 100).toStringAsFixed(0)}%',
                            style: Theme.of(
                              context,
                            ).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ] else if (progressState['status'] == 'completed') ...[
                          const Gap(8),
                          Row(
                            children: [
                              Icon(
                                Symbols.check_circle,
                                color: Colors.green,
                                size: 16,
                              ),
                              const Gap(4),
                              Text(
                                'Completed',
                                style: TextStyle(
                                  color: Colors.green,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ] else if (progressState['status'] == 'error') ...[
                          const Gap(8),
                          Row(
                            children: [
                              Icon(Symbols.error, color: Colors.red, size: 16),
                              const Gap(4),
                              Expanded(
                                child: Text(
                                  progressState['error'] ?? 'Upload failed',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 12,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                        // Show the final upload path when not uploading
                        if (!isUploading.value &&
                            progressState['status'] != 'uploading') ...[
                          const Gap(8),
                          Text(
                            'Will upload to: ${pathController.text.endsWith('/') ? pathController.text : '${pathController.text}/'}$fileName',
                            style: Theme.of(
                              context,
                            ).textTheme.bodySmall?.copyWith(
                              color:
                                  Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              }),
              const Gap(24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed:
                          isUploading.value
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
}
