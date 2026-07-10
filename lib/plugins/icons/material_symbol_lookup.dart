import 'package:flutter/widgets.dart';
import 'package:material_symbols_icons/get.dart';
import 'package:material_symbols_icons/iconname_to_unicode_map.dart';

/// Programmatic Material Symbols lookup by icon name.
///
/// Uses [materialSymbolsIconNameToUnicodeMap] from `material_symbols_icons`
/// so any of ~4k symbols can be resolved without a hand-maintained switch.
///
/// **Release builds:** Flutter icon tree-shaking only keeps glyphs referenced
/// by compile-time constant [IconData]s. Dynamic lookup requires building with
/// `--no-tree-shake-icons` (or the glyphs for unused names will be missing).
class MaterialSymbolLookup {
  MaterialSymbolLookup._();

  static const String _fontPackage = 'material_symbols_icons';

  /// Default when a name is missing or unknown (`extension`).
  static IconData get fallback =>
      _iconData(materialSymbolsIconNameToUnicodeMap['extension']!, SymbolStyle.outlined);

  /// Canonicalize a free-form name: lower-case, hyphens/spaces → underscores.
  static String normalize(String name) {
    var n = name.trim().toLowerCase();
    n = n.replaceAll(RegExp(r'[\s\-]+'), '_');
    n = n.replaceAll(RegExp(r'_+'), '_');
    // Common Material Icons → Symbols renames / aliases.
    if (n.endsWith('_outlined') && n != 'outlined') {
      n = n.substring(0, n.length - '_outlined'.length);
    }
    return n;
  }

  /// Parse an optional style suffix or explicit style string.
  ///
  /// Accepts names like `dashboard_rounded` / `chat_sharp`, or separate style
  /// of `outlined` | `rounded` | `sharp` (default outlined).
  static ({String name, SymbolStyle style}) parseNameAndStyle(
    String raw, {
    String? style,
  }) {
    var n = normalize(raw);
    var s = _styleFromString(style) ?? SymbolStyle.outlined;

    if (n.endsWith('_rounded')) {
      n = n.substring(0, n.length - '_rounded'.length);
      s = SymbolStyle.rounded;
    } else if (n.endsWith('_sharp')) {
      n = n.substring(0, n.length - '_sharp'.length);
      s = SymbolStyle.sharp;
    } else if (n.endsWith('_outlined')) {
      n = n.substring(0, n.length - '_outlined'.length);
      s = SymbolStyle.outlined;
    }

    // Map may list both `10k` and `ten_k` — prefer the key that exists.
    if (!materialSymbolsIconNameToUnicodeMap.containsKey(n)) {
      final underscored = n.replaceAll(RegExp(r'[^a-z0-9_]'), '_');
      if (materialSymbolsIconNameToUnicodeMap.containsKey(underscored)) {
        n = underscored;
      }
    }

    return (name: n, style: s);
  }

  static SymbolStyle? _styleFromString(String? style) {
    if (style == null || style.isEmpty) return null;
    return switch (normalize(style)) {
      'rounded' => SymbolStyle.rounded,
      'sharp' => SymbolStyle.sharp,
      'outlined' || 'outline' => SymbolStyle.outlined,
      _ => null,
    };
  }

  static String _fontFamily(SymbolStyle style) {
    return switch (style) {
      SymbolStyle.rounded => 'MaterialSymbolsRounded',
      SymbolStyle.sharp => 'MaterialSymbolsSharp',
      SymbolStyle.outlined => 'MaterialSymbolsOutlined',
    };
  }

  static IconData _iconData(int codePoint, SymbolStyle style) {
    // Dynamic code points — requires --no-tree-shake-icons in release builds.
    // ignore: non_const_argument_for_const_parameter
    return IconData(
      // ignore: non_const_argument_for_const_parameter
      codePoint,
      // ignore: non_const_argument_for_const_parameter
      fontFamily: _fontFamily(style),
      fontPackage: _fontPackage,
    );
  }

  /// Whether [name] resolves to a known Material Symbol.
  static bool exists(String? name) {
    if (name == null || name.trim().isEmpty) return false;
    final parsed = parseNameAndStyle(name);
    return materialSymbolsIconNameToUnicodeMap.containsKey(parsed.name);
  }

  /// Resolve [name] to [IconData]. Unknown names return [orElse] or [fallback].
  static IconData resolve(
    String? name, {
    String? style,
    IconData? orElse,
  }) {
    if (name == null || name.trim().isEmpty) {
      return orElse ?? fallback;
    }
    final parsed = parseNameAndStyle(name, style: style);
    final codePoint = materialSymbolsIconNameToUnicodeMap[parsed.name];
    if (codePoint == null) {
      return orElse ?? fallback;
    }
    return _iconData(codePoint, parsed.style);
  }

  /// Metadata for a name, or `null` if unknown.
  static Map<String, dynamic>? lookup(String? name, {String? style}) {
    if (name == null || name.trim().isEmpty) return null;
    final parsed = parseNameAndStyle(name, style: style);
    final codePoint = materialSymbolsIconNameToUnicodeMap[parsed.name];
    if (codePoint == null) return null;
    return {
      'name': parsed.name,
      'style': parsed.style.name,
      'codePoint': codePoint,
      'found': true,
    };
  }

  /// Search icon names (base names only) containing [query].
  static List<String> search(String query, {int limit = 50}) {
    final q = normalize(query);
    if (q.isEmpty || limit <= 0) return const [];

    final matches = <String>[];
    for (final key in materialSymbolsIconNameToUnicodeMap.keys) {
      // Prefer canonical dart-style names over digit aliases like "10k".
      if (RegExp(r'^\d').hasMatch(key)) continue;
      if (!key.contains(q)) continue;
      matches.add(key);
      if (matches.length >= limit) break;
    }
    return matches;
  }

  /// All known base icon names (may be large — prefer [search] in plugins).
  static Iterable<String> get allNames =>
      materialSymbolsIconNameToUnicodeMap.keys.where(
        (k) => !RegExp(r'^\d').hasMatch(k),
      );

  /// Number of known icon names in the map (includes digit aliases).
  static int get count => materialSymbolsIconNameToUnicodeMap.length;
}
