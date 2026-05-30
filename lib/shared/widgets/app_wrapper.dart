import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:convert';
import 'dart:ui';
import 'package:auto_route/auto_route.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:island/auth/web_auth/auth_request_sheet.dart';
import 'package:island/auth/web_auth/web_auth_server.dart';
import 'package:island/accounts/progression_ws.dart';
import 'package:island/accounts/pods/friend_status_listener.dart';
import 'package:island/accounts/widgets/friend_status_toast.dart';
import 'package:island/core/services/deeplink_service.dart';
import 'package:island/core/services/desktop_presence.dart';
import 'package:island/core/services/quick_actions.dart';
import 'package:island/notifications/notification.dart';
import 'package:island/posts/widgets/compose/compose_dialog.dart';
import 'package:island/route.dart';
import 'package:island/route.gr.dart';
import 'package:island/shared/widgets/app_onboarding_sheet.dart';
import 'package:island/shared/widgets/app_startup_splash.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/shared/widgets/task_overlay.dart';
import 'package:island/thoughts/screens/think_sheet.dart';
import 'package:logging/logging.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:island/activity/activity_rpc.dart';
import 'package:island/core/config.dart';
import 'package:island/core/network.dart';
import 'package:island/core/websocket.dart';
import 'package:island/auth/login_content.dart';
import 'package:island/misc/tray_manager.dart';
import 'package:island/core/services/notify.dart';
import 'package:island/core/services/sharing_intent.dart';
import 'package:island/core/services/update_service.dart';
import 'package:island/core/widgets/content/network_status_sheet.dart';
import 'package:island/core/tour/tour.dart';
import 'package:island/core/services/event_bus.dart';
import 'package:snow_fall_animation/snow_fall_animation.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:window_manager/window_manager.dart';

const kForceShowStartupSplashForTesting = false;
const kOnboardingLastShownVersion = 'app_onboarding_last_shown_version';

final appWrapperKey = GlobalKey();

class ForcedStartupSplashNotifier extends Notifier<bool> {
  @override
  bool build() => kForceShowStartupSplashForTesting;

  void setVisible(bool value) {
    state = value;
  }
}

final forcedStartupSplashProvider =
    NotifierProvider<ForcedStartupSplashNotifier, bool>(
      ForcedStartupSplashNotifier.new,
    );

class AppWrapper extends HookConsumerWidget {
  final Widget child;
  const AppWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final networkStateShowing = useState(false);
    final websocketState = ref.watch(websocketStateProvider);
    final apiState = ref.watch(networkStatusProvider);
    final connectivityStatus = ref.watch(connectivityStatusProvider);
    final hasConnectivity = hasNetworkConnectivityValue(connectivityStatus);
    final token = ref.watch(tokenProvider);
    final forceShowStartupSplash = ref.watch(forcedStartupSplashProvider);
    final isShowSnow = useState(false);
    final isSnowGone = useState(false);
    final bootstrapCompleted = useState(false);
    final startupGateResolved = useState(false);
    final onboardingChecked = useState(false);

    useEffect(() {
      ref.read(progressionWebSocketProvider);
      return null;
    }, []);

    useEffect(() {
      ref.read(friendStatusListenerProvider);
      return null;
    }, []);

    useEffect(() {
      ref.read(desktopPresenceProvider);
      return null;
    }, []);

    useEffect(() {
      ref.read(desktopNowPlayingProvider);
      return null;
    }, []);

    useEffect(() {
      bool triedOpen = false;
      if (!hasConnectivity && !networkStateShowing.value && !triedOpen) {
        networkStateShowing.value = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final ctx = ref.read(routerProvider).navigatorKey.currentContext!;
          showModalBottomSheet(
            context: ctx,
            isScrollControlled: true,
            builder: (context) => const NetworkStatusSheet(),
          ).then((_) => networkStateShowing.value = false);
        });
        triedOpen = true;
      }

