import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/models/sticker.dart';
import 'package:island/pods/network.dart';
import 'package:island/screens/creators/stickers/stickers.dart';
import 'package:island/widgets/alert.dart';
import 'package:island/widgets/app_scaffold.dart';
import 'package:island/widgets/content/cloud_file_picker.dart';
import 'package:island/widgets/content/cloud_files.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:super_context_menu/super_context_menu.dart';

part 'pack_detail.g.dart';
part 'pack_detail.freezed.dart';

@riverpod
Future<List<SnSticker>> stickerPackContent(Ref ref, String packId) async {
  final apiClient = ref.watch(apiClientProvider);
  final resp = await apiClient.get('/sphere/stickers/$packId/content');
  return resp.data
      .map<SnSticker>((e) => SnSticker.fromJson(e))
      .cast<SnSticker>()
      .toList();
}

class StickerPackDetailScreen extends HookConsumerWidget {
  final String id;
  final String pubName;
  const StickerPackDetailScreen({
    super.key,
    required this.pubName,
    required this.id,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pack = ref.watch(stickerPackProvider(id));
    final packContent = ref.watch(stickerPackContentProvider(id));

    Future<void> deleteSticker(SnSticker sticker) async {
      final confirm = await showConfirmAlert(
        'deleteStickerHint'.tr(),
        'deleteSticker'.tr(),
      );
      if (!confirm) return;
      if (!context.mounted) return;

      try {
        showLoadingModal(context);
        final apiClient = ref.watch(apiClientProvider);
        await apiClient.delete('/sphere/stickers/$id/content/${sticker.id}');
        ref.invalidate(stickerPackContentProvider(id));
      } catch (err) {
        showErrorAlert(err);
      } finally {
        if (context.mounted) hideLoadingModal(context);
      }
    }

    return AppScaffold(
      isNoBackground: false,
      appBar: AppBar(
        title: Text(pack.value?.name ?? 'loading'.tr()),
        actions: [
          IconButton(
            icon: const Icon(Symbols.add_circle),
            onPressed: () {
              context
                  .pushNamed(
                    'creatorStickerNew',
                    pathParameters: {'name': pubName, 'packId': id},
                  )
                  .then((value) {
                    if (value != null) {
                      ref.invalidate(stickerPackContentProvider(id));
                    }
                  });
            },
          ),
          _StickerPackActionMenu(
            pubName: pubName,
            packId: id,
            iconShadow: Shadow(),
          ),
          const Gap(8),
        ],
      ),
      body: pack.when(
        data:
            (pack) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(pack!.description),
                    Row(
                      spacing: 4,
                      children: [
                        const Icon(Symbols.folder, size: 16),
                        Text(
                          '${packContent.value?.length ?? 0}/24',
                          style: GoogleFonts.robotoMono(),
                        ),
                      ],
                    ).opacity(0.85),
                    Row(
                      spacing: 4,
                      children: [
                        const Icon(Symbols.sell, size: 16),
                        Text(pack.prefix, style: GoogleFonts.robotoMono()),
                      ],
                    ).opacity(0.85),
                    Row(
                      spacing: 4,
                      children: [
                        const Icon(Symbols.tag, size: 16),
                        SelectableText(
                          pack.id,
                          style: GoogleFonts.robotoMono(),
                        ),
                      ],
                    ).opacity(0.85),
                  ],
                ).padding(horizontal: 24, vertical: 24),
                const Divider(height: 1),
                Expanded(
                  child: packContent.when(
                    data:
                        (stickers) => RefreshIndicator(
                          onRefresh:
                              () => ref.refresh(
                                stickerPackContentProvider(id).future,
                              ),
                          child: GridView.builder(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 20,
                            ),
                            gridDelegate:
                                const SliverGridDelegateWithMaxCrossAxisExtent(
                                  maxCrossAxisExtent: 48,
                                  mainAxisSpacing: 8,
                                  crossAxisSpacing: 8,
                                ),
                            itemCount: stickers.length,
                            itemBuilder: (context, index) {
                              final sticker = stickers[index];
                              return ContextMenuWidget(
                                menuProvider: (_) {
                                  return Menu(
                                    children: [
                                      MenuAction(
                                        title: 'stickerCopyPlaceholder'.tr(),
                                        image: MenuImage.icon(Symbols.copy_all),
                                        callback: () {
                                          Clipboard.setData(
                                            ClipboardData(
                                              text:
                                                  ':${pack.prefix}${sticker.slug}:',
                                            ),
                                          );
                                        },
                                      ),
                                      MenuSeparator(),
                                      MenuAction(
                                        title: 'edit'.tr(),
                                        image: MenuImage.icon(Symbols.edit),
                                        callback: () {
                                          context
                                              .pushNamed(
                                                'creatorStickerEdit',
                                                pathParameters: {
                                                  'name': pubName,
                                                  'packId': id,
                                                  'id': sticker.id,
                                                },
                                              )
                                              .then((value) {
                                                if (value != null) {
                                                  ref.invalidate(
                                                    stickerPackContentProvider(
                                                      id,
                                                    ),
                                                  );
                                                }
                                              });
                                        },
                                      ),
                                      MenuAction(
                                        title: 'delete'.tr(),
                                        image: MenuImage.icon(Symbols.delete),
                                        callback: () {
                                          deleteSticker(sticker);
                                        },
                                      ),
                                    ],
                                  );
                                },
                                child: ClipRRect(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(8),
                                  ),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color:
                                          Theme.of(
                                            context,
                                          ).colorScheme.surfaceContainer,
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(8),
                                      ),
                                    ),
                                    child: CloudImageWidget(
                                      fileId: sticker.imageId,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                    error:
                        (err, _) =>
                            Text(
                              'Error: $err',
                            ).textAlignment(TextAlign.center).center(),
                    loading: () => const CircularProgressIndicator().center(),
                  ),
                ),
              ],
            ),
        error:
            (err, _) =>
                Text('Error: $err').textAlignment(TextAlign.center).center(),
        loading: () => const CircularProgressIndicator().center(),
      ),
    );
  }
}

