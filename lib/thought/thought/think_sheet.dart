import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_hooks/flutter_hooks.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:island/core/network.dart";
import "package:island/shared/widgets/alert.dart";
import "package:island/core/widgets/content/sheet_scaffold.dart";
import "package:island/thought/thought/think.dart";
import "package:island/thought/thought_widgets/thought/thought_shared.dart";
import "package:material_symbols_icons/material_symbols_icons.dart";

class ThoughtSheet extends HookConsumerWidget {
  final String? initialMessage;
  final List<Map<String, dynamic>> attachedMessages;
  final List<String> attachedPosts;

  const ThoughtSheet({
    super.key,
    this.initialMessage,
    this.attachedMessages = const [],
    this.attachedPosts = const [],
  });

  static Future<void> show(
    BuildContext context, {
    String? initialMessage,
    List<Map<String, dynamic>> attachedMessages = const [],
    List<String> attachedPosts = const [],
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => ThoughtSheet(
        initialMessage: initialMessage,
        attachedMessages: attachedMessages,
        attachedPosts: attachedPosts,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatState = useThoughtChat(
      ref,
      initialMessage: initialMessage,
      attachedMessages: attachedMessages,
      attachedPosts: attachedPosts,
    );

    final statusAsync = ref.watch(thoughtAvailableStausProvider);

    return SheetScaffold(
      titleText: chatState.currentTopic.value ?? 'aiThought'.tr(),
      child: statusAsync.maybeWhen(
        data: (status) {
          final retry = useMemoized(
            () => () async {
              showLoadingModal(context);
              try {
                await ref
                    .read(apiClientProvider)
                    .post('/insight/billing/retry');
                showSnackBar('Retried billing process');
                ref.invalidate(thoughtAvailableStausProvider);
              } catch (e) {
                showSnackBar('Failed to retry billing');
              }
              if (context.mounted) hideLoadingModal(context);
            },
            [context, ref],
          );

          final chatInterface = ThoughtChatInterface(
            attachedMessages: attachedMessages,
            attachedPosts: attachedPosts,
            isDisabled: !status,
          );
          return status
              ? chatInterface
              : Column(
                  children: [
                    MaterialBanner(
                      leading: const Icon(Symbols.error),
                      content: const Text(
                        'You have unpaid orders. Please settle your payment to continue using the service.',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            retry();
                          },
                          child: Text('retry'.tr()),
                        ),
                      ],
                    ),
                    Expanded(child: chatInterface),
                  ],
                );
        },
        orElse: () => ThoughtChatInterface(
          attachedMessages: attachedMessages,
          attachedPosts: attachedPosts,
        ),
      ),
    );
  }
}
