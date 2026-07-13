import 'package:easy_localization/easy_localization.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/account_pod.dart';
import 'package:island/core/network.dart';
import 'package:island/core/services/time.dart';
import 'package:island/creators/screens/publishers_form.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:island/posts/pods/post_list.dart';
import 'package:island/posts/widgets/compose/post_list.dart';
import 'package:island/posts/widgets/compose/publishers_modal.dart';
import 'package:island/route.gr.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/shared/widgets/app_scaffold.dart';
import 'package:island/shared/widgets/response.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

part 'post_category_detail.g.dart';

@riverpod
Future<SnPostCategory> postCategory(Ref ref, String slug) async {
  final client = ref.watch(solarNetworkClientProvider);
  // SphereApi.getCategory currently points at /sphere/categories/{slug},
  // but the live route is under /sphere/posts/categories/{slug}.
  final resp = await client.dio.get('/sphere/posts/categories/$slug');
  return SnPostCategory.fromJson(resp.data);
}

@riverpod
Future<SnPostTag> postTag(Ref ref, String slug) async {
  final client = ref.watch(solarNetworkClientProvider);
  return client.sphere.getTag(slug);
}

@riverpod
Future<SnCategorySubscription?> postCategorySubscription(
  Ref ref,
  String slug,
  bool isCategory,
) async {
  final client = ref.watch(solarNetworkClientProvider);
  try {
    final resp = await client.dio.get(
      '/sphere/posts/${isCategory ? 'categories' : 'tags'}/$slug/subscription',
    );
    if (resp.data == null) return null;
    return SnCategorySubscription.fromJson(resp.data);
  } catch (_) {
    return null;
  }
}

Future<void> _subscribeToCategoryOrTag(
  WidgetRef ref, {
  required String slug,
  required bool isCategory,
}) async {
  final client = ref.read(solarNetworkClientProvider);
  await client.dio.post(
    '/sphere/posts/${isCategory ? 'categories' : 'tags'}/$slug/subscribe',
  );
  ref.invalidate(postCategorySubscriptionProvider(slug, isCategory));
}

Future<void> _unsubscribeFromCategoryOrTag(
  WidgetRef ref, {
  required String slug,
  required bool isCategory,
}) async {
  final client = ref.read(solarNetworkClientProvider);
  await client.dio.post(
    '/sphere/posts/${isCategory ? 'categories' : 'tags'}/$slug/unsubscribe',
  );
  ref.invalidate(postCategorySubscriptionProvider(slug, isCategory));
}

Future<SnPublisher?> _pickPublisher(BuildContext context) async {
  return showModalBottomSheet<SnPublisher>(
    context: context,
    isScrollControlled: true,
    builder: (context) => const PublisherModal(),
  );
}

Future<void> _claimTag(
  BuildContext context,
  WidgetRef ref, {
  required String slug,
}) async {
  final publishers = await ref.read(publishersManagedProvider.future);
  if (!context.mounted) return;

  if (publishers.isEmpty) {
    showErrorAlert('publishersEmptyDescription'.tr());
    return;
  }

  SnPublisher? publisher;
  if (publishers.length == 1) {
    publisher = publishers.first;
  } else {
    publisher = await _pickPublisher(context);
  }
  if (publisher == null || !context.mounted) return;

  try {
    showLoadingModal(context);
    final client = ref.read(solarNetworkClientProvider);
    await client.sphere.claimTag(slug: slug, publisherName: publisher.name);
    ref.invalidate(postTagProvider(slug));
    if (context.mounted) {
      showSnackBar('postTagClaimed'.tr());
    }
  } catch (err) {
    showErrorAlert(err);
  } finally {
    if (context.mounted) hideLoadingModal(context);
  }
}

Future<void> _editTag(
  BuildContext context,
  WidgetRef ref, {
  required SnPostTag tag,
}) async {
  final publishers = await ref.read(publishersManagedProvider.future);
  if (!context.mounted) return;

  final ownedByMe = publishers.any((p) => p.id == tag.ownerPublisherId);
  if (!ownedByMe) {
    showErrorAlert('postTagEditForbidden'.tr());
    return;
  }

  final owner = publishers.firstWhere((p) => p.id == tag.ownerPublisherId);
  final nameController = TextEditingController(text: tag.name ?? '');
  final descriptionController = TextEditingController(
    text: tag.description ?? '',
  );

  final saved = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: Text('editPostTag'.tr()),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
      publisherName: owner.name,
    );
    ref.invalidate(postTagProvider(tag.slug));
    if (context.mounted) {
      showSnackBar('postTagUpdated'.tr());
    }
  } catch (err) {
    showErrorAlert(err);
  } finally {
    if (context.mounted) hideLoadingModal(context);
  }
}

