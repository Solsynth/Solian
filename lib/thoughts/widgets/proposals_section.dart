import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

class ProposalsSection extends StatelessWidget {
  const ProposalsSection({
    super.key,
    required this.proposals,
    required this.onProposalAction,
  });

  final List<Map<String, String>> proposals;
  final void Function(BuildContext, Map<String, String>) onProposalAction;

  @override
  Widget build(BuildContext context) {
    if (proposals.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              proposals.map((proposal) {
                return ElevatedButton.icon(
                  onPressed: () => onProposalAction(context, proposal),
                  icon: Icon(switch (proposal['type']) {
                    'post_create' => Symbols.add,
                    _ => Symbols.lightbulb,
                  }, size: 16),
                  label: Text(switch (proposal['type']) {
                    'post_create' => 'Create Post',
                    _ => proposal['type'] ?? 'Action',
                  }),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Theme.of(context).colorScheme.primaryContainer,
                    foregroundColor:
                        Theme.of(context).colorScheme.onPrimaryContainer,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }
}
