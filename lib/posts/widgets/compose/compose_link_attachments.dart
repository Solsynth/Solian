import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/network.dart';
import 'package:island/core/utils/file_icon_utils.dart';
import 'package:island/core/utils/format.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:island/shared/widgets/layouts/sheet_scaffold.dart';
import 'package:island/shared/widgets/pagination_list.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

final cloudFileListNotifierProvider = AsyncNotifierProvider.autoDispose(
  CloudFileListNotifier.new,
);

class CloudFileListNotifier extends AsyncNotifier<PaginationState<SnCloudFile>>
    with AsyncPaginationController<SnCloudFile> {
  @override
  Future<List<SnCloudFile>> fetch() async {
    final driveApi = ref.read(solarNetworkClientProvider).drive;
    const take = 20;

    final result = await driveApi.listMyFiles(
      offset: fetchedCount,
      take: take,
    );

    totalCount = result.totalCount;
    return result.items;
  }
}

class ComposeLinkAttachment extends HookConsumerWidget {
  const ComposeLinkAttachment({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SheetScaffold(
      heightFactor: 0.6,
      titleText: 'linkAttachment'.tr(),
      child: CloudFileLinkPicker(
        onSelected: (file) => Navigator.pop(context, file),
      ),
    );
  }
}

class CloudFileLinkPicker extends HookConsumerWidget {
  final ValueChanged<SnCloudFile> onSelected;
  final EdgeInsetsGeometry padding;
  final List<Widget> recentUploadsSliverHeaders;

  const CloudFileLinkPicker({
    super.key,
    required this.onSelected,
    this.padding = const EdgeInsets.all(12),
    this.recentUploadsSliverHeaders = const [],
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final idController = useTextEditingController();
    final errorMessage = useState<String?>(null);
    return DefaultTabController(
      length: 2,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TabBar(
            tabs: [
              Tab(text: 'attachmentsRecentUploads'.tr()),
              Tab(text: 'attachmentsManualInput'.tr()),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _RecentCloudFilesWaterfall(
                  padding: padding,
                  onSelected: onSelected,
                  sliverHeaders: recentUploadsSliverHeaders,
                ),
                _ManualCloudFileLinkForm(
                  idController: idController,
                  errorMessage: errorMessage,
                  onSelected: onSelected,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentCloudFilesWaterfall extends StatelessWidget {
  final EdgeInsetsGeometry padding;
  final ValueChanged<SnCloudFile> onSelected;
  final List<Widget> sliverHeaders;

  const _RecentCloudFilesWaterfall({
    required this.padding,
    required this.onSelected,
    required this.sliverHeaders,
  });

  @override
  Widget build(BuildContext context) {
    return PaginationWidget(
      provider: cloudFileListNotifierProvider,
      notifier: cloudFileListNotifierProvider.notifier,
      isRefreshable: false,
      contentBuilder: (data, footer) => CustomScrollView(
        slivers: [
          ...sliverHeaders,
          SliverPadding(
            padding: padding,
            sliver: SliverMasonryGrid(
              gridDelegate:
                  const SliverSimpleGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 180,
                  ),
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              delegate: SliverChildBuilderDelegate((context, index) {
                if (index == data.length) return footer;
                return _CloudFileLinkTile(
                  file: data[index],
                  onTap: () => onSelected(data[index]),
                );
              }, childCount: data.length + 1),
            ),
          ),
        ],
      ),
    );
  }
}

class _CloudFileLinkTile extends ConsumerWidget {
  final SnCloudFile file;
  final VoidCallback onTap;

  const _CloudFileLinkTile({required this.file, required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meta = file.fileMeta is Map ? (file.fileMeta as Map) : const {};
    final ratio = meta['ratio'] is num
        ? (meta['ratio'] as num).toDouble()
        : 1.0;
    final itemType = file.mimeType?.split('/').first;

    final previewWidget = switch (itemType) {
      'image' => CloudImageWidget(
        file: file,
        aspectRatio: ratio,
        fit: BoxFit.cover,
      ),
      'video' => CloudVideoWidget(item: file),
      _ => getFileIcon(file, size: 48),
    };

    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
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
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
              child: AspectRatio(
                aspectRatio: ratio,
                child: Container(
                  color: Theme.of(context).colorScheme.surfaceContainer,
                  child: previewWidget,
                ),
              ),
            ),
            Row(
              children: [
                getFileIcon(file, size: 22, tinyPreview: false),
                const Gap(10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      file.name.isEmpty
                          ? Text('untitled').tr().italic()
                          : Text(
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
              ],
            ).padding(horizontal: 10, vertical: 6),
          ],
        ),
      ),
    );
  }
}

class _ManualCloudFileLinkForm extends ConsumerWidget {
  final TextEditingController idController;
  final ValueNotifier<String?> errorMessage;
  final ValueChanged<SnCloudFile> onSelected;

  const _ManualCloudFileLinkForm({
    required this.idController,
    required this.errorMessage,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: idController,
            decoration: InputDecoration(
              labelText: 'fileId'.tr(),
              helperText: 'fileIdHint'.tr(),
              helperMaxLines: 3,
              errorText: errorMessage.value,
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
            ),
            onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
          ),
          const Gap(16),
          InkWell(
            child: Text('fileIdLinkHint').tr().fontSize(13).opacity(0.85),
            onTap: () {
              launchUrlString('https://fs.solian.app');
            },
          ).padding(horizontal: 14),
          const Gap(16),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              icon: const Icon(Symbols.add),
              label: Text('add'.tr()),
              onPressed: () async {
                final fileId = idController.text.trim();
                if (fileId.isEmpty) {
                  errorMessage.value = 'fileIdCannotBeEmpty'.tr();
                  return;
                }

                try {
                  final client = ref.read(solarNetworkClientProvider);
                  final cloudFile = await client.drive.getFileInfo(fileId);

                  if (context.mounted) {
                    onSelected(cloudFile);
                  }
                } catch (e) {
                  errorMessage.value = 'failedToFetchFile'.tr(
                    args: [e.toString()],
                  );
                }
              },
            ),
          ),
        ],
      ).padding(horizontal: 24, vertical: 24),
    );
  }
}
