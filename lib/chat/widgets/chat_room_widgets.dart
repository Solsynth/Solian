import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:relative_time/relative_time.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

class ChatRoomAvatar extends StatelessWidget {
  final SnChatRoom room;
  final bool isDirect;
  final AsyncValue<SnChatSummary?> summary;
  final List<SnChatMember> validMembers;
  final bool hideRealm;
  final double? radius;

  const ChatRoomAvatar({
    super.key,
    required this.room,
    required this.isDirect,
    required this.summary,
    required this.validMembers,
    this.hideRealm = false,
    this.radius,
  });

  @override
  Widget build(BuildContext context) {
    final avatarChild = (isDirect && room.picture == null)
        ? SplitAvatarWidget(
            files: validMembers.map((e) => e.account.profile.picture).toList(),
            radius: radius ?? 20,
          )
        : room.picture == null
        ? CircleAvatar(
            radius: radius,
            child: Text((room.name ?? 'DM')[0].toUpperCase()),
          )
        : ProfilePictureWidget(file: room.picture, radius: radius ?? 20);

    final badgeChild = Badge(
      isLabelVisible: summary.when(
        data: (data) => (data?.unreadCount ?? 0) > 0,
        loading: () => false,
        error: (_, _) => false,
      ),
      child: avatarChild,
    );

    // Show realm avatar as small overlay if chat belongs to a realm
    if (room.realm != null && !hideRealm) {
      return Stack(
        children: [
          badgeChild,
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipOval(
                child: ProfilePictureWidget(file: room.realm!.picture),
              ),
            ),
          ),
        ],
      );
    }

    return badgeChild;
  }
}

class ChatRoomSubtitle extends StatelessWidget {
  final SnChatRoom room;
  final bool isDirect;
  final List<SnChatMember> validMembers;
  final AsyncValue<SnChatSummary?> summary;
  final Widget? subtitle;

  const ChatRoomSubtitle({
    super.key,
    required this.room,
    required this.isDirect,
    required this.validMembers,
    required this.summary,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    if (subtitle != null) return subtitle!;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      layoutBuilder: (currentChild, previousChildren) => Stack(
        alignment: Alignment.centerLeft,
        children: [...previousChildren, ?currentChild],
      ),
      child: summary.when(
        data: (data) => Container(
          key: const ValueKey('data'),
          child: data == null
              ? isDirect && room.description == null
                    ? Text(
                        validMembers
                            .map((e) => '@${e.account.name}')
                            .join(', '),
                        maxLines: 1,
                      )
                    : Text(
                        room.description ?? 'descriptionNone'.tr(),
                        maxLines: 1,
                      )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (data.unreadCount > 0)
                      Text(
                        'unreadMessages'.plural(data.unreadCount),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    if (data.lastMessage == null)
                      Text(
                        room.description ?? 'descriptionNone'.tr(),
                        maxLines: 1,
                      )
                    else
                      Row(
                        spacing: 4,
                        children: [
                          Badge(
                            label: Text(data.lastMessage!.sender.account.nick),
                            textColor: Theme.of(context).colorScheme.onPrimary,
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.primary,
                          ),
                          Expanded(
                            child: Text(
                              (data.lastMessage!.content?.isNotEmpty ?? false)
                                  ? data.lastMessage!.content!
                                  : 'messageNone'.tr(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              RelativeTime(
                                context,
                              ).format(data.lastMessage!.createdAt),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
        ),
        loading: () => Container(
          key: const ValueKey('loading'),
          child: Builder(
            builder: (context) {
              final seed = DateTime.now().microsecondsSinceEpoch;
              final len = 4 + (seed % 17); // 4..20 inclusive
              const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
              var s = seed;
              final buffer = StringBuffer();
              for (var i = 0; i < len; i++) {
                s = (s * 1103515245 + 12345) & 0x7fffffff;
                buffer.write(chars[s % chars.length]);
              }
              return Skeletonizer(
                enabled: true,
                child: Text(buffer.toString()),
              );
            },
          ),
        ),
        error: (_, _) => Container(
          key: const ValueKey('error'),
          child: isDirect && room.description == null
              ? Text(
                  validMembers.map((e) => '@${e.account.name}').join(', '),
                  maxLines: 1,
                )
              : Text(room.description ?? 'descriptionNone'.tr(), maxLines: 1),
        ),
      ),
    );
  }
}
