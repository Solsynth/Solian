import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:surface/providers/config.dart';

const kMaterialYouToggleStoreKey = 'app_theme_material_you';

class ThemeSet {
  ThemeData light;
  ThemeData dark;

  ThemeSet({required this.light, required this.dark});
}

Future<ThemeSet> createAppThemeSet(
    {Color? seedColorOverride, bool? useMaterial3, String? customFonts}) async {
  return ThemeSet(
    light: await createAppTheme(
      Brightness.light,
      useMaterial3: useMaterial3,
      customFonts: customFonts,
    ),
    dark: await createAppTheme(
      Brightness.dark,
      useMaterial3: useMaterial3,
      customFonts: customFonts,
    ),
  );
}

Future<ThemeData> createAppTheme(
  Brightness brightness, {
  Color? seedColorOverride,
  bool? useMaterial3,
  String? customFonts,
}) async {
  final prefs = await SharedPreferences.getInstance();

  final seedColorString = prefs.getInt(kAppColorSchemeStoreKey);
  final seedColor =
      seedColorString != null ? Color(seedColorString) : Colors.indigo;

  final colorScheme = ColorScheme.fromSeed(
    seedColor: seedColorOverride ?? seedColor,
    brightness: brightness,
  );

  final hasAppBarTransparent =
      prefs.getBool(kAppbarTransparentStoreKey) ?? false;
  final useM3 =
      useMaterial3 ?? (prefs.getBool(kMaterialYouToggleStoreKey) ?? true);

  final inUseFonts = (customFonts ?? prefs.getString(kAppCustomFonts))
      ?.split(',')
      .map((ele) => ele.trim())
      .toList();

  return ThemeData(
    useMaterial3: useM3,
    colorScheme: colorScheme,
    brightness: brightness,
    fontFamily: inUseFonts?.firstOrNull,
    fontFamilyFallback: inUseFonts?.sublist(1),
    iconTheme: IconThemeData(
      fill: 0,
      weight: 400,
      opticalSize: 20,
      color: colorScheme.onSurface,
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: useM3 ? SnackBarBehavior.floating : SnackBarBehavior.fixed,
    ),
    appBarTheme: AppBarTheme(
      centerTitle: true,
      elevation: hasAppBarTransparent ? 0 : null,
      backgroundColor:
          hasAppBarTransparent ? Colors.transparent : colorScheme.primary,
      foregroundColor:
          hasAppBarTransparent ? colorScheme.onSurface : colorScheme.onPrimary,
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
  String toHex({bool leadingHashSign = true}) => '${leadingHashSign ? '#' : ''}'
      '${alpha.toRadixString(16).padLeft(2, '0')}'
      '${red.toRadixString(16).padLeft(2, '0')}'
      '${green.toRadixString(16).padLeft(2, '0')}'
      '${blue.toRadixString(16).padLeft(2, '0')}';
}
