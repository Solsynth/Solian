import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/pods/call.dart';
import 'package:island/pods/network.dart';
import 'package:island/widgets/alert.dart';
import 'package:island/widgets/chat/call_participant_tile.dart';
import 'package:island/widgets/content/sheet.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:livekit_client/livekit_client.dart';

class CallControlsBar extends HookConsumerWidget {
  const CallControlsBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final callState = ref.watch(callNotifierProvider);
    final callNotifier = ref.read(callNotifierProvider.notifier);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
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
          const Gap(16),
          _buildCircularButton(
            icon:
                callState.isScreenSharing
                    ? Icons.stop_screen_share
                    : Icons.screen_share,
            onPressed: () => callNotifier.toggleScreenShare(),
            backgroundColor: const Color(0xFF424242),
          ),
          const Gap(16),
          _buildCircularButtonWithDropdown(
            context: context,
            ref: ref,
            icon: callState.isMicrophoneEnabled ? Icons.mic : Icons.mic_off,
            onPressed: () => callNotifier.toggleMicrophone(),
            backgroundColor: const Color(0xFF424242),
            hasDropdown: true,
            deviceType: 'audioinput',
          ),
          const Gap(16),
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
                          ListTile(
                            leading: const Icon(Symbols.logout, fill: 1),
                            title: Text('callLeave').tr(),
                            onTap: () {
                              callNotifier.disconnect();
                              Navigator.of(context).pop();
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
                                  Navigator.of(context).pop();
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
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(color: backgroundColor, shape: BoxShape.circle),
      child: IconButton(
        icon: Icon(icon, color: iconColor ?? Colors.white, size: 24),
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
    return Stack(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: backgroundColor,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: Icon(icon, color: iconColor ?? Colors.white, size: 24),
            onPressed: onPressed,
          ),
        ),
        if (hasDropdown && deviceType != null)
          Positioned(
            bottom: 4,
            right: 4,
            child: GestureDetector(
              onTap: () => _showDeviceSelectionDialog(context, ref, deviceType),
              child: Container(
                width: 16,
                height: 16,
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
                  size: 12,
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${'switchedTo'.tr()} ${device.label.isNotEmpty ? device.label : 'selectedDevice'.tr()}',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${'failedToSwitchDevice'.tr()}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

class CallOverlayBar extends HookConsumerWidget {
  const CallOverlayBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final callState = ref.watch(callNotifierProvider);
    final callNotifier = ref.read(callNotifierProvider.notifier);
    // Only show if connected and not on the call screen
    if (!callState.isConnected) return const SizedBox.shrink();

    final lastSpeaker =
        callNotifier.participants
                .where(
                  (element) => element.remoteParticipant.lastSpokeAt != null,
                )
                .isEmpty
            ? callNotifier.participants.first
            : callNotifier.participants
                .where(
                  (element) => element.remoteParticipant.lastSpokeAt != null,
                )
                .fold(
                  callNotifier.participants.first,
                  (value, element) =>
                      element.remoteParticipant.lastSpokeAt != null &&
                              (value.remoteParticipant.lastSpokeAt == null ||
                                  element.remoteParticipant.lastSpokeAt!
                                          .compareTo(
                                            value
                                                .remoteParticipant
                                                .lastSpokeAt!,
                                          ) >
                                      0)
                          ? element
                          : value,
                );

    final actionButtonStyle = ButtonStyle(
      minimumSize: const MaterialStatePropertyAll(Size(24, 24)),
    );

    return GestureDetector(
      child: Card(
        margin: EdgeInsets.zero,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Row(
                children: [
                  Builder(
                    builder: (context) {
                      if (callNotifier.localParticipant == null) {
                        return CircularProgressIndicator().center();
                      }
                      return SizedBox(
                        width: 40,
                        height: 40,
                        child:
                            SpeakingRippleAvatar(
                              live: lastSpeaker,
                              size: 36,
                            ).center(),
                      );
                    },
                  ),
                  const Gap(8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('@${lastSpeaker.participant.identity}').bold(),
                      Text(
                        formatDuration(callState.duration),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(
                callState.isMicrophoneEnabled ? Icons.mic : Icons.mic_off,
              ),
              onPressed: () {
                callNotifier.toggleMicrophone();
              },
              style: actionButtonStyle,
            ),
            IconButton(
              icon: Icon(
                callState.isCameraEnabled ? Icons.videocam : Icons.videocam_off,
              ),
              onPressed: () {
                callNotifier.toggleCamera();
              },
              style: actionButtonStyle,
            ),
            IconButton(
              icon: Icon(
                callState.isScreenSharing
                    ? Icons.stop_screen_share
                    : Icons.screen_share,
              ),
              onPressed: () {
                callNotifier.toggleScreenShare();
              },
              style: actionButtonStyle,
            ),
          ],
        ).padding(all: 16),
      ),
      onTap: () {
        context.pushNamed(
          'chatCall',
          pathParameters: {'id': callNotifier.roomId!},
        );
      },
    );
  }
}
