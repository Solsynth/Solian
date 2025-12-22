import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/pods/post/post_subscriptions.dart';
import 'package:material_symbols_icons/symbols.dart';

class PostSubscriptionFilterWidget extends HookConsumerWidget {
  final List<String> initialSelectedPublisherIds;
  final ValueChanged<List<String>> onSelectedPublishersChanged;
  final bool hideSearch;

  const PostSubscriptionFilterWidget({
    super.key,
    required this.initialSelectedPublisherIds,
    required this.onSelectedPublishersChanged,
    this.hideSearch = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedPublisherIds = useState<List<String>>(
      initialSelectedPublisherIds,
    );
    final showSubscriptions = useState<bool>(false);

    final subscriptionsAsync = ref.watch(subscriptionsProvider);

    void updateSelection() {
      onSelectedPublishersChanged(selectedPublisherIds.value);
    }

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Column(
        children: [
          ListTile(
            title: Text('filterBySubscriptions'.tr()),
            leading: const Icon(Symbols.subscriptions),
            contentPadding: const EdgeInsets.symmetric(horizontal: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(const Radius.circular(8)),
            ),
            trailing: Icon(
              showSubscriptions.value
                  ? Symbols.expand_less
                  : Symbols.expand_more,
            ),
            onTap: () {
              showSubscriptions.value = !showSubscriptions.value;
            },
          ),
          if (showSubscriptions.value) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
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
                          final isSelected = selectedPublisherIds.value
                              .contains(subscription.publisherId);
                          final publisher = subscription.publisher;

                          return CheckboxListTile(
                            title: Text(publisher.name),
                            subtitle:
                                publisher.nick.isNotEmpty &&
                                    publisher.nick != publisher.name
                                ? Text(publisher.nick)
                                : null,
                            value: isSelected,
                            onChanged: (value) {
                              if (value == true) {
                                selectedPublisherIds.value = [
                                  ...selectedPublisherIds.value,
                                  subscription.publisherId,
                                ];
                              } else {
                                selectedPublisherIds.value =
                                    selectedPublisherIds.value
                                        .where(
                                          (id) =>
                                              id != subscription.publisherId,
                                        )
                                        .toList();
                              }
                              updateSelection();
                            },
                            dense: true,
                            controlAffinity: ListTileControlAffinity.leading,
                            secondary: const Icon(Symbols.person),
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
                  if (subscriptionsAsync.hasValue &&
                      subscriptionsAsync.value!.isNotEmpty) ...[
                    const Gap(12),
                    Row(
                      children: [
                        TextButton(
                          onPressed: () {
                            selectedPublisherIds.value = subscriptionsAsync
                                .value!
                                .map((s) => s.publisherId)
                                .toList();
                            updateSelection();
                          },
                          child: Text('selectAll'.tr()),
                        ),
                        const Gap(8),
                        TextButton(
                          onPressed: () {
                            selectedPublisherIds.value = [];
                            updateSelection();
                          },
                          child: Text('selectNone'.tr()),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
