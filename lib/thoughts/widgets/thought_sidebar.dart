import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:island/thoughts/widgets/thought_sequence_list_view.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

/// A reusable sidebar widget for the Thought/AI chat feature.
///
/// Displays a header with title and close button, followed by a scrollable
/// list of conversation sequences.
class ThoughtSidebar extends StatelessWidget {
  /// Currently selected sequence ID (for highlighting)
  final String? selectedSequenceId;

  /// Callback when a sequence is selected
  final Function(String) onSequenceSelected;

  /// Callback when the close button is pressed
  final VoidCallback onClose;

  const ThoughtSidebar({
    super.key,
    this.selectedSequenceId,
    required this.onSequenceSelected,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.only(top: 12, left: 18, right: 16, bottom: 12),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'conversations'.tr(),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Symbols.close),
                onPressed: onClose,
                tooltip: 'close'.tr(),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: ThoughtSequenceListView(
            selectedSequenceId: selectedSequenceId,
            onSequenceSelected: onSequenceSelected,
          ),
        ),
      ],
    );
  }
}
