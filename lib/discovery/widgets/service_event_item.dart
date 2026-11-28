import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:gap/gap.dart';
import 'package:island/core/network.dart';
import 'package:island/core/services/time.dart';
import 'package:island/core/theme.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

/// One exercpt from the fleet timeline event log, interleaved into the
/// explorable feed by Sphere (`type: "service.event"`). [data] carries
/// `{source, event_type, account_id, payload}`.
class ServiceEventItem extends ConsumerWidget {
  final Map<String, dynamic> data;
  final DateTime createdAt;

  const ServiceEventItem({
    super.key,
    required this.data,
    required this.createdAt,
  });

  static const _labels = <String, String>{
    'realm.created': 'timelineEventRealmCreated',
    'realm.joined': 'timelineEventRealmJoined',
    'work.reviewed': 'timelineEventWorkReviewed',
    'work.review_deleted': 'timelineEventWorkReviewDeleted',
    'work.status_updated': 'timelineEventWorkStatusUpdated',
  };

  static const _workStatuses = <String, String>{
    'plan_to_watch': 'workStatusPlanToWatch',
    'watching': 'workStatusWatching',
    'completed': 'workStatusCompleted',
    'on_hold': 'workStatusOnHold',
    'dropped': 'workStatusDropped',
  };

  IconData _icon(String eventType) => switch (eventType) {
    'realm.created' || 'realm.joined' => Symbols.group_add,
    'work.reviewed' || 'work.review_deleted' => Symbols.star,
    'work.status_updated' => Symbols.bolt,
    _ => Symbols.bolt,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final eventType = data['event_type'] as String? ?? '';
    final payload =
        (data['payload'] as Map?)?.cast<String, dynamic>() ?? const {};
    final labelKey = _labels[eventType];
    final label = labelKey != null
        ? labelKey.tr()
        : 'timelineEventGeneric'.tr();
    final statusKey = _workStatuses[payload['status'] as String? ?? ''];
    final statusLabel = statusKey?.tr();
    final account = ref.watch(_serviceEventAccountProvider(
      data['account_id'] as String? ?? '',
    ));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        spacing: 10,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _icon(eventType),
              size: 18,
              color: theme.colorScheme.primary,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  account.value?.nick ?? account.value?.name ?? '…',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const Gap(2),
                Row(
                  spacing: 6,
                  children: [
                    Flexible(
                      child: Text(
                        label,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (statusLabel != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(SolRadius.xs),
                        ),
                        child: Text(
                          statusLabel,
                          style: theme.textTheme.labelSmall,
                        ),
                      ),
                  ],
                ),
                const Gap(2),
                Text(
                  createdAt.toLocal().formatRelative(context),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Resolves the actor of a feed service event by account id.
final _serviceEventAccountProvider =
    FutureProvider.autoDispose.family<SnAccount?, String>((ref, accountId) async {
  if (accountId.isEmpty) return null;
  final client = ref.read(apiClientProvider);
  try {
    final response = await client.get('/stargate/accounts/$accountId');
    return SnAccount.fromJson(response.data as Map<String, dynamic>);
  } catch (_) {
    return null;
  }
});
