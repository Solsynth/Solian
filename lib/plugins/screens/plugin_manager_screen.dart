import 'package:auto_route/auto_route.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/plugins/plugin_manager.dart';
import 'package:island/plugins/models/plugin_manifest.dart';
import 'package:island/shared/widgets/layouts/sheet_scaffold.dart';
import 'package:material_symbols_icons/symbols.dart';

// ---------------------------------------------------------------------------
// Standalone route screen (thin wrapper)
// ---------------------------------------------------------------------------

@RoutePage()
class PluginManagerScreen extends HookConsumerWidget {
  const PluginManagerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Plugins')),
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
    final manager = useMemoized(() => PluginManager());
    final refreshKey = useState(0);
    final plugins = useMemoized(
      () => manager.plugins,
      [refreshKey.value],
    );

    void refresh() => refreshKey.value++;

    if (plugins.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Symbols.extension,
                size: 48, color: Theme.of(context).colorScheme.outline),
            const SizedBox(height: 12),
            Text('No plugins installed',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    )),
            const SizedBox(height: 4),
            Text('Create one with the editor',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    )),
            const SizedBox(height: 16),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                FilledButton.tonalIcon(
                  onPressed: () => _openEditor(context, manager, refresh),
                  icon: const Icon(Symbols.add, size: 18),
                  label: const Text('New Plugin'),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: () => _installFromFolder(context, manager, refresh),
                  icon: const Icon(Symbols.folder_open, size: 18),
                  label: const Text('From Folder'),
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
                  '${plugins.length} plugin${plugins.length == 1 ? '' : 's'}',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ),
              IconButton(
                onPressed: () async {
                  await manager.reload();
                  refresh();
                },
                icon: const Icon(Symbols.refresh, size: 20),
                tooltip: 'Reload plugins',
                visualDensity: VisualDensity.compact,
              ),
              IconButton(
                onPressed: () => _installFromFolder(context, manager, refresh),
                icon: const Icon(Symbols.folder_open, size: 20),
                tooltip: 'Install from folder',
                visualDensity: VisualDensity.compact,
              ),
              FilledButton.tonalIcon(
                onPressed: () => _openEditor(context, manager, refresh),
                icon: const Icon(Symbols.add, size: 18),
                label: const Text('New'),
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
                onToggle: (enabled) {
                  if (enabled) {
                    manager.enablePlugin(entry.key);
                    manager.loadPlugin(entry.key);
                  } else {
                    manager.disablePlugin(entry.key);
                  }
                  refresh();
                },
                onUninstall: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Uninstall plugin'),
                      content: Text(
                        'Remove "${entry.value.manifest.name}"? This cannot be undone.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('Cancel'),
                        ),
                        FilledButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text('Uninstall'),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    await manager.uninstallPlugin(entry.key);
                    refresh();
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

  void _openEditor(
    BuildContext context,
    PluginManager manager,
    VoidCallback onDone,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _PluginEditorSheet(manager: manager, onSaved: onDone),
    );
  }

  // -- Install from folder ---------------------------------------------------

  Future<void> _installFromFolder(
    BuildContext context,
    PluginManager manager,
    VoidCallback onDone,
  ) async {
    final result = await FilePicker.getDirectoryPath(
      dialogTitle: 'Select plugin folder',
    );
    if (result == null) return;

    final installed = await manager.installFromFolder(result);
    if (installed) {
      onDone();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Plugin installed')),
        );
      }
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Invalid plugin folder — must contain a valid manifest.json',
            ),
          ),
        );
      }
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
    final isDisabled = instance.state == PluginState.disabled;

    final (icon, iconBg, iconFg) = switch (instance.state) {
      PluginState.active => (Symbols.check_circle, cs.primaryContainer, cs.onPrimaryContainer),
      PluginState.error => (Symbols.error, cs.errorContainer, cs.onErrorContainer),
      PluginState.disabled => (Symbols.pause_circle, cs.surfaceContainerHighest, cs.onSurfaceVariant),
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
                    if (isError && instance.lastError != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        instance.lastError!,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: cs.error,
                            ),
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
                            .map((p) => Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: cs.surfaceContainerHighest,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    p.name,
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelSmall
                                        ?.copyWith(
                                          fontSize: 10,
                                          color: cs.onSurfaceVariant,
                                        ),
                                  ),
                                ))
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
                  Switch(
                    value: isActive,
                    onChanged: isDisabled ? null : onToggle,
                  ),
                  PopupMenuButton<String>(
                    icon: Icon(Symbols.more_vert,
                        size: 18, color: cs.onSurfaceVariant),
                    onSelected: (v) {
                      if (v == 'uninstall') onUninstall();
                    },
                    itemBuilder: (_) => [
                      const PopupMenuItem(
                        value: 'uninstall',
                        child: Text('Uninstall'),
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
  final PluginManager manager;
  final VoidCallback onSaved;

  const _PluginEditorSheet({required this.manager, required this.onSaved});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final codeController = useTextEditingController();
    final nameController = useTextEditingController(text: 'My Plugin');
    final output = useState<String?>(null);
    final isError = useState(false);
    final isRunning = useState(false);

    return SheetScaffold(
      titleText: 'New Plugin',
      actions: [
        FilledButton.icon(
          onPressed: isRunning.value
              ? null
              : () async {
                  isRunning.value = true;
                  output.value = null;
                  isError.value = false;

                  try {
                    await manager.initialize();
                    final instance = manager.installInlinePlugin(
                      name: nameController.text,
                      source: codeController.text,
                      permissions: PluginPermission.values,
                    );

                    if (instance.state == PluginState.active) {
                      output.value = 'Plugin loaded successfully.';
                      isError.value = false;
                      onSaved();
                    } else {
                      output.value = instance.lastError ?? 'Unknown error';
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
          label: const Text('Run'),
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
                labelText: 'Plugin name',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8)),
                isDense: true,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                      borderRadius: BorderRadius.circular(8)),
                  alignLabelWithHint: true,
                  contentPadding: const EdgeInsets.all(12),
                  hintText: '// Write your plugin code here\n'
                      'function on_load() {\n'
                      '  notify("Hello", "from my plugin!");\n'
                      '}\n',
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
                  color: isError.value ? cs.errorContainer : cs.primaryContainer,
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
