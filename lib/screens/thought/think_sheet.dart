import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:island/widgets/content/sheet.dart";
import "package:island/widgets/thought/thought_shared.dart";

class ThoughtSheet extends HookConsumerWidget {
  final List<Map<String, dynamic>> attachedMessages;
  final List<String> attachedPosts;

  const ThoughtSheet({
    super.key,
    this.attachedMessages = const [],
    this.attachedPosts = const [],
  });

  static Future<void> show(
    BuildContext context, {
    List<Map<String, dynamic>> attachedMessages = const [],
    List<String> attachedPosts = const [],
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder:
          (context) => ThoughtSheet(
            attachedMessages: attachedMessages,
            attachedPosts: attachedPosts,
          ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatState = useThoughtChat(
      ref,
      attachedMessages: attachedMessages,
      attachedPosts: attachedPosts,
    );

    return SheetScaffold(
      titleText: chatState.currentTopic.value ?? 'aiThought'.tr(),
      child: ThoughtChatInterface(
        attachedMessages: attachedMessages,
        attachedPosts: attachedPosts,
      ),
    );
  }
}
