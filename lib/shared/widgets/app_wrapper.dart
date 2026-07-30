import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:convert';
import 'dart:ui';
import 'package:auto_route/auto_route.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:island/auth/web_auth/auth_request_sheet.dart';
import 'package:island/auth/web_auth/web_auth_server.dart';
import 'package:island/auth/challenge_approval_sheet.dart';
import 'package:island/auth/challenge_ws_listener.dart';
import 'package:island/accounts/progression_ws.dart';
import 'package:island/accounts/pods/friend_status_listener.dart';
import 'package:island/accounts/screens/me/account_qr.dart';
import 'package:island/core/lifecycle.dart';
import 'package:island/core/services/deeplink_service.dart';
import 'package:island/core/services/desktop_presence.dart';
import 'package:island/core/services/quick_actions.dart';
import 'package:island/chat/pods/native_call_bridge.dart';
import 'package:island/chat/pods/call.dart';
import 'package:island/chat/widgets/incoming_call_invite_sheet.dart';
import 'package:island/chat/widgets/call_overlay.dart';
import 'package:island/chat/widgets/call_window.dart';
import 'package:island/chat/widgets/pending_join_sheet.dart';
import 'package:island/notifications/notification.dart';
import 'package:island/posts/widgets/compose/compose_dialog.dart';
import 'package:island/payments/payment_overlay.dart';
import 'package:island/route.dart';
import 'package:island/route.gr.dart';
import 'package:island/shared/widgets/app_onboarding_sheet.dart';
import 'package:island/shared/widgets/app_startup_splash.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/shared/widgets/attention_modal.dart';
import 'package:island/thoughts/screens/think_sheet.dart';
import 'package:island/wallets/wallet.dart';
import 'package:logging/logging.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:island/activity/activity_rpc.dart';
import 'package:island/core/audio.dart';
import 'package:island/core/config.dart';
import 'package:island/core/network.dart';
import 'package:island/core/websocket.dart';
import 'package:island/plugins/plugin.dart';
import 'package:island/auth/login_content.dart';
import 'package:island/misc/tray_manager.dart';
import 'package:island/core/services/notify.dart';
import 'package:island/core/services/sharing_intent.dart';
import 'package:island/accounts/screens/physical_passport.dart';
import 'package:island/accounts/widgets/account/account_nameplate.dart';
import 'package:island/shared/widgets/layouts/sheet_scaffold.dart';
import 'package:island/shared/widgets/response.dart';
import 'package:gap/gap.dart';
import 'package:island/core/services/update_service.dart';
import 'package:island/core/widgets/content/network_status_sheet.dart';
import 'package:island/core/tour/tour.dart';
import 'package:island/core/services/event_bus.dart';
import 'package:snow_fall_animation/snow_fall_animation.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:window_manager/window_manager.dart';

const kForceShowStartupSplashForTesting = false;
const kOnboardingLastShownVersion = 'app_onboarding_last_shown_version';

final appWrapperKey = GlobalKey();

class ForcedStartupSplashNotifier extends Notifier<bool> {
  bool _showAfterDone = false;

  bool get showAfterDone => _showAfterDone;

  @override
  bool build() => kForceShowStartupSplashForTesting;

