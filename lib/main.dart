import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:ui';

import 'package:audioplayers/audioplayers.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:croppy/croppy.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:easy_localization_loader/easy_localization_loader.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:relative_time/relative_time.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:surface/firebase_options.dart';
import 'package:surface/logger.dart';
import 'package:surface/providers/channel.dart';
import 'package:surface/providers/chat_call.dart';
import 'package:surface/providers/config.dart';
import 'package:surface/providers/database.dart';
import 'package:surface/providers/keypair.dart';
import 'package:surface/providers/link_preview.dart';
import 'package:surface/providers/navigation.dart';
import 'package:surface/providers/notification.dart';
import 'package:surface/providers/post.dart';
import 'package:surface/providers/relationship.dart';
import 'package:surface/providers/sn_attachment.dart';
import 'package:surface/providers/sn_network.dart';
import 'package:surface/providers/sn_realm.dart';
import 'package:surface/providers/sn_sticker.dart';
import 'package:surface/providers/special_day.dart';
import 'package:surface/providers/theme.dart';
import 'package:surface/providers/translation.dart';
import 'package:surface/providers/user_directory.dart';
import 'package:surface/providers/userinfo.dart';
import 'package:surface/providers/websocket.dart';
import 'package:surface/providers/widget.dart';
import 'package:surface/router.dart';
import 'package:flutter_web_plugins/url_strategy.dart' show usePathUrlStrategy;
import 'package:surface/widgets/dialog.dart';
import 'package:surface/widgets/menu_bar.dart';
import 'package:surface/widgets/navigation/app_scaffold.dart';
import 'package:surface/widgets/version_label.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:version/version.dart';
import 'package:workmanager/workmanager.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:image_picker_android/image_picker_android.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';
import 'package:local_notifier/local_notifier.dart';
import 'package:flutter_animate/flutter_animate.dart';

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

// Desktop size tools

Future<Size> _getSavedWindowSize() async {
  final prefs = await SharedPreferences.getInstance();
  String? sizeString = prefs.getString(kAppWindowSize);

  if (sizeString != null) {
    List<String> parts = sizeString.split('x');
    if (parts.length == 2) {
      double? width = double.tryParse(parts[0]);
      double? height = double.tryParse(parts[1]);
      if (width != null && height != null) {
        return Size(width, height);
      }
    }
  }

  return const Size(1280, 720); // Default size
}

