import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:island/plugins/models/marketplace_plugin.dart';
import 'package:island_plugin_foundation/island_plugin_foundation.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Client for the public plugin marketplace on the Develop service.
///
/// Host-only (Island). Endpoints:
/// - `GET /develop/miniapps?take=&offset=&search=`
/// - `GET /develop/miniapps/{slug}`
class PluginMarketplaceService {
  PluginMarketplaceService(this._dio);

  final Dio _dio;
  final _log = Logger('PluginMarketplaceService');

  static const String basePath = '/develop/miniapps';
  static const int pageSize = 20;

  /// Discover production plugins. Returns listings and `X-Total` count.
  Future<(List<MarketplacePlugin> items, int total)> listPlugins({
    int take = pageSize,
    int offset = 0,
    String? search,
  }) async {
    final response = await _dio.get<dynamic>(
      basePath,
      queryParameters: {
        'take': take,
        'offset': offset,
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
      },
    );

    final total = int.tryParse(response.headers.value('X-Total') ?? '') ?? 0;
    final data = response.data;
    final items = <MarketplacePlugin>[];
    if (data is List) {
      for (final entry in data) {
        if (entry is Map<String, dynamic>) {
          items.add(MarketplacePlugin.fromJson(entry));
        } else if (entry is Map) {
          items.add(
            MarketplacePlugin.fromJson(Map<String, dynamic>.from(entry)),
          );
        }
      }
    }
    return (items, total);
  }

  /// Fetch a single production plugin by slug.
  Future<MarketplacePlugin> getBySlug(String slug) async {
    final response = await _dio.get<dynamic>('$basePath/$slug');
    final data = response.data;
    if (data is Map<String, dynamic>) {
      return MarketplacePlugin.fromJson(data);
    }
    if (data is Map) {
      return MarketplacePlugin.fromJson(Map<String, dynamic>.from(data));
    }
    throw StateError('Unexpected marketplace response for slug "$slug"');
  }

  /// Download the plugin ZIP, verify checksum, extract, and install via
  /// [PluginController.installFromFolder].
  ///
  /// Returns `true` when the plugin was installed successfully.
  Future<bool> installPlugin(
    MarketplacePlugin plugin,
    PluginController controller,
  ) async {
    if (!plugin.hasInstallablePackage) {
      _log.warning('Plugin ${plugin.slug} has no package_url');
      return false;
    }

    Directory? workDir;
    try {
      final bytes = await _downloadPackage(plugin.packageUrl!);
      _verifyChecksum(bytes, plugin.packageSha256);

      final tempRoot = await getTemporaryDirectory();
      workDir = Directory(
        p.join(
          tempRoot.path,
          'plugin-market-${plugin.slug}-${DateTime.now().millisecondsSinceEpoch}',
        ),
      );
      await workDir.create(recursive: true);

      final zipPath = p.join(workDir.path, 'package.zip');
      await File(zipPath).writeAsBytes(bytes, flush: true);

      final extractDir = Directory(p.join(workDir.path, 'extracted'));
      await extractDir.create(recursive: true);
      await _extractZip(bytes, extractDir.path);

      final pluginRoot = await _findPluginRoot(extractDir);
      if (pluginRoot == null) {
        _log.warning('No manifest.json found in package for ${plugin.slug}');
        return false;
      }

      final installed = await controller.installFromFolder(pluginRoot);
      if (!installed) return false;

      // Prefer the package's manifest id; fall back to marketplace plugin_id.
      final id = plugin.pluginId.isNotEmpty
          ? plugin.pluginId
          : (await _readManifestId(pluginRoot) ?? plugin.pluginId);

      if (id.isNotEmpty && controller.plugins.containsKey(id)) {
        await controller.enablePlugin(id);
        await controller.loadPlugin(id);
      }

      return true;
    } catch (e, st) {
      _log.severe('Failed to install marketplace plugin ${plugin.slug}', e, st);
      return false;
    } finally {
      if (workDir != null) {
        try {
          if (await workDir.exists()) {
            await workDir.delete(recursive: true);
          }
        } catch (_) {}
      }
    }
  }

  Future<Uint8List> _downloadPackage(String url) async {
    final response = await _dio.get<List<int>>(
      url,
      options: Options(
        responseType: ResponseType.bytes,
        // Package may be on CDN, not the API host.
        followRedirects: true,
        validateStatus: (s) => s != null && s >= 200 && s < 400,
      ),
    );
    final data = response.data;
    if (data == null || data.isEmpty) {
      throw StateError('Empty package download from $url');
    }
    return Uint8List.fromList(data);
  }

  void _verifyChecksum(Uint8List bytes, String? expectedSha256) {
    if (expectedSha256 == null || expectedSha256.trim().isEmpty) {
      _log.info('No package_sha256 provided; skipping checksum verification');
      return;
    }
    final digest = sha256.convert(bytes).toString().toLowerCase();
    final expected = expectedSha256.trim().toLowerCase();
    if (digest != expected) {
      throw StateError(
        'Package checksum mismatch (expected $expected, got $digest)',
      );
    }
  }

  Future<void> _extractZip(Uint8List bytes, String extractDir) async {
    final archive = ZipDecoder().decodeBytes(bytes);
    for (final file in archive) {
      // Reject absolute / traversal paths (mirrors backend safety rules).
      final name = file.name.replaceAll('\\', '/');
      if (name.startsWith('/') ||
          name.contains('..') ||
          p.isAbsolute(name)) {
        _log.warning('Skipping unsafe archive path: ${file.name}');
        continue;
      }
      final outPath = p.join(extractDir, name);
      if (file.isFile) {
        final out = File(outPath);
        await out.parent.create(recursive: true);
        await out.writeAsBytes(file.content);
      } else {
        await Directory(outPath).create(recursive: true);
      }
    }
  }

  /// Locate the directory that contains `manifest.json` (handles a single
  /// nesting level like `my-plugin/manifest.json`).
  Future<String?> _findPluginRoot(Directory extractDir) async {
    final direct = File(p.join(extractDir.path, 'manifest.json'));
    if (await direct.exists()) return extractDir.path;

    await for (final entity in extractDir.list(recursive: true)) {
      if (entity is File && p.basename(entity.path) == 'manifest.json') {
        return entity.parent.path;
      }
    }
    return null;
  }

  Future<String?> _readManifestId(String pluginRoot) async {
    try {
      final file = File(p.join(pluginRoot, 'manifest.json'));
      if (!await file.exists()) return null;
      final json = jsonDecode(await file.readAsString());
      if (json is Map && json['id'] != null) return json['id'].toString();
    } catch (_) {}
    return null;
  }
}
