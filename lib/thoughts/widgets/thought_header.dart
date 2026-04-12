import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/account_pod.dart';
import 'package:island/core/utils/text.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
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
            Icon(
              Symbols.smart_toy,
              size: 16,
              color: isUser
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.secondary,
              fill: 1,
            ),
          Text(
            isUser
                ? userInfo.value?.nick ?? 'unknown'.tr()
                : 'thinkService${botName.capitalizeEachWord()}'.tr(),
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
          Icon(
            Symbols.smart_toy,
            size: 16,
            color: isUser
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.secondary,
            fill: 1,
          ),
          Text(
            'thinkService${botName.capitalizeEachWord()}'.tr(),
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
