import 'dart:convert';
import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/plugins/models/plugin_install_preview.dart';
import 'package:island/plugins/screens/plugin_marketplace_tab.dart';
import 'package:island/plugins/widgets/plugin_install_preview_sheet.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/shared/widgets/layouts/sheet_scaffold.dart';
import 'package:island_plugin_foundation/island_plugin_foundation.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:open_file/open_file.dart';
import 'package:path/path.dart' as p;

bool get _isDesktopPluginHost =>
    !kIsWeb && (Platform.isMacOS || Platform.isWindows || Platform.isLinux);

// ---------------------------------------------------------------------------
// Standalone route screen (thin wrapper)
// ---------------------------------------------------------------------------

@RoutePage()
class PluginManagerScreen extends HookConsumerWidget {
  const PluginManagerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text('plugins'.tr())),
      body: const PluginManagerContent(),
    );
  }
}

// ---------------------------------------------------------------------------
// Embeddable content widget
// ---------------------------------------------------------------------------

class PluginManagerContent extends HookConsumerWidget {
  const PluginManagerContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = useMemoized(() => PluginController.instance);
    useListenable(controller);

    return DefaultTabController(
      length: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TabBar(
            tabs: [
              Tab(text: 'pluginInstalledTab'.tr()),
              Tab(text: 'marketplace'.tr()),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _InstalledPluginsTab(controller: controller),
                const PluginMarketplaceTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Installed plugins tab
// ---------------------------------------------------------------------------

class _InstalledPluginsTab extends StatelessWidget {
  final PluginController controller;

  const _InstalledPluginsTab({required this.controller});

  @override
  Widget build(BuildContext context) {
    final plugins = controller.plugins;

    if (plugins.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Symbols.extension,
              size: 48,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 12),
            Text(
              'pluginsEmptyTitle'.tr(),
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'pluginsEmptyHint'.tr(),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                FilledButton.tonalIcon(
                  onPressed: () => _openEditor(context, controller),
                  icon: const Icon(Symbols.add, size: 18),
                  label: Text('newPlugin'.tr()),
                ),
                OutlinedButton.icon(
                  onPressed: () => _installFromFolder(context, controller),
                  icon: const Icon(Symbols.folder_open, size: 18),
                  label: Text('fromFolder'.tr()),
                ),
                if (_isDesktopPluginHost)
                  OutlinedButton.icon(
                    onPressed: () => _openPluginsFolder(context, controller),
                    icon: const Icon(Symbols.folder_copy, size: 18),
                    label: Text('openPluginsFolder'.tr()),
                  ),
              ],
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 16, 4),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'pluginsCount'.plural(plugins.length),
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              IconButton(
                onPressed: () async {
                  await controller.reload();
                },
                icon: const Icon(Symbols.refresh, size: 20),
                tooltip: 'reloadPlugins'.tr(),
                visualDensity: VisualDensity.compact,
              ),
              if (_isDesktopPluginHost)
                IconButton(
                  onPressed: () => _openPluginsFolder(context, controller),
                  icon: const Icon(Symbols.folder_copy, size: 20),
                  tooltip: 'openPluginsFolder'.tr(),
                  visualDensity: VisualDensity.compact,
                ),
              IconButton(
                onPressed: () => _installFromFolder(context, controller),
                icon: const Icon(Symbols.folder_open, size: 20),
                tooltip: 'installFromFolder'.tr(),
                visualDensity: VisualDensity.compact,
              ),
              FilledButton.tonalIcon(
                onPressed: () => _openEditor(context, controller),
                icon: const Icon(Symbols.add, size: 18),
                label: Text('new'.tr()),
                style: FilledButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                ),
              ),
            ],
          ),
        ),
        // List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 24),
            itemCount: plugins.length,
            itemBuilder: (context, index) {
              final entry = plugins.entries.elementAt(index);
              return _PluginTile(
                key: ValueKey(entry.key),
                instance: entry.value,
                onToggle: (enabled) async {
                  if (enabled) {
                    await controller.enablePlugin(entry.key);
                    await controller.loadPlugin(entry.key);
                  } else {
                    controller.disablePlugin(entry.key);
                  }
                },
                onUninstall: () async {
                  final confirm = await showConfirmAlert(
                    'pluginUninstallConfirm'.tr(
                      namedArgs: {'name': entry.value.manifest.name},
                    ),
                    'uninstallPlugin'.tr(),
                    icon: Symbols.delete_forever,
                    isDanger: true,
                  );
                  if (confirm) {
                    await controller.uninstallPlugin(entry.key);
                  }
                },
              );
            },
          ),
        ),
      ],
    );
  }

  // -- Editor sheet ----------------------------------------------------------

  void _openEditor(BuildContext context, PluginController controller) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _PluginEditorSheet(controller: controller),
    );
  }

  // -- Open plugins directory (desktop) --------------------------------------

  Future<void> _openPluginsFolder(
    BuildContext context,
    PluginController controller,
  ) async {
    if (!_isDesktopPluginHost) return;
    try {
      final dirPath = await controller.resolvePluginsDirectoryPath();
      final result = await OpenFile.open(dirPath);
      if (result.type != ResultType.done && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'openPluginsFolderFailed'.tr(
                namedArgs: {'path': dirPath},
              ),
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        showErrorAlert(e);
      }
    }
  }

  // -- Install from folder (preview → copy into app plugins dir) -------------

  Future<void> _installFromFolder(
    BuildContext context,
    PluginController controller,
  ) async {
    final result = await FilePicker.getDirectoryPath(
      dialogTitle: 'selectPluginFolder'.tr(),
    );
    if (result == null) return;

    final manifest = await _readManifest(result);
    if (!context.mounted) return;
    if (manifest == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('invalidPluginFolder'.tr())),
      );
      return;
    }

    final preview = PluginInstallPreview.fromManifestWithController(
      manifest,
      controller,
      sourceHint: result,
    );
    final confirmed = await showPluginInstallPreviewSheet(
      context,
      preview: preview,
    );
    if (!confirmed || !context.mounted) return;

    // Copy into `{appSupport}/plugins/{id}/` (override on upgrade / ack'd
    // conflict), then enable + load.
    final installed = await controller.installFromFolder(result);
    if (installed && controller.plugins.containsKey(manifest.id)) {
      await controller.enablePlugin(manifest.id);
      await controller.loadPlugin(manifest.id);
    }

    if (context.mounted) {
      final message = !installed
          ? 'invalidPluginFolder'.tr()
          : switch (preview.conflict) {
              PluginInstallConflict.upgrade => 'pluginMarketplaceUpdated'.tr(
                namedArgs: {
                  'name': manifest.name,
                  'version': manifest.version,
                },
              ),
              PluginInstallConflict.sameVersion ||
              PluginInstallConflict.downgrade ||
              PluginInstallConflict.unknown =>
                'pluginInstallReplaced'.tr(
                  namedArgs: {'name': manifest.name},
                ),
              PluginInstallConflict.none => 'pluginInstalled'.tr(),
            };
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  Future<PluginManifest?> _readManifest(String folderPath) async {
    try {
      final file = File(p.join(folderPath, 'manifest.json'));
      if (!await file.exists()) return null;
      final json = jsonDecode(await file.readAsString());
      if (json is! Map) return null;
      return PluginManifest.fromJson(Map<String, dynamic>.from(json));
    } catch (_) {
      return null;
    }
  }
}

