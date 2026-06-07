import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:island/plugins/apis/ui_api.dart';

final _log = Logger('PluginUiBridge');

/// Renders a [PluginUiDescriptor] as a Flutter widget.
///
/// Supports the following widget types:
/// - `card` - Material card with title, body, and action buttons
/// - `list` - Vertical list of items
/// - `button` - Elevated button
/// - `text` - Text widget
/// - `section` - Titled section with children
/// - `divider` - Divider line
class PluginUiRenderer extends StatelessWidget {
  final PluginUiDescriptor descriptor;
  final void Function(String callback)? onCallback;

  const PluginUiRenderer({
    super.key,
    required this.descriptor,
    this.onCallback,
  });

  /// Parse a JSON string from a plugin into a descriptor.
  static PluginUiDescriptor? parse(String jsonStr) {
    try {
      final data = jsonDecode(jsonStr) as Map<String, dynamic>;
      final type = data['type'] as String?;
      if (type == null) return null;
      return PluginUiDescriptor(type: type, data: data);
    } catch (e) {
      _log.warning('Failed to parse UI descriptor: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return _buildFromDescriptor(context, descriptor);
  }

  Widget _buildFromDescriptor(BuildContext context, PluginUiDescriptor desc) {
    switch (desc.type) {
      case 'card':
        return _buildCard(context, desc.data);
      case 'list':
        return _buildList(context, desc.data);
      case 'button':
        return _buildButton(context, desc.data);
      case 'text':
        return _buildText(context, desc.data);
      case 'section':
        return _buildSection(context, desc.data);
      case 'divider':
        return const Divider();
      default:
        return Text('Unknown widget type: ${desc.type}');
    }
  }

  Widget _buildCard(BuildContext context, Map<String, dynamic> data) {
    final title = data['title'] as String? ?? '';
    final body = data['body'] as String? ?? '';
    final actions = data['actions'] as List?;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (title.isNotEmpty)
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            if (title.isNotEmpty && body.isNotEmpty)
              const SizedBox(height: 8),
            if (body.isNotEmpty)
              Text(
                body,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            if (actions != null && actions.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: actions.map((action) {
                  if (action is Map<String, dynamic>) {
                    return _buildButton(context, action);
                  }
                  if (action is String) {
                    // Try parsing as JSON
                    try {
                      final parsed = jsonDecode(action) as Map<String, dynamic>;
                      return _buildButton(context, parsed);
                    } catch (_) {
                      return Text(action);
                    }
                  }
                  return const SizedBox.shrink();
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildList(BuildContext context, Map<String, dynamic> data) {
    final items = data['items'] as List? ?? [];

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: items.map((item) {
          if (item is String) {
            return ListTile(
              title: Text(item),
              dense: true,
            );
          }
          if (item is Map<String, dynamic>) {
            final type = item['type'] as String? ?? 'text';
            if (type == 'button') {
              return _buildButton(context, item);
            }
            return ListTile(
              title: Text(item['content']?.toString() ?? item.toString()),
              dense: true,
            );
          }
          return ListTile(
            title: Text(item?.toString() ?? ''),
            dense: true,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildButton(BuildContext context, Map<String, dynamic> data) {
    final label = data['label'] as String? ?? 'Action';
    final callback = data['callback'] as String?;

    return ElevatedButton(
      onPressed: callback != null ? () => onCallback?.call(callback) : null,
      child: Text(label),
    );
  }

  Widget _buildText(BuildContext context, Map<String, dynamic> data) {
    final content = data['content'] as String? ?? '';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(content, style: Theme.of(context).textTheme.bodyMedium),
    );
  }

  Widget _buildSection(BuildContext context, Map<String, dynamic> data) {
    final title = data['title'] as String? ?? '';
    final children = data['children'] as List? ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (title.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ...children.map((child) {
          if (child is String) {
            try {
              final parsed = jsonDecode(child) as Map<String, dynamic>;
              final type = parsed['type'] as String?;
              if (type != null) {
                return PluginUiRenderer(
                  descriptor: PluginUiDescriptor(type: type, data: parsed),
                  onCallback: onCallback,
                );
              }
            } catch (_) {
              return Text(child);
            }
          }
          if (child is Map<String, dynamic>) {
            final type = child['type'] as String?;
            if (type != null) {
              return PluginUiRenderer(
                descriptor: PluginUiDescriptor(type: type, data: child),
                onCallback: onCallback,
              );
            }
          }
          return Text(child?.toString() ?? '');
        }),
      ],
    );
  }
}

/// A widget that displays UI from a plugin's output.
class PluginOutputWidget extends StatelessWidget {
  final String pluginId;
  final List<PluginUiDescriptor> descriptors;
  final void Function(String callback)? onCallback;

  const PluginOutputWidget({
    super.key,
    required this.pluginId,
    required this.descriptors,
    this.onCallback,
  });

  @override
  Widget build(BuildContext context) {
    if (descriptors.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: descriptors
          .map((desc) => PluginUiRenderer(
                descriptor: desc,
                onCallback: onCallback,
              ))
          .toList(),
    );
  }
}
