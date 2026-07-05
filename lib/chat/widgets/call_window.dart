import 'dart:convert';
import 'dart:io' show Platform;
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/account_pod.dart';
import 'package:island/accounts/widgets/account/account_name.dart';
import 'package:island/chat/pods/call.dart';
import 'package:island/chat/widgets/call_content.dart';
import 'package:island/chat/widgets/call_overlay.dart'
    show CallControlsBar, hideCallOverlay;
import 'package:island/core/config.dart';
import 'package:island/core/network.dart';
import 'package:island/core/theme.dart';
import 'package:island/drive/widgets/cloud_files.dart'
    show ProfilePictureWidget;
import 'package:island/main.dart' show globalOverlay;
import 'package:island/shared/widgets/alert.dart';
import 'package:island/shared/widgets/layouts/sheet_scaffold.dart';
import 'package:window_manager/window_manager.dart';
import 'package:logging/logging.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

// ── Args / Channel ──────────────────────────────────────────────────────────

String _normalizedCallIdentity(String? value) =>
    value?.trim().toLowerCase() ?? '';

bool _isMemberAlreadyInCall(
  SnChatMember member,
  Iterable<CallParticipantLive> participants,
) {
  final activeKeys = <String>{
    for (final live in participants) ...[
      _normalizedCallIdentity(live.participant.identity),
      _normalizedCallIdentity(live.participant.name),
    ],
  }..remove('');

  return activeKeys.contains(_normalizedCallIdentity(member.account.name)) ||
      activeKeys.contains(_normalizedCallIdentity(member.account.nick)) ||
      activeKeys.contains(_normalizedCallIdentity(member.nick));
}

class CallWindowArgs {
  final String roomId;
  final String? roomName;
  final bool cameraEnabled;
  final bool microphoneEnabled;

  const CallWindowArgs({
    required this.roomId,
    this.roomName,
    this.cameraEnabled = false,
    this.microphoneEnabled = true,
  });

  factory CallWindowArgs.fromJson(Map<String, dynamic> json) => CallWindowArgs(
    roomId: json['roomId'] as String,
    roomName: json['roomName'] as String?,
    cameraEnabled: json['cameraEnabled'] as bool? ?? false,
    microphoneEnabled: json['microphoneEnabled'] as bool? ?? true,
  );

  Map<String, dynamic> toJson() => {
    'roomId': roomId,
    'roomName': roomName,
    'cameraEnabled': cameraEnabled,
    'microphoneEnabled': microphoneEnabled,
  };
  String encode() => jsonEncode(toJson());
  static CallWindowArgs decode(String raw) =>
      CallWindowArgs.fromJson(jsonDecode(raw) as Map<String, dynamic>);
}

const _callChannel = WindowMethodChannel('island/call');

Future<void> notifyCallEnded(String roomId) async {
  try {
    await _callChannel.invokeMethod('callEnded', {'roomId': roomId});
  } catch (_) {}
}

void setupCallChannelHandler() {
  _callChannel.setMethodCallHandler((call) async {
    switch (call.method) {
      case 'callEnded':
        hideCallOverlay();
        break;
    }
    return null;
  });
}

CallWindowArgs? parseCallWindowArgs(String raw) {
  if (raw.isEmpty) return null;
  try {
    final json = jsonDecode(raw) as Map<String, dynamic>;
    if (!json.containsKey('roomId')) return null;
    return CallWindowArgs.fromJson(json);
  } catch (_) {
    return null;
  }
}

Future<WindowController> createCallWindow(
  SnChatRoom room, {
  bool cameraEnabled = false,
  bool microphoneEnabled = true,
}) async {
  final args = CallWindowArgs(
    roomId: room.id,
    roomName: room.name,
    cameraEnabled: cameraEnabled,
    microphoneEnabled: microphoneEnabled,
  );
  final controller = await WindowController.create(
    WindowConfiguration(hiddenAtLaunch: true, arguments: args.encode()),
  );
  await controller.show();
  await windowManager.focus();
  Logger.root.info('[CallWindow] Created call window for room ${room.id}');
  return controller;
}

