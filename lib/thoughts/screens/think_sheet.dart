import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/main.dart';
import 'package:island/shared/widgets/responsive_sidebar.dart';
import 'package:island/thoughts/screens/think.dart';
import 'package:island/thoughts/widgets/billing_status_handler.dart';
import 'package:island/thoughts/widgets/thought_chat_notifier.dart';
import 'package:island/thoughts/widgets/thought_shared.dart';
import 'package:island/thoughts/widgets/thought_sidebar.dart';
import 'package:material_symbols_icons/symbols.dart';

OverlayEntry? _thoughtOverlayEntry;

final _thoughtOverlayStateProvider =
    NotifierProvider<_ThoughtOverlayStateNotifier, _ThoughtOverlayState>(
      _ThoughtOverlayStateNotifier.new,
    );

class _ThoughtOverlayState {
  final Offset position;
  final Size size;

  const _ThoughtOverlayState({
    this.position = const Offset(8, 80),
    this.size = const Size(360, 480),
  });

  _ThoughtOverlayState copyWith({Offset? position, Size? size}) {
    return _ThoughtOverlayState(
      position: position ?? this.position,
      size: size ?? this.size,
    );
  }
}

class _ThoughtOverlayStateNotifier extends Notifier<_ThoughtOverlayState> {
  @override
  _ThoughtOverlayState build() => const _ThoughtOverlayState();

  void updatePosition(Offset delta) {
    state = state.copyWith(
      position: Offset(
        state.position.dx + delta.dx,
        state.position.dy + delta.dy,
      ),
    );
  }

  void updateSize(Size delta) {
    const minWidth = 320.0;
    const minHeight = 360.0;
    const maxWidth = 600.0;
    const maxHeight = 800.0;

    final newWidth = (state.size.width + delta.width).clamp(minWidth, maxWidth);
    final newHeight = (state.size.height + delta.height).clamp(
      minHeight,
      maxHeight,
    );
    state = state.copyWith(size: Size(newWidth, newHeight));
  }

  void setPosition(Offset position) {
    state = state.copyWith(position: position);
  }
}

void showThoughtOverlay({
  String? initialMessage,
  List<Map<String, dynamic>> attachedMessages = const [],
  List<String> attachedPosts = const [],
}) {
  if (_thoughtOverlayEntry != null) {
    _thoughtOverlayEntry?.markNeedsBuild();
    return;
  }

  final state = _overlayContainer.read(_thoughtOverlayStateProvider);
  _thoughtOverlayEntry = OverlayEntry(
    builder: (context) => _ThoughtOverlayPanel(
      initialPosition: state.position,
      initialSize: state.size,
      initialMessage: initialMessage,
      attachedMessages: attachedMessages,
      attachedPosts: attachedPosts,
    ),
  );
  globalOverlay.currentState?.insert(_thoughtOverlayEntry!);
}

void hideThoughtOverlay() {
  _thoughtOverlayEntry?.remove();
  _thoughtOverlayEntry = null;
}

void toggleThoughtOverlay({
  String? initialMessage,
  List<Map<String, dynamic>> attachedMessages = const [],
  List<String> attachedPosts = const [],
}) {
  if (_thoughtOverlayEntry != null) {
    hideThoughtOverlay();
  } else {
    showThoughtOverlay(
      initialMessage: initialMessage,
      attachedMessages: attachedMessages,
      attachedPosts: attachedPosts,
    );
  }
}

final ProviderContainer _overlayContainer = ProviderContainer();

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
    showThoughtOverlay(
      initialMessage: initialMessage,
      attachedMessages: attachedMessages,
      attachedPosts: attachedPosts,
    );
    return Future.value();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusAsync = ref.watch(thoughtAvailableStausProvider);
    final showSidebar = useState(false);

    final args = ThoughtChatArgs(
      initialMessage: initialMessage,
      attachedMessages: attachedMessages,
      attachedPosts: attachedPosts,
    );

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
      if (serviceId == chatState.selectedServiceId) return;
      chatNotifier.clearChat(selectedServiceId: serviceId);
      showSidebar.value = false;
    }

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
            onSequenceSelected: chatNotifier.loadConversation,
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