Future<void> _saveWindowSize() async {
  final prefs = await SharedPreferences.getInstance();
  final size = appWindow.size;
  await prefs.setString(kAppWindowSize, '${size.width}x${size.height}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    final Size savedSize = await _getSavedWindowSize();
    doWhenWindowReady(() {
      appWindow.minSize = Size(480, 640);
      appWindow.size = savedSize;
      appWindow.alignment = Alignment.center;
      appWindow.show();
    });
  }

  await EasyLocalization.ensureInitialized();

  if (!kIsWeb && !Platform.isLinux) {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
  }

  GoRouter.optionURLReflectsImperativeAPIs = true;
  usePathUrlStrategy();

  if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
    Workmanager()
        .initialize(appBackgroundDispatcher, isInDebugMode: kDebugMode);
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
    final ImagePickerPlatform imagePickerImplementation =
        ImagePickerPlatform.instance;
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
          Locale('zh', 'HK')
        ],
        fallbackLocale: Locale('en', 'US'),
        useFallbackTranslations: true,
        assetLoader: JsonAssetLoader(),
        child: MultiProvider(
          providers: [
            // Infrastructure layer
            Provider(create: (ctx) => DatabaseProvider(ctx)),

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
            ChangeNotifierProvider(create: (ctx) => SnRealmProvider(ctx)),
            Provider(create: (ctx) => SnPostContentProvider(ctx)),
            Provider(create: (ctx) => SnRelationshipProvider(ctx)),
            Provider(create: (ctx) => SnLinkPreviewProvider(ctx)),
            Provider(create: (ctx) => SnStickerProvider(ctx)),
            ChangeNotifierProvider(create: (ctx) => UserProvider(ctx)),
            ChangeNotifierProvider(create: (ctx) => WebSocketProvider(ctx)),
            Provider(create: (ctx) => KeyPairProvider(ctx)),
            ChangeNotifierProvider(create: (ctx) => NotificationProvider(ctx)),
            ChangeNotifierProvider(create: (ctx) => ChatChannelProvider(ctx)),
            ChangeNotifierProvider(create: (ctx) => ChatCallProvider(ctx)),
            Provider(create: (ctx) => SnTranslator()),

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
  bool _isBusy = false;
  double _initPercentage = 0;
  String _phaseText = 'appInitStarting';

  void _tryRequestRating() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('first_boot_time')) {
      final rawTime = prefs.getString('first_boot_time');
      final time = DateTime.tryParse(rawTime ?? '');
      if (time != null &&
          time.isBefore(DateTime.now().subtract(const Duration(days: 3)))) {
        final inAppReview = InAppReview.instance;
        if (prefs.getBool('rating_requested') == true) return;
        if (await inAppReview.isAvailable()) {
          await inAppReview.requestReview();
          prefs.setBool('rating_requested', true);
        } else {
          logging.error('Unable request app review, unavailable');
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
            receiveTimeout: const Duration(seconds: 60)),
      ).get(
          'https://api.github.com/repos/Solsynth/HyperNet.Surface/releases/latest');
      final remoteVersionString = resp.data?['tag_name'] ?? '0.0.0+0';
      final remoteVersion = Version.parse(remoteVersionString.split('+').first);
      final localVersion = Version.parse(localVersionString.split('+').first);
      final remoteBuildNumber =
          int.tryParse(remoteVersionString.split('+').last) ?? 0;
      final localBuildNumber =
          int.tryParse(localVersionString.split('+').last) ?? 0;
      logging.info(
          "[Update] Local: $localVersionString, Remote: $remoteVersionString");
      if ((remoteVersion > localVersion ||
              remoteBuildNumber > localBuildNumber) &&
          mounted) {
        final config = context.read<ConfigProvider>();
        config.setUpdate(
            remoteVersionString, resp.data?['body'] ?? 'No changelog');
        logging.info("[Update] Update available: $remoteVersionString");
      }
    } catch (e) {
      logging.error('[Error] Unable to check update...', e);
      if (mounted) context.showErrorDialog('Unable to check update: $e');
    }
  }

  void _setPhaseText(String text) {
    _phaseText = 'appInit${text.capitalize()}'.tr();
    if (mounted) setState(() {});
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
      _initPercentage = 0.1;
      _setPhaseText('network');
      final sn = context.read<SnNetworkProvider>();
      await sn.initializeUserAgent();
      await sn.setConfigWithNative();
      if (!mounted) return;
      _initPercentage = 0.2;
      _setPhaseText('userdata');
      final ua = context.read<UserProvider>();
      await ua.initialize();
      if (!mounted) return;
      _initPercentage = 0.3;
      _setPhaseText('websocket');
      final ws = context.read<WebSocketProvider>();
      await ws.tryConnect();
      try {
        if (!mounted) return;
        _initPercentage = 0.9;
        _setPhaseText('keyPair');
        final kp = context.read<KeyPairProvider>();
        kp.reloadActive();
        kp.listen();
      } catch (_) {}
      if (ua.isAuthorized) {
        if (!mounted) return;
        _setPhaseText('notification');
        final notify = context.read<NotificationProvider>();
        notify.listen();
        try {
          notify.registerPushNotifications();
          if (!mounted) return;
          _setPhaseText('stickers');
          final sticker = context.read<SnStickerProvider>();
          await sticker.listSticker();
          if (!mounted) return;
          _setPhaseText('userDirectory');
          final ud = context.read<UserDirectoryProvider>();
          await ud.loadAccountCache();
          if (!mounted) return;
          _setPhaseText('realm');
          final rm = context.read<SnRealmProvider>();
          await rm.refreshAvailableRealms();
          if (!mounted) return;
          _setPhaseText('chat');
          final ct = context.read<ChatChannelProvider>();
          await ct.refreshAvailableChannels();
          _initPercentage = 1;
          _setPhaseText('done');
        } catch (_) {}
        _playIntro();
      }
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
    // The quit key has been removed, and the logic of the quit key is moved to system menu bar activator.
  }

  void _playIntro() async {
    final cfg = context.read<ConfigProvider>();
    if (!cfg.soundEffects) return;

    final player = AudioPlayer(playerId: 'launch-done-player');
    await player.play(
      AssetSource('audio/sfx/launch-done.mp3'),
      volume: 0.8,
      ctx: AudioContext(
        android: AudioContextAndroid(
          contentType: AndroidContentType.sonification,
          usageType: AndroidUsageType.notificationEvent,
        ),
        iOS: AudioContextIOS(category: AVAudioSessionCategory.ambient),
      ),
      mode: PlayerMode.lowLatency,
    );
    player.onPlayerComplete.listen((_) {
      player.dispose();
    });
  }

  final Menu _appTrayMenu = Menu(
    items: [
      MenuItem(key: 'version_label', label: 'Solian', disabled: true),
      MenuItem.separator(),
      MenuItem.checkbox(
          checked: false,
          key: 'mute_notification',
          label: 'trayMenuMuteNotification'.tr()),
      MenuItem.separator(),
      MenuItem(key: 'window_show', label: 'trayMenuShow'.tr()),
      MenuItem(key: 'exit', label: 'trayMenuExit'.tr()),
    ],
  );

  Future<void> _trayInitialization() async {
    if (kIsWeb || Platform.isAndroid || Platform.isIOS) return;

    final icon = Platform.isWindows
        ? 'assets/icon/tray-icon.ico'
        : 'assets/icon/tray-icon.png';
    final appVersion = await PackageInfo.fromPlatform();

    trayManager.addListener(this);
    await trayManager.setIcon(icon);

    _appTrayMenu.items![0] = MenuItem(
      key: 'version_label',
      label: 'Solian ${appVersion.version}+${appVersion.buildNumber}',
      disabled: true,
    );

    await trayManager.setContextMenu(_appTrayMenu);
  }

  Future<void> _notifyInitialization() async {
    if (kIsWeb || Platform.isAndroid || Platform.isIOS) return;

    await localNotifier.setup(
        appName: 'Solian', shortcutPolicy: ShortcutPolicy.requireCreate);
  }

  AppLifecycleListener? _appLifecycleListener;

  @override
  void initState() {
    super.initState();

    _isBusy = true;
    if (!kIsWeb && !(Platform.isIOS || Platform.isAndroid)) {
      _appLifecycleListener =
          AppLifecycleListener(onExitRequested: _onExitRequested);
    }

    try {
      _trayInitialization();
      _hotkeyInitialization();
      _notifyInitialization();
      _initialize().then((_) {
        _postInitialization();
        _tryRequestRating();
        _checkForUpdate();
        setState(() => _isBusy = false);
      }).catchError((err) {
        logging.error('[Bootstrap] Unable to initialize app', err);
        setState(() => _isBusy = false);
      });
    } catch (err) {
      logging.error('[Bootstrap] Unable to initialize (pre-stage) app', err);
    }
  }

  Future<AppExitResponse> _onExitRequested() async {
    appWindow.hide();
    return AppExitResponse.cancel;
  }

  void _quitApp() {
    _saveWindowSize();
    _appLifecycleListener?.dispose();
    if (Platform.isWindows) {
      appWindow.close();
    } else {
      SystemChannels.platform.invokeMethod('SystemNavigator.pop');
    }
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
      case 'mute_notification':
        final nty = context.read<NotificationProvider>();
        nty.isMuted = !nty.isMuted;
        _appTrayMenu.items![2].checked = nty.isMuted;
        trayManager.setContextMenu(_appTrayMenu);
        break;
      case 'window_show':
        // To prevent the window from being hide after just show on macOS
        Timer(const Duration(milliseconds: 100), () => appWindow.show());
        break;
      case 'exit':
        _quitApp();
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
    return AppSystemMenuBar(
      onQuit: _quitApp,
      child: NotificationListener<SizeChangedLayoutNotification>(
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
            Future.delayed(const Duration(milliseconds: 300), () {
              if (context.mounted) {
                cfg.calcDrawerSize(context);
              }
            });
            return SizeChangedLayoutNotifier(
              child: _isBusy
                  ? _AppLoadingScreen(
                      isBusy: _isBusy,
                      initPercentage: _initPercentage,
                      phaseText: _phaseText,
                    )
                  : widget.child,
            );
          },
        ),
      ),
    );
  }
}

