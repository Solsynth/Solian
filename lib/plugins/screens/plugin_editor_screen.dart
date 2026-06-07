import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/plugins/plugin_manager.dart';
import 'package:island/plugins/models/plugin_manifest.dart';
import 'package:material_symbols_icons/symbols.dart';

/// Standalone plugin editor screen.
/// Prefer using the editor sheet inside PluginManagerScreen for inline editing.
@RoutePage()
class PluginEditorScreen extends HookConsumerWidget {
  const PluginEditorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final codeController = useTextEditingController();
    final nameController = useTextEditingController(text: 'My Plugin');
    final output = useState<String?>(null);
    final isError = useState(false);
    final isRunning = useState(false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Plugin Editor'),
        actions: [
          FilledButton.icon(
            onPressed: isRunning.value
                ? null
                : () async {
                    isRunning.value = true;
                    output.value = null;
                    isError.value = false;

                    try {
                      final manager = PluginManager();
                      await manager.initialize();
                      final instance = manager.installInlinePlugin(
                        name: nameController.text,
                        source: codeController.text,
                        permissions: PluginPermission.values,
                      );

                      if (instance.state == PluginState.active) {
                        output.value = 'Plugin loaded successfully.';
                        isError.value = false;
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
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Plugin name',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                isDense: true,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: TextField(
                controller: codeController,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                style:
                    const TextStyle(fontFamily: 'monospace', fontSize: 13),
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
                      style:
                          Theme.of(context).textTheme.labelSmall?.copyWith(
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
