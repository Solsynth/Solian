import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:island/plugins/apis/ui_api.dart';
import 'package:island/plugins/plugin_manager.dart';
import 'package:island/core/network.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:island/shared/widgets/content/audio.dart';
import 'package:island/shared/widgets/content/image.dart';
import 'package:island/shared/widgets/content/video.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

final _log = Logger('PluginUiBridge');

typedef PluginUiCallback = void Function(String callback, [String? value]);

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
  final PluginUiCallback? onCallback;

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
      case 'page':
        return _buildPage(context, desc.data);
      case 'row':
        return _buildChildren(context, desc.data['children'], horizontal: true);
      case 'column':
        return _buildChildren(
          context,
          desc.data['children'],
          horizontal: false,
        );
      case 'spacing':
        return SizedBox(height: (desc.data['size'] as num?)?.toDouble() ?? 8);
      case 'icon':
        return Icon(
          _iconForName(desc.data['name']?.toString()),
          size: (desc.data['size'] as num?)?.toDouble() ?? 20,
        );
      case 'link':
        return _buildLink(context, desc.data);
      case 'input':
        return _buildInput(context, desc.data);
      case 'cloud_file':
        return _PluginCloudFile(
          fileId: desc.data['id']?.toString() ?? '',
          fit: _boxFit(desc.data['fit']?.toString()),
        );
      case 'asset_image':
        return UniversalImage(
          uri: desc.data['url']?.toString() ?? '',
          fit: _boxFit(desc.data['fit']?.toString()) ?? BoxFit.contain,
        );
      case 'asset_audio':
        return UniversalAudio(
          uri: desc.data['url']?.toString() ?? '',
          filename: desc.data['filename']?.toString() ?? 'Audio',
          autoplay: desc.data['autoplay'] == true,
        );
      case 'asset_video':
        return UniversalVideo(
          uri: desc.data['url']?.toString() ?? '',
          aspectRatio: (desc.data['aspectRatio'] as num?)?.toDouble() ?? 16 / 9,
          autoplay: desc.data['autoplay'] == true,
        );
      case 'plugin_asset':
        return _PluginAsset(
          pluginId: desc.data['pluginId']?.toString() ?? '',
          relativePath: desc.data['path']?.toString() ?? '',
          kind: desc.data['kind']?.toString(),
          fit: _boxFit(desc.data['fit']?.toString()) ?? BoxFit.contain,
        );
      default:
        return Text('Unknown widget type: ${desc.type}');
    }
  }

  Widget _buildPage(BuildContext context, Map<String, dynamic> data) {
    final title = data['title']?.toString() ?? '';
    final child = _descriptorFromObject(data['child']);
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: child == null
          ? const SizedBox.shrink()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: PluginUiRenderer(
                descriptor: child,
                onCallback: onCallback,
              ),
            ),
    );
  }

  Widget _buildChildren(
    BuildContext context,
    Object? rawChildren, {
    required bool horizontal,
  }) {
    final children = rawChildren is List
        ? rawChildren
              .map(_descriptorFromObject)
              .whereType<PluginUiDescriptor>()
              .map(
                (child) =>
                    PluginUiRenderer(descriptor: child, onCallback: onCallback),
              )
              .toList()
        : <Widget>[];
    if (horizontal) {
      return Wrap(spacing: 12, runSpacing: 8, children: children);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    );
  }

  Widget _buildLink(BuildContext context, Map<String, dynamic> data) {
    final label = data['label']?.toString() ?? data['url']?.toString() ?? '';
    final url = Uri.tryParse(data['url']?.toString() ?? '');
    return TextButton.icon(
      onPressed: url == null ? null : () => launchUrl(url),
      icon: const Icon(Icons.open_in_new, size: 16),
      label: Text(label),
    );
  }

  Widget _buildInput(BuildContext context, Map<String, dynamic> data) {
    final callback = data['callback']?.toString();
    return TextField(
      decoration: InputDecoration(
        labelText: data['label']?.toString(),
        hintText: data['hint']?.toString(),
        border: const OutlineInputBorder(),
      ),
      onSubmitted: callback == null
          ? null
          : (value) => onCallback?.call(callback, value),
    );
  }

  static PluginUiDescriptor? _descriptorFromObject(Object? value) {
    try {
      final data = value is String ? jsonDecode(value) : value;
      if (data is! Map || data['type'] is! String) return null;
      return PluginUiDescriptor(
        type: data['type'] as String,
        data: data.map((key, value) => MapEntry(key.toString(), value)),
      );
    } catch (_) {
      return null;
    }
  }

  static IconData _iconForName(String? name) {
    return switch (name) {
      'check' => Icons.check,
      'close' => Icons.close,
      'warning' => Icons.warning_amber,
      'info' => Icons.info_outline,
      'settings' => Icons.settings,
      'open_in_new' => Icons.open_in_new,
      'dashboard' => Icons.dashboard_outlined,
      _ => Icons.extension_outlined,
    };
  }

  static BoxFit? _boxFit(String? value) {
    return switch (value) {
      'fill' => BoxFit.fill,
      'contain' => BoxFit.contain,
      'cover' => BoxFit.cover,
      'fitWidth' => BoxFit.fitWidth,
      'fitHeight' => BoxFit.fitHeight,
      'none' => BoxFit.none,
      'scaleDown' => BoxFit.scaleDown,
      _ => null,
    };
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
              Text(title, style: Theme.of(context).textTheme.titleMedium),
            if (title.isNotEmpty && body.isNotEmpty) const SizedBox(height: 8),
            if (body.isNotEmpty)
              Text(body, style: Theme.of(context).textTheme.bodyMedium),
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
            return ListTile(title: Text(item), dense: true);
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
          return ListTile(title: Text(item?.toString() ?? ''), dense: true);
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

final _pluginCloudFileProvider = FutureProvider.family<SnCloudFile, String>(
  (ref, fileId) =>
      ref.read(solarNetworkClientProvider).drive.getFileInfo(fileId),
);

class _PluginCloudFile extends ConsumerWidget {
  final String fileId;
  final BoxFit? fit;

  const _PluginCloudFile({required this.fileId, required this.fit});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (fileId.isEmpty) return const SizedBox.shrink();
    final file = ref.watch(_pluginCloudFileProvider(fileId));
    return file.when(
      data: (item) => CloudFileWidget(item: item, fit: fit ?? BoxFit.cover),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Text('Unable to load cloud file: $error'),
    );
  }
}

