import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker_android/image_picker_android.dart';
import 'package:island/core/log_recorder.dart';
import 'package:island/core/services/analytics_service.dart';
import 'package:island/core/network.dart';
import 'package:island/shared/services/location_search_service.dart';
import 'package:island/shared/widgets/app_wrapper.dart';
import 'package:island/firebase_options.dart';
import 'package:island/core/config.dart';
import 'package:island/core/theme.dart';
import 'package:island/accounts/account_pod.dart';
import 'package:island/core/websocket.dart';
import 'package:island/posts/pods/realtime_posts.dart';
import 'package:island/route.dart';
import 'package:island/chat/pods/native_call_bridge.dart';
import 'package:island/core/services/widget_sync_service.dart';
import 'package:island/core/services/timezone.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/shared/widgets/app_scaffold.dart';
import 'package:island_ui_foundation/island_ui_foundation.dart';
import 'package:island/plugins/plugin.dart';
import 'package:logging/logging.dart';
import 'package:relative_time/relative_time.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:window_manager/window_manager.dart';
import 'package:protocol_handler/protocol_handler.dart';
import 'package:media_kit/media_kit.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
// ponytail: desktop_multi_window for call window support
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:island/chat/widgets/call_window.dart';

final List<LogRecord> _earlyLogs = [];
const _sentryDsn = String.fromEnvironment('SENTRY_DSN');

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  var handled = false;
  if (!kIsWeb && Platform.isAndroid) {
    await NativeCallBackgroundBridge.ensureInitialized();
    handled = await NativeCallBackgroundBridge.showIncomingCallFromPayload(
      message.data,
    );
  }
  Logger.root.info('Handling a background message: ${message.messageId}');
  if (handled) {
    Logger.root.info('[NativeCall] Displayed background incoming call');
  }
}

