import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:island/plugins/icons/material_symbol_lookup.dart';
import 'package:island_plugin_foundation/island_plugin_foundation.dart';
import 'package:logging/logging.dart';

final _log = Logger('PluginIconFontRegistry');

/// Glyph in a plugin-loaded font (not an [IconData] — keeps icon tree-shaking).
class PluginIconGlyph {
  final String fontFamily;
  final int codePoint;

  const PluginIconGlyph({required this.fontFamily, required this.codePoint});
}

/// A custom icon font registered by a plugin (TTF/OTF + name→codepoint map).
class PluginIconFont {
  final String pluginId;
  final String id;
  final String fontFamily;
  final Map<String, int> glyphs;
  bool loaded;
  String? loadError;

  PluginIconFont({
    required this.pluginId,
    required this.id,
    required this.fontFamily,
    required this.glyphs,
    this.loaded = false,
    this.loadError,
  });

  PluginIconGlyph? glyph(String name) {
    final codePoint = glyphs[MaterialSymbolLookup.normalize(name)];
    if (codePoint == null) return null;
    return PluginIconGlyph(fontFamily: fontFamily, codePoint: codePoint);
  }
}

/// Host registry for plugin-provided icon fonts with name-based lookup.
///
/// Custom glyphs are **not** exposed as [IconData] (that would disable Flutter
/// icon font tree-shaking). Use [buildIcon] / [glyph] and render via [Text].
class PluginIconFontRegistry {
  PluginIconFontRegistry._();
  static final PluginIconFontRegistry instance = PluginIconFontRegistry._();

  /// key: `$pluginId/$fontId`
  final Map<String, PluginIconFont> _fonts = {};

  String _key(String pluginId, String fontId) =>
      '$pluginId/${MaterialSymbolLookup.normalize(fontId)}';

  static String fontFamilyName(String pluginId, String fontId) {
    final safePlugin = pluginId.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_');
    final safeFont = MaterialSymbolLookup.normalize(fontId);
    return 'plugin_icon_${safePlugin}_$safeFont';
  }

  List<PluginIconFont> fontsFor(String pluginId) => _fonts.values
      .where((f) => f.pluginId == pluginId)
      .toList(growable: false);

  PluginIconFont? getFont(String pluginId, String fontId) =>
      _fonts[_key(pluginId, fontId)];

  /// Sync registration for the JS bridge (`sendMessage` is synchronous).
  Map<String, dynamic> registerSync({
    required String pluginId,
    required String id,
    required String fontPath,
    required dynamic glyphs,
  }) {
    final fontId = MaterialSymbolLookup.normalize(id);
    if (fontId.isEmpty) {
      return {'ok': false, 'error': 'Font id is required'};
    }

    final manager = PluginManager();
    final resolvedFont = manager.resolvePluginAsset(pluginId, fontPath);
    if (resolvedFont == null) {
      return {
        'ok': false,
        'error': 'Font file not found or escapes plugin folder: $fontPath',
      };
    }
    final lower = resolvedFont.toLowerCase();
    if (!lower.endsWith('.ttf') &&
        !lower.endsWith('.otf') &&
        !lower.endsWith('.ttc')) {
      return {
        'ok': false,
        'error': 'Font must be .ttf, .otf, or .ttc: $fontPath',
      };
    }

    final Map<String, int> glyphMap;
    try {
      glyphMap = _parseGlyphsSync(pluginId, glyphs);
    } catch (e) {
      return {'ok': false, 'error': 'Invalid glyph map: $e'};
    }
    if (glyphMap.isEmpty) {
      return {'ok': false, 'error': 'Glyph map is empty'};
    }

    late final Uint8List bytes;
    try {
      bytes = File(resolvedFont).readAsBytesSync();
    } catch (e) {
      return {'ok': false, 'error': 'Failed to read font file: $e'};
    }

    final family = fontFamilyName(pluginId, fontId);
    final entry = PluginIconFont(
      pluginId: pluginId,
      id: fontId,
      fontFamily: family,
      glyphs: glyphMap,
    );
    _fonts[_key(pluginId, fontId)] = entry;

    unawaited(_loadFontBytes(entry, bytes));

    return {
      'ok': true,
      'id': fontId,
      'fontFamily': family,
      'glyphCount': glyphMap.length,
      'loaded': entry.loaded,
    };
  }