// ── App ─────────────────────────────────────────────────────────────────────

class CallWindowApp extends HookConsumerWidget {
  final CallWindowArgs args;
  const CallWindowApp({super.key, required this.args});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    final settings = ref.watch(appSettingsProvider);

    ThemeMode getThemeMode() {
      switch (settings.themeMode ?? 'system') {
        case 'light':
          return ThemeMode.light;
        case 'dark':
          return ThemeMode.dark;
        default:
          return ThemeMode.system;
      }
    }

    final overlayKey = useMemoized(() => GlobalKey<OverlayState>());

    useEffect(() {
      final previous = globalOverlay;
      globalOverlay = overlayKey;
      return () => globalOverlay = previous;
    }, []);

    return EasyLocalization(
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('zh', 'CN'),
        Locale('zh', 'TW'),
        Locale('zh', 'OG'),
        Locale('ja', 'JP'),
        Locale('ko', 'KR'),
        Locale('es', 'ES'),
      ],
      path: 'assets/i18n',
      fallbackLocale: const Locale('en', 'US'),
      useFallbackTranslations: true,
      child: MaterialApp(
        title: 'Call - ${args.roomName ?? args.roomId}',
        debugShowCheckedModeBanner: false,
        theme: theme.light,
        darkTheme: theme.dark,
        themeMode: getThemeMode(),
        builder: (context, child) {
          return Overlay(
            key: overlayKey,
            initialEntries: [
              OverlayEntry(builder: (_) => child ?? const SizedBox.shrink()),
            ],
          );
        },
        home: _CallWindowHome(args: args),
      ),
    );
  }
}

// ── Home ────────────────────────────────────────────────────────────────────

class _CallWindowHome extends HookConsumerWidget {
  final CallWindowArgs args;
  const _CallWindowHome({required this.args});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final apiClient = ref.watch(apiClientProvider);
    final callNotifier = ref.read(callProvider.notifier);
    final chatRoom = useState<SnChatRoom?>(null);
    final joinError = useState<String?>(null);

    // Eagerly join the call before building content
    useEffect(() {
      () async {
        try {
          final resp = await apiClient.get('/messager/chat/${args.roomId}');
          var room = SnChatRoom.fromJson(resp.data);
          // Fetch members if not included
          if (room.members == null || room.members!.isEmpty) {
            try {
              final membersResp = await apiClient.get(
                '/messager/chat/${args.roomId}/members',
                queryParameters: {'take': '100', 'withStatus': 'true'},
              );
              final members = (membersResp.data as List)
                  .map((e) => SnChatMember.fromJson(e as Map<String, dynamic>))
                  .toList();
              room = room.copyWith(members: members);
            } catch (_) {}
          }
          chatRoom.value = room;
          await callNotifier.joinRoom(
            room,
            cameraEnabled: args.cameraEnabled,
            microphoneEnabled: args.microphoneEnabled,
          );
        } catch (e) {
          Logger.root.severe('[CallWindow] Failed to join: $e');
          joinError.value = e.toString();
        }
      }();

      windowManager.setPreventClose(true);
      final listener = _CallWindowListener(
        notifier: callNotifier,
        roomId: args.roomId,
      );
      windowManager.addListener(listener);
      return () {
        windowManager.removeListener(listener);
      };
    }, []);

    useEffect(() {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      return null;
    }, []);

    // Auto-close when call disconnects
    useEffect(() {
      final sub = ref.listenManual(callProvider, (prev, next) {
        if (prev != null &&
            prev.isConnected &&
            !next.isConnected &&
            next.hasJoined) {
          notifyCallEnded(args.roomId);
          _closeWindow();
        }
      });
      return sub.close;
    }, []);

    final userInfo = ref.watch(userInfoProvider).value;
    final roomForTitle = chatRoom.value;
    final roomTitle =
        roomForTitle?.name ??
        args.roomName ??
        (roomForTitle?.members ?? [])
            .where((m) => m.accountId != userInfo?.id)
            .map((m) => m.nick ?? m.account.nick)
            .firstOrNull ??
        'Call';

