import 'package:flutter/material.dart';
import 'package:island/shared/widgets/layouts/sheet_scaffold.dart';
import 'package:material_symbols_icons/symbols.dart';

class IncomingCallInvite {
  final String roomId;
  final String callId;
  final String sessionId;
  final String callerId;
  final String callerName;
  final String roomName;

  const IncomingCallInvite({
    required this.roomId,
    required this.callId,
    required this.sessionId,
    required this.callerId,
    required this.callerName,
    required this.roomName,
  });

  factory IncomingCallInvite.fromJson(Map<String, dynamic> json) {
    return IncomingCallInvite(
      roomId: json['room_id']?.toString() ?? '',
      callId: json['call_id']?.toString() ?? '',
      sessionId: json['session_id']?.toString() ?? '',
      callerId: json['caller_id']?.toString() ?? '',
      callerName: json['caller_name']?.toString() ?? '',
      roomName: json['room_name']?.toString() ?? '',
    );
  }

  bool get isValid =>
      roomId.isNotEmpty && (callId.isNotEmpty || sessionId.isNotEmpty);

  String get dedupeKey =>
      callId.isNotEmpty ? 'call:$callId' : 'room:$roomId/session:$sessionId';

  String get displayCallerName =>
      callerName.trim().isNotEmpty ? callerName.trim() : 'Incoming call';

  String get displayRoomName =>
      roomName.trim().isNotEmpty ? roomName.trim() : roomId;
}

class IncomingCallInviteSheet extends StatelessWidget {
  final IncomingCallInvite invite;
  final VoidCallback onJoin;
  final VoidCallback onDismiss;

  const IncomingCallInviteSheet({
    super.key,
    required this.invite,
    required this.onJoin,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SheetScaffold(
      titleText: 'Incoming Call',
      heightFactor: 0.42,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(
              Symbols.ring_volume,
              size: 42,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              invite.displayCallerName,
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              invite.displayRoomName,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Incoming call invite',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onDismiss,
                    icon: const Icon(Symbols.close),
                    label: const Text('Dismiss'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: onJoin,
                    icon: const Icon(Symbols.call),
                    label: const Text('Join'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
