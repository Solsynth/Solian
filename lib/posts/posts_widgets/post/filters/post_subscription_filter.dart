import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/posts/posts_models/post.dart';
import 'package:island/posts/posts_models/post_category.dart';
import 'package:island/core/network.dart';
import 'package:island/drive/drive_widgets/cloud_files.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:styled_widget/styled_widget.dart';

part 'post_subscription_filter.g.dart';

@riverpod
Future<List<SnPublisherSubscription>> publishersSubscriptions(Ref ref) async {
  final client = ref.read(apiClientProvider);

  final response = await client.get('/sphere/publishers/subscriptions');

  return response.data
      .map((json) => SnPublisherSubscription.fromJson(json))
      .cast<SnPublisherSubscription>()
      .toList();
}

@riverpod
Future<List<SnCategorySubscription>> categoriesSubscriptions(Ref ref) async {
  final client = ref.read(apiClientProvider);

  final response = await client.get('/sphere/categories/subscriptions');

  return response.data
      .map((json) => SnCategorySubscription.fromJson(json))
      .cast<SnCategorySubscription>()
      .toList();
}

class PostSubscriptionFilterWidget extends HookConsumerWidget {
  final List<String> initialSelectedPublishers;
  final List<String> initialSelectedCategories;
  final List<String> initialSelectedTags;
  final ValueChanged<List<String>> onSelectedPublishersChanged;
  final ValueChanged<List<String>> onSelectedCategoriesChanged;
  final ValueChanged<List<String>> onSelectedTagsChanged;
  final bool hideSearch;

  const PostSubscriptionFilterWidget({
    super.key,
    required this.initialSelectedPublishers,
    required this.initialSelectedCategories,
    required this.initialSelectedTags,
    required this.onSelectedPublishersChanged,
    required this.onSelectedCategoriesChanged,
    required this.onSelectedTagsChanged,
    this.hideSearch = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedPublishers = useState<List<String>>(
      initialSelectedPublishers,
    );
    final selectedCategories = useState<List<String>>(
      initialSelectedCategories,
    );
    final selectedTags = useState<List<String>>(initialSelectedTags);

    final publishersAsync = ref.watch(publishersSubscriptionsProvider);
    final categoriesAsync = ref.watch(categoriesSubscriptionsProvider);

    void updateSelection() {
      onSelectedPublishersChanged(selectedPublishers.value);
      onSelectedCategoriesChanged(selectedCategories.value);
      onSelectedTagsChanged(selectedTags.value);
    }

    return Card(
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            spacing: 16,
            children: [
              const Icon(Symbols.subscriptions, size: 20),
              Text(
                'exploreFilterSubscriptions'.tr(),
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ).padding(horizontal: 16, top: 12),
          const Gap(12),

          // Publishers Section
          publishersAsync.when(
            data: (subscriptions) {
              if (subscriptions.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text('noSubscriptions'.tr()),
                  ),
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'publishers'.tr(),
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ).padding(bottom: 8, horizontal: 16),
                  ...subscriptions.map((subscription) {
                    final isSelected = selectedPublishers.value.contains(
                      subscription.publisher.name,
                    );
                    final publisher = subscription.publisher;

                    return CheckboxListTile(
                      controlAffinity: ListTileControlAffinity.trailing,
                      title: Text(publisher.nick),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      ),
                      value: isSelected,
                      onChanged: (value) {
                        if (value == true) {
                          selectedPublishers.value = [
                            ...selectedPublishers.value,
                            subscription.publisher.name,
                          ];
                        } else {
                          selectedPublishers.value = selectedPublishers.value
                              .where(
                                (name) => name != subscription.publisher.name,
                              )
                              .toList();
                        }
                        updateSelection();
                      },
                      dense: true,
                      secondary: ProfilePictureWidget(
                        file: subscription.publisher.picture,
                        radius: 12,
                      ),
                      contentPadding: const EdgeInsets.only(
                        left: 15,
                        right: 16,
                      ),
                    );
                  }),
                ],
              );
            },
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ),
            ),
            error: (error, stack) => Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('errorLoadingSubscriptions'.tr()),
              ),
            ),
          ),

          if (publishersAsync.value?.isNotEmpty ?? false)
            const Divider(height: 1).padding(vertical: 8),

          // Categories Section
          categoriesAsync.when(
            data: (subscriptions) {
              if (subscriptions.isEmpty) {
                return const SizedBox.shrink();
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'categoriesAndTags'.tr(),
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ).padding(bottom: 8, horizontal: 16),
                  ...subscriptions.map((subscription) {
                    final category = subscription.category;
                    final tag = subscription.tag;
                    final slug = category?.slug ?? tag?.slug;
                    final displayTitle =
                        category?.categoryDisplayTitle ??
                        tag?.name ??
                        slug ??
                        '';
                    final isCategorySelected = selectedCategories.value
                        .contains(slug);
                    final isTagSelected = selectedTags.value.contains(slug);

                    return CheckboxListTile(
                      controlAffinity: ListTileControlAffinity.trailing,
                      title: Text(displayTitle),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      ),
                      secondary: category != null
                          ? Icon(Symbols.category)
                          : Icon(Symbols.tag),
                      value: category != null
                          ? isCategorySelected
                          : isTagSelected,
                      onChanged: (value) {
                        if (value == true) {
                          if (category != null) {
                            selectedCategories.value = [
                              ...selectedCategories.value,
                              slug!,
                            ];
                          } else if (tag != null) {
                            selectedTags.value = [...selectedTags.value, slug!];
                          }
                        } else {
                          if (category != null) {
                            selectedCategories.value = selectedCategories.value
                                .where((id) => id != slug)
                                .toList();
                          } else if (tag != null) {
                            selectedTags.value = selectedTags.value
                                .where((id) => id != slug)
                                .toList();
                          }
                        }
                        updateSelection();
                      },
                      dense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                    );
                  }),
                ],
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (error, stack) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
