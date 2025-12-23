import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/models/post.dart';
import 'package:island/models/post_category.dart';
import 'package:island/pods/network.dart';
import 'package:island/widgets/content/cloud_files.dart';
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
  final List<String> initialSelectedPublisherNames;
  final ValueChanged<List<String>> onSelectedPublishersChanged;
  final bool hideSearch;

  const PostSubscriptionFilterWidget({
    super.key,
    required this.initialSelectedPublisherNames,
    required this.onSelectedPublishersChanged,
    this.hideSearch = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedPublisherNames = useState<List<String>>(
      initialSelectedPublisherNames,
    );

    final subscriptionsAsync = ref.watch(publishersSubscriptionsProvider);

    void updateSelection() {
      onSelectedPublishersChanged(selectedPublisherNames.value);
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
          subscriptionsAsync.when(
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
                children: subscriptions.map((subscription) {
                  final isSelected = selectedPublisherNames.value.contains(
                    subscription.publisher.name,
                  );
                  final publisher = subscription.publisher;

                  return CheckboxListTile(
                    controlAffinity: ListTileControlAffinity.trailing,
                    title: Text(publisher.nick),
                    subtitle: Text('@${publisher.name}'),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                    value: isSelected,
                    onChanged: (value) {
                      if (value == true) {
                        selectedPublisherNames.value = [
                          ...selectedPublisherNames.value,
                          subscription.publisher.name,
                        ];
                      } else {
                        selectedPublisherNames.value = selectedPublisherNames
                            .value
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
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  );
                }).toList(),
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
        ],
      ),
    );
  }
}