class _AppLoadingScreen extends StatelessWidget {
  const _AppLoadingScreen({
    required this.isBusy,
    required this.initPercentage,
    required this.phaseText,
  });

  final bool isBusy;
  final double initPercentage;
  final String phaseText;

  @override
  Widget build(BuildContext context) {
    if (ResponsiveScaffold.getIsExpand(context)) {
      return Material(
        key: Key('app-splash-screen-$isBusy'),
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/icon/kanban-1st.jpg'),
                  fit: BoxFit.cover,
                  opacity: 0.1,
                ),
                color: Theme.of(context).colorScheme.surface,
                backgroundBlendMode: BlendMode.darken,
              ),
            ),
            Center(
              child: Row(
                children: [
                  Expanded(
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: initPercentage),
                      duration: Duration(milliseconds: 300),
                      builder: (context, value, _) => Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${(value * 100).toStringAsFixed(0)}%')
                              .padding(left: 32, bottom: 4),
                          LinearProgressIndicator(
                            value: value,
                            borderRadius: const BorderRadius.all(
                              Radius.circular(0),
                            ),
                            stopIndicatorColor: Colors.transparent,
                            backgroundColor: Colors.transparent,
                          ),
                          const Gap(24),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: initPercentage),
                      duration: Duration(milliseconds: 300),
                      builder: (context, value, _) => Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('${(value * 100).toStringAsFixed(0)}%')
                              .padding(right: 32, bottom: 4),
                          Transform.flip(
                            flipX: true,
                            child: LinearProgressIndicator(
                              value: value,
                              borderRadius: const BorderRadius.all(
                                Radius.circular(0),
                              ),
                              stopIndicatorColor: Colors.transparent,
                              backgroundColor: Colors.transparent,
                            ),
                          ),
                          const Gap(24),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 240, minWidth: 160),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                decoration: BoxDecoration(
                  color:
                      Theme.of(context).colorScheme.surface.withOpacity(0.85),
                  border: Border.all(
                    color: Theme.of(context).dividerColor,
                    width: 3,
                  ),
                  borderRadius: const BorderRadius.all(Radius.circular(12)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'splashScreenServer',
                      style: GoogleFonts.notoSerifHk(height: 1, fontSize: 11),
                      textAlign: TextAlign.center,
                    ).tr().opacity(0.85),
                    Text(
                      'splashScreenServerName',
                      style: GoogleFonts.notoSerifHk(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ).tr().opacity(0.85),
                    Text.rich(
                      TextSpan(
                        text: '#',
                        style: GoogleFonts.notoSerifHk(),
                        children: [
                          TextSpan(
                            text: '0',
                            style: GoogleFonts.notoSerifHk(
                              fontSize: 80,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ).padding(vertical: 16),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: MediaQuery.of(context).size.height * 0.2,
              child: Column(
                children: [
                  Text(
                    phaseText,
                    textAlign: TextAlign.center,
                  ),
                  AnimateWidgetExtensions(Text(
                    'splashScreenCaption',
                    textAlign: TextAlign.center,
                  ).tr())
                      .animate(onPlay: (e) => e.repeat())
                      .fadeIn(duration: 500.ms, curve: Curves.easeOut)
                      .then()
                      .fadeOut(
                        duration: 500.ms,
                        delay: 1000.ms,
                        curve: Curves.easeIn,
                      ),
                ],
              ),
            ),
            Positioned(
              bottom: 8,
              left: 16,
              right: 16,
              child: Row(
                children: [
                  Image.asset(
                    'assets/icon/icon.png',
                    width: 40,
                    height: 40,
                    color: Theme.of(context).colorScheme.onSurface,
                  ).padding(all: 4),
                  const Gap(4),
                  Text('Solar Network').bold(),
                  Expanded(child: const SizedBox()),
                  AppVersionLabel(),
                  const Gap(12),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Material(
      key: Key('app-splash-screen-$isBusy'),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/icon/kanban-1st.jpg'),
                fit: BoxFit.cover,
                opacity: 0.1,
              ),
              color: Theme.of(context).colorScheme.surface,
              backgroundBlendMode: BlendMode.darken,
            ),
          ),
          Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 240),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/icon/icon.png',
                    width: 64,
                    height: 64,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  Text('Solar Network').bold(),
                  AppVersionLabel(),
                  Gap(8),
                  Text(phaseText, textAlign: TextAlign.center),
                  Gap(16),
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: initPercentage),
                    duration: Duration(milliseconds: 300),
                    builder: (context, value, _) =>
                        LinearProgressIndicator(value: value),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