void main(List<String> args) async {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    _earlyLogs.add(record);
  });

  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  // ponytail: detect sub-window on desktop before heavy init
  if (!kIsWeb && (Platform.isMacOS || Platform.isLinux || Platform.isWindows)) {
    try {
      final windowController = await WindowController.fromCurrentEngine();
      final rawArgs = windowController.arguments;
      if (rawArgs.isNotEmpty) {
        final callArgs = parseCallWindowArgs(rawArgs);
        if (callArgs != null) {
          // Minimal init for call window — skip Firebase, plugins, full router
          await windowManager.ensureInitialized();
          final callPrefs = await SharedPreferences.getInstance();
          final savedSize = callPrefs.getString('callWindowSize');
          Size initialSize = const Size(1100, 760);
          if (savedSize != null) {
            try {
              final parts = savedSize.split(',');
              if (parts.length == 2) {
                initialSize = Size(
                  double.parse(parts[0]),
                  double.parse(parts[1]),
                );
              }
            } catch (_) {}
          }
          WindowOptions windowOptions = WindowOptions(
            size: initialSize,
            minimumSize: const Size(720, 520),
            maximumSize: const Size(1200, 900),
            alwaysOnTop: true,
            center: true,
            backgroundColor: Colors.transparent,
            skipTaskbar: false,
            titleBarStyle: TitleBarStyle.hidden,
            windowButtonVisibility: true,
          );
          await windowManager.waitUntilReadyToShow(windowOptions, () async {
            await windowManager.show();
            await windowManager.focus();
            await windowManager.setAlwaysOnTop(true);
            await windowManager.setResizable(true);
            // ponytail: prevent maximize — call window should stay compact
            await windowManager.setMaximizable(false);
          });
          await EasyLocalization.ensureInitialized();
          EasyLocalization.logger.enableBuildModes = [];
          runApp(
            ProviderScope(
              overrides: [
                sharedPreferencesProvider.overrideWithValue(callPrefs),
              ],
              child: CallWindowApp(args: callArgs),
            ),
          );
          return;
        }
      }
    } catch (_) {
      // Not a sub-window or parse failed — continue with normal init
    }
  }

  MediaKit.ensureInitialized();

  if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
    Logger.root.info(
      "[SplashScreen] Keeping the flash screen to loading other resources...",
    );
    FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  }

  if (!kIsWeb && (Platform.isLinux || Platform.isMacOS || Platform.isWindows)) {
    Logger.root.info("[SplashScreen] Initializing desktop window manager...");
    await protocolHandler.register('solian');
    Logger.root.info("[SplashScreen] Desktop window manager is ready!");
  }

  Future<void> appRunner() async {
    final prefs = await SharedPreferences.getInstance();

    try {
      await EasyLocalization.ensureInitialized();
      EasyLocalization.logger.enableBuildModes = [];

      if (kIsWeb || !Platform.isLinux) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
        FirebaseMessaging.onBackgroundMessage(
          _firebaseMessagingBackgroundHandler,
        );
      }

      if (!kIsWeb && Platform.isAndroid) {
        await NativeCallBackgroundBridge.ensureInitialized();
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

    try {
      Logger.root.info(
        "[LocationSearch] Initializing LocationSearch service...",
      );
      await LocationSearchService.instance.initialize();
      Logger.root.info("[LocationSearch] LocationSearch service is ready!");
    } catch (err) {
      Logger.root.severe(
        "[LocationSearch] Failed to initialize LocationSearch service...",
        err,
      );
    }

    try {
      Logger.root.info("[Plugin] Initializing plugin system...");
      // Clear stale state from previous hot restart
      PluginController.resetInstance();
      PluginManager().dispose();

      final controller = PluginController.instance;
      // Foundation APIs
      controller.registerApi('hooks', HooksApi());
      controller.registerApi('events', EventsApi());
      controller.registerApi('commands', CommandsApi());
      controller.registerApi('ui', UiApi());
      controller.registerApi('tasks', BackgroundTaskApi());
      // Host-specific APIs (dashboard, Solar Network, notify UI, icons)
      controller.registerApi('notify', NotifyApi());
      controller.registerApi('icons', IconsApi());
      controller.registerApi('dashboard', DashboardApi());
      final pluginNetworkScope = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );
      controller.registerApi(
        'network',
        PluginNetworkApi(prefs, pluginNetworkScope.read(apiClientProvider)),
      );
      controller.registerApi('ws', PluginWebsocketApi());
      await controller.initialize();
      PluginEventBridge().activate();
      Logger.root.info(
        "[Plugin] Plugin system ready with ${controller.plugins.length} plugins",
      );
    } catch (err) {
      Logger.root.severe("[Plugin] Failed to initialize plugin system...", err);
    }

    HttpOverrides.global = createAppHttpOverridesFromPrefs(prefs);

    if (!kIsWeb &&
        (Platform.isMacOS || Platform.isLinux || Platform.isWindows)) {
      await windowManager.ensureInitialized();

      const defaultSize = Size(360, 640);
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

    Logger.root.onRecord.listen((record) {
      developer.log(
        record.message,
        time: record.time,
        level: record.level.value,
        name: record.loggerName,
      );
    });
    for (final record in _earlyLogs) {
      developer.log(
        record.message,
        time: record.time,
        level: record.level.value,
        name: record.loggerName,
      );
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

  if (_sentryDsn.isNotEmpty) {
    await SentryFlutter.init((options) {
      options.dsn = _sentryDsn;
      options.sendDefaultPii = false;
      options.tracesSampleRate = 0.01;
      options.enableAutoSessionTracking = false;
    }, appRunner: appRunner);
    return;
  }

  await appRunner();
}

// 以下是 IslandApp 等代码保持不变...
// ponytail: non-final so call window can swap to its own overlay key
GlobalKey<OverlayState> globalOverlay = GlobalKey<OverlayState>();
final globalScaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

class IslandApp extends HookConsumerWidget {
  const IslandApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDeveloperMode = ref.watch(developerModeProvider);
    if (isDeveloperMode) {
      ref.read(logsProvider);
    }

    final theme = ref.watch(themeProvider);
    final settings = ref.watch(appSettingsProvider);
    final router = ref.watch(routerProvider);

    IslandUIFoundation.configureOverlay(globalOverlay);
    IslandUIFoundation.configureNavigator(router.navigatorKey);
    IslandUIFoundation.configureHaptic(() => settings.notifyWithHaptic);

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
          final router = ref.read(routerProvider);
          router.push(notification.data['meta']['action_uri']);
        } else {
          launchUrlString(uri);
        }
      }
    }

    useEffect(() {
      ref.listen<HttpOverrides?>(appHttpOverridesProvider, (_, overrides) {
        HttpOverrides.global = overrides;
      });

      if (!kIsWeb && (Platform.isLinux || Platform.isWindows)) {
        return null;
      }

      FirebaseMessaging.instance.getInitialMessage().then((message) {
        if (message != null) {
          handleMessage(message);
        }
      });

      final onMessageOpenedAppSubscription = FirebaseMessaging
          .onMessageOpenedApp
          .listen(handleMessage);

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

    return MaterialApp.router(
      title: 'Solar Network',
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
