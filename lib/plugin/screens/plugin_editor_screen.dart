import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/plugin/plugin_manager.dart';
import 'package:island/plugin/models/plugin_manifest.dart';
import 'package:material_symbols_icons/symbols.dart';

@RoutePage()
class PluginEditorScreen extends HookConsumerWidget {
  const PluginEditorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
            icon: const Icon(Symbols.play_arrow),
            label: const Text('Run'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Plugin Name',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: TextField(
                controller: codeController,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 14,
                ),
                decoration: const InputDecoration(
                  labelText: 'Python Code',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                  hintText: '# Write your plugin code here\n'
                      'def on_load():\n'
                      '    print("Hello from plugin!")\n',
                ),
              ),
            ),
          ),
          if (output.value != null)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isError.value
                    ? Theme.of(context).colorScheme.errorContainer
                    : Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isError.value ? 'Error' : 'Output',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    output.value!,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                      color: isError.value
                          ? Theme.of(context).colorScheme.onErrorContainer
                          : Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
