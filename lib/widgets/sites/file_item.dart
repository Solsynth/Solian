import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/models/site_file.dart';
import 'package:island/models/publication_site.dart';
import 'package:island/pods/site_files.dart';
import 'package:island/widgets/alert.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:styled_widget/styled_widget.dart';

class FileItem extends HookConsumerWidget {
  final SnSiteFileEntry file;
  final SnPublicationSite site;
  final void Function(String path)? onNavigateDirectory;

  const FileItem({
    super.key,
    required this.file,
    required this.site,
    this.onNavigateDirectory,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Card(
      color: Theme.of(context).colorScheme.surfaceContainerHigh,
      elevation: 0,
      child: ListTile(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        leading: Icon(
          file.isDirectory ? Symbols.folder : Symbols.description,
          color: theme.colorScheme.primary,
        ),
        title: Text(file.relativePath),
        subtitle: Text(
          file.isDirectory
              ? 'Directory'
              : '${(file.size / 1024).toStringAsFixed(1)} KB',
        ),
        trailing: PopupMenuButton<String>(
          itemBuilder:
              (context) => [
                PopupMenuItem(
                  value: 'download',
                  child: Row(
                    children: [
                      const Icon(Symbols.download),
                      const Gap(16),
                      Text('Download'),
                    ],
                  ),
                ),
                if (!file.isDirectory) ...[
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        const Icon(Symbols.edit),
                        const Gap(16),
                        Text('Edit Content'),
                      ],
                    ),
                  ),
                ],
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      const Icon(Symbols.delete, color: Colors.red),
                      const Gap(16),
                      Text('Delete').textColor(Colors.red),
                    ],
                  ),
                ),
              ],
          onSelected: (value) async {
            switch (value) {
              case 'download':
                // TODO: Implement file download
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Downloading ${file.relativePath}')),
                );
                break;
              case 'edit':
                // TODO: Implement file editing
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Editing ${file.relativePath}')),
                );
                break;
              case 'delete':
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder:
                      (context) => AlertDialog(
                        title: const Text('Delete File'),
                        content: Text(
                          'Are you sure you want to delete "${file.relativePath}"?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                );

                if (confirmed == true) {
                  try {
                    await ref
                        .read(
                          siteFilesNotifierProvider((
                            siteId: site.id,
                            path: null,
                          )).notifier,
                        )
                        .deleteFile(file.relativePath);
                    showSnackBar('File deleted successfully');
                  } catch (e) {
                    showErrorAlert(e);
                  }
                }
                break;
            }
          },
        ),
        onTap: () {
          if (file.isDirectory) {
            onNavigateDirectory?.call(file.relativePath);
          } else {
            // TODO: Open file preview/editor
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Opening file: ${file.relativePath}')),
            );
          }
        },
      ),
    );
  }
}
