import 'dart:io';

import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker_android/image_picker_android.dart';
import 'package:island/pods/config.dart';
import 'package:island/pods/theme.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:island/pods/userinfo.dart';
import 'package:island/route.dart';
import 'package:island/widgets/app_scaffold.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';

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

  if (!kIsWeb && Platform.isAndroid) {
    final ImagePickerPlatform imagePickerImplementation =
        ImagePickerPlatform.instance;
    if (imagePickerImplementation is ImagePickerAndroid) {
      imagePickerImplementation.useAndroidPhotoPicker = true;
    }
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
          child: IslandApp(),
        ),
      ),
    ),
  );
}

final _appRouter = AppRouter();

class IslandApp extends HookConsumerWidget {
  const IslandApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);

    useEffect(() {
      final userNotifier = ref.read(userInfoProvider.notifier);
      Future(() {
        userNotifier.fetchUser();
      });
      return null;
    }, []);

    return MaterialApp.router(
      theme: theme?.light,
      darkTheme: theme?.dark,
      themeMode: ThemeMode.system,
      routerConfig: _appRouter.config(),
      supportedLocales: context.supportedLocales,
      localizationsDelegates: [
        ...context.localizationDelegates,
      ], // this contains the cupertino one
      locale: context.locale,
      builder: (context, child) {
        return Overlay(
          initialEntries: [
            OverlayEntry(
              builder:
                  (_) => WindowScaffold(
                    router: _appRouter,
                    child: child ?? const SizedBox.shrink(),
                  ),
            ),
          ],
        );
      },
    );
  }
}