  void setVisible(bool value, {bool afterDone = false}) {
    _showAfterDone = afterDone;
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
    final autoUpdateChecked = useState(false);
    final activeInviteKey = useRef<String?>(null);
    final recentlyHandledInvites = useRef(<String, DateTime>{});
    final lastHandledAcceptedRoomId = useRef<String?>(null);

    // Attach the app WebSocket to the plugin host API so plugins can
    // subscribe / send packets (see PluginWebsocketApi).
    useEffect(() {
      final service = ref.read(websocketProvider);
      final wsApi = PluginController.instance.getApi<PluginWebsocketApi>();
      wsApi?.attach(service);
      return null;
    }, const []);

    void kickCallKitMicrophone(String reason) {
      if (kIsWeb || !Platform.isIOS) return;
      final callState = ref.read(callProvider);
      final nativeState = ref.read(nativeCallBridgeProvider);
      if (!callState.isConnected ||
          !nativeState.isAudioSessionActive ||
          nativeState.callUuid == null ||
          nativeState.roomId == null) {
        return;
      }
      Logger.root.info(
        '[AppWrapper] Restarting iOS CallKit microphone: $reason',
      );
      unawaited(() async {
        await Future<void>.delayed(const Duration(milliseconds: 250));
        await ref.read(callProvider.notifier).ensureMicrophoneEnabled();
        await Future<void>.delayed(const Duration(milliseconds: 800));
        await ref.read(callProvider.notifier).ensureMicrophoneEnabled();
      }());
    }

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
      if (kIsWeb ||
          !(Platform.isMacOS || Platform.isLinux || Platform.isWindows)) {
        return null;
      }

      final listener = _DesktopWindowFocusListener(ref);
      windowManager.addListener(listener);
      windowManager.isFocused().then(
        (focused) =>
            ref.read(desktopWindowFocusedProvider.notifier).set(focused),
      );

      return () {
        windowManager.removeListener(listener);
      };
    }, []);

    useEffect(() {
      if (isNativeCallAvailable) {
        unawaited(
          ref.read(nativeCallBridgeProvider.notifier).ensureInitialized(),
        );
      }
      // ponytail: setup inter-window call channel on desktop
      if (!kIsWeb &&
          (Platform.isMacOS || Platform.isLinux || Platform.isWindows)) {
        setupCallChannelHandler();
      }
      return null;
    }, []);

    useEffect(() {
      if (!isNativeCallAvailable) return null;
      final sub = ref.listenManual(appLifecycleStateProvider, (previous, next) {
        final state = next.value;
        if (state == AppLifecycleState.resumed) {
          Logger.root.info(
            '[AppWrapper] App resumed, syncing native call state',
          );
          unawaited(
            ref.read(nativeCallBridgeProvider.notifier).ensureInitialized(),
          );
        }
      });
      return sub.close;
    }, []);

    useEffect(() {
      if (!kIsWeb && Platform.isIOS) {
        // ponytail: let CallKit own iOS incoming-call UX
        return null;
      }

      void pruneRecentInvites() {
        final now = DateTime.now();
        recentlyHandledInvites.value.removeWhere(
          (_, expiresAt) => expiresAt.isBefore(now),
        );
      }

      BuildContext? resolveInviteModalContext() {
        final router = ref.read(routerProvider);
        final navigatorState = router.navigatorKey.currentState;
        final overlayContext = navigatorState?.overlay?.context;
        if (overlayContext != null && overlayContext.mounted) {
          return overlayContext;
        }

        final navigatorContext = router.navigatorKey.currentContext;
        if (navigatorContext != null && navigatorContext.mounted) {
          return navigatorContext;
        }

        return null;
      }

      Future<BuildContext?> waitForInviteModalContext([int retry = 0]) async {
        final context = resolveInviteModalContext();
        if (context != null) return context;
        if (retry >= 16) return null;

        await WidgetsBinding.instance.endOfFrame;
        await Future<void>.delayed(const Duration(milliseconds: 16));
        return waitForInviteModalContext(retry + 1);
      }

      bool shouldSuppressInvite(IncomingCallInvite invite) {
        final callState = ref.read(callProvider);
        final callNotifier = ref.read(callProvider.notifier);
        final nativeCallState = ref.read(nativeCallBridgeProvider);

        if (callNotifier.roomId == invite.roomId &&
            (callState.isConnected || callState.isReconnecting)) {
          return true;
        }
        if (nativeCallState.callKitAcceptedRoomId == invite.roomId &&
            (nativeCallState.isConnected ||
                nativeCallState.isAcceptedPending)) {
          return true;
        }
        return false;
      }

      Future<void> handleIncomingInvite(IncomingCallInvite invite) async {
        pruneRecentInvites();
        if (!invite.isValid || shouldSuppressInvite(invite)) {
          return;
        }
        if (activeInviteKey.value == invite.dedupeKey ||
            recentlyHandledInvites.value.containsKey(invite.dedupeKey)) {
          return;
        }

        final modalContext = await waitForInviteModalContext();
        if (modalContext == null) {
          Logger.root.warning(
            '[AppWrapper] Invite sheet aborted: navigator context unavailable for ${invite.dedupeKey}',
          );
          return;
        }

        activeInviteKey.value = invite.dedupeKey;
        bool shouldRecordInvite = false;
        bool shouldJoin = false;
        try {
          await playCallInvitedSfxLoop(ref);
          if (!modalContext.mounted) return;

          shouldJoin =
              await showModalBottomSheet<bool>(
                context: modalContext,
                useRootNavigator: true,
                useSafeArea: true,
                isScrollControlled: true,
                builder: (context) => IncomingCallInviteSheet(
                  invite: invite,
                  onJoin: () => Navigator.pop(context, true),
                  onDismiss: () => Navigator.pop(context, false),
                ),
              ) ==
              true;
          shouldRecordInvite = true;
        } catch (err, st) {
          Logger.root.severe(
            '[AppWrapper] Failed to present incoming call invite for ${invite.dedupeKey}',
            err,
            st,
          );
        } finally {
          activeInviteKey.value = null;
          await stopCallInvitedSfxLoop(ref);
        }

        final now = DateTime.now();
        if (shouldRecordInvite) {
          recentlyHandledInvites.value[invite.dedupeKey] = shouldJoin
              ? now.add(const Duration(minutes: 2))
              : now.add(const Duration(seconds: 30));
        }

        if (shouldJoin) {
          await _navigateToCallScreen(
            ref,
            invite.roomId,
            showPendingJoin: true,
          );
        }
      }

      final subscription = ref.read(websocketProvider).dataStream.listen((
        packet,
      ) {
        if (packet.type != 'call.invited' || packet.data == null) return;
        try {
          final invite = IncomingCallInvite.fromJson(packet.data!);
          unawaited(handleIncomingInvite(invite));
        } catch (err) {
          Logger.root.warning(
            '[AppWrapper] Failed to parse call.invited packet: $err',
          );
        }
      });
      return () {
        subscription.cancel();
      };
    }, []);

    // Navigate to CallScreen when CallKit call is accepted
    useEffect(() {
      if (!isNativeCallAvailable) return null;

      void handleNativeCallState(
        NativeCallState? previous,
        NativeCallState current,
      ) {
        Logger.root.info(
          '[AppWrapper] Native call state changed '
          'prevRoom=${previous?.callKitAcceptedRoomId} '
          'currRoom=${current.callKitAcceptedRoomId} '
          'pending=${current.isAcceptedPending} '
          'connected=${current.isConnected}',
        );
        final callbackRequested =
            current.callbackRequestedAt != null &&
            current.callbackRequestedAt != previous?.callbackRequestedAt;
        if (callbackRequested && current.roomId != null) {
          Logger.root.info(
            '[AppWrapper] Native callback requested, navigating to CallScreen: ${current.roomId}',
          );
          unawaited(() async {
            final didNavigate = await _navigateToCallScreen(
              ref,
              current.roomId!,
            );
            Logger.root.info(
              '[AppWrapper] Callback navigation result room=${current.roomId} didNavigate=$didNavigate',
            );
            ref.read(nativeCallBridgeProvider.notifier).clearCallbackRequest();
          }());
        }

        final currRoomId = current.callKitAcceptedRoomId;
        if (currRoomId == null) {
          final nativeEnded =
              current.systemEndedAt != null &&
              current.systemEndedAt != previous?.systemEndedAt;
          if (nativeEnded && ref.read(callProvider).isConnected) {
            Logger.root.info(
              '[AppWrapper] Native call ended, disconnecting Flutter call',
            );
            unawaited(ref.read(callProvider.notifier).disconnect());
          }
          lastHandledAcceptedRoomId.value = null;
          return;
        }

        if (currRoomId != lastHandledAcceptedRoomId.value &&
            (current.isAcceptedPending || current.isConnected)) {
          lastHandledAcceptedRoomId.value = currRoomId;
          Logger.root.info(
            '[AppWrapper] CallKit call accepted, navigating to CallScreen: $currRoomId',
          );
          unawaited(() async {
            final didNavigate = await _navigateToCallScreen(ref, currRoomId);
            Logger.root.info(
              '[AppWrapper] CallKit navigation result room=$currRoomId didNavigate=$didNavigate',
            );
            if (didNavigate) {
              await ref
                  .read(nativeCallBridgeProvider.notifier)
                  .clearPendingAcceptedCall();
            } else {
              await ref.read(nativeCallBridgeProvider.notifier).endCall();
            }
          }());
        }
      }

      final sub = ref.listenManual(
        nativeCallBridgeProvider,
        handleNativeCallState,
      );
      unawaited(() async {
        await ref.read(nativeCallBridgeProvider.notifier).ensureInitialized();
        handleNativeCallState(null, ref.read(nativeCallBridgeProvider));
      }());
      return sub.close;
    }, []);

    // Fulfill CallKit answer when Flutter call connects
    useEffect(() {
      if (!isNativeCallAvailable) return null;

      final sub = ref.listenManual(callProvider, (previous, current) {
        final prevConnected = previous?.isConnected ?? false;
        final currConnected = current.isConnected;

        // Flutter call just connected
        if (!prevConnected && currConnected) {
          Logger.root.info(
            '[AppWrapper] Flutter call connected, syncing native call state',
          );
          ref
              .read(nativeCallBridgeProvider.notifier)
              .markFlutterCallConnected();
          if (!kIsWeb && Platform.isIOS) {
            final nativeState = ref.read(nativeCallBridgeProvider);
            if (nativeState.isAudioSessionActive &&
                nativeState.callUuid != null &&
                nativeState.roomId != null) {
              kickCallKitMicrophone('call connected');
            }
          }
        }

        // Flutter call just disconnected
        if (prevConnected && !currConnected) {
          Logger.root.info('[AppWrapper] Flutter call disconnected');
          ref.read(nativeCallBridgeProvider.notifier).endAllCalls();
        }
      });
      return sub.close;
    }, []);

    // CallKit may activate audio after LiveKit already published the mic.
    // Restart capture when that happens; this mirrors the manual mute/unmute fix.
    useEffect(() {
      if (!isNativeCallAvailable) return null;
      final sub = ref.listenManual(nativeCallBridgeProvider, (
        previous,
        current,
      ) {
        if (!(previous?.isAudioSessionActive ?? false) &&
            current.isAudioSessionActive) {
          kickCallKitMicrophone('audio session activated');
        }
      });
      return sub.close;
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

      Future(() {
        ref.read(rpcServerStateProvider.notifier).start();
        ref.read(webAuthServerStateProvider.notifier).start();
      });

      final composeSheetSubs = eventBus.on<ShowComposeSheetEvent>().listen((
        event,
      ) {
        final ctx = ref.read(routerProvider).navigatorKey.currentContext!;
        if (ctx.mounted) _showPostCompose(ctx);
      });

      final notificationModalSubs = eventBus
          .on<ShowNotificationModalEvent>()
          .listen((event) {
            _showNotificationModal();
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

      ref.read(challengeWsListenerProvider).start();
      final challengeSubs = eventBus.on<ChallengePendingEvent>().listen((
        event,
      ) {
        final ctx = ref.read(routerProvider).navigatorKey.currentContext;
        if (ctx != null && ctx.mounted) _showChallengeApprovalSheet(ctx, event);
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
        notificationModalSubs.cancel();
        thoughtSheetSubs.cancel();
        webAuthSubs.cancel();
        challengeSubs.cancel();
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
      if (shouldShowStartupSplash ||
          onboardingChecked.value ||
          autoUpdateChecked.value) {
        return null;
      }

      Future(() async {
        final prefs = ref.read(sharedPreferencesProvider);
        final packageInfo = await PackageInfo.fromPlatform();
        final currentVersion =
            '${packageInfo.version}+${packageInfo.buildNumber}';
        final lastShownVersion = prefs.getString(kOnboardingLastShownVersion);
        final shouldShowOnboarding =
            lastShownVersion == null || lastShownVersion != currentVersion;

        onboardingChecked.value = true;
        if (shouldShowOnboarding) {
          final ctx = ref.read(routerProvider).navigatorKey.currentContext;
          if (ctx != null && ctx.mounted) {
            await showAppOnboardingSheet(
              ctx,
              version: packageInfo.version,
              isFirstLaunch: lastShownVersion == null,
              suggestAuth: token == null,
            );
            await prefs.setString(kOnboardingLastShownVersion, currentVersion);
          }
        }

        autoUpdateChecked.value = true;

        Future<void> checkForUpdatesWhenReady([int retry = 0]) async {
          final ctx = ref.read(routerProvider).navigatorKey.currentContext;
          if (ctx != null && ctx.mounted) {
            await UpdateService().checkForUpdates(ctx);
            return;
          }
          if (retry >= 16) return;
          await Future.delayed(const Duration(milliseconds: 250));
          await checkForUpdatesWhenReady(retry + 1);
        }

        unawaited(checkForUpdatesWhenReady());
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
                    showCompleted: ref
                        .read(forcedStartupSplashProvider.notifier)
                        .showAfterDone,
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

  void _showNotificationModal() {
    showAttentionModal(
      id: 'notifications',
      replaceIfExists: true,
      barrierDismissible: true,
      builder: (context, dismiss) => NotificationModal(onDismiss: dismiss),
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

  void _showChallengeApprovalSheet(
    BuildContext context,
    ChallengePendingEvent event,
  ) {
    final challenge = SnAuthChallenge.fromJson(
      Map<String, dynamic>.from(event.data),
    );
    // Don't show if the challenge is already expired
    if (challenge.expiredAt != null &&
        challenge.expiredAt!.isBefore(DateTime.now())) {
      return;
    }
    ChallengeApprovalSheet.show(context, challenge);
  }

  void _handleDeepLink(Uri uri, WidgetRef ref, BuildContext context) async {
    String path = '/${uri.host}${uri.path}';
    final transferRequestId = parseWalletTransferRequestId(uri.toString());
    final orderId = parseWalletOrderId(uri.toString());

    if (transferRequestId != null) {
      try {
        await handleWalletTransferRequestDeepLink(
          context: context,
          ref: ref,
          requestId: transferRequestId,
        );
      } catch (err) {
        showErrorAlert(err);
      }

      if (!kIsWeb &&
          (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
        windowManager.show();
      }
      return;
    }

    if (orderId != null) {
      try {
        await _handleWalletOrderDeepLink(context, ref, orderId);
      } catch (err) {
        showErrorAlert(err);
      }

      if (!kIsWeb &&
          (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
        windowManager.show();
      }
      return;
    }

    final transferPayload = parseWalletTransferQrPayload(uri.toString());
    if (transferPayload != null) {
      await handleWalletTransferPayloadDeepLink(
        context: context,
        ref: ref,
        payload: transferPayload,
      );

      if (!kIsWeb &&
          (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
        windowManager.show();
      }
      return;
    }

    if (path == '/auth/authorize') {
      context.router.push(
        AuthorizeRoute(
          clientId: uri.queryParameters['client_id'],
          redirectUri: uri.queryParameters['redirect_uri'],
          scope: uri.queryParameters['scope'],
          state: uri.queryParameters['state'],
          responseType: uri.queryParameters['response_type'],
        ),
      );
      if (!kIsWeb &&
          (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
        windowManager.show();
      }
      return;
    }

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
      eventBus.fire(ShowNotificationModalEvent());
      return;
    }

    final passportDeepLink = parsePhysicalPassportDeepLink(uri.toString());
    if (passportDeepLink != null) {
      await _handlePhysicalPassportDeepLink(
        context,
        ref,
        passportDeepLink,
      );
      return;
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

  Future<void> _handleWalletOrderDeepLink(
    BuildContext context,
    WidgetRef ref,
    String orderId,
  ) async {
    showLoadingModal(context);
    try {
      final client = ref.read(solarNetworkClientProvider);
      final response = await client.dio.get('/wallet/orders/$orderId');
      final data = Map<String, dynamic>.from(response.data as Map);
      final order = SnWalletOrder.fromJson(data);
      final orderInfo = PaymentOverlayOrderInfo.fromJson(data);

      if (context.mounted) {
        hideLoadingModal(context);
      }
      if (!context.mounted) return;

      if (order.status == 0 && !order.expiredAt.isBefore(DateTime.now())) {
        final paidOrder = await PaymentOverlay.show(
          context: context,
          order: order,
          orderInfo: orderInfo,
        );
        if (paidOrder != null) {
          ref.invalidate(walletCurrentProvider);
          ref.invalidate(walletListProvider);
          ref.invalidate(walletStatsProvider);
          showSnackBar('paymentSuccess'.tr());
        }
        return;
      }

      if (order.status == 1) {
        showSnackBar('paymentSuccess'.tr());
      } else if (order.status == 2) {
        showSnackBar('completed'.tr());
      } else if (order.status == 3) {
        showSnackBar('cancelled'.tr());
      } else {
        showSnackBar('expired'.tr());
      }
    } finally {
      if (context.mounted) {
        hideLoadingModal(context);
      }
    }
  }

  Future<void> _handlePhysicalPassportDeepLink(
    BuildContext context,
    WidgetRef ref,
    PhysicalPassportDeepLink link,
  ) async {
    final navigatorContext =
        ref.read(routerProvider).navigatorKey.currentContext ?? context;

    showModalBottomSheet(
      context: navigatorContext,
      isScrollControlled: true,
      useRootNavigator: true,
      builder: (sheetContext) {
        return Consumer(
          builder: (context, sheetRef, child) {
            if (link.isPathBased) {
              final asyncData = sheetRef.watch(
                scanPhysicalPassportProvider(link.tagId!),
              );
              return _buildPassportScanSheet(sheetContext, asyncData);
            } else {
              final asyncData = sheetRef.watch(
                scanPhysicalPassportByParamsProvider(
                  link.queryParameters!,
                ),
              );
              return _buildPassportScanSheet(sheetContext, asyncData);
            }
          },
        );
      },
    );
  }

  Widget _buildPassportScanSheet(
    BuildContext context,
    AsyncValue<SnScanResult> asyncData,
  ) {
    return SheetScaffold(
      heightFactor: 0.5,
      titleText: 'scanPhysicalPassport'.tr(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: asyncData.when(
          data: (result) => _buildScanResultCard(context, result),
          error: (error, _) => ResponseErrorWidget(
            error: error,
            onRetry: () => Navigator.of(context).pop(),
          ),
          loading: () => const ResponseLoadingWidget(),
        ),
      ),
    );
  }

  Widget _buildScanResultCard(BuildContext context, SnScanResult result) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (result.account != null)
          Card(
            margin: EdgeInsets.zero,
            child: InkWell(
              child: AccountNameplate(
                name: result.account!.name,
                isOutlined: false,
              ),
              onTap: () {
                context.router.push(
                  AccountProfileRoute(name: result.account!.name),
                );
              },
            ),
          )
        else
          Card(
            elevation: 0,
            margin: EdgeInsets.zero,
            color: colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Symbols.check_circle,
                        color: colorScheme.primary,
                        size: 20,
                      ),
                      const Gap(8),
                      Text(
                        'physicalPassportScanned'.tr(),
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Gap(12),
                  Text(
                    'ID: ${result.id}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontFamily: 'monospace',
                    ),
                  ),
                  const Gap(12),
                  Text('tagNotClaimed'.tr()),
                ],
              ),
            ),
          ),
        const Gap(24),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('done').tr(),
        ),
      ],
    );
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

  Future<bool> _navigateToCallScreen(
    WidgetRef ref,
    String roomId, {
    bool showPendingJoin = false,
  }) async {
    try {
      Logger.root.info(
        '[AppWrapper] Navigating to CallScreen for room=$roomId',
      );
      final router = ref.read(routerProvider);
      Future<BuildContext?> waitForNavigatorContext([int retry = 0]) async {
        final ctx = router.navigatorKey.currentContext;
        if (ctx != null && ctx.mounted) return ctx;
        if (retry >= 16) return null;

        await WidgetsBinding.instance.endOfFrame;
        await Future<void>.delayed(const Duration(milliseconds: 16));
        return waitForNavigatorContext(retry + 1);
      }

      final ctx = await waitForNavigatorContext();
      if (ctx == null || !ctx.mounted) {
        Logger.root.warning(
          '[AppWrapper] Navigation aborted: navigator context unavailable for room=$roomId',
        );
        return false;
      }

      // Fetch the chat room
      final apiClient = ref.read(apiClientProvider);
      final resp = await apiClient.get('/messager/chat/$roomId');
      final room = SnChatRoom.fromJson(resp.data);
      Logger.root.info(
        '[AppWrapper] Loaded room for call navigation room=$roomId',
      );
      var cameraEnabled = false;

      if (!ctx.mounted) return false;
      if (showPendingJoin) {
        final result = await showModalBottomSheet<({bool cameraEnabled})>(
          context: ctx,
          useSafeArea: true,
          isScrollControlled: true,
          useRootNavigator: true,
          builder: (context) => PendingJoinSheet(
            room: room,
            onJoin: (settings) => Navigator.pop(context, settings),
          ),
        );
        if (result == null) return false;
        cameraEnabled = result.cameraEnabled;
      }
      // Navigate to call screen — desktop: new window; mobile: push route
      if (!kIsWeb &&
          (Platform.isMacOS || Platform.isLinux || Platform.isWindows)) {
        await createCallWindow(room, cameraEnabled: cameraEnabled);
      } else {
        await pushCallScreenOnce(ref, room, cameraEnabled: cameraEnabled);
      }
      return true;
    } catch (e) {
      Logger.root.severe('[AppWrapper] Failed to navigate to call screen: $e');
      return false;
    }
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

class _DesktopWindowFocusListener with WindowListener {
  _DesktopWindowFocusListener(this.ref);

  final WidgetRef ref;

  @override
  void onWindowFocus() {
    ref.read(desktopWindowFocusedProvider.notifier).set(true);
  }

  @override
  void onWindowBlur() {
    ref.read(desktopWindowFocusedProvider.notifier).set(false);
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
