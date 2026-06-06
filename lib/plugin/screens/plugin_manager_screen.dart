import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/plugin/plugin_manager.dart';
import 'package:island/plugin/models/plugin_manifest.dart';
import 'package:material_symbols_icons/symbols.dart';

@RoutePage()
class PluginManagerScreen extends HookConsumerWidget {
  const PluginManagerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final manager = PluginManager();
    final plugins = manager.plugins;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Plugins'),
        actions: [
          IconButton(
            icon: const Icon(Symbols.add),
            onPressed: () => _showInstallDialog(context, manager),
            tooltip: 'Install plugin',
          ),
        ],
      ),
      body: plugins.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Symbols.extension,
                    size: 64,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No plugins installed',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Install plugins from the plugin directory\nor create one in the editor',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: plugins.length,
              itemBuilder: (context, index) {
                final entry = plugins.entries.elementAt(index);
                return _PluginTile(
                  instance: entry.value,
                  onToggle: (enabled) {
                    if (enabled) {
                      manager.enablePlugin(entry.key);
                      manager.loadPlugin(entry.key);
                    } else {
                      manager.disablePlugin(entry.key);
                    }
                  },
                  onUninstall: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Uninstall Plugin'),
                        content: Text(
                          'Remove "${entry.value.manifest.name}"? This cannot be undone.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            child: const Text('Uninstall'),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      await manager.uninstallPlugin(entry.key);
                    }
                  },
                );
              },
            ),
    );
  }

  void _showInstallDialog(BuildContext context, PluginManager manager) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Install Plugin'),
        content: const Text(
          'Place plugin folders in the app\'s plugins directory. '
          'Each plugin must contain a manifest.json and a main.py entry file.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

class _PluginTile extends StatelessWidget {
  final PluginInstance instance;
  final ValueChanged<bool> onToggle;
  final VoidCallback onUninstall;

  const _PluginTile({
    required this.instance,
    required this.onToggle,
    required this.onUninstall,
  });

  @override
  Widget build(BuildContext context) {
    final manifest = instance.manifest;
    final isActive = instance.state == PluginState.active;
    final isError = instance.state == PluginState.error;
    final isDisabled = instance.state == PluginState.disabled;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isError
              ? Theme.of(context).colorScheme.errorContainer
              : isActive
                  ? Theme.of(context).colorScheme.primaryContainer
                  : Theme.of(context).colorScheme.surfaceContainerHighest,
          foregroundColor: isError
              ? Theme.of(context).colorScheme.onErrorContainer
              : isActive
                  ? Theme.of(context).colorScheme.onPrimaryContainer
                  : Theme.of(context).colorScheme.onSurfaceVariant,
          child: Icon(
            isError
                ? Symbols.error
                : isActive
                    ? Symbols.check_circle
                    : Symbols.extension,
          ),
        ),
        title: Text(manifest.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${manifest.id} v${manifest.version}'),
            if (manifest.description.isNotEmpty)
              Text(
                manifest.description,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            if (isError && instance.lastError != null)
              Text(
                instance.lastError!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            Wrap(
              spacing: 4,
              children: manifest.permissions
                  .map((p) => Chip(
                        label: Text(
                          p.name,
                          style: const TextStyle(fontSize: 10),
                        ),
                        visualDensity: VisualDensity.compact,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ))
                  .toList(),
            ),
          ],
        ),
        isThreeLine: true,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Switch(
              value: isActive || (!isDisabled && instance.state == PluginState.loaded),
              onChanged: isDisabled ? null : onToggle,
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'uninstall') onUninstall();
              },
              itemBuilder: (ctx) => [
                const PopupMenuItem(
                  value: 'uninstall',
                  child: Text('Uninstall'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
