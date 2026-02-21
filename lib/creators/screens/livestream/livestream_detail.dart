import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:collection/collection.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/account_pod.dart';
import 'package:island/accounts/widgets/account/account_name.dart';
import 'package:island/creators/screens/livestream/livestream_actions.dart';
import 'package:island/core/network.dart';
import 'package:island/core/widgets/embeds/livestream_chat_message.dart';
import 'package:island/core/widgets/embeds/livestream_leaderboard_sheet.dart';
import 'package:island/core/widgets/embeds/livestream_overlay.dart';
import 'package:island/livestreams/livestream_room.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/shared/widgets/layouts/sheet_scaffold.dart';
import 'package:livekit_client/livekit_client.dart' as lk;
import 'package:material_symbols_icons/symbols.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

final creatorLivestreamDetailProvider = FutureProvider.family
    .autoDispose<SnLiveStream, String>((ref, livestreamId) async {
      final client = ref.watch(apiClientProvider);
      final response = await client.get('/sphere/livestreams/$livestreamId');
      return SnLiveStream.fromJson(Map<String, dynamic>.from(response.data));
    });

@RoutePage()
class CreatorLivestreamDetailScreen extends HookConsumerWidget {
  final String livestreamId;

  const CreatorLivestreamDetailScreen({super.key, required this.livestreamId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(
      creatorLivestreamDetailProvider(livestreamId),
    );
    final roomState = ref.watch(livestreamRoomProvider(livestreamId));
    final activeSuperchat = latestActiveSuperchat(roomState.messages);
    final notifier = ref.read(livestreamRoomProvider(livestreamId).notifier);

    final videoPlaybackEnabled = useState(true);
    final audioPlaybackEnabled = useState(true);
    final controlsVisible = useState(true);

    Future<void> connect() async {
      var streamerMode = roomState.requestedStreamerMode;
      if (streamerMode == null) {
        streamerMode = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Connection Mode'),
            content: const Text(
              'Choose your role for this room. Use Viewer mode when streaming via ingress (RTMP/WHIP).',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('cancel').tr(),
              ),
              FilledButton.tonal(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Viewer'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Streamer'),
              ),
            ],
          ),
        );
        if (streamerMode == null) return;
      }
      await notifier.connect(streamer: streamerMode);
    }

    Future<void> applyPlaybackSubscriptions() async {
      final room = roomState.room;
      if (room == null) return;
      for (final participant in room.remoteParticipants.values) {
        for (final pub in participant.videoTrackPublications) {
          if (videoPlaybackEnabled.value) {
            await pub.subscribe();
          } else {
            await pub.unsubscribe();
          }
        }
        for (final pub in participant.audioTrackPublications) {
          if (audioPlaybackEnabled.value) {
            await pub.subscribe();
          } else {
            await pub.unsubscribe();
          }
        }
      }
    }

    Future<void> toggleCamera() async {
      if (!roomState.isStreamerIdentity) return;
      final local = roomState.room?.localParticipant;
      if (local == null) return;
      await local.setCameraEnabled(!local.isCameraEnabled());
      notifier.syncLocalParticipantState();
    }

    Future<void> toggleMic() async {
      if (!roomState.isStreamerIdentity) return;
      final local = roomState.room?.localParticipant;
      if (local == null) return;
      await local.setMicrophoneEnabled(!local.isMicrophoneEnabled());
      notifier.syncLocalParticipantState();
    }

    Future<void> toggleScreenShare() async {
      if (!roomState.isStreamerIdentity) return;
      final local = roomState.room?.localParticipant;
      if (local == null) return;
      final target = !local.isScreenShareEnabled();

      try {
        if (target && lk.lkPlatformIsDesktop()) {
          final source = await showDialog(
            context: context,
            builder: (context) => lk.ScreenSelectDialog(),
          );
          if (source == null) return;
          final track = await lk.LocalVideoTrack.createScreenShareTrack(
            lk.ScreenShareCaptureOptions(
              sourceId: source.id,
              maxFrameRate: 30.0,
              captureScreenAudio: true,
              useiOSBroadcastExtension: true,
            ),
          );
          await local.publishVideoTrack(track);
        } else {
          await local.setScreenShareEnabled(target);
        }
        notifier.syncLocalParticipantState();
      } catch (e) {
        showErrorAlert(e);
      }
    }

    Future<void> toggleVideoPlayback() async {
      videoPlaybackEnabled.value = !videoPlaybackEnabled.value;
      await applyPlaybackSubscriptions();
    }

    Future<void> toggleAudioPlayback() async {
      audioPlaybackEnabled.value = !audioPlaybackEnabled.value;
      await applyPlaybackSubscriptions();
    }

    Future<void> switchDevice(lk.MediaDevice device, String deviceType) async {
      try {
        final localParticipant = roomState.room?.localParticipant;
        if (localParticipant == null) return;

        if (deviceType == 'videoinput') {
          final videoTrack =
              localParticipant.videoTrackPublications.firstOrNull?.track;
          if (videoTrack is lk.LocalVideoTrack) {
            await videoTrack.switchCamera(device.deviceId);
          }
        } else if (deviceType == 'audioinput') {
          final audioTrack =
              localParticipant.audioTrackPublications.firstOrNull?.track;
          if (audioTrack is lk.LocalAudioTrack) {
            await audioTrack.restartTrack(
              lk.AudioCaptureOptions(deviceId: device.deviceId),
            );
          }
        }

        showSnackBar(
          'switchedTo'.tr(
            args: [device.label.isNotEmpty ? device.label : 'device'.tr()],
          ),
        );
        notifier.syncLocalParticipantState();
      } catch (e) {
        showErrorAlert(e);
      }
    }

    Future<void> showDeviceSelectionDialog(String deviceType) async {
      try {
        final devices = await lk.Hardware.instance.enumerateDevices(
          type: deviceType,
        );
        if (!context.mounted) return;

        showModalBottomSheet(
          context: context,
          builder: (dialogContext) => SheetScaffold(
            titleText: deviceType == 'videoinput'
                ? 'selectCamera'.tr()
                : 'selectMicrophone'.tr(),
            child: ListView.builder(
              itemCount: devices.length,
              itemBuilder: (context, index) {
                final device = devices[index];
                return ListTile(
                  title: Text(
                    device.label.isNotEmpty
                        ? device.label
                        : '${'device'.tr()} ${index + 1}',
                  ),
                  onTap: () async {
                    Navigator.of(dialogContext).pop();
                    await switchDevice(device, deviceType);
                  },
                );
              },
            ),
          ),
        );
      } catch (e) {
        showErrorAlert(e);
      }
    }

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          unawaited(connect());
        }
      });
      return () {
        unawaited(notifier.disconnect());
      };
    }, const []);

    final room = roomState.room;
    final videoTrack = videoPlaybackEnabled.value ? roomState.videoTrack : null;
    final stream = detailAsync.asData?.value;
    final viewerCountText = '${roomState.viewerCount} in room';
    final modeText = roomState.localIdentity?.startsWith('streamer_') == true
        ? 'Studio mode'
        : roomState.localIdentity?.startsWith('viewer_') == true
        ? 'Viewer mode (Ingress connected)'
        : roomState.requestedStreamerMode == true
        ? 'Studio mode (selected)'
        : roomState.requestedStreamerMode == false
        ? 'Viewer mode (selected)'
        : 'Mode not selected';
    final subtitleText = '$modeText • $viewerCountText';

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => controlsVisible.value = !controlsVisible.value,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: videoTrack != null
                          ? lk.VideoTrackRenderer(videoTrack)
                          : (stream?.thumbnail?.id != null
                                ? CloudImageWidget(
                                    fileId: stream!.thumbnail!.id,
                                    fit: BoxFit.contain,
                                  )
                                : const ColoredBox(color: Colors.black)),
                    ),
                    if (videoTrack == null)
                      Positioned.fill(
                        child: Container(
                          color: Colors.black.withOpacity(0.42),
                          alignment: Alignment.center,
                          child: Text(
                            !videoPlaybackEnabled.value
                                ? 'Video playback disabled'
                                : room == null
                                ? 'Connecting...'
                                : 'Waiting for video...',
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ),
                      ),
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 180),
                      curve: Curves.easeOutCubic,
                      top: controlsVisible.value ? 0 : -96,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(10, 6, 10, 10),
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
                              onPressed: () => context.router.maybePop(),
                              icon: const Icon(
                                Icons.arrow_back,
                                color: Colors.white,
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    stream?.title ?? 'Livestream Studio',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    subtitleText,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (room != null) ...[
                              if (stream != null) ...[
                                PopupMenuButton<String>(
                                  tooltip: 'Stream actions',
                                  color: Theme.of(context).colorScheme.surface,
                                  icon: const Icon(
                                    Symbols.more_vert,
                                    color: Colors.white,
                                  ),
                                  itemBuilder: (_) =>
                                      buildLivestreamEgressMenuEntries(
                                        hasHlsUrl:
                                            stream.hlsPlaylistPath
                                                ?.trim()
                                                .isNotEmpty ??
                                            false,
                                      ),
                                  onSelected: (value) async {
                                    await handleLivestreamEgressMenuAction(
                                      context,
                                      ref,
                                      action: value,
                                      livestreamId: livestreamId,
                                      hlsUrl: stream.hlsPlaylistPath,
                                      onSuccess: () {
                                        ref.invalidate(
                                          creatorLivestreamDetailProvider(
                                            livestreamId,
                                          ),
                                        );
                                      },
                                    );
                                  },
                                ),
                                const Gap(6),
                              ],
                              IconButton.filledTonal(
                                tooltip: 'Pop out',
                                onPressed: () {
                                  ref
                                      .read(livestreamOverlayProvider.notifier)
                                      .show(livestreamId);
                                },
                                icon: const Icon(Symbols.open_in_new),
                              ),
                              const Gap(6),
                              IconButton.filledTonal(
                                tooltip: 'View viewers',
                                onPressed: () {
                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    builder: (context) => _ViewerListSheet(
                                      identities:
                                          roomState.remoteParticipantIdentities,
                                    ),
                                  );
                                },
                                icon: const Icon(Symbols.group),
                              ),
                              const Gap(6),
                            ],
                            if (room == null && !roomState.isConnecting)
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton.filledTonal(
                                    tooltip: 'Switch role',
                                    onPressed: () async {
                                      notifier.clearRequestedMode();
                                      await connect();
                                    },
                                    icon: const Icon(Symbols.person),
                                  ),
                                  const Gap(6),
                                  IconButton.filledTonal(
                                    onPressed: connect,
                                    icon: const Icon(Symbols.refresh),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ),
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 180),
                      curve: Curves.easeOutCubic,
                      bottom: controlsVisible.value ? 8 : -140,
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
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _CircleControlButton(
                                icon: videoPlaybackEnabled.value
                                    ? Symbols.visibility
                                    : Symbols.visibility_off,
                                active: videoPlaybackEnabled.value,
                                onTap: toggleVideoPlayback,
                              ),
                              const Gap(10),
                              _CircleControlButton(
                                icon: audioPlaybackEnabled.value
                                    ? Symbols.volume_up
                                    : Symbols.volume_off,
                                active: audioPlaybackEnabled.value,
                                onTap: toggleAudioPlayback,
                              ),
                              const Gap(10),
                              if (roomState.isStreamerIdentity) ...[
                                _CircleControlButtonWithDropdown(
                                  icon: roomState.isMicrophoneEnabled
                                      ? Symbols.mic
                                      : Symbols.mic_off,
                                  active: roomState.isMicrophoneEnabled,
                                  onTap: toggleMic,
                                  onDropdownTap: () =>
                                      showDeviceSelectionDialog('audioinput'),
                                ),
                                const Gap(10),
                                _CircleControlButtonWithDropdown(
                                  icon: roomState.isCameraEnabled
                                      ? Symbols.videocam
                                      : Symbols.videocam_off,
                                  active: roomState.isCameraEnabled,
                                  onTap: toggleCamera,
                                  onDropdownTap: () =>
                                      showDeviceSelectionDialog('videoinput'),
                                ),
                                const Gap(10),
                                _CircleControlButton(
                                  icon: roomState.isScreenSharing
                                      ? Symbols.stop_screen_share
                                      : Symbols.screen_share,
                                  active: roomState.isScreenSharing,
                                  onTap: toggleScreenShare,
                                ),
                                const Gap(10),
                              ],
                              _CircleControlButton(
                                icon: Symbols.logout,
                                active: false,
                                isDanger: true,
                                onTap: () async {
                                  await notifier.disconnect();
                                  if (context.mounted) {
                                    context.router.maybePop();
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                border: Border(
                  top: BorderSide(
                    color: Theme.of(context).dividerColor.withOpacity(0.3),
                  ),
                ),
              ),
              child: Column(
                children: [
                  InkWell(
                    onTap: notifier.toggleChatCollapsed,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
                      child: Row(
                        children: [
                          const Icon(Symbols.chat_bubble, size: 18),
                          const Gap(8),
                          Text('Live Chat (${roomState.messages.length})'),
                          const Spacer(),
                          IconButton(
                            onPressed: () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                builder: (context) =>
                                    LivestreamLeaderboardSheet(
                                      livestreamId: livestreamId,
                                    ),
                              );
                            },
                            icon: const Icon(Symbols.leaderboard, size: 18),
                            tooltip: 'livestreamLeaderboard'.tr(),
                            visualDensity: VisualDensity.compact,
                          ),
                          const Icon(Symbols.volume_up, size: 16),
                          SizedBox(
                            width: 100,
                            child: Slider(
                              max: 2,
                              value: roomState.volume,
                              onChanged: notifier.setVolume,
                              year2023: true,
                              padding: EdgeInsets.symmetric(horizontal: 4),
                            ),
                          ),
                          Icon(
                            roomState.isChatCollapsed
                                ? Symbols.expand_more
                                : Symbols.expand_less,
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (!roomState.isChatCollapsed) ...[
                    if (activeSuperchat != null)
                      LivestreamSuperchatStickyChip(
                        message: activeSuperchat,
                        margin: const EdgeInsets.fromLTRB(10, 8, 10, 2),
                      ),
                    SizedBox(
                      height: 220,
                      child: roomState.messages.isEmpty
                          ? const Center(child: Text('No chat messages yet'))
                          : ListView.builder(
                              controller: notifier.chatScrollController,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 8,
                              ),
                              itemCount: roomState.messages.length,
                              itemBuilder: (context, index) {
                                return LivestreamChatMessage(
                                  msg: roomState.messages[index],
                                  compact: true,
                                );
                              },
                            ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 0, 8, 10),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: notifier.chatInputController,
                              onSubmitted: (value) => notifier.sendMessage(),
                              decoration: InputDecoration(
                                isDense: true,
                                hintText: 'liveChatMessageHint'.tr(),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          const Gap(8),
                          IconButton.filled(
                            onPressed: roomState.isSendingChat
                                ? null
                                : notifier.sendMessage,
                            icon: roomState.isSendingChat
                                ? const SizedBox.square(
                                    dimension: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Symbols.send),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (roomState.errorText != null)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
                      child: Text(
                        roomState.errorText!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CircleControlButton extends StatelessWidget {
  final IconData icon;
  final bool active;
  final bool isDanger;
  final VoidCallback onTap;

  const _CircleControlButton({
    required this.icon,
    required this.active,
    required this.onTap,
    this.isDanger = false,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton.filled(
      onPressed: onTap,
      style: IconButton.styleFrom(
        backgroundColor: isDanger
            ? Colors.red
            : active
            ? Theme.of(context).colorScheme.primary
            : Colors.white24,
      ),
      icon: Icon(icon),
      color: Colors.white,
    );
  }
}

class _CircleControlButtonWithDropdown extends StatelessWidget {
  final IconData icon;
  final bool active;
  final VoidCallback onTap;
  final VoidCallback onDropdownTap;

  const _CircleControlButtonWithDropdown({
    required this.icon,
    required this.active,
    required this.onTap,
    required this.onDropdownTap,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        _CircleControlButton(icon: icon, active: active, onTap: onTap),
        Positioned(
          right: -4,
          bottom: -2,
          child: InkWell(
            onTap: onDropdownTap,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white30, width: 0.8),
              ),
              child: const Icon(
                Icons.arrow_drop_down,
                size: 16,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ViewerListSheet extends ConsumerWidget {
  final List<String> identities;

  const _ViewerListSheet({required this.identities});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SheetScaffold(
      titleText: 'Viewers (${identities.length})',
      child: identities.isEmpty
          ? const Center(child: Text('No viewers in room'))
          : ListView.separated(
              itemCount: identities.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final identity = identities[index];
                // Identity is now the username itself
                final accountAsync = ref.watch(accountInfoProvider(identity));
                final account = accountAsync.value;
                final role = identity.startsWith('streamer_')
                    ? 'Streamer'
                    : 'Viewer';
                return ListTile(
                  leading: account?.profile.picture != null
                      ? ProfilePictureWidget(
                          file: account!.profile.picture,
                          radius: 16,
                        )
                      : const Icon(Symbols.person),
                  title: account != null
                      ? AccountName(
                          account: account,
                          hideOverlay: true,
                          style: Theme.of(context).textTheme.bodyMedium,
                        )
                      : Text(identity),
                  subtitle: Text(role),
                );
              },
            ),
    );
  }
}
