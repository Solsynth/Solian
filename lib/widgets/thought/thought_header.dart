import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

class ThoughtHeader extends StatelessWidget {
  const ThoughtHeader({
    super.key,
    required this.isStreaming,
    required this.isUser,
  });

  final bool isStreaming;
  final bool isUser;

  @override
  Widget build(BuildContext context) {
    if (!isStreaming) {
      return Row(
        spacing: 6,
        children: [
          Icon(
            isUser ? Symbols.person : Symbols.smart_toy,
            size: 16,
            color:
                isUser
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.secondary,
            fill: 1,
          ),
          Text(
            isUser ? 'thoughtUserName'.tr() : 'thoughtAiName'.tr(),
            style: Theme.of(context).textTheme.titleSmall!.copyWith(
              fontWeight: FontWeight.w600,
              color:
                  isUser
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.secondary,
            ),
          ),
        ],
      );
    } else {
      return Row(
        spacing: 6,
        children: [
          Icon(
            Symbols.smart_toy,
            size: 16,
            color:
                isUser
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.secondary,
            fill: 1,
          ),
          Text(
            'thoughtAiName'.tr(),
            style: Theme.of(context).textTheme.titleSmall!.copyWith(
              fontWeight: FontWeight.w600,
              color:
                  isUser
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.secondary,
            ),
          ),
        ],
      );
    }
  }
}
