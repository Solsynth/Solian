import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_hooks/flutter_hooks.dart";
import "package:gap/gap.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:island/shared/widgets/responsive_sidebar.dart";
import "package:island/thoughts/screens/think.dart";
import "package:island/thoughts/widgets/billing_status_handler.dart";
import "package:island/thoughts/widgets/thought_shared.dart";
import "package:island/thoughts/widgets/thought_sidebar.dart";
import "package:material_symbols_icons/material_symbols_icons.dart";

/// A sheet-based thought chat interface that uses [ResponsiveSidebar].
///
/// This provides a modal bottom sheet with a sidebar for conversation selection
/// and a main chat area. The sidebar adapts responsively based on screen size.
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

  /// Shows the thought sheet as a modal bottom sheet.
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
    final showSidebar = useState(false);

    void refreshStatus() => ref.invalidate(thoughtAvailableStausProvider);

    void startNewConversation() {
      chatState.sequenceId.value = null;
      chatState.localThoughts.value = [];
      chatState.currentTopic.value = 'aiThought'.tr();
      showSidebar.value = false;
    }

    void toggleSidebar() => showSidebar.value = !showSidebar.value;

    void closeSidebar() => showSidebar.value = false;

    void handleSequenceSelected(String sequenceId) {
      // TODO: Load the selected sequence
      // For now, just close the sidebar
      showSidebar.value = false;
    }

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Scaffold(
          appBar: AppBar(
            title: Text(chatState.currentTopic.value ?? 'aiThought'.tr()),
            leading: IconButton(
              icon: const Icon(Symbols.close),
              onPressed: () => Navigator.of(context).pop(),
              tooltip: 'close'.tr(),
            ),
            actions: [
              IconButton(
                icon: const Icon(Symbols.add),
                onPressed: startNewConversation,
                tooltip: 'newConversation'.tr(),
              ),
              IconButton(
                icon: const Icon(Symbols.history),
                onPressed: toggleSidebar,
                tooltip: 'conversations'.tr(),
              ),
              const Gap(8),
            ],
          ),
          body: ResponsiveSidebar(
            showSidebar: showSidebar,
            sidebarWidth: 320,
            sidebarContent: ThoughtSidebar(
              selectedSequenceId: chatState.sequenceId.value,
              onSequenceSelected: handleSequenceSelected,
              onClose: closeSidebar,
            ),
            mainContent: BillingStatusHandler(
              statusAsync: statusAsync,
              onRefreshStatus: refreshStatus,
              child: ThoughtChatInterface(
                attachedMessages: attachedMessages,
                attachedPosts: attachedPosts,
                isDisabled: statusAsync.value == false,
              ),
            ),
          ),
        );
      },
    );
  }
}
