import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/models/account.dart';
import 'package:island/models/chat.dart';
import 'package:island/pods/chat/call.dart';
import 'package:island/pods/userinfo.dart';
import 'package:island/screens/chat/call.dart';
import 'package:island/pods/network.dart';
import 'package:island/widgets/alert.dart';
import 'package:island/widgets/chat/call_button.dart';
import 'package:island/widgets/chat/call_content.dart';
import 'package:island/widgets/chat/call_participant_tile.dart';
import 'package:island/widgets/content/sheet.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:livekit_client/livekit_client.dart';

class CallControlsBar extends HookConsumerWidget {
  final bool isCompact;
  const CallControlsBar({super.key, this.isCompact = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final callState = ref.watch(callNotifierProvider);
    final callNotifier = ref.read(callNotifierProvider.notifier);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 12 : 20,
        vertical: isCompact ? 8 : 16,
      ),
      child: Wrap(
        alignment: WrapAlignment.center,
        runSpacing: isCompact ? 12 : 16,
        spacing: isCompact ? 12 : 16,
        children: [
          _buildCircularButtonWithDropdown(
            context: context,
            ref: ref,
            icon:
                callState.isCameraEnabled ? Icons.videocam : Icons.videocam_off,
            onPressed: () => callNotifier.toggleCamera(),
            backgroundColor: const Color(0xFF424242),
            hasDropdown: true,
            deviceType: 'videoinput',
          ),
          _buildCircularButton(
            icon:
                callState.isScreenSharing
                    ? Icons.stop_screen_share
                    : Icons.screen_share,
            onPressed: () => callNotifier.toggleScreenShare(context),
            backgroundColor: const Color(0xFF424242),
          ),
          _buildCircularButtonWithDropdown(
            context: context,
            ref: ref,
            icon: callState.isMicrophoneEnabled ? Icons.mic : Icons.mic_off,
            onPressed: () => callNotifier.toggleMicrophone(),
            backgroundColor: const Color(0xFF424242),
            hasDropdown: true,
            deviceType: 'audioinput',
          ),
          _buildCircularButton(
            icon:
                callState.isSpeakerphone
                    ? Symbols.mobile_speaker
                    : Symbols.ear_sound,
            onPressed: () => callNotifier.toggleSpeakerphone(),
            backgroundColor: const Color(0xFF424242),
          ),
          _buildCircularButton(
            icon: Icons.call_end,
            onPressed:
                () => showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  useRootNavigator: true,
                  builder:
                      (innerContext) => Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Gap(24),
                          ListTile(
                            leading: const Icon(Symbols.logout, fill: 1),
                            title: Text('callLeave').tr(),
                            onTap: () {
                              callNotifier.disconnect();
                              if (Navigator.of(context).canPop()) {
                                Navigator.of(context).pop();
                              }
                              Navigator.of(innerContext).pop();
                            },
                          ),
                          ListTile(
                            leading: const Icon(Symbols.call_end, fill: 1),
                            iconColor: Colors.red,
                            title: Text('callEnd').tr(),
                            onTap: () async {
                              callNotifier.disconnect();
                              final apiClient = ref.watch(apiClientProvider);
                              try {
                                showLoadingModal(context);
                                await apiClient.delete(
                                  '/sphere/chat/realtime/${callNotifier.roomId}',
                                );
                                callNotifier.dispose();
                                if (context.mounted) {
                                  if (Navigator.of(context).canPop()) {
                                    Navigator.of(context).pop();
                                  }
                                  Navigator.of(innerContext).pop();
                                }
                              } catch (err) {
                                showErrorAlert(err);
                              } finally {
                                if (context.mounted) hideLoadingModal(context);
                              }
                            },
                          ),
                          Gap(MediaQuery.of(context).padding.bottom),
                        ],
                      ),
                ),
            backgroundColor: const Color(0xFFE53E3E),
            iconColor: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _buildCircularButton({
    required IconData icon,
    required VoidCallback onPressed,
    required Color backgroundColor,
    Color? iconColor,
  }) {
    final size = isCompact ? 40.0 : 56.0;
    final iconSize = isCompact ? 20.0 : 24.0;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: backgroundColor, shape: BoxShape.circle),
      child: IconButton(
        icon: Icon(icon, color: iconColor ?? Colors.white, size: iconSize),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildCircularButtonWithDropdown({
    required BuildContext context,
    required WidgetRef ref,
    required IconData icon,
    required VoidCallback onPressed,
    required Color backgroundColor,
    required bool hasDropdown,
    Color? iconColor,
    String? deviceType, // 'videoinput' or 'audioinput'
  }) {
    final size = isCompact ? 40.0 : 56.0;
    final iconSize = isCompact ? 20.0 : 24.0;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: backgroundColor,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: Icon(icon, color: iconColor ?? Colors.white, size: iconSize),
            onPressed: onPressed,
          ),
        ),
        if (hasDropdown && deviceType != null)
          Positioned(
            bottom: 0,
            right: isCompact ? 0 : -4,
            child: Material(
              color:
                  Colors
                      .transparent, // Make Material transparent to show underlying color
              child: InkWell(
                onTap:
                    () => _showDeviceSelectionDialog(context, ref, deviceType),
                borderRadius: BorderRadius.circular((isCompact ? 16 : 24) / 2),
                child: Container(
                  width: isCompact ? 16 : 24,
                  height: isCompact ? 16 : 24,
                  decoration: BoxDecoration(
                    color: backgroundColor.withOpacity(0.8),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 0.5,
                    ),
                  ),
                  child: Icon(
                    Icons.arrow_drop_down,
                    color: Colors.white,
                    size: isCompact ? 12 : 20,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _showDeviceSelectionDialog(
    BuildContext context,
    WidgetRef ref,
    String deviceType,
  ) async {
    try {
      final devices = await Hardware.instance.enumerateDevices(
        type: deviceType,
      );

      if (!context.mounted) return;

      showModalBottomSheet(
        context: context,
        builder: (BuildContext dialogContext) {
          return SheetScaffold(
            titleText:
                deviceType == 'videoinput'
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
                  onTap: () {
                    Navigator.of(dialogContext).pop();
                    _switchDevice(context, ref, device, deviceType);
                  },
                );
              },
            ),
          );
        },
      );
    } catch (e) {
      showErrorAlert(e);
    }
  }

  Future<void> _switchDevice(
    BuildContext context,
    WidgetRef ref,
    MediaDevice device,
    String deviceType,
  ) async {
    try {
      final callNotifier = ref.read(callNotifierProvider.notifier);

      if (deviceType == 'videoinput') {
        // Switch camera device
        final localParticipant = callNotifier.room?.localParticipant;
        final videoTrack =
            localParticipant?.videoTrackPublications.firstOrNull?.track;

        if (videoTrack is LocalVideoTrack) {
          await videoTrack.switchCamera(device.deviceId);
        }
      } else if (deviceType == 'audioinput') {
        // Switch microphone device
        final localParticipant = callNotifier.room?.localParticipant;
        final audioTrack =
            localParticipant?.audioTrackPublications.firstOrNull?.track;

        if (audioTrack is LocalAudioTrack) {
          // For audio devices, we need to restart the track with new device
          await audioTrack.restartTrack(
            AudioCaptureOptions(deviceId: device.deviceId),
          );
        }
      }

      if (context.mounted) {
        showSnackBar(
          'switchedTo'.tr(
            args: [device.label.isNotEmpty ? device.label : 'device'],
          ),
        );
      }
    } catch (err) {
      showErrorAlert(err);
    }
  }
}

class CallOverlayBar extends HookConsumerWidget {
  final SnChatRoom room;
  const CallOverlayBar({super.key, required this.room});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final callState = ref.watch(callNotifierProvider);
    final callNotifier = ref.read(callNotifierProvider.notifier);
    final ongoingCall = ref.watch(ongoingCallProvider(room.id));

    // State for overlay mode: compact or preview
    // Default to true (preview mode) so user sees video immediately after joining
    final isExpanded = useState(true);

    // If connected, show active call UI
    if (callState.isConnected) {
      return _buildActiveCallOverlay(
        context,
        ref,
        callState,
        callNotifier,
        isExpanded,
      );
    }

    // If not connected but there is an ongoing call, show join prompt
    if (ongoingCall.value != null) {
      return _buildJoinPrompt(context, ref);
    }

    return const SizedBox.shrink();
  }

  Widget _buildJoinPrompt(BuildContext context, WidgetRef ref) {
    final isLoading = useState(false);

    return Card(
      margin: EdgeInsets.zero,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.videocam,
              color: Theme.of(context).colorScheme.onPrimary,
              size: 20,
            ),
          ),
          const Gap(12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Call in progress').bold(),
              Text('Tap to join', style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
          const Spacer(),
          if (isLoading.value)
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            ).padding(right: 8)
          else
            FilledButton.icon(
              onPressed: () async {
                isLoading.value = true;
                try {
                  // Just join the room, don't navigate
                  await ref.read(callNotifierProvider.notifier).joinRoom(room);
                } catch (e) {
                  showErrorAlert(e);
                } finally {
                  isLoading.value = false;
                }
              },
              icon: const Icon(Icons.call, size: 18),
              label: const Text('Join'),
              style: FilledButton.styleFrom(
                visualDensity: VisualDensity.compact,
              ),
            ),
        ],
      ).padding(all: 12),
    );
  }

  String _getChatRoomName(SnChatRoom? room, SnAccount currentUser) {
    if (room == null) return 'unnamed'.tr();
    return room.name ??
        (room.members ?? [])
            .where((element) => element.id != currentUser.id)
            .map((element) => element.account.nick)
            .first;
  }

  Widget _buildActiveCallOverlay(
    BuildContext context,
    WidgetRef ref,
    CallState callState,
    CallNotifier callNotifier,
    ValueNotifier<bool> isExpanded,
  ) {
    final lastSpeaker =
        callNotifier.participants
                .where(
                  (element) => element.remoteParticipant.lastSpokeAt != null,
                )
                .isEmpty
            ? callNotifier.participants.firstOrNull
            : callNotifier.participants
                .where(
                  (element) => element.remoteParticipant.lastSpokeAt != null,
                )
                .fold(
                  callNotifier.participants.firstOrNull,
                  (value, element) =>
                      element.remoteParticipant.lastSpokeAt != null &&
                              (value?.remoteParticipant.lastSpokeAt == null ||
                                  element.remoteParticipant.lastSpokeAt!
                                          .compareTo(
                                            value!
                                                .remoteParticipant
                                                .lastSpokeAt!,
                                          ) >
                                      0)
                          ? element
                          : value,
                );

    if (lastSpeaker == null) return const SizedBox.shrink();

    final userInfo = ref.watch(userInfoProvider).value!;

    // Preview Mode (Expanded)
    if (isExpanded.value) {
      return Card(
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                const Gap(4),
                Text(_getChatRoomName(callNotifier.chatRoom, userInfo)),
                const Gap(4),
                Text(formatDuration(callState.duration)).bold(),
                const Spacer(),
                IconButton(
                  visualDensity: const VisualDensity(
                    horizontal: -4,
                    vertical: -4,
                  ),
                  icon: const Icon(Icons.fullscreen),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => CallScreen(room: room),
                      ),
                    );
                  },
                  tooltip: 'Full Screen',
                ),
                IconButton(
                  visualDensity: const VisualDensity(
                    horizontal: -4,
                    vertical: -4,
                  ),
                  icon: const Icon(Icons.expand_less),
                  onPressed: () => isExpanded.value = false,
                  tooltip: 'Collapse',
                ),
              ],
            ).padding(horizontal: 12, vertical: 8),
            // Video Preview
            Container(
              height: 200,
              width: double.infinity,
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: const CallContent(),
            ),
            const CallControlsBar(
              isCompact: true,
            ).padding(vertical: 8, horizontal: 16),
          ],
        ),
      );
    }

    // Compact Mode
    return GestureDetector(
      onTap: () => isExpanded.value = true,
      child: Card(
        margin: EdgeInsets.zero,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Row(
                children: [
                  SizedBox(
                    width: 40,
                    height: 40,
                    child:
                        SpeakingRippleAvatar(
                          live: lastSpeaker,
                          size: 36,
                        ).center(),
                  ),
                  const Gap(8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('@${lastSpeaker.participant.identity}').bold(),
                      Row(
                        spacing: 4,
                        children: [
                          Text(
                            _getChatRoomName(callNotifier.chatRoom, userInfo),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          Text(
                            formatDuration(callState.duration),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(
                callState.isMicrophoneEnabled ? Icons.mic : Icons.mic_off,
                size: 20,
              ),
              onPressed: () {
                callNotifier.toggleMicrophone();
              },
            ),
            IconButton(
              icon: const Icon(Icons.expand_more),
              onPressed: () => isExpanded.value = true,
              tooltip: 'Expand',
            ),
          ],
        ).padding(all: 12),
      ),
    );
  }
}