  Future<void> _loadFontBytes(PluginIconFont entry, Uint8List bytes) async {
    try {
      final loader = FontLoader(entry.fontFamily);
      loader.addFont(Future.value(ByteData.sublistView(bytes)));
      await loader.load();
      entry.loaded = true;
      entry.loadError = null;
      _log.info(
        'Loaded plugin icon font ${entry.id} for ${entry.pluginId} '
        '(${entry.glyphs.length} glyphs, family=${entry.fontFamily})',
      );
    } catch (e) {
      entry.loadError = e.toString();
      _log.warning('Failed to load plugin icon font ${entry.id}: $e');
    }
  }

  Map<String, int> _parseGlyphsSync(String pluginId, dynamic glyphs) {
    if (glyphs is String) {
      final resolved = PluginManager().resolvePluginAsset(pluginId, glyphs);
      if (resolved == null) {
        throw ArgumentError('Glyph map asset not found: $glyphs');
      }
      return _mapFromJson(jsonDecode(File(resolved).readAsStringSync()));
    }
    return _mapFromJson(glyphs);
  }

  Map<String, int> _mapFromJson(dynamic raw) {
    if (raw is! Map) {
      throw ArgumentError('Glyph map must be a JSON object');
    }
    final out = <String, int>{};
    for (final entry in raw.entries) {
      final name = MaterialSymbolLookup.normalize(entry.key.toString());
      if (name.isEmpty) continue;
      final value = entry.value;
      int? codePoint;
      if (value is int) {
        codePoint = value;
      } else if (value is num) {
        codePoint = value.toInt();
      } else if (value is String) {
        final s = value.trim();
        if (s.startsWith('0x') || s.startsWith('0X')) {
          codePoint = int.tryParse(s.substring(2), radix: 16);
        } else {
          codePoint = int.tryParse(s);
        }
      }
      if (codePoint != null) {
        out[name] = codePoint;
      }
    }
    return out;
  }

  bool exists({
    required String? name,
    String? font,
    String? pluginId,
  }) {
    if (name == null || name.trim().isEmpty) return false;
    final parsed = parseIconRef(name, font: font);
    if (parsed.font == null) {
      return MaterialSymbolLookup.exists(parsed.name);
    }
    if (pluginId == null) return false;
    final f = getFont(pluginId, parsed.font!);
    if (f == null) return false;
    return f.glyphs.containsKey(MaterialSymbolLookup.normalize(parsed.name));
  }

  Map<String, dynamic>? lookup({
    required String? name,
    String? style,
    String? font,
    String? pluginId,
  }) {
    if (name == null || name.trim().isEmpty) return null;
    final parsed = parseIconRef(name, font: font);
    if (parsed.font == null) {
      return MaterialSymbolLookup.lookup(parsed.name, style: style);
    }
    if (pluginId == null) return null;
    final f = getFont(pluginId, parsed.font!);
    if (f == null) return null;
    final key = MaterialSymbolLookup.normalize(parsed.name);
    final codePoint = f.glyphs[key];
    if (codePoint == null) return null;
    return {
      'name': key,
      'font': f.id,
      'pluginId': pluginId,
      'codePoint': codePoint,
      'fontFamily': f.fontFamily,
      'loaded': f.loaded,
      'found': true,
      'const': false,
    };
  }

