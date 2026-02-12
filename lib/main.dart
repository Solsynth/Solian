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
import 'package:island/core/services/analytics_service.dart';
import 'package:island/talker.dart';
import 'package:island/firebase_options.dart';
import 'package:island/core/config.dart';
import 'package:island/core/audio.dart';
import 'package:island/core/network.dart';
import 'package:island/core/theme.dart';
import 'package:island/accounts/account_pod.dart';
import 'package:island/core/websocket.dart';
import 'package:island/posts/pods/realtime_posts.dart';
import 'package:island/route.dart';
import 'package:island/core/services/notify.dart';
import 'package:island/core/services/widget_sync_service.dart';
import 'package:island/core/services/timezone.dart';
import 'package:island/core/services/quick_actions.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/shared/widgets/app_scaffold.dart';
import 'package:relative_time/relative_time.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'package:talker_riverpod_logger/talker_riverpod_logger.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:window_manager/window_manager.dart';
import 'package:protocol_handler/protocol_handler.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  talker.info('Handling a background message: ${message.messageId}');
}

void main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
    talker.info(
      "[SplashScreen] Keeping the flash screen to loading other resources...",
    );
    FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  }

  if (!kIsWeb && (Platform.isLinux || Platform.isMacOS || Platform.isWindows)) {
    talker.info("[SplashScreen] Initializing desktop window manager...");
    await protocolHandler.register('solian');
    await hotKeyManager.unregisterAll();
    talker.info("[SplashScreen] Desktop window manager is ready!");
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

    talker.info("[SplashScreen] Firebase is ready!");
  } catch (err) {
    showErrorAlert(err);
  }

  try {
    talker.info("[SplashScreen] Loading timezone database...");
    await initializeTzdb();
    talker.info("[SplashScreen] Time zone database was loaded!");
  } catch (err) {
    talker.error("[SplashScreen] Failed to load timezone database... $err");
  }

  try {
    talker.info("[QuickActions] Initializing Quick Actions service...");
    final quickActionsService = QuickActionsService();
    await quickActionsService.initialize();
    talker.info("[QuickActions] Quick Actions service is ready!");
  } catch (err) {
    talker.error(
      "[QuickActions] Failed to initialize Quick Actions service... $err",
    );
  }

  try {
    talker.info("[Analytics] Initializing Analytics service...");
    final analyticsService = AnalyticsService();
    analyticsService.initialize();
  } catch (err) {
    talker.error("[Analytics] Failed to initialize Analytics service... $err");
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
        talker.error("[SplashScreen] Failed to parse saved window size: $e");
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
      talker.info(
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
    talker.info("[SplashScreen] Android image picker is ready!");
  }

  if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
    FlutterNativeSplash.remove();
    talker.info("[SplashScreen] Now hiding splash screen...");
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
      observers: [
        TalkerRiverpodObserver(
          talker: talker,
          settings: TalkerRiverpodLoggerSettings(
            printProviderAdded: false,
            printProviderDisposed: false,
            printProviderUpdated: false,
            printStateFullData: false,
          ),
        ),
      ],
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

class IslandApp extends HookConsumerWidget {
  const IslandApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
        talker.info(
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
      // Load userinfo
      final userNotifier = ref.read(userInfoProvider.notifier);
      ref.listen(websocketStateProvider, (_, state) {
        talker.info('[WebSocket] $state');
        if (state == WebSocketState.connected()) {
          ref.read(realtimePostsProvider).startListening();
        }
      });
      ref.listen(userInfoProvider, (_, user) {
        if (user.value != null) {
          WidgetSyncService().syncToWidget();
        }
      });
      Future(() {
        userNotifier.fetchUser().then((_) {
          final user = ref.watch(userInfoProvider);
          if (user.value != null) {
            final apiClient = ref.read(apiClientProvider);
            subscribePushNotification(apiClient);
            initializeLocalNotifications();
            ref.read(audioSessionProvider);
            ref.read(notificationSfxProvider);
            ref.read(messageSfxProvider);
            final wsNotifier = ref.read(websocketStateProvider.notifier);
            wsNotifier.connect();
          }
        });
      });
      return null;
    }, []);

    final router = ref.watch(routerProvider);

    return MaterialApp.router(
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
            TalkerRouteObserver(talker),
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
                return TalkerWrapper(
                  talker: talker,
                  options: const TalkerWrapperOptions(enableErrorAlerts: true),
                  child: WindowScaffold(
                    child: child ?? const SizedBox.shrink(),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
