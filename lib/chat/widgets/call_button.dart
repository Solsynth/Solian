import 'dart:io' show Platform;
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/account_pod.dart';
import 'package:island/chat/pods/call.dart';
import 'package:island/chat/pods/call_participants.dart';
import 'package:island/chat/pods/native_call_bridge.dart';
import 'package:island/chat/widgets/call_overlay.dart';
import 'package:island/chat/widgets/call_window.dart';
import 'package:island/chat/widgets/pending_join_sheet.dart';
import 'package:island/core/network.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

part 'call_button.g.dart';

final activeCallParticipantCountProvider = FutureProvider.family<int, String>((
  ref,
  roomId,
) async {
  if (roomId.isEmpty) return 0;
  try {
    final apiClient = ref.watch(apiClientProvider);
    final resp = await apiClient.get(
      '/messager/chat/realtime/$roomId/participants',
    );
    final data = resp.data;
    if (data is List) return data.length;
    return 0;
  } catch (e) {
    if (e is DioException) {
      final statusCode = e.response?.statusCode;
      if (statusCode == 403 || statusCode == 404) {
        return 0;
      }
    }
    return 0;
  }
});

final activeCallParticipantsProvider =
    FutureProvider.family<List<CallParticipant>, String>((ref, roomId) async {
      if (roomId.isEmpty) return const [];
      try {
        final apiClient = ref.watch(apiClientProvider);
        final resp = await apiClient.get(
          '/messager/chat/realtime/$roomId/participants',
        );
        final data = resp.data;
        if (data is! List) return const [];
        return data
            .whereType<Map>()
            .map((e) => CallParticipant.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      } catch (e) {
        if (e is DioException) {
          final statusCode = e.response?.statusCode;
          if (statusCode == 403 || statusCode == 404) {
            return const [];
          }
        }
        return const [];
      }
    });

@riverpod
Future<SnRealtimeCall?> ongoingCall(Ref ref, String roomId) async {
  if (roomId.isEmpty) return null;
  try {
    final apiClient = ref.watch(apiClientProvider);
    final resp = await apiClient.get('/messager/chat/realtime/$roomId');
    return SnRealtimeCall.fromJson(resp.data);
  } catch (e) {
    if (e is DioException && e.response?.statusCode == 404) {
      return null;
    }
    showErrorAlert(e);
    return null;
  }
}

class AudioCallButton extends HookConsumerWidget {
  final SnChatRoom room;
  const AudioCallButton({super.key, required this.room});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeParticipantCount = ref.watch(
      activeCallParticipantCountProvider(room.id),
    );
    final hasActiveCall = activeParticipantCount.maybeWhen(
      data: (count) => count > 0,
      orElse: () => false,
    );
    final callState = ref.watch(callProvider);
    final callNotifier = ref.read(callProvider.notifier);
    final currentUserId = ref.watch(userInfoProvider).value?.id;
    final nativeBridge = ref.watch(nativeCallBridgeProvider);
    final isLoading = useState(false);
    final apiClient = ref.watch(apiClientProvider);

    // ponytail: In-app calls always use Flutter. CallKit is only for system-level (push/lock screen).
    // Also check if a CallKit call is active for this room.
    final hasNativeAcceptedCall =
        nativeBridge.callKitAcceptedRoomId == room.id &&
        (nativeBridge.isConnected || nativeBridge.isAcceptedPending);
    final isInCall = callState.isConnected || hasNativeAcceptedCall;

    String callKitDisplayName() {
      if (room.name?.trim().isNotEmpty == true) return room.name!.trim();
      final other = (room.members ?? const <SnChatMember>[])
          .where((m) => m.accountId != currentUserId)
          .firstOrNull;
      return other?.nick?.trim().isNotEmpty == true
          ? other!.nick!.trim()
          : other?.account.nick.trim().isNotEmpty == true
          ? other!.account.nick.trim()
          : 'Voice Call';
    }

    Future<void> openCallScreen({bool cameraEnabled = false}) async {
      if (!kIsWeb &&
          (Platform.isMacOS || Platform.isLinux || Platform.isWindows)) {
        await createCallWindow(room, cameraEnabled: cameraEnabled);
      } else {
        await pushCallScreenOnce(
          ref,
          room,
          cameraEnabled: cameraEnabled,
        );
      }
    }

    Future<void> handleJoin() async {
      isLoading.value = true;
      try {
        // Show pending join sheet
        final result = await showModalBottomSheet<({bool cameraEnabled})>(
          context: context,
          useSafeArea: true,
          isScrollControlled: true,
          builder: (context) => PendingJoinSheet(
            room: room,
            onJoin: (settings) => Navigator.pop(context, settings),
          ),
        );

        if (result == null) {
          isLoading.value = false;
          return;
        }

        if (isNativeCallAvailable) {
          await ref.read(nativeCallBridgeProvider.notifier).startOutgoingCall(
            roomId: room.id,
            callerName: callKitDisplayName(),
            hasVideo: result.cameraEnabled,
          );
          await ref.read(nativeCallBridgeProvider.notifier).markOutgoingConnecting();
        }

        // Open call screen with camera setting
        await openCallScreen(cameraEnabled: result.cameraEnabled);
      } catch (e) {
        showErrorAlert(e);
      } finally {
        isLoading.value = false;
      }
    }

    Future<void> handleEnd() async {
      isLoading.value = true;
      try {
        await apiClient.delete('/messager/chat/realtime/${room.id}');
        if (isNativeCallAvailable && nativeBridge.callUuid != null) {
          await ref.read(nativeCallBridgeProvider.notifier).endCall();
        }
        await callNotifier.disconnect();
        callNotifier.dispose();
        ref.invalidate(activeCallParticipantCountProvider(room.id));
        ref.read(callParticipantAccountCacheProvider.notifier).clear();
      } catch (e) {
        showErrorAlert(e);
      } finally {
        isLoading.value = false;
      }
    }

    if (isLoading.value) {
      return IconButton(
        icon: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Theme.of(context).appBarTheme.foregroundColor!,
            padding: EdgeInsets.all(4),
          ),
        ),
        onPressed: null,
      );
    }

    if (isInCall) {
      // Show end call button if in call
      return IconButton(
        icon: const Icon(Icons.call_end),
        tooltip: 'Leave Call',
        onPressed: handleEnd,
      );
    }

    if (hasActiveCall) {
      // There is an ongoing call, offer to join it directly
      return FilledButton.icon(
        icon: const Icon(Icons.call),
        label: Text('${activeParticipantCount.value}'),
        style: FilledButton.styleFrom(
          visualDensity: VisualDensity.compact,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          minimumSize: const Size(0, 36),
        ),
        onPressed: () async {
          isLoading.value = true;
          try {
            // Show pending join sheet
            final result = await showModalBottomSheet<({bool cameraEnabled})>(
              context: context,
              useSafeArea: true,
              isScrollControlled: true,
              builder: (context) => PendingJoinSheet(
                room: room,
                onJoin: (settings) => Navigator.pop(context, settings),
              ),
            );

            if (result == null) {
              isLoading.value = false;
              return;
            }

            if (isNativeCallAvailable) {
              await ref
                  .read(nativeCallBridgeProvider.notifier)
                  .startOutgoingCall(
                    roomId: room.id,
                    callerName: callKitDisplayName(),
                    hasVideo: result.cameraEnabled,
                  );
              await ref
                  .read(nativeCallBridgeProvider.notifier)
                  .markOutgoingConnecting();
            }

            await openCallScreen(cameraEnabled: result.cameraEnabled);
          } catch (e) {
            showErrorAlert(e);
          } finally {
            isLoading.value = false;
          }
        },
      );
    }

    // Show join/start call button
    return IconButton(
      icon: const Icon(Icons.call),
      tooltip: 'Join Call',
      onPressed: handleJoin,
    );
  }
}
