import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/network.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/shared/widgets/app_scaffold.dart';
import 'package:island/shared/widgets/layouts/sheet_scaffold.dart';
import 'package:island/shared/widgets/response.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

final publisherCollectionsProvider =
    FutureProvider.family<List<SnPostCollection>, String>((ref, pubName) async {
  final client = ref.watch(solarNetworkClientProvider);
  return client.sphere.listPublisherCollections(pubName);
});

final collectionPostsProvider = FutureProvider.family<PaginatedResult<SnPost>, (String, String)>(
  (ref, args) async {
    final client = ref.watch(solarNetworkClientProvider);
    return client.sphere.listPublisherCollectionPosts(
      publisherName: args.$1,
      slug: args.$2,
    );
  },
);

@RoutePage()
class CreatorPostCollectionsScreen extends HookConsumerWidget {
  final String pubName;
  const CreatorPostCollectionsScreen({super.key, required this.pubName});

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
            ? Center(child: Text('No collections'))
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: items.length,
                separatorBuilder: (_, _) => const Gap(8),
                itemBuilder: (context, index) {
                  final collection = items[index];
                  return Card(
                    child: ListTile(
                      title: Text(
                        collection.name?.isNotEmpty == true
                            ? collection.name!
                            : collection.slug,
                      ),
                      subtitle: Text(collection.slug),
                      leading: const Icon(Symbols.collections),
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
                            ref.invalidate(publisherCollectionsProvider(pubName));
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

class _CollectionEditorSheet extends HookConsumerWidget {
  final String pubName;
  final SnPostCollection? existing;

  const _CollectionEditorSheet({required this.pubName, this.existing});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final slugController = useTextEditingController(text: existing?.slug ?? '');
    final nameController = useTextEditingController(text: existing?.name ?? '');
    final descController = useTextEditingController(text: existing?.description ?? '');
    final saving = useState(false);

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
          TextField(
            controller: slugController,
            decoration: InputDecoration(
              labelText: 'slug'.tr(),
              helperText: 'Collection identifier',
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

  const _CollectionDetailSheet({required this.pubName, required this.collection});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final posts = ref.watch(collectionPostsProvider((pubName, collection.slug)));

    Future<void> deleteCollection() async {
      final confirm = await showConfirmAlert(
        'Delete this collection?',
        'Delete collection',
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
      titleText: collection.name?.isNotEmpty == true ? collection.name! : collection.slug,
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
              if (value != null && context.mounted) Navigator.pop(context, true);
            });
          },
        ),
        IconButton(
          icon: const Icon(Symbols.delete),
          onPressed: deleteCollection,
        ),
      ],
      child: posts.when(
        data: (result) => ListView.separated(
          itemCount: result.items.length,
          separatorBuilder: (_, _) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final post = result.items[index];
            return ListTile(
              leading: const Icon(Symbols.article),
              title: Text(post.title ?? post.slug ?? post.id),
              subtitle: Text(post.id),
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
                        ref.invalidate(collectionPostsProvider((pubName, collection.slug)));
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
                        ref.invalidate(collectionPostsProvider((pubName, collection.slug)));
                      },
                    ),
                ],
              ),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => ResponseErrorWidget(
          error: error,
          onRetry: () => ref.invalidate(collectionPostsProvider((pubName, collection.slug))),
        ),
      ),
    );
  }
}
