import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/account_pod.dart';
import 'package:island/accounts/relationship_pod.dart';
import 'package:island/accounts/utils/account_status_utils.dart';
import 'package:island/chat/widgets/chat_member_list_tile.dart';
import 'package:island/core/network.dart';
import 'package:island/core/websocket.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

void _showOnlineMembers(BuildContext context, String roomId) {
  showModalBottomSheet(
    context: context,
    builder: (context) => _OnlineMembersSheet(roomId: roomId),
  );
}

class _OnlineMembersSheet extends HookConsumerWidget {
  final String roomId;
  const _OnlineMembersSheet({required this.roomId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const pageSize = 10;
    final members = useState<List<SnChatMember>>(const []);
    final loading = useState(true);
    final error = useState<String?>(null);
    final noMore = useState(false);

    useEffect(() {
      Future<void> fetch() async {
        loading.value = true;
        error.value = null;
        members.value = [];
        noMore.value = false;

        try {
          final apiClient = ref.read(apiClientProvider);
          var offset = 0;

          while (true) {
            final response = await apiClient.get(
              '/messager/chat/$roomId/members',
              queryParameters: {
                'offset': offset.toString(),
                'take': pageSize.toString(),
                'withStatus': true,
              },
            );
            final page = (response.data as List)
                .map((e) => SnChatMember.fromJson(e))
                .cast<SnChatMember>()
                .toList();

            if (page.isEmpty) break;

            // Server sorts online first; stop at first offline member.
            final firstOffline = page.indexWhere(
              (m) => m.status?.isOnline != true,
            );
            final onlineOnPage = firstOffline == -1
                ? page
                : page.sublist(0, firstOffline);
            members.value = [...members.value, ...onlineOnPage];

            if (firstOffline != -1 || page.length < pageSize) {
              noMore.value = true;
              break;
            }
            offset += pageSize;
          }
        } catch (e) {
          error.value = e.toString();
        }

        loading.value = false;
      }

      fetch();
      return null;
    }, [roomId]);

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Text(
                  error.value != null
                      ? 'chatPeopleOnline'.plural(0)
                      : loading.value
                      ? 'chatPeopleOnline'.plural(0)
                      : 'chatPeopleOnline'.plural(members.value.length),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          if (loading.value && members.value.isEmpty)
            const SizedBox(
              height: 200,
              child: Center(child: CircularProgressIndicator()),
            )
          else if (error.value != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Center(child: Text('Error: ${error.value}')),
            )
          else if (members.value.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Center(child: Text('chatNoOnlineMembers'.tr())),
            )
          else
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount:
                    members.value.length +
                    (loading.value && !noMore.value ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == members.value.length) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    );
                  }
                  return ChatMemberListTile(member: members.value[index]);
                },
              ),
            ),
        ],
      ),
    );
  }
}

List<SnChatMember> getValidMembers(List<SnChatMember> members, String? userId) {
  return members.where((member) => member.accountId != userId).toList();
}

class RoomAppBar extends ConsumerWidget {
  final SnChatRoom room;
  final SnChatOnlineStatus? onlineStatus;

  const RoomAppBar({super.key, required this.room, required this.onlineStatus});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userInfo = ref.watch(userInfoProvider);
    final validMembers = getValidMembers(
      room.members ?? [],
      userInfo.value?.id,
    );
    final isDirect = room.type == 1;
    String title;
    if (isDirect && room.name == null) {
      // Look up relationship aliases for each member
      final memberNames = <String>[];
      for (final member in validMembers) {
        final aliasAsync = ref.watch(
          relationshipAliasProvider(member.accountId),
        );
        final alias = aliasAsync.hasValue ? aliasAsync.value : null;
        memberNames.add(
          (alias != null && alias.isNotEmpty) ? alias : member.account.nick,
        );
      }
      title = memberNames.join(', ');
    } else {
      title = room.name!;
    }
    final weakInternetMode = ref.watch(weakInternetModeProvider);
    final subtitle = _buildSubtitle(
      context,
      room,
      validMembers,
      onlineStatus,
      userInfo.value?.id,
      weakInternetMode,
    );
    final hasOnlineAccounts =
        room.type != 1 && (onlineStatus?.onlineAccounts.isNotEmpty == true);

