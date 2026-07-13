import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/network.dart';
import 'package:island/core/services/time.dart';
import 'package:island/route.gr.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/shared/widgets/app_scaffold.dart';
import 'package:island/shared/widgets/layouts/sheet_scaffold.dart';
import 'package:island/shared/widgets/response.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

part 'tag_manage.g.dart';

/// Protected-tag quota and owned tags for a publisher.
@riverpod
Future<SnTagQuota> publisherTagQuota(Ref ref, String pubName) async {
  final client = ref.watch(solarNetworkClientProvider);
  return client.sphere.getProtectedTagQuota(publisherName: pubName);
}

@riverpod
Future<SnPublisher> creatorPublisher(Ref ref, String pubName) async {
  final client = ref.watch(solarNetworkClientProvider);
  return client.sphere.getPublisher(pubName);
}

Future<void> _showCreateTagSheet(
  BuildContext context,
  WidgetRef ref, {
  required String pubName,
}) async {
  final created = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useRootNavigator: true,
    builder: (_) => _CreateTagSheet(pubName: pubName),
  );
  if (created == true) {
    ref.invalidate(publisherTagQuotaProvider(pubName));
  }
}

Future<void> _showClaimTagSheet(
  BuildContext context,
  WidgetRef ref, {
  required String pubName,
}) async {
  final claimed = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useRootNavigator: true,
    builder: (_) => _ClaimTagSheet(pubName: pubName),
  );
  if (claimed == true) {
    ref.invalidate(publisherTagQuotaProvider(pubName));
  }
}

Future<void> _releaseOwnedTag(
  BuildContext context,
  WidgetRef ref, {
  required String pubName,
  required String slug,
}) async {
  final confirm = await showConfirmAlert(
    'releasePostTagHint'.tr(args: ['#$slug']),
    'releasePostTag'.tr(),
    isDanger: true,
  );
  if (confirm != true || !context.mounted) return;

  try {
    showLoadingModal(context);
    final client = ref.read(solarNetworkClientProvider);
    await client.sphere.releaseTag(slug: slug, publisherName: pubName);
    ref.invalidate(publisherTagQuotaProvider(pubName));
    if (context.mounted) {
      showSnackBar('postTagReleased'.tr());
    }
  } catch (err) {
    showErrorAlert(err);
  } finally {
    if (context.mounted) hideLoadingModal(context);
  }
}

Future<void> _editOwnedTag(
  BuildContext context,
  WidgetRef ref, {
  required String pubName,
  required SnPostTag tag,
}) async {
  final nameController = TextEditingController(text: tag.name ?? '');
  final descriptionController = TextEditingController(
    text: tag.description ?? '',
  );

  final saved = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: Text('editPostTag'.tr()),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '#${tag.slug}',
                style: Theme.of(dialogContext).textTheme.bodySmall?.copyWith(
                  color: Theme.of(dialogContext).colorScheme.onSurfaceVariant,
                ),
              ),
              const Gap(12),
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'name'.tr()),
                textCapitalization: TextCapitalization.sentences,
              ),
              const Gap(12),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(
                  labelText: 'description'.tr(),
                  alignLabelWithHint: true,
                ),
                minLines: 2,
                maxLines: 5,
                textCapitalization: TextCapitalization.sentences,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text('cancel'.tr()),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text('save'.tr()),
          ),
        ],
      );
    },
  );

  final name = nameController.text.trim();
  final description = descriptionController.text.trim();
  nameController.dispose();
  descriptionController.dispose();

  if (saved != true || !context.mounted) return;

  try {
    showLoadingModal(context);
    final client = ref.read(solarNetworkClientProvider);
    await client.sphere.updateTag(
      slug: tag.slug,
      name: name.isEmpty ? null : name,
      description: description,
      publisherName: pubName,
    );
    ref.invalidate(publisherTagQuotaProvider(pubName));
    if (context.mounted) {
      showSnackBar('postTagUpdated'.tr());
    }
  } catch (err) {
    showErrorAlert(err);
  } finally {
    if (context.mounted) hideLoadingModal(context);
  }
}

