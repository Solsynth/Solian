import 'dart:developer';
import 'dart:io';
import 'package:croppy/croppy.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:image_picker_android/image_picker_android.dart';
import 'package:island/core/log_recorder.dart';
import 'package:island/core/services/analytics_service.dart';
import 'package:island/shared/widgets/app_wrapper.dart';
import 'package:island/firebase_options.dart';
import 'package:island/core/config.dart';
import 'package:island/core/theme.dart';
import 'package:island/accounts/account_pod.dart';
import 'package:island/core/websocket.dart';
import 'package:island/posts/pods/realtime_posts.dart';
import 'package:island/route.dart';
import 'package:island/core/services/widget_sync_service.dart';
import 'package:island/core/services/timezone.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/shared/widgets/app_scaffold.dart';
import 'package:logging/logging.dart';
import 'package:relative_time/relative_time.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:window_manager/window_manager.dart';
import 'package:protocol_handler/protocol_handler.dart';
import 'package:island/core/services/unifiedpush_service.dart';
import 'package:media_kit/media_kit.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  Logger.root.info('Handling a background message: ${message.messageId}');
}

void main(List<String> args) async {
  // Initialize logging
  Logger.root.onRecord.listen((record) {
    log(
      [
        '[${record.time}] [${record.level}] ${record.message}',
        if (record.error != null) 'Error: ${record.error}',
        ?record.stackTrace,
      ].join('\n'),
      time: record.time,
      level: record.level.value,
    );
  });

  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();

  await initializeUnifiedPush(args);

  if (!kIsWeb && Platform.isLinux && args.contains('--unifiedpush-bg')) {
    Logger.root.info('[UnifiedPush] Linux background receiver initialized.');
    return;
  }

  if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
    Logger.root.info(
      "[SplashScreen] Keeping the flash screen to loading other resources...",
    );
    FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  }

  if (!kIsWeb && (Platform.isLinux || Platform.isMacOS || Platform.isWindows)) {
    Logger.root.info("[SplashScreen] Initializing desktop window manager...");
    await protocolHandler.register('solian');
    await hotKeyManager.unregisterAll();
    Logger.root.info("[SplashScreen] Desktop window manager is ready!");
  }

  try {
    await EasyLocalization.ensureInitialized();
    // Disable logs
    EasyLocalization.logger.enableBuildModes = [];

    if (kIsWeb || !Platform.isLinux) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      FirebaseMessaging.onBackgroundMessage(
        _firebaseMessagingBackgroundHandler,
      );
      // Although previous if case checked this. Still check is web or not
      // Otherwise the web platform will broke due to there is no Platform api on the web
      // Skip crashlytics setup on debug mode to prevent unexpected report to firebase
      if ((kIsWeb || !Platform.isWindows) && !kDebugMode) {
        FlutterError.onError =
            FirebaseCrashlytics.instance.recordFlutterFatalError;
        PlatformDispatcher.instance.onError = (error, stack) {
          FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
          return true;
        };
      }
    }

    Logger.root.info("[SplashScreen] Firebase is ready!");
  } catch (err) {
    showErrorAlert(err);
  }

  try {
    Logger.root.info("[SplashScreen] Loading timezone database...");
    await initializeTzdb();
    Logger.root.info("[SplashScreen] Time zone database was loaded!");
  } catch (err) {
    Logger.root.severe(
      "[SplashScreen] Failed to load timezone database...",
      err,
    );
  }

  try {
    Logger.root.info("[Analytics] Initializing Analytics service...");
    final analyticsService = AnalyticsService();
    analyticsService.initialize();
  } catch (err) {
    Logger.root.severe(
      "[Analytics] Failed to initialize Analytics service...",
      err,
    );
  }

  final prefs = await SharedPreferences.getInstance();

  if (!kIsWeb && (Platform.isMacOS || Platform.isLinux || Platform.isWindows)) {
    await windowManager.ensureInitialized();

    const defaultSize = Size(360, 640);

    // Get saved window size from preferences
    final savedSizeString = prefs.getString(kAppWindowSize);
    Size initialSize = defaultSize;

    if (savedSizeString != null) {
      try {
        final parts = savedSizeString.split(',');
        if (parts.length == 2) {
          final width = double.parse(parts[0]);
          final height = double.parse(parts[1]);
          initialSize = Size(width, height);
        }
      } catch (e) {
        Logger.root.severe(
          "[SplashScreen] Failed to parse saved window size",
          e,
        );
        initialSize = defaultSize;
      }
    }

    WindowOptions windowOptions = WindowOptions(
      size: initialSize,
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.hidden,
      windowButtonVisibility: true,
    );
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      final env = Platform.environment;
      final isWayland = env.containsKey('WAYLAND_DISPLAY');

      if (isWayland) {
        try {
          await windowManager.setAsFrameless();
        } catch (e) {
          debugPrint('[Wayland] setAsFrameless failed: $e');
        }
      }
      await windowManager.setMinimumSize(defaultSize);
      await windowManager.show();
      await windowManager.focus();
      final opacity = prefs.getDouble(kAppWindowOpacity) ?? 1.0;
      await windowManager.setOpacity(opacity);
      Logger.root.info(
        "[SplashScreen] Desktop window is ready with size: ${initialSize.width}x${initialSize.height}"
        "${isWayland ? " (Wayland frameless fix applied)" : ""}",
      );
    });
  }

  if (!kIsWeb && Platform.isAndroid) {
    final ImagePickerPlatform imagePickerImplementation =
        ImagePickerPlatform.instance;
    if (imagePickerImplementation is ImagePickerAndroid) {
      imagePickerImplementation.useAndroidPhotoPicker = true;
    }
    Logger.root.info("[SplashScreen] Android image picker is ready!");
  }

  if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
    FlutterNativeSplash.remove();
    Logger.root.info("[SplashScreen] Now hiding splash screen...");
  }

  runApp(
    ProviderScope(
      retry: (retryCount, error) {
        if (retryCount > 3) return null;
        if (error is DioException) {
          if (error.response?.statusCode == 401) return null;
          if (error.response?.statusCode == 403) return null;
          if (error.response?.statusCode == 404) return null;
          if (error.response?.statusCode == 500) return null;
        }
        return const Duration(milliseconds: 300);
      },
      observers: [ProviderLogger()],
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: EasyLocalization(
          supportedLocales: [
            Locale('en', 'US'),
            Locale('zh', 'CN'),
            Locale('zh', 'TW'),
            Locale('zh', 'OG'),
            Locale('ja', 'JP'),
            Locale('ko', 'KR'),
            Locale('es', 'ES'),
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

// Router will be provided through Riverpod

final globalOverlay = GlobalKey<OverlayState>();
final globalScaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

class IslandApp extends HookConsumerWidget {
  const IslandApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Make sure it's active
    final _ = ref.read(logsProvider);

    // Theme data and prefs
    final theme = ref.watch(themeProvider);
    final settings = ref.watch(appSettingsProvider);

    // Convert string theme mode to ThemeMode enum
    ThemeMode getThemeMode() {
      final themeMode = settings.themeMode ?? 'system';
      switch (themeMode) {
        case 'light':
          return ThemeMode.light;
        case 'dark':
          return ThemeMode.dark;
        case 'system':
        default:
          return ThemeMode.system;
      }
    }

    void handleMessage(RemoteMessage notification) {
      if (notification.data['meta']?['action_uri'] != null) {
        var uri = notification.data['meta']['action_uri'] as String;
        if (uri.startsWith('/')) {
          // In-app routes
          final router = ref.read(routerProvider);
          router.push(notification.data['meta']['action_uri']);
        } else {
          // External links
          launchUrlString(uri);
        }
      }
    }

    useEffect(() {
      if (!kIsWeb && (Platform.isLinux || Platform.isWindows)) {
        return null;
      }

      // When the app is opened from a terminated state.
      FirebaseMessaging.instance.getInitialMessage().then((message) {
        if (message != null) {
          handleMessage(message);
        }
      });

      // When the app is in the background and opened.
      final onMessageOpenedAppSubscription = FirebaseMessaging
          .onMessageOpenedApp
          .listen(handleMessage);

      // When the app is in the foreground.
      final onMessageSubscription = FirebaseMessaging.onMessage.listen((
        message,
      ) {
        Logger.root.info(
          '[Notification] foreground message received: ${message.messageId}',
        );
        handleMessage(message);
      });

      return () {
        onMessageOpenedAppSubscription.cancel();
        onMessageSubscription.cancel();
      };
    }, []);

    useEffect(() {
      ref.listen(websocketStateProvider, (_, state) {
        Logger.root.info('[WebSocket] $state');
        if (state == WebSocketState.connected()) {
          ref.read(realtimePostsProvider).startListening();
        }
      });
      ref.listen(userInfoProvider, (_, user) {
        if (user.value != null) {
          WidgetSyncService().sendCfgToAppGroup();
        }
      });
      return null;
    }, []);

    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      scaffoldMessengerKey: globalScaffoldMessengerKey,
      color: Colors.transparent,
      theme: theme.light,
      darkTheme: theme.dark,
      themeMode: getThemeMode(),
      routerConfig: router.config(
        navigatorObservers: () {
          return [
            if (kIsWeb ||
                Platform.isAndroid ||
                Platform.isIOS ||
                Platform.isMacOS)
              FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance),
          ];
        },
      ),
      supportedLocales: context.supportedLocales,
      scrollBehavior: AppScrollBehavior(),
      localizationsDelegates: [
        ...context.localizationDelegates,
        CroppyLocalizations.delegate,
        RelativeTimeLocalizations.delegate,
      ],
      locale: context.locale,
      builder: (context, child) {
        return Overlay(
          key: globalOverlay,
          initialEntries: [
            OverlayEntry(
              builder: (_) {
                return WindowScaffold(
                  child: AppWrapper(child: child ?? const SizedBox.shrink()),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