      if (websocketState == WebSocketState.duplicateDevice() &&
          !networkStateShowing.value &&
          !triedOpen) {
        networkStateShowing.value = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final ctx = ref.read(routerProvider).navigatorKey.currentContext!;
          showModalBottomSheet(
            context: ctx,
            isScrollControlled: true,
            builder: (context) => NetworkStatusSheet(autoClose: true),
          ).then((_) => networkStateShowing.value = false);
        });
        triedOpen = true;
      }

      if (hasConnectivity &&
          apiState != NetworkStatus.online &&
          !networkStateShowing.value &&
          !triedOpen) {
        networkStateShowing.value = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final ctx = ref.read(routerProvider).navigatorKey.currentContext!;
          showModalBottomSheet(
            context: ctx,
            isScrollControlled: true,
            builder: (context) => const NetworkStatusSheet(),
          ).then((_) => networkStateShowing.value = false);
        });
        triedOpen = true;
      }
      return null;
    }, [websocketState, apiState, hasConnectivity]);

    useEffect(() {
      if (!hasConnectivity) {
        Future.microtask(() {
          ref.read(networkStatusProvider.notifier).setOffline();
        });
        return null;
      }

      if (token == null) return null;
      final shouldReconnect = websocketState.maybeWhen(
        disconnected: () => true,
        serverDown: () => true,
        error: (_) => true,
        orElse: () => false,
      );
      if (shouldReconnect) {
        Future(() => ref.read(websocketStateProvider.notifier).connect());
      }
      return null;
    }, [hasConnectivity, token, websocketState]);

    // TODO reenable this till the python service is stable
    // useEffect(() {
    //   if (!kIsWeb) {
    //     Future(() async {
    //       await python.initPython();
    //       if (python.isPythonAvailable()) {
    //         Logger.root.info("[pocketpy] Initialized from AppWrapper");
    //       } else {
    //         Logger.root.info(
    //           "[pocketpy] Not available (folder missing or init failed)",
    //         );
    //       }
    //     });
    //   }
    //   return null;
    // }, []);

    useEffect(() {
      final ntySubs = setupNotificationListener(context, ref);
      final sharingService = SharingIntentService();
      final deeplinkService = DeeplinkService();
      sharingService.setWidgetRef(ref);
      sharingService.initialize();
      deeplinkService.initialize(
        onDeepLink: (uri) {
          void handleWhenReady([int retry = 0]) {
            final ctx = ref.read(routerProvider).navigatorKey.currentContext;
            if (ctx != null && ctx.mounted) {
              _handleDeepLink(uri, ref, ctx);
              return;
            }
            if (retry >= 16) return;
            Future.delayed(const Duration(milliseconds: 250), () {
              handleWhenReady(retry + 1);
            });
          }

          handleWhenReady();
        },
      );
      UpdateService().checkForUpdates(context);

      void checkPendingShare([int retry = 0]) {
        final ctx = ref.read(routerProvider).navigatorKey.currentContext;
        if (ctx != null && ctx.mounted) {
          sharingService.checkAndShowShareSheet();
          return;
        }
        if (retry >= 16) return;
        Future.delayed(const Duration(milliseconds: 250), () {
          checkPendingShare(retry + 1);
        });
      }

      checkPendingShare();

      final trayService = TrayService.instance;
      trayService.initialize(
        _TrayListenerImpl(
          onTrayIconMouseDown: () => windowManager.show(),
          onTrayIconRightMouseUp: () => trayManager.popUpContextMenu(),
          onTrayMenuItemClick: (menuItem) => trayService.handleAction(menuItem),
        ),
      );

      ref.read(rpcServerStateProvider.notifier).start();
      ref.read(webAuthServerStateProvider.notifier).start();

      final composeSheetSubs = eventBus.on<ShowComposeSheetEvent>().listen((
        event,
      ) {
        final ctx = ref.read(routerProvider).navigatorKey.currentContext!;
        if (ctx.mounted) _showPostCompose(ctx);
      });

      final notificationSheetSubs = eventBus
          .on<ShowNotificationSheetEvent>()
          .listen((event) {
            final ctx = ref.read(routerProvider).navigatorKey.currentContext!;
            if (ctx.mounted) _showNotificationSheet(ctx);
          });

      final thoughtSheetSubs = eventBus.on<ShowThoughtSheetEvent>().listen((
        event,
      ) {
        final ctx = ref.read(routerProvider).navigatorKey.currentContext!;
        if (ctx.mounted) _showThoughtSheet(ctx, event);
      });

      final webAuthSubs = eventBus.on<WebAuthRequestEvent>().listen((event) {
        final ctx = ref.read(routerProvider).navigatorKey.currentContext!;
        if (ctx.mounted) _showWebAuthSheet(ctx, event);
      });

      return () {
        ref.read(rpcServerProvider).stop();
        deeplinkService.dispose();
        trayService.dispose(
          _TrayListenerImpl(
            onTrayIconMouseDown: () => {},
            onTrayIconRightMouseUp: () => {},
            onTrayMenuItemClick: (menuItem) => {},
          ),
        );
        ntySubs?.cancel();
        composeSheetSubs.cancel();
        notificationSheetSubs.cancel();
        thoughtSheetSubs.cancel();
        webAuthSubs.cancel();
      };
    }, []);

    final settings = ref.watch(appSettingsProvider);
    final settingsNotifier = ref.watch(appSettingsProvider.notifier);

    useEffect(() {
      if (settings.defaultScreen != null &&
          settings.defaultScreen != 'dashboard') {
        Future(() {
          ref.read(routerProvider).navigatePath('/${settings.defaultScreen!}');
        });
      }
      return null;
    }, []);

    final now = DateTime.now();
    final doesShowSnow =
        settings.festivalFeatures &&
        now.month == 12 &&
        (now.day >= 22 && now.day <= 28);
    final shouldRunBootstrap = token != null && !bootstrapCompleted.value;
    final shouldShowStartupSplash =
        !startupGateResolved.value ||
        forceShowStartupSplash ||
        shouldRunBootstrap;

    useEffect(() {
      Future.microtask(() {
        startupGateResolved.value = true;
      });
      return null;
    }, []);

    useEffect(() {
      Future(() {
        final now = DateTime.now();
        if (doesShowSnow) {
          isShowSnow.value = true;
          Future.delayed(const Duration(seconds: 60), () {
            if (!context.mounted) return;
            isShowSnow.value = false;
            Future.delayed(const Duration(seconds: 3), () {
              if (!context.mounted) return;
              isSnowGone.value = true;
            });
          });
        }

        if (settings.firstLaunchAt == null) {
          settingsNotifier.setFirstLaunchAt(now.toIso8601String());
        } else if (!settings.askedReview) {
          final launchAt = DateTime.parse(settings.firstLaunchAt!);
          final daysSinceFirstLaunch = now.difference(launchAt).inDays;
          if (daysSinceFirstLaunch >= 3 &&
              !kIsWeb &&
              (Platform.isAndroid || Platform.isIOS || Platform.isMacOS)) {
            final InAppReview inAppReview = InAppReview.instance;
            Future(() async {
              if (await inAppReview.isAvailable()) {
                inAppReview.requestReview();
              }
            });
            settingsNotifier.setAskedReview(true);
          }
        }
      });

      return null;
    }, []);

    useEffect(() {
      Future(() async {
        try {
          Logger.root.info(
            "[QuickActions] Initializing Quick Actions service...",
          );
          final quickActionsService = QuickActionsService();
          await quickActionsService.initialize(ref);
          Logger.root.info("[QuickActions] Quick Actions service is ready!");
        } catch (err) {
          Logger.root.severe(
            "[QuickActions] Failed to initialize Quick Actions service...",
            err,
          );
        }
      });
      return null;
    }, []);

    useEffect(() {
      if (shouldShowStartupSplash || onboardingChecked.value) return null;

      Future(() async {
        final prefs = ref.read(sharedPreferencesProvider);
        final packageInfo = await PackageInfo.fromPlatform();
        final currentVersion =
            '${packageInfo.version}+${packageInfo.buildNumber}';
        final lastShownVersion = prefs.getString(kOnboardingLastShownVersion);
        final shouldShowOnboarding =
            lastShownVersion == null || lastShownVersion != currentVersion;

        onboardingChecked.value = true;
        if (!shouldShowOnboarding) return;

        WidgetsBinding.instance.addPostFrameCallback((_) async {
          final ctx = ref.read(routerProvider).navigatorKey.currentContext;
          if (ctx == null || !ctx.mounted) return;

          await showAppOnboardingSheet(
            ctx,
            version: packageInfo.version,
            isFirstLaunch: lastShownVersion == null,
            suggestAuth: token == null,
          );
          await prefs.setString(kOnboardingLastShownVersion, currentVersion);
        });
      });
      return null;
    }, [shouldShowStartupSplash, token]);

    return Container(
      key: appWrapperKey,
      child: TourTriggerWidget(
        key: const Key("app_tour_trigger"),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          reverseDuration: const Duration(milliseconds: 500),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeOut,
          transitionBuilder: (widget, animation) {
            return FadeTransition(opacity: animation, child: widget);
          },
          child: shouldShowStartupSplash
              ? KeyedSubtree(
                  key: ValueKey('bootstrap_splash'),
                   child: StartupSplashScreen(
                     runBootstrap: shouldRunBootstrap,
                     onCompleted: () {
                       ref
                           .read(forcedStartupSplashProvider.notifier)
                           .setVisible(false);
                        bootstrapCompleted.value = true;
                      },
                    ),
                )
               : KeyedSubtree(
                   key: const ValueKey('main_content'),
                   child: Stack(
                     children: [
                      _AppWrapperBackdrop(child: child),
                       if (doesShowSnow && !isSnowGone.value)
                         IgnorePointer(
                           child: AnimatedOpacity(
                            opacity: isShowSnow.value ? 1 : 00,
                            duration: const Duration(seconds: 3),
                            child: SnowFallAnimation(
                              key: const Key("app_snow_animation"),
                              config: SnowfallConfig(
                                numberOfSnowflakes: 50,
                                speed: 1.0,
                              ),
                            ),
                          ),
                        ),
                      const TaskOverlay(),
                      const FriendStatusToastOverlay(),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  void _showPostCompose(BuildContext context) {
    PostComposeDialog.show(context);
  }

  void _showNotificationSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      builder: (context) => const NotificationSheet(),
    );
  }

  void _showThoughtSheet(BuildContext context, ShowThoughtSheetEvent event) {
    ThoughtSheet.show(
      context,
      initialMessage: event.initialMessage,
      attachedMessages: event.attachedMessages,
      attachedPosts: event.attachedPosts,
    );
  }

  void _showWebAuthSheet(BuildContext context, WebAuthRequestEvent event) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      useSafeArea: true,
      isDismissible: false,
      enableDrag: false,
      builder: (context) => AuthRequestSheet(
        app: event.app,
        onAllow: () {
          Navigator.pop(context);
          event.completer.complete(_generateWebAuthChallenge());
        },
        onDeny: () {
          Navigator.pop(context);
          event.completer.complete(null);
        },
      ),
    );
  }

  String _generateWebAuthChallenge() {
    final random = Random.secure();
    final values = List<int>.generate(32, (i) => random.nextInt(256));
    return base64Url.encode(values);
  }

  void _handleDeepLink(Uri uri, WidgetRef ref, BuildContext context) async {
    String path = '/${uri.host}${uri.path}';

    if (path == '/auth/web') {
      await _handleProtocolWebAuth(uri, ref, context);
      return;
    }

    if (path == '/auth/callback' && uri.queryParameters.containsKey('token')) {
      final token = uri.queryParameters['token']!;
      setToken(ref.read(sharedPreferencesProvider), token);
      ref.invalidate(tokenProvider);

      await performPostLogin(context, ref);

      if (!kIsWeb &&
          (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
        windowManager.show();
      }
      return;
    }

    if (path == '/share') {
      if (!kIsWeb &&
          (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
        windowManager.show();
      }
      return;
    }

    if (path == '/notifications') {
      eventBus.fire(ShowNotificationSheetEvent());
      return;
    }

    if (path.startsWith('/phpass/')) {
      final tagId = path.substring('/phpass/'.length);
      if (tagId.isNotEmpty) {
        context.router.navigate(PhysicalPassportRoute());
        return;
      }
    }

    if (path == '/dashboard') {
      context.router.navigate(const DashboardRoute());
      return;
    }

    final bottomNavRoutes = ['/', '/explore', '/chat', '/realms', '/account'];
    if (bottomNavRoutes.contains(path)) {
      context.router.navigatePath(path);
      if (!kIsWeb &&
          (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
        windowManager.show();
      }
      return;
    }

    if (uri.queryParameters.isNotEmpty) {
      path = Uri.parse(
        path,
      ).replace(queryParameters: uri.queryParameters).toString();
    }
    context.router.navigatePath(path);
    if (!kIsWeb &&
        (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      windowManager.show();
    }
  }

  Future<void> _handleProtocolWebAuth(
    Uri uri,
    WidgetRef ref,
    BuildContext context,
  ) async {
    final redirectUriRaw = uri.queryParameters['redirect_uri'];
    final redirectUri = redirectUriRaw == null
        ? null
        : Uri.tryParse(redirectUriRaw);
    final state = uri.queryParameters['state'];

    if (redirectUri == null || !redirectUri.hasScheme) {
      await _showWebAuthError(
        context,
        'Invalid web auth request: missing or invalid redirect_uri.',
      );
      return;
    }

    final appName = uri.queryParameters['app'] ?? 'Unknown App';
    final signedChallenge = uri.queryParameters['signed_challenge'];
    final secretId = uri.queryParameters['secret_id'];

    int? port = ref.read(webAuthServerStateProvider).port;
    port ??= await ref.read(webAuthServerProvider).start();

    final client = Dio();
    try {
      if (signedChallenge == null || signedChallenge.isEmpty) {
        final response = await client.get(
          'http://127.0.0.1:$port/alive',
          queryParameters: {'app': appName},
        );
        final data = Map<String, dynamic>.from(response.data as Map);
        final status = data['status'] as String?;

        if (status == 'ok' && data['challenge'] is String) {
          await _launchWebAuthRedirect(
            redirectUri: redirectUri,
            state: state,
            payload: {'status': 'ok', 'challenge': data['challenge'] as String},
          );
          return;
        }

        if (status == 'denied') {
          await _launchWebAuthRedirect(
            redirectUri: redirectUri,
            state: state,
            payload: {'status': 'denied'},
          );
          return;
        }

        await _launchWebAuthRedirect(
          redirectUri: redirectUri,
          state: state,
          payload: {'status': 'error', 'error': 'invalid_alive_response'},
        );
        return;
      }

      final response = await client.post(
        'http://127.0.0.1:$port/exchange',
        data: jsonEncode({
          'signed_challenge': signedChallenge,
          if (secretId != null && secretId.isNotEmpty) 'secret_id': secretId,
        }),
      );
      final data = Map<String, dynamic>.from(response.data as Map);

      if (data['token'] is String && (data['token'] as String).isNotEmpty) {
        final payload = <String, String>{
          'status': 'success',
          'token': data['token'] as String,
        };
        if (data['refresh_token'] is String &&
            (data['refresh_token'] as String).isNotEmpty) {
          payload['refresh_token'] = data['refresh_token'] as String;
        }
        if (data['expires_in'] != null) {
          payload['expires_in'] = data['expires_in'].toString();
        }
        if (data['refresh_expires_in'] != null) {
          payload['refresh_expires_in'] = data['refresh_expires_in'].toString();
        }
        await _launchWebAuthRedirect(
          redirectUri: redirectUri,
          state: state,
          payload: payload,
        );
        return;
      }

      await _launchWebAuthRedirect(
        redirectUri: redirectUri,
        state: state,
        payload: {
          'status': 'error',
          'error': (data['error']?.toString() ?? 'exchange_failed'),
        },
      );
    } on DioException catch (e) {
      final error =
          (e.response?.data is Map &&
              (e.response!.data as Map).containsKey('error'))
          ? (e.response!.data['error']?.toString() ?? 'exchange_failed')
          : (e.message ?? 'exchange_failed');
      await _launchWebAuthRedirect(
        redirectUri: redirectUri,
        state: state,
        payload: {'status': 'error', 'error': error},
      );
    } catch (_) {
      await _launchWebAuthRedirect(
        redirectUri: redirectUri,
        state: state,
        payload: {'status': 'error', 'error': 'unexpected_error'},
      );
    } finally {
      client.close();
    }
  }

  Future<void> _showWebAuthError(BuildContext context, String message) async {
    showInfoAlert(message, 'App Connect Request Invalid', icon: Symbols.error);
  }

  Future<void> _launchWebAuthRedirect({
    required Uri redirectUri,
    String? state,
    required Map<String, String> payload,
  }) async {
    final queryParams = Map<String, String>.from(redirectUri.queryParameters);
    if (state != null && state.isNotEmpty) {
      queryParams['state'] = state;
    }
    queryParams.addAll(payload);
    final target = redirectUri.replace(queryParameters: queryParams).toString();
    await launchUrlString(target, mode: LaunchMode.externalApplication);
  }
}

class _AppWrapperBackdrop extends StatelessWidget {
  final Widget child;

  const _AppWrapperBackdrop({required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                scheme.surface,
                Color.lerp(
                  scheme.surface,
                  scheme.surfaceContainerHighest,
                  isDark ? 0.65 : 0.85,
                )!,
                Color.lerp(
                  scheme.surface,
                  scheme.primary.withOpacity(isDark ? 0.14 : 0.08),
                  0.5,
                )!,
              ],
              stops: const [0, 0.55, 1],
            ),
          ),
        ),
        const Positioned(
          top: -120,
          left: -80,
          child: _BackdropOrb(size: 280, alignment: Alignment.topLeft),
        ),
        const Positioned(
          right: -110,
          top: 90,
          child: _BackdropOrb(size: 240, alignment: Alignment.topRight),
        ),
        const Positioned(
          left: 24,
          bottom: -140,
          child: _BackdropOrb(size: 320, alignment: Alignment.bottomLeft),
        ),
        Positioned.fill(
          child: IgnorePointer(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 36, sigmaY: 36),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: scheme.surface.withOpacity(isDark ? 0.18 : 0.08),
                ),
              ),
            ),
          ),
        ),
        child,
      ],
    );
  }
}

