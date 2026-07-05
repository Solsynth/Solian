import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/widgets/account/account_name.dart';
import 'package:island/chat/pods/call_participants.dart';
import 'package:island/chat/widgets/call_button.dart';
import 'package:island/drive/widgets/cloud_files.dart' show ProfilePictureWidget;
import 'package:island/shared/widgets/layouts/sheet_scaffold.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

/// Shows a sheet before joining a call where user can:
/// - Toggle camera on/off
/// - See who's already in the call
/// - Confirm to join
class PendingJoinSheet extends HookConsumerWidget {
  final SnChatRoom room;
  final ValueChanged<({bool cameraEnabled, bool microphoneEnabled})> onJoin;

  const PendingJoinSheet({
    super.key,
    required this.room,
    required this.onJoin,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cameraEnabled = useState(false);
    final microphoneEnabled = useState(true);
    final participants = ref.watch(activeCallParticipantsProvider(room.id));

    return SheetScaffold(
      titleText: 'Join Call',
      heightFactor: 0.6,
      child: Column(
        children: [
          // Toggles
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      cameraEnabled.value
                          ? Symbols.videocam
                          : Symbols.videocam_off,
                      color: cameraEnabled.value
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Camera',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                    Switch(
                      value: cameraEnabled.value,
                      onChanged: (v) => cameraEnabled.value = v,
                    ),
                  ],
                ),
                Row(
                  children: [
                    Icon(
                      microphoneEnabled.value ? Symbols.mic : Symbols.mic_off,
                      color: microphoneEnabled.value
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Microphone',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                    Switch(
                      value: microphoneEnabled.value,
                      onChanged: (v) => microphoneEnabled.value = v,
                    ),
                  ],
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
          const SizedBox(height: 12),

          // Participants — avatar grid like CallContent audio-only mode
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
                return Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 480),
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 20,
                      runSpacing: 16,
                      children: [
                        for (final p in list)
                          _ParticipantAvatar(participant: p),
                      ],
                    ),
                  ),
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
                  microphoneEnabled: microphoneEnabled.value,
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

/// Avatar + name tile matching CallContent's audio-only layout.
class _ParticipantAvatar extends HookConsumerWidget {
  final CallParticipant participant;
  const _ParticipantAvatar({required this.participant});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final account = ref.watch(callParticipantAccountProvider(participant.identity));

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        account.value?.profile.picture != null
            ? ProfilePictureWidget(
                file: account.value!.profile.picture,
                radius: 42,
              )
            : CircleAvatar(
                radius: 42,
                backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: Text(
                  participant.name.isNotEmpty
                      ? participant.name[0].toUpperCase()
                      : '?',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
        const SizedBox(height: 8),
        SizedBox(
          width: 100,
          child: account.value != null
              ? AccountName(
                  account: account.value!,
                  style: Theme.of(context).textTheme.bodySmall,
                  hideVerificationMark: true,
                )
              : Text(
                  participant.name,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
        ),
      ],
    );
  }
}
