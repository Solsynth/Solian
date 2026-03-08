import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:convert';
import 'package:auto_route/auto_route.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:island/accounts/account_pod.dart';
import 'package:island/auth/web_auth/auth_request_sheet.dart';
import 'package:island/auth/web_auth/web_auth_server.dart';
import 'package:island/notifications/notification.dart';
import 'package:island/posts/widgets/compose/compose_dialog.dart';
import 'package:island/route.dart';
import 'package:island/route.gr.dart';
import 'package:island/thoughts/screens/think_sheet.dart';
import 'package:protocol_handler/protocol_handler.dart';
import 'package:island/activity/activity_rpc.dart';
import 'package:island/core/audio.dart';
import 'package:island/core/config.dart';
import 'package:island/core/network.dart';
import 'package:island/core/websocket.dart';
import 'package:island/auth/login_content.dart';
import 'package:island/settings/tray_manager.dart';
import 'package:island/core/services/notify.dart';
import 'package:island/core/services/sharing_intent.dart';
import 'package:island/core/services/update_service.dart';
import 'package:island/core/widgets/content/network_status_sheet.dart';
import 'package:island/core/tour/tour.dart';
import 'package:island/core/services/event_bus.dart';
import 'package:snow_fall_animation/snow_fall_animation.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';

const kForceShowStartupSplashForTesting = false;
const kBootstrapRetryTimeouts = <Duration>[
  Duration(milliseconds: 1000),
  Duration(seconds: 2),
  Duration(seconds: 3),
];

class AppWrapper extends HookConsumerWidget {
  final Widget child;
  const AppWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final networkStateShowing = useState(false);
    final websocketState = ref.watch(websocketStateProvider);
    final apiState = ref.watch(networkStatusProvider);
    final token = ref.watch(tokenProvider);
    final isShowSnow = useState(false);
    final isSnowGone = useState(false);
    final bootstrapCompleted = useState(false);
    final startupGateResolved = useState(false);