    return Material(
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        crossAxisAlignment: .stretch,
        children: [
          // ── Title bar (matches main app WindowScaffold) ──
          _TitleBar(title: roomTitle),
          // ── Call body ──
          Expanded(
            child: joinError.value != null
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Symbols.error_outline,
                          size: 48,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        const SizedBox(height: 8),
                        Text(joinError.value!, textAlign: TextAlign.center),
                        const SizedBox(height: 12),
                        FilledButton.tonal(
                          onPressed: () => _closeWindow(),
                          child: const Text('Close'),
                        ),
                      ],
                    ),
                  )
                : _CallBody(args: args, chatRoom: chatRoom),
          ),
        ],
      ),
    );
  }
}

// ── Title bar ───────────────────────────────────────────────────────────────

class _TitleBar extends StatelessWidget {
  final String title;
  const _TitleBar({required this.title});

  @override
  Widget build(BuildContext context) {
    return DragToMoveArea(
      child: Container(
        height: 32,
        color: Theme.of(context).colorScheme.surfaceContainer,
        child: Platform.isMacOS
            ? Stack(
                alignment: Alignment.center,
                children: [
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 12,
                    ),
                  ),
                ],
              )
            : Row(
                children: [
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Symbols.close, size: 16),
                    padding: const EdgeInsets.all(8),
                    constraints: const BoxConstraints(),
                    onPressed: () => _closeWindow(),
                  ),
                ],
              ),
      ),
    );
  }
}

// ── Call body (in-call overlay + content + controls) ─────────────────────────

class _CallBody extends HookConsumerWidget {
  final CallWindowArgs args;
  final ValueNotifier<SnChatRoom?> chatRoom;
  const _CallBody({required this.args, required this.chatRoom});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final callState = ref.watch(callProvider);
    ref.watch(callProvider.select((state) => state.participantSyncVersion));
    final controlsVisible = useState(true);
    final mediaQuery = MediaQuery.of(context);
    final topOverlayInset = controlsVisible.value ? 64.0 : 0.0;
    final bottomOverlayInset = controlsVisible.value
        ? mediaQuery.padding.bottom + 104
        : 0.0;
    final toolParticipants = ref
        .read(callProvider.notifier)
        .participants
        .where(isToolCallParticipant)
        .toList();

    final statusText = callState.isConnected
        ? formatDuration(callState.duration)
        : callState.isReconnecting
        ? 'Reconnecting'
        : callState.hasJoined
        ? formatDuration(callState.duration)
        : 'Connecting';

    final userInfo = ref.watch(userInfoProvider).value;
    final roomForTitle = chatRoom.value;
    final roomTitle =
        roomForTitle?.name ??
        args.roomName ??
        (roomForTitle?.members ?? [])
            .where((m) => m.accountId != userInfo?.id)
            .map((m) => m.nick ?? m.account.nick)
            .firstOrNull ??
        'Call';

