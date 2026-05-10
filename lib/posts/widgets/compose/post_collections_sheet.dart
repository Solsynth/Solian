import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/network.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/shared/widgets/layouts/sheet_scaffold.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

class PostCollectionsSheet extends HookConsumerWidget {
  final SnPost post;
  final VoidCallback? onChanged;

  const PostCollectionsSheet({
    super.key,
    required this.post,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final publisherName = post.publisher?.name;
    final isLoading = useState(false);
    final collections = useState<List<SnPostCollection>>([]);

    final selected = useState<Set<String>>(
      post.publisherCollections.map((c) => c.slug).toSet(),
    );

    Future<void> load() async {
      if (publisherName == null || publisherName.isEmpty) return;
      try {
        isLoading.value = true;
        final client = ref.read(solarNetworkClientProvider);
        final items = await client.sphere.listPublisherCollections(publisherName);
        collections.value = items;
      } catch (err) {
        showErrorAlert(err);
      } finally {
        isLoading.value = false;
      }
    }

    useEffect(() {
      load();
      return null;
    }, [publisherName, post.id]);

    Future<void> toggleCollection(SnPostCollection collection) async {
      if (publisherName == null || publisherName.isEmpty) return;
      if (isLoading.value) return;

      final slug = collection.slug;
      final wasSelected = selected.value.contains(slug);

      // Optimistic UI update.
      final next = Set<String>.from(selected.value);
      if (wasSelected) {
        next.remove(slug);
      } else {
        next.add(slug);
      }
      selected.value = next;

      try {
        isLoading.value = true;
        final client = ref.read(solarNetworkClientProvider);
        if (wasSelected) {
          await client.sphere.removePostFromCollection(
            publisherName: publisherName,
            slug: slug,
            postId: post.id,
          );
        } else {
          await client.sphere.addPostToCollection(
            publisherName: publisherName,
            slug: slug,
            postId: post.id,
          );
        }
        onChanged?.call();
      } catch (err) {
        // Rollback on error.
        final rollback = Set<String>.from(selected.value);
        if (wasSelected) {
          rollback.add(slug);
        } else {
          rollback.remove(slug);
        }
        selected.value = rollback;
        showErrorAlert(err);
      } finally {
        isLoading.value = false;
      }
    }

    return SheetScaffold(
      titleText: 'collections'.tr(),
      actions: [
        IconButton(
          icon: const Icon(Symbols.refresh),
          style: IconButton.styleFrom(minimumSize: const Size(36, 36)),
          onPressed: isLoading.value ? null : load,
        ),
      ],
      child: Builder(
        builder: (context) {
          if (publisherName == null || publisherName.isEmpty) {
            return const Center(child: Text('Publisher required'));
          }

          if (isLoading.value && collections.value.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (collections.value.isEmpty) {
            return const Center(child: Text('No collections'));
          }

          return ListView.separated(
            itemCount: collections.value.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final c = collections.value[index];
              final isSelected = selected.value.contains(c.slug);
              return ListTile(
                leading: Icon(
                  isSelected ? Symbols.check_circle : Symbols.circle,
                  fill: 1,
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.outline,
                ),
                title: Text(c.name?.isNotEmpty == true ? c.name! : c.slug),
                subtitle: (c.description?.isNotEmpty ?? false)
                    ? Text(
                        c.description!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      )
                    : null,
                trailing: isLoading.value
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : null,
                onTap: () => toggleCollection(c),
              );
            },
          );
        },
      ),
    );
  }
}