class _PluginAsset extends StatelessWidget {
  final String pluginId;
  final String relativePath;
  final String? kind;
  final BoxFit fit;

  const _PluginAsset({
    required this.pluginId,
    required this.relativePath,
    required this.kind,
    required this.fit,
  });

  @override
  Widget build(BuildContext context) {
    final resolved = PluginManager().resolvePluginAsset(pluginId, relativePath);
    if (resolved == null) return const SizedBox.shrink();
    final file = File(resolved);
    final type = kind ?? _inferKind(relativePath);
    return switch (type) {
      'image' => Image.file(file, fit: fit),
      'video' => UniversalVideo(uri: file.path),
      'audio' => UniversalAudio(uri: file.path, filename: relativePath),
      _ => ListTile(
        leading: const Icon(Icons.insert_drive_file_outlined),
        title: Text(relativePath.split(Platform.pathSeparator).last),
        subtitle: Text('${file.lengthSync()} bytes'),
      ),
    };
  }

  String _inferKind(String path) {
    final extension = path.toLowerCase().split('.').last;
    if (const {
      'png',
      'jpg',
      'jpeg',
      'gif',
      'webp',
      'svg',
    }.contains(extension)) {
      return 'image';
    }
    if (const {'mp4', 'webm', 'mov', 'mkv'}.contains(extension)) {
      return 'video';
    }
    if (const {'mp3', 'wav', 'm4a', 'aac', 'ogg', 'flac'}.contains(extension)) {
      return 'audio';
    }
    return 'file';
  }
}

/// A widget that displays UI from a plugin's output.
class PluginOutputWidget extends StatelessWidget {
  final String pluginId;
  final List<PluginUiDescriptor> descriptors;
  final PluginUiCallback? onCallback;

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
          .map(
            (desc) =>
                PluginUiRenderer(descriptor: desc, onCallback: onCallback),
          )
          .toList(),
    );
  }
}
