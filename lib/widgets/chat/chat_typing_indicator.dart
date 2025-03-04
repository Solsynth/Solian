import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:provider/provider.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:surface/controllers/chat_message_controller.dart';
import 'package:surface/providers/user_directory.dart';

class ChatTypingIndicator extends StatelessWidget {
  final ChatMessageController controller;

  const ChatTypingIndicator({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final ud = context.read<UserDirectoryProvider>();

    return StyledWidget(controller.typingMembers.isEmpty
            ? const SizedBox.shrink()
            : Container(
                padding: const EdgeInsets.only(left: 16, right: 16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Theme.of(context).dividerColor,
                      width: 1 / MediaQuery.of(context).devicePixelRatio,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Symbols.more_horiz, weight: 600, size: 20),
                    const Gap(8),
                    Text(
                      'messageTyping'
                          .plural(controller.typingMembers.length, args: [
                        controller.typingMembers
                            .map((ele) => (ele.nick?.isNotEmpty ?? false)
                                ? ele.nick!
                                : ud.getFromCache(ele.accountId)?.name ??
                                    'unknown')
                            .join(', '),
                      ]),
                    ),
                  ],
                ),
              ))
        .height(controller.typingMembers.isNotEmpty ? 38 : 0, animate: true)
        .animate(
          const Duration(milliseconds: 300),
          Curves.fastLinearToSlowEaseIn,
        );
  }
}
