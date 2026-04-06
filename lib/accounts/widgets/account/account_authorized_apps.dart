import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/network.dart';
import 'package:island/core/services/time.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/shared/widgets/layouts/sheet_scaffold.dart';
import 'package:island/shared/widgets/response.dart';
import 'package:island/shared/widgets/extended_refresh_indicator.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'account_authorized_apps.g.dart';

@riverpod
Future<List<Map<String, dynamic>>> authorizedApps(Ref ref) async {
  final padlockApi = ref.watch(solarNetworkClientProvider).padlock;
  return padlockApi.getAuthorizedApps();
}

class _AuthorizedAppCard extends StatelessWidget {
  final Map<String, dynamic> app;
  final Function(String) deauthorize;

  const _AuthorizedAppCard({required this.app, required this.deauthorize});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final type = app['type'] as int? ?? 0;
    final lastUsedAt = app['last_used_at'] as String?;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                type == 0 ? Icons.security : Icons.connecting_airports,
                color: colorScheme.onPrimaryContainer,
              ),
            ),
            Gap(12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    app['app_name'] as String? ??
                        app['app_slug'] as String? ??
                        'unknownApp'.tr(),
                    style: Theme.of(context).textTheme.titleMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    lastUsedAt != null
                        ? 'lastActiveAt'.tr(args: [_formatDate(lastUsedAt)])
                        : 'neverUsed'.tr(),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.logout),
              tooltip: 'deauthorize'.tr(),
              onPressed: () => deauthorize(app['id'] as String),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String isoDate) {
    try {
      final dt = DateTime.parse(isoDate);
      return dt.toLocal().formatSystem();
    } catch (_) {
      return isoDate;
    }
  }
}

class AccountAuthorizedAppsSheet extends HookConsumerWidget {
  const AccountAuthorizedAppsSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final apps = ref.watch(authorizedAppsProvider);

    void deauthorizeApp(String appId) async {
      final confirm = await showConfirmAlert(
        'authorizedAppDeauthorizeHint'.tr(),
        'deauthorize'.tr(),
        isDanger: true,
      );
      if (!confirm || !context.mounted) return;
      try {
        final padlockApi = ref.read(solarNetworkClientProvider).padlock;
        await padlockApi.deauthorizeApp(appId);
        ref.invalidate(authorizedAppsProvider);
      } catch (err) {
        showErrorAlert(err);
      }
    }

    return SheetScaffold(
      titleText: 'authorizedApps'.tr(),
      child: apps.when(
        data: (data) => data.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.app_settings_alt,
                      size: 64,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    Gap(16),
                    Text(
                      'dataEmpty'.tr(),
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              )
            : ExtendedRefreshIndicator(
                onRefresh: () =>
                    Future.sync(() => ref.invalidate(authorizedAppsProvider)),
                child: ListView.builder(
                  padding: EdgeInsets.only(bottom: 16, top: 8),
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    final app = data[index];
                    return _AuthorizedAppCard(
                      app: app,
                      deauthorize: deauthorizeApp,
                    );
                  },
                ),
              ),
        error: (err, _) => ResponseErrorWidget(
          error: err,
          onRetry: () => ref.invalidate(authorizedAppsProvider),
        ),
        loading: () => ResponseLoadingWidget(),
      ),
    );
  }
}