class _BackdropOrb extends StatelessWidget {
  final double size;
  final Alignment alignment;

  const _BackdropOrb({required this.size, required this.alignment});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final primary = scheme.primary.withOpacity(0.18);
    final tertiary = scheme.tertiary.withOpacity(0.12);

    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            center: alignment,
            radius: 1,
            colors: [primary, tertiary, Colors.transparent],
            stops: const [0, 0.55, 1],
          ),
        ),
      ),
    );
  }
}

class _TrayListenerImpl implements TrayListener {
  final VoidCallback _primaryAction;
  final VoidCallback _secondaryAction;
  final void Function(MenuItem) _onTrayMenuItemClick;

  _TrayListenerImpl({
    required VoidCallback onTrayIconMouseDown,
    required VoidCallback onTrayIconRightMouseUp,
    required void Function(MenuItem) onTrayMenuItemClick,
  }) : _primaryAction = onTrayIconMouseDown,
       _secondaryAction = onTrayIconRightMouseUp,
       _onTrayMenuItemClick = onTrayMenuItemClick;

  @override
  void onTrayIconMouseDown() => _primaryAction();

  @override
  void onTrayIconRightMouseUp() => _secondaryAction();

  @override
  void onTrayIconMouseUp() => _primaryAction();

  @override
  void onTrayIconRightMouseDown() => _secondaryAction();

  @override
  void onTrayMenuItemClick(MenuItem menuItem) => _onTrayMenuItemClick(menuItem);
}
