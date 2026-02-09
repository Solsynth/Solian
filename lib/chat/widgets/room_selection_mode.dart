import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:material_symbols_icons/symbols.dart';

class RoomSelectionMode extends StatelessWidget {
  final bool visible;
  final int selectedCount;
  final VoidCallback onClose;
  final VoidCallback onAIThink;

  const RoomSelectionMode({
    super.key,
    required this.visible,
    required this.selectedCount,
    required this.onClose,
    required this.onAIThink,
  });

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();

    return Container(
      color: Theme.of(context).colorScheme.surface,
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 8,
        bottom: MediaQuery.of(context).padding.bottom + 8,
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: onClose,
            tooltip: 'Cancel selection',
          ),
          const SizedBox(width: 8),
          Text(
            '$selectedCount selected',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const Spacer(),
          if (selectedCount > 0)
            FilledButton.icon(
              onPressed: onAIThink,
              icon: const Icon(Symbols.smart_toy),
              label: const Text('AI Think'),
            ),
        ],
      ),
    );
  }
}
