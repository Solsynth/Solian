import 'package:desktop_drop/desktop_drop.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/models/file_list_item.dart';
import 'package:island/models/file.dart';
import 'package:island/pods/file_list.dart';
import 'package:island/pods/network.dart';
import 'package:island/services/file_uploader.dart';
import 'package:island/services/responsive.dart';
import 'package:island/utils/file_icon_utils.dart';
import 'package:island/utils/format.dart';
import 'package:island/widgets/alert.dart';
import 'package:island/widgets/content/cloud_files.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:riverpod_paging_utils/riverpod_paging_utils.dart';
import 'package:styled_widget/styled_widget.dart';

enum FileListMode { normal, unindexed }

enum FileListViewMode { list, waterfall }

class FileListView extends HookConsumerWidget {
  final Map<String, dynamic>? usage;
  final Map<String, dynamic>? quota;
  final ValueNotifier<String> currentPath;
  final VoidCallback onPickAndUpload;
  final Function(BuildContext, ValueNotifier<String>) onShowCreateDirectory;
  final ValueNotifier<FileListMode> mode;
  final ValueNotifier<FileListViewMode> viewMode;

  const FileListView({
    required this.usage,
    required this.quota,
    required this.currentPath,
    required this.onPickAndUpload,
    required this.onShowCreateDirectory,
    required this.mode,
    required this.viewMode,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dragging = useState(false);

    useEffect(() {
      if (mode.value == FileListMode.normal) {
        final notifier = ref.read(cloudFileListNotifierProvider.notifier);
        notifier.setPath(currentPath.value);
      }
      return null;
    }, [currentPath.value, mode.value]);

    if (usage == null) return const SizedBox.shrink();

    final bodyWidget = switch (mode.value) {
      FileListMode.unindexed => PagingHelperSliverView(
        provider: unindexedFileListNotifierProvider,
        futureRefreshable: unindexedFileListNotifierProvider.future,
        notifierRefreshable: unindexedFileListNotifierProvider.notifier,
        contentBuilder:
            (data, widgetCount, endItemView) =>
                data.items.isEmpty
                    ? SliverToBoxAdapter(
                      child: _buildEmptyUnindexedFilesHint(ref),
                    )
                    : _buildUnindexedFileListContent(
                      data.items,
                      widgetCount,
                      endItemView,
                      ref,
                      context,
                      viewMode,
                    ),
      ),
      _ => PagingHelperSliverView(
        provider: cloudFileListNotifierProvider,
        futureRefreshable: cloudFileListNotifierProvider.future,
        notifierRefreshable: cloudFileListNotifierProvider.notifier,
        contentBuilder:
            (data, widgetCount, endItemView) =>
                data.items.isEmpty
                    ? SliverToBoxAdapter(
                      child: _buildEmptyDirectoryHint(ref, currentPath),
                    )
                    : _buildFileListContent(
                      data.items,
                      widgetCount,
                      endItemView,
                      ref,
                      context,
                      currentPath,
                      viewMode,
                    ),
      ),
    };

    return DropTarget(
      onDragDone: (details) async {
        dragging.value = false;
        // Handle file upload
        for (final file in details.files) {
          final universalFile = UniversalFile(
            data: file,
            type: UniversalFileType.file,
            displayName: file.name,
          );

          final completer = FileUploader.createCloudFile(
            fileData: universalFile,
            ref: ref,
            path: currentPath.value,
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
      },
      onDragEntered: (details) {
        dragging.value = true;
      },
      onDragExited: (details) {
        dragging.value = false;
      },
      child: Container(
        color:
            dragging.value
                ? Theme.of(context).primaryColor.withOpacity(0.1)
                : null,
        child: Column(
          children: [
            const Gap(8),
            _buildPathNavigation(ref, currentPath),
            const Gap(8),
            if (mode.value == FileListMode.normal && currentPath.value == '/')
              _buildUnindexedFilesEntry(ref).padding(bottom: 12),
            Expanded(
              child: CustomScrollView(
                slivers: [bodyWidget, const SliverGap(12)],
              ).padding(
                horizontal:
                    viewMode.value == FileListViewMode.waterfall ? 12 : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFileListContent(
    List<FileListItem> items,
    int widgetCount,
    Widget endItemView,
    WidgetRef ref,
    BuildContext context,
    ValueNotifier<String> currentPath,
    ValueNotifier<FileListViewMode> currentViewMode,
  ) {
    return switch (currentViewMode.value) {
      // Waterfall mode
      FileListViewMode.waterfall => SliverMasonryGrid(
        gridDelegate: SliverSimpleGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: isWideScreen(context) ? 340 : 240,
        ),
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        delegate: SliverChildBuilderDelegate((context, index) {
          if (index == widgetCount - 1) {
            return endItemView;
          }

          if (index >= items.length) {
            return const SizedBox.shrink();
          }

          final item = items[index];
          return item.map(
            file: (fileItem) => _buildWaterfallFileTile(fileItem, ref, context),
            folder:
                (folderItem) =>
                    _buildWaterfallFolderTile(folderItem, currentPath, context),
            unindexedFile: (unindexedFileItem) {
              // Should not happen
              return const SizedBox.shrink();
            },
          );
        }, childCount: widgetCount),
      ),
      // ListView mode
      _ => SliverList.builder(
        itemCount: widgetCount,
        itemBuilder: (context, index) {
          if (index == widgetCount - 1) {
            return endItemView;
          }

          final item = items[index];
          return item.map(
            file: (fileItem) {
              final file = fileItem.fileIndex.file;
              return ListTile(
                leading: ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                  child: SizedBox(
                    height: 48,
                    width: 48,
                    child: getFileIcon(file, size: 24),
                  ),
                ),
                title:
                    file.name.isEmpty
                        ? Text('untitled').tr().italic()
                        : Text(
                          file.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                subtitle: Text(formatFileSize(file.size)),
                onTap: () {
                  context.push('/files/${fileItem.fileIndex.id}', extra: file);
                },
                trailing: IconButton(
                  icon: const Icon(Symbols.delete),
                  onPressed: () async {
                    final confirmed = await showConfirmAlert(
                      'confirmDeleteFile'.tr(),
                      'deleteFile'.tr(),
                    );
                    if (!confirmed) return;

                    if (context.mounted) {
                      showLoadingModal(context);
                    }
                    try {
                      final client = ref.read(apiClientProvider);
                      await client.delete(
                        '/drive/index/remove/${fileItem.fileIndex.id}',
                      );
                      ref.invalidate(cloudFileListNotifierProvider);
                    } catch (e) {
                      showSnackBar('failedToDeleteFile'.tr());
                    } finally {
                      if (context.mounted) {
                        hideLoadingModal(context);
                      }
                    }
                  },
                ),
              );
            },
            folder:
                (folderItem) => ListTile(
                  leading: ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(8)),
                    child: SizedBox(
                      height: 48,
                      width: 48,
                      child: const Icon(Symbols.folder, fill: 1).center(),
                    ),
                  ),
                  title: Text(
                    folderItem.folderName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: const Text('Folder'),
                  onTap: () {
                    final newPath =
                        currentPath.value == '/'
                            ? '/${folderItem.folderName}'
                            : '${currentPath.value}/${folderItem.folderName}';
                    currentPath.value = newPath;
                  },
                ),
            unindexedFile: (unindexedFileItem) {
              // Should not happen in normal mode
              return const SizedBox.shrink();
            },
          );
        },
      ),
    };
  }

  Widget _buildPathNavigation(
    WidgetRef ref,
    ValueNotifier<String> currentPath,
  ) {
    Widget pathContent;
    if (mode.value == FileListMode.unindexed) {
      pathContent = Row(
        children: [
          Text(
            'Unindexed Files',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      );
    } else if (currentPath.value == '/') {
      pathContent = Text(
        'Root Directory',
        style: TextStyle(fontWeight: FontWeight.bold),
      );
    } else {
      final pathParts =
          currentPath.value
              .split('/')
              .where((part) => part.isNotEmpty)
              .toList();
      final breadcrumbs = <Widget>[];

      // Add root
      breadcrumbs.add(
        InkWell(onTap: () => currentPath.value = '/', child: Text('Root')),
      );

      // Add path parts
      String currentPathBuilder = '';
      for (int i = 0; i < pathParts.length; i++) {
        currentPathBuilder += '/${pathParts[i]}';
        final path = currentPathBuilder;

        breadcrumbs.add(const Text(' / '));
        if (i == pathParts.length - 1) {
          // Current directory
          breadcrumbs.add(
            Text(pathParts[i], style: TextStyle(fontWeight: FontWeight.bold)),
          );
        } else {
          // Clickable parent directory
          breadcrumbs.add(
            InkWell(
              onTap: () => currentPath.value = path,
              child: Text(pathParts[i]),
            ),
          );
        }
      }

      pathContent = Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        children: breadcrumbs,
      );
    }

    return SizedBox(
      height: 64,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              IconButton(
                icon: Icon(
                  mode.value == FileListMode.unindexed
                      ? Symbols.inventory_2
                      : Symbols.folder,
                ),
                onPressed: () {
                  if (mode.value == FileListMode.unindexed) {
                    mode.value = FileListMode.normal;
                  }
                  currentPath.value = '/';
                },
                visualDensity: const VisualDensity(
                  horizontal: -4,
                  vertical: -4,
                ),
              ),
              const Gap(8),
              Expanded(child: pathContent),
              IconButton(
                icon: Icon(
                  viewMode.value == FileListViewMode.list
                      ? Symbols.view_module
                      : Symbols.list,
                ),
                onPressed:
                    () =>
                        viewMode.value =
                            viewMode.value == FileListViewMode.list
                                ? FileListViewMode.waterfall
                                : FileListViewMode.list,
                tooltip:
                    viewMode.value == FileListViewMode.list
                        ? 'Switch to Waterfall View'
                        : 'Switch to List View',
                visualDensity: const VisualDensity(
                  horizontal: -4,
                  vertical: -4,
                ),
              ),
              if (mode.value == FileListMode.normal) ...[
                IconButton(
                  icon: const Icon(Symbols.create_new_folder),
                  onPressed:
                      () => onShowCreateDirectory(ref.context, currentPath),
                  tooltip: 'Create Directory',
                  visualDensity: const VisualDensity(
                    horizontal: -4,
                    vertical: -4,
                  ),
                ),
                IconButton(
                  icon: const Icon(Symbols.upload_file),
                  onPressed: onPickAndUpload,
                  tooltip: 'Upload File',
                  visualDensity: const VisualDensity(
                    horizontal: -4,
                    vertical: -4,
                  ),
                ),
              ],
            ],
          ),
        ),
      ).padding(horizontal: 8),
    );
  }

  Widget _buildUnindexedFilesEntry(WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(ref.context).colorScheme.outline),
        borderRadius: const BorderRadius.all(Radius.circular(8)),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 12),
      child: InkWell(
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              const Icon(Symbols.inventory_2).padding(horizontal: 8),
              const Gap(8),
              const Text('Unindexed Files').bold(),
              const Spacer(),
              const Icon(Symbols.chevron_right).padding(horizontal: 8),
            ],
          ),
        ),
        onTap: () {
          mode.value = FileListMode.unindexed;
          currentPath.value = '/';
        },
      ),
    );
  }

  Widget _buildEmptyDirectoryHint(
    WidgetRef ref,
    ValueNotifier<String> currentPath,
  ) {
    return Card(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Symbols.folder_off, size: 64, color: Colors.grey),
            const Gap(16),
            Text(
              'This directory is empty',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(ref.context).textTheme.bodyLarge?.color,
              ),
            ),
            const Gap(8),
            Text(
              'Upload files or create subdirectories to populate this path.\n'
              'Directories are created implicitly when you upload files to them.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(
                  ref.context,
                ).textTheme.bodyMedium?.color?.withOpacity(0.7),
              ),
            ),
            const Gap(16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: onPickAndUpload,
                  icon: const Icon(Symbols.upload_file),
                  label: const Text('Upload Files'),
                ),
                const Gap(12),
                OutlinedButton.icon(
                  onPressed:
                      () => onShowCreateDirectory(ref.context, currentPath),
                  icon: const Icon(Symbols.create_new_folder),
                  label: const Text('Create Directory'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWaterfallFileTile(
    FileItem fileItem,
    WidgetRef ref,
    BuildContext context,
  ) {
    return _buildWaterfallFileTileBase(
      fileItem.fileIndex.file,
      () => '/files/${fileItem.fileIndex.id}',
      ref,
      context,
      [
        IconButton(
          icon: const Icon(Symbols.delete),
          onPressed: () async {
            final confirmed = await showConfirmAlert(
              'confirmDeleteFile'.tr(),
              'deleteFile'.tr(),
            );
            if (!confirmed) return;

            if (context.mounted) {
              showLoadingModal(context);
            }
            try {
              final client = ref.read(apiClientProvider);
              await client.delete(
                '/drive/index/remove/${fileItem.fileIndex.id}',
              );
              ref.invalidate(cloudFileListNotifierProvider);
            } catch (e) {
              showSnackBar('failedToDeleteFile'.tr());
            } finally {
              if (context.mounted) {
                hideLoadingModal(context);
              }
            }
          },
        ),
      ],
    );
  }

  Widget _buildWaterfallFileTileBase(
    SnCloudFile file,
    String Function() getRoutePath,
    WidgetRef ref,
    BuildContext context,
    List<Widget>? actions,
  ) {
    final meta = file.fileMeta is Map ? (file.fileMeta as Map) : const {};
    final ratio =
        meta['ratio'] is num ? (meta['ratio'] as num).toDouble() : 1.0;
    final itemType = file.mimeType?.split('/').first;
    final uri =
        '${ref.read(apiClientProvider).options.baseUrl}/drive/files/${file.id}';

    Widget previewWidget;
    switch (itemType) {
      case 'image':
        previewWidget = CloudImageWidget(
          file: file,
          aspectRatio: ratio,
          fit: BoxFit.cover,
        );
        break;
      case 'video':
        previewWidget = CloudVideoWidget(item: file);
        break;
      case 'audio':
        previewWidget = getFileIcon(file, size: 48);
        break;
      case 'text':
        previewWidget = FutureBuilder<String>(
          future: ref
              .read(apiClientProvider)
              .get(uri)
              .then((response) => response.data as String),
          builder:
              (context, snapshot) =>
                  snapshot.hasData
                      ? SingleChildScrollView(
                        child: Text(
                          snapshot.data!,
                          style: const TextStyle(
                            fontSize: 8,
                            fontFamily: 'monospace',
                          ),
                          maxLines: 20,
                          overflow: TextOverflow.ellipsis,
                        ),
                      )
                      : const Center(child: CircularProgressIndicator()),
        );
        break;
      case 'application' when file.mimeType == 'application/pdf':
        previewWidget = SfPdfViewer.network(
          uri,
          canShowScrollStatus: false,
          canShowScrollHead: false,
          enableDoubleTapZooming: false,
          pageSpacing: 0,
        );
        break;
      default:
        previewWidget = getFileIcon(file, size: 48);
        break;
    }

    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () {
        context.push(getRoutePath(), extra: file);
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
          ),
        ),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
              child: AspectRatio(
                aspectRatio: ratio,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Container(color: Colors.white, child: previewWidget),
                ),
              ),
            ),
            Row(
              children: [
                getFileIcon(file, size: 24, tinyPreview: false),
                const Gap(16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        file.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        formatFileSize(file.size),
                        maxLines: 1,
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall!.copyWith(fontSize: 11),
                      ),
                    ],
                  ),
                ),
                if (actions != null) ...actions,
              ],
            ).padding(horizontal: 16, vertical: 4),
          ],
        ),
      ),
    );
  }

  Widget _buildWaterfallFolderTile(
    FolderItem folderItem,
    ValueNotifier<String> currentPath,
    BuildContext context,
  ) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () {
        final newPath =
            currentPath.value == '/'
                ? '/${folderItem.folderName}'
                : '${currentPath.value}/${folderItem.folderName}';
        currentPath.value = newPath;
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Symbols.folder,
              fill: 1,
              size: 24,
              color: Theme.of(context).colorScheme.primaryFixedDim,
            ),
            const Gap(16),
            Text(
              folderItem.folderName,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnindexedFileListContent(
    List<FileListItem> items,
    int widgetCount,
    Widget endItemView,
    WidgetRef ref,
    BuildContext context,
    ValueNotifier<FileListViewMode> currentViewMode,
  ) {
    return switch (currentViewMode.value) {
      // Waterfall mode
      FileListViewMode.waterfall => SliverMasonryGrid(
        gridDelegate: SliverSimpleGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: isWideScreen(context) ? 340 : 240,
        ),
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        delegate: SliverChildBuilderDelegate((context, index) {
          if (index == widgetCount - 1) {
            return endItemView;
          }

          if (index >= items.length) {
            return const SizedBox.shrink();
          }

          final item = items[index];
          return item.map(
            file: (fileItem) {
              // Should not happen in unindexed mode
              return const SizedBox.shrink();
            },
            folder: (folderItem) {
              // Should not happen in unindexed mode
              return const SizedBox.shrink();
            },
            unindexedFile:
                (unindexedFileItem) => _buildWaterfallUnindexedFileTile(
                  unindexedFileItem,
                  ref,
                  context,
                ),
          );
        }, childCount: widgetCount),
      ),
      // ListView mode
      _ => SliverList.builder(
        itemCount: widgetCount,
        itemBuilder: (context, index) {
          if (index == widgetCount - 1) {
            return endItemView;
          }

          final item = items[index];
          return item.map(
            file: (fileItem) {
              // Should not happen in unindexed mode
              return const SizedBox.shrink();
            },
            folder: (folderItem) {
              // Should not happen in unindexed mode
              return const SizedBox.shrink();
            },
            unindexedFile:
                (unindexedFileItem) => _buildListUnindexedFileTile(
                  unindexedFileItem,
                  ref,
                  context,
                ),
          );
        },
      ),
    };
  }

  Widget _buildWaterfallUnindexedFileTile(
    UnindexedFileItem unindexedFileItem,
    WidgetRef ref,
    BuildContext context,
  ) {
    return _buildWaterfallFileTileBase(
      unindexedFileItem.file,
      () => '/files/${unindexedFileItem.file.id}',
      ref,
      context,
      [
        IconButton(
          icon: const Icon(Symbols.delete),
          onPressed: () async {
            final confirmed = await showConfirmAlert(
              'confirmDeleteFile'.tr(),
              'deleteFile'.tr(),
            );
            if (!confirmed) return;

            if (context.mounted) {
              showLoadingModal(context);
            }
            try {
              final client = ref.read(apiClientProvider);
              await client.delete('/drive/files/${unindexedFileItem.file.id}');
              ref.invalidate(unindexedFileListNotifierProvider);
            } catch (e) {
              showSnackBar('failedToDeleteFile'.tr());
            } finally {
              if (context.mounted) {
                hideLoadingModal(context);
              }
            }
          },
        ),
      ],
    );
  }

  Widget _buildListUnindexedFileTile(
    UnindexedFileItem unindexedFileItem,
    WidgetRef ref,
    BuildContext context,
  ) {
    final file = unindexedFileItem.file;
    return ListTile(
      leading: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        child: SizedBox(
          height: 48,
          width: 48,
          child: getFileIcon(file, size: 24),
        ),
      ),
      title:
          file.name.isEmpty
              ? Text('untitled').tr().italic()
              : Text(file.name, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(formatFileSize(file.size)),
      onTap: () {
        context.push('/files/${file.id}', extra: file);
      },
      trailing: IconButton(
        icon: const Icon(Symbols.delete),
        onPressed: () async {
          final confirmed = await showConfirmAlert(
            'confirmDeleteFile'.tr(),
            'deleteFile'.tr(),
          );
          if (!confirmed) return;

          if (context.mounted) {
            showLoadingModal(context);
          }
          try {
            final client = ref.read(apiClientProvider);
            await client.delete('/drive/files/${file.id}');
            ref.invalidate(unindexedFileListNotifierProvider);
          } catch (e) {
            showSnackBar('failedToDeleteFile'.tr());
          } finally {
            if (context.mounted) {
              hideLoadingModal(context);
            }
          }
        },
      ),
    );
  }

  Widget _buildEmptyUnindexedFilesHint(WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Symbols.inventory_2, size: 64, color: Colors.grey),
            const Gap(16),
            Text(
              'No unindexed files',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(ref.context).textTheme.bodyLarge?.color,
              ),
            ),
            const Gap(8),
            Text(
              'All files have been assigned to paths.\n'
              'Files without paths will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(
                  ref.context,
                ).textTheme.bodyMedium?.color?.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
