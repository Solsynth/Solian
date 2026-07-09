import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/widgets/account/board.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:island/shared/widgets/layouts/sheet_scaffold.dart';
import 'package:island/shared/widgets/response.dart';
import 'package:material_symbols_icons/symbols.dart';

class AddCustomWidgetSheet extends HookConsumerWidget {
  final String accountId;

  const AddCustomWidgetSheet({super.key, required this.accountId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appsAsync = ref.watch(boardWidgetAppsProvider);
    final theme = Theme.of(context);

    return SheetScaffold(
      titleText: 'boardAddCustomWidget'.tr(),
      heightFactor: 0.85,
      child: appsAsync.when(
        data: (apps) {
          if (apps.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Symbols.extension_off, size: 48, color: theme.colorScheme.onSurfaceVariant),
                  const Gap(12),
                  Text('boardNoCustomWidgetApps'.tr(), style: theme.textTheme.bodyLarge),
                ],
              ),
            );
          }

          return _AppSelectionList(
            apps: apps,
            accountId: accountId,
          );
        },
        error: (err, _) => ResponseErrorWidget(
          error: err,
          onRetry: () => ref.invalidate(boardWidgetAppsProvider),
        ),
        loading: () => const ResponseLoadingWidget(),
      ),
    );
  }
}

class _AppSelectionList extends StatelessWidget {
  final List<BoardWidgetApp> apps;
  final String accountId;

  const _AppSelectionList({required this.apps, required this.accountId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: apps.length,
      separatorBuilder: (_, _) => const Gap(8),
      itemBuilder: (context, index) {
        final app = apps[index];
        final enabledWidgets = app.boardWidgets.where((w) => w.isEnabled).toList();

        return Card(
          margin: EdgeInsets.zero,
          child: InkWell(
            onTap: enabledWidgets.isEmpty
                ? null
                : () => _showWidgetPicker(context, app, enabledWidgets, accountId),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  app.pictureId != null
                      ? ProfilePictureWidget(
                          fileId: app.pictureId,
                          radius: 24,
                          borderRadius: 14,
                        )
                      : Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(Symbols.extension, color: theme.colorScheme.onPrimaryContainer),
                        ),
                  const Gap(12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(app.name, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                        if (app.description != null && app.description!.isNotEmpty) ...[
                          const Gap(2),
                          Text(app.description!, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                        ],
                        const Gap(4),
                        Text(
                          'boardWidgetCount'.tr(args: ['${enabledWidgets.length}']),
                          style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.primary),
                        ),
                      ],
                    ),
                  ),
                  Icon(Symbols.chevron_right, color: theme.colorScheme.onSurfaceVariant),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showWidgetPicker(
    BuildContext context,
    BoardWidgetApp app,
    List<BoardWidgetDefinition> widgets,
    String accountId,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => _WidgetPickerSheet(
        app: app,
        widgets: widgets,
        accountId: accountId,
      ),
    );
  }
}

class _WidgetPickerSheet extends HookConsumerWidget {
  final BoardWidgetApp app;
  final List<BoardWidgetDefinition> widgets;
  final String accountId;

  const _WidgetPickerSheet({
    required this.app,
    required this.widgets,
    required this.accountId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return SheetScaffold(
      titleText: app.name,
      heightFactor: 0.6,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: widgets.length,
        separatorBuilder: (_, _) => const Gap(8),
        itemBuilder: (context, index) {
          final widget = widgets[index];
          final requiredFields = widget.requiredFields;

          return Card(
            margin: EdgeInsets.zero,
            child: InkWell(
              onTap: () {
                Navigator.pop(context);
                _showPayloadForm(context, app, widget, accountId);
              },
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
                      child: Icon(_rendererIcon(widget.rendererType), color: theme.colorScheme.onSecondaryContainer),
                    ),
                    const Gap(12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.key, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                          const Gap(2),
                          Text(
                            '${widget.fieldTypes.length} ${'boardFields'.tr()}${requiredFields.isNotEmpty ? ' · ${requiredFields.length} ${'required'.tr()}' : ''}',
                            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                          ),
                          if (!widget.allowMultiple)
                            Text(
                              'boardWidgetSingleton'.tr(),
                              style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.tertiary),
                            ),
                        ],
                      ),
                    ),
                    Icon(Symbols.chevron_right, color: theme.colorScheme.onSurfaceVariant),
                  ],
                ),
              ),
            ),
          );
        },
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

  void _showPayloadForm(
    BuildContext context,
    BoardWidgetApp app,
    BoardWidgetDefinition widget,
    String accountId,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => _PayloadFormSheet(
        app: app,
        widget: widget,
        accountId: accountId,
      ),
    ).then((result) {
      if (result != null && context.mounted) {
        Navigator.pop(context, result);
      }
    });
  }
}

