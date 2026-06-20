import 'dart:convert';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/chat/pods/call.dart';
import 'package:island/chat/pods/call_controller.dart';
import 'package:island/chat/widgets/call_overlay.dart' show hideCallOverlay;
import 'package:island/chat/widgets/call_participant_tile.dart';
import 'package:island/core/network.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:livekit_client/livekit_client.dart' as lk;
import 'package:window_manager/window_manager.dart';
import 'package:logging/logging.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

/// Minimal argument shape passed to the call window via desktop_multi_window.
class CallWindowArgs {
  final String roomId;
  final String? roomName;
  final bool cameraEnabled;

  const CallWindowArgs({
    required this.roomId,
    this.roomName,
    this.cameraEnabled = false,
  });

  factory CallWindowArgs.fromJson(Map<String, dynamic> json) =>
      CallWindowArgs(
        roomId: json['roomId'] as String,
        roomName: json['roomName'] as String?,
        cameraEnabled: json['cameraEnabled'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        'roomId': roomId,
        'roomName': roomName,
        'cameraEnabled': cameraEnabled,
      };

  String encode() => jsonEncode(toJson());

  static CallWindowArgs decode(String raw) =>
      CallWindowArgs.fromJson(jsonDecode(raw) as Map<String, dynamic>);
}

/// ponytail: inter-window channel for call lifecycle sync
const _callChannel = WindowMethodChannel('island/call');

/// Send a 'callEnded' message from the call window to the main window.
Future<void> notifyCallEnded(String roomId) async {
  try {
    await _callChannel.invokeMethod('callEnded', {'roomId': roomId});
  } catch (_) {
    // ponytail: main window may not have handler yet — swallow
  }
}

/// Register a handler on the main window side for call lifecycle events.
void setupCallChannelHandler() {
  _callChannel.setMethodCallHandler((call) async {
    switch (call.method) {
      case 'callEnded':
        // ponytail: caller should hide the overlay
        hideCallOverlay();
        break;
    }
    return null;
  });
}

/// Parse the raw arguments string from desktop_multi_window.
/// Returns null if the string is empty or missing 'roomId'.
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

/// Creates and shows a new desktop window for a call.
/// Returns the [WindowController] for the new window.
Future<WindowController> createCallWindow(
  SnChatRoom room, {
  bool cameraEnabled = false,
}) async {
  final args = CallWindowArgs(
    roomId: room.id,
    roomName: room.name,
    cameraEnabled: cameraEnabled,
  );

  final controller = await WindowController.create(
    WindowConfiguration(
      hiddenAtLaunch: true,
      arguments: args.encode(),
    ),
  );

  await controller.show();
  // ponytail: WindowController.show() already focuses, but explicit focus helps
  await windowManager.focus();
  Logger.root.info('[CallWindow] Created call window for room ${room.id}');
  return controller;
}

/// Lightweight app for the dedicated call window.
/// Runs independently from the main app — no full router, no tabs.
class CallWindowApp extends StatelessWidget {
  final CallWindowArgs args;

  const CallWindowApp({super.key, required this.args});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Call — ${args.roomName ?? args.roomId}',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true).copyWith(
        scaffoldBackgroundColor: const Color(0xFF0E1117),
      ),
      home: _CallWindowHome(args: args),
    );
  }
}

class _CallWindowHome extends HookConsumerWidget {
  final CallWindowArgs args;

  const _CallWindowHome({required this.args});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final apiClient = ref.watch(apiClientProvider);

    // ponytail: create a standalone controller for this window
    final controller = useMemoized(
      () => CallController(apiClient: apiClient),
    );
    final callState = useValueListenable(controller.stateNotifier);
    final controlsVisible = useState(true);

    useEffect(() {
      // Fetch room info and join
      () async {
        try {
          // Fetch minimal room data from API
          final resp = await apiClient.get('/messager/chat/${args.roomId}');
          final room = SnChatRoom.fromJson(resp.data);
          await controller.joinRoom(room, cameraEnabled: args.cameraEnabled);
        } catch (e) {
          Logger.root.severe('[CallWindow] Failed to join: $e');
        }
      }();
      return () => controller.dispose();
    }, []);

    useEffect(() {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      return null;
    }, []);

    // Notify main window when call disconnects
    useEffect(() {
      void listener() {
        final s = controller.stateNotifier.value;
        if (!s.isConnected && !s.isReconnecting && s.hasJoined) {
          notifyCallEnded(args.roomId);
        }
      }

      controller.stateNotifier.addListener(listener);
      return () => controller.stateNotifier.removeListener(listener);
    }, [controller]);

    final statusText = callState.isConnected
        ? formatDuration(callState.duration)
        : callState.isReconnecting
            ? 'reconnecting'.tr()
            : 'connecting'.tr();

