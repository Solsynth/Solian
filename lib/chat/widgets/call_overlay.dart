import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/chat/pods/call.dart';
import 'package:island/accounts/account_pod.dart';
import 'package:island/accounts/screens/profile.dart';
import 'package:island/chat/widgets/call_button.dart';
import 'package:island/chat/widgets/call_content.dart';
import 'package:island/chat/widgets/call_screen.dart';
import 'package:island/core/network.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/shared/widgets/layouts/sheet_scaffold.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:collection/collection.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

class CallControlsBar extends HookConsumerWidget {
  final bool isCompact;
  final bool popOnLeaves;
  const CallControlsBar({
    super.key,
    this.isCompact = false,
    this.popOnLeaves = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final callState = ref.watch(callProvider);
    final callNotifier = ref.read(callProvider.notifier);

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
            icon: callState.isCameraEnabled
                ? Symbols.videocam
                : Symbols.videocam_off,
            onPressed: () => callNotifier.toggleCamera(),
            backgroundColor: const Color(0xFF424242),
            hasDropdown: true,
            deviceType: 'videoinput',
          ),
          _buildCircularButton(
            icon: callState.isScreenSharing
                ? Symbols.stop_screen_share
                : Symbols.screen_share,
            onPressed: () => callNotifier.toggleScreenShare(context),
            backgroundColor: const Color(0xFF424242),
          ),
          _buildCircularButtonWithDropdown(
            context: context,
            ref: ref,
            icon: callState.isMicrophoneEnabled ? Symbols.mic : Symbols.mic_off,
            onPressed: () => callNotifier.toggleMicrophone(),
            backgroundColor: const Color(0xFF424242),
            hasDropdown: true,
            deviceType: 'audioinput',
          ),
          _buildCircularButton(
            icon: callState.isSpeakerphone
                ? Symbols.mobile_speaker
                : Symbols.ear_sound,
            onPressed: () => callNotifier.toggleSpeakerphone(),
            backgroundColor: const Color(0xFF424242),
          ),
          _buildCircularButton(
            icon: callState.viewMode == ViewMode.grid
                ? Symbols.grid_view
                : Symbols.view_list,
            onPressed: () => callNotifier.toggleViewMode(),
            backgroundColor: const Color(0xFF424242),
          ),
          _buildCircularButton(
            icon: Icons.call_end,
            onPressed: () async {
              final confirmed = await showConfirmAlert(
                'Are you sure you want to leave this call?',
                'callLeave'.tr(),
                icon: Symbols.logout,
                isDanger: true,
              );
              if (!confirmed) return;
              if (!context.mounted) return;

              final apiClient = ref.watch(apiClientProvider);
              try {
                showLoadingModal(context);
                await apiClient.delete(
                  '/messager/chat/realtime/${callNotifier.roomId}',
                );
                await callNotifier.disconnect();
                callNotifier.dispose();
                if (context.mounted && popOnLeaves) {
                  if (Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                  }
                }
              } catch (err) {
                showErrorAlert(err);
              } finally {
                if (context.mounted) hideLoadingModal(context);
              }
            },
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
              color: Colors
                  .transparent, // Make Material transparent to show underlying color
              child: InkWell(
                onTap: () =>
                    _showDeviceSelectionDialog(context, ref, deviceType),
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
      final callNotifier = ref.read(callProvider.notifier);

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
    // Use selective watching to reduce rebuilds
    final isConnected = ref.watch(
      callProvider.select((state) => state.isConnected),
    );
    final duration = ref.watch(callProvider.select((state) => state.duration));
    final isMicrophoneEnabled = ref.watch(
      callProvider.select((state) => state.isMicrophoneEnabled),
    );
    ref.watch(callProvider.select((state) => state.participantSyncVersion));
    final callNotifier = ref.read(callProvider.notifier);
    final activeParticipantCount = ref.watch(
      activeCallParticipantCountProvider(room.id),
    );
    final activeParticipants = ref.watch(
      activeCallParticipantsProvider(room.id),
    );
    final hasActiveCall = activeParticipantCount.maybeWhen(
      data: (count) => count > 0,
      orElse: () => false,
    );
    final participants = callNotifier.participants;

    final lastSpeaker = (() {
      if (participants.isEmpty) return null;

      final speakers = participants.where(
        (element) => element.remoteParticipant.lastSpokeAt != null,
      );

      if (speakers.isEmpty) return participants.first;

      return speakers.fold<CallParticipantLive?>(null, (previous, current) {
        if (previous == null) return current;
        return current.remoteParticipant.lastSpokeAt!.compareTo(
                  previous.remoteParticipant.lastSpokeAt!,
                ) >
                0
            ? current
            : previous;
      });
    })();

    final userInfo = ref.watch(userInfoProvider).value!;

    // Memoize chat room name
    final chatRoomName = useMemoized(() {
      final room = callNotifier.chatRoom;
      if (room == null) return 'unnamed'.tr();
      return room.name ??
          (room.members ?? [])
              .where((element) => element.id != userInfo.id)
              .map((element) => element.account.nick)
              .first;
    }, [callNotifier.chatRoom, userInfo]);

    // State for overlay mode: compact or preview
    // Default to true (preview mode) so user sees video immediately after joining
    final isExpanded = useState(true);

    Widget child;
    if (isConnected) {
      child = _buildActiveCallOverlay(
        context,
        ref,
        duration,
        isMicrophoneEnabled,
        callNotifier,
        participants,
        lastSpeaker,
        chatRoomName,
        isExpanded,
      );
    } else if (hasActiveCall) {
      final participantsPreview = activeParticipants.maybeWhen(
        data: (value) => value,
        orElse: () => const <CallParticipant>[],
      );
      child = _buildJoinPrompt(context, ref, participantsPreview);
    } else {
      child = const SizedBox.shrink(key: ValueKey('empty'));
    }

    return AnimatedSize(
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeInOut,
      alignment: Alignment.topCenter,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 150),
        layoutBuilder: (currentChild, previousChildren) {
          return Stack(
            alignment: Alignment.topCenter,
            children: <Widget>[...previousChildren, ?currentChild],
          );
        },
        child: child,
      ),
    );
  }

