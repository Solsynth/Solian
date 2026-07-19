import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/network.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

part 'post_subscription_filter.g.dart';

/// One row from `GET /sphere/publishers/subscriptions`.
class PublisherSubscriptionLiveItem {
  final SnPublisherSubscriptionCompact subscription;
  final DateTime? lastReadAt;
  final bool isLive;
  final DateTime? latestContentAt;
  final bool hasNewContent;

  const PublisherSubscriptionLiveItem({
    required this.subscription,
    this.lastReadAt,
    required this.isLive,
    this.latestContentAt,
    this.hasNewContent = false,
  });

  String get publisherName => subscription.publisher.name;

  PublisherSubscriptionLiveItem copyWith({
    SnPublisherSubscriptionCompact? subscription,
    DateTime? lastReadAt,
    bool? isLive,
    DateTime? latestContentAt,
    bool? hasNewContent,
    bool clearLastReadAt = false,
    bool clearLatestContentAt = false,
  }) {
    return PublisherSubscriptionLiveItem(
      subscription: subscription ?? this.subscription,
      lastReadAt: clearLastReadAt ? null : (lastReadAt ?? this.lastReadAt),
      isLive: isLive ?? this.isLive,
      latestContentAt: clearLatestContentAt
          ? null
          : (latestContentAt ?? this.latestContentAt),
      hasNewContent: hasNewContent ?? this.hasNewContent,
    );
  }
}

/// Response from `GET|PUT /sphere/publishers/{name}/subscription/read-status`.
class PublisherSubscriptionReadStatus {
  final SnPublisherSubscription? subscription;
  final DateTime? latestContentAt;
  final bool hasNewContent;

  const PublisherSubscriptionReadStatus({
    this.subscription,
    this.latestContentAt,
    this.hasNewContent = false,
  });

  DateTime? get lastReadAt => subscription?.lastReadAt;

  factory PublisherSubscriptionReadStatus.fromJson(Map<String, dynamic> json) {
    SnPublisherSubscription? subscription;
    final subRaw = json['subscription'];
    if (subRaw is Map) {
      try {
        subscription = SnPublisherSubscription.fromJson(
          Map<String, dynamic>.from(subRaw),
        );
      } catch (_) {
        subscription = null;
      }
    }

    DateTime? latestContentAt;
    final latestRaw = json['latest_content_at'];
    if (latestRaw is String) {
      latestContentAt = DateTime.tryParse(latestRaw);
    }

    return PublisherSubscriptionReadStatus(
      subscription: subscription,
      latestContentAt: latestContentAt,
      hasNewContent: json['has_new_content'] == true,
    );
  }
}

PublisherSubscriptionLiveItem? _parseLiveItem(Object? raw) {
  if (raw is! Map) return null;
  final json = Map<String, dynamic>.from(raw);
  final subRaw = json['subscription'];
  final subMap = Map<String, dynamic>.from(
    subRaw is Map ? Map<String, dynamic>.from(subRaw) : json,
  );

  final publisherRaw = subMap['publisher'];
  if (publisherRaw is! Map) return null;

  final publisher = SnPublisher.fromJson(
    Map<String, dynamic>.from(publisherRaw),
  );
  final subscription = SnPublisherSubscriptionCompact(
    accountId: (subMap['account_id'] ?? subMap['accountId'] ?? '') as String,
    publisherId:
        (subMap['publisher_id'] ?? subMap['publisherId'] ?? publisher.id)
            as String,
    publisher: publisher,
  );

  DateTime? lastReadAt;
  final lastReadRaw = subMap['last_read_at'] ?? subMap['lastReadAt'];
  if (lastReadRaw is String) {
    lastReadAt = DateTime.tryParse(lastReadRaw);
  }

  DateTime? latestContentAt;
  final latestRaw = json['latest_content_at'] ?? json['latestContentAt'];
  if (latestRaw is String) {
    latestContentAt = DateTime.tryParse(latestRaw);
  }

  final hasNewContent =
      json['has_new_content'] == true || json['hasNewContent'] == true;
  final isLive = json['is_live'] == true || json['isLive'] == true;

  return PublisherSubscriptionLiveItem(
    subscription: subscription,
    lastReadAt: lastReadAt,
    isLive: isLive,
    latestContentAt: latestContentAt,
    hasNewContent: hasNewContent,
  );
}

