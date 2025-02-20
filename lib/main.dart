import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:ui';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:croppy/croppy.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:easy_localization_loader/easy_localization_loader.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:relative_time/relative_time.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:surface/firebase_options.dart';
import 'package:surface/providers/channel.dart';
import 'package:surface/providers/chat_call.dart';
import 'package:surface/providers/config.dart';
import 'package:surface/providers/link_preview.dart';
import 'package:surface/providers/navigation.dart';
import 'package:surface/providers/notification.dart';
import 'package:surface/providers/post.dart';
import 'package:surface/providers/relationship.dart';
import 'package:surface/providers/sn_attachment.dart';
import 'package:surface/providers/sn_network.dart';
import 'package:surface/providers/sn_sticker.dart';
import 'package:surface/providers/special_day.dart';
import 'package:surface/providers/theme.dart';
import 'package:surface/providers/user_directory.dart';
import 'package:surface/providers/userinfo.dart';
import 'package:surface/providers/websocket.dart';
import 'package:surface/providers/widget.dart';
import 'package:surface/router.dart';
import 'package:surface/types/chat.dart';
import 'package:surface/types/realm.dart';
import 'package:flutter_web_plugins/url_strategy.dart' show usePathUrlStrategy;
import 'package:surface/widgets/dialog.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:version/version.dart';
import 'package:workmanager/workmanager.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:image_picker_android/image_picker_android.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';

@pragma('vm:entry-point')
void appBackgroundDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    log("[WorkManager] Native called background task: $task");
    switch (task) {
      case Workmanager.iOSBackgroundTask:
        await Future.wait([widgetUpdateRandomPost()]);
        return true;
      case "WidgetUpdateRandomPost":
        await widgetUpdateRandomPost();
        return true;
      default:
        return true;
    }
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    doWhenWindowReady(() {
      appWindow.minSize = Size(480, 640);
      appWindow.size = Size(1280, 720);
      appWindow.alignment = Alignment.center;
      appWindow.show();
    });
  }

  await EasyLocalization.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(SnChannelImplAdapter());
  Hive.registerAdapter(SnRealmImplAdapter());
  Hive.registerAdapter(SnChannelMemberImplAdapter());
  Hive.registerAdapter(SnChatMessageImplAdapter());

  if (!kIsWeb && !Platform.isLinux) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  GoRouter.optionURLReflectsImperativeAPIs = true;
  usePathUrlStrategy();

  if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
    Workmanager().initialize(
      appBackgroundDispatcher,
      isInDebugMode: kDebugMode,
    );
    if (Platform.isAndroid) {
      Workmanager().registerPeriodicTask(
        "widget-update-random-post",
        "WidgetUpdateRandomPost",
        frequency: Duration(minutes: 1),
        constraints: Constraints(networkType: NetworkType.connected),
        tag: "widget-update",
      );
    }
  }

  if (!kIsWeb && Platform.isAndroid) {
    final ImagePickerPlatform imagePickerImplementation = ImagePickerPlatform.instance;
    if (imagePickerImplementation is ImagePickerAndroid) {
      imagePickerImplementation.useAndroidPhotoPicker = true;
    }
  }

  runApp(const SolianApp());
}

class SolianApp extends StatelessWidget {
  const SolianApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveBreakpoints.builder(
      child: EasyLocalization(
        path: 'assets/translations',
        supportedLocales: [
          Locale('en', 'US'),
          Locale('zh', 'CN'),
          Locale('zh', 'TW'),
          Locale('zh', 'HK'),
        ],
        fallbackLocale: Locale('en', 'US'),
        useFallbackTranslations: true,
        assetLoader: JsonAssetLoader(),
        child: MultiProvider(
          providers: [
            // System extensions layer
            Provider(create: (ctx) => HomeWidgetProvider(ctx)),

            // Preferences layer
            ChangeNotifierProvider(create: (ctx) => ConfigProvider(ctx)),

            // Display layer
            ChangeNotifierProvider(create: (_) => ThemeProvider()),
            ChangeNotifierProvider(create: (ctx) => NavigationProvider()),

            // Data layer
            Provider(create: (ctx) => SnNetworkProvider(ctx)),
            Provider(create: (ctx) => UserDirectoryProvider(ctx)),
            Provider(create: (ctx) => SnAttachmentProvider(ctx)),
            Provider(create: (ctx) => SnPostContentProvider(ctx)),
            Provider(create: (ctx) => SnRelationshipProvider(ctx)),
            Provider(create: (ctx) => SnLinkPreviewProvider(ctx)),
            Provider(create: (ctx) => SnStickerProvider(ctx)),
            ChangeNotifierProvider(create: (ctx) => UserProvider(ctx)),
            ChangeNotifierProvider(create: (ctx) => WebSocketProvider(ctx)),
            ChangeNotifierProvider(create: (ctx) => NotificationProvider(ctx)),
            ChangeNotifierProvider(create: (ctx) => ChatChannelProvider(ctx)),
            ChangeNotifierProvider(create: (ctx) => ChatCallProvider(ctx)),

            // Additional helper layer
            Provider(create: (ctx) => SpecialDayProvider(ctx)),
          ],
          child: _AppDelegate(),
        ),
      ),
      breakpoints: [
        const Breakpoint(start: 0, end: 600, name: MOBILE),
        const Breakpoint(start: 601, end: 800, name: TABLET),
        const Breakpoint(start: 801, end: 1920, name: DESKTOP),
      ],
    );
  }
}

