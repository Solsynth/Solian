import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/chat/widgets/call_button.dart';
import 'package:island/shared/widgets/layouts/sheet_scaffold.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

/// Shows a sheet before joining a call where user can:
/// - Toggle camera on/off
/// - See who's already in the call
/// - Confirm to join
class PendingJoinSheet extends HookConsumerWidget {
  final SnChatRoom room;
  final ValueChanged<({bool cameraEnabled})> onJoin;

  const PendingJoinSheet({
    super.key,
    required this.room,
    required this.onJoin,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cameraEnabled = useState(false);
    final participants = ref.watch(activeCallParticipantsProvider(room.id));

    return SheetScaffold(
      titleText: 'Join Call',
      heightFactor: 0.6,
      child: Column(
        children: [
          // Camera toggle
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                Icon(
                  cameraEnabled.value ? Symbols.videocam : Symbols.videocam_off,
                  color: cameraEnabled.value
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Camera',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      Text(
                        'Your camera will be ${cameraEnabled.value ? 'on' : 'off'} when joining',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: cameraEnabled.value,
                  onChanged: (v) => cameraEnabled.value = v,
                ),
              ],
            ),
          ),

          // Mic info (always on)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                Icon(
                  Symbols.mic,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Microphone',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      Text(
                        'Your microphone will be on',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Symbols.check_circle,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
              ],
            ),
          ),

          const Divider(height: 24),

          // Participants header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Text(
                  'In the call',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const Spacer(),
                participants.maybeWhen(
                  data: (list) => Text(
                    '${list.length}',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  orElse: () => const SizedBox.shrink(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Participants list
          Expanded(
            child: participants.when(
              data: (list) {
                if (list.isEmpty) {
                  return Center(
                    child: Text(
                      'No one in the call yet',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final participant = list[index];
                    return _ParticipantTile(participant: participant);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Text(
                  'Failed to load participants',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ),
            ),
          ),

          // Join button
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: FilledButton.icon(
                onPressed: () => onJoin((
                  cameraEnabled: cameraEnabled.value,
                )),
                icon: const Icon(Symbols.call),
                label: const Text('Join Call'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ParticipantTile extends StatelessWidget {
  final CallParticipant participant;

  const _ParticipantTile({required this.participant});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        child: Text(
          participant.name.isNotEmpty ? participant.name[0].toUpperCase() : '?',
        ),
      ),
      title: Text(participant.name),
      subtitle: Text(
        participant.identity,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
