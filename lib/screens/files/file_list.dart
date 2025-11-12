import 'package:cross_file/cross_file.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/models/file.dart';
import 'package:island/pods/network.dart';
import 'package:island/services/file_uploader.dart';
import 'package:island/utils/format.dart';
import 'package:island/widgets/alert.dart';
import 'package:island/widgets/app_scaffold.dart';
import 'package:island/widgets/content/cloud_files.dart';
import 'package:island/widgets/content/file_info_sheet.dart';
import 'package:island/widgets/content/sheet.dart';
import 'package:island/widgets/usage_overview.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:riverpod_paging_utils/riverpod_paging_utils.dart';
import 'package:styled_widget/styled_widget.dart';

part 'file_list.g.dart';

@riverpod
class CloudFileListNotifier extends _$CloudFileListNotifier
    with CursorPagingNotifierMixin<SnCloudFileIndex> {
  String _currentPath = '/';

  void setPath(String path) {
    _currentPath = path;
    ref.invalidateSelf();
  }

  @override
  Future<CursorPagingData<SnCloudFileIndex>> build() => fetch(cursor: null);

  @override
  Future<CursorPagingData<SnCloudFileIndex>> fetch({
    required String? cursor,
  }) async {
    final client = ref.read(apiClientProvider);

    final response = await client.get(
      '/drive/index/browse',
      queryParameters: {'path': _currentPath},
    );

    final List<SnCloudFileIndex> items =
        (response.data['files'] as List)
            .map((e) => SnCloudFileIndex.fromJson(e as Map<String, dynamic>))
            .toList();

    // The new API returns all files in the path, no pagination
    return CursorPagingData(items: items, hasMore: false, nextCursor: null);
  }
}

@riverpod
Future<Map<String, dynamic>?> billingUsage(Ref ref) async {
  final client = ref.read(apiClientProvider);
  final response = await client.get('/drive/billing/usage');
  return response.data;
}

@riverpod
Future<Map<String, dynamic>?> billingQuota(Ref ref) async {
  final client = ref.read(apiClientProvider);
  final response = await client.get('/drive/billing/quota');
  return response.data;
}

class FileListScreen extends HookConsumerWidget {
  const FileListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Path navigation state
    final currentPath = useState<String>('/');

    final usageAsync = ref.watch(billingUsageProvider);
    final quotaAsync = ref.watch(billingQuotaProvider);

    // Update notifier path when state changes
    useEffect(() {
      final notifier = ref.read(cloudFileListNotifierProvider.notifier);
      notifier.setPath(currentPath.value);
      return null;
    }, [currentPath.value]);

    return AppScaffold(
      isNoBackground: false,
      appBar: AppBar(
        title: Text('Files'),
        leading: const PageBackButton(),
        actions: [
          IconButton(
            icon: const Icon(Symbols.upload_file),
            onPressed: () => _pickAndUploadFile(ref, currentPath.value),
            tooltip: 'Upload File',
          ),
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
              data: (quota) => _buildQuotaUI(usage, quota, ref, currentPath),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error loading quota')),
            ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error loading usage')),
      ),
    );
  }

  Widget _buildQuotaUI(
    Map<String, dynamic>? usage,
    Map<String, dynamic>? quota,
    WidgetRef ref,
    ValueNotifier<String> currentPath,
  ) {
    if (usage == null) return const SizedBox.shrink();
    return CustomScrollView(
      slivers: [
        const SliverGap(8),
        SliverToBoxAdapter(child: _buildPathNavigation(ref, currentPath)),
        const SliverGap(8),
        PagingHelperSliverView(
          provider: cloudFileListNotifierProvider,
          futureRefreshable: cloudFileListNotifierProvider.future,
          notifierRefreshable: cloudFileListNotifierProvider.notifier,
          contentBuilder:
              (data, widgetCount, endItemView) => SliverList.builder(
                itemCount: widgetCount,
                itemBuilder: (context, index) {
                  if (index == widgetCount - 1) {
                    return endItemView;
                  }

                  final item = data.items[index];
                  final file = item.file;
                  final itemType = file.mimeType?.split('/').firstOrNull;
                  return ListTile(
                    leading: ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(8)),
                      child: SizedBox(
                        height: 48,
                        width: 48,
                        child: switch (itemType) {
                          'image' => CloudImageWidget(file: file),
                          'audio' =>
                            const Icon(Symbols.audio_file, fill: 1).center(),
                          'video' =>
                            const Icon(Symbols.video_file, fill: 1).center(),
                          _ =>
                            const Icon(Symbols.body_system, fill: 1).center(),
                        },
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
                      showModalBottomSheet(
                        useRootNavigator: true,
                        context: context,
                        isScrollControlled: true,
                        builder: (context) => FileInfoSheet(item: file),
                      );
                    },
                    trailing: IconButton(
                      icon: const Icon(Symbols.delete),
                      onPressed: () async {
                        final confirmed = await showConfirmAlert(
                          'confirmDeleteFile'.tr(),
                          'deleteFile'.tr(),
                        );
                        if (!confirmed) return;

                        if (context.mounted) showLoadingModal(context);
                        try {
                          final client = ref.read(apiClientProvider);
                          await client.delete('/drive/index/remove/${item.id}');
                          ref.invalidate(cloudFileListNotifierProvider);
                        } catch (e) {
                          showSnackBar('failedToDeleteFile'.tr());
                        } finally {
                          if (context.mounted) hideLoadingModal(context);
                        }
                      },
                    ),
                  );
                },
              ),
        ),
      ],
    );
  }

  Widget _buildPathNavigation(
    WidgetRef ref,
    ValueNotifier<String> currentPath,
  ) {
    if (currentPath.value == '/') {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(Symbols.folder),
              const Gap(8),
              Text(
                'Root Directory',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ).padding(horizontal: 8);
    }

    final pathParts =
        currentPath.value.split('/').where((part) => part.isNotEmpty).toList();
    final breadcrumbs = <Widget>[];

    // Add root
    breadcrumbs.add(
      InkWell(
        onTap: () => currentPath.value = '/',
        child: Text(
          'Root',
          style: TextStyle(color: Theme.of(ref.context).primaryColor),
        ),
      ),
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
            child: Text(
              pathParts[i],
              style: TextStyle(color: Theme.of(ref.context).primaryColor),
            ),
          ),
        );
      }
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Symbols.folder),
            const Gap(8),
            Expanded(
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                children: breadcrumbs,
              ),
            ),
          ],
        ),
      ),
    ).padding(horizontal: 8);
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
                    // Refresh the file list after successful upload
                    ref.invalidate(cloudFileListNotifierProvider);
                    showSnackBar('File uploaded successfully');
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
