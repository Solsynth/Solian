import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
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
    with
        AsyncPaginationController<SnActionLog>,
        AsyncPaginationFilter<String?, SnActionLog> {
  static const int pageSize = 20;

  @override
  String? currentFilter;

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
    final client = ref.read(solarNetworkClientProvider);

    final result = await client.padlock.getActionLogs(
      offset: fetchedCount,
      take: pageSize,
      action: currentFilter,
    );

    totalCount = result.totalCount;
    return result.items;
  }
}

@RoutePage()
class ActionLogsScreen extends HookConsumerWidget {
  const ActionLogsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final searchController = useTextEditingController();
    final focusNode = useFocusNode();
    final debounceTimer = useState<Timer?>(null);
    final currentQuery = useState<String?>(null);

    final notifier = ref.watch(actionLogsNotifierProvider.notifier);

    // Clean up timer on dispose
    useEffect(() {
      return () {
        debounceTimer.value?.cancel();
      };
    }, []);

    // Clear search when query is cleared externally
    useEffect(() {
      if (currentQuery.value == null || currentQuery.value!.isEmpty) {
        searchController.clear();
      }
      return null;
    }, [currentQuery.value]);

    return AppScaffold(
      appBar: AppBar(
        title: Text('actionLogs').tr(),
        centerTitle: true,
        scrolledUnderElevation: 4,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: SearchBar(
              elevation: WidgetStateProperty.all(4),
              controller: searchController,
              focusNode: focusNode,
              hintText: 'searchByAction'.tr(),
              leading: const Icon(Symbols.search),
              padding: WidgetStateProperty.all(
                const EdgeInsets.symmetric(horizontal: 24),
              ),
              onTapOutside: (_) =>
                  FocusManager.instance.primaryFocus?.unfocus(),
              trailing: [
                if (currentQuery.value != null &&
                    currentQuery.value!.isNotEmpty)
                  IconButton(
                    icon: const Icon(Symbols.close),
                    onPressed: () {
                      currentQuery.value = null;
                      notifier.applyFilter(null);
                      searchController.clear();
                      focusNode.unfocus();
                    },
                  ),
              ],
              onChanged: (value) {
                // Debounce search to avoid excessive API calls
                debounceTimer.value?.cancel();
                debounceTimer.value = Timer(
                  const Duration(milliseconds: 500),
                  () {
                    currentQuery.value = value;
                    notifier.applyFilter(value.isEmpty ? null : value);
                  },
                );
              },
              onSubmitted: (value) {
                debounceTimer.value?.cancel();
                currentQuery.value = value;
                notifier.applyFilter(value.isEmpty ? null : value);
                focusNode.unfocus();
              },
            ),
          ),
          Expanded(
            child: PaginationList(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              provider: actionLogsNotifierProvider,
              notifier: actionLogsNotifierProvider.notifier,
              itemBuilder: (context, idx, log) {
                final location = log.location;
                final locationText = [
                  if (location?.city != null) location!.city,
                  if (location?.country != null) location!.country,
                ].join(', ');

                final actionColor = _getActionColor(log.action, colorScheme);
                final actionContainerColor = actionColor.withOpacity(0.12);

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 0,
                  color: colorScheme.surfaceContainerLow,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Action Icon Container - Material 3 tonal style
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: actionContainerColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            _getActionIcon(log.action),
                            color: actionColor,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Content
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Action Title
                              Text(
                                _formatAction(log.action),
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: colorScheme.onSurface,
                                    ),
                              ),
                              // Location
                              if (locationText.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Symbols.location_on,
                                        size: 14,
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          locationText,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                color: colorScheme
                                                    .onSurfaceVariant,
                                              ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              // Time
                              Row(
                                children: [
                                  Icon(
                                    Symbols.schedule,
                                    size: 14,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    log.createdAt.toLocal().formatSystem(),
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(
                                          color: colorScheme.onSurfaceVariant,
                                        ),
                                  ),
                                ],
                              ),
                              // IP Address
                              if (log.ipAddress?.isNotEmpty ?? false)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Symbols.dns,
                                        size: 14,
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        log.ipAddress!,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color:
                                                  colorScheme.onSurfaceVariant,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
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

Color _getActionColor(String action, ColorScheme colorScheme) {
  final actionLower = action.toLowerCase();
  if (actionLower.contains('login')) return colorScheme.primary;
  if (actionLower.contains('logout')) return colorScheme.tertiary;
  if (actionLower.contains('register')) return colorScheme.secondary;
  if (actionLower.contains('delete')) return colorScheme.error;
  if (actionLower.contains('error') || actionLower.contains('fail')) {
    return colorScheme.error;
  }
  if (actionLower.contains('password')) return colorScheme.tertiaryContainer;
  if (actionLower.contains('oauth') || actionLower.contains('connect')) {
    return colorScheme.primaryContainer;
  }
  if (actionLower.contains('verify') || actionLower.contains('enable')) {
    return colorScheme.secondaryContainer;
  }
  return colorScheme.outline;
}

String _formatAction(String action) {
  // Return original action name without formatting
  return action;
}
