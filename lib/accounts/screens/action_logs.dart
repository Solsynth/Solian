import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/network.dart';
import 'package:island/core/services/time.dart';
import 'package:island/shared/widgets/app_scaffold.dart';
import 'package:island/shared/widgets/pagination_list.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

final actionLogsNotifierProvider = AsyncNotifierProvider.autoDispose(
  ActionLogsNotifier.new,
);

class ActionLogsNotifier extends AsyncNotifier<PaginationState<SnActionLog>>
    with AsyncPaginationController<SnActionLog> {
  static const int pageSize = 20;

  @override
  FutureOr<PaginationState<SnActionLog>> build() async {
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
  Future<List<SnActionLog>> fetch() async {
    final client = ref.read(apiClientProvider);

    final queryParams = {
      'offset': fetchedCount.toString(),
      'take': pageSize.toString(),
    };

    final response = await client.get(
      '/padlock/actions',
      queryParameters: queryParams,
    );

    totalCount = int.parse(response.headers.value('X-Total') ?? '0');

    final records = response.data
        .map<SnActionLog>((json) => SnActionLog.fromJson(json))
        .toList();

    return records;
  }
}

@RoutePage()
class ActionLogsScreen extends ConsumerWidget {
  const ActionLogsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppScaffold(
      appBar: AppBar(title: Text('actionLogs').tr()),
      body: PaginationList(
        padding: EdgeInsets.zero,
        provider: actionLogsNotifierProvider,
        notifier: actionLogsNotifierProvider.notifier,
        itemBuilder: (context, idx, log) {
          final location = log.location;
          final locationText = [
            if (location?.city != null) location!.city,
            if (location?.country != null) location!.country,
          ].join(', ');

          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _getActionColor(log.action).withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getActionIcon(log.action),
                color: _getActionColor(log.action),
                size: 20,
              ),
            ),
            title: Text(
              _formatAction(log.action),
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (locationText.isNotEmpty)
                  Text(
                    locationText,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                Row(
                  spacing: 4,
                  children: [
                    Icon(
                      Symbols.schedule,
                      size: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    Text(
                      log.createdAt.toLocal().formatSystem(),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                Row(
                  spacing: 4,
                  children: [
                    Icon(
                      Symbols.dns,
                      size: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    Text(
                      log.ipAddress,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            isThreeLine: true,
          );
        },
      ),
    );
  }
}

IconData _getActionIcon(String action) {
  final actionLower = action.toLowerCase();
  if (actionLower.contains('login')) return Icons.login;
  if (actionLower.contains('logout')) return Icons.logout;
  if (actionLower.contains('register')) return Icons.person_add;
  if (actionLower.contains('password')) return Icons.password;
  if (actionLower.contains('email')) return Icons.email;
  if (actionLower.contains('sms')) return Icons.sms;
  if (actionLower.contains('totp') || actionLower.contains('auth')) {
    return Icons.security;
  }
  if (actionLower.contains('delete')) return Icons.delete;
  if (actionLower.contains('update') || actionLower.contains('edit')) {
    return Icons.edit;
  }
  if (actionLower.contains('create')) return Icons.add_circle;
  if (actionLower.contains('device')) return Icons.phone_android;
  if (actionLower.contains('session')) return Icons.devices;
  if (actionLower.contains('oauth') || actionLower.contains('connect')) {
    return Icons.link;
  }
  if (actionLower.contains('revoke')) return Icons.remove_circle;
  if (actionLower.contains('verify')) return Icons.verified;
  if (actionLower.contains('enable')) return Icons.lock_open;
  if (actionLower.contains('disable')) return Icons.lock;
  return Icons.history;
}

Color _getActionColor(String action) {
  final actionLower = action.toLowerCase();
  if (actionLower.contains('login')) return Colors.green;
  if (actionLower.contains('logout')) return Colors.orange;
  if (actionLower.contains('register')) return Colors.blue;
  if (actionLower.contains('delete')) return Colors.red;
  if (actionLower.contains('error') || actionLower.contains('fail')) {
    return Colors.red;
  }
  if (actionLower.contains('password')) return Colors.amber;
  if (actionLower.contains('oauth') || actionLower.contains('connect')) {
    return Colors.purple;
  }
  if (actionLower.contains('verify') || actionLower.contains('enable')) {
    return Colors.teal;
  }
  return Colors.grey;
}

String _formatAction(String action) {
  return action
      .replaceAll('.', ' ')
      .replaceAll('_', ' ')
      .split(' ')
      .map(
        (word) => word.isNotEmpty
            ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}'
            : '',
      )
      .join(' ');
}
