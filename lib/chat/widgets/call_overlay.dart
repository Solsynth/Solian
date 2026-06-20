import 'dart:io' show Platform;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/chat/pods/call.dart';
import 'package:island/chat/pods/call_participants.dart';
import 'package:island/accounts/account_pod.dart';
import 'package:island/chat/widgets/call_button.dart';
import 'package:island/chat/widgets/call_content.dart';
import 'package:island/chat/widgets/call_participant_tile.dart';
import 'package:island/chat/widgets/call_screen.dart';
import 'package:island/chat/widgets/call_window.dart';
import 'package:island/core/network.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:island/main.dart';
import 'package:island/route.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/shared/widgets/layouts/sheet_scaffold.dart';
import 'package:logging/logging.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:collection/collection.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

OverlayEntry? _callOverlayEntry;
final ProviderContainer _overlayContainer = ProviderContainer();

// Track if the full-screen CallScreen is active to prevent overlay from showing
bool _isCallScreenActive = false;

/// Set whether the full-screen CallScreen is currently active.
/// When active, the floating overlay will not be shown.
void setCallScreenActive(bool active) {
  _isCallScreenActive = active;
  if (active) {
    hideCallOverlay();
  }
}

/// Check if the full-screen CallScreen is currently active.
bool isCallScreenActive() => _isCallScreenActive;

final _callOverlayStateProvider =
    NotifierProvider<_CallOverlayStateNotifier, _CallOverlayState>(
      _CallOverlayStateNotifier.new,
    );

class _CallOverlayState {
  final Offset position;
  final Size size;
  final bool isExpanded;
  final SnChatRoom? room;

  const _CallOverlayState({
    this.position = const Offset(8, 80),
    this.size = const Size(320, 420),
    this.isExpanded = true,
    this.room,
  });

  _CallOverlayState copyWith({
    Offset? position,
    Size? size,
    bool? isExpanded,
    SnChatRoom? room,
  }) {
    return _CallOverlayState(
      position: position ?? this.position,
      size: size ?? this.size,
      isExpanded: isExpanded ?? this.isExpanded,
      room: room ?? this.room,
    );
  }
}

class _CallOverlayStateNotifier extends Notifier<_CallOverlayState> {
  @override
  _CallOverlayState build() => const _CallOverlayState();

  void updatePosition(Offset delta) {
    state = state.copyWith(
      position: Offset(
        state.position.dx + delta.dx,
        state.position.dy + delta.dy,
      ),
    );
  }

  void setPosition(Offset position) {
    state = state.copyWith(position: position);
  }

  void updateSize(Size delta) {
    const minWidth = 280.0;
    const minHeight = 300.0;
    const maxWidth = 600.0;
    const maxHeight = 800.0;

    final newWidth = (state.size.width + delta.width).clamp(minWidth, maxWidth);
    final newHeight = (state.size.height + delta.height).clamp(
      minHeight,
      maxHeight,
    );
    state = state.copyWith(size: Size(newWidth, newHeight));
  }

  void setExpanded(bool value) {
    state = state.copyWith(isExpanded: value);
  }

  void setRoom(SnChatRoom room) {
    state = state.copyWith(room: room);
  }
}

void showCallOverlay(SnChatRoom room) {
  // Don't show overlay if CallScreen is active
  if (_isCallScreenActive) {
    Logger.root.info(
      '[CallOverlay] Not showing overlay - CallScreen is active',
    );
    return;
  }

  if (_callOverlayEntry != null) {
    _overlayContainer.read(_callOverlayStateProvider.notifier).setRoom(room);
    _callOverlayEntry?.markNeedsBuild();
    return;
  }

  final state = _overlayContainer.read(_callOverlayStateProvider);
  _overlayContainer.read(_callOverlayStateProvider.notifier).setRoom(room);

  _callOverlayEntry = OverlayEntry(
    builder: (context) => _CallOverlayPanel(
      initialPosition: state.position,
      initialSize: state.size,
      initialExpanded: state.isExpanded,
      initialRoom: room,
    ),
  );
  globalOverlay.currentState?.insert(_callOverlayEntry!);
}

void hideCallOverlay() {
  _callOverlayEntry?.remove();
  _callOverlayEntry = null;
}

void toggleCallOverlay(SnChatRoom room) {
  if (_callOverlayEntry != null) {
    hideCallOverlay();
  } else {
    showCallOverlay(room);
  }
}

class _CallOverlayPanel extends ConsumerStatefulWidget {
  final Offset initialPosition;
  final Size initialSize;
  final bool initialExpanded;
  final SnChatRoom initialRoom;

