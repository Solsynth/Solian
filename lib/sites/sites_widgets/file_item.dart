import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:flutter_highlight/themes/monokai-sublime.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/discovery/discovery_models/site_file.dart';
import 'package:island/creators/publication_site.dart';
import 'package:island/core/network.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/core/widgets/content/sheet.dart';
import 'package:island/sites/site_files.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:path_provider/path_provider.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:photo_view/photo_view.dart';
import 'package:island/core/config.dart';

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

  Future<void> _downloadFile(BuildContext context, WidgetRef ref) async {
    try {
      final apiClient = ref.read(apiClientProvider);

      // Get downloads directory
      Directory? directory;
      if (Platform.isAndroid) {
        directory = await getExternalStorageDirectory();
        if (directory != null) {
          directory = Directory('${directory.path}/Download');
        }
      } else {
        directory = await getDownloadsDirectory();
      }

      if (directory == null) {
        throw Exception('Unable to access downloads directory');
      }

      // Create directory if it doesn't exist
      await directory.create(recursive: true);

      // Generate file path
      final fileName = file.relativePath.split('/').last;
      final filePath = '${directory.path}/$fileName';

      // Use Dio's download method to directly stream from server to file
      await apiClient.download(
        '/zone/sites/${site.id}/files/content/${file.relativePath}',
        filePath,
      );

      showSnackBar('Downloaded to $filePath');
    } catch (e) {
      showErrorAlert(e);
    }
  }

  Future<void> _showImageViewer(BuildContext context, WidgetRef ref) async {
    final serverUrl = ref.read(serverUrlProvider);
    final token = await getToken(ref.read(tokenProvider));
    final imageUrl =
        '$serverUrl/zone/sites/${site.id}/files/content/${file.relativePath}';

    if (context.mounted) {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(
              title: Text(file.relativePath),
              backgroundColor: Colors.transparent,
              elevation: 0,
            ),
            extendBodyBehindAppBar: true,
            backgroundColor: Colors.black,
            body: PhotoView(
              imageProvider: CachedNetworkImageProvider(
                imageUrl,
                headers: token != null
                    ? {'Authorization': 'AtField $token'}
                    : null,
              ),
              heroAttributes: PhotoViewHeroAttributes(tag: file.relativePath),
            ),
          ),
        ),
      );
    }
  }

  Future<void> _openFile(BuildContext context, WidgetRef ref) async {
    final ext = file.relativePath.split('.').last.toLowerCase();
    final isImage = [
      'jpg',
      'jpeg',
      'png',
      'gif',
      'webp',
      'bmp',
      'ico',
      'svg',
    ].contains(ext);

    if (isImage) {
      await _showImageViewer(context, ref);
      return;
    }

    // Check for large files (> 1MB)
    if (file.size > 1024 * 1024) {
      final confirmed = await showConfirmAlert(
        'This file is large (${(file.size / 1024 / 1024).toStringAsFixed(2)} MB). Opening it might cause performance issues. Do you want to continue?',
        'Large File',
      );

      if (confirmed != true) return;
    }

    if (context.mounted) await _showEditSheet(context, ref);
  }

  Future<void> _showEditSheet(BuildContext context, WidgetRef ref) async {
    try {
      final fileContent = await ref.read(
        siteFileContentProvider(
          siteId: site.id,
          relativePath: file.relativePath,
        ).future,
      );

      if (context.mounted) {
        await showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          useSafeArea: false,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height,
          ),
          barrierColor: Theme.of(context).colorScheme.surfaceContainerLow,
          backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
          builder: (BuildContext context) {
            return FileEditorSheet(
              file: file,
              site: site,
              initialContent: fileContent.content,
            );
          },
        );
      }
    } catch (e) {
      showErrorAlert(e);
    }
  }

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
          itemBuilder: (context) => [
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
                    Text('Open'),
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
                await _downloadFile(context, ref);
                break;
              case 'edit':
                await _openFile(context, ref);
                break;
              case 'delete':
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
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
            _openFile(context, ref);
          }
        },
      ),
    );
  }
}

class FileEditorSheet extends HookConsumerWidget {
  final SnSiteFileEntry file;
  final SnPublicationSite site;
  final String initialContent;

  const FileEditorSheet({
    super.key,
    required this.file,
    required this.site,
    required this.initialContent,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final codeController = useMemoized(
      () => CodeController(
        text: initialContent,
        language: null, // Let the editor auto-detect or use plain text
      ),
    );
    final isSaving = useState(false);

    final saveFile = useCallback(() async {
      if (codeController.text.trim().isEmpty) {
        showSnackBar('contentCantEmpty'.tr());
        return;
      }

      isSaving.value = true;
      try {
        await ref
            .read(
              siteFilesNotifierProvider((siteId: site.id, path: null)).notifier,
            )
            .updateFileContent(file.relativePath, codeController.text);

        if (context.mounted) {
          showSnackBar('File saved successfully');
          Navigator.of(context).pop();
        }
      } catch (e) {
        showErrorAlert(e);
      } finally {
        isSaving.value = false;
      }
    }, [codeController, ref, site.id, file.relativePath, context, isSaving]);

    return SheetScaffold(
      heightFactor: 1,
      titleText: 'Edit ${file.relativePath}',
      actions: [
        FilledButton(
          onPressed: isSaving.value ? null : saveFile,
          child: Text(isSaving.value ? 'Saving...' : 'Save'),
        ),
      ],
      child: SingleChildScrollView(
        padding: EdgeInsets.zero,
        child: CodeTheme(
          data: CodeThemeData(styles: monokaiSublimeTheme),
          child: CodeField(
            controller: codeController,
            minLines: 20,
            maxLines: null,
          ),
        ),
      ),
    );
  }
}
