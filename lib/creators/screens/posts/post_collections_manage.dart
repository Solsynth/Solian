import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/network.dart';
import 'package:island/core/widgets/content/image_picker_editor.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/shared/widgets/app_scaffold.dart';
import 'package:island/shared/widgets/layouts/sheet_scaffold.dart';
import 'package:island/shared/widgets/response.dart';
import 'package:island/posts/widgets/compose/post_card_tile.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';
import 'package:styled_widget/styled_widget.dart';

final publisherCollectionsProvider = FutureProvider.autoDispose
    .family<List<SnPostCollection>, String>((ref, pubName) async {
      final client = ref.watch(solarNetworkClientProvider);
      return client.sphere.listPublisherCollections(pubName);
    });

final collectionPostsProvider = FutureProvider.autoDispose
    .family<PaginatedResult<SnPost>, (String, String)>((ref, args) async {
      final client = ref.watch(solarNetworkClientProvider);
      return client.sphere.listPublisherCollectionPosts(
        publisherName: args.$1,
        slug: args.$2,
      );
    });

@RoutePage()
class CreatorPostCollectionsScreen extends HookConsumerWidget {
  final String pubName;
  const CreatorPostCollectionsScreen({
    super.key,
    @PathParam("pubName") required this.pubName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collections = ref.watch(publisherCollectionsProvider(pubName));

    Future<void> createCollection() async {
      final created = await showModalBottomSheet<SnPostCollection>(
        context: context,
        isScrollControlled: true,
        builder: (context) => _CollectionEditorSheet(pubName: pubName),
      );
      if (created != null) {
        ref.invalidate(publisherCollectionsProvider(pubName));
      }
    }

    return AppScaffold(
      appBar: AppBar(
        leading: const AutoLeadingButton(),
        title: Text('collections').tr(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: createCollection,
        child: const Icon(Symbols.add),
      ),
      body: collections.when(
        data: (items) => items.isEmpty
            ? Center(child: Text('noCollections'.tr()))
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: items.length,
                separatorBuilder: (_, _) => const Gap(8),
                itemBuilder: (context, index) {
                  final collection = items[index];
                  final title = collection.name?.isNotEmpty == true
                      ? collection.name!
                      : collection.slug;
                  return Card(
                    child: ListTile(
                      title: Text(title),
                      subtitle: Text(collection.slug),
                      leading: _CollectionAvatar(collection: collection),
                      trailing: const Icon(Symbols.chevron_right),
                      onTap: () async {
                        await showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          builder: (context) => _CollectionDetailSheet(
                            pubName: pubName,
                            collection: collection,
                          ),
                        );
                        ref.invalidate(publisherCollectionsProvider(pubName));
                      },
                      onLongPress: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          builder: (context) => _CollectionEditorSheet(
                            pubName: pubName,
                            existing: collection,
                          ),
                        ).then((value) {
                          if (value != null) {
                            ref.invalidate(
                              publisherCollectionsProvider(pubName),
                            );
                          }
                        });
                      },
                    ),
                  );
                },
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => ResponseErrorWidget(
          error: error,
          onRetry: () => ref.invalidate(publisherCollectionsProvider(pubName)),
        ),
      ),
    );
  }
}

class _CollectionAvatar extends StatelessWidget {
  final SnPostCollection collection;

  const _CollectionAvatar({required this.collection});

