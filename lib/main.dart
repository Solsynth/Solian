import 'dart:io';

import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:island/pods/config.dart';
import 'package:island/pods/theme.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:island/route.dart';
import 'package:island/widgets/app_scaffold.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  if (!kIsWeb && (Platform.isMacOS || Platform.isLinux || Platform.isWindows)) {
    doWhenWindowReady(() {
      const initialSize = Size(600, 450);
      appWindow.minSize = initialSize;
      appWindow.size = initialSize;
      appWindow.alignment = Alignment.center;
      appWindow.show();
    });
  }

  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: EasyLocalization(
          supportedLocales: [Locale('en', 'US')],
          path: 'assets/i18n',
          fallbackLocale: Locale('en', 'US'),
          useFallbackTranslations: true,
          child: Overlay(
            initialEntries: [OverlayEntry(builder: (_) => IslandApp())],
          ),
        ),
      ),
    ),
  );
}

final _appRouter = AppRouter();

class IslandApp extends ConsumerWidget {
  const IslandApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);

    return MaterialApp.router(
      theme: theme?.light,
      darkTheme: theme?.dark,
      themeMode: ThemeMode.system,
      routerConfig: _appRouter.config(),
      supportedLocales: context.supportedLocales,
      localizationsDelegates: [...context.localizationDelegates],
      locale: context.locale,
      builder: (context, child) {
        return WindowScaffold(
          router: _appRouter,
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
