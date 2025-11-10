import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/models/file.dart';
import 'package:island/pods/network.dart';
import 'package:island/pods/file_pool.dart';
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
    with CursorPagingNotifierMixin<SnCloudFile> {
  String? _poolId;
  bool _includeRecycled = false;

  void setFilters(String? poolId, bool includeRecycled) {
    _poolId = poolId;
    _includeRecycled = includeRecycled;
    ref.invalidateSelf();
  }

  @override
  Future<CursorPagingData<SnCloudFile>> build() => fetch(cursor: null);

  @override
  Future<CursorPagingData<SnCloudFile>> fetch({required String? cursor}) async {
    final client = ref.read(apiClientProvider);
    final offset = cursor == null ? 0 : int.parse(cursor);
    final take = 20;

    final queryParameters = <String, dynamic>{'offset': offset, 'take': take};

    // Add filter parameters
    if (_poolId != null) {
      queryParameters['pool'] = _poolId!;
    }
    if (_includeRecycled) {
      queryParameters['recycled'] = 'true';
    }

    final response = await client.get(
      '/drive/files/me',
      queryParameters: queryParameters,
    );

    final List<SnCloudFile> items =
        (response.data as List)
            .map((e) => SnCloudFile.fromJson(e as Map<String, dynamic>))
            .toList();
    final total = int.parse(response.headers.value('X-Total') ?? '0');

    final hasMore = offset + items.length < total;
    final nextCursor = hasMore ? (offset + items.length).toString() : null;

    return CursorPagingData(
      items: items,
      hasMore: hasMore,
      nextCursor: nextCursor,
    );
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
    // Filter state
    final selectedPool = useState<String?>(null);
    final includeRecycled = useState(false);

    final usageAsync = ref.watch(billingUsageProvider);
    final quotaAsync = ref.watch(billingQuotaProvider);

    // Update notifier filters when state changes
    useEffect(() {
      final notifier = ref.read(cloudFileListNotifierProvider.notifier);
      notifier.setFilters(selectedPool.value, includeRecycled.value);
      return null;
    }, [selectedPool.value, includeRecycled.value]);

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
                  (quota) => _buildQuotaUI(
                    usage,
                    quota,
                    ref,
                    selectedPool,
                    includeRecycled,
                  ),
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
    ValueNotifier<String?> selectedPool,
    ValueNotifier<bool> includeRecycled,
  ) {
    if (usage == null) return const SizedBox.shrink();
    return CustomScrollView(
      slivers: [
        const SliverGap(8),
        SliverToBoxAdapter(
          child: _buildFilters(ref, selectedPool, includeRecycled),
        ),
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
                  final itemType = item.mimeType?.split('/').firstOrNull;
                  return ListTile(
                    leading: ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(8)),
                      child: SizedBox(
                        height: 48,
                        width: 48,
                        child: switch (itemType) {
                          'image' => CloudImageWidget(file: item),
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
                        item.name.isEmpty
                            ? Text('untitled').tr().italic()
                            : Text(
                              item.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                    subtitle: Text(formatFileSize(item.size)),
                    onTap: () {
                      showModalBottomSheet(
                        useRootNavigator: true,
                        context: context,
                        isScrollControlled: true,
                        builder: (context) => FileInfoSheet(item: item),
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
                          await client.delete('/drive/files/${item.id}');
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

  Widget _buildFilters(
    WidgetRef ref,
    ValueNotifier<String?> selectedPool,
    ValueNotifier<bool> includeRecycled,
  ) {
    final poolsAsync = ref.watch(poolsProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'filters'.tr(),
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Gap(16),
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 600;
                return isWide
                    ? Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: poolsAsync.when(
                            data:
                                (pools) => DropdownButtonFormField<String?>(
                                  value: selectedPool.value,
                                  decoration: InputDecoration(
                                    labelText: 'Pool',
                                    border: const OutlineInputBorder(),
                                  ),
                                  items: [
                                    DropdownMenuItem<String?>(
                                      value: null,
                                      child: Text('allPools'.tr()),
                                    ),
                                    ...pools.map(
                                      (pool) => DropdownMenuItem<String?>(
                                        value: pool.id,
                                        child: Text(pool.name),
                                      ),
                                    ),
                                  ],
                                  onChanged:
                                      (value) => selectedPool.value = value,
                                ),
                            loading: () => const CircularProgressIndicator(),
                            error: (e, _) => const Text('Error loading pools'),
                          ),
                        ),
                        const Gap(8),
                        Expanded(
                          child: Row(
                            children: [
                              Text('includeRecycled'.tr()),
                              const Gap(8),
                              Switch(
                                value: includeRecycled.value,
                                onChanged:
                                    (value) => includeRecycled.value = value,
                                padding: EdgeInsets.zero,
                              ),
                            ],
                          ),
                        ),
                        const Gap(16),
                        IconButton(
                          icon: const Icon(Symbols.delete_sweep),
                          tooltip: 'deleteRecycledFiles'.tr(),
                          onPressed:
                              includeRecycled.value
                                  ? () => _deleteRecycledFiles(ref)
                                  : null,
                        ),
                      ],
                    )
                    : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        poolsAsync.when(
                          data:
                              (pools) => DropdownButtonFormField<String?>(
                                value: selectedPool.value,
                                decoration: const InputDecoration(
                                  labelText: 'Pool',
                                  border: OutlineInputBorder(),
                                ),
                                items: [
                                  DropdownMenuItem<String?>(
                                    value: null,
                                    child: Text('allPools'.tr()),
                                  ),
                                  ...pools.map(
                                    (pool) => DropdownMenuItem<String?>(
                                      value: pool.id,
                                      child: Text(pool.name),
                                    ),
                                  ),
                                ],
                                onChanged:
                                    (value) => selectedPool.value = value,
                              ),
                          loading: () => const CircularProgressIndicator(),
                          error: (e, _) => const Text('Error loading pools'),
                        ),
                        const Gap(16),
                        Row(
                          children: [
                            Text('includeRecycled'.tr()),
                            const Gap(8),
                            Switch(
                              value: includeRecycled.value,
                              onChanged:
                                  (value) => includeRecycled.value = value,
                            ),
                            const Spacer(),
                            IconButton(
                              icon: const Icon(Symbols.delete_sweep),
                              tooltip: 'deleteRecycledFiles'.tr(),
                              onPressed:
                                  includeRecycled.value
                                      ? () => _deleteRecycledFiles(ref)
                                      : null,
                            ),
                          ],
                        ),
                      ],
                    );
              },
            ),
          ],
        ),
      ),
    ).padding(horizontal: 8);
  }

  Future<void> _deleteRecycledFiles(WidgetRef ref) async {
    final confirmed = await showConfirmAlert(
      'confirmDeleteRecycledFiles'.tr(),
      'deleteRecycledFiles'.tr(),
    );
    if (!confirmed) return;

    if (ref.context.mounted) showLoadingModal(ref.context);
    try {
      final client = ref.read(apiClientProvider);
      await client.delete('/drive/files/recycled');
      ref.invalidate(cloudFileListNotifierProvider);
      showSnackBar('recycledFilesDeleted'.tr());
    } catch (e) {
      showSnackBar('failedToDeleteRecycledFiles'.tr());
    } finally {
      if (ref.context.mounted) hideLoadingModal(ref.context);
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