Future<void> _openTagForManage(
  BuildContext context,
  WidgetRef ref, {
  required String pubName,
  required String slug,
}) async {
  final normalized = slug.trim().toLowerCase();
  if (normalized.isEmpty) return;

  try {
    showLoadingModal(context);
    final client = ref.read(solarNetworkClientProvider);
    final tag = await client.sphere.getTag(normalized);
    if (!context.mounted) return;
    hideLoadingModal(context);

    final publisher = await ref.read(creatorPublisherProvider(pubName).future);
    if (!context.mounted) return;

    final isOwner = tag.ownerPublisherId == publisher.id;
    if (isOwner) {
      await _editOwnedTag(context, ref, pubName: pubName, tag: tag);
      return;
    }

    if (tag.isUnclaimed) {
      final confirm = await showConfirmAlert(
        'postTagClaimConfirmHint'.tr(args: ['#${tag.slug}']),
        'claimPostTag'.tr(),
      );
      if (confirm != true || !context.mounted) return;
      try {
        showLoadingModal(context);
        await client.sphere.claimTag(slug: tag.slug, publisherName: pubName);
        ref.invalidate(publisherTagQuotaProvider(pubName));
        if (context.mounted) showSnackBar('postTagClaimed'.tr());
      } catch (err) {
        showErrorAlert(err);
      } finally {
        if (context.mounted) hideLoadingModal(context);
      }
      return;
    }

    if (context.mounted) {
      context.router.push(
        PostCategoryDetailRoute(slug: tag.slug, isCategory: false),
      );
    }
  } catch (err) {
    if (context.mounted) hideLoadingModal(context);
    showErrorAlert(err);
  }
}