    return Scaffold(
      backgroundColor: const Color(0xFF0E1117),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => controlsVisible.value = !controlsVisible.value,
        child: Stack(
          children: [
            SafeArea(
              bottom: false,
              child: callState.error != null
                  ? Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 320),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Symbols.error_outline,
                                size: 48, color: Colors.white70),
                            const SizedBox(height: 8),
                            Text(
                              callState.error!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.white70),
                            ),
                            const SizedBox(height: 10),
                            TextButton(
                              onPressed: () async {
                                // ponytail: retry not implemented — user should close and reopen
                                showErrorAlert('Please close this window and try again.');
                              },
                              child: Text('retry'.tr()),
                            ),
                          ],
                        ),
                      ),
                    )
                  : Column(
                      children: [
                        const SizedBox(height: 6),
                        Expanded(
                          child: _CallWindowContent(controller: controller),
                        ),
                      ],
                    ),
            ),
            // Top bar
            AnimatedPositioned(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOutCubic,
              top: controlsVisible.value ? 0 : -80,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(10, 12, 10, 10),
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
                    IconButton(
                      onPressed: () => windowManager.close(),
                      icon:
                          const Icon(Icons.close, color: Colors.white),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            args.roomName ?? 'call'.tr(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                          Text(
                            statusText,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${controller.participants.length}',
                      style: const TextStyle(color: Colors.white70),
                    ),
                    const Icon(Symbols.group,
                        size: 16, color: Colors.white70),
                  ],
                ),
              ),
            ),
            // Bottom controls
            AnimatedPositioned(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOutCubic,
              bottom: controlsVisible.value ? 0 : -140,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.only(top: 8, bottom: 8),
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
                child: Center(
                  child: _CallWindowControlsBar(controller: controller),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Content widget that watches the controller's state directly.
class _CallWindowContent extends HookConsumerWidget {
  final CallController controller;
  const _CallWindowContent({required this.controller});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final callState = useValueListenable(controller.stateNotifier);
    final participants = controller.participants;
    final hasRenderableCall =
        participants.isNotEmpty || callState.hasJoined || callState.isReconnecting;

    if (!hasRenderableCall) {
      return const Center(child: CircularProgressIndicator(color: Colors.white));
    }

    if (participants.isEmpty) {
      return Center(
        child: Text(
          callState.isReconnecting
              ? 'Reconnecting call...'
              : 'Waiting for participants...',
          style: const TextStyle(color: Colors.white70),
        ),
      );
    }

    final allAudioOnly = participants.every(
      (p) => !(p.hasVideo &&
          p.remoteParticipant.trackPublications.values.any(
            (pub) => pub.track != null && pub.kind == lk.TrackType.VIDEO && !pub.muted && !pub.isDisposed,
          )),
    );

    if (allAudioOnly) {
      return Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 24,
            runSpacing: 24,
            children: [
              for (final live in participants)
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SpeakingRippleAvatar(live: live, size: 84),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: 84,
                      child: Text(
                        live.participant.name,
                        style: const TextStyle(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      );
    }

    // Video grid
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final count = participants.length;
        final crossAxisCount = switch (count) {
          <= 1 => 1,
          <= 4 => width > 900 ? 2 : 1,
          <= 9 => width > 1200 ? 3 : 2,
          _ => width > 1400 ? 4 : 3,
        };

        return GridView.builder(
          padding: const EdgeInsets.all(10),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 16 / 9,
          ),
          itemCount: participants.length,
          itemBuilder: (context, index) {
            return _SimpleVideoTile(live: participants[index]);
          },
        );
      },
    );
  }
}

/// Minimal video tile for the call window (no participant card interactions).
class _SimpleVideoTile extends StatelessWidget {
  final CallParticipantLive live;
  const _SimpleVideoTile({required this.live});

  @override
  Widget build(BuildContext context) {
    final videoTrack = live.remoteParticipant.videoTrackPublications
        .where((pub) => pub.track != null && !pub.muted && !pub.isDisposed)
        .map((pub) => pub.track!)
        .firstOrNull;

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        color: const Color(0xFF1A1D23),
        child: videoTrack != null
            ? lk.VideoTrackRenderer(videoTrack as lk.VideoTrack)
            : Center(
                child: Text(
                  live.participant.name.isNotEmpty
                      ? live.participant.name[0].toUpperCase()
                      : '?',
                  style: const TextStyle(color: Colors.white, fontSize: 32),
                ),
              ),
      ),
    );
  }
}

/// Controls bar for the call window — uses CallController directly.
class _CallWindowControlsBar extends HookConsumerWidget {
  final CallController controller;
  const _CallWindowControlsBar({required this.controller});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final callState = useValueListenable(controller.stateNotifier);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Wrap(
        alignment: WrapAlignment.center,
        runSpacing: 16,
        spacing: 16,
        children: [
          _ctrlBtn(
            icon: callState.isCameraEnabled
                ? Symbols.videocam
                : Symbols.videocam_off,
            onPressed: () => controller.toggleCamera(),
          ),
          _ctrlBtn(
            icon: callState.isScreenSharing
                ? Symbols.stop_screen_share
                : Symbols.screen_share,
            onPressed: () => controller.toggleScreenShare(context),
          ),
          _ctrlBtn(
            icon: callState.isMicrophoneEnabled ? Symbols.mic : Symbols.mic_off,
            onPressed: () => controller.toggleMicrophone(),
          ),
          _ctrlBtn(
            icon: Icons.call_end,
            backgroundColor: const Color(0xFFE53E3E),
            onPressed: () async {
              final confirmed = await showConfirmAlert(
                'Are you sure you want to leave this call?',
                'callLeave'.tr(),
                icon: Symbols.logout,
                isDanger: true,
              );
              if (!confirmed) return;
              await controller.disconnect();
              if (context.mounted) {
                windowManager.close();
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _ctrlBtn({
    required IconData icon,
    required VoidCallback onPressed,
    Color backgroundColor = const Color(0xFF424242),
  }) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(color: backgroundColor, shape: BoxShape.circle),
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: 24),
        onPressed: onPressed,
      ),
    );
  }
}
