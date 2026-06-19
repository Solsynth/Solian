import 'package:flutter/material.dart';
import 'island_call.dart';

/// A bottom sheet for inviting users to a call.
///
/// Shows a list of room members with invite buttons.
/// On iOS/macOS, uses native styling.
class InviteSheet extends StatefulWidget {
  /// Room ID to invite to.
  final String roomId;

  /// Members available to invite (id, name pairs).
  final List<InviteMember> members;

  /// Called after each invite attempt. [success] is true if the invite succeeded.
  final void Function(String accountId, bool success)? onInviteResult;

  const InviteSheet({
    super.key,
    required this.roomId,
    required this.members,
    this.onInviteResult,
  });

  /// Convenience: show the sheet from any context.
  static Future<void> show(
    BuildContext context, {
    required String roomId,
    required List<InviteMember> members,
    void Function(String accountId, bool success)? onInviteResult,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => InviteSheet(
        roomId: roomId,
        members: members,
        onInviteResult: onInviteResult,
      ),
    );
  }

  @override
  State<InviteSheet> createState() => _InviteSheetState();
}

class _InviteSheetState extends State<InviteSheet> {
  final Set<String> _inviting = {};
  final Set<String> _invited = {};

  Future<void> _invite(InviteMember member) async {
    if (_inviting.contains(member.id) || _invited.contains(member.id)) return;

    setState(() => _inviting.add(member.id));

    try {
      await IslandCall.inviteToCall(
        roomId: widget.roomId,
        targetAccountId: member.id,
      );
      _invited.add(member.id);
      widget.onInviteResult?.call(member.id, true);
    } catch (_) {
      widget.onInviteResult?.call(member.id, false);
    } finally {
      if (mounted) setState(() => _inviting.remove(member.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.6,
      ),
      margin: EdgeInsets.only(bottom: bottomPadding),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(
              children: [
                const Icon(Icons.person_add_outlined, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Invite to call',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                Text(
                  '${widget.members.length}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          Flexible(
            child: widget.members.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(24),
                    child: Text('No members to invite'),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: widget.members.length,
                    itemBuilder: (context, index) {
                      final member = widget.members[index];
                      final isInviting = _inviting.contains(member.id);
                      final isInvited = _invited.contains(member.id);

                      return ListTile(
                        leading: CircleAvatar(
                          radius: 18,
                          backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                          child: Text(
                            member.name.isNotEmpty ? member.name[0].toUpperCase() : '?',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                        title: Text(member.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                        trailing: isInvited
                            ? const Icon(Icons.check_circle, color: Colors.green, size: 20)
                            : isInviting
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : IconButton(
                                    icon: const Icon(Icons.add_call, size: 20),
                                    onPressed: () => _invite(member),
                                  ),
                      );
                    },
                  ),
          ),

          SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
        ],
      ),
    );
  }
}

/// Represents a room member that can be invited.
class InviteMember {
  final String id;
  final String name;

  const InviteMember({required this.id, required this.name});
}