@RoutePage()
class CreatorTagManageScreen extends HookConsumerWidget {
  final String pubName;
  const CreatorTagManageScreen({
    super.key,
    @PathParam('pubName') required this.pubName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quota = ref.watch(publisherTagQuotaProvider(pubName));
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return AppScaffold(
      appBar: AppBar(
        leading: const AutoLeadingButton(),
        title: Text('publisherTags'.tr()),
        actions: [
          IconButton(
            tooltip: 'claimPostTag'.tr(),
            onPressed: () => _showClaimTagSheet(context, ref, pubName: pubName),
            icon: const Icon(Symbols.flag),
          ),
          IconButton(
            tooltip: 'managePostTag'.tr(),
            onPressed: () => _showManageBySlugSheet(context, ref),
            icon: const Icon(Symbols.search),
          ),
          const Gap(8),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateTagSheet(context, ref, pubName: pubName),
        icon: const Icon(Symbols.add),
        label: Text('createPostTag'.tr()),
      ),
      body: quota.when(
        data: (data) {
          final records = data.records;
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(publisherTagQuotaProvider(pubName));
              await ref.read(publisherTagQuotaProvider(pubName).future);
            },
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
              children: [
                Card(
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Symbols.lock, color: scheme.primary),
                            const Gap(8),
                            Expanded(
                              child: Text(
                                'protectedTagQuota'.tr(),
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Text(
                              '${data.used}/${data.total}',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const Gap(8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: data.total == 0
                                ? 0
                                : (data.used / data.total).clamp(0.0, 1.0),
                            minHeight: 6,
                          ),
                        ),
                        const Gap(8),
                        Text(
                          'protectedTagQuotaHint'.tr(
                            args: [
                              data.remaining.toString(),
                              data.perkLevel.toString(),
                            ],
                          ),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                        const Gap(4),
                        Text(
                          'publisherTagsDescription'.tr(),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Gap(16),
                Text(
                  'ownedTags'.tr(),
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Gap(8),
                if (records.isEmpty)
                  Card(
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          Icon(
                            Symbols.label_off,
                            size: 40,
                            color: scheme.onSurfaceVariant,
                          ),
                          const Gap(8),
                          Text(
                            'ownedTagsEmpty'.tr(),
                            textAlign: TextAlign.center,
                          ),
                          const Gap(4),
                          Text(
                            'ownedTagsEmptyHint'.tr(),
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Card(
                    margin: EdgeInsets.zero,
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      children: [
                        for (var i = 0; i < records.length; i++) ...[
                          if (i > 0) const Divider(height: 1),
                          ListTile(
                            leading: Icon(
                              records[i].isProtected
                                  ? Symbols.lock
                                  : Symbols.label,
                            ),
                            title: Text(
                              records[i].name?.isNotEmpty == true
                                  ? records[i].name!
                                  : '#${records[i].slug}',
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('#${records[i].slug}'),
                                if (records[i].description?.isNotEmpty == true)
                                  Text(
                                    records[i].description!,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                Wrap(
                                  spacing: 6,
                                  children: [
                                    if (records[i].isProtected)
                                      Text(
                                        'tagProtected'.tr(),
                                        style: theme.textTheme.labelSmall,
                                      ),
                                    if (records[i].isEvent)
                                      Text(
                                        records[i].eventEndsAt != null &&
                                                !records[i].eventEndsAt!
                                                    .toUtc()
                                                    .isAfter(
                                                      DateTime.now().toUtc(),
                                                    )
                                            ? 'tagEventExpired'.tr()
                                            : records[i].eventEndsAt != null
                                            ? 'tagEventEnds'.tr(
                                                args: [
                                                  records[i].eventEndsAt!
                                                      .formatSystem(),
                                                ],
                                              )
                                            : 'tagEvent'.tr(),
                                        style: theme.textTheme.labelSmall,
                                      ),
                                  ],
                                ),
                              ],
                            ),
                            isThreeLine:
                                records[i].description?.isNotEmpty == true ||
                                records[i].isProtected ||
                                records[i].isEvent,
                            trailing: PopupMenuButton<String>(
                              onSelected: (action) async {
                                final record = records[i];
                                switch (action) {
                                  case 'open':
                                    context.router.push(
                                      PostCategoryDetailRoute(
                                        slug: record.slug,
                                        isCategory: false,
                                      ),
                                    );
                                  case 'edit':
                                    try {
                                      showLoadingModal(context);
                                      final client = ref.read(
                                        solarNetworkClientProvider,
                                      );
                                      final tag = await client.sphere.getTag(
                                        record.slug,
                                      );
                                      if (!context.mounted) return;
                                      hideLoadingModal(context);
                                      await _editOwnedTag(
                                        context,
                                        ref,
                                        pubName: pubName,
                                        tag: tag,
                                      );
                                    } catch (err) {
                                      if (context.mounted) {
                                        hideLoadingModal(context);
                                      }
                                      showErrorAlert(err);
                                    }
                                  case 'release':
                                    await _releaseOwnedTag(
                                      context,
                                      ref,
                                      pubName: pubName,
                                      slug: record.slug,
                                    );
                                }
                              },
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  value: 'open',
                                  child: Text('open'.tr()),
                                ),
                                PopupMenuItem(
                                  value: 'edit',
                                  child: Text('editPostTag'.tr()),
                                ),
                                PopupMenuItem(
                                  value: 'release',
                                  child: Text('releasePostTag'.tr()),
                                ),
                              ],
                            ),
                            onTap: () {
                              context.router.push(
                                PostCategoryDetailRoute(
                                  slug: records[i].slug,
                                  isCategory: false,
                                ),
                              );
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                const Gap(20),
                Text(
                  'publisherTagActions'.tr(),
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Gap(8),
                Card(
                  margin: EdgeInsets.zero,
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Symbols.add_circle),
                        title: Text('createPostTag'.tr()),
                        subtitle: Text('createPostTagHint'.tr()),
                        trailing: const Icon(Symbols.chevron_right),
                        onTap: () =>
                            _showCreateTagSheet(context, ref, pubName: pubName),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Symbols.flag),
                        title: Text('claimPostTag'.tr()),
                        subtitle: Text('claimPostTagHint'.tr()),
                        trailing: const Icon(Symbols.chevron_right),
                        onTap: () =>
                            _showClaimTagSheet(context, ref, pubName: pubName),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Symbols.edit),
                        title: Text('managePostTag'.tr()),
                        subtitle: Text('managePostTagHint'.tr()),
                        trailing: const Icon(Symbols.chevron_right),
                        onTap: () => _showManageBySlugSheet(context, ref),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: ResponseLoadingWidget()),
        error: (error, _) => Center(
          child: ResponseErrorWidget(
            error: error,
            onRetry: () => ref.invalidate(publisherTagQuotaProvider(pubName)),
          ),
        ),
      ),
    );
  }

  Future<void> _showManageBySlugSheet(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final controller = TextEditingController();
    final slug = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('managePostTag'.tr()),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: InputDecoration(
              labelText: 'tagSlug'.tr(),
              hintText: 'photography',
              prefixText: '#',
            ),
            onSubmitted: (value) => Navigator.pop(dialogContext, value.trim()),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text('cancel'.tr()),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.pop(dialogContext, controller.text.trim()),
              child: Text('open'.tr()),
            ),
          ],
        );
      },
    );
    controller.dispose();
    if (slug == null || slug.isEmpty || !context.mounted) return;
    await _openTagForManage(context, ref, pubName: pubName, slug: slug);
  }
}

class _CreateTagSheet extends HookConsumerWidget {
  final String pubName;
  const _CreateTagSheet({required this.pubName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final slugController = useTextEditingController();
    final nameController = useTextEditingController();
    final descriptionController = useTextEditingController();
    final submitting = useState(false);

    Future<void> submit() async {
      final slug = slugController.text.trim().toLowerCase();
      if (slug.isEmpty) {
        showErrorAlert('tagSlugRequired'.tr());
        return;
      }
      submitting.value = true;
      try {
        final client = ref.read(solarNetworkClientProvider);
        final tag = await client.sphere.createTag(
          slug: slug,
          name: nameController.text.trim().isEmpty
              ? null
              : nameController.text.trim(),
          description: descriptionController.text.trim().isEmpty
              ? null
              : descriptionController.text.trim(),
          publisherName: pubName,
        );
        if (context.mounted) {
          showSnackBar('postTagCreated'.tr(args: ['#${tag.slug}']));
          Navigator.pop(context, true);
        }
      } catch (err) {
        showErrorAlert(err);
      } finally {
        submitting.value = false;
      }
    }

    return SheetScaffold(
      titleText: 'createPostTag'.tr(),
      actions: [
        IconButton(
          onPressed: submitting.value ? null : submit,
          icon: submitting.value
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Symbols.check),
        ),
      ],
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        children: [
          TextField(
            controller: slugController,
            autofocus: true,
            decoration: InputDecoration(
              labelText: 'tagSlug'.tr(),
              hintText: 'photography',
              prefixText: '#',
              helperText: 'tagSlugHint'.tr(),
            ),
            textInputAction: TextInputAction.next,
          ),
          const Gap(12),
          TextField(
            controller: nameController,
            decoration: InputDecoration(labelText: 'name'.tr()),
            textCapitalization: TextCapitalization.sentences,
            textInputAction: TextInputAction.next,
          ),
          const Gap(12),
          TextField(
            controller: descriptionController,
            decoration: InputDecoration(
              labelText: 'description'.tr(),
              alignLabelWithHint: true,
            ),
            minLines: 2,
            maxLines: 5,
            textCapitalization: TextCapitalization.sentences,
          ),
          const Gap(12),
          Text(
            'createPostTagOwnershipHint'.tr(),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _ClaimTagSheet extends HookConsumerWidget {
  final String pubName;
  const _ClaimTagSheet({required this.pubName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final slugController = useTextEditingController();
    final submitting = useState(false);
    final preview = useState<SnPostTag?>(null);
    final lookingUp = useState(false);

    Future<void> lookup() async {
      final slug = slugController.text.trim().toLowerCase();
      if (slug.isEmpty) return;
      lookingUp.value = true;
      preview.value = null;
      try {
        final client = ref.read(solarNetworkClientProvider);
        preview.value = await client.sphere.getTag(slug);
      } catch (err) {
        showErrorAlert(err);
      } finally {
        lookingUp.value = false;
      }
    }

    Future<void> claim() async {
      final slug = slugController.text.trim().toLowerCase();
      if (slug.isEmpty) {
        showErrorAlert('tagSlugRequired'.tr());
        return;
      }
      submitting.value = true;
      try {
        final client = ref.read(solarNetworkClientProvider);
        await client.sphere.claimTag(slug: slug, publisherName: pubName);
        if (context.mounted) {
          showSnackBar('postTagClaimed'.tr());
          Navigator.pop(context, true);
        }
      } catch (err) {
        showErrorAlert(err);
      } finally {
        submitting.value = false;
      }
    }

    final tag = preview.value;
    final canClaim = tag?.isUnclaimed == true;

    return SheetScaffold(
      titleText: 'claimPostTag'.tr(),
      actions: [
        IconButton(
          onPressed: submitting.value || !canClaim ? null : claim,
          icon: submitting.value
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Symbols.check),
        ),
      ],
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        children: [
          TextField(
            controller: slugController,
            autofocus: true,
            decoration: InputDecoration(
              labelText: 'tagSlug'.tr(),
              hintText: 'photography',
              prefixText: '#',
              suffixIcon: IconButton(
                onPressed: lookingUp.value ? null : lookup,
                icon: lookingUp.value
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Symbols.search),
              ),
            ),
            onSubmitted: (_) => lookup(),
          ),
          const Gap(12),
          Text(
            'claimPostTagHint'.tr(),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          if (tag != null) ...[
            const Gap(16),
            Card(
              margin: EdgeInsets.zero,
              child: ListTile(
                leading: Icon(
                  tag.isUnclaimed ? Symbols.lock_open : Symbols.lock,
                ),
                title: Text(tag.displayName),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('#${tag.slug}'),
                    if (tag.description?.isNotEmpty == true)
                      Text(tag.description!),
                    const Gap(4),
                    Text(
                      tag.isUnclaimed
                          ? 'tagUnclaimed'.tr()
                          : tag.ownerPublisher != null
                          ? 'tagOwnedByPublisher'.tr(
                              args: [
                                tag.ownerPublisher!.nick.isNotEmpty
                                    ? tag.ownerPublisher!.nick
                                    : '@${tag.ownerPublisher!.name}',
                              ],
                            )
                          : 'tagProtected'.tr(),
                    ).bold().fontSize(12),
                    if (tag.isEvent) ...[
                      Text(
                        tag.isEventExpired
                            ? 'tagEventExpired'.tr()
                            : tag.eventEndsAt != null
                            ? 'tagEventEnds'.tr(
                                args: [tag.eventEndsAt!.formatSystem()],
                              )
                            : 'tagEvent'.tr(),
                      ).fontSize(12),
                    ],
                  ],
                ),
                isThreeLine: true,
              ),
            ),
            if (!tag.isUnclaimed) ...[
              const Gap(8),
              Text(
                'postTagAlreadyOwned'.tr(),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}