  const _CallOverlayPanel({
    required this.initialPosition,
    required this.initialSize,
    required this.initialExpanded,
    required this.initialRoom,
  });

  @override
  ConsumerState<_CallOverlayPanel> createState() => _CallOverlayPanelState();
}

class _CallOverlayPanelState extends ConsumerState<_CallOverlayPanel>
    with SingleTickerProviderStateMixin {
  late Offset _position;
  late Size _size;
  late bool _isExpanded;
  late SnChatRoom _room;
  late AnimationController _animController;
  late Animation<double> _expandAnim;

  @override
  void initState() {
    super.initState();
    _position = widget.initialPosition;
    _size = widget.initialSize;
    _isExpanded = widget.initialExpanded;
    _room = widget.initialRoom;
    _animController = AnimationController(
      duration: const Duration(milliseconds: 280),
      vsync: this,
      value: _isExpanded ? 1.0 : 0.0,
    );
    _expandAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() => _isExpanded = !_isExpanded);
    ref.read(_callOverlayStateProvider.notifier).setExpanded(_isExpanded);
    if (_isExpanded) {
      _animController.forward();
    } else {
      _animController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final callState = ref.watch(callProvider);
    final isConnected = callState.isConnected;
    final isReconnecting = callState.isReconnecting;
    final duration = callState.duration;
    final isMicrophoneEnabled = callState.isMicrophoneEnabled;
    final callNotifier = ref.read(callProvider.notifier);
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

    final overlayState = ref.watch(_callOverlayStateProvider);
    final room = overlayState.room;
    final userInfo = ref.watch(userInfoProvider).value!;

    String chatRoomName;
    final r = callNotifier.chatRoom;
    if (r == null) {
      chatRoomName = 'unnamed'.tr();
    } else {
      chatRoomName =
          r.name ??
          (r.members ?? [])
              .where((element) => element.id != userInfo.id)
              .map((element) => element.account.nick)
              .firstOrNull ??
          'unnamed'.tr();
    }

    final activeParticipantCount = ref.watch(
      activeCallParticipantCountProvider(room?.id ?? ''),
    );
    final hasActiveCall = activeParticipantCount.maybeWhen(
      data: (count) => count > 0,
      orElse: () => false,
    );

    if (!isConnected && !isReconnecting && !hasActiveCall) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        hideCallOverlay();
      });
      return const SizedBox.shrink();
    }

    return Positioned(
      left: _position.dx,
      top: _position.dy,
      child: Material(
        color: Colors.transparent,
        child: GestureDetector(
          onPanUpdate: (details) {
            final screenSize = MediaQuery.of(context).size;
            const collapsedWidth = 120.0;
            const collapsedHeight = 80.0;
            final overlayWidth = _isExpanded ? _size.width : collapsedWidth;
            final overlayHeight = _isExpanded ? _size.height : collapsedHeight;

            setState(() {
              _position = Offset(
                (_position.dx + details.delta.dx).clamp(
                  0,
                  screenSize.width - overlayWidth,
                ),
                (_position.dy + details.delta.dy).clamp(
                  0,
                  screenSize.height - overlayHeight,
                ),
              );
            });
            ref
                .read(_callOverlayStateProvider.notifier)
                .updatePosition(details.delta);
          },
          child: AnimatedBuilder(
            animation: _expandAnim,
            builder: (context, child) {
              if (!isConnected && !isReconnecting && hasActiveCall) {
                return _buildJoinPrompt(context, ref, room, theme);
              }

              if (lastSpeaker == null) {
                if (isReconnecting) {
                  return _buildReconnectingCard(theme, callState.reconnectAttempt);
                }
                return const SizedBox.shrink();
              }

              return _buildOverlayContent(
                context,
                ref,
                theme,
                chatRoomName,
                duration,
                participants,
                lastSpeaker,
                callNotifier,
                isMicrophoneEnabled,
                _room,
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildJoinPrompt(
    BuildContext context,
    WidgetRef ref,
    SnChatRoom? room,
    ThemeData theme,
  ) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 320),
        child: _JoinPromptWidget(room: room, theme: theme),
      ),
    );
  }

  Widget _buildReconnectingCard(ThemeData theme, int reconnectAttempt) {
    return Container(
      width: 220,
      height: 120,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withOpacity(0.92),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2.4),
          ),
          const Gap(12),
          Text(
            reconnectAttempt > 0
                ? 'Reconnecting... ($reconnectAttempt/${CallNotifier.maxReconnectAttempts})'
                : 'Reconnecting...',
            style: theme.textTheme.titleSmall,
          ),
        ],
      ),
    );
  }

  Widget _buildOverlayContent(
    BuildContext context,
    WidgetRef ref,
    ThemeData theme,
    String chatRoomName,
    Duration duration,
    List<CallParticipantLive> participants,
    CallParticipantLive lastSpeaker,
    CallNotifier callNotifier,
    bool isMicrophoneEnabled,
    SnChatRoom? room,
  ) {
    const collapsedWidth = 140.0;
    const collapsedHeight = 140.0;
    final currentWidth =
        collapsedWidth + (_size.width - collapsedWidth) * _expandAnim.value;
    final currentHeight =
        collapsedHeight + (_size.height - collapsedHeight) * _expandAnim.value;

    return AnimatedSize(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
      alignment: Alignment.topLeft,
      child: SizedBox(
        width: currentWidth,
        height: currentHeight,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              bottom: 0,
              child: _buildPanelContainer(
                context,
                theme,
                child: _isExpanded
                    ? _buildExpandedContent(
                        context,
                        ref,
                        theme,
                        chatRoomName,
                        duration,
                        participants,
                        lastSpeaker,
                        callNotifier,
                        isMicrophoneEnabled,
                        room,
                      )
                    : _buildCollapsedContent(
                        context,
                        ref,
                        theme,
                        chatRoomName,
                        duration,
                        participants,
                        lastSpeaker,
                        isMicrophoneEnabled,
                        callNotifier,
                      ),
              ),
            ),
            if (_isExpanded) ...[
              Positioned(right: 0, bottom: 0, child: _buildResizeHandle(theme)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildResizeHandle(ThemeData theme) {
    const minWidth = 280.0;
    const minHeight = 300.0;
    const maxWidth = 600.0;
    const maxHeight = 800.0;

    return GestureDetector(
      onPanUpdate: (details) {
        setState(() {
          final newWidth = (_size.width + details.delta.dx).clamp(
            minWidth,
            maxWidth,
          );
          final newHeight = (_size.height + details.delta.dy).clamp(
            minHeight,
            maxHeight,
          );
          _size = Size(newWidth, newHeight);
        });
      },
      onPanEnd: (_) {
        ref
            .read(_callOverlayStateProvider.notifier)
            .updateSize(Size(_size.width - 320, _size.height - 420));
      },
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(8),
            bottomRight: Radius.circular(16),
          ),
        ),
        child: Icon(
          Icons.drag_handle,
          size: 14,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _buildPanelContainer(
    BuildContext context,
    ThemeData theme, {
    required Widget child,
  }) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 32,
            offset: const Offset(0, 12),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: theme.colorScheme.shadow.withOpacity(0.08),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(borderRadius: BorderRadius.circular(16), child: child),
    );
  }

  Widget _buildExpandedContent(
    BuildContext context,
    WidgetRef ref,
    ThemeData theme,
    String chatRoomName,
    Duration duration,
    List<CallParticipantLive> participants,
    CallParticipantLive lastSpeaker,
    CallNotifier callNotifier,
    bool isMicrophoneEnabled,
    SnChatRoom? room,
  ) {
    return Column(
      children: [
        Row(
          children: [
            const Gap(4),
            Text(chatRoomName, style: theme.textTheme.bodySmall),
            const Gap(4),
            Text(formatDuration(duration)).bold(),
            const Gap(8),
            Icon(
              Symbols.group,
              size: 16,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const Gap(4),
            Text('${participants.length}', style: theme.textTheme.bodySmall),
            const Spacer(),
            IconButton(
              visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
              icon: const Icon(Icons.fullscreen),
              onPressed: room != null
                  ? () {
                      hideCallOverlay();
                      if (!kIsWeb && (Platform.isMacOS || Platform.isLinux || Platform.isWindows)) {
                        createCallWindow(room);
                      } else {
                        final router = ref.read(routerProvider);
                        router.pushWidget(CallScreen(room: room));
                      }
                    }
                  : null,
              tooltip: 'Full Screen',
            ),
            IconButton(
              visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
              icon: const Icon(Icons.fullscreen_exit),
              onPressed: _toggleExpanded,
              tooltip: 'Collapse',
            ),
          ],
        ).padding(horizontal: 12, vertical: 8),
        Expanded(
          child: Container(
            width: double.infinity,
            color: theme.colorScheme.surfaceContainerHighest,
            child: SingleChildScrollView(child: const CallContent()).center(),
          ),
        ),
        CallControlsBar(isCompact: true).padding(vertical: 8),
      ],
    );
  }

  Widget _buildCollapsedContent(
    BuildContext context,
    WidgetRef ref,
    ThemeData theme,
    String chatRoomName,
    Duration duration,
    List<CallParticipantLive> participants,
    CallParticipantLive lastSpeaker,
    bool isMicrophoneEnabled,
    CallNotifier callNotifier,
  ) {
    return GestureDetector(
      onTap: _toggleExpanded,
      child: Container(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SpeakingRippleAvatar(live: lastSpeaker, size: 48),
            const Gap(6),
            Text(
              chatRoomName,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
            const Gap(2),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isMicrophoneEnabled ? Icons.mic : Icons.mic_off,
                  size: 12,
                  color: isMicrophoneEnabled
                      ? theme.colorScheme.primary
                      : theme.colorScheme.error,
                ),
                const Gap(4),
                Text(
                  formatDuration(duration),
                  style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
                ),
                const Gap(4),
                Icon(
                  Symbols.group,
                  size: 12,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const Gap(2),
                Text(
                  '${participants.length}',
                  style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
                ),
              ],
            ),
            const Gap(4),
            Icon(
              Icons.expand_more,
              size: 14,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}

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
                  final router = ref.read(routerProvider);
                  if (router.canPop()) {
                    router.pop();
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
    final navContext = ref.read(routerProvider).navigatorKey.currentContext!;

    try {
      final devices = await Hardware.instance.enumerateDevices(
        type: deviceType,
      );

      if (!context.mounted) return;

      showModalBottomSheet(
        context: navContext,
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

class CallOverlayBar extends ConsumerStatefulWidget {
  final SnChatRoom room;
  const CallOverlayBar({super.key, required this.room});

  @override
  ConsumerState<CallOverlayBar> createState() => _CallOverlayBarState();
}

class _CallOverlayBarState extends ConsumerState<CallOverlayBar> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndShowOverlay();
    });
  }

  void _checkAndShowOverlay() {
    // Don't show overlay if CallScreen is active
    if (_isCallScreenActive) return;

    final callState = ref.read(callProvider);
    final activeParticipantCount = ref.read(
      activeCallParticipantCountProvider(widget.room.id),
    );
    final hasActiveCall = activeParticipantCount.maybeWhen(
      data: (count) => count > 0,
      orElse: () => false,
    );

    if (callState.isConnected || hasActiveCall) {
      showCallOverlay(widget.room);
    }
  }

  @override
  Widget build(BuildContext context) {
    final callState = ref.watch(callProvider);
    final activeParticipantCount = ref.watch(
      activeCallParticipantCountProvider(widget.room.id),
    );
    final hasActiveCall = activeParticipantCount.maybeWhen(
      data: (count) => count > 0,
      orElse: () => false,
    );

    ref.listen(callProvider.select((state) => state.isConnected), (
      previous,
      current,
    ) {
      if (current && !callState.isConnected && !_isCallScreenActive) {
        showCallOverlay(widget.room);
      }
    });

    if (!_isCallScreenActive && (callState.isConnected || hasActiveCall)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_callOverlayEntry == null) {
          showCallOverlay(widget.room);
        }
      });
    }

    return const SizedBox.shrink();
  }
}

class _JoinPromptWidget extends HookConsumerWidget {
  final SnChatRoom? room;
  final ThemeData theme;

  const _JoinPromptWidget({required this.room, required this.theme});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeParticipants = ref.watch(
      activeCallParticipantsProvider(room?.id ?? ''),
    );
    final participantsPreview = activeParticipants.maybeWhen(
      data: (value) => value,
      orElse: () => const <CallParticipant>[],
    );
    final isLoading = useState(false);

    return _buildPanelContainerStatic(
      context,
      theme,
      width: 320,
      child: Card(
        margin: EdgeInsets.zero,
        color: theme.colorScheme.surfaceContainerHighest,
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
                      color: theme.colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.videocam,
                      color: theme.colorScheme.onPrimary,
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
                      style: theme.textTheme.bodySmall,
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
                    onPressed: room != null
                        ? () async {
                            isLoading.value = true;
                            try {
                              await ref
                                  .read(callProvider.notifier)
                                  .joinRoom(room!);
                            } catch (e) {
                              showErrorAlert(e);
                            } finally {
                              isLoading.value = false;
                            }
                          }
                        : null,
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
      ),
    );
  }

  Widget _buildPanelContainerStatic(
    BuildContext context,
    ThemeData theme, {
    required double width,
    required Widget child,
  }) {
    return Container(
      width: width,
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: theme.colorScheme.outlineVariant,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 32,
                  offset: const Offset(0, 12),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
                BoxShadow(
                  color: theme.colorScheme.shadow.withOpacity(0.08),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: child,
            ),
          ),
        ],
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
    final account = ref.watch(
      callParticipantAccountProvider(participant.identity),
    );
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