class _ThoughtOverlayPanel extends HookConsumerWidget {
  final Offset initialPosition;
  final Size initialSize;
  final String? initialMessage;
  final List<Map<String, dynamic>> attachedMessages;
  final List<String> attachedPosts;

  const _ThoughtOverlayPanel({
    required this.initialPosition,
    required this.initialSize,
    this.initialMessage,
    this.attachedMessages = const [],
    this.attachedPosts = const [],
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final showSidebar = useState(false);

    final position = useState(initialPosition);
    final size = useState(initialSize);
    final isInitialized = useState(false);

    final animController = useAnimationController(
      duration: const Duration(milliseconds: 300),
    );

    useEffect(() {
      animController.forward();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        isInitialized.value = true;
      });
      return animController.dispose;
    }, []);

    void onPanUpdate(DragUpdateDetails details) {
      final screenSize = MediaQuery.of(context).size;
      position.value = Offset(
        (position.value.dx + details.delta.dx).clamp(
          0,
          screenSize.width - size.value.width,
        ),
        (position.value.dy + details.delta.dy).clamp(
          0,
          screenSize.height - size.value.height,
        ),
      );
      ref
          .read(_thoughtOverlayStateProvider.notifier)
          .updatePosition(details.delta);
    }

    void onResizeUpdate(DragUpdateDetails details) {
      size.value = Size(
        (size.value.width + details.delta.dx).clamp(320.0, 600.0),
        (size.value.height + details.delta.dy).clamp(360.0, 800.0),
      );
    }

    void onResizeEnd(DragEndDetails details) {
      ref
          .read(_thoughtOverlayStateProvider.notifier)
          .updateSize(Size(size.value.width - 360, size.value.height - 480));
    }

    if (!isInitialized.value) {
      return const SizedBox.shrink();
    }

    return Positioned(
      left: position.value.dx,
      top: position.value.dy,
      child: Material(
        color: Colors.transparent,
        child: GestureDetector(
          onPanUpdate: onPanUpdate,
          child: SizedBox(
            width: size.value.width,
            height: size.value.height,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: _buildPanelContainer(context, ref, showSidebar),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: GestureDetector(
                    onPanUpdate: onResizeUpdate,
                    onPanEnd: onResizeEnd,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(8),
                          bottomRight: Radius.circular(16),
                        ),
                      ),
                      child: const Icon(Icons.drag_handle, size: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPanelContainer(
    BuildContext context,
    WidgetRef ref,
    ValueNotifier<bool> showSidebar,
  ) {
    final theme = Theme.of(context);
    final statusAsync = ref.watch(thoughtAvailableStausProvider);

    final args = ThoughtChatArgs(
      initialMessage: initialMessage,
      attachedMessages: attachedMessages,
      attachedPosts: attachedPosts,
    );

    final chatState = ref.watch(thoughtChatProvider(args));
    final chatNotifier = ref.read(thoughtChatProvider(args).notifier);

    void closeSidebar() => showSidebar.value = false;
    void refreshStatus() => ref.invalidate(thoughtAvailableStausProvider);

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 32,
            offset: const Offset(0, 12),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: theme.colorScheme.shadow.withOpacity(0.08),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            _buildHeader(context, chatState),
            Container(height: 1, color: theme.dividerColor),
            Expanded(
              child: ResponsiveSidebar(
                showSidebar: showSidebar,
                sidebarWidth: 280,
                sidebarContent: ThoughtSidebar(
                  selectedSequenceId: chatState.sequenceId,
                  onSequenceSelected: chatNotifier.loadConversation,
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
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, dynamic chatState) {
    final theme = Theme.of(context);

    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            theme.colorScheme.surfaceContainerHighest.withOpacity(0.7),
            theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
          ],
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 20,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.primary.withOpacity(0.6),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          Icon(Symbols.psychology, size: 18, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              chatState.currentTopic ?? 'aiThought'.tr(),
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            icon: const Icon(Symbols.close),
            onPressed: () => hideThoughtOverlay(),
            tooltip: 'close'.tr(),
            color: theme.colorScheme.onSurface,
          ),
        ],
      ),
    );
  }
}
