import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/models/publication_site.dart';
import 'package:island/pods/site_files.dart';
import 'package:island/widgets/sites/file_upload_dialog.dart';
import 'package:island/widgets/sites/file_item.dart';
import 'package:material_symbols_icons/symbols.dart';

class FileManagementSection extends HookConsumerWidget {
  final SnPublicationSite site;
  final String pubName;

  const FileManagementSection({
    super.key,
    required this.site,
    required this.pubName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filesAsync = ref.watch(siteFilesProvider(siteId: site.id));
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Symbols.folder, size: 20),
                const Gap(8),
                Text(
                  'File Management',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () async {
                    // Open file upload dialog
                    final selectedFiles = await FilePicker.platform.pickFiles(
                      allowMultiple: true,
                      type: FileType.any,
                    );

                    if (selectedFiles == null || selectedFiles.files.isEmpty) {
                      return; // User canceled
                    }

                    if (!context.mounted) return;

                    // Show upload dialog for path specification
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder:
                          (context) => FileUploadDialog(
                            selectedFiles:
                                selectedFiles.files
                                    .map((f) => File(f.path!))
                                    .toList(),
                            site: site,
                            onUploadComplete: () {
                              // Refresh file list
                              ref.invalidate(
                                siteFilesProvider(siteId: site.id),
                              );
                            },
                          ),
                    );
                  },
                  icon: const Icon(Symbols.upload),
                  visualDensity: const VisualDensity(
                    horizontal: -4,
                    vertical: -4,
                  ),
                ),
              ],
            ),
            const Gap(16),
            filesAsync.when(
              data: (files) {
                if (files.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          Icon(
                            Symbols.folder,
                            size: 48,
                            color: theme.colorScheme.outline,
                          ),
                          const Gap(16),
                          Text(
                            'No files uploaded yet',
                            style: theme.textTheme.bodyLarge,
                          ),
                          const Gap(8),
                          Text(
                            'Upload your first file to get started',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  itemCount: files.length,
                  itemBuilder: (context, index) {
                    final file = files[index];
                    return FileItem(file: file, site: site);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error:
                  (error, stack) => Center(
                    child: Column(
                      children: [
                        Text('Failed to load files'),
                        const Gap(8),
                        ElevatedButton(
                          onPressed:
                              () => ref.invalidate(
                                siteFilesProvider(siteId: site.id),
                              ),
                          child: const Text('Retry'),
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
}