/// Fetch all pages ordered by latest public root post (newest first).
Future<List<PublisherSubscriptionLiveItem>> fetchPublisherSubscriptionsLive(
  SolarNetworkClient client, {
  String order = 'latest_posted_at',
  int pageSize = 50,
}) async {
  final items = <PublisherSubscriptionLiveItem>[];
  var offset = 0;
  int? total;

  while (true) {
    final response = await client.dio.get(
      '/sphere/publishers/subscriptions',
      queryParameters: {
        'order': order,
        'offset': offset,
        'take': pageSize,
      },
    );

    final data = response.data;
    if (data is! List || data.isEmpty) break;

    final page = data
        .map(_parseLiveItem)
        .whereType<PublisherSubscriptionLiveItem>()
        .toList();
    if (page.isEmpty) break;

    items.addAll(page);
    offset += page.length;

    final totalHeader =
        response.headers.value('x-total') ?? response.headers.value('X-Total');
    total ??= int.tryParse(totalHeader ?? '');

    if (page.length < pageSize) break;
    if (total != null && offset >= total) break;
  }

  // Unread + live first while keeping relative recency within groups.
  items.sort((a, b) {
    if (a.hasNewContent != b.hasNewContent) {
      return a.hasNewContent ? -1 : 1;
    }
    if (a.isLive != b.isLive) {
      return a.isLive ? -1 : 1;
    }
    final aAt = a.latestContentAt;
    final bAt = b.latestContentAt;
    if (aAt == null && bAt == null) return 0;
    if (aAt == null) return 1;
    if (bAt == null) return -1;
    return bAt.compareTo(aAt);
  });

  return items;
}

@riverpod
Future<List<SnPublisherSubscription>> publishersSubscriptions(Ref ref) async {
  final client = ref.read(solarNetworkClientProvider);
  final response = await client.dio.get(
    '/sphere/publishers/subscriptions',
    queryParameters: {
      'order': 'latest_posted_at',
      'offset': 0,
      'take': 100,
    },
  );

  return (response.data as List)
      .whereType<Map>()
      .map((raw) {
        final json = Map<String, dynamic>.from(raw);
        final subRaw = json['subscription'];
        final map = Map<String, dynamic>.from(
          subRaw is Map ? Map<String, dynamic>.from(subRaw) : json,
        );
        return SnPublisherSubscription.fromJson(map);
      })
      .toList();
}

class PublishersSubscriptionsLiveNotifier
    extends AsyncNotifier<List<PublisherSubscriptionLiveItem>> {
  @override
  Future<List<PublisherSubscriptionLiveItem>> build() async {
    final client = ref.read(solarNetworkClientProvider);
    return fetchPublisherSubscriptionsLive(client);
  }

  Future<void> refresh() async {
    state = await AsyncValue.guard(() async {
      final client = ref.read(solarNetworkClientProvider);
      return fetchPublisherSubscriptionsLive(client);
    });
  }

  /// Optimistic local clear of the new-content flag for one publisher.
  void optimisticallyMarkRead(String publisherName, {DateTime? lastReadAt}) {
    final current = state.value;
    if (current == null) return;
    final readAt = lastReadAt ?? DateTime.now().toUtc();
    state = AsyncData([
      for (final item in current)
        if (item.publisherName == publisherName)
          item.copyWith(hasNewContent: false, lastReadAt: readAt)
        else
          item,
    ]);
  }

  void optimisticallyMarkAllRead() {
    final current = state.value;
    if (current == null) return;
    final now = DateTime.now().toUtc();
    state = AsyncData([
      for (final item in current)
        item.copyWith(
          hasNewContent: false,
          lastReadAt: item.latestContentAt ?? now,
        ),
    ]);
  }

  Future<PublisherSubscriptionReadStatus?> markAsRead(
    String publisherName, {
    DateTime? lastReadAt,
  }) async {
    optimisticallyMarkRead(publisherName, lastReadAt: lastReadAt);
    try {
      final client = ref.read(solarNetworkClientProvider);
      final status = await markPublisherAsRead(
        client,
        publisherName,
        lastReadAt: lastReadAt,
      );
      final current = state.value;
      if (status != null && current != null) {
        state = AsyncData([
          for (final item in current)
            if (item.publisherName == publisherName)
              item.copyWith(
                hasNewContent: status.hasNewContent,
                lastReadAt: status.lastReadAt ?? lastReadAt,
                latestContentAt: status.latestContentAt ?? item.latestContentAt,
              )
            else
              item,
        ]);
      }
      return status;
    } catch (e) {
      // Re-fetch to restore accurate badges after a failed mutation.
      await refresh();
      rethrow;
    }
  }

  Future<int> markAllAsRead() async {
    optimisticallyMarkAllRead();
    try {
      final client = ref.read(solarNetworkClientProvider);
      final updated = await markAllPublishersAsRead(client);
      await refresh();
      return updated;
    } catch (e) {
      await refresh();
      rethrow;
    }
  }
}

final publishersSubscriptionsLiveProvider =
    AsyncNotifierProvider.autoDispose<
      PublishersSubscriptionsLiveNotifier,
      List<PublisherSubscriptionLiveItem>
    >(PublishersSubscriptionsLiveNotifier.new);

@riverpod
Future<List<SnCategorySubscription>> categoriesSubscriptions(Ref ref) async {
  final client = ref.read(solarNetworkClientProvider);
  final response = await client.dio.get('/sphere/categories/subscriptions');

  return (response.data as List)
      .map((json) => SnCategorySubscription.fromJson(json))
      .cast<SnCategorySubscription>()
      .toList();
}

@riverpod
Future<PublisherSubscriptionReadStatus?> publisherSubscriptionReadStatus(
  Ref ref,
  String publisherName,
) async {
  final client = ref.read(solarNetworkClientProvider);
  final response = await client.dio.get(
    '/sphere/publishers/$publisherName/subscription/read-status',
  );

  if (response.data is! Map) return null;
  return PublisherSubscriptionReadStatus.fromJson(
    Map<String, dynamic>.from(response.data as Map),
  );
}