class _PayloadFormSheet extends HookConsumerWidget {
  final BoardWidgetApp app;
  final BoardWidgetDefinition widget;
  final String accountId;

  const _PayloadFormSheet({
    required this.app,
    required this.widget,
    required this.accountId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final controllers = <String, TextEditingController>{};
    final boolValues = <String, bool>{};

    for (final field in widget.fieldTypes) {
      controllers[field.name] = TextEditingController();
      if (field.type == 'boolean') {
        boolValues[field.name] = false;
      }
    }

    void submit() {
      final payload = <String, dynamic>{};
      for (final field in widget.fieldTypes) {
        final rawValue = field.type == 'boolean'
            ? boolValues[field.name] ?? false
            : controllers[field.name]!.text.trim();

        if (field.required) {
          final isEmpty = rawValue is String ? rawValue.isEmpty : rawValue == false;
          if (isEmpty) return;
        }

        if (rawValue is String && rawValue.isEmpty) continue;

        payload[field.name] = {
          'value': rawValue,
          'label': field.label.isNotEmpty ? field.label : field.name,
          if (field.format.isNotEmpty) 'format': field.format,
        };
      }

      final item = AccountBoardItem(
        order: 0,
        kind: BoardWidgetKind.customApp,
        customAppId: app.id,
        customAppWidgetKey: widget.key,
        isEnabled: true,
        payload: payload,
      );

      Navigator.pop(context, item);
    }

    return SheetScaffold(
      titleText: widget.key,
      heightFactor: 0.7,
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (widget.fieldTypes.isNotEmpty) ...[
                  Text('boardPayloadFields'.tr(), style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                  const Gap(12),
                  ...widget.fieldTypes.map((field) => _buildField(
                    context, theme, field, controllers, boolValues,
                  )),
                ] else
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: Text('boardNoFields'.tr(), style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: FilledButton.icon(
              onPressed: submit,
              icon: const Icon(Symbols.add, size: 18),
              label: Text('boardAddWidget'.tr()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField(
    BuildContext context,
    ThemeData theme,
    BoardWidgetField field,
    Map<String, TextEditingController> controllers,
    Map<String, bool> boolValues,
  ) {
    final label = '${field.label.isNotEmpty ? field.label : field.name}${field.required ? ' *' : ''}';

    if (field.type == 'boolean') {
      return StatefulBuilder(
        builder: (context, setState) {
          return SwitchListTile(
            title: Text(label),
            subtitle: field.format.isNotEmpty ? Text(field.format).tr() : null,
            value: boolValues[field.name] ?? false,
            onChanged: (v) => setState(() => boolValues[field.name] = v),
          );
        },
      );
    }

    if (field.type == 'number') {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: TextField(
          controller: controllers[field.name],
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controllers[field.name],
        decoration: InputDecoration(
          labelText: label,
          hintText: field.format.isNotEmpty ? field.format : null,
          border: const OutlineInputBorder(),
        ),
        maxLines: field.type == 'text' ? 3 : 1,
      ),
    );
  }
}
