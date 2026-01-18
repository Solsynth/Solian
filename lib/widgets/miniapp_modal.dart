import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:island/modular/interface.dart';
import 'package:island/pods/plugin_registry.dart';

Future<void> showMiniappModal(
  BuildContext context,
  WidgetRef ref,
  String miniappId,
) async {
  final registry = ref.read(pluginRegistryProvider);
  final miniapp = registry.getMiniApp(miniappId);

  if (miniapp == null) {
    return;
  }

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) {
      return MiniappDisplay(miniapp: miniapp);
    },
  );
}

class MiniappDisplay extends StatelessWidget {
  final MiniApp miniapp;

  const MiniappDisplay({super.key, required this.miniapp});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).dividerColor,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Text('Miniapp', style: Theme.of(context).textTheme.titleMedium),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          Expanded(
            child: ProviderScope(
              child: Consumer(
                builder: (context, ref, child) {
                  return miniapp.buildEntry();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