/// Mark one subscription as read.
///
/// When [lastReadAt] is omitted the server uses the current instant.
/// Prefer passing [PublisherSubscriptionLiveItem.latestContentAt] so the
/// marker matches the content the user just acknowledged.
Future<PublisherSubscriptionReadStatus?> markPublisherAsRead(
  SolarNetworkClient client,
  String publisherName, {
  DateTime? lastReadAt,
}) async {
  final response = await client.dio.put(
    '/sphere/publishers/$publisherName/subscription/read-status',
    data: {
      if (lastReadAt != null)
        'last_read_at': lastReadAt.toUtc().toIso8601String(),
    },
  );

  if (response.data is! Map) return null;
  return PublisherSubscriptionReadStatus.fromJson(
    Map<String, dynamic>.from(response.data as Map),
  );
}

/// Mark every active subscription as read up to each publisher's latest content.
Future<int> markAllPublishersAsRead(SolarNetworkClient client) async {
  final response = await client.dio.put(
    '/sphere/publishers/subscriptions/read-status',
  );

  if (response.data is! Map) return 0;
  final count = response.data['updated_count'] ?? response.data['updatedCount'];
  if (count is int) return count;
  if (count is num) return count.toInt();
  return int.tryParse('$count') ?? 0;
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
    final isMarkingAll = useState(false);

    final publishersAsync = ref.watch(publishersSubscriptionsLiveProvider);
    final categoriesAsync = ref.watch(categoriesSubscriptionsProvider);

    void updateSelection() {
      onSelectedPublishersChanged(selectedPublishers.value);
      onSelectedCategoriesChanged(selectedCategories.value);
      onSelectedTagsChanged(selectedTags.value);
    }

    final unreadCount =
        publishersAsync.value?.where((item) => item.hasNewContent).length ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Icon(Symbols.subscriptions, size: 20),
            const Gap(12),
            Expanded(
              child: Text(
                'exploreFilterSubscriptions'.tr(),
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            if (unreadCount > 0)
              TextButton(
                onPressed: isMarkingAll.value
                    ? null
                    : () async {
                        isMarkingAll.value = true;
                        try {
                          await ref
                              .read(publishersSubscriptionsLiveProvider.notifier)
                              .markAllAsRead();
                        } catch (_) {
                          // ignore
                        } finally {
                          isMarkingAll.value = false;
                        }
                      },
                child: isMarkingAll.value
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text('markAllRead'.tr()),
              ),
          ],
        ).padding(horizontal: 16, top: 12),
        const Gap(12),

        // Publishers Section
        publishersAsync.when(
          data: (items) {
            if (items.isEmpty) {
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
                Row(
                  children: [
                    Text(
                      'publishers'.tr(),
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (unreadCount > 0) ...[
                      const Gap(8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          '$unreadCount',
                          style: const TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.w700,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ],
                ).padding(bottom: 8, horizontal: 16),
                ...items.map((item) {
                  final subscription = item.subscription;
                  final isSelected = selectedPublishers.value.contains(
                    subscription.publisher.name,
                  );
                  final publisher = subscription.publisher;

                  return CheckboxListTile(
                    controlAffinity: ListTileControlAffinity.trailing,
                    title: Row(
                      children: [
                        Expanded(child: Text(publisher.nick)),
                        if (item.hasNewContent)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                            ),
                          ),
                        if (item.isLive) ...[
                          const Gap(6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.redAccent.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(
                                  Symbols.fiber_manual_record,
                                  size: 9,
                                  color: Colors.redAccent,
                                ),
                                SizedBox(width: 3),
                                Text(
                                  'LIVE',
                                  style: TextStyle(
                                    color: Colors.redAccent,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                    value: isSelected,
                    onChanged: (value) async {
                      if (value == true) {
                        selectedPublishers.value = [
                          subscription.publisher.name,
                        ];
                        selectedCategories.value = [];
                        selectedTags.value = [];
                        try {
                          await ref
                              .read(publishersSubscriptionsLiveProvider.notifier)
                              .markAsRead(
                                subscription.publisher.name,
                                lastReadAt: item.latestContentAt,
                              );
                        } catch (_) {
                          // ignore
                        }
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
                    contentPadding: const EdgeInsets.only(left: 15, right: 16),
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
              child: Text('errorLoadingSubscription'.tr()),
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
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ).padding(bottom: 8, horizontal: 16),
                ...subscriptions.map((subscription) {
                  final category = subscription.category;
                  final tag = subscription.tag;
                  final slug = category?.slug ?? tag?.slug;
                  final displayTitle =
                      category?.categoryTranslationKey.tr() ??
                      tag?.name ??
                      slug ??
                      '';
                  final isCategorySelected = selectedCategories.value.contains(
                    slug,
                  );
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
                        selectedPublishers.value = [];
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
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  );
                }),
              ],
            );
          },
          loading: () => const SizedBox.shrink(),
          error: (error, stack) => const SizedBox.shrink(),
        ),
      ],
    );
  }
}
