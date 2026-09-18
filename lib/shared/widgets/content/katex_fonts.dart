import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// Lazily registers the KaTeX fonts used by [flutter_math_fork].
///
/// The vendored `flutter_math_fork` declares its KaTeX fonts as plain assets
/// (not pubspec `fonts:`) so Flutter web does not eagerly download all of them
/// at startup. This registers the families with the engine on first use; after
/// the first load every math expression renders synchronously.
class KaTeXFonts {
  KaTeXFonts._();

  static const String _assetBase =
      'packages/flutter_math_fork/lib/katex_fonts/fonts';

  /// KaTeX family (as referenced by flutter_math_fork's `TextStyle.fontFamily`)
  /// mapped to the font files that belong to it. Order matches upstream.
  static const Map<String, List<String>> _families = {
    'packages/flutter_math_fork/KaTeX_Main': [
      'KaTeX_Main-Regular.ttf',
      'KaTeX_Main-Italic.ttf',
      'KaTeX_Main-Bold.ttf',
      'KaTeX_Main-BoldItalic.ttf',
    ],
    'packages/flutter_math_fork/KaTeX_Math': [
      'KaTeX_Math-Italic.ttf',
      'KaTeX_Math-BoldItalic.ttf',
    ],
    'packages/flutter_math_fork/KaTeX_AMS': ['KaTeX_AMS-Regular.ttf'],
    'packages/flutter_math_fork/KaTeX_Caligraphic': [
      'KaTeX_Caligraphic-Regular.ttf',
      'KaTeX_Caligraphic-Bold.ttf',
    ],
    'packages/flutter_math_fork/KaTeX_Fraktur': [
      'KaTeX_Fraktur-Regular.ttf',
      'KaTeX_Fraktur-Bold.ttf',
    ],
    'packages/flutter_math_fork/KaTeX_SansSerif': [
      'KaTeX_SansSerif-Regular.ttf',
      'KaTeX_SansSerif-Bold.ttf',
      'KaTeX_SansSerif-Italic.ttf',
    ],
    'packages/flutter_math_fork/KaTeX_Script': ['KaTeX_Script-Regular.ttf'],
    'packages/flutter_math_fork/KaTeX_Typewriter': [
      'KaTeX_Typewriter-Regular.ttf',
    ],
    'packages/flutter_math_fork/KaTeX_Size1': ['KaTeX_Size1-Regular.ttf'],
    'packages/flutter_math_fork/KaTeX_Size2': ['KaTeX_Size2-Regular.ttf'],
    'packages/flutter_math_fork/KaTeX_Size3': ['KaTeX_Size3-Regular.ttf'],
    'packages/flutter_math_fork/KaTeX_Size4': ['KaTeX_Size4-Regular.ttf'],
  };

  static final Set<String> _loadedFamilies = <String>{};
  static Future<void>? _loading;

  /// Registers all KaTeX font families with the engine.
  ///
  /// Memoized: concurrent and subsequent calls share the same future. On
  /// failure the memo is dropped so the next call retries.
  static Future<void> ensureLoaded() => _loading ??= _loadAll();

  static Future<void> _loadAll() async {
    try {
      await Future.wait(_families.entries.map(_loadFamily));
    } catch (_) {
      _loading = null;
      rethrow;
    }
  }

  static Future<void> _loadFamily(MapEntry<String, List<String>> family) async {
    if (_loadedFamilies.contains(family.key)) return;
    final loader = FontLoader(family.key);
    for (final file in family.value) {
      loader.addFont(rootBundle.load('$_assetBase/$file'));
    }
    await loader.load();
    _loadedFamilies.add(family.key);
  }

  @visibleForTesting
  static void debugReset() {
    _loadedFamilies.clear();
    _loading = null;
  }
}

/// Builds [builder] only after the KaTeX fonts are registered with the engine.
///
/// While the fonts load (first math render only) [placeholder] is shown, so
/// math never renders with fallback fonts.
class KaTeXFontGate extends StatefulWidget {
  const KaTeXFontGate({
    super.key,
    required this.builder,
    required this.placeholder,
  });

  /// Built once fonts are available.
  final WidgetBuilder builder;

  /// Shown while fonts load.
  final WidgetBuilder placeholder;

  @override
  State<KaTeXFontGate> createState() => _KaTeXFontGateState();
}

class _KaTeXFontGateState extends State<KaTeXFontGate> {
  late Future<void> _fonts;

  @override
  void initState() {
    super.initState();
    _fonts = KaTeXFonts.ensureLoaded();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _fonts,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return widget.placeholder(context);
        }
        // On error, render anyway (fallback glyphs) and let the next gate
        // instance retry the load.
        return widget.builder(context);
      },
    );
  }
}