    return Material(
      color: Theme.of(context).colorScheme.surface,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => controlsVisible.value = !controlsVisible.value,
        child: Stack(
          children: [
            // Content
            SafeArea(
              bottom: false,
              child: AnimatedPadding(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOutCubic,
                padding: EdgeInsets.only(
                  top: topOverlayInset,
                  bottom: bottomOverlayInset,
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 6),
                    const Expanded(child: CallContent()),
                  ],
                ),
              ),
            ),
            // In-call info overlay (room name + actions)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOutCubic,
              top: controlsVisible.value ? 0 : -72,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.64),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            roomTitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            statusText,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () =>
                          ref.read(callProvider.notifier).toggleViewMode(),
                      tooltip: callState.viewMode == ViewMode.grid
                          ? 'Stage view'
                          : 'Grid view',
                      icon: Icon(
                        callState.viewMode == ViewMode.grid
                            ? Symbols.view_list
                            : Symbols.grid_view,
                        color: Colors.white,
                        size: 20,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 36,
                        minHeight: 36,
                      ),
                    ),
                    if (toolParticipants.isNotEmpty)
                      IconButton(
                        onPressed: () => showToolParticipantsSheet(
                          context,
                          toolParticipants,
                        ),
                        tooltip: 'toolsInCall'.tr(),
                        icon: Badge.count(
                          count: toolParticipants.length,
                          child: const Icon(
                            Symbols.terminal,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 36,
                          minHeight: 36,
                        ),
                      ),
                    IconButton(
                      onPressed: () => _doInvite(context, ref, chatRoom.value),
                      tooltip: 'inviteToCall'.tr(),
                      icon: const Icon(
                        Symbols.person_add,
                        color: Colors.white,
                        size: 20,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 36,
                        minHeight: 36,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Bottom controls
            AnimatedPositioned(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOutCubic,
              bottom: controlsVisible.value ? 0 : -160,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.only(
                  top: 8,
                  bottom: MediaQuery.of(context).padding.bottom + 8,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.64),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: const Center(
                  child: CallControlsBar(
                    showSpeakerToggle: false,
                    showViewToggle: false,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _doInvite(
    BuildContext context,
    WidgetRef ref,
    SnChatRoom? room,
  ) async {
    if (room == null) return;
    final apiClient = ref.read(apiClientProvider);
    final currentUserId = ref.read(userInfoProvider).value?.id;
    final callNotifier = ref.read(callProvider.notifier);
    var members = room.members ?? const <SnChatMember>[];

    // Fetch members if not available
    if (members.isEmpty) {
      try {
        final resp = await apiClient.get(
          '/messager/chat/${room.id}/members',
          queryParameters: {'take': '100', 'withStatus': 'true'},
        );
        members = (resp.data as List)
            .map((e) => SnChatMember.fromJson(e as Map<String, dynamic>))
            .toList();
      } catch (_) {}
    }

    final candidates = members.where((m) {
      if (m.joinedAt == null) return false;
      if (m.accountId == currentUserId) return false;
      return !_isMemberAlreadyInCall(m, callNotifier.participants);
    }).toList();

    if (candidates.isEmpty) {
      showErrorAlert('noMembersToInvite'.tr());
      return;
    }

    if (!context.mounted) return;
    final target = await showModalBottomSheet<SnChatMember>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (ctx) => SheetScaffold(
        titleText: 'inviteToCall'.tr(),
        heightFactor: 0.6,
        child: ListView.builder(
          itemCount: candidates.length,
          itemBuilder: (_, i) {
            final m = candidates[i];
            return ListTile(
              leading: ProfilePictureWidget(
                file: m.account.profile.picture,
                radius: 18,
              ),
              title: AccountName(account: m.account),
              subtitle: Text(
                m.account.name,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              trailing: IconButton(
                icon: const Icon(Symbols.call),
                onPressed: () => Navigator.pop(ctx, m),
              ),
              onTap: () => Navigator.pop(ctx, m),
            );
          },
        ),
      ),
    );
    if (target == null) return;
    try {
      await apiClient.post(
        '/messager/chat/realtime/${room.id}/invite/${target.accountId}',
      );
      showSnackBar(
        'inviteSentTo'.tr(args: [target.nick ?? target.account.nick]),
      );
    } catch (e) {
      showErrorAlert(e);
    }
  }
}

// ── Invite sheet (uses AccountName + ProfilePicture) ────────────────────────

// ── Listener ────────────────────────────────────────────────────────────────

Future<void> _closeWindow() async {
  await windowManager.setPreventClose(false);
  await windowManager.close();
}

class _CallWindowListener with WindowListener {
  final CallNotifier notifier;
  final String roomId;
  bool _closed = false;

  _CallWindowListener({required this.notifier, required this.roomId});

  @override
  void onWindowClose() async {
    if (_closed) return;
    _closed = true;
    try {
      final bounds = await windowManager.getBounds();
      SharedPreferences.getInstance()
          .then((prefs) {
            prefs.setString(
              'callWindowSize',
              '${bounds.size.width},${bounds.size.height}',
            );
          })
          .catchError((_) {});
    } catch (_) {}
    // ponytail: don't disconnect — let the main window show the in-app overlay
    await windowManager.setPreventClose(false);
    await windowManager.close();
  }
}
