import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/account_pod.dart';
import 'package:island/core/utils/text.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:island/thoughts/widgets/bot_avatar_widget.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

class ThoughtHeader extends HookConsumerWidget {
  final String agentService;
  final SnThinkingThought? item;
  const ThoughtHeader({
    super.key,
    required this.agentService,
    required this.item,
    required this.isStreaming,
    required this.isUser,
  });

  final bool isStreaming;
  final bool isUser;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userInfo = ref.watch(userInfoProvider);
    final botName = item?.botName ?? agentService;
    final botAccount = ref.watch(accountInfoProvider(botName));

    // Use the bot's nick if available, otherwise fall back to translated service name
    final botDisplayName = botAccount.when(
      data: (account) =>
          account?.nick ?? 'thinkService${botName.capitalizeEachWord()}'.tr(),
      loading: () => 'thinkService${botName.capitalizeEachWord()}'.tr(),
      error: (err, stack) => 'thinkService${botName.capitalizeEachWord()}'.tr(),
    );

    if (!isStreaming) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        spacing: 6,
        children: [
          if (isUser)
            ProfilePictureWidget(
              file: userInfo.value?.profile.picture,
              radius: 8,
            )
          else
            BotAvatarWidget(botName: botName, radius: 8),
          Text(
            isUser ? userInfo.value?.nick ?? 'unknown'.tr() : botDisplayName,
            style: Theme.of(context).textTheme.titleSmall!.copyWith(
              fontWeight: FontWeight.w600,
              color: isUser
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.secondary,
            ),
          ),
        ],
      );
    } else {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        spacing: 6,
        children: [
          BotAvatarWidget(botName: botName, radius: 8),
          Text(
            botDisplayName,
            style: Theme.of(context).textTheme.titleSmall!.copyWith(
              fontWeight: FontWeight.w600,
              color: isUser
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.secondary,
            ),
          ),
        ],
      );
    }
  }
}