class _StickerPackActionMenu extends HookConsumerWidget {
  final String pubName;
  final String packId;
  final Shadow iconShadow;

  const _StickerPackActionMenu({
    required this.pubName,
    required this.packId,
    required this.iconShadow,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopupMenuButton(
      icon: Icon(Icons.more_vert, shadows: [iconShadow]),
      itemBuilder:
          (context) => [
            PopupMenuItem(
              onTap: () {
                context.push('/creators/$pubName/stickers/$packId/edit');
              },
              child: Row(
                children: [
                  Icon(
                    Icons.edit,
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                  ),
                  const Gap(12),
                  const Text('editStickerPack').tr(),
                ],
              ),
            ),
            PopupMenuItem(
              child: Row(
                children: [
                  const Icon(Icons.delete, color: Colors.red),
                  const Gap(12),
                  const Text(
                    'deleteStickerPack',
                    style: TextStyle(color: Colors.red),
                  ).tr(),
                ],
              ),
              onTap: () {
                showConfirmAlert(
                  'deleteStickerPackHint'.tr(),
                  'deleteStickerPack'.tr(),
                ).then((confirm) {
                  if (confirm) {
                    final client = ref.watch(apiClientProvider);
                    client.delete('/sphere/stickers/$packId');
                    ref.invalidate(stickerPacksNotifierProvider);
                    if (context.mounted) context.pop(true);
                  }
                });
              },
            ),
          ],
    );
  }
}

@freezed
sealed class StickerWithPackQuery with _$StickerWithPackQuery {
  const factory StickerWithPackQuery({
    required String packId,
    required String id,
  }) = _StickerWithPackQuery;
}

@riverpod
Future<SnSticker?> stickerPackSticker(
  Ref ref,
  StickerWithPackQuery? query,
) async {
  if (query == null) return null;
  final apiClient = ref.watch(apiClientProvider);
  final resp = await apiClient.get(
    '/sphere/stickers/${query.packId}/content/${query.id}',
  );
  if (resp.data == null) return null;
  return SnSticker.fromJson(resp.data);
}

class NewStickersScreen extends StatelessWidget {
  final String packId;
  const NewStickersScreen({super.key, required this.packId});

  @override
  Widget build(BuildContext context) {
    return EditStickersScreen(packId: packId, id: null);
  }
}

class EditStickersScreen extends HookConsumerWidget {
  final String packId;
  final String? id;
  const EditStickersScreen({super.key, required this.packId, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sticker = ref.watch(
      stickerPackStickerProvider(
        id == null ? null : StickerWithPackQuery(packId: packId, id: id!),
      ),
    );

    final formKey = useMemoized(() => GlobalKey<FormState>(), []);

    final image = useState<String?>(id == null ? '' : sticker.value?.imageId);
    final imageController = useTextEditingController(text: image.value);
    final slugController = useTextEditingController(
      text: id == null ? '' : sticker.value?.slug,
    );

    useEffect(() {
      if (sticker.value != null) {
        image.value = sticker.value!.imageId;
        imageController.text = sticker.value!.imageId;
        slugController.text = sticker.value!.slug;
      }
      return null;
    }, [sticker]);

    final submitting = useState(false);

    Future<void> submit() async {
      final apiClient = ref.watch(apiClientProvider);
      submitting.value = true;
      try {
        final resp = await apiClient.request(
          id == null
              ? '/sphere/stickers/$packId/content'
              : '/sphere/stickers/$packId/content/$id',
          data: {'slug': slugController.text, 'image_id': imageController.text},
          options: Options(method: id == null ? 'POST' : 'PATCH'),
        );
        if (context.mounted) {
          Navigator.pop(context, SnSticker.fromJson(resp.data));
        }
      } catch (err) {
        showErrorAlert(err);
      } finally {
        submitting.value = false;
      }
    }

    return AppScaffold(
      isNoBackground: false,
      appBar: AppBar(
        title: Text(id == null ? 'createSticker' : 'editSticker').tr(),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 96,
            width: 96,
            child: ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
                child:
                    (image.value?.isEmpty ?? true)
                        ? const SizedBox.shrink()
                        : CloudImageWidget(fileId: image.value!),
              ),
            ),
          ),
          const Gap(16),
          Form(
            key: formKey,
            child: Column(
              spacing: 8,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: imageController,
                  decoration: InputDecoration(
                    labelText: 'stickerImage'.tr(),
                    border: const UnderlineInputBorder(),
                    suffix: InkWell(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          builder: (context) => CloudFilePicker(),
                        ).then((value) {
                          if (value == null) return;
                          image.value = value[0].id;
                          imageController.text = image.value!;
                        });
                      },
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                      child: const Icon(
                        Symbols.cloud_upload,
                      ).padding(horizontal: 4),
                    ),
                  ),
                  readOnly: true,
                  onTapOutside:
                      (_) => FocusManager.instance.primaryFocus?.unfocus(),
                ),
                TextFormField(
                  controller: slugController,
                  decoration: InputDecoration(
                    labelText: 'stickerSlug'.tr(),
                    helperText: 'stickerSlugHint'.tr(),
                    border: const UnderlineInputBorder(),
                  ),
                  onTapOutside:
                      (_) => FocusManager.instance.primaryFocus?.unfocus(),
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
              label: Text(id == null ? 'create' : 'saveChanges').tr(),
            ),
          ),
        ],
      ).padding(horizontal: 24, vertical: 24),
    );
  }
}
