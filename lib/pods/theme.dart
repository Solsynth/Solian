import 'package:flutter/material.dart';
import 'package:island/pods/config.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'theme.g.dart';

@riverpod
ThemeSet theme(Ref ref) {
  final settings = ref.watch(appSettingsNotifierProvider);
  return createAppThemeSet(settings);
}

class ThemeSet {
  ThemeData light;
  ThemeData dark;

  ThemeSet({required this.light, required this.dark});
}

ThemeSet createAppThemeSet(AppSettings settings) {
  return ThemeSet(
    light: createAppTheme(Brightness.light, settings),
    dark: createAppTheme(Brightness.dark, settings),
  );
}

ThemeData createAppTheme(Brightness brightness, AppSettings settings) {
  final seedColor =
      settings.appColorScheme != null
          ? Color(settings.appColorScheme!)
          : Colors.indigo;

  var colorScheme = ColorScheme.fromSeed(
    seedColor: seedColor,
    brightness: brightness,
  );

  final customColors = settings.customColors;
  if (customColors != null) {
    colorScheme = colorScheme.copyWith(
      primary:
          customColors.primary != null ? Color(customColors.primary!) : null,
      secondary:
          customColors.secondary != null
              ? Color(customColors.secondary!)
              : null,
      tertiary:
          customColors.tertiary != null ? Color(customColors.tertiary!) : null,
      surface:
          customColors.surface != null ? Color(customColors.surface!) : null,
      background:
          customColors.background != null
              ? Color(customColors.background!)
              : null,
      error: customColors.error != null ? Color(customColors.error!) : null,
    );
  }

  final hasAppBarTransparent = settings.appBarTransparent;
  final useM3 = settings.useMaterial3;

  final inUseFonts =
      settings.customFonts?.split(',').map((ele) => ele.trim()).toList() ??
      ['Nunito'];

  return ThemeData(
    useMaterial3: useM3,
    colorScheme: colorScheme,
    brightness: brightness,
    fontFamily: inUseFonts.firstOrNull,
    fontFamilyFallback: inUseFonts.sublist(1),
    iconTheme: IconThemeData(
      fill: 0,
      weight: 400,
      opticalSize: 20,
      color: colorScheme.onSurface,
    ),
    appBarTheme: AppBarTheme(
      centerTitle: true,
      elevation: hasAppBarTransparent ? 0 : null,
      backgroundColor:
          hasAppBarTransparent ? Colors.transparent : colorScheme.primary,
      foregroundColor:
          hasAppBarTransparent ? colorScheme.onSurface : colorScheme.onPrimary,
    ),
    cardTheme: CardThemeData(
      color: colorScheme.surfaceContainer.withOpacity(
        settings.cardTransparency,
      ),
      elevation: settings.cardTransparency <= 1 ? 0 : null,
    ),
    pageTransitionsTheme: PageTransitionsTheme(
      builders: {
        TargetPlatform.android: ZoomPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.macOS: ZoomPageTransitionsBuilder(),
        TargetPlatform.fuchsia: ZoomPageTransitionsBuilder(),
        TargetPlatform.linux: ZoomPageTransitionsBuilder(),
        TargetPlatform.windows: ZoomPageTransitionsBuilder(),
      },
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(year2023: false),
    sliderTheme: SliderThemeData(year2023: false),
  );
}

extension HexColor on Color {
  /// String is in the format "aabbcc" or "ffaabbcc" with an optional leading "#".
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  /// Prefixes a hash sign if [leadingHashSign] is set to `true` (default is `true`).
  String toHex({bool leadingHashSign = true}) =>
      '${leadingHashSign ? '#' : ''}'
      '${alpha.toRadixString(16).padLeft(2, '0')}'
      '${red.toRadixString(16).padLeft(2, '0')}'
      '${green.toRadixString(16).padLeft(2, '0')}'
      '${blue.toRadixString(16).padLeft(2, '0')}';
}
