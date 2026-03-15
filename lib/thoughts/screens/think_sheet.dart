import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_hooks/flutter_hooks.dart";
import "package:gap/gap.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:island/core/services/responsive.dart";
import "package:island/shared/widgets/responsive_sidebar.dart";
import "package:island/thoughts/screens/think.dart";
import "package:island/thoughts/widgets/billing_status_handler.dart";
import "package:island/thoughts/widgets/thought_chat_notifier.dart";
import "package:island/thoughts/widgets/thought_shared.dart";
import "package:island/thoughts/widgets/thought_sidebar.dart";
import "package:material_symbols_icons/material_symbols_icons.dart";

/// A dialog-based thought chat interface that uses [ResponsiveSidebar].
///
/// On wide screens: Shows as a non-blocking floating panel on the right side
///   - Allows interaction with background widgets
///   - Full height, draggable/resizable like a window
/// On mobile screens: Shows as a full screen dialog
/// The sidebar adapts responsively based on screen size for conversation selection.
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

  /// Shows the thought sheet.
  /// On wide screens: Displays as a non-blocking floating panel on the right
  /// On mobile: Displays as a full screen dialog
  static Future<void> show(
    BuildContext context, {
    String? initialMessage,
    List<Map<String, dynamic>> attachedMessages = const [],
    List<String> attachedPosts = const [],
  }) {
    final isWide = isWideScreen(context);

    if (isWide) {
      // On wide screens: show as non-blocking overlay that allows background interaction
      return showDialog(
        context: context,
        useRootNavigator: true,
        barrierDismissible: true,
        barrierColor:
            Colors.transparent, // Allow clicking through to background
        builder: (context) => _AnimatedThoughtPanel(
          initialMessage: initialMessage,
          attachedMessages: attachedMessages,
          attachedPosts: attachedPosts,
        ),
      );
    } else {
      // On mobile: show as full screen dialog
      return showDialog(
        context: context,
        useRootNavigator: true,
        barrierDismissible: true,
        barrierColor: Colors.black.withOpacity(0.6),
        builder: (context) => ThoughtSheet(
          initialMessage: initialMessage,
          attachedMessages: attachedMessages,
          attachedPosts: attachedPosts,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusAsync = ref.watch(thoughtAvailableStausProvider);
    final showSidebar = useState(false);

    // Create args for the chat notifier
    final args = ThoughtChatArgs(
      initialMessage: initialMessage,
      attachedMessages: attachedMessages,
      attachedPosts: attachedPosts,
    );

    // Watch the notifier
    final chatState = ref.watch(thoughtChatProvider(args));
    final chatNotifier = ref.read(thoughtChatProvider(args).notifier);

    void refreshStatus() => ref.invalidate(thoughtAvailableStausProvider);

    void startNewConversation() {
      chatNotifier.clearChat();
      showSidebar.value = false;
    }

    void toggleSidebar() => showSidebar.value = !showSidebar.value;

    void closeSidebar() => showSidebar.value = false;

    void handleServiceChanged(String serviceId) {
      final previousServiceId = chatState.selectedServiceId;
      if (serviceId == 'michan' && previousServiceId != 'michan') {
        chatNotifier.clearChat(selectedServiceId: serviceId);
        showSidebar.value = false;
        return;
      }

      chatNotifier.setSelectedServiceId(serviceId);
    }

    // Full screen for mobile dialog
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface),
      child: Scaffold(
        appBar: AppBar(
          title: Text(chatState.currentTopic ?? 'aiThought'.tr()),
          leading: IconButton(
            icon: const Icon(Symbols.close),
            onPressed: () => Navigator.of(context).pop(),
            tooltip: 'close'.tr(),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(52),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                child: ServiceSelector(
                  services: chatState.services,
                  selectedServiceId: chatState.selectedServiceId,
                  onServiceChanged: handleServiceChanged,
                  isStreaming: chatState.isStreaming,
                  isDisabled: statusAsync.value == false,
                ),
              ),
            ),
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
            selectedSequenceId: chatState.sequenceId,
            onClose: closeSidebar,
          ),
          mainContent: BillingStatusHandler(
            statusAsync: statusAsync,
            onRefreshStatus: refreshStatus,
            child: ThoughtChatInterface(
              initialMessage: initialMessage,
              attachedMessages: attachedMessages,
              attachedPosts: attachedPosts,
              isDisabled: statusAsync.value == false,
            ),
          ),
        ),
      ),
    );
  }
}

