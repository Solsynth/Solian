import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:styled_widget/styled_widget.dart';

class SiteConfigForm extends HookWidget {
  final Map<String, dynamic>? initialConfig;
  final ValueChanged<Map<String, dynamic>> onChanged;

  const SiteConfigForm({
    super.key,
    this.initialConfig,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final jsonText = useState(
      const JsonEncoder.withIndent('  ').convert(initialConfig ?? {}),
    );
    final jsonError = useState<String?>(null);

    return Card(
      margin: EdgeInsets.zero,
      child: ExpansionTile(
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.all(Radius.circular(8)),
        ),
        title: const Text('Site Config (JSON)'),
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (jsonError.value != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    jsonError.value!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onErrorContainer,
                      fontSize: 12,
                    ),
                  ),
                ),
              TextFormField(
                initialValue: jsonText.value,
                decoration: const InputDecoration(
                  labelText: 'Config (JSON)',
                  hintText: '{"key": "value"}',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                ),
                minLines: 8,
                maxLines: null,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
                onChanged: (value) {
                  jsonText.value = value;
                  try {
                    final parsed = json.decode(value) as Map<String, dynamic>;
                    jsonError.value = null;
                    onChanged(parsed);
                  } catch (e) {
                    jsonError.value = 'Invalid JSON: $e';
                  }
                },
              ),
              const SizedBox(height: 8),
              Text(
                'Edit site configuration as JSON. Keys: styleOverride, navItems, etc.',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ).padding(all: 16),
        ],
      ),
    );
  }
}
