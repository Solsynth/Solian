import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/models/chat.dart';
import 'package:island/pods/chat/call.dart';
import 'package:island/pods/network.dart';
import 'package:island/widgets/alert.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'call_button.g.dart';

@riverpod
Future<SnRealtimeCall?> ongoingCall(Ref ref, String roomId) async {
  if (roomId.isEmpty) return null;
  try {
    final apiClient = ref.watch(apiClientProvider);
    final resp = await apiClient.get('/sphere/chat/realtime/$roomId');
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
    final ongoingCall = ref.watch(ongoingCallProvider(room.id));
    final callState = ref.watch(callNotifierProvider);
    final callNotifier = ref.read(callNotifierProvider.notifier);
    final isLoading = useState(false);
    final apiClient = ref.watch(apiClientProvider);

    Future<void> handleJoin() async {
      isLoading.value = true;
      try {
        await apiClient.post('/sphere/chat/realtime/${room.id}');
        // Just join the room, the overlay will handle the UI
        await callNotifier.joinRoom(room);
      } catch (e) {
        showErrorAlert(e);
      } finally {
        isLoading.value = false;
      }
    }

    Future<void> handleEnd() async {
      isLoading.value = true;
      try {
        await apiClient.delete('/sphere/chat/realtime/${room.id}');
        callNotifier.dispose(); // Clean up call resources
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

    if (callState.isConnected) {
      // Show end call button if in call
      return IconButton(
        icon: const Icon(Icons.call_end),
        tooltip: 'End Call',
        onPressed: handleEnd,
      );
    }

    if (ongoingCall.value != null) {
      // There is an ongoing call, offer to join it directly
      return IconButton(
        icon: const Icon(Icons.call),
        tooltip: 'Join Ongoing Call',
        onPressed: () async {
          isLoading.value = true;
          try {
            await callNotifier.joinRoom(room);
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
      tooltip: 'Start Call',
      onPressed: handleJoin,
    );
  }
}