Widget _subscriptionButton(
  BuildContext context,
  WidgetRef ref, {
  required String slug,
  required bool isCategory,
  required AsyncValue<SnCategorySubscription?> subscriptionStatus,
}) {
  return subscriptionStatus.when(
    data: (subscription) => subscription != null
        ? FilledButton.tonalIcon(
            onPressed: () async {
              try {
                await _unsubscribeFromCategoryOrTag(
                  ref,
                  slug: slug,
                  isCategory: isCategory,
                );
              } catch (err) {
                showErrorAlert(err);
              }
            },
            icon: const Icon(Symbols.remove_circle),
            label: Text('unsubscribe'.tr()),
          )
        : FilledButton.icon(
            onPressed: () async {
              try {
                await _subscribeToCategoryOrTag(
                  ref,
                  slug: slug,
                  isCategory: isCategory,
                );
              } catch (err) {
                showErrorAlert(err);
              }
            },
            icon: const Icon(Symbols.add_circle),
            label: Text('subscribe'.tr()),
          ),
    error: (error, _) => Text('errorLoadingSubscription'.tr()),
    loading: () => const CircularProgressIndicator().center(),
  );
}

Widget _statusChip({
  required BuildContext context,
  required IconData icon,
  required String label,
  Color? color,
}) {
  final scheme = Theme.of(context).colorScheme;
  final chipColor = color ?? scheme.secondaryContainer;
  final onChip = color != null
      ? scheme.onErrorContainer
      : scheme.onSecondaryContainer;

  return Chip(
    avatar: Icon(icon, size: 16, color: onChip),
    label: Text(label),
    labelStyle: Theme.of(context).textTheme.labelMedium?.copyWith(
      color: onChip,
    ),
    backgroundColor: chipColor,
    side: BorderSide.none,
    visualDensity: VisualDensity.compact,
    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    padding: EdgeInsets.zero,
  );
}

@RoutePage()
class PostCategoryDetailScreen extends HookConsumerWidget {
  final String slug;
  final bool isCategory;
  const PostCategoryDetailScreen({
    super.key,
    required this.slug,
    required this.isCategory,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postCategory = isCategory
        ? ref.watch(postCategoryProvider(slug))
        : null;
    final postTag = isCategory ? null : ref.watch(postTagProvider(slug));
    final subscriptionStatus = ref.watch(
      postCategorySubscriptionProvider(slug, isCategory),
    );
    final publishersManaged = ref.watch(publishersManagedProvider);
    final user = ref.watch(userInfoProvider);

    final postFilterTitle = isCategory
        ? postCategory?.value?.categoryTranslationKey.tr() ?? 'loading'.tr()
        : postTag?.value?.displayName ?? 'loading'.tr();

    final managedPublishers = publishersManaged.value ?? const <SnPublisher>[];
    final ownsTag =
        !isCategory &&
        postTag?.value?.ownerPublisherId != null &&
        managedPublishers.any(
          (p) => p.id == postTag!.value!.ownerPublisherId,
        );
    final canClaimTag =
        !isCategory &&
        user.value != null &&
        postTag?.value?.isUnclaimed == true;

    return AppScaffold(
      isNoBackground: false,
      appBar: AppBar(
        title: Text(postFilterTitle),
        actions: [
          if (ownsTag)
            IconButton(
              tooltip: 'editPostTag'.tr(),
              onPressed: () {
                final tag = postTag?.value;
                if (tag == null) return;
                _editTag(context, ref, tag: tag);
              },
              icon: const Icon(Symbols.edit),
            ),
        ],
      ),
      body: Expanded(
        child: CustomScrollView(
          slivers: [
            if (isCategory)
              SliverToBoxAdapter(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 540),
                    child: Card(
                      margin: const EdgeInsets.only(top: 8),
                      child: postCategory!.when(
                        data: (category) => Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              category.categoryTranslationKey,
                            ).tr().bold().fontSize(15),
                            Text(
                              'postCount',
                            ).plural(category.usage).fontSize(13).opacity(0.7),
                            const Gap(8),
                            _subscriptionButton(
                              context,
                              ref,
                              slug: slug,
                              isCategory: isCategory,
                              subscriptionStatus: subscriptionStatus,
                            ),
                          ],
                        ).padding(horizontal: 24, vertical: 16),
                        error: (error, _) => ResponseErrorWidget(
                          error: error,
                          onRetry: () =>
                              ref.invalidate(postCategoryProvider(slug)),
                        ),
                        loading: () => const ResponseLoadingWidget(),
                      ),
                    ),
                  ).padding(horizontal: 8),
                ),
              )
            else
              SliverToBoxAdapter(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 540),
                    child: Card(
                      margin: const EdgeInsets.only(top: 8),
                      child: postTag!.when(
                        data: (tag) => _TagDetailCard(
                          tag: tag,
                          subscriptionStatus: subscriptionStatus,
                          canClaim: canClaimTag,
                          onSubscribe: () => _subscribeToCategoryOrTag(
                            ref,
                            slug: slug,
                            isCategory: false,
                          ),
                          onUnsubscribe: () => _unsubscribeFromCategoryOrTag(
                            ref,
                            slug: slug,
                            isCategory: false,
                          ),
                          onClaim: () => _claimTag(context, ref, slug: slug),
                        ),
                        error: (error, _) => ResponseErrorWidget(
                          error: error,
                          onRetry: () => ref.invalidate(postTagProvider(slug)),
                        ),
                        loading: () => const ResponseLoadingWidget(),
                      ),
                    ),
                  ).padding(horizontal: 8),
                ),
              ),
            const SliverGap(4),
            SliverPostList(
              query: PostListQuery(
                categories: isCategory ? [slug] : null,
                tags: isCategory ? null : [slug],
              ),
              maxWidth: 540 + 16,
            ),
            SliverGap(MediaQuery.of(context).padding.bottom + 8),
          ],
        ),
      ),
    );
  }
}