  Widget _buildJoinPrompt(
    BuildContext context,
    WidgetRef ref,
    List<CallParticipant> participantsPreview,
  ) {
    final isLoading = useState(false);

    return Card(
      key: const ValueKey('join_prompt'),
      margin: EdgeInsets.zero,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              if (participantsPreview.isNotEmpty)
                _CallPreviewParticipantsStrip(
                  participants: participantsPreview,
                  maxVisible: 3,
                )
              else
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
                  Text(
                    participantsPreview.isEmpty
                        ? 'Tap to join'
                        : '${participantsPreview.length} participants online',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
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
                      await ref.read(callProvider.notifier).joinRoom(room);
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
          ),
        ],
      ).padding(all: 12),
    );
  }

  Widget _buildActiveCallOverlay(
    BuildContext context,
    WidgetRef ref,
    Duration duration,
    bool isMicrophoneEnabled,
    CallNotifier callNotifier,
    List<CallParticipantLive> participants,
    CallParticipantLive? lastSpeaker,
    String chatRoomName,
    ValueNotifier<bool> isExpanded,
  ) {
    if (lastSpeaker == null) {
      return const SizedBox.shrink(key: ValueKey('active_waiting'));
    }

    // Preview Mode (Expanded)
    if (isExpanded.value) {
      return Card(
        key: const ValueKey('active_expanded'),
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                const Gap(4),
                Text(chatRoomName),
                const Gap(4),
                Text(formatDuration(duration)).bold(),
                const Gap(8),
                Icon(
                  Symbols.group,
                  size: 16,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const Gap(4),
                Text(
                  '${participants.length}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const Spacer(),
                IconButton(
                  visualDensity: const VisualDensity(
                    horizontal: -4,
                    vertical: -4,
                  ),
                  icon: const Icon(Icons.fullscreen),
                  onPressed: () =>
                      Navigator.of(context, rootNavigator: true).push(
                        MaterialPageRoute(
                          builder: (context) => CallScreen(room: room),
                        ),
                      ),
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
              height: 320,
              width: double.infinity,
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: const CallContent(outerMaxHeight: 320),
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
      key: const ValueKey('active_collapsed'),
      onTap: () => isExpanded.value = true,
      child: Card(
        margin: EdgeInsets.zero,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Row(
                children: [
                  const Gap(8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text('@${lastSpeaker.participant.identity}').bold(),
                          const Gap(8),
                          Icon(
                            Symbols.group,
                            size: 14,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                          const Gap(2),
                          Text(
                            '${participants.length}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                      Row(
                        spacing: 4,
                        children: [
                          Text(
                            chatRoomName,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          Text(
                            formatDuration(duration),
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
                isMicrophoneEnabled ? Icons.mic : Icons.mic_off,
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

class _CallPreviewParticipantsStrip extends StatelessWidget {
  final List<CallParticipant> participants;
  final int maxVisible;

  const _CallPreviewParticipantsStrip({
    required this.participants,
    required this.maxVisible,
  });

  @override
  Widget build(BuildContext context) {
    final hasOverflow = participants.length > maxVisible;
    final avatarSlots = hasOverflow ? (maxVisible - 1) : maxVisible;
    final visible = participants.take(avatarSlots).toList();
    final overflow = participants.length - visible.length;

    return SizedBox(
      height: 34,
      child: Row(
        children:
            [
                ...visible.map(
                  (participant) =>
                      _CallPreviewParticipantAvatar(participant: participant),
                ),
                if (overflow > 0)
                  Container(
                    width: 28,
                    height: 28,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                    ),
                    child: Text(
                      '+$overflow',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ),
              ].expand((widget) => [widget, const Gap(6)]).toList()
              ..removeLast(), // Remove the last Gap to avoid trailing separator
      ),
    );
  }
}

class _CallPreviewParticipantAvatar extends HookConsumerWidget {
  final CallParticipant participant;

  const _CallPreviewParticipantAvatar({required this.participant});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final account = ref.watch(accountProvider(participant.identity));
    return account.when(
      data: (value) =>
          ProfilePictureWidget(file: value.profile.picture, radius: 17),
      loading: () => CircleAvatar(
        radius: 14,
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: SizedBox(
          width: 12,
          height: 12,
          child: CircularProgressIndicator(strokeWidth: 1.8),
        ),
      ),
      error: (_, _) => CircleAvatar(
        radius: 14,
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: Text(
          participant.name.isNotEmpty
              ? participant.name.substring(0, 1).toUpperCase()
              : '?',
          style: Theme.of(context).textTheme.labelSmall,
        ),
      ),
    );
  }
}
