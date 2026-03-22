import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';
import 'package:island/accounts/widgets/account/activity_presence.dart';
import 'package:island/core/network.dart';
import 'package:island/core/services/time.dart';
import 'package:island/shared/widgets/pagination_list.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:gap/gap.dart';

class AccountTimelineList extends ConsumerWidget {
  final String uname;

  const AccountTimelineList({super.key, required this.uname});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PaginationList<SnAccountTimelineItem>(
      isSliver: true,
      isRefreshable: false,
      provider: accountTimelineProvider(uname),
      notifier: accountTimelineProvider(uname).notifier,
      spacing: 8,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      footerSkeletonChild: Container(
        height: 60,
        decoration: BoxDecoration(
          color: Theme.of(
            context,
          ).colorScheme.surfaceContainerHighest.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      itemBuilder: (context, idx, item) {
        return AccountTimelineItem(item: item);
      },
    );
  }
}

class AccountTimelineItem extends StatelessWidget {
  final SnAccountTimelineItem item;

  const AccountTimelineItem({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final createdAt = item.createdAt;

    switch (item.eventType) {
      case 0:
        final status = item.status!;
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            spacing: 12,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _getStatusColor(status).withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getStatusIcon(status),
                  size: 20,
                  color: _getStatusColor(status),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      status.label.isNotEmpty
                          ? status.label
                          : 'statusChange'.tr(),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
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
              if (status.isAutomated)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    spacing: 4,
                    children: [
                      Icon(
                        Symbols.smart_toy,
                        size: 14,
                        color: theme.colorScheme.onSecondaryContainer,
                      ),
                      Text(
                        'bot',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSecondaryContainer,
                        ),
                      ).tr(),
                    ],
                  ),
                ),
            ],
          ),
        );
      case 1:
        final activity = item.activity!;
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            spacing: 12,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _getActivityColor(activity.type).withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getActivityIcon(activity.type),
                  size: 20,
                  color: _getActivityColor(activity.type),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activity.title ?? 'unknown'.tr(),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (activity.subtitle != null) ...[
                      const Gap(2),
                      Text(
                        activity.subtitle!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.tertiaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  kPresenceActivityTypes[activity.type],
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onTertiaryContainer,
                  ),
                ).tr(),
              ),
            ],
          ),
        );
      default:
        return Text('unknown').tr();
    }
  }

  Color _getStatusColor(SnAccountStatus status) {
    switch (status.type) {
      case SnAccountStatusType.busy:
        return Colors.red;
      case SnAccountStatusType.doNotDisturb:
        return Colors.orange;
      case SnAccountStatusType.invisible:
        return Colors.grey;
      default:
        return Colors.green;
    }
  }

  IconData _getStatusIcon(SnAccountStatus status) {
    switch (status.type) {
      case SnAccountStatusType.busy:
        return Symbols.do_not_disturb_on;
      case SnAccountStatusType.doNotDisturb:
        return Symbols.mic_off;
      case SnAccountStatusType.invisible:
        return Symbols.visibility_off;
      default:
        return Symbols.circle;
    }
  }

  Color _getActivityColor(int type) {
    switch (type) {
      case 1:
        return Colors.purple;
      case 2:
        return Colors.green;
      case 3:
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  IconData _getActivityIcon(int type) {
    switch (type) {
      case 1:
        return Symbols.play_arrow;
      case 2:
        return Symbols.music_note;
      case 3:
        return Symbols.fitness_center;
      default:
        return Symbols.category;
    }
  }
}

final accountTimelineProvider = AsyncNotifierProvider.autoDispose
    .family<
      AccountTimelineNotifier,
      PaginationState<SnAccountTimelineItem>,
      String
    >(AccountTimelineNotifier.new);

class AccountTimelineNotifier
    extends AsyncNotifier<PaginationState<SnAccountTimelineItem>>
    with AsyncPaginationController<SnAccountTimelineItem> {
  static const int pageSize = 20;

  final String arg;
  AccountTimelineNotifier(this.arg);

  @override
  FutureOr<PaginationState<SnAccountTimelineItem>> build() async {
    final items = await fetch();
    return PaginationState(
      items: items,
      isLoading: false,
      isReloading: false,
      totalCount: totalCount,
      hasMore: hasMore,
      cursor: cursor,
    );
  }

  @override
  Future<List<SnAccountTimelineItem>> fetch() async {
    final client = ref.read(apiClientProvider);

    final queryParams = {
      'offset': fetchedCount.toString(),
      'take': pageSize.toString(),
    };

    final response = await client.get(
      '/passport/accounts/$arg/timeline',
      queryParameters: queryParams,
    );

    totalCount = int.parse(response.headers.value('X-Total') ?? '0');

    return (response.data as List<dynamic>)
        .map((e) => SnAccountTimelineItem.fromJson(e))
        .cast<SnAccountTimelineItem>()
        .toList();
  }
}