// ---------------------------------------------------------------------------
// Plugin tile
// ---------------------------------------------------------------------------

class _PluginTile extends StatelessWidget {
  final PluginInstance instance;
  final ValueChanged<bool> onToggle;
  final VoidCallback onUninstall;

  const _PluginTile({
    super.key,
    required this.instance,
    required this.onToggle,
    required this.onUninstall,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final manifest = instance.manifest;
    final isActive = instance.state == PluginState.active;
    final isError = instance.state == PluginState.error;
    final isSafeguarded =
        instance.state == PluginState.disabled && instance.lastError != null;

    final (icon, iconBg, iconFg) = switch (instance.state) {
      PluginState.active => (
        Symbols.check_circle,
        cs.primaryContainer,
        cs.onPrimaryContainer,
      ),
      PluginState.error => (
        Symbols.error,
        cs.errorContainer,
        cs.onErrorContainer,
      ),
      PluginState.disabled when isSafeguarded => (
        Symbols.warning,
        cs.errorContainer,
        cs.onErrorContainer,
      ),
      PluginState.disabled => (
        Symbols.pause_circle,
        cs.surfaceContainerHighest,
        cs.onSurfaceVariant,
      ),
      _ => (Symbols.extension, cs.surfaceContainerHighest, cs.onSurfaceVariant),
    };

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 0,
        color: cs.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: cs.outlineVariant.withOpacity(0.4)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              // Icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Icon(icon, size: 20, color: iconFg),
              ),
              const SizedBox(width: 12),

              // Text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      manifest.name,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      manifest.description.isNotEmpty
                          ? manifest.description
                          : manifest.id,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if ((isError || isSafeguarded) &&
                        instance.lastError != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        instance.lastError!,
                        style: Theme.of(
                          context,
                        ).textTheme.labelSmall?.copyWith(color: cs.error),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (manifest.permissions.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 4,
                        runSpacing: 2,
                        children: manifest.permissions
                            .map(
                              (p) => Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 1,
                                ),
                                decoration: BoxDecoration(
                                  color: cs.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  p.name,
                                  style: Theme.of(context).textTheme.labelSmall
                                      ?.copyWith(
                                        fontSize: 10,
                                        color: cs.onSurfaceVariant,
                                      ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ],
                ),
              ),

              // Switch + menu
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Switch(value: isActive, onChanged: onToggle),
                  PopupMenuButton<String>(
                    icon: Icon(
                      Symbols.more_vert,
                      size: 18,
                      color: cs.onSurfaceVariant,
                    ),
                    onSelected: (v) {
                      if (v == 'uninstall') onUninstall();
                    },
                    itemBuilder: (_) => [
                      PopupMenuItem(
                        value: 'uninstall',
                        child: Text('uninstall'.tr()),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Plugin editor sheet
// ---------------------------------------------------------------------------

class _PluginEditorSheet extends HookConsumerWidget {
  final PluginController controller;

  const _PluginEditorSheet({required this.controller});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final codeController = useTextEditingController();
    final nameController = useTextEditingController(text: 'myPlugin'.tr());
    final output = useState<String?>(null);
    final isError = useState(false);
    final isRunning = useState(false);

    return SheetScaffold(
      titleText: 'newPlugin'.tr(),
      actions: [
        FilledButton.icon(
          onPressed: isRunning.value
              ? null
              : () async {
                  isRunning.value = true;
                  output.value = null;
                  isError.value = false;

                  try {
                    await controller.initialize();
                    final instance = controller.installInlinePlugin(
                      name: nameController.text,
                      source: codeController.text,
                      permissions: PluginPermission.values,
                    );

                    if (instance.state == PluginState.active) {
                      output.value = 'pluginLoadedSuccessfully'.tr();
                      isError.value = false;
                    } else {
                      output.value = instance.lastError ?? 'unknownError'.tr();
                      isError.value = true;
                    }
                  } catch (e) {
                    output.value = e.toString();
                    isError.value = true;
                  } finally {
                    isRunning.value = false;
                  }
                },
          icon: const Icon(Symbols.play_arrow, size: 18),
          label: Text('run'.tr()),
          style: FilledButton.styleFrom(
            visualDensity: VisualDensity.compact,
            padding: const EdgeInsets.symmetric(horizontal: 14),
          ),
        ),
      ],
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 12,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Name field
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'pluginName'.tr(),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Code editor
            Expanded(
              child: TextField(
                controller: codeController,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
                decoration: InputDecoration(
                  labelText: 'JavaScript',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignLabelWithHint: true,
                  contentPadding: const EdgeInsets.all(12),
                  hintText: 'pluginCodeHint'.tr(),
                ),
              ),
            ),

            // Output
            if (output.value != null) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isError.value
                      ? cs.errorContainer
                      : cs.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isError.value ? 'Error' : 'Output',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isError.value
                            ? cs.onErrorContainer
                            : cs.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      output.value!,
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                        color: isError.value
                            ? cs.onErrorContainer
                            : cs.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