    return Row(
      spacing: 12,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        _RoomAvatar(room: room, validMembers: validMembers, size: 28),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ).fontSize(17),
              if (subtitle != null)
                GestureDetector(
                  onTap: hasOnlineAccounts
                      ? () => _showOnlineMembers(context, room.id)
                      : null,
                  child: subtitle,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

Widget? _buildSubtitle(
  BuildContext context,
  SnChatRoom room,
  List<SnChatMember> validMembers,
  SnChatOnlineStatus? onlineStatus,
  String? currentUserId,
  bool weakInternetMode,
) {
  final subtitleStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
    fontSize: 11,
    height: 1,
    color:
        Theme.of(context).appBarTheme.foregroundColor ??
        Theme.of(context).colorScheme.onSurface,
  );

  if (room.type == 1) {
    final status = onlineStatus?.directMessageStatus;
    final isBot = validMembers.any(
      (member) => member.account.automatedId != null,
    );
    final label = status != null
        ? getStatusDisplayLabel(context, status)
        : null;
    if (label == null && !isBot && !weakInternetMode) return null;
    final statusColor = getStatusIndicatorColor(status);
    final isOnline = showsOnlinePresence(status);

    return Row(
      children: [
        if (weakInternetMode) ...[
          _WeakInternetChip(style: subtitleStyle),
          if (label != null || isBot) const SizedBox(width: 6),
        ],
        if (label != null) ...[
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(right: 6),
            decoration: BoxDecoration(
              color: isOnline ? statusColor : Colors.transparent,
              shape: BoxShape.circle,
              border: Border.all(color: statusColor, width: isOnline ? 0 : 1.5),
            ),
          ),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: subtitleStyle,
            ),
          ),
        ],
        if (label != null && isBot) const SizedBox(width: 6),
        if (isBot) _BotChip(style: subtitleStyle),
      ],
    );
  }

  final onlineNames =
      onlineStatus?.onlineAccounts
          .where((account) => account.id != currentUserId)
          .map((account) => account.nick.trim())
          .where((name) => name.isNotEmpty)
          .toList() ??
      const <String>[];

  String subtitleText;
  if (onlineNames.isNotEmpty) {
    final preview = onlineNames.take(3).join(', ');
    final remaining = onlineNames.length - 3;
    subtitleText = remaining > 0
        ? '$preview +$remaining online'
        : '$preview online';
  } else {
    final count = onlineStatus?.onlineCount ?? 0;
    subtitleText = count > 0
        ? '$count online'
        : '${validMembers.length} members';
  }

  return Row(
    children: [
      if (weakInternetMode) ...[
        _WeakInternetChip(style: subtitleStyle),
        const SizedBox(width: 6),
      ],
      if (_shouldShowSubtitleOnlineDot(room, onlineStatus))
        Container(
          width: 6,
          height: 6,
          margin: const EdgeInsets.only(right: 6),
          decoration: const BoxDecoration(
            color: Colors.green,
            shape: BoxShape.circle,
          ),
        ),
      Expanded(
        child: Text(
          subtitleText,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: subtitleStyle,
        ),
      ),
    ],
  );
}

class _WeakInternetChip extends StatelessWidget {
  final TextStyle? style;

  const _WeakInternetChip({required this.style});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.18),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.amber.withOpacity(0.45)),
      ),
      child: Text(
        'weakInternetMode'.tr(),
        style: style?.copyWith(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
      ),
    );
  }
}

bool _shouldShowSubtitleOnlineDot(
  SnChatRoom room,
  SnChatOnlineStatus? onlineStatus,
) {
  return room.type != 1 && (onlineStatus?.onlineCount ?? 0) >= 2;
}

class _BotChip extends StatelessWidget {
  final TextStyle? style;

  const _BotChip({required this.style});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
      decoration: BoxDecoration(
        color: colorScheme.primary.withOpacity(0.18),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: colorScheme.primary.withOpacity(0.35)),
      ),
      child: Text(
        'Bot',
        style: style?.copyWith(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: colorScheme.primary,
        ),
      ),
    );
  }
}

class _RoomAvatar extends StatelessWidget {
  final SnChatRoom room;
  final List<SnChatMember> validMembers;
  final double size;

  const _RoomAvatar({
    required this.room,
    required this.validMembers,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size,
      width: size,
      child: (room.type == 1 && room.picture == null)
          ? SplitAvatarWidget(
              files: validMembers
                  .map((e) => e.account.profile.picture)
                  .toList(),
            )
          : room.picture != null
          ? ProfilePictureWidget(file: room.picture, fallbackIcon: Symbols.chat)
          : CircleAvatar(
              child: Text(
                room.name![0].toUpperCase(),
                style: const TextStyle(fontSize: 12),
              ),
            ),
    );
  }
}