class _TagDetailCard extends StatelessWidget {
  final SnPostTag tag;
  final AsyncValue<SnCategorySubscription?> subscriptionStatus;
  final bool canClaim;
  final Future<void> Function() onSubscribe;
  final Future<void> Function() onUnsubscribe;
  final Future<void> Function() onClaim;

  const _TagDetailCard({
    required this.tag,
    required this.subscriptionStatus,
    required this.canClaim,
    required this.onSubscribe,
    required this.onUnsubscribe,
    required this.onClaim,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final owner = tag.ownerPublisher;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(tag.displayName).bold().fontSize(15),
        Text(
          [
            'tagLabel'.tr(),
            if (tag.usage > 0) 'postCount'.plural(tag.usage),
          ].join(' · '),
        ).fontSize(13).opacity(0.7),
        if (tag.description?.isNotEmpty == true) ...[
          const Gap(8),
          Text(
            tag.description!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
        const Gap(10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            if (tag.isUnclaimed)
              _statusChip(
                context: context,
                icon: Symbols.lock_open,
                label: 'tagUnclaimed'.tr(),
              ),
            if (tag.isProtected)
              _statusChip(
                context: context,
                icon: Symbols.lock,
                label: 'tagProtected'.tr(),
              ),
            if (tag.isEvent)
              _statusChip(
                context: context,
                icon: tag.isEventExpired
                    ? Symbols.event_busy
                    : Symbols.event,
                label: tag.isEventExpired
                    ? 'tagEventExpired'.tr()
                    : tag.eventEndsAt != null
                    ? 'tagEventEnds'.tr(
                        args: [tag.eventEndsAt!.formatSystem()],
                      )
                    : 'tagEvent'.tr(),
                color: tag.isEventExpired
                    ? scheme.errorContainer
                    : null,
              ),
          ],
        ),
        if (tag.isUnclaimed) ...[
          const Gap(8),
          Text(
            'postTagUnclaimedHint'.tr(),
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ] else if (tag.isProtected) ...[
          const Gap(8),
          Text(
            'postTagProtectedHint'.tr(),
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
        if (owner != null) ...[
          const Gap(12),
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              context.router.push(PublisherProfileRoute(name: owner.name));
            },
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  ProfilePictureWidget(
                    file: owner.picture,
                    radius: 18,
                    borderRadius: owner.type == 0 ? null : 8,
                  ),
                  const Gap(10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'tagOwnedBy'.tr(),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                        Text(
                          owner.nick.isNotEmpty ? owner.nick : owner.name,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '@${owner.name}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Symbols.chevron_right,
                    color: scheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
        ],
        const Gap(12),
        if (canClaim) ...[
          FilledButton.icon(
            onPressed: () async {
              try {
                await onClaim();
              } catch (err) {
                showErrorAlert(err);
              }
            },
            icon: const Icon(Symbols.flag),
            label: Text('claimPostTag'.tr()),
          ),
          const Gap(8),
        ],
        subscriptionStatus.when(
          data: (subscription) => subscription != null
              ? FilledButton.tonalIcon(
                  onPressed: () async {
                    try {
                      await onUnsubscribe();
                    } catch (err) {
                      showErrorAlert(err);
                    }
                  },
                  icon: const Icon(Symbols.remove_circle),
                  label: Text('unsubscribe'.tr()),
                )
              : FilledButton.icon(
                  onPressed: () async {
                    try {
                      await onSubscribe();
                    } catch (err) {
                      showErrorAlert(err);
                    }
                  },
                  icon: const Icon(Symbols.add_circle),
                  label: Text('subscribe'.tr()),
                ),
          error: (error, _) => Text('errorLoadingSubscription'.tr()),
          loading: () => const CircularProgressIndicator().center(),
        ),
      ],
    ).padding(horizontal: 24, vertical: 16);
  }
}