class _AppDelegate extends StatelessWidget {
  const _AppDelegate();

  @override
  Widget build(BuildContext context) {
    context.read<NavigationProvider>();
    context.read<WebSocketProvider>();
    context.read<ChatChannelProvider>();
    context.read<NotificationProvider>();

    final th = context.watch<ThemeProvider>();

    return MaterialApp.router(
      theme: th.theme?.light,
      darkTheme: th.theme?.dark,
      locale: context.locale,
      supportedLocales: context.supportedLocales,
      localizationsDelegates: [
        CroppyLocalizations.delegate,
        RelativeTimeLocalizations.delegate,
        ...context.localizationDelegates,
      ],
      routerConfig: appRouter,
      builder: (context, child) {
        return _AppSplashScreen(
          key: const Key('global-splash-screen'),
          child: child!,
        );
      },
    );
  }
}

class _AppSplashScreen extends StatefulWidget {
  final Widget child;

  const _AppSplashScreen({super.key, required this.child});

  @override
  State<_AppSplashScreen> createState() => _AppSplashScreenState();
}

class _AppSplashScreenState extends State<_AppSplashScreen> with TrayListener {
  void _tryRequestRating() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('first_boot_time')) {
      final rawTime = prefs.getString('first_boot_time');
      final time = DateTime.tryParse(rawTime ?? '');
      if (time != null && time.isBefore(DateTime.now().subtract(const Duration(days: 3)))) {
        final inAppReview = InAppReview.instance;
        if (prefs.getBool('rating_requested') == true) return;
        if (await inAppReview.isAvailable()) {
          await inAppReview.requestReview();
          prefs.setBool('rating_requested', true);
        } else {
          log('Unable request app review, unavailable');
        }
      }
    } else {
      prefs.setString('first_boot_time', DateTime.now().toIso8601String());
    }
  }

  Future<void> _checkForUpdate() async {
    if (kIsWeb) return;
    try {
      final info = await PackageInfo.fromPlatform();
      final localVersionString = '${info.version}+${info.buildNumber}';
      final resp = await Dio(
        BaseOptions(
          sendTimeout: const Duration(seconds: 60),
          receiveTimeout: const Duration(seconds: 60),
        ),
      ).get(
        'https://git.solsynth.dev/api/v1/repos/HyperNet/Surface/tags?page=1&limit=1',
      );
      final remoteVersionString = (resp.data as List).firstOrNull?['name'] ?? '0.0.0+0';
      final remoteVersion = Version.parse(remoteVersionString.split('+').first);
      final localVersion = Version.parse(localVersionString.split('+').first);
      final remoteBuildNumber = int.tryParse(remoteVersionString.split('+').last) ?? 0;
      final localBuildNumber = int.tryParse(localVersionString.split('+').last) ?? 0;
      log("[Update] Local: $localVersionString, Remote: $remoteVersionString");
      if ((remoteVersion > localVersion || remoteBuildNumber > localBuildNumber) && mounted) {
        final config = context.read<ConfigProvider>();
        config.setUpdate(remoteVersionString);
        log("[Update] Update available: $remoteVersionString");
      }
    } catch (e) {
      if (mounted) context.showErrorDialog('Unable to check update: $e');
    }
  }

  Future<void> _initialize() async {
    try {
      final cfg = context.read<ConfigProvider>();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        cfg.calcDrawerSize(context);
      });
      final home = context.read<HomeWidgetProvider>();
      await home.initialize();
      if (!mounted) return;
      // The Network initialization must be done after the HomeWidget initialization
      // The Network initialization will save the server url to the HomeWidget
      // The Network initialization will also save initialize the Config, so it not need to be initialized again
      final sn = context.read<SnNetworkProvider>();
      await sn.initializeUserAgent();
      await sn.setConfigWithNative();
      if (!mounted) return;
      final ua = context.read<UserProvider>();
      await ua.initialize();
      if (!mounted) return;
      final ws = context.read<WebSocketProvider>();
      await ws.tryConnect();
      if (!mounted) return;
      final notify = context.read<NotificationProvider>();
      notify.listen();
      await notify.registerPushNotifications();
      if (!mounted) return;
      final sticker = context.read<SnStickerProvider>();
      await sticker.listStickerEagerly();
    } catch (err) {
      if (!mounted) return;
      await context.showErrorDialog(err);
    }
  }

  Future<void> _postInitialization() async {
    await widgetUpdateRandomPost();
  }

  Future<void> _hotkeyInitialization() async {
    if (kIsWeb) return;

    if (Platform.isMacOS) {
      HotKey quitHotKey = HotKey(
        key: PhysicalKeyboardKey.keyQ,
        modifiers: [HotKeyModifier.meta],
        scope: HotKeyScope.inapp,
      );
      await hotKeyManager.register(quitHotKey, keyUpHandler: (_) {
        _appLifecycleListener?.dispose();
        SystemChannels.platform.invokeMethod('SystemNavigator.pop');
      });
    }
  }

  Future<void> _trayInitialization() async {
    if (kIsWeb || Platform.isAndroid || Platform.isIOS) return;

    final icon = Platform.isWindows ? 'assets/icon/tray-icon.ico' : 'assets/icon/tray-icon.png';
    final appVersion = await PackageInfo.fromPlatform();

    trayManager.addListener(this);
    await trayManager.setIcon(icon);

    Menu menu = Menu(
      items: [
        MenuItem(
          key: 'version_label',
          label: 'Solian ${appVersion.version}+${appVersion.buildNumber}',
          disabled: true,
        ),
        MenuItem.separator(),
        MenuItem(
          key: 'exit',
          label: 'trayMenuExit'.tr(),
        ),
      ],
    );
    await trayManager.setContextMenu(menu);
  }

  AppLifecycleListener? _appLifecycleListener;

  @override
  void initState() {
    super.initState();

    if (!kIsWeb && !(Platform.isIOS || Platform.isAndroid)) {
      _appLifecycleListener = AppLifecycleListener(
        onExitRequested: _onExitRequested,
      );
    }

    _trayInitialization();
    _hotkeyInitialization();
    _initialize().then((_) {
      _postInitialization();
      _tryRequestRating();
      _checkForUpdate();
    });
  }

  Future<AppExitResponse> _onExitRequested() async {
    appWindow.hide();
    return AppExitResponse.cancel;
  }

  @override
  void onTrayIconMouseDown() {
    if (Platform.isWindows) {
      context.read<NotificationProvider>().clearTray();
      appWindow.show();
    } else {
      trayManager.popUpContextMenu();
    }
  }

  @override
  void onTrayIconRightMouseDown() {
    if (Platform.isWindows) {
      trayManager.popUpContextMenu();
    } else {
      context.read<NotificationProvider>().clearTray();
      appWindow.show();
    }
  }

  @override
  void onTrayMenuItemClick(MenuItem menuItem) {
    switch (menuItem.key) {
      case 'exit':
        _appLifecycleListener?.dispose();
        SystemChannels.platform.invokeMethod('SystemNavigator.pop');
        break;
    }
  }

  @override
  void dispose() {
    if (!kIsWeb && !(Platform.isAndroid || Platform.isIOS)) {
      trayManager.removeListener(this);
      hotKeyManager.unregisterAll();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cfg = context.read<ConfigProvider>();
    return NotificationListener<SizeChangedLayoutNotification>(
      onNotification: (notification) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          cfg.calcDrawerSize(context);
        });
        return false;
      },
      child: OrientationBuilder(
        builder: (context, orientation) {
          final cfg = context.read<ConfigProvider>();
          WidgetsBinding.instance.addPostFrameCallback((_) {
            cfg.calcDrawerSize(context);
          });
          return SizeChangedLayoutNotifier(
            child: widget.child,
          );
        },
      ),
    );
  }
}
