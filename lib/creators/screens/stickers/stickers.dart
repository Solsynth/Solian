import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/creators/screens/stickers/pack_detail.dart';
import 'package:island/stickers/models/sticker.dart';
import 'package:island/core/network.dart';
import 'package:island/core/services/responsive.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/shared/widgets/app_scaffold.dart';
import 'package:island/core/widgets/content/cloud_file_picker.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:island/shared/widgets/layouts/sheet_scaffold.dart';
import 'package:island/shared/widgets/pagination_list.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

part 'stickers.g.dart';

@RoutePage()
class CreatorStickerListScreen extends HookConsumerWidget {
  final String pubName;
  const CreatorStickerListScreen({super.key, required this.pubName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final content = SliverStickerPacksList(pubName: pubName);

    return AppScaffold(
      isNoBackground: false,
      appBar: AppBar(
        leading: const PageBackButton(backTo: '/creators'),
        title: const Text('stickers').tr(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (context) => SheetScaffold(
              titleText: 'createStickerPack'.tr(),
              child: StickerPackForm(pubName: pubName),
            ),
          ).then((value) {
            if (value != null) {
              ref.invalidate(stickerPacksProvider(pubName));
            }
          });
        },
        child: const Icon(Symbols.add),
      ),
      body: isWideScreen(context)
          ? Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 640),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8),
                    ),
                  ),
                  margin: const EdgeInsets.only(top: 16),
                  child: content,
                ),
              ),
            )
          : content,
    );
  }
}

class SliverStickerPacksList extends HookConsumerWidget {
  final String pubName;
  const SliverStickerPacksList({super.key, required this.pubName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PaginationList(
      padding: EdgeInsets.zero,
      provider: stickerPacksProvider(pubName),
      notifier: stickerPacksProvider(pubName).notifier,
      itemBuilder: (context, index, sticker) {
        return ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: const BorderRadius.all(Radius.circular(8)),
          ),
          title: Text(sticker.name),
          subtitle: Text(sticker.description),
          trailing: const Icon(Symbols.chevron_right),
          onTap: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (context) => SheetScaffold(
                titleText: sticker.name,
                actions: [
                  IconButton(
                    icon: const Icon(Symbols.add_circle),
                    onPressed: () {
                      final id = sticker.id;
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        builder: (context) => SheetScaffold(
                          titleText: 'createSticker'.tr(),
                          child: StickerForm(packId: id),
                        ),
                      ).then((value) {
                        if (value != null) {
                          ref.invalidate(stickerPackContentProvider(id));
                        }
                      });
                    },
                  ),
                  StickerPackActionMenu(
                    pubName: pubName,
                    packId: sticker.id,
                    iconShadow: Shadow(),
                  ),
                ],
                child: StickerPackDetailContent(
                  id: sticker.id,
                  pubName: pubName,
                ),
              ),
            );
          },
        );
      },
    );
  }
}

final stickerPacksProvider = AsyncNotifierProvider.family.autoDispose(
  StickerPacksNotifier.new,
);

class StickerPacksNotifier extends AsyncNotifier<PaginationState<SnStickerPack>>
    with AsyncPaginationController<SnStickerPack> {
  static const int pageSize = 20;

  final String arg;
  StickerPacksNotifier(this.arg);

  @override
  Future<List<SnStickerPack>> fetch() async {
    final client = ref.read(apiClientProvider);

    try {
      final response = await client.get(
        '/sphere/stickers',
        queryParameters: {
          'offset': fetchedCount.toString(),
          'take': pageSize,
          'pub': arg,
        },
      );

      totalCount = int.parse(response.headers.value('X-Total') ?? '0');
      final stickers = response.data
          .map((e) => SnStickerPack.fromJson(e))
          .cast<SnStickerPack>()
          .toList();

      return stickers;
    } catch (err) {
      rethrow;
    }
  }
}

@riverpod
Future<SnStickerPack?> stickerPack(Ref ref, String? packId) async {
  if (packId == null) return null;
  final apiClient = ref.watch(apiClientProvider);
  final resp = await apiClient.get('/sphere/stickers/$packId');
  return SnStickerPack.fromJson(resp.data);
}

class StickerPackForm extends HookConsumerWidget {
  final String pubName;
  final String? packId;
  const StickerPackForm({super.key, required this.pubName, this.packId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormState>(), []);
    final initialPack = ref.watch(stickerPackProvider(packId));

    final icon = useState<String?>(
      packId == null ? '' : initialPack.value?.icon?.id,
    );
    final nameController = useTextEditingController();
    final descriptionController = useTextEditingController();
    final prefixController = useTextEditingController();

    useEffect(() {
      if (initialPack.value != null) {
        nameController.text = initialPack.value!.name;
        descriptionController.text = initialPack.value!.description;
        prefixController.text = initialPack.value!.prefix;
      }
      return null;
    }, [initialPack]);

    final submitting = useState(false);

    Future<void> submit() async {
      if (!(formKey.currentState?.validate() ?? false)) return;

      try {
        submitting.value = true;
        final apiClient = ref.watch(apiClientProvider);
        final resp = await apiClient.request(
          packId == null ? '/sphere/stickers' : '/sphere/stickers/$packId',
          data: {
            'name': nameController.text,
            'description': descriptionController.text,
            'prefix': prefixController.text,
            'icon_id': icon.value,
          },
          queryParameters: {'pub': pubName},
          options: Options(method: packId == null ? 'POST' : 'PATCH'),
        );
        if (!context.mounted) return;
        Navigator.of(context).pop(SnStickerPack.fromJson(resp.data));
      } catch (err) {
        showErrorAlert(err);
      } finally {
        submitting.value = false;
      }
    }

    return Column(
      children: [
        Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 16,
            children: [
              Row(
                spacing: 8,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  SizedBox(
                    height: 80,
                    width: 80,
                    child: ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceContainer,
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                        ),
                        child: (icon.value?.isEmpty ?? true)
                            ? const SizedBox.shrink()
                            : CloudImageWidget(fileId: icon.value!),
                      ),
                    ),
                  ),
                  IconButton.filledTonal(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (context) => CloudFilePicker(
                          allowedTypes: {UniversalFileType.image},
                        ),
                      ).then((value) {
                        if (value == null) return;
                        icon.value = value[0].id;
                      });
                    },
                    icon: const Icon(Symbols.cloud_upload),
                  ),
                ],
              ),
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'name'.tr(),
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'fieldCannotBeEmpty'.tr();
                  }
                  return null;
                },
                onTapOutside: (_) =>
                    FocusManager.instance.primaryFocus?.unfocus(),
              ),
              TextFormField(
                controller: descriptionController,
                decoration: InputDecoration(
                  labelText: 'description'.tr(),
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                  alignLabelWithHint: true,
                ),
                minLines: 3,
                maxLines: null,
                onTapOutside: (_) =>
                    FocusManager.instance.primaryFocus?.unfocus(),
              ),
              TextFormField(
                controller: prefixController,
                decoration: InputDecoration(
                  labelText: 'stickerPackPrefix'.tr(),
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                  helperText: 'stickerPackPrefixHint'.tr(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'fieldCannotBeEmpty'.tr();
                  }
                  return null;
                },
                onTapOutside: (_) =>
                    FocusManager.instance.primaryFocus?.unfocus(),
              ),
            ],
          ),
        ),
        const Gap(12),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: submitting.value ? null : submit,
            icon: const Icon(Symbols.save),
            label: Text(packId == null ? 'create'.tr() : 'saveChanges'.tr()),
          ),
        ),
      ],
    ).padding(horizontal: 24, vertical: 16);
  }
}
