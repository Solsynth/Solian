import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/models/file.dart';
import 'package:island/pods/network.dart';
import 'package:island/pods/paging.dart';
import 'package:island/widgets/content/cloud_files.dart';
import 'package:island/widgets/content/sheet.dart';
import 'package:island/widgets/paging/pagination_list.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:url_launcher/url_launcher_string.dart';

final cloudFileListNotifierProvider =
    AsyncNotifierProvider.autoDispose<CloudFileListNotifier, List<SnCloudFile>>(
      CloudFileListNotifier.new,
    );

class CloudFileListNotifier extends AutoDisposeAsyncNotifier<List<SnCloudFile>>
    with AutoDisposeAsyncPaginationController<SnCloudFile> {
  @override
  Future<List<SnCloudFile>> fetch() async {
    final client = ref.read(apiClientProvider);
    final take = 20;

    final queryParameters = {'offset': fetchedCount, 'take': take};

    final response = await client.get(
      '/drive/files/me',
      queryParameters: queryParameters,
    );

    totalCount = int.parse(response.headers.value('X-Total') ?? '0');
    final List<dynamic> data = response.data;
    return data
        .map((e) => SnCloudFile.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

class ComposeLinkAttachment extends HookConsumerWidget {
  const ComposeLinkAttachment({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final idController = useTextEditingController();
    final errorMessage = useState<String?>(null);
    final provider = cloudFileListNotifierProvider;

    return SheetScaffold(
      heightFactor: 0.6,
      titleText: 'linkAttachment'.tr(),
      child: DefaultTabController(
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
                  PaginationList(
                    padding: EdgeInsets.only(top: 8),
                    provider: provider,
                    notifier: provider.notifier,
                    itemBuilder: (context, index, item) {
                      final itemType = item.mimeType?.split('/').firstOrNull;
                      return ListTile(
                        leading: ClipRRect(
                          borderRadius: const BorderRadius.all(
                            Radius.circular(8),
                          ),
                          child: SizedBox(
                            height: 48,
                            width: 48,
                            child: switch (itemType) {
                              'image' => CloudImageWidget(file: item),
                              'audio' =>
                                const Icon(
                                  Symbols.audio_file,
                                  fill: 1,
                                ).center(),
                              'video' =>
                                const Icon(
                                  Symbols.video_file,
                                  fill: 1,
                                ).center(),
                              _ =>
                                const Icon(
                                  Symbols.body_system,
                                  fill: 1,
                                ).center(),
                            },
                          ),
                        ),
                        title:
                            item.name.isEmpty
                                ? Text('untitled').tr().italic()
                                : Text(item.name),
                        onTap: () {
                          Navigator.pop(context, item);
                        },
                      );
                    },
                  ),
                  SingleChildScrollView(
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
                            border: OutlineInputBorder(
                              borderRadius: const BorderRadius.all(
                                Radius.circular(12),
                              ),
                            ),
                          ),
                          onTapOutside:
                              (_) =>
                                  FocusManager.instance.primaryFocus?.unfocus(),
                        ),
                        const Gap(16),
                        InkWell(
                          child: Text(
                            'fileIdLinkHint',
                          ).tr().fontSize(13).opacity(0.85),
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
                                final client = ref.read(apiClientProvider);
                                final response = await client.get(
                                  '/drive/files/$fileId/info',
                                );
                                final SnCloudFile cloudFile =
                                    SnCloudFile.fromJson(response.data);

                                if (context.mounted) {
                                  Navigator.of(context).pop(cloudFile);
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
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