  List<String> search({
    required String query,
    int limit = 50,
    String? font,
    String? pluginId,
  }) {
    if (font == null || font.isEmpty) {
      return MaterialSymbolLookup.search(query, limit: limit);
    }
    if (pluginId == null) return const [];
    final f = getFont(pluginId, font);
    if (f == null) return const [];
    final q = MaterialSymbolLookup.normalize(query);
    if (q.isEmpty) return f.glyphs.keys.take(limit).toList();
    final matches = <String>[];
    for (final key in f.glyphs.keys) {
      if (!key.contains(q)) continue;
      matches.add(key);
      if (matches.length >= limit) break;
    }
    return matches;
  }

  int count({String? font, String? pluginId}) {
    if (font == null || font.isEmpty) {
      return MaterialSymbolLookup.count;
    }
    if (pluginId == null) return 0;
    return getFont(pluginId, font)?.glyphs.length ?? 0;
  }

  /// Resolve to **const** Material [IconData] only.
  ///
  /// Custom plugin fonts cannot become [IconData] without breaking icon
  /// tree-shaking — use [buildIcon] / [glyph] for those.
  static IconData resolve({
    String? name,
    String? style,
    String? font,
    String? pluginId,
    IconData? orElse,
  }) {
    if (name == null || name.trim().isEmpty) {
      return orElse ?? MaterialSymbolLookup.fallback;
    }
    final parsed = instance.parseIconRef(name, font: font);
    if (parsed.font != null) {
      // Prefer Material name if someone used a plain alias; else fallback.
      return orElse ?? MaterialSymbolLookup.fallback;
    }
    return MaterialSymbolLookup.resolve(
      parsed.name,
      style: style,
      orElse: orElse,
    );
  }

  /// Glyph for a custom font, if registered.
  static PluginIconGlyph? glyph({
    required String? name,
    String? font,
    String? pluginId,
  }) {
    if (name == null || pluginId == null) return null;
    final parsed = instance.parseIconRef(name, font: font);
    if (parsed.font == null) return null;
    return instance.getFont(pluginId, parsed.font!)?.glyph(parsed.name);
  }

  /// Build an icon widget — Material via [Icon], plugin fonts via [Text].
  static Widget buildIcon({
    String? name,
    double size = 24,
    String? style,
    String? font,
    String? pluginId,
    Color? color,
  }) {
    final custom = glyph(name: name, font: font, pluginId: pluginId);
    if (custom != null) {
      return Text(
        String.fromCharCode(custom.codePoint),
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: custom.fontFamily,
          fontSize: size,
          height: 1.0,
          color: color,
          leadingDistribution: TextLeadingDistribution.even,
        ),
      );
    }
    return Icon(
      resolve(name: name, style: style, font: font, pluginId: pluginId),
      size: size,
      color: color,
    );
  }

  /// Parse `"myfont:logo"` or plain `"logo"` (+ optional [font] arg).
  ({String name, String? font}) parseIconRef(String raw, {String? font}) {
    final explicit = font != null && font.trim().isNotEmpty
        ? MaterialSymbolLookup.normalize(font)
        : null;
    final trimmed = raw.trim();
    if (explicit != null) {
      return (name: trimmed, font: explicit);
    }
    final colon = trimmed.indexOf(':');
    if (colon > 0 && colon < trimmed.length - 1) {
      final maybeFont = trimmed.substring(0, colon);
      final maybeName = trimmed.substring(colon + 1);
      if (maybeFont.isNotEmpty &&
          maybeName.isNotEmpty &&
          !maybeFont.contains(' ')) {
        return (
          name: maybeName,
          font: MaterialSymbolLookup.normalize(maybeFont),
        );
      }
    }
    return (name: trimmed, font: null);
  }

  void clearPlugin(String pluginId) {
    _fonts.removeWhere((key, _) => key.startsWith('$pluginId/'));
    _log.info('Cleared icon fonts for plugin $pluginId');
  }

  void clearAll() {
    _fonts.clear();
  }
}