/// Animated wrapper for the thought panel with slide in/out animation.
class _AnimatedThoughtPanel extends StatefulWidget {
  final String? initialMessage;
  final List<Map<String, dynamic>> attachedMessages;
  final List<String> attachedPosts;

  const _AnimatedThoughtPanel({
    this.initialMessage,
    this.attachedMessages = const [],
    this.attachedPosts = const [],
  });

  @override
  State<_AnimatedThoughtPanel> createState() => _AnimatedThoughtPanelState();
}

class _AnimatedThoughtPanelState extends State<_AnimatedThoughtPanel>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0), // Start from right (off-screen)
      end: Offset.zero, // End at natural position
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.forward(); // Start slide in animation
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _dismiss() async {
    // Slide out animation
    await _controller.reverse();
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    const padding = 16.0;
    const panelWidth = 480.0;

    return Stack(
      children: [
        // Transparent background to catch taps outside
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: _dismiss,
          ),
        ),
        // Animated panel with padding from edges - aligned to right
        Align(
          alignment: Alignment.centerRight,
          child: AnimatedBuilder(
            animation: _slideAnimation,
            builder: (context, child) {
              // Slide in from right (off-screen) to visible position
              // _slideAnimation.value.dx goes from 1.0 (start) to 0.0 (end)
              // So at start: offset = panelWidth + padding (off-screen right)
              // At end: offset = 0 (visible)
              final slideOffset =
                  _slideAnimation.value.dx * (panelWidth + padding * 2);
              return Transform.translate(
                offset: Offset(slideOffset, 0),
                child: child,
              );
            },
            child: Padding(
              padding: const EdgeInsets.only(
                top: padding,
                bottom: padding,
                right: padding,
              ),
              child: _ThoughtPanel(
                initialMessage: widget.initialMessage,
                attachedMessages: widget.attachedMessages,
                attachedPosts: widget.attachedPosts,
                onClose: _dismiss,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// The floating panel widget for wide screens.
class _ThoughtPanel extends HookConsumerWidget {
  final String? initialMessage;
  final List<Map<String, dynamic>> attachedMessages;
  final List<String> attachedPosts;
  final VoidCallback onClose;

  const _ThoughtPanel({
    this.initialMessage,
    this.attachedMessages = const [],
    this.attachedPosts = const [],
    required this.onClose,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusAsync = ref.watch(thoughtAvailableStausProvider);
    final showSidebar = useState(false);

    // Create args for the chat notifier
    final args = ThoughtChatArgs(
      initialMessage: initialMessage,
      attachedMessages: attachedMessages,
      attachedPosts: attachedPosts,
    );

    // Watch the notifier
    final chatState = ref.watch(thoughtChatProvider(args));
    final chatNotifier = ref.read(thoughtChatProvider(args).notifier);

    // Panel width
    const panelWidth = 480.0;

    void refreshStatus() => ref.invalidate(thoughtAvailableStausProvider);

    void closeSidebar() => showSidebar.value = false;

    void handleServiceChanged(String serviceId) {
      final previousServiceId = chatState.selectedServiceId;
      if (serviceId == 'michan' && previousServiceId != 'michan') {
        chatNotifier.clearChat(selectedServiceId: serviceId);
        showSidebar.value = false;
        return;
      }

      chatNotifier.setSelectedServiceId(serviceId);
    }

    return Material(
      type: MaterialType.transparency,
      child: Container(
        width: panelWidth,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 16,
              offset: const Offset(-4, 0),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              automaticallyImplyLeading: false,
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(52),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: ServiceSelector(
                      services: chatState.services,
                      selectedServiceId: chatState.selectedServiceId,
                      onServiceChanged: handleServiceChanged,
                      isStreaming: chatState.isStreaming,
                      isDisabled: statusAsync.value == false,
                    ),
                  ),
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Symbols.close),
                  onPressed: onClose,
                  tooltip: 'close'.tr(),
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                const Gap(8),
              ],
            ),
            body: ResponsiveSidebar(
              showSidebar: showSidebar,
              sidebarWidth: 280,
              sidebarContent: ThoughtSidebar(
                selectedSequenceId: chatState.sequenceId,
                onClose: closeSidebar,
              ),
              mainContent: BillingStatusHandler(
                statusAsync: statusAsync,
                onRefreshStatus: refreshStatus,
                child: ThoughtChatInterface(
                  initialMessage: initialMessage,
                  attachedMessages: attachedMessages,
                  attachedPosts: attachedPosts,
                  isDisabled: statusAsync.value == false,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
