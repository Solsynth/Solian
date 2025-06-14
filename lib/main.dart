import 'dart:developer';
import 'dart:io';

import 'package:croppy/croppy.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker_android/image_picker_android.dart';
import 'package:island/firebase_options.dart';
import 'package:island/pods/config.dart';
import 'package:island/pods/network.dart';
import 'package:island/pods/theme.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:island/pods/userinfo.dart';
import 'package:island/pods/websocket.dart';
import 'package:island/route.dart';
import 'package:island/screens/auth/tabs.dart';
import 'package:island/services/notify.dart';
import 'package:island/services/timezone.dart';
import 'package:island/widgets/alert.dart';
import 'package:island/widgets/app_scaffold.dart';
import 'package:relative_time/relative_time.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:url_launcher/url_launcher_string.dart';

void main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
    log(
      "[SplashScreen] Keeping the flash screen to loading other resources...",
    );
    FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  }

  try {
    await EasyLocalization.ensureInitialized();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    log("[SplashScreen] Firebase is ready!");
  } catch (err) {
    showErrorAlert(err);
  }

  try {
    log("[SplashScreen] Loading timezone database...");
    await initializeTzdb();
    log("[SplashScreen] Time zone database was loaded!");
  } catch (err) {
    log("[SplashScreen] Failed to load timezone database... $err");
  }

  final prefs = await SharedPreferences.getInstance();

  if (!kIsWeb && (Platform.isMacOS || Platform.isLinux || Platform.isWindows)) {
    doWhenWindowReady(() {
      const initialSize = Size(360, 640);
      appWindow.minSize = initialSize;
      appWindow.size = initialSize;
      appWindow.alignment = Alignment.center;
      appWindow.show();
      log("[SplashScreen] Desktop window is ready!");
    });
  }

  if (!kIsWeb && Platform.isAndroid) {
    final ImagePickerPlatform imagePickerImplementation =
        ImagePickerPlatform.instance;
    if (imagePickerImplementation is ImagePickerAndroid) {
      imagePickerImplementation.useAndroidPhotoPicker = true;
    }
    log("[SplashScreen] Android image picker is ready!");
  }

  if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
    FlutterNativeSplash.remove();
    log("[SplashScreen] Now hiding the splash screen...");
  }

  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: EasyLocalization(
          supportedLocales: [
            Locale('en', 'US'),
            Locale('zh', 'CN'),
            Locale('zh', 'TW'),
          ],
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

    void handleMessage(RemoteMessage notification) {
      if (notification.data['action_uri'] != null) {
        var uri = notification.data['action_uri'] as String;
        if (uri.startsWith('/')) {
          // In-app routes
          _appRouter.pushPath(notification.data['action_uri']);
        } else {
          // External links
          launchUrlString(uri);
        }
      }
    }

    useEffect(() {
      Future(() async {
        RemoteMessage? initialMessage =
            await FirebaseMessaging.instance.getInitialMessage();
        if (initialMessage != null) {
          handleMessage(initialMessage);
        }

        FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
      });

      return null;
    }, []);

    useEffect(() {
      // Load userinfo
      final userNotifier = ref.read(userInfoProvider.notifier);
      ref.listen(websocketStateProvider, (_, state) {
        log('[WebSocket] $state');
      });
      Future(() {
        userNotifier.fetchUser().then((_) {
          final user = ref.watch(userInfoProvider);
          if (user.hasValue) {
            final apiClient = ref.read(apiClientProvider);
            subscribePushNotification(apiClient);
            final wsNotifier = ref.read(websocketStateProvider.notifier);
            wsNotifier.connect();
          }
        });
      });
      return null;
    }, []);

    return MaterialApp.router(
      theme: theme?.light,
      darkTheme: theme?.dark,
      themeMode: ThemeMode.system,
      routerConfig: _appRouter.config(
        navigatorObservers:
            () => [
              TabNavigationObserver(
                onChange: (route) {
                  ref.read(currentRouteProvider.notifier).state = route;
                },
              ),
            ],
      ),
      supportedLocales: context.supportedLocales,
      localizationsDelegates: [
        ...context.localizationDelegates,
        CroppyLocalizations.delegate,
        RelativeTimeLocalizations.delegate,
      ], // this contains the cupertino one
      locale: context.locale,
      builder: (context, child) {
        return Overlay(
          initialEntries: [
            OverlayEntry(
              builder:
                  (_) => WindowScaffold(
                    router: _appRouter,
                    child: TabsNavigationWidget(
                      router: _appRouter,
                      child: child ?? const SizedBox.shrink(),
                    ),
                  ),
            ),
          ],
        );
      },
    );
  }
}
