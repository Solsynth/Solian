import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:island/accounts/models/authorized_app.dart';
import 'package:island/accounts/widgets/account/account_authorized_apps.dart';
import 'package:island/accounts/widgets/account/board.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/shared/widgets/layouts/sheet_scaffold.dart';
import 'package:island/shared/widgets/response.dart';
import 'package:material_symbols_icons/symbols.dart';

class AddCustomWidgetSheet extends HookConsumerWidget {
  final String accountId;

  const AddCustomWidgetSheet({super.key, required this.accountId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authorizedAppsAsync = ref.watch(authorizedAppsProvider);
    final theme = Theme.of(context);
    final selectedApp = useState<AuthorizedApp?>(null);

    return SheetScaffold(
      titleText: 'boardAddCustomWidget'.tr(),
      heightFactor: 0.85,
      child: authorizedAppsAsync.when(
        data: (apps) {
          final appsWithSlug = apps
              .where((a) => a.appSlug != null && a.appSlug!.isNotEmpty)
              .toList();
          if (appsWithSlug.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Symbols.extension_off,
                    size: 48,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const Gap(12),
                  Text(
                    'boardNoCustomWidgetApps'.tr(),
                    style: theme.textTheme.bodyLarge,
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: DropdownButtonFormField<AuthorizedApp>(
                  value: selectedApp.value,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: 'boardSelectApp'.tr(),
                  ),
                  items: appsWithSlug
                      .map(
                        (app) => DropdownMenuItem(
                          value: app,
                          child: Text(
                            app.appName ?? app.appSlug ?? '',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (app) {
                    selectedApp.value = app;
                  },
                ),
              ),
              if (selectedApp.value != null)
                Expanded(
                  child: _WidgetList(
                    slug: selectedApp.value!.appSlug!,
                    accountId: accountId,
                  ),
                ),
            ],
          );
        },
        error: (err, _) => ResponseErrorWidget(
          error: err,
          onRetry: () => ref.invalidate(authorizedAppsProvider),
        ),
        loading: () => const ResponseLoadingWidget(),
      ),
    );
  }
}

class _WidgetList extends HookConsumerWidget {
  final String slug;
  final String accountId;

  const _WidgetList({required this.slug, required this.accountId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final boardAppAsync = ref.watch(boardWidgetByAppSlugProvider(slug));

    return boardAppAsync.when(
      data: (boardApp) {
        if (boardApp == null) {
          return Center(
            child: Text(
              'boardAppNoWidgets'.tr(),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          );
        }
        final enabledWidgets =
            boardApp.boardWidgets.where((w) => w.isEnabled).toList();
        if (enabledWidgets.isEmpty) {
          return Center(
            child: Text(
              'boardAppNoWidgets'.tr(),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'boardWidgetCount'.tr(args: ['${enabledWidgets.length}']),
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Gap(8),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: enabledWidgets.length,
                separatorBuilder: (_, _) => const Gap(8),
                itemBuilder: (context, index) {
                  final widget = enabledWidgets[index];
                  final requiredFields = widget.requiredFields;

                  return Card(
                    margin: EdgeInsets.zero,
                    child: InkWell(
                      onTap: () => _confirmAddWidget(
                        context,
                        boardApp,
                        widget,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: theme.colorScheme.secondaryContainer,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                _rendererIcon(widget.rendererType),
                                color:
                                    theme.colorScheme.onSecondaryContainer,
                              ),
                            ),
                            const Gap(12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.key,
                                    style: theme.textTheme.titleSmall
                                        ?.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                  const Gap(2),
                                  Text(
                                    widget.fieldTypes.isNotEmpty
                                        ? '${widget.fieldTypes.length} ${'boardFields'.tr()}${requiredFields.isNotEmpty ? ' · ${requiredFields.length} ${'required'.tr()}' : ''}'
                                        : 'boardWidgetNotConfigured'.tr(),
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color:
                                          theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  if (!widget.allowMultiple)
                                    Text(
                                      'boardWidgetSingleton'.tr(),
                                      style: theme.textTheme.labelSmall
                                          ?.copyWith(
                                            color: theme.colorScheme.tertiary,
                                          ),
                                    ),
                                ],
                              ),
                            ),
                            Icon(
                              Symbols.chevron_right,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(
        child: Text(
          err.toString(),
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.error,
          ),
        ),
      ),
    );
  }

  IconData _rendererIcon(String type) {
    switch (type) {
      case 'hero':
        return Symbols.image;
      case 'data':
        return Symbols.monitoring;
      case 'list':
        return Symbols.view_list;
      default:
        return Symbols.widgets;
    }
  }

  void _confirmAddWidget(
    BuildContext context,
    BoardWidgetApp app,
    BoardWidgetDefinition widget,
  ) async {
    final confirmed = await showConfirmAlert(
      'boardAddWidgetConfirm'.tr(args: [widget.key, app.name]),
      'boardAddWidget'.tr(),
    );
    if (!confirmed || !context.mounted) return;

    final item = AccountBoardItem(
      order: 0,
      kind: BoardWidgetKind.customApp,
      customAppId: app.id,
      customAppWidgetKey: widget.key,
      isEnabled: true,
      payload: {},
    );

    Navigator.pop(context, item);
  }
}
