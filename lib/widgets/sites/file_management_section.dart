import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/models/publication_site.dart';
import 'package:island/pods/site_files.dart';
import 'package:island/widgets/alert.dart';
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
    final currentPath = useState<String?>(null);
    final filesAsync = ref.watch(
      siteFilesProvider(siteId: site.id, path: currentPath.value),
    );
    final theme = Theme.of(context);

    return Card(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Symbols.folder, size: 20),
                    const Gap(8),
                    Text(
                      'fileManagement'.tr(),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    PopupMenuButton<String>(
                      icon: const Icon(Symbols.upload),
                      onSelected: (String choice) async {
                        List<File> files = [];
                        List<Map<String, dynamic>>? results;
                        if (choice == 'files') {
                          final selectedFiles = await FilePicker.platform
                              .pickFiles(
                                allowMultiple: true,
                                type: FileType.any,
                              );
                          if (selectedFiles == null ||
                              selectedFiles.files.isEmpty) {
                            return; // User canceled
                          }
                          files =
                              selectedFiles.files
                                  .map((f) => File(f.path!))
                                  .toList();
                        } else if (choice == 'folder') {
                          final dirPath =
                              await FilePicker.platform.getDirectoryPath();
                          if (dirPath == null) return;
                          results = await _getFilesRecursive(dirPath);
                          files =
                              results.map((m) => m['file'] as File).toList();
                          if (files.isEmpty) {
                            showSnackBar('noFilesFoundInFolder'.tr());
                            return;
                          }
                        }

                        if (!context.mounted) return;

                        // Show upload dialog for path specification
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          builder:
                              (context) => FileUploadDialog(
                                selectedFiles: files,
                                site: site,
                                relativePaths:
                                    results
                                        ?.map(
                                          (m) => m['relativePath'] as String,
                                        )
                                        .toList(),
                                onUploadComplete: () {
                                  // Refresh file list
                                  ref.invalidate(
                                    siteFilesProvider(
                                      siteId: site.id,
                                      path: currentPath.value,
                                    ),
                                  );
                                },
                              ),
                        );
                      },
                      itemBuilder:
                          (BuildContext context) => [
                            PopupMenuItem<String>(
                              value: 'files',
                              child: Row(
                                children: [
                                  Icon(Symbols.file_copy),
                                  Gap(12),
                                  Text('siteFiles'.tr()),
                                ],
                              ),
                            ),
                            PopupMenuItem<String>(
                              value: 'folder',
                              child: Row(
                                children: [
                                  Icon(Symbols.folder),
                                  Gap(12),
                                  Text('siteFolder'.tr()),
                                ],
                              ),
                            ),
                          ],
                      style: ButtonStyle(
                        visualDensity: const VisualDensity(
                          horizontal: -4,
                          vertical: -4,
                        ),
                      ),
                    ),
                  ],
                ),
                const Gap(8),
                if (currentPath.value != null && currentPath.value!.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(Symbols.arrow_back),
                          onPressed: () {
                            final pathParts =
                                currentPath.value!
                                    .split('/')
                                    .where((part) => part.isNotEmpty)
                                    .toList();
                            if (pathParts.isEmpty) {
                              currentPath.value = null;
                            } else {
                              pathParts.removeLast();
                              currentPath.value =
                                  pathParts.isEmpty
                                      ? null
                                      : pathParts.join('/');
                            }
                          },
                          visualDensity: const VisualDensity(
                            horizontal: -4,
                            vertical: -4,
                          ),
                        ),
                        Expanded(
                          child: Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              InkWell(
                                onTap: () => currentPath.value = null,
                                child: Text('siteRoot'.tr()),
                              ),
                              ...() {
                                final parts =
                                    currentPath.value!
                                        .split('/')
                                        .where((part) => part.isNotEmpty)
                                        .toList();
                                final widgets = <Widget>[];
                                String currentBuilder = '';
                                for (final part in parts) {
                                  currentBuilder +=
                                      (currentBuilder.isEmpty ? '' : '/') +
                                      part;
                                  final pathToSet = currentBuilder;
                                  widgets.addAll([
                                    const Text(' / '),
                                    InkWell(
                                      onTap:
                                          () => currentPath.value = pathToSet,
                                      child: Text(part),
                                    ),
                                  ]);
                                }
                                return widgets;
                              }(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                const Gap(8),
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
                                'noFilesUploadedYet'.tr(),
                                style: theme.textTheme.bodyLarge,
                              ),
                              const Gap(8),
                              Text(
                                'uploadFirstFile'.tr(),
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
                        return FileItem(
                          file: file,
                          site: site,
                          onNavigateDirectory:
                              (path) => currentPath.value = path,
                        );
                      },
                    );
                  },
                  loading:
                      () => const Center(child: CircularProgressIndicator()),
                  error:
                      (error, stack) => Center(
                        child: Column(
                          children: [
                            Text('failedToLoadFiles'.tr()),
                            const Gap(8),
                            ElevatedButton(
                              onPressed:
                                  () => ref.invalidate(
                                    siteFilesProvider(
                                      siteId: site.id,
                                      path: currentPath.value,
                                    ),
                                  ),
                              child: Text('retry'.tr()),
                            ),
                          ],
                        ),
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _getFilesRecursive(String dirPath) async {
    final List<Map<String, dynamic>> results = [];
    try {
      await for (final entity in Directory(dirPath).list(recursive: true)) {
        if (entity is File) {
          String relativePath = entity.path.substring(dirPath.length);
          if (relativePath.startsWith('/')) {
            relativePath = relativePath.substring(1);
          }
          if (relativePath.isEmpty) continue;
          results.add({
            'file': File(entity.path),
            'relativePath': relativePath,
          });
        }
      }
    } catch (e) {
      // Handle error if needed
    }
    return results;
  }
}