  @override
  Widget build(BuildContext context) {
    final background = collection.background;
    final icon = collection.icon;

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 48,
        height: 48,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (background != null)
              CloudFileWidget(item: background, fit: BoxFit.cover)
            else
              ColoredBox(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
            Center(
              child: ProfilePictureWidget(
                file: icon,
                radius: 14,
                fallbackIcon: Symbols.collections,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CollectionEditorSheet extends HookConsumerWidget {
  final String pubName;
  final SnPostCollection? existing;

  const _CollectionEditorSheet({required this.pubName, this.existing});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final slugController = useTextEditingController(text: existing?.slug ?? '');
    final nameController = useTextEditingController(text: existing?.name ?? '');
    final descController = useTextEditingController(
      text: existing?.description ?? '',
    );
    final background = useState<IDisplayableCloudFile?>(existing?.background);
    final icon = useState<IDisplayableCloudFile?>(existing?.icon);
    final saving = useState(false);

    Future<IDisplayableCloudFile?> pickBackground() async {
      final result = await showImagePickerEditor(
        context,
        config: ImageEditorConfig.banner,
        title: 'collectionBackground'.tr(),
      );
      return result as IDisplayableCloudFile?;
    }

    Future<IDisplayableCloudFile?> pickIcon() async {
      final result = await showImagePickerEditor(
        context,
        config: ImageEditorConfig.avatar,
        title: 'collectionIcon'.tr(),
      );
      return result as IDisplayableCloudFile?;
    }

    Future<void> submit() async {
      try {
        saving.value = true;
        final client = ref.read(solarNetworkClientProvider);
        final slug = slugController.text.trim();
        if (slug.isEmpty) return;
        final result = existing == null
            ? await client.sphere.createPublisherCollection(
                publisherName: pubName,
                slug: slug,
                name: nameController.text.trim().isEmpty
                    ? null
                    : nameController.text.trim(),
                description: descController.text.trim().isEmpty
                    ? null
                    : descController.text.trim(),
                backgroundId: background.value?.id,
                iconId: icon.value?.id,
              )
            : await client.sphere.updatePublisherCollection(
                publisherName: pubName,
                slug: existing!.slug,
                name: nameController.text.trim().isEmpty
                    ? null
                    : nameController.text.trim(),
                description: descController.text.trim().isEmpty
                    ? null
                    : descController.text.trim(),
                backgroundId: background.value?.id,
                iconId: icon.value?.id,
                clearBackground:
                    existing?.background != null && background.value == null,
                clearIcon: existing?.icon != null && icon.value == null,
              );
        if (context.mounted) Navigator.pop(context, result);
      } catch (err) {
        showErrorAlert(err);
      } finally {
        saving.value = false;
      }
    }

    return SheetScaffold(
      titleText: existing == null ? 'create'.tr() : 'edit'.tr(),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AspectRatio(
            aspectRatio: 16 / 7,
            child: Stack(
              fit: StackFit.expand,
              children: [
                GestureDetector(
                  onTap: () async {
                    background.value = await pickBackground();
                  },
                  child: background.value != null
                      ? CloudImageWidget(
                          file: background.value!,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          color: Theme.of(
                            context,
                          ).colorScheme.surfaceContainerHighest,
                          alignment: Alignment.center,
                          child: const Icon(Symbols.wallpaper),
                        ),
                ),
                Positioned(
                  left: 16,
                  bottom: 16,
                  child: GestureDetector(
                    onTap: () async {
                      icon.value = await pickIcon();
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Theme.of(context).colorScheme.surface,
                          width: 3,
                        ),
                      ),
                      child: icon.value != null
                          ? ProfilePictureWidget(file: icon.value!, radius: 28)
                          : ProfilePictureWidget(
                              file: null,
                              radius: 28,
                              fallbackIcon: Symbols.collections,
                            ),
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: background.value == null
                            ? null
                            : () => background.value = null,
                        icon: const Icon(Symbols.delete),
                      ),
                      IconButton(
                        onPressed: icon.value == null
                            ? null
                            : () => icon.value = null,
                        icon: const Icon(Symbols.delete),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Gap(16),
          TextField(
            controller: slugController,
            decoration: InputDecoration(
              labelText: 'slug'.tr(),
              helperText: 'collectionIdentifier'.tr(),
            ),
          ),
          const Gap(12),
          TextField(
            controller: nameController,
            decoration: InputDecoration(labelText: 'name'.tr()),
          ),
          const Gap(12),
          TextField(
            controller: descController,
            maxLines: 4,
            decoration: InputDecoration(labelText: 'description'.tr()),
          ),
          const Gap(16),
          FilledButton.icon(
            onPressed: saving.value ? null : submit,
            icon: const Icon(Symbols.save),
            label: Text(existing == null ? 'create'.tr() : 'update'.tr()),
          ),
        ],
      ),
    );
  }
}

class _CollectionDetailSheet extends HookConsumerWidget {
  final String pubName;
  final SnPostCollection collection;

  const _CollectionDetailSheet({
    required this.pubName,
    required this.collection,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final posts = ref.watch(
      collectionPostsProvider((pubName, collection.slug)),
    );
    final title = collection.name?.isNotEmpty == true
        ? collection.name!
        : collection.slug;

    Future<void> deleteCollection() async {
      final confirm = await showConfirmAlert(
        'deleteThisCollection'.tr(),
        'deleteCollection'.tr(),
        isDanger: true,
      );
      if (confirm != true) return;
      final client = ref.read(solarNetworkClientProvider);
      try {
        await client.sphere.deletePublisherCollection(
          publisherName: pubName,
          slug: collection.slug,
        );
        if (context.mounted) Navigator.pop(context, true);
      } catch (err) {
        showErrorAlert(err);
      }
    }

    return SheetScaffold(
      titleText: title,
      actions: [
        IconButton(
          icon: const Icon(Symbols.edit),
          onPressed: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (context) => _CollectionEditorSheet(
                pubName: pubName,
                existing: collection,
              ),
            ).then((value) {
              if (value != null && context.mounted) {
                Navigator.pop(context, true);
              }
            });
          },
        ),
        IconButton(
          icon: const Icon(Symbols.delete),
          onPressed: deleteCollection,
        ),
      ],
      child: ListView(
        padding: const EdgeInsets.only(bottom: 16),
        children: [
          AspectRatio(
            aspectRatio: 16 / 7,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (collection.background != null)
                  CloudFileWidget(
                    item: collection.background!,
                    fit: BoxFit.cover,
                  )
                else
                  Container(
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                  ),
                Positioned(
                  left: 16,
                  bottom: 16,
                  child: Row(
                    children: [
                      ProfilePictureWidget(
                        file: collection.icon,
                        radius: 24,
                        fallbackIcon: Symbols.collections,
                      ),
                      const Gap(12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            title,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(color: Colors.white),
                          ),
                          if (collection.description?.isNotEmpty ?? false)
                            Text(
                              collection.description!,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: Colors.white70),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Gap(16),
          posts.when(
            data: (result) => ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: result.items.length,
              itemBuilder: (context, index) {
                final post = result.items[index];
                return CreatorPostCardTile(
                  index: index,
                  post: post,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (index > 0)
                        IconButton(
                          icon: const Icon(Symbols.arrow_upward),
                          onPressed: () async {
                            final ids = result.items.map((e) => e.id).toList();
                            final tmp = ids[index - 1];
                            ids[index - 1] = ids[index];
                            ids[index] = tmp;
                            final client = ref.read(solarNetworkClientProvider);
                            await client.sphere.reorderPublisherCollectionPosts(
                              publisherName: pubName,
                              slug: collection.slug,
                              postIds: ids,
                            );
                            ref.invalidate(
                              collectionPostsProvider((
                                pubName,
                                collection.slug,
                              )),
                            );
                          },
                        ),
                      if (index < result.items.length - 1)
                        IconButton(
                          icon: const Icon(Symbols.arrow_downward),
                          onPressed: () async {
                            final ids = result.items.map((e) => e.id).toList();
                            final tmp = ids[index + 1];
                            ids[index + 1] = ids[index];
                            ids[index] = tmp;
                            final client = ref.read(solarNetworkClientProvider);
                            await client.sphere.reorderPublisherCollectionPosts(
                              publisherName: pubName,
                              slug: collection.slug,
                              postIds: ids,
                            );
                            ref.invalidate(
                              collectionPostsProvider((
                                pubName,
                                collection.slug,
                              )),
                            );
                          },
                        ),
                    ],
                  ),
                ).padding(horizontal: 16);
              },
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => ResponseErrorWidget(
              error: error,
              onRetry: () => ref.invalidate(
                collectionPostsProvider((pubName, collection.slug)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