    // Handle network status modal
    useEffect(() {
      bool triedOpen = false;
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

      if (apiState != NetworkStatus.online &&
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
    }, [websocketState, apiState]);

    // Initialize services and listeners
    useEffect(() {
      final ntySubs = setupNotificationListener(context, ref);
      final sharingService = SharingIntentService();
      sharingService.initialize(context);
      UpdateService().checkForUpdates(context);

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

      // Listen to special action events
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

      // Web auth request listener
      final webAuthSubs = eventBus.on<WebAuthRequestEvent>().listen((event) {
        final ctx = ref.read(routerProvider).navigatorKey.currentContext!;
        if (ctx.mounted) _showWebAuthSheet(ctx, event);
      });

      // Protocol handler listener - only for desktop platforms
      // protocol_handler plugin is only available and implemented on desktop (Linux, macOS, Windows)
      ProtocolListener? protocolListener;
      if (!kIsWeb &&
          (Platform.isLinux || Platform.isMacOS || Platform.isWindows)) {
        protocolListener = _ProtocolListenerImpl(
          onProtocolUrlReceived: (url) {
            final ctx = ref.read(routerProvider).navigatorKey.currentContext!;
            _handleDeepLink(Uri.parse(url), ref, ctx);
          },
        );
        protocolHandler.addListener(protocolListener);

        // Handle initial URL
        protocolHandler.getInitialUrl().then((initialUrl) {
          if (initialUrl != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              final ctx = ref.read(routerProvider).navigatorKey.currentContext!;
              _handleDeepLink(Uri.parse(initialUrl), ref, ctx);
            });
          }
        });
      }

      return () {
        // Clean up protocol handler listener only on desktop
        if (!kIsWeb &&
            (Platform.isLinux || Platform.isMacOS || Platform.isWindows)) {
          if (protocolListener != null) {
            protocolHandler.removeListener(protocolListener);
          }
        }
        ref.read(rpcServerProvider).stop();
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
        kForceShowStartupSplashForTesting ||
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

    return TourTriggerWidget(
      key: const Key("app_tour_trigger"),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        reverseDuration: const Duration(milliseconds: 500),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeOut,
        layoutBuilder: (currentChild, previousChildren) {
          return Stack(
            fit: StackFit.expand,
            children: [
              ...previousChildren,
              if (currentChild != null) currentChild,
            ],
          );
        },
        transitionBuilder: (widget, animation) {
          return FadeTransition(opacity: animation, child: widget);
        },
        child: shouldShowStartupSplash
            ? KeyedSubtree(
                key: ValueKey('bootstrap_splash'),
                child: _StartupSplashScreen(
                  runBootstrap: shouldRunBootstrap,
                  onCompleted: () {
                    bootstrapCompleted.value = true;
                  },
                ),
              )
            : KeyedSubtree(
                key: const ValueKey('main_content'),
                child: Stack(
                  children: [
                    child,
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
                  ],
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
      isDismissible: false,
      enableDrag: false,
      builder: (context) => AuthRequestSheet(
        appName: event.appName,
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

    // Special handling for OIDC auth callback
    if (path == '/auth/callback' && uri.queryParameters.containsKey('token')) {
      final token = uri.queryParameters['token']!;
      setToken(ref.read(sharedPreferencesProvider), token);
      ref.invalidate(tokenProvider);

      // Do post login tasks
      await performPostLogin(context, ref);

      if (!kIsWeb &&
          (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
        windowManager.show();
      }
      return;
    }

    // Special handling for share intent deep links
    // Share intents are handled by SharingIntentService showing a modal,
    // not by routing to a page
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

    // final router = ref.read(routerProvider);
    if (path == '/dashboard') {
      context.router.navigate(const DashboardRoute());
      return;
    }

    // Handle bottom navigation routes properly to prevent navigation bar disappearance
    // These routes should navigate within the bottom navigation shell
    final bottomNavRoutes = ['/', '/explore', '/chat', '/realms', '/account'];
    if (bottomNavRoutes.contains(path)) {
      // Navigate within the bottom navigation shell using go() to maintain shell context
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
    // For non-bottom navigation routes, use push() to navigate outside the shell
    context.router.navigatePath(path);
    if (!kIsWeb &&
        (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      windowManager.show();
    }
  }
}

class _StartupSplashScreen extends HookConsumerWidget {
  final bool runBootstrap;
  final VoidCallback onCompleted;

  const _StartupSplashScreen({
    required this.runBootstrap,
    required this.onCompleted,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Future<void> runWithTimeoutRetries({
      required Future<void> Function(Duration timeout) action,
      required String stageLabel,
      required ValueNotifier<String?> subtitle,
      List<Duration> timeouts = kBootstrapRetryTimeouts,
    }) async {
      Object? lastError;
      StackTrace? lastStackTrace;
      for (var idx = 0; idx < timeouts.length; idx++) {
        final timeout = timeouts[idx];
        try {
          await action(timeout);
          return;
        } catch (error, stackTrace) {
          lastError = error;
          lastStackTrace = stackTrace;
          subtitle.value =
              '$stageLabel retry ${idx + 1}/${timeouts.length} failed.';
        }
      }
      if (lastError != null && lastStackTrace != null) {
        Error.throwWithStackTrace(lastError, lastStackTrace);
      }
    }

    final subtitle = useState<String?>(null);
    final stages = useMemoized(
      () => <_BootstrapStage>[
        _BootstrapStage(
          label: 'Checking service health',
          isCritical: true,
          action: () async {
            await runWithTimeoutRetries(
              stageLabel: 'Health check',
              subtitle: subtitle,
              action: (timeout) async {
                final apiClient = ref.read(apiClientProvider);
                final response = await apiClient.get(
                  '/health',
                  options: Options(
                    validateStatus: (_) => true,
                    connectTimeout: timeout,
                    sendTimeout: timeout,
                    receiveTimeout: timeout,
                  ),
                );
                final code = response.statusCode ?? 0;
                if (code != 200) {
                  throw DioException(
                    requestOptions: response.requestOptions,
                    response: response,
                    error: 'Health check failed with status $code',
                  );
                }
              },
            );
          },
        ),
        _BootstrapStage(
          label: 'Loading account profile',
          isCritical: true,
          action: () async {
            await ref
                .read(userInfoProvider.notifier)
                .fetchUserForBootstrap(retryTimeouts: kBootstrapRetryTimeouts);
          },
        ),
        _BootstrapStage(
          label: 'Connecting realtime gateway',
          isCritical: true,
          action: () async {
            ref.read(websocketStateProvider.notifier).connect();
          },
        ),
        _BootstrapStage(
          label: 'Registering push notifications',
          isCritical: false,
          action: () async {
            final user = await ref.read(userInfoProvider.future);
            if (user == null) return;
            final apiClient = ref.read(apiClientProvider);
            await subscribePushNotification(apiClient);
          },
        ),
        _BootstrapStage(
          label: 'Preparing local notifications',
          isCritical: false,
          action: () async {
            await initializeLocalNotifications();
          },
        ),
        _BootstrapStage(
          label: 'Preparing audio assets',
          isCritical: false,
          action: () async {
            await ref.read(audioSessionProvider.future);
            await ref.read(notificationSfxProvider.future);
            await ref.read(messageSfxProvider.future);
          },
        ),
      ],
      [],
    );

    final isBusy = useState(true);
    final isErrored = useState(false);
    final isDismissable = useState(true);
    final periodCursor = useState(0);
    final showSkip = useState(false);
    final isCurrentStageSkippable = useState(false);
    final phaseNonce = useRef(0);
    final skipCompleterRef = useRef<Completer<void>?>(null);
    final warnings = useState<List<String>>([]);
    final unFocusColor = Theme.of(
      context,
    ).colorScheme.onSurface.withValues(alpha: 0.75);

    Future<void> runStages() async {
      final phase = ++phaseNonce.value;
      isBusy.value = true;
      isErrored.value = false;
      isDismissable.value = true;
      subtitle.value = null;
      showSkip.value = false;
      warnings.value = [];

      for (var idx = 0; idx < stages.length; idx++) {
        if (phaseNonce.value != phase) return;
        final stage = stages[idx];
        periodCursor.value = idx;
        isCurrentStageSkippable.value = !stage.isCritical;
        skipCompleterRef.value = Completer<void>();
        showSkip.value = false;

        Timer? skipTimer;
        if (!stage.isCritical) {
          skipTimer = Timer(const Duration(milliseconds: 500), () {
            if (phaseNonce.value == phase && isBusy.value) {
              showSkip.value = true;
            }
          });
        }

        try {
          if (stage.isCritical) {
            await stage.action();
          } else {
            await Future.any([stage.action(), skipCompleterRef.value!.future]);
            if (skipCompleterRef.value!.isCompleted) {
              subtitle.value = 'Skipped optional stage: ${stage.label}';
            }
          }
        } catch (e) {
          final warning = 'Skipped "${stage.label}" after retries.';
          warnings.value = [...warnings.value, warning];
          subtitle.value = '$warning App may have limited functionality.';
        } finally {
          skipTimer?.cancel();
          showSkip.value = false;
          skipCompleterRef.value = null;
        }
      }

      if (phaseNonce.value != phase) return;
      isBusy.value = false;
      if (warnings.value.isEmpty) {
        if (runBootstrap) onCompleted();
      } else {
        isErrored.value = true;
        isDismissable.value = true;
        subtitle.value =
            '${warnings.value.length} startup stage(s) were skipped due to network issues. Tap to continue.';
      }
    }

    useEffect(() {
      if (!runBootstrap) {
        isBusy.value = false;
        subtitle.value = null;
        return null;
      }
      Future(() => runStages());
      return () {
        phaseNonce.value++;
      };
    }, [runBootstrap]);

    return ColoredBox(
      color: Theme.of(context).colorScheme.surface,
      child: GestureDetector(
        onTap: () {
          if (isBusy.value) return;
          if (isDismissable.value) {
            if (runBootstrap) {
              onCompleted();
            }
          } else {
            Future(() => runStages());
          }
        },
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            SizedBox(
              height: 280,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(16)),
                  child: Image.asset(
                    'assets/icons/icon.png',
                    width: 80,
                    height: 80,
                  ),
                ),
              ),
            ),
            Column(
              children: [
                if (isErrored.value && !isDismissable.value && !isBusy.value)
                  const Icon(Icons.cancel, size: 24),
                if (isErrored.value && isDismissable.value && !isBusy.value)
                  const Icon(Icons.warning, size: 24),
                if ((isErrored.value && isDismissable.value && isBusy.value) ||
                    isBusy.value)
                  const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 3),
                  ),
                if (!isBusy.value && !isErrored.value)
                  const Icon(Icons.check_circle, size: 24, color: Colors.green),
                const SizedBox(height: 12),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 280),
                  child: Column(
                    children: [
                      if (subtitle.value == null)
                        Text(
                          '${stages[periodCursor.value].label} (${periodCursor.value + 1}/${stages.length})',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 13, color: unFocusColor),
                        ),
                      if (subtitle.value != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            subtitle.value!,
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 13, color: unFocusColor),
                          ),
                        ),
                      if (!isBusy.value &&
                          isErrored.value &&
                          isDismissable.value)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 5),
                          child: Text(
                            'Tap anywhere to dismiss',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 13, color: unFocusColor),
                          ),
                        ),
                      if (isBusy.value &&
                          isCurrentStageSkippable.value &&
                          showSkip.value)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: TextButton(
                            onPressed: () {
                              if (skipCompleterRef.value?.isCompleted ==
                                  false) {
                                skipCompleterRef.value?.complete();
                              }
                            },
                            child: const Text('Skip optional stage'),
                          ),
                        ),
                      Text(
                        '${DateTime.now().year} © Solsynth LLC',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 11, color: unFocusColor),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BootstrapStage {
  final String label;
  final bool isCritical;
  final Future<void> Function() action;

  const _BootstrapStage({
    required this.label,
    required this.isCritical,
    required this.action,
  });
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

class _ProtocolListenerImpl implements ProtocolListener {
  final void Function(String) _onProtocolUrlReceived;

  _ProtocolListenerImpl({required void Function(String) onProtocolUrlReceived})
    : _onProtocolUrlReceived = onProtocolUrlReceived;

  @override
  void onProtocolUrlReceived(String url) => _onProtocolUrlReceived(url);
}
