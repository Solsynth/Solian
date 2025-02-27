import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:surface/providers/config.dart';

const kMaterialYouToggleStoreKey = 'app_theme_material_you';

class ThemeSet {
  ThemeData light;
  ThemeData dark;

  ThemeSet({required this.light, required this.dark});
}

Future<ThemeSet> createAppThemeSet(
    {Color? seedColorOverride, bool? useMaterial3}) async {
  return ThemeSet(
    light: await createAppTheme(Brightness.light, useMaterial3: useMaterial3),
    dark: await createAppTheme(Brightness.dark, useMaterial3: useMaterial3),
  );
}

Future<ThemeData> createAppTheme(
  Brightness brightness, {
  Color? seedColorOverride,
  bool? useMaterial3,
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

  return ThemeData(
    useMaterial3: useM3,
    colorScheme: colorScheme,
    brightness: brightness,
    // textTheme: GoogleFonts.rubikTextTheme(),
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
